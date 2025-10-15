local isOnDuty = false
local department = ""
local playerName = ""
local callsign = ""
local dutyBlips = {}

RegisterCommand("duty", function()
    if isOnDuty then
        TriggerServerEvent("duty:updateStatus", false, department, playerName, callsign)
        return
    end

    local departmentOptions = {}
    for _, dept in ipairs(Config.Departments) do
        table.insert(departmentOptions, {
            label = dept.label,
            value = dept.value
        })
    end

    local input = lib.inputDialog('Duty Menu', {
        {type = 'select', label = 'Department', options = departmentOptions},
        {type = 'input', label = 'Your Name'},
        {type = 'input', label = 'Callsign'}
    })

    if input and input[1] and input[2] and input[3] then
        department = input[1]
        playerName = input[2]
        callsign = input[3]

        TriggerServerEvent("duty:updateStatus", true, department, playerName, callsign)
    else
        lib.notify({
            title = "Duty Menu",
            description = "You must fill in all fields to go on duty.",
            type = "error"
        })
    end
end)

RegisterNetEvent("duty:confirmedOnDuty")
AddEventHandler("duty:confirmedOnDuty", function()
    isOnDuty = true
end)

RegisterNetEvent("duty:roleFailed")
AddEventHandler("duty:roleFailed", function()
    isOnDuty = false
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
AddEventHandler("duty:giveLoadout", function(dept)
    local ped = PlayerPedId()
    local departmentConfig = nil
    
    for _, deptData in ipairs(Config.Departments) do
        if deptData.value == dept then
            departmentConfig = deptData
            break
        end
    end
    
    if not departmentConfig then
        lib.notify({
            title = "Loadout",
            description = "Department configuration not found.",
            type = "error"
        })
        return
    end
    
    for _, weaponData in ipairs(departmentConfig.loadout.weapons) do
        local weaponHash = GetHashKey(weaponData.weapon)
        GiveWeaponToPed(ped, weaponHash, weaponData.ammo, false, true)
        
        for _, component in ipairs(weaponData.components) do
            GiveWeaponComponentToPed(ped, weaponHash, GetHashKey(component))
        end
    end
    
    SetPedArmour(ped, departmentConfig.loadout.armor)

    lib.notify({
        title = "Loadout",
        description = "✓ Full duty loadout equipped with attachments.",
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
    for _, department in ipairs(Config.Departments) do
        if department.value == dept then
            return department.blipColor
        end
    end
    return 1 
end

function GetDepartmentBlipSprite(dept)
    for _, department in ipairs(Config.Departments) do
        if department.value == dept then
            return department.blipSprite
        end
    end
    return 1 
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
