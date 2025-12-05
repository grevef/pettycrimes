if not Config.GraveRob.Enable then return end

lib.callback.register('flex_pettycrimes:server:IsGraveDigged', function(source, id, grave)
    return Config.GraveRob.GraveZones[id].graves[grave].robbed
end)

RegisterServerEvent("flex_pettycrimes:server:SetGraveRobState", function(id, grave, state)
    Config.GraveRob.GraveZones[id].graves[grave].robbed = state
    TriggerClientEvent('flex_pettycrimes:client:SetGraveRobState', -1, id, grave, state)
    if state then
        CreateThread(function()
            SetTimeout(1000*60*Config.GraveRob.ResetTime, function()
                Config.GraveRob.GraveZones[id].graves[grave].robbed = not state
                TriggerClientEvent('flex_pettycrimes:client:SetGraveRobState', -1, id, grave, not state)
            end)
        end)
    end
end)

lib.callback.register('flex_pettycrimes:server:GetGraveConfig', function(source)
    return Config.GraveRob
end)

RegisterServerEvent("flex_pettycrimes:server:GraveLoot", function()
    local src = source
    local loot = Config.GraveRob.GraveLoot[math.random(1, #Config.GraveRob.GraveLoot)]
    if math.random(100) <= loot.chance then
        if AddItem(src, loot.item, loot.amount, loot.info, nil) then
        end
    else
        Config.Notify.server(src, Language.error.nothingfound, 'error', 3000)
    end
end)

RegisterServerEvent("flex_pettycrimes:server:GravePedLoot", function()
    local src = source
    local loot = Config.GraveRob.PedLoot[math.random(1, #Config.GraveRob.PedLoot)]
    if math.random(100) <= loot.chance then
        if AddItem(src, loot.item, loot.amount, loot.info, nil) then
        end
    else
        Config.Notify.server(src, Language.error.nothingfound, 'error', 3000)
    end
end)