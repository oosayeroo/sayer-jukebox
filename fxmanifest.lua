fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'oosayeroo'
description 'casette playing system built for Outback Zombies'
version '1.0.0' 

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
}
