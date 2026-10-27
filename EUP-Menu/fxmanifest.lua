fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Copeman'
description 'EUP Menu - ox_lib'
version '3.0.0'

shared_scripts {
    '@ox_lib/init.lua',
	'config.lua',
}

client_scripts {
    'client.lua',
}


server_scripts {
    'config.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
}
