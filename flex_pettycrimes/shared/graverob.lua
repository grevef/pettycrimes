---------------------
--- GRAVE ROBBERY ---
---------------------
Config.GraveRob = {}
Config.GraveRob.Enable = true -- If you want this feature

Config.GraveRob.DigItem = {'jail_shovel'}
Config.GraveRob.ResetTime = 15 -- Time in minutes to reset grave from robbing
Config.GraveRob.DigTime = 15 -- Time in seconds
Config.GraveRob.SearchTime = 10 -- Time in seconds
Config.GraveRob.PoliceChance = 25 -- 50% Chance to notify police

Config.GraveRob.GraveLoot = {
    [1] = {
        chance = 75, -- chance out of 100
        item = 'cloth',
        amount = math.random(3,10),
        info = {}
    },
    [2] = {
        chance = 75, -- chance out of 100
        item = 'wallet',
        amount = 1,
        info = {}
    },
    [3] = {
        chance = 45, -- chance out of 100
        item = 'goldring',
        amount = 1,
        info = {}
    },
    [4] = {
        chance = 45, -- chance out of 100
        item = 'diamond_ring',
        amount = 1,
        info = {}
    },
    [5] = {
        chance = 65, -- chance out of 100
        item = 'coins',
        amount = math.random(1,3),
        info = {}
    },
}
Config.GraveRob.PedLoot = {
    [1] = {
        chance = 10, -- chance out of 100
        item = 'weapon_knife',
        amount = 1,
        info = {}
    },
    [2] = {
        chance = 10, -- chance out of 100
        item = 'goldchain',
        amount = math.random(1,3),
        info = {}
    },
}

Config.GraveRob.PedChance = 100 -- chance out of 100 to spawn attacking ped
Config.GraveRob.GraveZones = {
    [1] = {
        zone = {
            vec2(-1589.52, -182.79),
            vec2(-1637.85, -114.59),
            vec2(-1688.77, -123.57),
            vec2(-1738.47, -161.16),
            vec2(-1783.29, -189.78),
            vec2(-1834.49, -229.94),
            vec2(-1806.74, -274.15),
            vec2(-1740.58, -330.27),
            vec2(-1700.17, -284.33),
            vec2(-1687.47, -222.65),
            vec2(-1632.29, -204.29),
        },
        graves = {
            [1] = {
                robbed = false,
                coords = vec4(-1748.42, -296.47, 48.00, 99.05)
            }
        }
    }
}

Config.GraveRob.PedWeapons = {
    "weapon_bat",
    "weapon_hammer",
    "weapon_golfclub",
    "weapon_bottle",
    "weapon_crowbar",
    "weapon_flashlight",
    "weapon_hatchet",
    "weapon_knife",
    "weapon_machete",
    "weapon_switchblade",
    "weapon_nightstick",
    "weapon_wrench",
    "weapon_battleaxe",
    "weapon_poolcue",
}