fx_version 'cerulean'
game 'gta5'

name 'qbx_targets'
description 'Targets voor ox_target in Qbox'
version '1.0.0'

lua54 'yes'

 
shared_scripts {
    '@ox_lib/init.lua'
}

 
client_scripts {
    'client/*.lua'
}

 
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
