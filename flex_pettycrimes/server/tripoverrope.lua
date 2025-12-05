if not Config.TripRope.enable then return end

local Ropes = {}

RegisterNetEvent("flex_pettycrimes:server:rope:LoadRopes", function()
    local src = source
    for k, v in pairs(Ropes) do
        TriggerClientEvent("flex_pettycrimes:client:rope:CreateProp", src, v.p1)
        TriggerClientEvent("flex_pettycrimes:client:rope:CreateProp", src, v.p2)
        TriggerClientEvent("flex_pettycrimes:client:rope:createRope", src, v.p1, v.p2)
    end
end)

RegisterNetEvent("flex_pettycrimes:server:rope:syncRope", function(p1, p2)
    local RopeId = #Ropes + 1
    Ropes[RopeId] = {}
    Ropes[RopeId].p1 = vec4(p1.x, p1.y, p1.z, p1.w)
    Ropes[RopeId].p2 = vec4(p2.x, p2.y, p2.z, p2.w)
    TriggerClientEvent("flex_pettycrimes:client:rope:createRope", -1, p1, p2)
end)

RegisterNetEvent("flex_pettycrimes:server:rope:CreateProp", function(pos)
    TriggerClientEvent("flex_pettycrimes:client:rope:CreateProp", -1, pos)
end)

RegisterNetEvent("flex_pettycrimes:server:RemoveRope", function(index)
    local src = source
    if AddItem(src, Config.TripRope.Item.Place, 2, nil, nil) then
        TriggerClientEvent("flex_pettycrimes:client:rope:RemoveRope", -1, index)
        table.remove(Ropes, index)
    end
end)

-- RegisterNetEvent("flex_pettycrimes:server:AddRopes", function(pos)
--     if AddItem(src, Config.TripRope.Item.Place, 2, nil, nil) then
--     end
-- end)

RegisterNetEvent("flex_pettycrimes:server:rope:RemoveProp", function(pos, removeItem)
    local src = source
    if pos and AddItem(src, Config.TripRope.Item.Place, 1, nil, nil) then
        TriggerClientEvent("flex_pettycrimes:client:rope:RemoveProp", -1, pos)
    end
end)

if GetResourceState(Config.CoreName.qbx) == 'started' then
    exports.qbx_core:CreateUseableItem(Config.TripRope.Item.Place, function(source, item)
        local src = source
        if RemoveItem(src, Config.TripRope.Item.Place, 1, nil, nil) then
            TriggerClientEvent('flex_pettycrimes:client:rope:PlaceRope', src)
        end
    end)
elseif GetResourceState(Config.CoreName.qb) == 'started' then
    local QBCore = exports[Config.CoreName.qb]:GetCoreObject()
    QBCore.Functions.CreateUseableItem(Config.TripRope.Item.Place, function(source, item)
        local src = source
        if RemoveItem(src, Config.TripRope.Item.Place, 1, nil, nil) then
            TriggerClientEvent('flex_pettycrimes:client:rope:PlaceRope', src)
        end
    end)
elseif GetResourceState(Config.CoreName.esx) == 'started' then
    local ESX = exports[Config.CoreName.esx]:getSharedObject()
    ESX.RegisterUsableItem(Config.TripRope.Item.Place, function(source)
        local src = source
        if RemoveItem(src, Config.TripRope.Item.Place, 1, nil, nil) then
            TriggerClientEvent('flex_pettycrimes:client:rope:PlaceRope', src)
        end
    end)
elseif GetResourceState(Config.CoreName.ox_inv) == 'started' and GetResourceState(Config.CoreName.qbx) ~= 'started' then
    AddEventHandler('ox_inventory:usedItem', function(source, name, slotId, metadata)
        if name:lower() == Config.TripRope.Item.Place:lower() then
            local src = source
            if RemoveItem(src, Config.TripRope.Item.Place, 1, nil, nil) then
                TriggerClientEvent('flex_pettycrimes:client:rope:PlaceRope', src)
            end
        end
    end)
end