if not Config.StealTyres.Enabled then return end

RegisterServerEvent("flex_pettycrimes:server:BreakTyre", function(NetId, bone)
    local src = source
    if AddItem(src, Config.StealTyres.StealTool, 1, nil, nil) then
        if AddItem(src, Config.StealTyres.TyreItem, 1, nil, nil) then
            TriggerClientEvent('flex_pettycrimes:client:BreakTyre', -1, NetId, bone)
        end
    end
end)