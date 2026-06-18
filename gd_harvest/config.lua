-- config.lua
Config = {}

-- Debug mode (shows zone boundaries)
Config.Debug = false

-- Use ox_target (set to false to use lib.zones fallback)
Config.UseTarget = true

-- Harvesting locations (Ghost Developments)
Config.HarvestingLocations = {
    {
        id = 1,
        label = "X Pills",
        item = "xtcbaggy",
        minAmount = 2,
        maxAmount = 6,
        time = 8000, -- milliseconds
        coords = vector3(244.56, 374.36, 104.74),
        radius = 1.8,
        blip = {
            sprite = 496,
            color = 2,
            scale = 0.75,
            name = "X Pills Field"
        }
    },
    {
        id = 2,
        label = "Weed",
        item = "weed_white",
        minAmount = 1,
        maxAmount = 4,
        time = 10000,
        coords = vector3(-45.32, 1921.45, 195.32),
        radius = 2.0,
        blip = {
            sprite = 496,
            color = 2,
            scale = 0.75,
            name = "Weed Field"
        }
    },
    {
        id = 3,
        label = "Coke",
        item = "coke_brick",
        minAmount = 1,
        maxAmount = 2,
        time = 15000,
        coords = vector3(1108.23, -3192.11, -38.99),
        radius = 2.5,
        blip = {
            sprite = 496,
            color = 5,
            scale = 0.8,
            name = "Coke Processing"
        }
    }
}

-- Job-restricted zones (optional)
Config.RestrictedZones = {
    -- Example:
    -- {
    --     zoneId = 1,
    --     job = "police",
    --     grade = 2
    -- }
}

-- Export config for server access
return Config