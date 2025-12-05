if not Config.TripRope.enable then return end

local pos1, pos2 = nil, nil
local ropeIds, Props = {}, {}
local BoxZones, RemoveBoxZones = {}, {}
local placeing, ragdoll = false, false

CreateThread(function()
    RopeLoadTextures()
end)

local function getBoxDimensions(p1, p2)
    local width = math.abs(p2.x - p1.x)
    local length = math.abs(p2.y - p1.y)
    local height = math.abs(p2.z - p1.z)
    return width, length, height
end

local function getHeadingFromPoints(p1, p2)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local heading = math.deg(math.atan2(dy, dx))
    heading = (heading - 90) % 360 -- Correct for GTA/FiveM heading
    return (heading + 360) % 360
end

RegisterNetEvent("flex_pettycrimes:client:rope:PlaceRope", function()
    if #ropeIds >= Config.TripRope.MaxServerRopes then return Config.Notify.client(Language.error.maxtraps, 'error', 5000) end
    placeing = true
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    if not pos1 then
        lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
        if lib.progressBar({
            duration = 1000 * Config.TripRope.ProgressTime,  
            label = Language.progress.placing,      
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                mouse = false,
                combat = true
            } 
        }) then
            pos1 = vec4(pos.x, pos.y, pos.z+Config.TripRope.Z_Offset, heading)
            TriggerServerEvent('flex_pettycrimes:server:rope:CreateProp', vec4(pos.x, pos.y, pos.z, heading))
            Config.Notify.client(Language.success.placesecondrod, 'success', 5000)
        end
        ClearPedTasks(ped)
    elseif not pos2 then
        lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
        if lib.progressBar({
            duration = 1000 * Config.TripRope.ProgressTime,  
            label = Language.progress.placing,      
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                mouse = false,
                combat = true
            } 
        }) then
            pos2 = vec4(pos.x, pos.y, pos.z+Config.TripRope.Z_Offset, heading)
            if #(vector2(pos1.x, pos1.y) - vector2(pos2.x, pos2.y)) <= Config.TripRope.MaxRopeLength then
                TriggerServerEvent("flex_pettycrimes:server:rope:syncRope", pos1, pos2)
                TriggerServerEvent('flex_pettycrimes:server:rope:CreateProp', vec4(pos.x, pos.y, pos.z, heading))
                pos1, pos2 = nil, nil
                placeing = false
            else
                pos2 = nil
            end
        end
        ClearPedTasks(ped)
    end
    CreateThread(function()
        -- SetTimeout(60* 1000 * Config.TripRope.PlaceTime, function()
        --     if pos1 and not pos2 then
        --         TriggerServerEvent('flex_pettycrimes:server:rope:RemoveProp', pos1, false)
        --         pos1, pos2 = nil, nil
        --         placeing = false
        --     end
        -- end)
        while placeing do
            Wait(500)
            pos = GetEntityCoords(ped)
            if pos1 then
                if #(pos - pos1.xyz) >= Config.TripRope.MaxRopeLength + 3.0 then
                    TriggerServerEvent('flex_pettycrimes:server:rope:RemoveProp', pos1)
                    pos1, pos2 = nil, nil
                    placeing = false
                end
            end
            if pos2 then
                if #(pos - pos2.xyz) >= Config.TripRope.MaxRopeLength + 3.0 then
                    TriggerServerEvent('flex_pettycrimes:server:rope:RemoveProp', pos2)
                    pos1, pos2 = nil, nil
                    placeing = false
                end
            end
        end
    end)
end)

