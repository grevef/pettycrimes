if not Config.SmashGrab.Enabled then return end

local GeneratedBags = {}
local RegisteredCars = {}
local Vehicles = {}
local BagHashes = {}
local BoxZones, IsInBoxZone = {}, false
for _, bagModel in ipairs(Config.SmashGrab.Bags) do
    BagHashes[GetHashKey(bagModel)] = true
end

-- Create a unique identifier for vehicles
function GetVehicleIdentifier(vehicle)
    if not DoesEntityExist(vehicle) then return nil end
    return tostring(vehicle)
end

function GetSeatWorldPosition(vehicle, seatIndex)
    if not DoesEntityExist(vehicle) then return nil end

    local boneNames = {
        [-1] = "seat_dside_f",   -- Driver
        [0]  = "seat_pside_f",   -- Front passenger
        [1]  = "seat_dside_r",   -- Rear left
        [2]  = "seat_pside_r",   -- Rear right
        [3]  = "seat_dside_r1",  -- Extra seats (some vehicles)
        [4]  = "seat_pside_r1",
        [5]  = "extra_1",        -- Additional fallback bones
        [6]  = "extra_2",
        [7]  = "extra_3",
        [8]  = "extra_4"
    }

    local boneName = boneNames[seatIndex]
    if not boneName then return nil end

    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    if boneIndex == -1 then
        -- Try alternative bone names for different vehicle types
        if seatIndex == 1 then boneName = "seat_dside_r1" end
        if seatIndex == 2 then boneName = "seat_pside_r1" end
        boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex == -1 then return nil end
    end

    return GetWorldPositionOfEntityBone(vehicle, boneIndex), boneName
end

function VehicleWindowIntact(vehicle)
    if not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then
        return false
    end
    
    -- Window indices: 0=front right, 1=rear right, 2=rear left, 3=front left
    local intactWindows = 0
    local totalSideWindows = 0
    
    -- Check each possible side window
    for i = 0, 3 do
        local windowState = IsVehicleWindowIntact(vehicle, i)
        
        -- If window exists (not nil) and is intact
        if windowState ~= nil then
            totalSideWindows = totalSideWindows + 1
            if windowState then
                intactWindows = intactWindows + 1
            end
        end
    end
    
    -- Return true only if ALL existing side windows are intact
    return intactWindows == totalSideWindows
end

function HasBagInVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    
    -- First check if bag is attached to vehicle
    for _, v in pairs(GeneratedBags) do
        if v ~= nil and NetworkDoesNetworkIdExist(v) then
            local bag = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(bag) and GetEntityAttachedTo(bag) == vehicle then
                return true
            end
        end
    end
    
    for _, obj in pairs(GetGamePool("CObject")) do
        if DoesEntityExist(obj) and GetEntityAttachedTo(obj) == vehicle then
            local model = GetEntityModel(obj)
            for _, bagModel in ipairs(Config.SmashGrab.Bags) do
                if model == GetHashKey(bagModel) then
                    return true
                end
            end
        end
    end
    return false
end

