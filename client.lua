-- EUP Menu Script
-- Client-side script for FiveM using RageUI and ox_lib
-- Commands:
--   /eup - Opens the main menu to apply saved uniforms
--   /eupadmin - Opens the admin menu to create menus, submenus, and save uniforms (admin-only)
-- Dependencies: RageUI (required), ox_lib (required)
-- Saves all menus, submenus, and uniforms in outfits.json (via server)
-- Uses ox_lib for notifications and input dialogs (text input)

-- Check if RageUI is loaded
if not RageUI then
    print('[EUP_Menu] ERROR: RageUI is not loaded! Ensure RageUI is included and loaded correctly.')
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            lib.notify({title = 'EUP Menu Error', description = 'RageUI is not loaded. Check resource setup.', type = 'error'})
        end
    end)
    return
end

-- Check if ox_lib is loaded
if not lib then
    print('[EUP_Menu] ERROR: ox_lib is not loaded! Ensure ox_lib is included and loaded correctly.')
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5000)
            lib.notify({title = 'EUP Menu Error', description = 'ox_lib is not loaded. Check resource setup.', type = 'error'})
        end
    end)
    return
end

-- Global variables
local mainMenu = nil
local adminMenu = nil
local menuOpen = false
local outfits = {}
local pendingCallbacks = {}

-- Function to show notification (using ox_lib)
local function ShowNotification(title, description, type)
   
    lib.notify({title = title, description = description, type = type})
end

-- Load outfits from server
local function LoadOutfits(callback)
    
    pendingCallbacks.load = callback
    TriggerServerEvent('eup:loadOutfits')
end

-- Save outfits to server
local function SaveOutfits(newOutfits, callback)
    
    outfits = newOutfits
    pendingCallbacks.save = callback
    TriggerServerEvent('eup:saveOutfits', outfits)
end

-- Collect current ped clothing data
local function CollectClothingData()
    local ped = PlayerPedId()
    return {
        hat = GetPedPropIndex(ped, 0),
        hatTexture = GetPedPropTextureIndex(ped, 0),
        glasses = GetPedPropIndex(ped, 1),
        glassesTexture = GetPedPropTextureIndex(ped, 1),
        ear = GetPedPropIndex(ped, 2),
        earTexture = GetPedPropTextureIndex(ped, 2),
        watch = GetPedPropIndex(ped, 6),
        watchTexture = GetPedPropTextureIndex(ped, 6),
        bracelet = GetPedPropIndex(ped, 7),
        braceletTexture = GetPedPropTextureIndex(ped, 7),
        mask = GetPedDrawableVariation(ped, 1),
        maskTexture = GetPedTextureVariation(ped, 1),
        torso = GetPedDrawableVariation(ped, 3),
        torsoTexture = GetPedTextureVariation(ped, 3),
        pants = GetPedDrawableVariation(ped, 4),
        pantsTexture = GetPedTextureVariation(ped, 4),
        shoes = GetPedDrawableVariation(ped, 6),
        shoesTexture = GetPedTextureVariation(ped, 6),
        accessory = GetPedDrawableVariation(ped, 7),
        accessoryTexture = GetPedTextureVariation(ped, 7),
        bag = GetPedDrawableVariation(ped, 5),
        bagTexture = GetPedTextureVariation(ped, 5),
        vest = GetPedDrawableVariation(ped, 9),
        vestTexture = GetPedTextureVariation(ped, 9),
        decal = GetPedDrawableVariation(ped, 10),
        decalTexture = GetPedTextureVariation(ped, 10),
        shirt = GetPedDrawableVariation(ped, 8),
        shirtTexture = GetPedTextureVariation(ped, 8)
    }
end

-- Close all menus
local function CloseAllMenus()
    
    if mainMenu then
        RageUI.CloseAll()
        RageUI.Visible(mainMenu, false)
    end
    if adminMenu then
        RageUI.Visible(adminMenu, false)
    end
    menuOpen = false
end

