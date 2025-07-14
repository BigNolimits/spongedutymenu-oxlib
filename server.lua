local DISCORD_BOT_TOKEN = "DISCORD_BOT_TOKEN"
local GUILD_ID = "GUILD_ID"

local DEPARTMENT_ROLES = {
    SASP = "SASP_ROLE_ID",
    BCSO = "BCSO_ROLE_ID",
    LSPD = "LSPD_ROLE_ID"
}

local playersOnDuty = {}

function GetDiscordId(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(identifier, "discord:") then
            return string.gsub(identifier, "discord:", "")
        end
    end
    return nil
end

function UserHasRole(discordId, roleId, callback)
    local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(GUILD_ID, discordId)
    PerformHttpRequest(url, function(code, data)
        if code == 200 then
            local user = json.decode(data)
            for _, role in ipairs(user.roles or {}) do
                if role == roleId then callback(true) return end
            end
        end
        callback(false)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. DISCORD_BOT_TOKEN,
        ["Content-Type"] = "application/json"
    })
end

function FormatDutyTime(startTime)
    local duration = os.time() - startTime
    local h = math.floor(duration / 3600)
    local m = math.floor((duration % 3600) / 60)
    local s = duration % 60
    return (h > 0 and string.format("%dh %dm %ds", h, m, s)) or (m > 0 and string.format("%dm %ds", m, s)) or string.format("%ds", s)
end

function BroadcastDutyBlips()
    TriggerClientEvent("duty:updateBlips", -1, playersOnDuty)
end

RegisterServerEvent("duty:updateStatus")
AddEventHandler("duty:updateStatus", function(onDuty, department, playerName, callsign)
    local src = source
    local discordId = GetDiscordId(src)
    local statusText = onDuty and "On Duty" or "Off Duty"
    local name = playerName or GetPlayerName(src)
    local role = DEPARTMENT_ROLES[department]

    if not discordId then
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = "No linked Discord account."})
        return
    end

    if onDuty then
        UserHasRole(discordId, role, function(hasRole)
            if not hasRole then
                TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = "Missing required Discord role for " .. department})
                return
            end

            playersOnDuty[src] = {
                playerName = name,
                callsign = callsign,
                department = department,
                startTime = os.time(),
                discordId = discordId
            }

            print(string.format("%s (%s) went ON duty in %s [%s]", name, discordId, department, callsign))
            SendDutyLogWebhook(name, callsign, department, onDuty, discordId, nil)
            TriggerClientEvent("duty:giveLoadout", src)
            BroadcastDutyBlips()

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'inform',
                description = string.format("You are now ON DUTY as %s (%s)", department, callsign)
            })
        end)
    else
        if playersOnDuty[src] then
            local dutyTime = FormatDutyTime(playersOnDuty[src].startTime)
            TriggerClientEvent("duty:showDutyTime", src, dutyTime)
            SendDutyLogWebhook(name, callsign, department, onDuty, discordId, dutyTime)
            playersOnDuty[src] = nil
            BroadcastDutyBlips()

            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = string.format("You are now OFF DUTY. Time on duty: %s", dutyTime)
            })
        end

        print(string.format("%s (%s) went OFF duty", name, discordId))
    end
end)

function SendDutyLogWebhook(name, callsign, department, onDuty, discordId, dutyTime)
    local currentTime = os.date("%A, %B %d, %Y %I:%M %p")
    local status = onDuty and "On Duty" or "Off Duty"
    local departmentLogos = {
        SASP = "https://i.imgur.com/qwjPGhj.png",
        BCSO = "https://i.imgur.com/MWL8fOL.png",
        LSPD = "https://i.imgur.com/PCRR7pN.png"
    }

    local fields = {
        { name = "Name", value = name, inline = true },
        { name = "Callsign", value = callsign, inline = true },
        { name = "Department", value = department, inline = true },
        { name = "Status", value = status, inline = true },
        { name = onDuty and "Time On Duty" or "Time Off Duty", value = currentTime, inline = true },
        { name = "Discord Check", value = discordId and "✅ Role Verified" or "❌ Not Linked", inline = true }
    }

    if not onDuty and dutyTime then
        table.insert(fields, { name = "Duty Duration", value = dutyTime, inline = true })
    end

    PerformHttpRequest("DISCORD_WEBHOOK_LINK", function() end, "POST", json.encode({
        username = "SpongeBobs Duty System",
        avatar_url = "https://i.imgur.com/RZ26FYn.jpeg",
        embeds = {{
            color = onDuty and 3066993 or 15158332,
            title = "Duty Log",
            description = string.format("**%s** (Callsign: %s) from **%s** is now **%s**", name, callsign, department, status),
            thumbnail = { url = departmentLogos[department] or "https://i.imgur.com/default-badge.png" },
            fields = fields,
            footer = { text = "SpongeBobs Duty System • " .. currentTime },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }), { ["Content-Type"] = "application/json" })
end

AddEventHandler('playerDropped', function()
    local src = source
    if playersOnDuty[src] then
        local p = playersOnDuty[src]
        local dutyTime = FormatDutyTime(p.startTime)
        print(string.format("%s disconnected while on duty. Duration: %s", p.playerName, dutyTime))
        playersOnDuty[src] = nil
        BroadcastDutyBlips()
    end
end)

RegisterCommand("dutylist", function(source)
    if source == 0 then
        print("=== Players Currently On Duty ===")
        for id, data in pairs(playersOnDuty) do
            print(string.format("ID: %s | %s (%s) - %s | Duration: %s",
                id, data.playerName, data.callsign, data.department, FormatDutyTime(data.startTime)))
        end
        if next(playersOnDuty) == nil then print("No players on duty.") end
    end
end, true)

RegisterServerEvent("duty:requestBlips")
AddEventHandler("duty:requestBlips", function()
    TriggerClientEvent("duty:updateBlips", source, playersOnDuty)
end)

exports('GetPlayersOnDuty', function()
    return playersOnDuty
end)
