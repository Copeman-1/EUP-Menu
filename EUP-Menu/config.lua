Config = {}

-- Permission types for /eup and /eupadmin. Use one type, or a list of types
-- (passing ANY one of them is enough), e.g. { "qbcore_job", "qbcore_admin" }
--   "none"          everyone (only allowed for /eup, never for /eupadmin)
--   "ace"           ACE permission (Config.AdminAce / Config.EupAce)
--   "discord"       Discord roles  (Config.AdminDiscordRoles / Config.EupDiscordRoles)
--   "qbcore_job"    QBCore job + minimum grade (Config.AdminJobs / Config.EupJobs)
--   "qbcore_admin"  QBCore permission level (Config.AdminQBPermission / Config.EupQBPermission)

-- Discord Bot Token and Guild ID (only required when using the "discord" type)
Config.BotToken = "" -- Your Discord bot token
Config.GuildID = ""  -- Your Discord server (guild) ID

-- Admin Menu Permissions (for /eupadmin)
Config.AdminPermType = { "qbcore_admin" } -- "ace", "discord", "qbcore_job", "qbcore_admin" or a list of them
Config.AdminAce = "eup.admin"
Config.AdminDiscordRoles = { -- Up to 4 Discord role IDs
    "",
    "",
    "",
    ""
}
Config.AdminQBPermission = { "admin", "god" } -- QBCore permission levels allowed to use /eupadmin
Config.AdminJobs = {                          -- [job name] = minimum grade level
    -- police = 4,
}
Config.AdminRequireOnDuty = false

-- EUP Menu Permissions (for /eup)
Config.EupPermType = { "qbcore_job", "qbcore_admin" } -- "none", "ace", "discord", "qbcore_job", "qbcore_admin" or a list of them
Config.EupAce = "eup.user"
Config.EupDiscordRoles = { -- Up to 4 Discord role IDs
    "",
    "",
    "",
    ""
}
Config.EupQBPermission = { "admin", "god" } -- QBCore permission levels allowed to use /eup
Config.EupJobs = {                          -- [job name] = minimum grade level
    police = 0,
    sheriff = 0,
    ambulance = 0,
    fire = 0,
}
Config.EupRequireOnDuty = false -- true = job must be clocked on duty to open /eup

-- Prints extra info to the server console when a QBCore admin check is denied
Config.Debug = false

---------------------------------------------------------------------------
-- Category Permission Settings (used by the in-game "Set Permissions" button)
---------------------------------------------------------------------------

-- Jobs that appear in the multi-select dropdown when setting category access
Config.AvailableJobs = {
    { value = 'police',    label = 'Police' },
    { value = 'sheriff',   label = 'Sheriff' },
    { value = 'ambulance', label = 'EMS / Ambulance' },
    { value = 'fire',      label = 'Fire' },
    { value = 'mechanic',  label = 'Mechanic' },
    -- Add more jobs here as needed
}

-- Default minimum grade when selecting jobs for a category
Config.DefaultGrade = 0