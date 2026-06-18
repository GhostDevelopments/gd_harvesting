-- client/main.lua
local HarvestingLocations = {}
local isHarvesting = false

-- Get Qbox player data
local function getPlayerData()
    if exports.qbx_core then
        return exports.qbx_core:GetPlayerData()
    end
    return nil
end

-- Helper: Show GTA native help notification
local function showHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Start harvesting process
local function startHarvest(zone)
    if isHarvesting then return end
    isHarvesting = true

    TriggerServerEvent("ghostdev:harvesting:start", zone.id)

    -- Progress circle with ox_lib
    local success = lib.progressCircle({
        duration = zone.time or 8000,
        label = "Harvesting " .. zone.label .. "...",
        position = "bottom",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = "pickup_object",
            clip = "pickup_low"
        }
    })

    isHarvesting = false

    if success then
        TriggerServerEvent("ghostdev:harvesting:done", zone.id)
    else
        lib.notify({
            title = "Harvesting Cancelled",
            description = "You stopped harvesting " .. zone.label,
            type = "error"
        })
    end
end

-- Create harvesting zones with ox_target
local function createHarvestZones()
    for _, zone in ipairs(HarvestingLocations) do
        local options = {
            {
                name = "harvest_" .. zone.id,
                icon = "fa-solid fa-hand",
                label = "Harvest " .. zone.label,
                distance = 2.0,
                onSelect = function()
                    startHarvest(zone)
                end
            }
        }

        exports.ox_target:addBoxZone({
            id = "harvest_zone_" .. zone.id,
            coords = zone.coords,
            size = vec3(zone.radius or 2.0, zone.radius or 2.0, 2.0),
            rotation = 0,
            debug = Config.Debug or false,
            options = options
        })

        -- Add blip if configured
        if zone.blip then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite or 496)
            SetBlipColour(blip, zone.blip.color or 2)
            SetBlipScale(blip, zone.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.name or zone.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

-- Create marker threads for visual feedback
local function createMarkerThreads()
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for _, zone in ipairs(HarvestingLocations) do
                local dist = #(playerCoords - zone.coords)

                if dist < 50.0 then
                    sleep = 0
                    -- Draw marker (ground circle)
                    DrawMarker(
                        27, -- type
                        zone.coords.x,
                        zone.coords.y,
                        zone.coords.z - 0.9,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        zone.radius or 1.5,
                        zone.radius or 1.5,
                        0.5,
                        30, 144, 255, 150, -- RGBA
                        false,
                        true,
                        2,
                        false,
                        false,
                        false,
                        false
                    )
                end
            end

            Wait(sleep)
        end
    end)
end

-- Initialize
CreateThread(function()
    -- Fetch config from server
    local success = lib.callback.await("ghostdev:harvesting:getConfig", false)
    if success then
        HarvestingLocations = success
        createHarvestZones()
        createMarkerThreads()
        print("[GhostDev] Harvesting system loaded with " .. #HarvestingLocations .. " zones")
    else
        print("[GhostDev] Failed to load config")
    end
end)

-- Update zones when player data changes (for job-restricted zones)
if exports.qbx_core then
    CreateThread(function()
        while true do
            Wait(5000)
            local newData = getPlayerData()
            -- Handle dynamic zone updates here if needed
        end
    end)
end