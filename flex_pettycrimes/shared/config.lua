Config = {}

Config.Debug = false
Config.Lang = 'nl'
Config.CoreName = {
    qb = 'qb-core',
    esx = 'es_extended',
    ox = 'ox_core',
    ox_inv = 'ox_inventory',
    qbx = 'qbx_core',
    qb_radial = 'qb-radialmenu',
}

Config.Events = {
    unload = 'QBCore:Client:OnPlayerUnload',
    load = 'QBCore:Client:OnPlayerLoaded',
}

Config.Notify = {
    client = function(msg, type, time)
        lib.notify({
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
    server = function(src, msg, type, time)
        lib.notify(src, {
            title = msg,
            type = type,
            time = time or 5000,
        })
    end,
}

Config.PoliceNotify = {
    client = function(coords, streetname, msg)
        exports.tk_dispatch:addCall({
			title = msg,
			code = '53-32',
			priority = 'Prioriteit 3',
			coords = coords,
			showLocation = true,
			showGender = false,
			playSound = true,
			blip = {
				color = 13,
				sprite = 66,
				scale = 0.6,
			},
			jobs = {'police'}
		})
    end,
    server = function(src)
    end,
}

Config.ItemExports = {
    ['scrap_contract'] = function(src, item, amount, info, slot)
        exports['flex_carscrap']:GiveContract(src, nil, math.random(1, 2))
    end,
}