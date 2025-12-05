---------------------
-- SMASH AND GRAB  --
---------------------
Config.SmashGrab = {}
Config.SmashGrab.Enabled = true -- If you want this feature

Config.SmashGrab.Zones = {
    [1] = {
        vector2(-785.32, -2485.12),
        vector2(-806.64, -2456.16),
        vector2(-847.24, -2360.32),
        vector2(-832.4, -2288.04),
        vector2(-723.16, -2393.44),
    },
    [2] = {
        vector2(-835.16, -2287.28),
        vector2(-907.08, -2370.64),
        vector2(-956.32, -2344.88),
        vector2(-903.08, -2233.64)
    },
    [3] = {
        vector2(-996.56, -2106.88),
        vector2(-894.6, -2023.76),
        vector2(-870.8, -2050.64),
        vector2(-950.84, -2141.28),
    },
    [4] = {
        vector2(-818.96, -2028.6),
        vector2(-713.52, -1933.2),
        vector2(-508.24, -2138.4),
        vector2(-614.08, -2258.84)
    },
    [5] = {
        vector2(-226.64, -1938.2),
        vector2(-186.84, -1902.04),
        vector2(-163.16, -1997.6),
        vector2(-183.72, -2065.24),
        vector2(-235.48, -2109.68),
        vector2(-278.84, -2106.36),
        vector2(-278.36, -2081.56),
        vector2(-225.6, -2019.12),
        vector2(-226.0, -1958.56)
    },
    [6] = {
        vector2(-49.28, -1734.48),
        vector2(44.28, -1690.28),
        vector2(73.36, -1715.12),
        vector2(11.84, -1794.12)
    },
    [7] = {
        vector2(1.28, -1609.16),
        vector2(70.04, -1523.24),
        vector2(89.84, -1539.2),
        vector2(27.32, -1623.12)
    },
    [8] = {
        vector2(107.12, -1045.32),
        vector2(171.88, -1072.08),
        vector2(173.6, -1087.96),
        vector2(91.96, -1081.76)
    },
    [9] = {
        vector2(245.84, -940.76),
        vector2(157.32, -909.88),
        vector2(181.28, -849.04),
        vector2(258.08, -870.4)
    },
    [10] = {
        vector2(192.0, -819.12),
        vector2(226.32, -726.32),
        vector2(274.08, -739.92),
        vector2(244.16, -825.04)
    }
}
Config.SmashGrab.SpawnBagRadius = 50.0 -- Radius when you need to be in from a car to check if it can spawn a bag
Config.SmashGrab.StealTime = 5 -- Time in seconds it takes to steal
Config.SmashGrab.PoliceChance = 95 -- 25% chance to call the police for stealing
Config.SmashGrab.Bags = {
    "prop_ld_suitcase_01",
    "prop_ld_handbag_s",
    "prop_carrier_bag_01",
    "prop_nigel_bag_pickup",
    "ch_prop_ch_duffelbag_01x",
    "h4_prop_h4_med_bag_01b",
    "prop_shopping_bags02",
    "sf_prop_sf_backpack_01a",
    "p_michael_backpack_s",
    "xm3_prop_xm3_backpack_01a"
}
Config.SmashGrab.BagOffset = { -- pos offset , rot offset
    ["prop_carrier_bag_01"] = {vec3(0.0, 0.1, 0.2), vec3(0.0, 0.0, 0.0)},
    ["ch_prop_ch_duffelbag_01x"] = {vec3(0.0, 0.1, -0.05), vec3(0.0, 0.0, 0.0)},
    ["prop_shopping_bags02"] = {vec3(0.0, 0.0, 0.6), vec3(0.0, 0.0, -90.0)},
    ["p_michael_backpack_s"] = {vec3(0.0, 0.0, 0.19), vec3(0.0, 0.0, 0.0)},
    ["xm3_prop_xm3_backpack_01a"] = {vec3(0.0, 0.0, 0.1), vec3(0.0, 0.0, 0.0)},
}
Config.SmashGrab.DailyLootPool = true
-- True = Generate a random id to use as the Config.LootPools ID
-- For example random number between 1 and 3 generates number 2 so it will use Config.LootPools[2] for the rest of the day
-- False = Random every time
Config.SmashGrab.LootPools = {
    [1] = {
        rare = {
            chance = 5, -- Chance out of 100 to get this
            items = {
                {'weapon_bat', 1, nil}, -- item, amount, info
            }
        },
        common = {
            {'scrap_contract', 1, nil},-- item, amount, info
            {'money',math.random(10,25), nil},-- item, amount, info
            {'nylonrope',1, nil},-- item, amount, info
        }
    }
}