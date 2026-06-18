-- server/main.lua
local ActiveSessions = {} -- [src] = { startTime = os.time(), zoneId = zoneId }

-- Standalone detection - check if Qbox is available
local function isQbox()
    return exports.qbx_core ~= nil
end

-- Drop player with reason
local function dropPlayer(src, reason)
    DropPlayer(src, reason)
end

-- Add item to player (Qbox or fallback)
local function addItem(src, item, amount)
    if isQbox() then
        exports.ox_inventory:AddItem(src, item, amount)
    else
        -- Standalone fallback
        exports.ox_inventory:AddItem(src, item, amount)
    end
end

-- Notify player (Qbox or fallback)
local function notify(src, data)
    if isQbox() then
        TriggerClientEvent("ox_lib:notify", src, data)
    else
        TriggerClientEvent("ox_lib:notify", src, data)
    end
end

-- Clear session on disconnect
AddEventHandler("playerDropped", function()
    local src = source
    ActiveSessions[src] = nil
end)

-- Player started harvesting
RegisterNetEvent("ghostdev:harvesting:start", function(zoneId)
    local src = source

    -- Validate zone exists
    local zone = nil
    for _, z in ipairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    if not zone then return end

    -- Record session with timestamp
    ActiveSessions[src] = {
        startTime = os.clock(),
        zoneId = zoneId
    }
end)

-- Player finished harvesting
RegisterNetEvent("ghostdev:harvesting:done", function(zoneId)
    local src = source
    local session = ActiveSessions[src]

    -- Anti-exploit: validate session exists and matches
    if not session then
        dropPlayer(src, "GhostDev: No active harvest session")
        return
    end

    if session.zone ~= zoneId and session.zoneId ~= zoneId then
        dropPlayer(src, "GhostDev: Zone mismatch")
        return
    end

    -- Anti-exploit: check time elapsed (prevent instant harvest)
    local elapsed = os.clock() - session.startTime
    local requiredTime = (Config.HarvestingLocations[zoneId] and Config.HarvestingLocations[zoneId].time or 8000) / 1000

    if elapsed < (requiredTime * 0.8) then
        dropPlayer(src, "GhostDev: Harvest too fast (exploit)")
        return
    end

    -- Clear session
    ActiveSessions[src] = nil

    -- Get zone config
    local zone = nil
    for _, z in ipairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    if not zone then return end

    -- Award items
    local amount = math.random(zone.minAmount, zone.maxAmount)
    addItem(src, zone.item, amount)

    -- Notify success
    notify(src, {
        title = "Harvested",
        description = string.format("+%d %s", amount, zone.label),
        type = "success",
        duration = 4000
    })
end)

-- Ox_lib callback for config (client fetches config)
lib.callback.register("ghostdev:harvesting:getConfig", function()
    return Config.HarvestingLocations
end)