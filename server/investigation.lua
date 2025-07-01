local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local function logprint(key)
    if Config.Debug then print(locale('print_sv_debug'), locale('print_sv_inv'), key) end
end

-- Safe JSON decode, returns fallback on error or non-table
local function SafeDecode(jsonString, fallback)
    local ok, result = pcall(function() return json.decode(jsonString or '') end)
    if ok and type(result) == 'table' then return result end
    return fallback or {}
end

-- Safe MySQL query await, catches errors and logs them
local function SafeQueryAwait(query, params)
    local result
    local ok, err = xpcall(function()
        result = MySQL.query.await(query, params)
    end, function(e)
        logprint(locale('print_sv_error')..' '..e)
        logprint(debug.traceback())
    end)
    return result or {}
end

-- HELPERS 
-- To Fetch a citizenid
local function FetchTelegrams(citizenid)
    local telegrams = SafeQueryAwait("SELECT * FROM telegrams WHERE citizenid = ?", { citizenid })
    for i = #telegrams, 1, -1 do
        if not telegrams[i].sender or not telegrams[i].receiver then
            table.remove(telegrams, i)
        end
    end
    return telegrams
end

local function FetchSkins(citizenid)
    local rows = SafeQueryAwait("SELECT * FROM playerskins WHERE citizenid = ?", { citizenid }) or {}
    local out = {}
    for _, v in ipairs(rows) do
        table.insert(out, {
            id      = v.id,
            skin    = SafeDecode(v.skin, {}),
            clothes = SafeDecode(v.clothes, {})
        })
    end
    return out
end

local function FetchOutfits(citizenid)
    local rows = SafeQueryAwait("SELECT * FROM playeroutfit WHERE citizenid = ?", { citizenid }) or {}
    local out = {}
    for _, v in ipairs(rows) do
        table.insert(out, {
            id      = v.id,
            name    = v.name,
            clothes = SafeDecode(v.clothes, {})
        })
    end
    return out
end

local function FetchHorses(citizenid)
    local query = "SELECT * FROM player_horses WHERE citizenid = ? ORDER BY `horsexp` DESC LIMIT 5"
    local horses = SafeQueryAwait(query, { citizenid }) or {}
    local out = {}
    for _, horse in ipairs(horses) do
        table.insert(out, {
            name = horse.name,
            horsexp = horse.horsexp or 0,
            stable = horse.stable,
            gender = horse.gender,
            model = horse.model,
            components = SafeDecode(horse.components, {})
        })
    end
    return out
end

local function FetchCompanions(citizenid)
    local companions = SafeQueryAwait("SELECT * FROM player_companions WHERE citizenid = ?", { citizenid }) or {}
    local out = {}
    for _, companion in ipairs(companions) do
        table.insert(out, {
            name = companion.companiondata.name,
            companionxp = companion.companiondata.companionxp or 0,
            stable = companion.stable,
            gender = companion.companiondata.gender or 0,
            companiondata = SafeDecode(companion.companiondata, {}),
            components = SafeDecode(companion.components, {})
        })
    end
    return out
end

local function FetchAnimations(citizenid)
    local resultAnim = nil
    if Config.Investigation.dossier.sqlAnimations == 'wd_emotemenu' then
        resultAnim = SafeQueryAwait("SELECT * FROM emenu_styles WHERE character_id = ?", { citizenid })
    else -- if Config.Investigation.dossier.sqlAnimations == 'rsg-animations' then
        resultAnim = SafeQueryAwait("SELECT * FROM favorites_animations WHERE citizenid = ?", { citizenid })
    end
    local out = {}
    for _, v in ipairs(resultAnim) do
        table.insert(out, v)
    end
    return out
end

local function FetchHousesAndKeys(citizenid)
    local houses = SafeQueryAwait("SELECT * FROM rex_houses WHERE citizenid = ?", { citizenid }) or {}
    local outhouses = {}
    for _, v in ipairs(houses) do
        table.insert(outhouses, v)
    end
    local keys = SafeQueryAwait("SELECT * FROM rex_housekeys WHERE citizenid = ?", { citizenid }) or {}
    local outkeys = {}
    for _, v in ipairs(keys) do
        table.insert(outkeys, v)
    end
    return outhouses, outkeys
end

--[[ local function FetchLegalStatus(citizenid)
    local result = MySQL.single.await("SELECT * FROM player_legal WHERE citizenid = ?", { citizenid })
    if not result then return {} end
    return {
        arrests = result and result.arrests or 0,
        warrants = result and result.warrants or 0,
        fines = result and result.fines or 0.0,
        isWanted = result and result.isWanted or false,
    }
end 

local function describeArrests(data)
    local arrests = data.legal.arrests or 0
    if data.legal.isWanted then
        return "Sujeto actualmente en busca y captura. Considerado peligroso.\nExpedientes: " .. arrests .. " arrestos"
    elseif data.metadata.criminalrecord and data.metadata.criminalrecord.hasRecord then
        return "Tiene antecedentes penales. Se recomienda precaución\nExpedientes: " .. arrests .. " arrestos"
    elseif arrests > 0 then
        return "Expedientes: " .. arrests .. " arrestos, aunque no está buscado actualmente."
    else
        return "No presenta antecedentes ni alertas"
    end
end ]]

