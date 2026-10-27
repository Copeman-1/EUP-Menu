local outfits = {}
local adminMode = false

local ROOT = 'eup_root'
local DELETE = 'eup_delete'


local PROPS = {
    { key = 'hat',      id = 0 },
    { key = 'glasses',  id = 1 },
    { key = 'ear',      id = 2 },
    { key = 'watch',    id = 6 },
    { key = 'bracelet', id = 7 },
}

local COMPONENTS = {
    { key = 'mask',      id = 1 },
    { key = 'torso',     id = 3 },
    { key = 'pants',     id = 4 },
    { key = 'shoes',     id = 6 },
    { key = 'accessory', id = 7 },
    { key = 'bag',       id = 5 },
    { key = 'vest',      id = 9 },
    { key = 'decal',     id = 10 },
    { key = 'shirt',     id = 8 },
    { key = 'jacket',    id = 11, optional = true },
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local function notify(description, nType)
    lib.notify({ title = 'EUP Menu', description = description, type = nType or 'inform' })
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t or {}) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
    return keys
end

local function trim(s)
    return (tostring(s or ''):match('^%s*(.-)%s*$'))
end

local function deptId(menuName)
    return 'eup_dept:' .. menuName
end

local function subId(menuName, subName)
    return ('eup_sub:%d:%s%s'):format(#menuName, menuName, subName)
end

local function pathLabel(menuName, subName)
    if subName then return menuName .. ' / ' .. subName end
    return menuName
end

local function getUniforms(menuName, subName)
    local menu = outfits[menuName]
    if not menu then return nil end
    if subName then
        local sub = menu.submenus and menu.submenus[subName]
        return sub and sub.uniforms
    end
    return menu.uniforms
end

local function collectClothing()
    local ped = PlayerPedId()
    local data = {}

    for _, p in ipairs(PROPS) do
        data[p.key] = GetPedPropIndex(ped, p.id)
        data[p.key .. 'Texture'] = GetPedPropTextureIndex(ped, p.id)
    end

    for _, c in ipairs(COMPONENTS) do
        data[c.key] = GetPedDrawableVariation(ped, c.id)
        data[c.key .. 'Texture'] = GetPedTextureVariation(ped, c.id)
    end

    return data
end

local function applyUniform(name, data)
    local ped = PlayerPedId()

    for _, p in ipairs(PROPS) do
        local index = data[p.key] or -1
        if index == -1 then
            ClearPedProp(ped, p.id)
        else
            SetPedPropIndex(ped, p.id, index, data[p.key .. 'Texture'] or 0, true)
        end
    end

    for _, c in ipairs(COMPONENTS) do
        if data[c.key] ~= nil or not c.optional then
            SetPedComponentVariation(ped, c.id, data[c.key] or 0, data[c.key .. 'Texture'] or 0, 2)
        end
    end

    notify('Applied uniform: ' .. name, 'success')
end

---------------------------------------------------------------------------
-- Admin actions
---------------------------------------------------------------------------

local buildContexts 
local showDeleteMenu


local function runAction(callbackName, successMessage, returnId, ...)
    local res = lib.callback.await(callbackName, false, ...)

    if res and res.ok then
        outfits = res.outfits or {}
        buildContexts()
        notify(successMessage, 'success')
    else
        notify((res and res.error) or 'Request failed.', 'error')
    end

    lib.showContext(returnId)
end

local function createMenu()
    local input = lib.inputDialog('Create Menu', {
        { type = 'input', label = 'Menu Name', description = 'e.g. Police, Fire, EMS', required = true, max = 32 },
    })
    if not input then return lib.showContext(ROOT) end

    local name = trim(input[1])
    runAction('eup:createMenu', 'Menu created: ' .. name, ROOT, name)
end

local function createSubmenu(menuName)
    local returnId = deptId(menuName)
    local input = lib.inputDialog('Create Sub Menu', {
        { type = 'input', label = 'Sub Menu Name', description = 'New sub menu inside ' .. menuName, required = true, max = 32 },
    })
    if not input then return lib.showContext(returnId) end

    local name = trim(input[1])
    runAction('eup:createSubmenu', 'Sub menu created: ' .. name, returnId, menuName, name)
end

local function saveCurrentOutfit(menuName, subName, returnId)
    local input = lib.inputDialog('Save Current Outfit', {
        {
            type = 'input',
            label = 'Outfit Name',
            description = 'Saves what you are wearing to ' .. pathLabel(menuName, subName),
            required = true,
            max = 32,
        },
    })
    if not input then return lib.showContext(returnId) end

    local name = trim(input[1])
    if name == '' then
        notify('Outfit name cannot be empty.', 'error')
        return lib.showContext(returnId)
    end

    local existing = getUniforms(menuName, subName)
    if existing and existing[name] then
        local confirm = lib.alertDialog({
            header = 'Overwrite outfit?',
            content = ('"%s" already exists in %s. Overwrite it with your current outfit?'):format(name, pathLabel(menuName, subName)),
            centered = true,
            cancel = true,
        })
        if confirm ~= 'confirm' then return lib.showContext(returnId) end
    end

    runAction('eup:saveUniform', 'Saved outfit: ' .. name, returnId, menuName, subName or false, name, collectClothing())
end

local function setCategoryPermissions(menuName)
    local returnId = deptId(menuName)

    
    local jobOptions = {}
    for _, job in ipairs(Config.AvailableJobs or {}) do
        jobOptions[#jobOptions + 1] = {
            value = job.value,
            label = job.label
        }
    end

    
    local current = outfits[menuName] and outfits[menuName].permissions or {}
    local currentJobs = {}
    if current.jobs then
        for jobName, _ in pairs(current.jobs) do
            currentJobs[#currentJobs + 1] = jobName
        end
    end

    local input = lib.inputDialog('Set Permissions – ' .. menuName, {
        {
            type = 'multi-select',
            label = 'Allowed Jobs',
            description = 'Select which jobs can see this category. Leave empty = anyone with /eup access.',
            options = jobOptions,
            default = currentJobs,
            searchable = true,
            required = false,
        },
        {
            type = 'number',
            label = 'Minimum Grade',
            description = 'Minimum grade level required for the selected jobs (0 = all ranks)',
            default = Config.DefaultGrade or 0,
            min = 0,
            max = 20,
            required = true,
        },
        {
            type = 'checkbox',
            label = 'Require On Duty',
            description = 'Players must be clocked on duty',
            checked = current.requireOnDuty or false,
        },
    })

    if not input then
        return lib.showContext(returnId)
    end

    local selectedJobs = input[1] or {}
    local minGrade = tonumber(input[2]) or 0
    local requireOnDuty = input[3] == true

   
    local jobsTable = {}
    for _, jobName in ipairs(selectedJobs) do
        jobsTable[jobName] = minGrade
    end

    runAction('eup:setCategoryPerms',
        'Permissions updated for ' .. menuName,
        returnId,
        menuName,
        jobsTable,
        requireOnDuty
    )
end

showDeleteMenu = function(menuName, subName, returnId)
    local uniforms = getUniforms(menuName, subName)
    local options = {}

    for _, name in ipairs(sortedKeys(uniforms)) do
        options[#options + 1] = {
            title = name,
            description = 'Delete this outfit',
            icon = 'trash',
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Delete outfit?',
                    content = ('Delete "%s" from %s? This cannot be undone.'):format(name, pathLabel(menuName, subName)),
                    centered = true,
                    cancel = true,
                })
                if confirm == 'confirm' then
                    runAction('eup:deleteUniform', 'Deleted outfit: ' .. name, returnId, menuName, subName or false, name)
                else
                    showDeleteMenu(menuName, subName, returnId)
                end
            end,
        }
    end

    if #options == 0 then
        notify('There are no outfits to delete here.', 'error')
        return lib.showContext(returnId)
    end

    lib.registerContext({ id = DELETE, title = 'Delete Outfit', menu = returnId, options = options })
    lib.showContext(DELETE)
