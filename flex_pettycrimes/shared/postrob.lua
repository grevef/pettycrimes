---------------------
--- POST  ROBBERY ---
---------------------
Config.PostRob = {}
Config.PostRob.Enable = true -- If you want this feature

Config.PostRob.DailyLootPool = true
-- True = Generate a random id to use as the Config.LootPools ID
-- For example random number between 1 and 3 generates number 2 so it will use Config.LootPools[2] for the rest of the day
-- False = Random every time
Config.PostRob.ResetTime = 10 -- Time In minutes before the package can appear again
Config.PostRob.BoxItem = 'box' -- Itemname for when taking the box of the fround
Config.PostRob.ExplodeChance = 35 -- 15% chance to explode insead of getting the item
Config.PostRob.RagdollDuration = 4 -- Seconds the player ragdolls
Config.PostRob.ExplosionSound = true -- Play a native explosion sound
Config.PostRob.PoliceChance = 25 -- 50% chance to call the police for stealing OR false to disable
Config.PostRob.Zones = {
    [1] = { -- Mirrorpark
        zone = {
            vec2(1228.68, -319.37),
            vec2(1293.83, -411.29),
            vec2(1419.21, -542.74),
            vec2(1379.80, -642.75),
            vec2(1310.55, -769.46),
            vec2(999.31, -757.86),
            vec2(820.52, -566.54),
            vec2(818.05, -514.92),
            vec2(963.02, -426.73),
            vec2(1113.03, -311.25)
        },
        packages = {
            vec4(1029.40, -409.40, 65.95, 208.49),
            vec4(1011.94, -422.80, 64.95, 240.41),
            vec4(1006.15, -511.30, 60.83, 109.40),
            vec4(1009.89, -573.98, 60.59, 322.55),
            vec4(1204.36, -561.36, 69.40, 33.01),
            vec4(1206.90, -621.44, 66.44, 27.81),
            vec4(1228.70, -728.07, 60.65, 348.99),
            vec4(1273.09, -679.47, 65.78, 156.26),
            vec4(1347.23, -547.73, 73.89, 175.96),
            vec4(1344.78, -599.88, 74.70, 44.75),
            vec4(1387.94, -572.31, 74.54, 29.58),
            vec4(1324.36, -534.54, 72.44, 249.76),
            vec4(1252.84, -492.42, 69.54, 211.75),
            vec4(1262.21, -428.33, 69.80, 282.81),
        }
    },
    [2] = { -- Vinewood
        zone = {
            vec2(406.42, 418.18),
            vec2(259.03, 475.53),
            vec2(125.63, 461.09),
            vec2(22.70, 435.56),
            vec2(-270.70, 351.59),
            vec2(-468.07, 318.19),
            vec2(-544.78, 400.50),
            vec2(-735.63, 408.83),
            vec2(-830.03, 844.37),
            vec2(-678.56, 941.00),
            vec2(-390.10, 735.23),
            vec2(-225.41, 627.45),
            vec2(189.13, 584.68),
        },
        packages = {
            vec4(148.46, 567.66, 183.92, 9.87),
            vec4(87.68, 563.08, 182.58, 68.89),
            vec4(7.58, 541.09, 176.03, 309.57),
            vec4(57.35, 450.46, 147.03, 302.87),
            vec4(119.31, 493.05, 147.34, 133.54),
            vec4(-225.21, 494.39, 128.45, 79.77),
            vec4(-353.84, 466.93, 112.60, 328.16),
            vec4(-352.75, 514.09, 120.65, 173.32),
            vec4(-422.58, 535.38, 122.18, 29.69),
            vec4(-519.44, 596.98, 120.90, 206.00),
            vec4(-564.43, 682.54, 147.00, 199.02),
            vec4(-492.22, 736.24, 162.83, 343.90),
            vec4(-401.05, 665.13, 163.83, 312.81),
            vec4(-342.01, 665.39, 169.22, 114.92),
            vec4(-257.35, 629.79, 187.81, 49.41),
            vec4(-291.68, 601.55, 181.44, 38.24),
            vec4(-187.09, 615.84, 199.68, 135.23)
        }
    },
}
Config.PostRob.Boxes = {
    'prop_cs_package_01',
    'ba_prop_battle_drug_package_02'
}
Config.PostRob.LootPools = {
    [1] = {
        rare = {
            chance = 15, -- Chance out of 100 to get this
            items = {
                {'tracker_blueprint', 1, nil}, -- item, amount, info
                {'diamonds_box', math.random(1,2), nil},-- item, amount, info
                {'diamond_ring', math.random(1,2), nil},-- item, amount, info
            }
        },
        common = {
            {'scrap_contract', 1, nil},-- item, amount, info
            {'flat_tv',1, nil},-- item, amount, info
            {'console',1, nil},-- item, amount, info
            {'microwave',1, nil},-- item, amount, info
            {'painting',1, nil},-- item, amount, info
            {'x_guitar',1, nil},-- item, amount, info
        }
    }
}