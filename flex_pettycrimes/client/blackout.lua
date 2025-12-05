if not Config.BlackOut.Enable then return end

local TargetZones = {}
local BlackOutZones = {}
local CanStartBlackOut = false

RegisterNetEvent(Config.Events.load, function()
    Wait(5000)
    Config.BlackOut.HackLocations = lib.callback.await('flex_pettycrimes:server:GetBlackOutConfig', false)
    CanStartBlackOut = lib.callback.await('flex_pettycrimes:server:CanStartBlackOut', false)

    for k, v in pairs(Config.BlackOut.HackLocations) do
        BlackOutZones[#BlackOutZones+1] = BoxZone:Create(vector3(v[1].x, v[1].y, v[1].z), 10, 10, {
            name = "BlackOutZones"..k,
            debugPoly = Config.Debug
        })
        BlackOutZones[#BlackOutZones]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                -- local closestElecBox = GetClosestObjectOfType(
                --     v[1].x,
                --     v[1].y,
                --     v[1].z,
                --     5.0,
                --     GetHashKey('tr_prop_tr_elecbox_01a'),
                --     false,
                --     false,
                --     false
                -- )
                -- NetworkRegisterEntityAsNetworked(closestElecBox)
                -- NetworkRequestControlOfEntity(closestElecBox)
                -- while not NetworkHasControlOfEntity(closestElecBox) and timeout < 100 do
                --     Wait(10)
                --     NetworkRequestControlOfEntity(closestElecBox)
                -- end
                -- SetEntityRemoteSyncedScenesAllowed(closestElecBox, true)
                
                local targetPosition, targetRotation, targetHeading = GetEntityCoords(closestElecBox), GetEntityRotation(closestElecBox), GetEntityHeading(closestElecBox)
        
                TargetZones[#TargetZones+1] = exports.ox_target:addBoxZone({
                    name = "blackoutzone_"..k,
                    coords = vec3(targetPosition.x, targetPosition.y, targetPosition.z+1.3),
                    size = vec3(1.0, 0.7, 2.0),
                    rotation = targetHeading,
                    debug = Config.Debug,
                    drawSprite = true,
                    options = {
                        {
                            name = "blackoutzone_"..k,
                            icon = "fa-solid fa-bolt",
                            label = Language.target.blackout,
                            distance = 2.0,
                            items = Config.BlackOut.HackItems,
                            canInteract = function()
                                return not v.state and CanStartBlackOut
                            end,
                            onSelect = function(args)
                                local ped = PlayerPedId()
                                local pedCoords = GetEntityCoords(ped)
                                if closestElecBox and closestElecBox ~= 0 then
                                    local AnimDic = "anim@scripted@player@mission@tun_control_tower@male@"
        
                                    local ElectrocBoxIntro = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, true, 1065353216, 0, 1.0)
                                    NetworkAddPedToSynchronisedScene(ped, ElectrocBoxIntro, AnimDic, "enter", 8.0, -8.0, 1, 16, 1148846080, 0)
                                    NetworkAddEntityToSynchronisedScene(closestElecBox, ElectrocBoxIntro, AnimDic, "enter_electric_box", 8.0, -8.0, 1)
                                    NetworkStartSynchronisedScene(ElectrocBoxIntro)
                                    Wait(GetAnimDuration(AnimDic, "enter")*1000)
                                    NetworkStopSynchronisedScene(ElectrocBoxIntro)
        
                                    local ElectrocBoxLoop = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, true, 1065353216, 0, 1.0)
                                    NetworkAddPedToSynchronisedScene(ped, ElectrocBoxLoop, AnimDic, "loop", 8.0, -8.0, 1, 16, 1148846080, 0)
                                    NetworkAddEntityToSynchronisedScene(closestElecBox, ElectrocBoxLoop, AnimDic, "loop_electric_box", 8.0, -8.0, 1)
                                    NetworkStartSynchronisedScene(ElectrocBoxLoop)
                                    if Config.BlackOut.MiniGame() then
                                        TriggerServerEvent('flex_pettycrimes:server:SetBlackOut', k)
                                        Config.Notify.client(Language.success.blackouthack, 'success', 5000)
                                    end
                                    NetworkStopSynchronisedScene(ElectrocBoxLoop)
        
                                    local ElectrocBoxOutro = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, true, 1065353216, 0, 1.0)
                                    NetworkAddPedToSynchronisedScene(ped, ElectrocBoxOutro, AnimDic, "exit", 8.0, -8.0, 1, 16, 1148846080, 0)
                                    NetworkAddEntityToSynchronisedScene(closestElecBox, ElectrocBoxOutro, AnimDic, "exit_electric_box", 8.0, -8.0, 1)
                                    NetworkStartSynchronisedScene(ElectrocBoxOutro)
                                    Wait(GetAnimDuration(AnimDic, "exit")*750)
                                    NetworkStopSynchronisedScene(ElectrocBoxOutro)
                                end
                            end,
                        }
                    }
                })
            else
                for k, v in pairs(TargetZones) do
                    exports.ox_target:removeZone(v)
                end
                TargetZones = {}
            end
        end)
        Wait(500)
    end
end)

RegisterNetEvent("flex_pettycrimes:client:SetBlackOutConfig", function(config)
    Config.BlackOut.HackLocations = config
end)

RegisterNetEvent("flex_pettycrimes:client:SetBlackOutState", function(state)
end)

local function UnloadEvent()
    for k, v in pairs(TargetZones) do
        exports.ox_target:removeZone(v)
    end
    TargetZones = {}
    for k, v in pairs(BlackOutZones) do
        v:destroy()
    end
    BlackOutZones = {}
end

RegisterNetEvent(Config.Events.unload, function()
    UnloadEvent()
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        UnloadEvent()
    end
end)