-- Define the biography sections with their respective locales
local bioSections = {
    intro = {
        locale('inv_sv_bio_intro_a'),
        locale('inv_sv_bio_intro_b'),
        locale('inv_sv_bio_intro_c'),
        locale('inv_sv_bio_intro_d'),
        locale('inv_sv_bio_intro_e'),
    },
    background = {
        locale('inv_sv_bio_background_a'),
        locale('inv_sv_bio_background_b'),
        locale('inv_sv_bio_background_c'),
        locale('inv_sv_bio_background_d'),
        locale('inv_sv_bio_background_e'),
    },
    assets = {
        function(ctx)
            return ctx.houses > 0
                and (locale('inv_sv_bio_assets_houses_a')):format(ctx.houses)
                or locale('inv_sv_bio_assets_nohouses_a')
        end,
        function(ctx)
            return ctx.houses > 0
                and (locale('inv_sv_bio_assets_houses_b')):format(ctx.houses)
                or locale('inv_sv_bio_assets_nohouses_b')
        end,
        function(ctx)
            return ctx.outfits > 0
                and (locale('inv_sv_bio_assets_outfits_a')):format(ctx.outfits)
                or locale('inv_sv_bio_assets_outfits_a')
        end,
        function(ctx)
            return ctx.outfits > 0
                and (locale('inv_sv_bio_assets_outfits_b')):format(ctx.outfits)
                or locale('inv_sv_bio_assets_outfits_b')
        end
    },
    horses = {
        function(ctx)
            return ctx.horses > 0
                and (locale('inv_sv_bio_horses_a')):format(ctx.horses)
                or locale('inv_sv_bio_nohorses_a')
        end,
        function(ctx)
            return ctx.horses > 0
                and (locale('inv_sv_bio_horses_b')):format(ctx.horses)
                or locale('inv_sv_bio_nohorses_b')
        end
    },
    companions = {
        function(ctx)
            return ctx.companions > 0
                and (locale('inv_sv_bio_companions_a')):format(ctx.companions)
                or locale('inv_sv_bio_nocompanions_a')
        end
    },
    behavior = {
        function(ctx)
            return (locale('inv_sv_bio_behavior_walk_a')):format(ctx.walk)
        end,
        function(ctx)
            return (locale('inv_sv_bio_behavior_walk_b')):format(ctx.walk)
        end,
        function(ctx)
            return (locale('inv_sv_bio_behavior_brawl_a')):format(ctx.brawl)
        end,
        function(ctx)
            return (locale('inv_sv_bio_behavior_brawl_b')):format(ctx.brawl)
        end
    },
    outro = {
        locale('inv_sv_bio_outro_a'),
        locale('inv_sv_bio_outro_b'),
        locale('inv_sv_bio_outro_c'),
        locale('inv_sv_bio_outro_d'),
        locale('inv_sv_bio_outro_e'),
    },
    legal = {
        function(ctx)
            return ctx.isWanted and locale('inv_sv_bio_legal_wanted_a')
        end,
        function(ctx)
            return ctx.isWanted and locale('inv_sv_bio_legal_wanted_b')
        end,
        function(ctx)
            return ctx.isWanted and locale('inv_sv_bio_legal_wanted_c')
        end,
        -- function(ctx)
        --     return ctx.arrests > 0
        --         and ("Con %d arrestos a cuestas, su sombra es más larga que su nombre."):format(ctx.arrests)
        --         or "Sin grilletes marcados… por ahora."
        -- end
    }
}

