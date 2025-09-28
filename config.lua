Config = {}

-- Discord Bot Token and Guild ID (required for "discord" perm type)
Config.BotToken = "" -- Your Discord bot token
Config.GuildID = ""  -- Your Discord server (guild) ID

-- Admin Menu Permissions (for /eupadmin)
Config.AdminPermType = "discord" -- "ace" or "discord"
Config.AdminAce = "" -- ACE permission string for admin access
Config.AdminDiscordRoles = { -- Up to 4 Discord role IDs
    "",
    "",
    "",
    ""
}

-- EUP Menu Permissions (for /eup)
Config.EupPermType = "none" -- "ace", "discord", or "none"
Config.EupAce = "eup.user" -- ACE permission string for EUP access
Config.EupDiscordRoles = { -- Up to 4 Discord role IDs
    "",
    "",
    "",
    ""
}