end



local function uniformOptions(uniforms, returnId)
    local options = {}

    for _, name in ipairs(sortedKeys(uniforms)) do
        local data = uniforms[name]
        options[#options + 1] = {
            title = name,
            description = 'Apply this uniform',
            icon = 'shirt',
            onSelect = function()
                applyUniform(name, data)
                lib.showContext(returnId)
            end,
        }
    end

    return options
end

local function adminOptions(menuName, subName, selfId)
    local options = {
        {
            title = 'Save Current Outfit',
            description = 'Save what you are wearing to ' .. pathLabel(menuName, subName),
            icon = 'floppy-disk',
            onSelect = function() saveCurrentOutfit(menuName, subName, selfId) end,
        },
    }

    
    if not subName then
        options[#options + 1] = {
            title = 'Set Permissions',
            description = 'Restrict this category to specific QBCore jobs / grades',
            icon = 'user-lock',
            onSelect = function() setCategoryPermissions(menuName) end,
        }

        options[#options + 1] = {
            title = 'Create Sub Menu',
            description = 'Add a sub menu inside ' .. menuName,
            icon = 'folder-plus',
            onSelect = function() createSubmenu(menuName) end,
        }
    end

    options[#options + 1] = {
        title = 'Delete Outfit',
        description = 'Remove a saved outfit from ' .. pathLabel(menuName, subName),
        icon = 'trash',
        onSelect = function() showDeleteMenu(menuName, subName, selfId) end,
    }

    return options
