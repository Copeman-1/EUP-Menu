-- EUP Menu Server Script
-- Handles saving and loading of outfits.json for the EUP Menu resource
-- Supports ACE and Discord permissions for /eup and /eupadmin

-- Helper functions for Discord permissions
local function GetDiscordID(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(id, "discord:") then
            local discordID = string.sub(id, 9)
            print('[EUP_Menu] Found Discord ID: ' .. discordID .. ' for player ' .. source)
            return discordID
        end
    end
    print('[EUP_Menu] No Discord ID found for player ' .. source)
    return nil
end

local function GetDiscordRoles(discordID, callback)
    print('[EUP_Menu] Sending Discord API request for user: ' .. discordID)
    PerformHttpRequest("https://discord.com/api/guilds/" .. Config.GuildID .. "/members/" .. discordID, function(status, body, headers)
        if status == 200 then
            local data = json.decode(body)
            if data and data.roles then
                local roles = {}
                for _, role in ipairs(data.roles) do
                    roles[role] = true
                end
                print('[EUP_Menu] Discord roles retrieved for ' .. discordID .. ': ' .. json.encode(roles))
                callback(roles)
            else
                print('[EUP_Menu] ERROR: Invalid Discord API response for ' .. discordID)
                callback({})
            end
        else
            print('[EUP_Menu] ERROR: Discord API request failed, status: ' .. status .. ', body: ' .. tostring(body))
            callback({})
        end
    end, 'GET', "", {Authorization = "Bot " .. Config.BotToken})
end

-- Load outfits from json file
RegisterServerEvent('eup:loadOutfits')
AddEventHandler('eup:loadOutfits', function()
    local source = source
    local resourceName = GetCurrentResourceName()
    local fileName = 'outfits.json'
    local jsonData = LoadResourceFile(resourceName, fileName)
    if not jsonData then
        print('[EUP_Menu] No outfits.json found, initializing empty file')
        SaveResourceFile(resourceName, fileName, json.encode({}, {indent = true}), -1)
        TriggerClientEvent('eup:receiveOutfits', source, {})
        return
    end
    local data = json.decode(jsonData)
    if not data then
        print('[EUP_Menu] Failed to decode outfits.json')
        TriggerClientEvent('eup:receiveOutfits', source, {})
        return
    end
    TriggerClientEvent('eup:receiveOutfits', source, data)
end)

-- Save outfits to json file
RegisterServerEvent('eup:saveOutfits')
AddEventHandler('eup:saveOutfits', function(outfits)
    local source = source
    local resourceName = GetCurrentResourceName()
    local fileName = 'outfits.json'
    local jsonData = json.encode(outfits, {indent = true})
    local success = SaveResourceFile(resourceName, fileName, jsonData, -1)
    if not success then
        print('[EUP_Menu] Failed to save outfits.json')
        TriggerClientEvent('eup:saveOutfitsResult', source, false)
    end
    TriggerClientEvent('eup:saveOutfitsResult', source, true)
end)

-- Permission check for /eupadmin
RegisterServerEvent('eup:checkAdminPermission')
AddEventHandler('eup:checkAdminPermission', function()
    local source = source
    print('[EUP_Menu] Checking admin permission for player ' .. source)

    -- Validate Config
    if not Config then
        print('[EUP_Menu] ERROR: Config table not loaded. Check config.lua.')
        TriggerClientEvent('eup:openAdminMenuResult', source, false)
        return
    end

    local hasPermission = false
    if Config.AdminPermType == "ace" then
        print('[EUP_Menu] Checking ACE permission: ' .. Config.AdminAce)
        hasPermission = IsPlayerAceAllowed(source, Config.AdminAce)
    elseif Config.AdminPermType == "discord" then
        if not Config.BotToken or Config.BotToken == "" or not Config.GuildID or Config.GuildID == "" then
            print('[EUP_Menu] ERROR: BotToken or GuildID missing in config.lua')
            TriggerClientEvent('eup:openAdminMenuResult', source, false)
            return
        end
        local discordID = GetDiscordID(source)
        if discordID then
            print('[EUP_Menu] Fetching Discord roles for ID: ' .. discordID)
            GetDiscordRoles(discordID, function(roles)
                for _, role in ipairs(Config.AdminDiscordRoles) do
                    if role ~= "" and roles[role] then
                        print('[EUP_Menu] Player ' .. source .. ' has required Discord role: ' .. role)
                        hasPermission = true
                        break
                    end
                end
                TriggerClientEvent('eup:openAdminMenuResult', source, hasPermission)
                print('[EUP_Menu] Admin permission result for player ' .. source .. ': ' .. tostring(hasPermission))
            end)
            return
        else
            print('[EUP_Menu] No Discord ID found for player ' .. source)
            hasPermission = false
        end
    else
        print('[EUP_Menu] ERROR: Invalid AdminPermType in config.lua: ' .. tostring(Config.AdminPermType))
        hasPermission = false
    end
    TriggerClientEvent('eup:openAdminMenuResult', source, hasPermission)
    print('[EUP_Menu] Admin permission result for player ' .. source .. ': ' .. tostring(hasPermission))
end)

-- Permission check for /eup
RegisterServerEvent('eup:checkEupPermission')
AddEventHandler('eup:checkEupPermission', function()
    local source = source
    print('[EUP_Menu] Checking EUP permission for player ' .. source)

    -- Validate Config
    if not Config then
        print('[EUP_Menu] ERROR: Config table not loaded. Check config.lua.')
        TriggerClientEvent('eup:openEupMenuResult', source, false)
        return
    end

    local hasPermission = true
    if Config.EupPermType == "ace" then
        print('[EUP_Menu] Checking ACE permission: ' .. Config.EupAce)
        hasPermission = IsPlayerAceAllowed(source, Config.EupAce)
    elseif Config.EupPermType == "discord" then
        if not Config.BotToken or Config.BotToken == "" or not Config.GuildID or Config.GuildID == "" then
            print('[EUP_Menu] ERROR: BotToken or GuildID missing in config.lua')
            TriggerClientEvent('eup:openEupMenuResult', source, false)
            return
        end
        local discordID = GetDiscordID(source)
        if discordID then
            print('[EUP_Menu] Fetching Discord roles for ID: ' .. discordID)
            GetDiscordRoles(discordID, function(roles)
                for _, role in ipairs(Config.EupDiscordRoles) do
                    if role ~= "" and roles[role] then
                        print('[EUP_Menu] Player ' .. source .. ' has required Discord role: ' .. role)
                        hasPermission = true
                        break
                    end
                end
                TriggerClientEvent('eup:openEupMenuResult', source, hasPermission)
                print('[EUP_Menu] EUP permission result for player ' .. source .. ': ' .. tostring(hasPermission))
            end)
            return
        else
            print('[EUP_Menu] No Discord ID found for player ' .. source)
            hasPermission = false
        end
    elseif Config.EupPermType ~= "none" then
        print('[EUP_Menu] ERROR: Invalid EupPermType in config.lua: ' .. tostring(Config.EupPermType))
        hasPermission = false
    end
    TriggerClientEvent('eup:openEupMenuResult', source, hasPermission)
    print('[EUP_Menu] EUP permission result for player ' .. source .. ': ' .. tostring(hasPermission))
end)