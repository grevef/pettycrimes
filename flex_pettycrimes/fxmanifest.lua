fx_version 'cerulean'
game 'gta5'
author 'Flexiboii'
description 'Pettycrimes'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/blackout.lua',
    'shared/postrob.lua',
    'shared/smashgrab.lua',
    'shared/tripoverrope.lua',
    'shared/stealtyres.lua',
    'shared/graverob.lua',
    'locale/*.lua',
    'client/bridge/*.lua',
    'server/bridge/*.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**.lua',
}

dependency '/assetpacks'