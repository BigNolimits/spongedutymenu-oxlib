local isOnDuty = false
local department = ""
local playerName = ""
local callsign = ""
local dutyBlips = {}

RegisterCommand("duty", function()
    local input = lib.inputDialog('Duty Menu', {
        {type = 'select', label = 'Department', options = {
            {label = 'SASP', value = 'SASP'},
            {label = 'BCSO', value = 'BCSO'},
            {label = 'LSPD', value = 'LSPD'}
        }},
        {type = 'input', label = 'Your Name'},
        {type = 'input', label = 'Callsign'},
        {type = 'checkbox', label = 'Go On Duty'}
    })

    if input then
        department = input[1]
        playerName = input[2]
        callsign = input[3]
        isOnDuty = input[4]

        TriggerServerEvent("duty:updateStatus", isOnDuty, department, playerName, callsign)
    end
end)

RegisterNetEvent("duty:showDutyTime")
AddEventHandler("duty:showDutyTime", function(dutyTime)
    lib.notify({
        title = "Duty Ended",
        description = ("You were on duty for: %s"):format(dutyTime),
        type = "info"
    })
end)

RegisterNetEvent("duty:giveLoadout")
AddEventHandler("duty:giveLoadout", function()
    local ped = PlayerPedId()

    GiveWeaponToPed(ped, `WEAPON_COMBATPISTOL`, 250, false, true)
    GiveWeaponComponentToPed(ped, `WEAPON_COMBATPISTOL`, `COMPONENT_AT_PI_FLSH`)
    GiveWeaponToPed(ped, `WEAPON_CARBINERIFLE`, 200, false, true)
    GiveWeaponComponentToPed(ped, `WEAPON_CARBINERIFLE`, `COMPONENT_AT_AR_FLSH`)
    GiveWeaponToPed(ped, `WEAPON_PUMPSHOTGUN`, 50, false, true)
    GiveWeaponComponentToPed(ped, `WEAPON_PUMPSHOTGUN`, `COMPONENT_AT_AR_FLSH`)
    GiveWeaponToPed(ped, `WEAPON_STUNGUN`, 1, false, true)
    GiveWeaponToPed(ped, `WEAPON_NIGHTSTICK`, 1, false, true)
    GiveWeaponToPed(ped, `WEAPON_FLASHLIGHT`, 1, false, true)
    GiveWeaponToPed(ped, `WEAPON_FIREEXTINGUISHER`, 1000, false, true)
    SetPedArmour(ped, 100)

    lib.notify({
        title = "Loadout",
        description = "🔫 Full duty loadout equipped with attachments.",
        type = "success"
    })
end)

RegisterNetEvent("duty:updateBlips")
AddEventHandler("duty:updateBlips", function(playersOnDuty)
    for playerId, blipData in pairs(dutyBlips) do
        if DoesBlipExist(blipData.blip) then
            RemoveBlip(blipData.blip)
        end
    end
    dutyBlips = {}

    for playerId, playerData in pairs(playersOnDuty) do
        local targetPlayer = GetPlayerFromServerId(playerId)
        if targetPlayer ~= -1 and targetPlayer ~= PlayerId() then
            local targetPed = GetPlayerPed(targetPlayer)
            if DoesEntityExist(targetPed) then
                local blip = AddBlipForEntity(targetPed)
                SetBlipSprite(blip, GetDepartmentBlipSprite(playerData.department))
                SetBlipColour(blip, GetDepartmentBlipColor(playerData.department))
                SetBlipScale(blip, 0.8)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(("%s - %s (%s)"):format(playerData.department, playerData.playerName, playerData.callsign))
                EndTextCommandSetBlipName(blip)
                dutyBlips[playerId] = {blip = blip, data = playerData}
            end
        end
    end
end)

function GetDepartmentBlipColor(dept)
    return ({SASP = 5, BCSO = 17, LSPD = 3})[dept] or 1
end

function GetDepartmentBlipSprite(dept)
    return ({SASP = 56, BCSO = 56, LSPD = 56})[dept] or 1
end

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        for playerId, blipData in pairs(dutyBlips) do
            local targetPlayer = GetPlayerFromServerId(playerId)
            local targetPed = GetPlayerPed(targetPlayer)
            if targetPlayer == -1 or not DoesEntityExist(targetPed) or not DoesBlipExist(blipData.blip) then
                if DoesBlipExist(blipData.blip) then RemoveBlip(blipData.blip) end
                dutyBlips[playerId] = nil
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for _, v in pairs(dutyBlips) do
            if DoesBlipExist(v.blip) then RemoveBlip(v.blip) end
        end
    end
end)
