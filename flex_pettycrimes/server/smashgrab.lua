if not Config.SmashGrab.Enabled then return end

local LootId = 1
if Config.SmashGrab.DailyLootPool then
    LootId = math.random(1, #Config.SmashGrab.LootPools)
end

RegisterServerEvent("flex_pettycrimes:server:RemoveBag", function(coords)
    local src = source
    if not Config.SmashGrab.DailyLootPool then
        LootId = math.random(1, #Config.SmashGrab.LootPools)
    end
    local loot = Config.SmashGrab.LootPools[LootId]
    if loot.rare then
        if math.random(0, 100) <= loot.rare.chance then
            local item = loot.rare.items[math.random(1, #loot.rare.items)]
            AddItem(src, item[1], item[2], item[3], nil)
        else
            local item = loot.common[math.random(1, #loot.common)]
            AddItem(src, item[1], item[2], item[3], nil)
        end
        TriggerClientEvent('flex_pettycrimes:client:RemoveBag', -1, coords)
    else
        local item = loot.common[math.random(1, #loot.common)]
        if AddItem(src, item[1], item[2], item[3], nil) then
            TriggerClientEvent('flex_pettycrimes:client:RemoveBag', -1, coords)
        end
    end
end)

RegisterServerEvent("flex_pettycrimes:server:RegisterBag", function(NetId)
    TriggerClientEvent('flex_pettycrimes:client:RegisterBag', -1, NetId)
end)

RegisterServerEvent("flex_pettycrimes:server:SetRobState", function(id, state)
    TriggerClientEvent('flex_pettycrimes:client:SetRobState', -1, id, state)
end)

lib.callback.register('flex_pettycrimes:server:IsVehicleOwned', function(source, plate)
    return MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate}) ~= nil
end)