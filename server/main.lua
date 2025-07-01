local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- local identifierUsed = GetConvar('es_identifierUsed', 'steam')
-- local foundResources = {}

local function logprint(key)
    if Config.Debug then print(locale('print_sv_debug'), key) end
end

-- Events
-- To disconnect
RegisterNetEvent('rsg-multicharacter:server:disconnect', function(source)
    DropPlayer(source, locale('print_sv_disconnect'))
end)

-- To load data when they join the server
RegisterNetEvent('rsg-multicharacter:server:loadUserData', function(cData, skindata)
    local src = source
    if RSGCore.Player.Login(src, cData.citizenid) then
        logprint(GetPlayerName(src)..' ('..locale('print_sv_id')..': '..cData.citizenid..') '..locale('print_sv_loaded'))
        RSGCore.Commands.Refresh(src)
        TriggerClientEvent("rsg-multicharacter:client:closeNUI", src)
        if not skindata then
            TriggerClientEvent('rsg-spawn:client:setupSpawnUI', src, cData, false)
        else
            TriggerClientEvent('rsg-appearance:client:OpenCreator', src, false, true)
        end
        TriggerEvent('rsg-log:server:CreateLog', 'joinleave', locale('sv_joined'), 'green', '**' .. GetPlayerName(src) .. '** '..locale('sv_joined_log'))
    end
end)

-- Give starter items to the player when they create a new character
RegisterNetEvent('rsg-multicharacter:server:createCharacter', function(data)
    local newData = {}
    local src = source
    newData.cid = data.cid
    newData.charinfo = data
    if RSGCore.Player.Login(src, false, newData) then
        RSGCore.ShowSuccess(GetCurrentResourceName(), GetPlayerName(src)..' '.. locale('sv_loaded'))
        RSGCore.Commands.Refresh(src)
        TriggerEvent("rsg-multicharacter:server:giveStarterItems", src)
    end
end)

-- Delete the character from the database
RegisterNetEvent('rsg-multicharacter:server:deleteCharacter', function(citizenid)
    MySQL.update('DELETE FROM playerskins WHERE citizenid = ?', {citizenid})
    RSGCore.Player.DeleteCharacter(source, citizenid)
end)

-- Callbacks
-- To setup the characters for the player
RSGCore.Functions.CreateCallback("rsg-multicharacter:server:setupCharacters", function(source, cb)
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    MySQL.Async.fetchAll('SELECT * FROM players WHERE license = @license', {['@license'] = license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            -- result[i].metadata = json.decode(result[i].metadata)
            plyChars[#plyChars+1] = result[i]
        end
        cb(plyChars)
    end)
end)

-- To get the number of characters a player can create
RSGCore.Functions.CreateCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(source, cb)
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
    local numOfChars = 0
    if next(Config.PlayersNumberOfCharacters) then
        for i, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = Config.DefaultNumberOfCharacters
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    cb(numOfChars)
end)

-- To get the appearance of a character by citizenid
RSGCore.Functions.CreateCallback("rsg-multicharacter:server:getAppearance", function(source, cb, citizenid)
    MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ?', {citizenid}, function(result)
        if result ~= nil and #result > 0 then
            local skinData = json.decode(result[1].skin)
            local clothesData = json.decode(result[1].clothes)
            result[1].skin = skinData
            result[1].clothes = clothesData
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

-- Commands
-- To create a new character
RSGCore.Commands.Add("logout", locale('sv_logout'), {}, false, function(source)
    RSGCore.Player.Logout(source)
    TriggerClientEvent('rsg-multicharacter:client:chooseChar', source)
end, 'admin')

-- To close the NUI
RSGCore.Commands.Add("closeNUI", locale('sv_closeNUI'), {}, false, function(source)
    TriggerClientEvent('rsg-multicharacter:client:closeNUI', source)
end, 'user')