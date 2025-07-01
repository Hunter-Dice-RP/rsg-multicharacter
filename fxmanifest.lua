fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'rsg-multicharacter'
version '2.3.3'

ui_page "html/index.html"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/unstick.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/actions.lua',
    'server/givestart.lua',
    'server/investigation.lua',
    'server/main.lua',
    'server/versionchecker.lua'
}

files {
    'html/index.html',
    'html/css/reset.css',
    'html/css/style.css',
    'html/js/script.js',
    'html/js/profanity.js',
    'html/assets/*.png',
    'html/song/*.mp3',
    'locales/*.json'
}

dependencies {
    'rsg-core'
}

lua54 'yes'