-- Open main menu (/eup)
local function OpenMainMenu()
    
    CloseAllMenus()

    if not mainMenu then
        
        mainMenu = RageUI.CreateMenu("EUP Menu", "Apply saved uniforms")
        mainMenu.Closed = function()
           
            CloseAllMenus()
        end
    end

    LoadOutfits(function(loadedOutfits)
        
        menuOpen = true
        RageUI.Visible(mainMenu, true)

        Citizen.CreateThread(function()
            while menuOpen do
                Citizen.Wait(0)
                if not RageUI.Visible(mainMenu) and not menuOpen then
                    
                    menuOpen = false
                    break
                end

                RageUI.IsVisible(mainMenu, function()
                    
                    for menuName, menuData in pairs(outfits) do
                        RageUI.Button(menuName, "Open menu", {}, true, {
                            onSelected = function()
                                
                                local submenu = RageUI.CreateSubMenu(mainMenu, menuName, "Submenus and Uniforms")
                                submenu.Closed = function()
                                   
                                    RageUI.Visible(submenu, false)
                                    RageUI.Visible(mainMenu, true)
                                end

                                RageUI.Visible(mainMenu, false)
                                RageUI.Visible(submenu, true)

                                Citizen.CreateThread(function()
                                    while RageUI.Visible(submenu) do
                                        Citizen.Wait(0)
                                        RageUI.IsVisible(submenu, function()
                                            
                                            if menuData.uniforms then
                                                for uniformName, uniformData in pairs(menuData.uniforms) do
                                                    RageUI.Button("Apply: " .. uniformName, "Apply this uniform", {}, true, {
                                                        onSelected = function()
                                                            
                                                            local ped = PlayerPedId()
                                                            SetPedPropIndex(ped, 0, uniformData.hat or -1, uniformData.hatTexture or 0, true)
                                                            SetPedPropIndex(ped, 1, uniformData.glasses or -1, uniformData.glassesTexture or 0, true)
                                                            SetPedPropIndex(ped, 2, uniformData.ear or -1, uniformData.earTexture or 0, true)
                                                            SetPedPropIndex(ped, 6, uniformData.watch or -1, uniformData.watchTexture or 0, true)
                                                            SetPedPropIndex(ped, 7, uniformData.bracelet or -1, uniformData.braceletTexture or 0, true)
                                                            SetPedComponentVariation(ped, 1, uniformData.mask or 0, uniformData.maskTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 3, uniformData.torso or 0, uniformData.torsoTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 4, uniformData.pants or 0, uniformData.pantsTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 6, uniformData.shoes or 0, uniformData.shoesTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 7, uniformData.accessory or 0, uniformData.accessoryTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 5, uniformData.bag or 0, uniformData.bagTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 9, uniformData.vest or 0, uniformData.vestTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 10, uniformData.decal or 0, uniformData.decalTexture or 0, 2)
                                                            SetPedComponentVariation(ped, 8, uniformData.shirt or 0, uniformData.shirtTexture or 0, 2)
                                                            ShowNotification('EUP Menu', 'Applied uniform: ' .. uniformName, 'success')
                                                        end
                                                    })
                                                end
                                            end

                                            for submenuName, submenuData in pairs(menuData.submenus) do
                                                RageUI.Button(submenuName, "Open sub menu", {}, true, {
                                                    onSelected = function()
                                                        
                                                        local subsubmenu = RageUI.CreateSubMenu(submenu, submenuName, "Uniforms")
                                                        subsubmenu.Closed = function()
                                                            
                                                            RageUI.Visible(subsubmenu, false)
                                                            RageUI.Visible(submenu, true)
                                                        end

                                                        RageUI.Visible(submenu, false)
                                                        RageUI.Visible(subsubmenu, true)

                                                        Citizen.CreateThread(function()
                                                            while RageUI.Visible(subsubmenu) do
                                                                Citizen.Wait(0)
                                                                RageUI.IsVisible(subsubmenu, function()
                                                                   
                                                                    if submenuData.uniforms then
                                                                        for uniformName, uniformData in pairs(submenuData.uniforms) do
                                                                            RageUI.Button("Apply: " .. uniformName, "Apply this uniform", {}, true, {
                                                                                onSelected = function()
                                                                                    
                                                                                    local ped = PlayerPedId()
                                                                                    SetPedPropIndex(ped, 0, uniformData.hat or -1, uniformData.hatTexture or 0, true)
                                                                                    SetPedPropIndex(ped, 1, uniformData.glasses or -1, uniformData.glassesTexture or 0, true)
                                                                                    SetPedPropIndex(ped, 2, uniformData.ear or -1, uniformData.earTexture or 0, true)
                                                                                    SetPedPropIndex(ped, 6, uniformData.watch or -1, uniformData.watchTexture or 0, true)
                                                                                    SetPedPropIndex(ped, 7, uniformData.bracelet or -1, uniformData.braceletTexture or 0, true)
                                                                                    SetPedComponentVariation(ped, 1, uniformData.mask or 0, uniformData.maskTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 3, uniformData.torso or 0, uniformData.torsoTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 4, uniformData.pants or 0, uniformData.pantsTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 6, uniformData.shoes or 0, uniformData.shoesTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 7, uniformData.accessory or 0, uniformData.accessoryTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 5, uniformData.bag or 0, uniformData.bagTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 9, uniformData.vest or 0, uniformData.vestTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 10, uniformData.decal or 0, uniformData.decalTexture or 0, 2)
                                                                                    SetPedComponentVariation(ped, 8, uniformData.shirt or 0, uniformData.shirtTexture or 0, 2)
                                                                                    ShowNotification('EUP Menu', 'Applied uniform: ' .. uniformName, 'success')
                                                                                end
                                                                            })
                                                                        end
                                                                    else
                                                                        RageUI.Button("No uniforms saved", "Save uniforms using /eupadmin", {}, false, {})
                                                                    end
                                                                end)
                                                            end
                                                        end)
                                                    end
                                                })
                                            end
                                        end)
                                    end
                                end)
                            end
                        })
                    end
                end)
            end
        end)
    end)
