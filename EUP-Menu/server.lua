-- Load outfits from json file
RegisterServerEvent('eup:loadOutfits')
AddEventHandler('eup:loadOutfits', function()
    local source = source
    local resourceName = GetCurrentResourceName()
    local fileName = 'outfits.json'
    local jsonData = LoadResourceFile(resourceName, fileName)
    if not jsonData then
        print('[EUP_Menu] No outfits.json found, initializing empty file')
        local success = SaveResourceFile(resourceName, fileName, json.encode({}, {indent = true}), -1)
        if success then
            print('[EUP_Menu] Initialized empty outfits.json')
        else
            print('[EUP_Menu] Failed to initialize outfits.json')
        end
        TriggerClientEvent('eup:receiveOutfits', source, {})
        return
    end
    local data = json.decode(jsonData)
    if not data then
        print('[EUP_Menu] Failed to decode outfits.json - returning empty')
        TriggerClientEvent('eup:receiveOutfits', source, {})
        return
    end
    print('[EUP_Menu] Loaded outfits.json successfully')
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
    else
        print('[EUP_Menu] Saved outfits.json successfully')
        TriggerClientEvent('eup:saveOutfitsResult', source, true)
    end
end)