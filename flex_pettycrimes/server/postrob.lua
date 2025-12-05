if not Config.PostRob.Enable then return end

local Boxes = {}

local LootId = 1
if Config.PostRob.DailyLootPool then
    LootId = math.random(1, #Config.PostRob.LootPools)
end

RegisterServerEvent("flex_pettycrimes:server:StealBox", function(id, box, coords)
    local src = source
    local BoxId = #Boxes + 1
    Boxes[BoxId] = Config.PostRob.Zones[id].packages[box]
    CreateThread(function()
        SetTimeout(1000*60*Config.PostRob.ResetTime, function()
            for k, v in pairs(Boxes) do
                if v == Config.PostRob.Zones[id].packages[box] then
                    table.remove(Boxes, k)
                end
            end
        end)
    end)
    if AddItem(src, Config.PostRob.BoxItem, 1, nil, nil) then
        TriggerClientEvent('flex_pettycrimes:client:RemoveBox', -1, coords)
    end
end)

RegisterServerEvent("flex_pettycrimes:server:Unbox", function(id)
    local src = id or source
    if not Config.PostRob.DailyLootPool then
        LootId = math.random(1, #Config.PostRob.LootPools)
    end
    local loot = Config.PostRob.LootPools[LootId]
    if loot.rare then
        if math.random(0, 100) <= loot.rare.chance then
            local item = loot.rare.items[math.random(1, #loot.rare.items)]
            AddItem(src, item[1], item[2], item[3], nil)
        else
            local item = loot.common[math.random(1, #loot.common)]
            AddItem(src, item[1], item[2], item[3], nil)
        end
    else
        local item = loot.common[math.random(1, #loot.common)]
        if AddItem(src, item[1], item[2], item[3], nil) then
        end
    end
end)

lib.callback.register('flex_pettycrimes:server:IsPackageStolen', function(source, coords)
    for k, v in pairs(Boxes) do
        if #(coords.xyz - v.xyz) < 1.0 then
            return true
        end
    end
    return false
end)

RegisterServerEvent("flex_pettycrimes:server:ExplodeBoxEffect", function(coords)
    TriggerClientEvent('flex_pettycrimes:client:ExplodeBoxEffect', -1, coords)
end)

if GetResourceState(Config.CoreName.qbx) == 'started' then
    exports.qbx_core:CreateUseableItem(Config.PostRob.BoxItem, function(source, item)
        local src = source
        if RemoveItem(src, Config.PostRob.BoxItem, 1, nil, nil) then
            if math.random(0,100) <= Config.PostRob.ExplodeChance then
                TriggerClientEvent('flex_pettycrimes:client:ExplodeBox', src)
            else
                TriggerEvent("flex_pettycrimes:server:Unbox", src)
            end
        end
    end)
elseif GetResourceState(Config.CoreName.qb) == 'started' then
    local QBCore = exports[Config.CoreName.qb]:GetCoreObject()
    QBCore.Functions.CreateUseableItem(Config.PostRob.BoxItem, function(source, item)
        local src = source
        if RemoveItem(src, Config.PostRob.BoxItem, 1, nil, nil) then
            if math.random(0,100) <= Config.PostRob.ExplodeChance then
                TriggerClientEvent('flex_pettycrimes:client:ExplodeBox', src)
            else
                TriggerEvent("flex_pettycrimes:server:Unbox", src)
            end
        end
    end)
elseif GetResourceState(Config.CoreName.esx) == 'started' then
    local ESX = exports[Config.CoreName.esx]:getSharedObject()
    ESX.RegisterUsableItem(Config.PostRob.BoxItem, function(source)
        local src = source
        if RemoveItem(src, Config.PostRob.BoxItem, 1, nil, nil) then
            if math.random(0,100) <= Config.PostRob.ExplodeChance then
                TriggerClientEvent('flex_pettycrimes:client:ExplodeBox', src)
            else
                TriggerEvent("flex_pettycrimes:server:Unbox", src)
            end
        end
    end)
elseif GetResourceState(Config.CoreName.ox_inv) == 'started' and GetResourceState(Config.CoreName.qbx) ~= 'started' then
    AddEventHandler('ox_inventory:usedItem', function(source, name, slotId, metadata)
        if name:lower() == Config.PostRob.BoxItem:lower() then
            local src = source
            if RemoveItem(src, Config.PostRob.BoxItem, 1, nil, nil) then
                if math.random(0,100) <= Config.PostRob.ExplodeChance then
                    TriggerClientEvent('flex_pettycrimes:client:ExplodeBox', src)
                else
                    TriggerEvent("flex_pettycrimes:server:Unbox", src)
                end
            end
        end
    end)
end