end

-- Open admin menu (/eupadmin)
local function OpenAdminMenu()
    
    CloseAllMenus()

    if not adminMenu then
        
        adminMenu = RageUI.CreateMenu("EUP Admin Menu", "Manage menus and uniforms")
        adminMenu.Closed = function()
            
            CloseAllMenus()
        end
    end

    LoadOutfits(function(loadedOutfits)
        
        menuOpen = true
        RageUI.Visible(adminMenu, true)

        Citizen.CreateThread(function()
            while menuOpen do
                Citizen.Wait(0)
                if not RageUI.Visible(adminMenu) and not menuOpen then
                    
                    menuOpen = false
                    break
                end

                RageUI.IsVisible(adminMenu, function()
                    
                    -- Create a Menu Button
                    RageUI.Button("Create a Menu", "Create a new menu to organize uniforms", {}, true, {
                        onSelected = function()
                            
                            local input = lib.inputDialog('Create Menu', {
                                {type = 'input', label = 'Menu Name', description = 'Enter the name for the new menu', required = true}
                            })
                            if input then
                                local menuName = input[1]
                                if not outfits[menuName] then
                                    outfits[menuName] = { submenus = {} }
                                    SaveOutfits(outfits, function(success)
                                        if success then
                                            ShowNotification('EUP Menu', 'Menu created: ' .. menuName, 'success')
                                        else
                                            ShowNotification('EUP Menu', 'Failed to save menu: ' .. menuName, 'error')
                                            
                                        end
                                    end)
                                else
                                    ShowNotification('EUP Menu', 'Menu already exists', 'error')
                                    
                                end
                            else
                                
                            end
                        end
                    })

                    -- Create Sub Menu Button
                    RageUI.Button("Create Sub Menu", "Create a new sub menu in an existing menu", {}, true, {
                        onSelected = function()
                            
                            local input = lib.inputDialog('Create Sub Menu', {
                                {type = 'input', label = 'Menu Name', description = 'Enter the name of the existing menu', required = true},
                                {type = 'input', label = 'Sub Menu Name', description = 'Enter the name for the new sub menu', required = true}
                            })
                            if input then
                                local menuName = input[1]
                                local submenuName = input[2]
                                if outfits[menuName] then
                                    if not outfits[menuName].submenus[submenuName] then
                                        outfits[menuName].submenus[submenuName] = { uniforms = {} }
                                        SaveOutfits(outfits, function(success)
                                            if success then
                                                ShowNotification('EUP Menu', 'Sub menu created: ' .. submenuName, 'success')
                                            else
                                                ShowNotification('EUP Menu', 'Failed to save sub menu: ' .. submenuName, 'error')
                                                
                                            end
                                        end)
                                    else
                                        ShowNotification('EUP Menu', 'Sub menu already exists', 'error')
                                       
                                    end
                                else
                                    ShowNotification('EUP Menu', 'Menu does not exist', 'error')
                                    
                                end
                            else
                                
                            end
                        end
                    })

                    -- Add Uniform Button
                    RageUI.Button("Add Uniform", "Save the current clothing to a submenu", {}, true, {
                        onSelected = function()
                            
                            local ped = PlayerPedId()
                            local clothingData = CollectClothingData()
                            local input = lib.inputDialog('Add Uniform', {
                                {type = 'input', label = 'Uniform Name', description = 'Enter the name for this uniform', required = true},
                                {type = 'input', label = 'Submenu Path', description = 'Enter Menu/Submenu (e.g., Police/Patrol)', required = true}
                            })
                            if input then
                                local uniformName = input[1]
                                local submenuPath = input[2]
                               

                                -- Parse submenu path (e.g., "Police/Patrol" or "Patrol")
                                local menuName, submenuName = submenuPath:match("([^/]+)/(.+)")
                                if not menuName then
                                    submenuName = submenuPath
                                    for mName, mData in pairs(outfits) do
                                        if mData.submenus[submenuName] then
                                            menuName = mName
                                            break
                                        end
                                    end
                                end

                                if menuName and submenuName and outfits[menuName] and outfits[menuName].submenus[submenuName] then
                                    
                                    if not outfits[menuName].submenus[submenuName].uniforms then
                                        outfits[menuName].submenus[submenuName].uniforms = {}
                                    end
                                    outfits[menuName].submenus[submenuName].uniforms[uniformName] = clothingData
                                    SaveOutfits(outfits, function(success)
                                        if success then
                                            ShowNotification('EUP Menu', 'Uniform saved: ' .. uniformName .. ' to ' .. menuName .. '/' .. submenuName, 'success')
                                        else
                                            ShowNotification('EUP Menu', 'Failed to save uniform: ' .. uniformName, 'error')
                                            
                                        end
                                    end)
                                else
                                    ShowNotification('EUP Menu', 'Invalid menu/submenu: ' .. submenuPath, 'error')
                                    
                                end
                            else
                                
                            end
                        end
                    })
                end)
            end
        end)
    end)