local function AddFlavorInterludes()
    local interludes = {
        locale('inv_sv_bio_interludes_a'),
        locale('inv_sv_bio_interludes_b'),
        locale('inv_sv_bio_interludes_c'),
        locale('inv_sv_bio_interludes_d'),
    }
    return interludes[math.random(#interludes)]
end

--[[ local narrativeStyles = {
    ["epic"] = function() return math.random(1, 3) end,
    ["comic"] = function() return math.random(2, 4) end,
    ["dark"] = function() return math.random(3, 5) end,
    ["myst"] = function() return math.random(1, 5) end,
    ["drama"] = function() return 1 end
} ]]

-- Generate a brief biography based on collected data
local function BuildBiography(data)
    -- PREPARE INFO DATA PLAYER
    local lines = {}
    local ctx = {
        firstname  = data.stats.charinfo.firstname or locale('inv_sv_bio_ctx_a'),
        lastname   = data.stats.charinfo.lastname  or locale('inv_sv_bio_ctx_b'),
        blood      = data.metadata.bloodtype or locale('inv_sv_bio_ctx_c'),
        guild      = data.stats.job.label or locale('inv_sv_bio_ctx_d'),
        gang       = data.stats.gang.label or locale('inv_sv_bio_ctx_e'),
        houses     = #data.houses,
        outfits    = #data.outfits,
        horses     = #data.horses,
        companions = #data.companions,
        walk       = data.animations[1] and (data.animations[1].walk_style or locale('inv_sv_bio_ctx_f')) or locale('inv_sv_bio_ctx_f'),
        brawl      = data.animations[1] and (data.animations[1].brawl_style or locale('inv_sv_bio_ctx_g')) or locale('inv_sv_bio_ctx_g'),
        -- arrests    = data.legal.arrests,
        isWanted   = data.legal.isWanted
    }

    -- test narrative styles
    -- local idx = narrativeStyles["épico"] and narrativeStyles["épico"]() or math.random(1, #bioSections.intro)
    -- local intro = bioSections.intro[idx]

    -- Intro
    local intro = bioSections.intro[math.random(#bioSections.intro)]
    table.insert(lines, intro:format(ctx.firstname, ctx.lastname))

    -- Background
    local bg = bioSections.background[math.random(#bioSections.background)]
    table.insert(lines, bg:format(ctx.blood, ctx.guild, ctx.gang))

    -- Assets
    local assetT = bioSections.assets[math.random(#bioSections.assets)]
    table.insert(lines, assetT(ctx))

    -- Companions
    local compT = bioSections.companions[math.random(#bioSections.companions)]
    table.insert(lines, compT(ctx))

    -- Behavior
    local behT = bioSections.behavior[math.random(#bioSections.behavior)]
    table.insert(lines, behT(ctx))

    -- Legal
    for _, fn in ipairs(bioSections.legal) do
        local txt = fn(ctx)
        if txt ~= "" then table.insert(lines, txt) end
    end

    -- Interludes
    if #lines >= 2 then
        table.insert(lines, math.random(2, #lines), AddFlavorInterludes())
    else
        table.insert(lines, AddFlavorInterludes())
    end

    -- Outro
    local outro = bioSections.outro[math.random(#bioSections.outro)]
    if outro:find("%%s") then
        outro = outro:format(ctx.firstname, ctx.lastname)
    end
    table.insert(lines, outro)

    if #lines > 0 then
        local bioString = table.concat(lines, " ")
        data.bio = bioString
        return bioString
    end

    return locale('inv_sv_nobio')
end

-- To get investigation data for a specific citizenid
RSGCore.Functions.CreateCallback('rsg-multicharacter:server:getInvestigationData', function(source, cb, citizenid)

    local data = {
        telegrams = {},
        legal = {
            isWanted = false,
            outlawstatus= 0,
            -- arrests = 0,
            -- warrants = 0,
            -- fines = 0.0
        },
        skins = {},
        outfits = {},
        animations = {},
        houses = {},
        housekeys = {},
        horses = {},
        companions = {},
        stats = {
            playtime = 0,
            citizenid = '',
            money = {},
            charinfo = {},
            job = {},
            gang = {},
            position = {},
            reputation = {}
        },
        metadata = {},
        inventory = {},
        bio = locale('inv_sv_nobio'),
    }

    local result = SafeQueryAwait("SELECT * FROM players WHERE citizenid = ?", { citizenid })
    if not result[1] then return cb(data) end
    local pData = result[1]

    -- INFO BASIC
    -- Others Sections / EXTRA
    if Config.Investigation.outfits.enabledSkins then data.skins = FetchSkins(citizenid) end
    if Config.Investigation.dossier.enableHouses then data.houses, data.housekeys = FetchHousesAndKeys(citizenid) end
    if Config.Investigation.dossier.enableHorses then data.horses = FetchHorses(citizenid) end
    if Config.Investigation.dossier.enableCompanions then data.companions = FetchCompanions(citizenid) end
    if Config.Investigation.dossier.enableAnimations then data.animations = FetchAnimations(citizenid) end

    -- Telegrams, outfits and dossier
    if Config.InvPanels.telegrams.enabled then data.telegrams = FetchTelegrams(citizenid) end
    if Config.InvPanels.outfits.enabled then data.outfits = FetchOutfits(citizenid) end
    if Config.InvPanels.dossier.enabled then

        -- logprint( locale('print_sv_dossier_enabled')..": ", json.encode(pData))
        data.stats = {
            playtime    = SafeDecode(pData.metadata, {}).playtime or 0,
            citizenid   = pData.citizenid,
            money       = SafeDecode(pData.money, {}),
            charinfo    = SafeDecode(pData.charinfo, {}),
            job         = SafeDecode(pData.job, {}),
            gang        = SafeDecode(pData.gang, {}),
            position    = SafeDecode(pData.position, {}),
        }
        data.metadata          = SafeDecode(pData.metadata, {})
        data.inventory         = SafeDecode(pData.inventory, {})

        data.legal = {
            --arrests     = pData.arrests or data.legal.arrests or nil,
            --warrants    = pData.warrants or data.legal.warrants or nil,
            --fines       = pData.fines or data.legal.fines or nil,
            outlawstatus= pData.outlawstatus or 0,
        }
        if pData.outlawstatus and pData.outlawstatus > 30 then
            data.legal.isWanted = true
        end

        -- Generate Biografía
        data.bio = BuildBiography(data)

        -- logprint(locale('print_sv_send')..": ", json.encode(data))
    end
    cb(data)
end)

-- To get investigation data for the client
-- RegisterNetEvent('rsg-multicharacter:client:getInvestigationData', function()
-- end)