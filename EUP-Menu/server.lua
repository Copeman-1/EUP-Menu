local RESOURCE = GetCurrentResourceName()
local FILE = 'outfits.json'
local CACHE_SECONDS = 60

local outfits = {}
local permCache = {}

local function log(msg)
    print('[EUP_Menu] ' .. msg)
end


local function saveOutfits()
    local ok = SaveResourceFile(RESOURCE, FILE, json.encode(outfits, { indent = true }), -1)
    if not ok then log('ERROR: Failed to save ' .. FILE) end
    return ok
end

local function normalize()
    for _, menu in pairs(outfits) do
        menu.submenus = menu.submenus or {}
        menu.permissions = menu.permissions or { jobs = {}, requireOnDuty = false }
        for _, sub in pairs(menu.submenus) do
            sub.uniforms = sub.uniforms or {}
        end
    end
end

local function loadOutfits()
    local raw = LoadResourceFile(RESOURCE, FILE)

    if not raw or raw == '' then
        log('No ' .. FILE .. ' found, creating an empty one')
        outfits = {}
        saveOutfits()
        return
    end

    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        outfits = data
        normalize()
    else
        
        log('ERROR: Could not decode ' .. FILE .. ', backing it up to outfits.backup.json and starting empty')
        SaveResourceFile(RESOURCE, 'outfits.backup.json', raw, -1)
        outfits = {}
    end
end

loadOutfits()



