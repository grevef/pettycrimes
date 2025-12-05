if not Config.GraveRob.Enable then return end

local IsPlayerDigging, IsPlayerRobbing = false, false
local GraveZones, Targets = {}, {}
local Coffins, Peds = {}, {}

local function LoadModel(model) RequestModel(model) while not HasModelLoaded(model) do Wait(0) end end
local function RemoveWeapon(npc)
    for k, v in pairs(Config.GraveRob.PedWeapons) do
        RemoveWeaponFromPed(npc, v)
    end
end
local function MakePedHatePlayer(npc)
    local RandomPedWeapon = math.random(1,#Config.GraveRob.PedWeapons)
    GiveWeaponToPed(npc, GetHashKey(Config.GraveRob.PedWeapons[RandomPedWeapon]), 0, false, false)
    SetCurrentPedWeapon(npc, GetHashKey(Config.GraveRob.PedWeapons[RandomPedWeapon]), true)
    SetPedMaxHealth(npc, 200)
    SetPedArmour(npc, 200)
    SetCanAttackFriendly(npc, false, true)
    TaskCombatPed(npc, PlayerPedId(), 0, 16)
    SetPedCombatAttributes(npc, 46, true)
    SetPedCombatAttributes(npc, 0, false)
    SetPedCombatAbility(npc, 100)
    SetPedAsCop(npc, true)
    SetPedRelationshipGroupHash(npc, `HATES_PLAYER`)
    SetPedAccuracy(npc, 60)
    SetPedFleeAttributes(npc, 0, 0)
    SetPedKeepTask(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end

local function RegisterGraveZones()
    for k, v in pairs(Config.GraveRob.GraveZones) do
        GraveZones[#GraveZones+1] = PolyZone:Create(v.zone, {
            name = "GraveZone"..k,
            debugPoly = Config.Debug
        })
        GraveZones[#GraveZones]:onPlayerInOut(function(isPointInside)
            IsInBoxZone = isPointInside
            if isPointInside then
                for id, grave in pairs(v.graves) do
                    if not lib.callback.await('flex_pettycrimes:server:IsGraveDigged', false, k, id) then
                        Targets[#Targets+1] = exports.ox_target:addBoxZone({
                            name = 'GraveBoxZone'..id,
                            coords = vec3(grave.coords.x, grave.coords.y, grave.coords.z-1),
                            size = vec3(1.5, 1.5, 1.5),
                            rotation = grave.coords.w,
                            debug = Config.Debug,
                            options = {
                                {
                                    icon = "fa-brands fa-digg",
                                    label = Language.target.diggrave,
                                    distance = 1.5,
                                    items = Config.GraveRob.DigItem,
                                    onSelect = function()
                                        local ped = PlayerPedId()
                                        IsPlayerRobbing = true
                                        local Coffin = CreateObject(GetHashKey('prop_coffin_02'), grave.coords.x, grave.coords.y, grave.coords.z-2, true, true, true)
                                        Coffins[#Coffins+1] = Coffin
                                        FreezeEntityPosition(Coffin, true)
                                        SetEntityHeading(Coffin, grave.coords.w+180.0)

                                        IsPlayerDigging = true

                                        TaskTurnPedToFaceCoord(ped, grave.coords.x, grave.coords.y, grave.coords.z, 1000)
                                        Wait(1000)

                                        lib.playAnim(ped, "random@burial", "a_burial", 3.0, 3.0, -1, 1)

                                        CreateThread(function()
                                            local startZ = grave.coords.z - 1
                                            local endZ = grave.coords.z
                                            local duration = 1000 * Config.GraveRob.DigTime -- ms
                                            local interval = 50 -- ms
                                            local steps = duration / interval
                                            local stepAmount = (endZ - startZ) / steps
                                            local currentStep = 0

                                            while IsPlayerDigging and currentStep < steps do
                                                local coords = GetEntityCoords(Coffin)
                                                SetEntityCoords(Coffin, coords.x, coords.y, coords.z + stepAmount)
                                                currentStep = currentStep + 1
                                                Wait(interval)
                                            end
                                            local coords = GetEntityCoords(Coffin)
                                            if coords.z < endZ then
                                                SetEntityCoords(Coffin, coords.x, coords.y, endZ-.8)
                                                SetEntityHeading(Coffin, grave.coords.w+180.0+math.random(-10, 10))
                                                PlaceObjectOnGroundProperly(Coffin)
                                            end
                                        end)
                                        if lib.progressBar({
                                            duration = 1000 * Config.GraveRob.DigTime,  
                                            label = Language.progress.digging,      
                                            useWhileDead = false,
                                            canCancel = true,
                                            disable = {
                                                move = true,
                                                car = true,
                                                mouse = false,
                                                combat = true
                                            },
                                            prop = {
                                                model = 'prop_tool_shovel',
                                                bone = 28422,
                                                pos = {
                                                    x = 0.0,
                                                    y = 0.0,
                                                    z = 0.24,
                                                },
                                                rot = {
                                                    x = 0.0,
                                                    y = 0.0,
                                                    z = 0.0
                                                },
                                            }
                                        }) then
                                            ClearPedTasks(ped)
                                            IsPlayerDigging = false
                                            TriggerServerEvent('flex_pettycrimes:server:SetGraveRobState', k, id, true)
                                            if Config.GraveRob.PoliceChance and math.random(0, 100) <= Config.GraveRob.PoliceChance then
                                                local playerCoords = GetEntityCoords(ped)
                                                local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                                local streetName = GetStreetNameFromHashKey(streetHash)
                                                Config.PoliceNotify.client(playerCoords, streetName, Language.dispatch.GraveRob)
                                            end
                                        else
                                            ClearPedTasks(ped)
                                            if DoesEntityExist(Coffin) then
                                                DeleteEntity(Coffin)
                                            end
                                        end
                                    end,
                                    canInteract = function(data, distance)
                                        return not grave.robbed and not IsPlayerRobbing
                                    end
                                },
                                {
                                    icon = "fa-solid fa-magnifying-glass",
                                    label = Language.target.searchgrave,
                                    distance = 1.5,
                                    onSelect = function()
                                        local ped = PlayerPedId()
                                        TaskTurnPedToFaceCoord(ped, grave.coords.x, grave.coords.y, grave.coords.z, 1000)
                                        Wait(1000)
                                        lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
                                        if lib.progressBar({
                                            duration = 1000 *Config.GraveRob.SearchTime,  
                                            label = Language.progress.searchgrave,      
                                            useWhileDead = false,
                                            canCancel = false,
                                            disable = {
                                                move = true,
                                                car = true,
                                                mouse = false,
                                                combat = true
                                            } 
                                        }) then
                                            ClearPedTasks(ped)
                                            IsPlayerRobbing = false
                                            for k, v in pairs(Coffins) do
                                                if DoesEntityExist(v) then
                                                    DeleteEntity(v)
                                                end
                                            end
                                            if math.random(100) < Config.GraveRob.PedChance then
                                                LoadModel('u_f_y_corpse_01')
                                                local npc = CreatePed(0, 'u_f_y_corpse_01', grave.coords.x+math.random(-20, 20), grave.coords.y+math.random(-20, 20), grave.coords.z, true, true)
                                                Peds[#Peds+1] = npc
                                                PlaceObjectOnGroundProperly(npc)
                                                -- SetEntityAlpha(npc, 150, false)
                                                MakePedHatePlayer(npc)
                                                local PedTarget = exports.ox_target:addLocalEntity(npc, {
                                                    {
                                                        icon = "fa-solid fa-magnifying-glass",
                                                        label = Language.target.takedeadstuff,
                                                        onSelect = function()
                                                            local coords = GetEntityCoords(npc)
                                                            TaskTurnPedToFaceCoord(ped, coords.x, coords.y, coords.z, 1000)
                                                            Wait(1000)
                                                            lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
                                                            exports.ox_target:removeLocalEntity(npc)
                                                            if lib.progressBar({
                                                                duration = 1000 *Config.GraveRob.SearchTime,  
                                                                label = Language.progress.takedeadstuff,      
                                                                useWhileDead = false,
                                                                canCancel = false,
                                                                disable = {
                                                                    move = true,
                                                                    car = true,
                                                                    mouse = false,
                                                                    combat = true
                                                                } 
                                                            }) then
                                                                ClearPedTasks(ped)
                                                                if DoesEntityExist(npc) then
                                                                    SetModelAsNoLongerNeeded('u_f_y_corpse_01')
                                                                    RemoveWeapon(npc)
                                                                    DeleteEntity(npc)
                                                                end
                                                                TriggerServerEvent('flex_pettycrimes:server:GravePedLoot')
                                                            end
                                                        end,
                                                        canInteract = function(data, distance)
                                                            return GetEntityHealth(npc) <= 1
                                                        end,
                                                        distance = 2.0,
                                                    }
                                                })
                                                CreateThread(function()
                                                    SetTimeout(1000*60*Config.GraveRob.ResetTime, function()
                                                        if DoesEntityExist(npc) then
                                                            SetModelAsNoLongerNeeded('u_f_y_corpse_01')
                                                            RemoveWeapon(npc)
                                                            DeleteEntity(npc)
                                                        end
                                                    end)
                                                end)
                                            else
                                                TriggerServerEvent('flex_pettycrimes:server:GraveLoot')
                                            end
                                        end
                                    end,
                                    canInteract = function(data, distance)
                                        return grave.robbed and IsPlayerRobbing
                                    end
                                },
                            }
                        })
                    end
                end
            else
                for k, v in pairs(Targets) do
                    exports.ox_target:removeZone(v)
                end
                IsPlayerRobbing = false
                for k, v in pairs(Coffins) do
                    if DoesEntityExist(v) then
                        RemoveWeapon(v)
                        DeleteEntity(v)
                    end
                end
            end
        end)
    end
end

RegisterNetEvent("flex_pettycrimes:client:SetGraveRobState", function(id, grave, state)
    Config.GraveRob.GraveZones[id].graves[grave].robbed = state
end)

local function UnloadGraveEvent()
    for k, v in pairs(GraveZones) do
        v:destroy()
    end
    for k, v in pairs(Targets) do
        exports.ox_target:removeZone(v)
    end
    for k, v in pairs(Coffins) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in pairs(Peds) do
        if DoesEntityExist(v) then
            RemoveWeapon(v)
            DeleteEntity(v)
        end
    end
end

RegisterNetEvent(Config.Events.unload, function()
    UnloadGraveEvent()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        UnloadGraveEvent()
    end
end)

RegisterNetEvent(Config.Events.load, function()
    Config.GraveRob = lib.callback.await('flex_pettycrimes:server:GetGraveConfig', 1000)
    RegisterGraveZones()
end)