RegisterNetEvent("flex_pettycrimes:client:rope:PlayerRemoveRope", function(pos)
    local ped = PlayerPedId()
    local closestIndex = nil
    local closestDist = nil
    for i, rope in ipairs(ropeIds) do
        local midPos = (rope.startPos + rope.endPos) / 2
        local dist = #(pos - midPos)
        
        if not closestDist or dist < closestDist then
            closestDist = dist
            closestIndex = i
        end
    end
    if closestIndex then
        local ropeToDelete = ropeIds[closestIndex]
        if closestDist-7 > Config.TripRope.MaxRemoveDistance then return Config.Notify.client(Language.error.tofar, 'error', 5000) end
        TaskTurnPedToFaceCoord(ped, ropeToDelete.startPos.x, ropeToDelete.startPos.y, ropeToDelete.startPos.z, 1000)
        lib.playAnim(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.0, 3.0, -1, 1)
        if lib.progressBar({
            duration = 1000 * Config.TripRope.ProgressTime,  
            label = Language.progress.taking,      
            useWhileDead = false,
            disable = {
                move = true,
                car = true,
                mouse = false,
                combat = true
            } 
        }) then
            TriggerServerEvent('flex_pettycrimes:server:RemoveRope', closestIndex)
        end
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent("flex_pettycrimes:client:rope:CreateProp", function(pos)
    local offset = Config.TripRope.PropOffset
    local prop = CreateObject(GetHashKey(Config.TripRope.PlaceProp), pos.x + offset.x, pos.y + offset.y, pos.z + offset.z, false, true, true)
    Props[#Props+1] = prop
    SetEntityHeading(prop, pos.w)
    -- PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)
    SetEntityAsMissionEntity(prop, true, true)
    RemoveBoxZones[prop] = exports.ox_target:addBoxZone({
        name = 'flex_pettycrimes_tripoverremovezone_'..prop,
        coords = vec3(pos.x + offset.x, pos.y + offset.y, pos.z -.5),
        size = vec3(1, 1, 1),
        rotation = pos.w,
        debug = Config.Debug,
        options = {
            {
                icon = 'fas fa-hand-point-down',
                label = Language.target.removerop,
                distance = Config.TripRope.MaxRemoveDistance,
                onSelect = function(args)
                    TriggerEvent('flex_pettycrimes:client:rope:PlayerRemoveRope', pos.xyz)
                end
            }
        }
    })
end)

RegisterNetEvent("flex_pettycrimes:client:rope:RemoveRope", function(closestIndex)
    if closestIndex then
        local ropeToDelete = ropeIds[closestIndex]
        if not ropeToDelete then return end
        local offset = Config.TripRope.PropOffset
        local p1 = vec3(ropeToDelete.startPos.x + offset.x, ropeToDelete.startPos.y + offset.y, ropeToDelete.startPos.z + offset.z)
        local p2 = vec3(ropeToDelete.endPos.x + offset.x, ropeToDelete.endPos.y + offset.y, ropeToDelete.endPos.z + offset.z)
        local obj1 = GetClosestObjectOfType(p1.x, p1.y, p1.z, 0.5, GetHashKey(Config.TripRope.PlaceProp), false, false, false)
        local obj2 = GetClosestObjectOfType(p2.x, p2.y, p2.z, 0.5, GetHashKey(Config.TripRope.PlaceProp), false, false, false)
        if obj1 == 0 or obj2 == 0 then return end
        DeleteRope(ropeToDelete.id)
        exports.ox_target:removeZone(RemoveBoxZones[obj1])
        DeleteEntity(obj1)
        exports.ox_target:removeZone(RemoveBoxZones[obj2])
        DeleteEntity(obj2)
        BoxZones[ropeToDelete.id]:destroy()
        table.remove(ropeIds, closestIndex)
    end
end)

RegisterNetEvent("flex_pettycrimes:client:rope:RemoveProp", function(p)
    for k, v in pairs(Props) do
        local pos = GetEntityCoords(v)
        if #(pos.xyz - p.xyz) <= 1.0 then
            DeleteEntity(v)
        end
    end
end)

RegisterNetEvent("flex_pettycrimes:client:rope:createRope", function(p1, p2, serverID)
    local ropeLength = #(vector3(p1.x, p1.y, p1.z) - vector3(p2.x, p2.y, p2.z))
    local ropeCenter = (p1.xyz + p2.xyz) / 2
    local ropeLength2D = #(vector2(p1.x, p1.y) - vector2(p2.x, p2.y))
    local zoneWidth = 0.3
    local zoneLength = ropeLength2D
    local heading = getHeadingFromPoints(p1.xyz, p2.xyz)
    local ropeType = 4
    local numSegments = 20

    local ropeId = AddRope(p1.x, p1.y, p1.z, 0.0, 0.0, 0.0, ropeLength, ropeType, ropeLength, numSegments * 1.0, false, false, true, 1.0, false, false )
    Wait(100)
    local vertexCount = GetRopeVertexCount(ropeId)
    PinRopeVertex(ropeId, 0, p1.x, p1.y, p1.z)
    PinRopeVertex(ropeId, vertexCount - 1, p2.x, p2.y, p2.z)
    StartRopeUnwindingFront(ropeId)
    ActivatePhysics(ropeId)
    ropeIds[#ropeIds + 1] = {
        serverID = serverID,
        id = ropeId,
        startPos = vector3(p1.x, p1.y, p1.z),
        endPos = vector3(p2.x, p2.y, p2.z)
    }
    BoxZones[ropeId] = BoxZone:Create(ropeCenter, zoneLength, zoneWidth+3.0, {
        name = "rope-" .. ropeId,
        debugPoly = Config.Debug,
        heading = heading,
        minZ = ropeCenter.z - 0.3,
        maxZ = ropeCenter.z + .9,
    })
    BoxZones[ropeId]:onPlayerInOut(function(isPointInside)
        local ped = PlayerPedId()
        if isPointInside then
            ragdoll = true
            CreateThread(function()
                while ragdoll do
                    local FallRepeat = math.random(2, 4)
                    local RagdollTimeout = FallRepeat * 750
                    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                        SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                        ragdoll = false
                    end
                    Wait(1000)
                end
            end)
        else
            ragdoll = false
        end
    end)
end)

local function UnloadEvent()
    for _, rope in ipairs(ropeIds) do
        if DoesRopeExist(rope.id) then
            DeleteRope(rope.id)
        end
    end
    for k, v in pairs(Props) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
    for k, v in pairs(ropeIds) do
        BoxZones[v.id]:destroy()
    end
    for k, v in pairs(RemoveBoxZones) do
        exports.ox_target:removeZone(v)
    end
    BoxZones = {}
    Props = {}
    ropeIds = {}
    RemoveBoxZones = {}
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
    Wait(1500)
    TriggerServerEvent('flex_pettycrimes:server:rope:LoadRopes')
end)