local function getDiscordId(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find('discord:', 1, true) == 1 then
            return id:sub(9)
        end
    end
end

local function fetchDiscordRoles(discordId)
    local p = promise.new()

    PerformHttpRequest(
        ('https://discord.com/api/guilds/%s/members/%s'):format(Config.GuildID, discordId),
        function(status, body)
            if status == 200 then
                local data = json.decode(body)
                local roles = {}
                for _, role in ipairs(data and data.roles or {}) do roles[role] = true end
                p:resolve(roles)
            else
                log(('ERROR: Discord API request failed (status %s)'):format(tostring(status)))
                p:resolve({})
            end
        end,
        'GET', '', { Authorization = 'Bot ' .. Config.BotToken }
    )

    return Citizen.Await(p)
end


local function getDiscordRoles(discordId)
    local cached = permCache[discordId]
    if cached and cached.expires > GetGameTimer() then
        return cached.roles
    end

    local roles = fetchDiscordRoles(discordId)
    permCache[discordId] = { roles = roles, expires = GetGameTimer() + CACHE_SECONDS * 1000 }
    return roles
end

-- QBCore is looked up lazily so the resource still works on servers that do not use it
local QBCore

local function getQBCore()
    if QBCore then return QBCore end
    if GetResourceState('qb-core') ~= 'started' then return nil end

    local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if ok then QBCore = core end
    return QBCore
end

local function toList(value)
    if type(value) == 'table' then return value end
    if value == nil or value == '' then return {} end
    return { value }
end


local function checkQBJob(src, jobs, requireOnDuty)
    local core = getQBCore()
    if not core then
        log('ERROR: qb-core is not started, cannot check QBCore jobs')
        return false
    end

    local player = core.Functions.GetPlayer(src)
    local job = player and player.PlayerData and player.PlayerData.job
    if not job then return false end

    local minGrade = jobs and jobs[job.name]
    if minGrade == nil then return false end

    local grade = job.grade and tonumber(job.grade.level) or 0
    if grade < minGrade then return false end

    if requireOnDuty and not job.onduty then return false end

    return true
end


local function checkQBAdmin(src, permissions)
    local core = getQBCore()
    if not core then
        log('ERROR: qb-core is not started, cannot check QBCore permissions')
        return false
    end

  
    if IsPlayerAceAllowed(src, 'command') then return true end

    for _, permission in ipairs(toList(permissions)) do
        if permission ~= '' then
            local okPerm, hasPerm = pcall(core.Functions.HasPermission, src, permission)
            if okPerm and hasPerm then return true end

           
            if IsPlayerAceAllowed(src, permission) or IsPlayerAceAllowed(src, 'qbcore.' .. permission) then
                return true
            end
        end
    end

    if Config.Debug then
        log(('QBCore admin check DENIED for %s (%d). identifiers: %s'):format(
            GetPlayerName(src), src, json.encode(GetPlayerIdentifiers(src))))
    end

    return false
end

local function checkType(src, permType, isAdmin)
    local prefix = isAdmin and 'Admin' or 'Eup'

    if permType == 'none' then
        return not isAdmin -- 
    end

    if permType == 'ace' then
        local ace = Config[prefix .. 'Ace']
        return ace ~= nil and ace ~= '' and IsPlayerAceAllowed(src, ace) == true
    end

    if permType == 'discord' then
        if not Config.BotToken or Config.BotToken == '' or not Config.GuildID or Config.GuildID == '' then
            log('ERROR: BotToken or GuildID missing in config.lua')
            return false
        end

        local discordId = getDiscordId(src)
        if not discordId then return false end

        local roles = getDiscordRoles(discordId)
        for _, role in ipairs(Config[prefix .. 'DiscordRoles'] or {}) do
            if role ~= '' and roles[role] then return true end
        end
        return false
    end

    if permType == 'qbcore_job' then
        return checkQBJob(src, Config[prefix .. 'Jobs'], Config[prefix .. 'RequireOnDuty'])
    end

    if permType == 'qbcore_admin' then
        return checkQBAdmin(src, Config[prefix .. 'QBPermission'])
    end

    log('ERROR: Invalid permission type in config.lua: ' .. tostring(permType))
    return false
end


local function hasPermission(src, kind)
    local isAdmin = kind == 'admin'
    local permTypes = toList(isAdmin and Config.AdminPermType or Config.EupPermType)

    for _, permType in ipairs(permTypes) do
        if checkType(src, permType, isAdmin) then return true end
    end

    return false
end



local function getCategoryPerms(menuName)
    local menu = outfits[menuName]
    if not menu then return nil end
    return menu.permissions or { jobs = {}, requireOnDuty = false }
end


local function canAccessCategory(src, menuName)
   
    if hasPermission(src, 'admin') then return true end

    local perms = getCategoryPerms(menuName)
    if not perms or not perms.jobs or next(perms.jobs) == nil then
        
        return hasPermission(src, 'user')
    end

   
    return checkQBJob(src, perms.jobs, perms.requireOnDuty)
end


local function filterOutfitsForPlayer(src)
    local filtered = {}
    for menuName, menuData in pairs(outfits) do
        if canAccessCategory(src, menuName) then
            filtered[menuName] = menuData
        end
    end
    return filtered
end



local function cleanName(name)
    if type(name) ~= 'string' then return nil end
    name = name:match('^%s*(.-)%s*$')
    if #name < 1 or #name > 32 then return nil end
    return name
end

local function cleanClothing(data)
    if type(data) ~= 'table' then return nil end

    local out, count = {}, 0
    for k, v in pairs(data) do
        if type(k) == 'string' and #k <= 32 and type(v) == 'number' then
            count = count + 1
            if count > 60 then return nil end
            out[k] = math.floor(v)
        end
    end

    return count > 0 and out or nil
end

local function getUniformTable(menuName, subName, create)
    local menu = outfits[menuName]
    if not menu then return nil, 'That menu does not exist.' end

    local node = menu
    if subName then
        node = menu.submenus and menu.submenus[subName]
        if not node then return nil, 'That sub menu does not exist.' end
    end

    if create and not node.uniforms then node.uniforms = {} end
    return node.uniforms
end



lib.callback.register('eup:open', function(src)
    if not hasPermission(src, 'user') then
        return { ok = false, error = 'You do not have permission to use /eup.' }
    end
    return { ok = true, outfits = filterOutfitsForPlayer(src) }
end)

lib.callback.register('eup:openAdmin', function(src)
    if not hasPermission(src, 'admin') then
        return { ok = false, error = 'You do not have permission to use /eupadmin.' }
    end
    
    return { ok = true, outfits = outfits }
end)


local function registerAdminCallback(name, handler)
    lib.callback.register(name, function(src, ...)
        if not hasPermission(src, 'admin') then
            return { ok = false, error = 'You do not have permission to do that.' }
        end

        local ok, err = handler(src, ...)
        if not ok then return { ok = false, error = err or 'Request failed.' } end

        if not saveOutfits() then
            return { ok = false, error = 'Failed to write outfits.json, check the server console.' }
        end

        return { ok = true, outfits = outfits }
    end)
end

registerAdminCallback('eup:createMenu', function(src, menuName)
    menuName = cleanName(menuName)
    if not menuName then return false, 'Invalid menu name (1-32 characters).' end
    if outfits[menuName] then return false, 'Menu already exists.' end

    outfits[menuName] = {
        submenus = {},
        uniforms = {},
        permissions = { jobs = {}, requireOnDuty = false }
    }
    log(('%s (%d) created menu "%s"'):format(GetPlayerName(src), src, menuName))
    return true
end)

registerAdminCallback('eup:createSubmenu', function(src, menuName, subName)
    subName = cleanName(subName)
    if not subName then return false, 'Invalid sub menu name (1-32 characters).' end

    local menu = outfits[menuName]
    if not menu then return false, 'That menu does not exist.' end
    menu.submenus = menu.submenus or {}
    if menu.submenus[subName] then return false, 'Sub menu already exists.' end

    menu.submenus[subName] = { uniforms = {} }
    log(('%s (%d) created sub menu "%s/%s"'):format(GetPlayerName(src), src, menuName, subName))
    return true
end)

registerAdminCallback('eup:saveUniform', function(src, menuName, subName, name, data)
    if subName == false then subName = nil end

    name = cleanName(name)
    if not name then return false, 'Invalid outfit name (1-32 characters).' end

    data = cleanClothing(data)
    if not data then return false, 'Invalid clothing data.' end

    local uniforms, err = getUniformTable(menuName, subName, true)
    if not uniforms then return false, err end

    uniforms[name] = data
    log(('%s (%d) saved outfit "%s" to "%s%s"'):format(GetPlayerName(src), src, name, menuName, subName and ('/' .. subName) or ''))
    return true
end)

registerAdminCallback('eup:deleteUniform', function(src, menuName, subName, name)
    if subName == false then subName = nil end

    local uniforms, err = getUniformTable(menuName, subName, false)
    if not uniforms then return false, err end
    if type(name) ~= 'string' or not uniforms[name] then return false, 'That outfit does not exist.' end

    uniforms[name] = nil
    log(('%s (%d) deleted outfit "%s" from "%s%s"'):format(GetPlayerName(src), src, name, menuName, subName and ('/' .. subName) or ''))
    return true
end)

registerAdminCallback('eup:setCategoryPerms', function(src, menuName, jobsTable, requireOnDuty)
    if type(menuName) ~= 'string' or not outfits[menuName] then
        return false, 'That menu does not exist.'
    end

    if type(jobsTable) ~= 'table' then
        return false, 'Invalid jobs data.'
    end

    outfits[menuName].permissions = {
        jobs = jobsTable,               -- e.g. { police = 0, sheriff = 2 }
        requireOnDuty = requireOnDuty == true
    }

    log(('%s (%d) updated permissions for category "%s"'):format(GetPlayerName(src), src, menuName))
    return true
end)