Config = {}

Config.DISCORD_BOT_TOKEN = "DISCORD_BOT_TOKEN"
Config.GUILD_ID = "GUILD_ID"

Config.DEPARTMENT_ROLES = {
    SASP = "SASP_ROLE_ID",
    BCSO = "BCSO_ROLE_ID",
    LSPD = "LSPD_ROLE_ID"
    -- Just Add More Departments Above This 
}

Config.WEBHOOK = "WEBHOOK_LINK_HERE"

Config.DepartmentLogos = {
    SASP = "https://i.imgur.com/qwjPGhj.png",
    BCSO = "https://i.imgur.com/MWL8fOL.png",
    LSPD = "https://i.imgur.com/PCRR7pN.png"
    -- Just Add More Departments Above This 
}

Config.Departments = {
    {
        label = 'SASP',
        value = 'SASP',
        blipSprite = 56,
        blipColor = 5,
        loadout = {
            weapons = {
                {weapon = 'WEAPON_COMBATPISTOL', ammo = 250, components = {'COMPONENT_AT_PI_FLSH'}},
                {weapon = 'WEAPON_CARBINERIFLE', ammo = 200, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_PUMPSHOTGUN', ammo = 50, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_STUNGUN', ammo = 1, components = {}},
                {weapon = 'WEAPON_NIGHTSTICK', ammo = 1, components = {}},
                {weapon = 'WEAPON_FLASHLIGHT', ammo = 1, components = {}},
                {weapon = 'WEAPON_FIREEXTINGUISHER', ammo = 1000, components = {}}
            },
            armor = 100
        }
    },
    {
        label = 'BCSO',
        value = 'BCSO',
        blipSprite = 56,
        blipColor = 17,
        loadout = {
            weapons = {
                {weapon = 'WEAPON_COMBATPISTOL', ammo = 250, components = {'COMPONENT_AT_PI_FLSH'}},
                {weapon = 'WEAPON_CARBINERIFLE', ammo = 200, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_PUMPSHOTGUN', ammo = 50, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_STUNGUN', ammo = 1, components = {}},
                {weapon = 'WEAPON_NIGHTSTICK', ammo = 1, components = {}},
                {weapon = 'WEAPON_FLASHLIGHT', ammo = 1, components = {}},
                {weapon = 'WEAPON_FIREEXTINGUISHER', ammo = 1000, components = {}}
            },
            armor = 100
        }
    },
    {
        label = 'LSPD',
        value = 'LSPD',
        blipSprite = 56,
        blipColor = 3,
        loadout = {
            weapons = {
                {weapon = 'WEAPON_COMBATPISTOL', ammo = 250, components = {'COMPONENT_AT_PI_FLSH'}},
                {weapon = 'WEAPON_CARBINERIFLE', ammo = 200, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_PUMPSHOTGUN', ammo = 50, components = {'COMPONENT_AT_AR_FLSH'}},
                {weapon = 'WEAPON_STUNGUN', ammo = 1, components = {}},
                {weapon = 'WEAPON_NIGHTSTICK', ammo = 1, components = {}},
                {weapon = 'WEAPON_FLASHLIGHT', ammo = 1, components = {}},
                {weapon = 'WEAPON_FIREEXTINGUISHER', ammo = 1000, components = {}}
            },
            armor = 100
        }
    }
        -- Just Add More Departments Above This 
}
