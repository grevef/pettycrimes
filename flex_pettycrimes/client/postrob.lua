if not Config.PostRob.Enable then return end

local BoxZones, Boxes = {}, {}
local Targets = {}
local IsInBoxZone = false

local function RegisterZones()
    for k, v in pairs(Config.PostRob.Zones) do
        BoxZones[#BoxZones+1] = PolyZone:Create(v.zone, {
            name = "PackageBoxZone"..k,
            debugPoly = Config.Debug
        })
        BoxZones[#BoxZones]:onPlayerInOut(function(isPointInside)
            IsInBoxZone = isPointInside
            if isPointInside then
                for id, v in pairs(v.packages) do
                    if not lib.callback.await('flex_pettycrimes:server:IsPackageStolen', false, v) then
                        local BoxModel = Config.PostRob.Boxes[math.random(1, #Config.PostRob.Boxes)]
                        local box = CreateObject(GetHashKey(BoxModel), v.x, v.y, v.z-1, false, true, true)
                        Boxes[#Boxes+1] = box
                        SetEntityHeading(box, v.w)
                        PlaceObjectOnGroundProperly(box)
                        FreezeEntityPosition(box, true)
                        Targets[#Targets+1] = exports.ox_target:addLocalEntity(box, {
                            {
                                name = "flex_pettycrimes_boxes"..k,
                                icon = "fa-solid fa-dolly",
                                label = Language.target.stealbox,
                                canInteract = function(entity, distance, coords, name)
                                    return IsInBoxZone
                                end,
                                onSelect = function(data)
                                    local BoxCoords = GetEntityCoords(data.entity)
                                    TaskTurnPedToFaceCoord(cache.ped, BoxCoords, 1000)
                                    Wait(1000)
                                    lib.playAnim(cache.ped, 'pickup_object', 'pickup_low', 8.0, -8.0, -1, 1, 0, false, false, false)
                                    TriggerServerEvent('flex_pettycrimes:server:StealBox', k, id, BoxCoords)
                                    Wait(1000)
                                    ClearPedTasks(cache.ped)
                                    if Config.PostRob.PoliceChance and math.random(0, 100) <= Config.PostRob.PoliceChance then
                                        local playerCoords = GetEntityCoords(cache.ped)
                                        local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                        local streetName = GetStreetNameFromHashKey(streetHash)
                                        Config.PoliceNotify.client(playerCoords, streetName, Language.dispatch.postrob)
                                    end
                                end,
                                distance = 2.0
                            },
                        })
                    end
                end
            else
                for k, v in pairs(Targets) do
                    exports.ox_target:removeLocalEntity(v)
                end
                for k, v in pairs(Boxes) do
                    if DoesEntityExist(v) then
                        DeleteEntity(v)
                    end
                end
            end
        end)
    end
end

RegisterNetEvent("flex_pettycrimes:client:RemoveBox", function(coords)
    if not IsInBoxZone then return end
    for k, box in pairs(Boxes) do
        if #(GetEntityCoords(box) - coords) < 0.5 then
            exports.ox_target:removeLocalEntity(box, "flex_pettycrimes_boxes"..k)
            if DoesEntityExist(box) then
                DeleteEntity(box)
            end
            table.remove(Boxes, k)
        end
    end
end)

RegisterNetEvent("flex_pettycrimes:client:ExplodeBox", function()
    local pedCoords = GetEntityCoords(cache.ped)
    local box = GetClosestObjectOfType(
        pedCoords.x,
        pedCoords.y,
        pedCoords.z,
        3.0,
        GetHashKey('hei_prop_heist_box'),
        false,
        false,
        false
    )
    if box == 0 then return end
    local boxCoords = GetEntityCoords(box)

    local force = 100.0
    local dir = pedCoords - boxCoords
    dir = dir / #(dir)

    SetPedToRagdoll(cache.ped, Config.PostRob.RagdollDuration * 1000, Config.PostRob.RagdollDuration * 1000, 0, false, false, false)
    ApplyForceToEntity(
        cache.ped, 1,
        dir.x * force, dir.y * force, 2.0 * force,
        0.0, 0.0, 0.0,
        0, false, true, true, false, true
    )

    TriggerServerEvent('flex_pettycrimes:server:ExplodeBoxEffect', boxCoords)
end)

RegisterNetEvent("flex_pettycrimes:client:ExplodeBoxEffect", function(coords)
    if #(GetEntityCoords(cache.ped) - coords.xyz) > 50.0 then return end
    local soundId = GetSoundId()
    if Config.PostRob.ExplosionSound then
        PlaySoundFromCoord(soundId, "collect_part", coords.x, coords.y, coords.z, "DLC_sum20_BB_Captured_Sounds", false, 15, false)
    end
    local dict = "scr_rcbarry2"
    local particle = "scr_clown_appears"
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end
    UseParticleFxAssetNextCall(dict)
    StartParticleFxNonLoopedAtCoord(
        particle,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        0.4, false, false, false
    )
    if Config.PostRob.ExplosionSound then
        Wait(1000)
        StopSound(soundId)
    end
end)

local function UnloadEvent()
    for k, v in pairs(Boxes) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in pairs(BoxZones) do
        v:destroy()
    end
    for k, v in pairs(Targets) do
        exports.ox_target:removeLocalEntity(v, "flex_pettycrimes_boxes"..k)
    end
end

RegisterNetEvent(Config.Events.unload, function()
    UnloadEvent()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        UnloadEvent()
    end
end)

RegisterNetEvent(Config.Events.load, function()
    RegisterZones()
end)