end

-- Register receive events
RegisterNetEvent('eup:receiveOutfits')
AddEventHandler('eup:receiveOutfits', function(data)
   
    outfits = data or {}
    if pendingCallbacks.load then
        pendingCallbacks.load(outfits)
        pendingCallbacks.load = nil
    end
end)

RegisterNetEvent('eup:saveOutfitsResult')
AddEventHandler('eup:saveOutfitsResult', function(success)
    
    if pendingCallbacks.save then
        pendingCallbacks.save(success)
        pendingCallbacks.save = nil
    end
end)

RegisterNetEvent('eup:openAdminMenuResult')
AddEventHandler('eup:openAdminMenuResult', function(hasPermission)
    if hasPermission then
        
        OpenAdminMenu()
    else
        
        lib.notify({title = 'EUP Menu', description = 'You do not have permission to use /eupadmin.', type = 'error'})
    end
end)

RegisterNetEvent('eup:openEupMenuResult')
AddEventHandler('eup:openEupMenuResult', function(hasPermission)
    if hasPermission then
        
        OpenMainMenu()
    else
        
        lib.notify({title = 'EUP Menu', description = 'You do not have permission to use /eup.', type = 'error'})
    end
end)

-- Register commands
RegisterCommand('eup', function()
    
    TriggerServerEvent('eup:checkEupPermission')
end, false)

RegisterCommand('eupadmin', function()
    
    TriggerServerEvent('eup:checkAdminPermission')
end, false)

-- Key handler for Backspace and ESC
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if menuOpen then
            if IsControlJustPressed(0, 200) then -- ESC key
                
                CloseAllMenus()
            elseif IsControlJustPressed(0, 177) then -- Backspace key
                
                local currentMenu = RageUI.CurrentMenu
                if currentMenu then
                    if currentMenu == mainMenu or currentMenu == adminMenu then
                        
                        CloseAllMenus()
                    elseif currentMenu.Parent and (currentMenu.Parent == mainMenu or currentMenu.Parent == adminMenu) then
                        
                        RageUI.Visible(currentMenu, false)
                        RageUI.Visible(currentMenu.Parent, true)
                    elseif currentMenu.Parent then
                        
                        RageUI.Visible(currentMenu, false)
                        RageUI.Visible(currentMenu.Parent, true)
                    end
                else
                    
                    CloseAllMenus()
                end
            end
        end
    end
end)