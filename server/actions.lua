local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local function logprint(key)
    if Config.Debug then print(locale('print_sv_debug'), locale('print_sv_actions'), key) end
end

-- Mark telegrams as read
RSGCore.Functions.CreateCallback('rsg-multicharacter:server:markTelegramsAsRead', function(source, cb, recipientName)
    MySQL.Async.execute('UPDATE telegrams SET status = 1 WHERE recipient = ? AND status = 0', { recipientName }, function() cb(true) end)
end)


-- Get player skin
RSGCore.Functions.CreateCallback('rsg-multicharacter:server:getPlayerSkin', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local skins = MySQL.Sync.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', {cid})
    cb(skins[1])
end)

-- Get player outfits
RegisterNUICallback('selectOutfit', function(data, cb)
    -- UNDRESS PLAYER
    -- local src = source
    -- local Player = RSGCore.Functions.GetPlayer(src)
    -- local jailed = Player.PlayerData.metadata['injail']

    -- if jailed > 0 then return end
    -- TriggerClientEvent('rsg-wardrobe:client:removeAllClothing', src)

    cb('ok')
end)

-- Mark outfit as change
RSGCore.Functions.CreateCallback('rsg-multicharacter:server:selectOutfitAsCange', function(source, cb, recipientName)
end)