end

buildContexts = function()
    
    local rootOptions = {}

    if adminMode then
        rootOptions[#rootOptions + 1] = {
            title = 'Create Menu',
            description = 'Create a new menu (e.g. Police, Fire)',
            icon = 'folder-plus',
            onSelect = createMenu,
        }
    end

    for _, menuName in ipairs(sortedKeys(outfits)) do
        rootOptions[#rootOptions + 1] = {
            title = menuName,
            description = 'Open menu',
            icon = 'folder',
            arrow = true,
            onSelect = function() lib.showContext(deptId(menuName)) end,
        }
    end

    if #rootOptions == 0 or (adminMode and #rootOptions == 1) then
        rootOptions[#rootOptions + 1] = {
            title = 'No menus yet',
            description = adminMode and 'Use "Create Menu" above to add one' or 'An admin needs to set these up with /eupadmin',
            icon = 'circle-info',
            readOnly = true,
        }
    end

    lib.registerContext({ id = ROOT, title = 'EUP Menu', options = rootOptions })

    
    for menuName, menuData in pairs(outfits) do
        local id = deptId(menuName)
        local options = {}

        if adminMode then
            for _, opt in ipairs(adminOptions(menuName, nil, id)) do options[#options + 1] = opt end
        end

        for _, opt in ipairs(uniformOptions(menuData.uniforms, id)) do options[#options + 1] = opt end

        for _, subName in ipairs(sortedKeys(menuData.submenus)) do
            options[#options + 1] = {
                title = subName,
                description = 'Open sub menu',
                icon = 'folder-open',
                arrow = true,
                onSelect = function() lib.showContext(subId(menuName, subName)) end,
            }
        end

        if #options == 0 then
            options[#options + 1] = { title = 'Nothing saved yet', icon = 'circle-info', readOnly = true }
        end

        lib.registerContext({ id = id, title = menuName, menu = ROOT, options = options })

        for subName, subData in pairs(menuData.submenus or {}) do
            local sId = subId(menuName, subName)
            local subOptions = {}

            if adminMode then
                for _, opt in ipairs(adminOptions(menuName, subName, sId)) do subOptions[#subOptions + 1] = opt end
            end

            for _, opt in ipairs(uniformOptions(subData.uniforms, sId)) do subOptions[#subOptions + 1] = opt end

            if #subOptions == 0 then
                subOptions[#subOptions + 1] = { title = 'No uniforms saved', icon = 'circle-info', readOnly = true }
            end

            lib.registerContext({ id = sId, title = menuName .. ' / ' .. subName, menu = id, options = subOptions })
        end
    end
end



local function openMenu(admin)
    local res = lib.callback.await(admin and 'eup:openAdmin' or 'eup:open', false)

    if not res or not res.ok then
        notify((res and res.error) or 'Could not open the menu.', 'error')
        return
    end

    outfits = res.outfits or {}
    adminMode = admin
    buildContexts()
    lib.showContext(ROOT)
end

RegisterCommand('eup', function() openMenu(false) end, false)
RegisterCommand('eupadmin', function() openMenu(true) end, false)