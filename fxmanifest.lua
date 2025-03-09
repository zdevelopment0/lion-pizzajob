fx_version 'cerulean'
game 'gta5'

description 'Pizza Delivery Job'
author 'Lion WorkShop'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

lua54 'yes'

dependency 'qb-core'