if not Config.StealTyres.Enabled then return end

local Wheels = {
    "wheel_lf",      -- Front Left Tyre
    "wheel_rf",      -- Front Right Tyre
    "wheel_lr",      -- Rear Left
    "wheel_rr",      -- Rear Right
}

local WheelIndexes = {
    ["wheel_lf"] = 0,  -- Front Left
    ["wheel_rf"] = 1,  -- Front Right
    ["wheel_lr"] = 2,  -- Rear Left
    ["wheel_rr"] = 3,  -- Rear Right
}

function GetClosestWheelBone(vehicle)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pos = nil
    local closestBone = nil
    local closestDist = math.huge

    for _, boneName in ipairs(Wheels) do
        local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
        if boneIndex ~= -1 then
            local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
            local dist = #(pedCoords - bonePos)
            if dist < closestDist then
                closestDist = dist
                closestBone = boneName
                pos = bonePos
            end
        end
    end

    return closestBone, pos
end

RegisterNetEvent(Config.Events.load, function()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'flex_pettycrimes_stealtyres',
            icon = "fa-solid fa-screwdriver-wrench",
            label = Language.target.stealtyre,
            items = {Config.StealTyres.StealTool} or nil,
            distance = 1.0,
            canInteract = function()
                local ped = PlayerPedId()
                return not IsEntityPlayingAnim(ped, 'anim@heists@box_carry@', 'idle', 3)
            end,
            onSelect = function(data)
                local ped = PlayerPedId()
                local closestWheel, WheelPos = GetClosestWheelBone(data.entity)
                if closestWheel then
                    TaskTurnPedToFaceCoord(ped, WheelPos.x, WheelPos.y, WheelPos.z, 1000)
                    Wait(1000)
                    lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
                    if lib.progressBar({
                        duration = 1000 * Config.StealTyres.ProgressTime,  
                        label = Language.progress.stealtyre,      
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            mouse = false,
                            combat = true
                        } 
                    }) then
                        NetworkRegisterEntityAsNetworked(data.entity)
                        local NetWorkId = NetworkGetNetworkIdFromEntity(data.entity)
                        if NetWorkId then
                            TriggerServerEvent('flex_pettycrimes:server:BreakTyre', NetWorkId, closestWheel)
                            if Config.StealTyres.PoliceChance and math.random(0, 100) <= Config.StealTyres.PoliceChance then
                                local playerCoords = GetEntityCoords(ped)
                                local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
                                local streetName = GetStreetNameFromHashKey(streetHash)
                                Config.PoliceNotify.client(playerCoords, streetName, Language.dispatch.stealtyre)
                            end
                        end
                    end
                    ClearPedTasks(ped)
                end
            end,
        }
    })
end)

RegisterNetEvent("flex_pettycrimes:client:BreakTyre", function(NetId, bone)
    local vehicle = NetworkGetEntityFromNetworkId(NetId)
    if DoesEntityExist(vehicle) then
        local wheelIndex = WheelIndexes[bone]
        if wheelIndex ~= nil then
            SetVehicleWheelHealth(vehicle, wheelIndex, 0)
            BreakOffVehicleWheel(vehicle, wheelIndex, true, true, true, false)
            ApplyForceToEntity(vehicle, 1, 1, 1, 1, 1, 10, true, true, true, false, true, false, false)
        end
    end
end)

RegisterNetEvent(Config.Events.unload, function()
    exports.ox_target:removeGlobalVehicle('flex_pettycrimes_stealtyres')
end)