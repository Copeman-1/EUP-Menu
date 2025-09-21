-- server.lua
local savedOutfits = {} -- In-memory cache for outfits

-- Load saved outfits from JSON file on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local file = LoadResourceFile(GetCurrentResourceName(), "saved_outfits.json")
    if file then
        savedOutfits = json.decode(file)
        if not savedOutfits then savedOutfits = {} end -- Ensure empty table if decode fails
    else
        savedOutfits = {}
        SaveResourceFile(GetCurrentResourceName(), "saved_outfits.json", json.encode(savedOutfits), -1) -- Create empty file
    end
end)

-- Existing geteup event
RegisterNetEvent("geteup")
AddEventHandler("geteup", function(props, components)
    print(props .. "\n" .. components) -- Keep your existing print
end)

-- Client requests saved outfits (on menu open or resource start)
RegisterNetEvent("getSavedOutfits")
AddEventHandler("getSavedOutfits", function()
    TriggerClientEvent("receiveSavedOutfits", source, savedOutfits)
end)

-- Save new outfit from client
RegisterNetEvent("saveeup")
AddEventHandler("saveeup", function(department, subMenu, buttonName, props, components)
    if not savedOutfits[department] then
        savedOutfits[department] = {}
    end
    if not savedOutfits[department][subMenu] then
        savedOutfits[department][subMenu] = {}
    end
    table.insert(savedOutfits[department][subMenu], {
        button = buttonName,
        props = load(props)(), -- Convert string to table (props is like "return {...}")
        components = load(components)() -- Convert string to table
    })
    
    -- Save to JSON file
    SaveResourceFile(GetCurrentResourceName(), "saved_outfits.json", json.encode(savedOutfits), -1)
    
    -- Notify all clients to refresh menus
    TriggerClientEvent("refreshEUPMenu", -1)
end)
