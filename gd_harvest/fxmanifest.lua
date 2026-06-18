-- fxmanifest.lua
fx_version "cerulean"
game "gta5"

author "Ghost Developments"
description "Ghost Developments Harvesting Script - A Qbox compatible resource"
version "1.0.0"

-- Qbox dependencies
shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}

-- Dependencies
dependencies {
    "ox_lib",
    "ox_inventory",
    "qbx_core:optional"
}

-- Files
files {
}

-- Build settings
lua54 "yes"