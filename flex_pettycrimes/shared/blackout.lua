---------------------
---   BLACK OUT   ---
---------------------
Config.BlackOut = {}
Config.BlackOut.Enable = true -- If you want this feature

Config.BlackOut.HackItems = {'phone'} -- Items needed to hack

Config.BlackOut.SetState = function(state)
    if GetResourceState('av_weather') ~= 'started' then return false end
    exports['av_weather']:setBlackout(state)
end

Config.BlackOut.GetState = function()
    if GetResourceState('av_weather') ~= 'started' then return false end
    return exports['av_weather']:getBlackout()
end

Config.BlackOut.MiniGame = function()
    return exports["flex_minigamebridge"]:StartMinigame('breakerpuzzle', math.random(4,7))
end

Config.BlackOut.CanHackResetTime = 1 -- Time in hourse before they can hack again
Config.BlackOut.HackResetTime = 30 -- Time in seconds they have to hack all HackLocations
Config.BlackOut.ResetTime = 5 -- Time in minutes before the blackout reset

Config.BlackOut.BlackOutEvent = function(src, started) -- Extra event to trigger when blackout is active
    if started then
        exports.yseries:CellBroadcast(-1, 'Stroompanne', 'Geen paniek! De stroom schiet zo weer aan!', 'https://cdn-icons-png.flaticon.com/512/4325/4325930.png')
    else
    end
end

Config.BlackOut.HackLocations = {
    [1] = {vec3(648.3794, 108.61, 81.2279), state = false},
    [2] = {vec3(765.7249, -1917.9962, 29.677), state = false},
    [3] = {vector3(2298.533, 2948.384, 47.0828), state = false},
    [4] = {vector3(1868.4056, 3714.8013, 33.5164), state = false},
}