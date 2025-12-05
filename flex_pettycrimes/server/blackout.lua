if not Config.BlackOut.Enable then return end

local CanStartBlackOut = true
local IsHackTimerActive = false

RegisterServerEvent("flex_pettycrimes:server:SetBlackOut", function(id)
    if not CanStartBlackOut then return end
    local src = source
    if Config.BlackOut.GetState() then return end
    Config.BlackOut.HackLocations[id].state = true
    TriggerClientEvent('flex_pettycrimes:client:SetBlackOutConfig', -1, Config.BlackOut.HackLocations)
    if not IsHackTimerActive then
        IsHackTimerActive = true
        StartHackTimer()
    end
    for k, v in pairs(Config.BlackOut.HackLocations) do
        if not v.state then
            return 
        end
    end
    StartBlackOut(src)
end)

function StartHackTimer()
    CreateThread(function()
        SetTimeout(1000*Config.BlackOut.HackResetTime, function()
            IsHackTimerActive = false
            for k, v in pairs(Config.BlackOut.HackLocations) do
                if v.state then
                    v.state = false 
                end
            end
            TriggerClientEvent('flex_pettycrimes:client:SetBlackOutConfig', -1, Config.BlackOut.HackLocations)
        end)
    end)
end

function StartBlackOut(src)
    CanStartBlackOut = false
    TriggerClientEvent('flex_pettycrimes:client:SetBlackOutState', -1, CanStartBlackOut)
    Config.BlackOut.SetState(true)
    Config.BlackOut.BlackOutEvent(src, true)
    CreateThread(function()
        SetTimeout(1000*60*Config.BlackOut.ResetTime, function()
            Config.BlackOut.SetState(false)
            IsHackTimerActive = false
            for k, v in pairs(Config.BlackOut.HackLocations) do
                if v.state then
                    v.state = false 
                end
            end
            TriggerClientEvent('flex_pettycrimes:client:SetBlackOutConfig', -1, Config.BlackOut.HackLocations)
            Config.BlackOut.BlackOutEvent(src, false)
        end)
    end)
    CreateThread(function()
        SetTimeout(1000*60*Config.BlackOut.CanHackResetTime*60, function()
            CanStartBlackOut = true
            TriggerClientEvent('flex_pettycrimes:client:SetBlackOutState', -1, CanStartBlackOut)
        end)
    end)
end

lib.callback.register('flex_pettycrimes:server:GetBlackOutConfig', function(source)
    return Config.BlackOut.HackLocations
end)

lib.callback.register('flex_pettycrimes:server:IsInBlackOut', function(source, coords)
    for k, v in pairs(Config.BlackOut.HackLocations) do
        if #(coords.xyz - v[k].xyz) < 1.0 then
            return v.state
        end
    end
end)

lib.callback.register('flex_pettycrimes:server:CanStartBlackOut', function(source)
    return CanStartBlackOut
end)

AddEventHandler('onResourceStart', function(resource)
   if resource == GetCurrentResourceName() then
        if Config.BlackOut.SetState then
            Config.BlackOut.SetState(false)
        end
    end
end)