function VehicleHasBackseats(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    
    -- Check for various rear seat bone names
    local rearSeatBones = {"seat_dside_r", "seat_pside_r", "seat_dside_r1", "seat_pside_r1", "seat_r"}
    
    for _, boneName in ipairs(rearSeatBones) do
        if GetEntityBoneIndexByName(vehicle, boneName) ~= -1 then
            return true
        end
    end
    
    return false
end

function IsBagNearby(coords)
    -- Get all objects in the game world
    local objects = GetGamePool('CObject')
    
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            local objectModel = GetEntityModel(object)
            
            -- Check if this is a valid bag
            if BagHashes[objectModel] then
                local objectCoords = GetEntityCoords(object)
                if #(coords - objectCoords) < 3.0 then
                    return true
                end
            end
        end
    end
    return false
end

function GetNearbyBag(coords)
    -- Get all objects in the game world
    local objects = GetGamePool('CObject')
    
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            local objectModel = GetEntityModel(object)
            
            -- Check if this is a valid bag
            if BagHashes[objectModel] then
                local objectCoords = GetEntityCoords(object)
                if #(coords - objectCoords) < 3.0 then
                    return object
                end
            end
        end
    end
    return nil
end

function IsVehicleEmpty(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    
    -- Check all seats
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if GetPedInVehicleSeat(vehicle, i) ~= 0 then
            return false
        end
    end
    
    return true
end

function IsVehicleParked(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return false
    end
    
    -- Check if vehicle is stationary
    local speed = GetEntitySpeed(vehicle)
    local isStopped = IsVehicleStopped(vehicle)
    local onWheels = IsVehicleOnAllWheels(vehicle)
    local isEmpty = IsVehicleEmpty(vehicle)
    
    return speed < 0.1 and isStopped and onWheels and isEmpty
end

RegisterNetEvent(Config.Events.load, function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(300)
    end
    Wait(5000)
    for k, v in pairs(Config.SmashGrab.Zones) do
        BoxZones[k] = PolyZone:Create(v, {
            name = "GrabBagBoxZone"..k,
            debugPoly = Config.Debug
        })
        BoxZones[k]:onPlayerInOut(function(isPointInside)
            IsInBoxZone = isPointInside
            if isPointInside then
                CreateThread(function()
                    while IsInBoxZone do
                        Wait(5000)
                        local playerCoords = GetEntityCoords(cache.ped)
                        local vehicles = GetGamePool("CVehicle")
                        
                        for _, vehicle in ipairs(vehicles) do
                            if not IsEntityAVehicle(vehicle) then goto continue end
                            
                            while not DoesEntityExist(vehicle) do
                                Wait(100)
                            end
                            
                            local vehicleIdentifier = GetVehicleIdentifier(vehicle)
                            if not vehicleIdentifier then
                                goto continue
                            end
                            
                            local vehicleCoords = GetEntityCoords(vehicle)
                            local distance = #(vehicleCoords - playerCoords)
                            local class = GetVehicleClass(vehicle)
                            if distance < Config.SmashGrab.SpawnBagRadius
                                and not GetIsVehicleEngineRunning(vehicle)
                                and GetVehicleDoorLockStatus(vehicle) < 2
                                and VehicleWindowIntact(vehicle)
                                and not HasBagInVehicle(vehicle)
                                and not Vehicles[vehicleIdentifier]
                                and not IsBagNearby(vehicleCoords)
                                and IsVehicleParked(vehicle)
                                and class ~= 18 -- not emergency vehicle
                                and not lib.callback.await('flex_pettycrimes:server:IsVehicleOwned', 1000, GetVehicleNumberPlateText(vehicle))
                            then
                                local bagModel = Config.SmashGrab.Bags[math.random(1, #Config.SmashGrab.Bags)]
                                if bagModel then
                                    local bagOffset = Config.SmashGrab.BagOffset[bagModel] or {vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 0.0)}
                                    local bagHash = GetHashKey(bagModel)
                                    lib.requestModel(bagHash)
            
                                    -- Try different seat positions
                                    local bagPos, boneName
                                    
                                    if VehicleHasBackseats(vehicle) then
                                        -- Prefer back seats if available
                                        bagPos, boneName = GetSeatWorldPosition(vehicle, math.random(1, 2))
                                    else
                                        -- Use front passenger seat if no back seats
                                        bagPos, boneName = GetSeatWorldPosition(vehicle, 0)
                                    end
                                    
                                    -- If that seat doesn't exist, try others
                                    if not bagPos or not boneName then
                                        for i = -1, 4 do
                                            bagPos, boneName = GetSeatWorldPosition(vehicle, i)
                                            if bagPos and boneName then break end
                                        end
                                    end
            
                                    if not bagPos or not boneName then
                                        goto continue
                                    end
            
                                    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
                                    if boneIndex == -1 then
                                        goto continue
                                    end
            
                                    local CreatedBag = CreateObject(bagHash, bagPos.x, bagPos.y, bagPos.z, true, true, true)
                                    if not DoesEntityExist(CreatedBag) then
                                        goto continue
                                    end
            
                                    if not DoesEntityExist(vehicle) then
                                        DeleteEntity(CreatedBag)
                                        goto continue
                                    end
            
                                    SetEntityAsMissionEntity(CreatedBag, true, true)
                                    AttachEntityToEntity(
                                        CreatedBag, vehicle, boneIndex,
                                        bagOffset[1].x, bagOffset[1].y, bagOffset[1].z,
                                        bagOffset[2].x, bagOffset[2].y, bagOffset[2].z,
                                        false, false, false, false, 2, true
                                    )
            
                                    TriggerServerEvent('flex_pettycrimes:server:RegisterBag', NetworkGetNetworkIdFromEntity(CreatedBag))
                                    SetVehicleDoorsLocked(vehicle, 2)
                                    Vehicles[vehicleIdentifier] = true
                                end
                            elseif HasBagInVehicle(vehicle) and not Vehicles[vehicleIdentifier] then
                                Vehicles[vehicleIdentifier] = true
                            end
                            ::continue::
                        end
                    end
                end)
                CreateThread(function()
                    exports.ox_target:addGlobalVehicle({
                        {
                            name = 'flex_pettycrimes:grabbag',
                            icon = 'fas fa-closed-captioning',
                            label = Language.target.grabbag,
                            distance = 4.5,
                            offset = vec3(0.5, 0.5, 0.5),
            
                            canInteract = function(entity)
                                if not DoesEntityExist(entity) or not IsEntityAVehicle(entity) then return false end
            
                                local vehicleIdentifier = GetVehicleIdentifier(entity)
                                if not vehicleIdentifier then return false end
            
                                if lib.table.contains(RegisteredCars, vehicleIdentifier) then return false end
            
                                -- local hasBag = HasBagInVehicle(entity)
                                local hasBagNear = IsBagNearby(GetEntityCoords(entity))
                                return IsEntityAVehicle(entity) and not VehicleWindowIntact(entity) and hasBagNear
                            end,
            
                            onSelect = function(data)
                                local vehicle = data.entity
                                while not DoesEntityExist(vehicle) do
                                    Wait(1000)
                                end
                                local vehicleIdentifier = GetVehicleIdentifier(vehicle)
                                local vehicleCoords = GetEntityCoords(vehicle)
                                local foundBagEntity = nil
                                
                                for _, v in pairs(GeneratedBags) do
                                    if v ~= nil and NetworkDoesNetworkIdExist(v) then
                                        local bag = NetworkGetEntityFromNetworkId(v)
                                        if DoesEntityExist(bag) and GetEntityAttachedTo(bag) == vehicle then
                                            foundBagEntity = bag
                                            break
                                        end
                                    end
                                end
            
                                if not foundBagEntity then
                                    for _, v in pairs(GeneratedBags) do
                                        if v ~= nil and NetworkDoesNetworkIdExist(v) then
                                            local bag = NetworkGetEntityFromNetworkId(v)
                                            if DoesEntityExist(bag) and #(GetEntityCoords(bag) - vehicleCoords) < 2.5 then
                                                foundBagEntity = bag
                                                break
                                            end
                                        end
                                    end
                                end
            
                                if not foundBagEntity then
                                    return
                                end
            
                                TriggerServerEvent('flex_pettycrimes:server:SetRobState', vehicleIdentifier, true)
            
                                local success = lib.progressBar({
                                    duration = 1000 * Config.SmashGrab.StealTime,
                                    label = Language.progress.grabbing,
                                    useWhileDead = false,
                                    canCancel = true,
                                    anim = {
                                        dict = 'missexile3',
                                        clip = 'ex03_dingy_search_case_base_michael'
                                    },
                                    disable = {
                                        move = true,
                                        car = true,
                                        mouse = false,
                                        combat = true
                                    }
                                })
            
                                ClearPedTasks(cache.ped)
            
                                if success then
                                    TriggerServerEvent('flex_pettycrimes:server:RemoveBag', GetEntityCoords(foundBagEntity))
            
                                    if Config.SmashGrab.PoliceChance and math.random(0, 100) <= Config.SmashGrab.PoliceChance then
                                        local playerCoords = GetEntityCoords(cache.ped)
                                        local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                        local streetName = GetStreetNameFromHashKey(streetHash)
                                        Config.PoliceNotify.client(playerCoords, streetName, Language.dispatch.smahgrab)
                                    end
                                else
                                    TriggerServerEvent('flex_pettycrimes:server:SetRobState', vehicleIdentifier, false)
                                end
                            end,
                        }
                    })
                end)
            else
                for k, v in pairs(GeneratedBags) do
                    if v ~= nil and NetworkDoesNetworkIdExist(v) then
                        local bag = NetworkGetEntityFromNetworkId(v)
                        if DoesEntityExist(bag) then
                            DeleteEntity(bag)
                        end
                    end
                end
                exports.ox_target:removeGlobalVehicle('flex_pettycrimes:grabbag')
            end
        end)
    end
end)

RegisterNetEvent("flex_pettycrimes:client:RegisterBag", function(NetId)
    GeneratedBags[#GeneratedBags + 1] = NetId
end)

RegisterNetEvent("flex_pettycrimes:client:SetRobState", function(id, state)
    if state then
        RegisteredCars[#RegisteredCars+1] = id
    else
        for k, car in pairs(RegisteredCars) do
            if car == id then
                table.remove(RegisteredCars, k)
            end
        end
    end
end)

RegisterNetEvent("flex_pettycrimes:client:RemoveBag", function(coords)
    for i = #GeneratedBags, 1, -1 do
        if GeneratedBags[i] ~= nil and NetworkDoesNetworkIdExist(GeneratedBags[i]) then
            local bag = NetworkGetEntityFromNetworkId(GeneratedBags[i])
            if DoesEntityExist(bag) and #(GetEntityCoords(bag) - coords) < 1.0 then
                DeleteEntity(bag)
                table.remove(GeneratedBags, i)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(GeneratedBags) do
            if v ~= nil and NetworkDoesNetworkIdExist(v) then
                local bag = NetworkGetEntityFromNetworkId(v)
                if DoesEntityExist(bag) then
                    DeleteEntity(bag)
                end
            end
        end
        exports.ox_target:removeGlobalVehicle('flex_pettycrimes:grabbag')
    end
end)

RegisterNetEvent(Config.Events.unload, function()
    for k, v in pairs(GeneratedBags) do
        if v ~= nil and NetworkDoesNetworkIdExist(v) then
            local bag = NetworkGetEntityFromNetworkId(v)
            if DoesEntityExist(bag) then
                DeleteEntity(bag)
            end
        end
    end
    exports.ox_target:removeGlobalVehicle('flex_pettycrimes:grabbag')
end)