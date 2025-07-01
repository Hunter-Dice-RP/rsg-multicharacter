local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- HELPERS
-- To generate sex
local function GenerateSex()
    local type = {'male', 'female'}
    local randomSex = math.random(1, #type)
    local sex = type[randomSex]
    return sex
end

-- To generate breedable status
local function GenerateBreed()
    local breedable = {"Yes", "No"}
    local randomIndex1 = math.random(1, #breedable)
    return breedable[randomIndex1]
end

-- To generate unique identifiers true = horses, false = companions
local function Generateid(bool)
    local UniqueFound = false
    local id = nil
    while not UniqueFound do
        if bool then
            id = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
            local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM player_horses WHERE horseid = ?', { id })
            if result == 0 then
                UniqueFound = true
            end
        else
            id = tostring(RSGCore.Shared.RandomStr(3) .. RSGCore.Shared.RandomInt(3)):upper()
            local result = MySQL.prepare.await('SELECT COUNT(*) as count FROM player_companions WHERE companionid = ?', { id })
            if result == 0 then
                UniqueFound = true
            end
        end
    end
    return id
end

-- To generate names true = horses, false = companions
local function GenerateName(bool)
    local newname = nil
    if bool then
        newname = {locale('Vaquero'), locale('Redención'), locale('Relámpago'), locale('Centella'), locale('Tormenta'), locale('Valiente'), locale('Zafiro'), locale('Sombra'), locale('Lucero'), locale('Fénix'), locale('Copérnico'), locale('Alazán'), locale('Sabanero')}
    else
        newname = {locale('Bandido'), locale('Tequila'), locale('Coyote'), locale('Rayo'), locale('Gringo'), locale('Sierra'), locale('Bronco'), locale('Chispa')}
    end
    local random = math.random(1, #newname)
    local name = newname[random]
    return name
end

-- INIT START GIVE NEWPLAYER
-- This event is used to give starter items to the player when they create a new character
RegisterNetEvent('rsg-multicharacter:server:giveStarterItems', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)

    for k, v in pairs(RSGCore.Shared.StarterItems) do
        Player.Functions.AddItem(v.item, v.amount)
    end

    if Config.StarterHorse then
        MySQL.insert('INSERT INTO player_horses(stable, citizenid, horseid, name, horse, gender, active, born, breedable, inBreed) VALUES(@stable, @citizenid, @horseid, @name, @horse, @gender, @active, @born, @breedable, @inBreed)', {
            ['@stable'] = Config.StarterHorseStable,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@horseid'] = Generateid(true),
            ['@name'] = GenerateName(true),
            ['@horse'] = Config.StarterHorseModel,
            ['@gender'] = GenerateSex(),
            ['@active'] = true,
            ['@born'] = os.time(),
            ['@breedable'] = GenerateBreed(),
            ['@inBreed'] = "No"
        })
    end

    if Config.StarterCompanion then
        local companionid = Generateid(false)
        local skin = math.floor(math.random(0, 2))
        local datacomp = {
            -- information
            id = companionid,
            name = GenerateName(false),
            companion = Config.StarterCompanionModel or nil,
            skin = skin or 0,
            gender = GenerateSex(),
            -- atributes
            hunger = math.random(50, 100),
            thirst = math.random(50, 100),
            happiness = math.random(50, 100),
            dirt = 100.0,
            age = math.random(1, 5),
            scale = math.random(5, 10)/10,
            companionxp = 0.0,
            dead = false,
            born = os.time()
        }

        local animaldata = json.encode(datacomp)
        MySQL.insert('INSERT INTO player_companions(stable, citizenid, companionid, companiondata, active, breedable, inBreed) VALUES(@stable, @citizenid, @companionid, @companiondata, @active, @breedable, @inBreed)', {
            ['@stable'] = Config.StarterCompanionStable,
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@companionid'] = companionid,
            ['@companiondata'] = animaldata,
            ['@active'] = true,
            ['@breedable'] = GenerateBreed(),
            ['@inBreed'] = "No"
        })
    end
end)