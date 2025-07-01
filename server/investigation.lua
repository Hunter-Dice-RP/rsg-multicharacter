local RSGCore = exports['rsg-core']:GetCoreObject()

-- Safe JSON decode, returns fallback on error or non-table
local function SafeDecode(jsonString, fallback)
    local ok, result = pcall(function() return json.decode(jsonString or '') end)
    if ok and type(result) == 'table' then return result end
    return fallback or {}
end

local function SafeQueryAwait(query, params)
    local result
    local ok, err = xpcall(function()
        result = MySQL.query.await(query, params)
    end, function(e)
        print("[ERROR SQL] "..e)
        print(debug.traceback())
    end)
    return result or {}
end

-- HELPERS 
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
    local query = "SELECT * FROM player_horses WHERE citizenid = ? ORDER BY `horsexp` DESC LIMIT 3"
    local horses = SafeQueryAwait(query, { citizenid }) or {}
    -- local horses = SafeQueryAwait("SELECT * FROM player_horses WHERE citizenid = ?", { citizenid }) or {}
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
            stable = companion.stable,
            companiondata = SafeDecode(companion.companiondata, {}),
            components = SafeDecode(companion.components, {})
        })
    end
    return out
end

local function FetchAnimations(citizenid)
    -- local animations = MySQL.Sync.fetchAll('SELECT * FROM favorites_animations WHERE citizenid = ?', { citizenid })
    local result = SafeQueryAwait("SELECT * FROM emenu_styles WHERE character_id = ?", { citizenid })
    local out = {}
    for _, v in ipairs(result) do
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


local bioSections = {
    intro = {
        "Dicen que en estos lares nadie olvida un rostro… ni una tragedia. El tal %s %s parece decidido a cambiar eso.",
        "En cuanto pisó el polvoriento pueblo, %s %s supo que el Oeste no perdona a los de corazón blando.",
        "%s %s llegó como el viento entre los cañones: sin aviso, sin disculpas.",
        "Nadie sabe si %s %s es el héroe que necesitábamos… o el desastre que merecíamos.",
        "Las leyendas no siempre llevan capa. Algunas montan a caballo y escupen tabaco. Como %s %s."
    },
    background = {
        "Con un grupo sanguíneo %s y más cicatrices que un rancho abandonado, pertenece al gremio de %s.",
        "Forjado entre whisky y pólvora, su pacto con la banda “%s” le ha granjeado tan buena como mala reputación.",
        "Criado por bandidos y educado por el caos, su lealtad es tan volátil como la dinamita.",
        "Dicen que %s no es un tipo, sino una tormenta con botas. Marca registrada de %s.",
        "Abandonado por el destino, recogido por %s. Así comenzó el cuento que aún no termina."
    },
    assets = {
        function(ctx)
            return ctx.houses > 0
                and ("Es dueño de %d moradas donde pueden oírse murmullos… y a veces disparos."):format(ctx.houses)
                or "No paga renta, pero tampoco tiene casa que quemar."
        end,
        function(ctx)
            return ctx.houses > 0
                and ("Posee %d propiedades. Si las paredes hablaran, gritarían."):format(ctx.houses)
                or "No tiene techo fijo. Como las balas perdidas, va donde el viento lo arrastra."
        end,
        function(ctx)
            return ctx.outfits > 0
                and ("Viste con %d atuendos tan relucientes como un revólver recién pulido."):format(ctx.outfits)
                or "Hace de su harapos una bandera de orgullo."
        end,
        function(ctx)
            return ctx.outfits > 0
                and ("Su guardarropa es testigo de %d vidas pasadas."):format(ctx.outfits)
                or "Viste lo puesto. Y lo puesto lleva años puesto."
        end
    },
    companions = {
        function(ctx)
            return ctx.horses > 0
                and ("Posee %d corcel(es) que relinchan a la menor señal."):format(ctx.horses)
                or "Dejó a punta de espuelas más caballos que raíces."
        end,
        function(ctx)
            return ctx.horses > 0
                and ("Sus %d caballos conocen caminos que ni los mapas se atreven a mostrar."):format(ctx.horses)
                or "No monta. Prefiere dejar huellas con las botas rotas."
        end,
        function(ctx)
            return ctx.companions > 0
                and ("A su lado lame la mano hambrienta de %d compañero(s) peludos."):format(ctx.companions)
                or "Ni un cuervo le hace compañía en el amanecer."
        end
    },
    behavior = {
        function(ctx)
            return ("Camina con estilo %s, es capaz de ganarse el aplauso de un tiburón y aterrorizar a un gato."):format(ctx.walk)
        end,
        function(ctx)
            return ("Cuando la bronca llama, saca su estilo de pelea %s como si fuera un cuchillo bien afilado."):format(ctx.brawl)
        end,
        function(ctx)
            return ("Camina como quien ya ha muerto y sigue de pie. Su estilo: %s."):format(ctx.walk)
        end
    },
    legal = {
        function(ctx)
            return ctx.isWanted
                and ("Se le busca con orden de arresto de nivel ALTO, un infierno en tinta negra.")
                or ""
        end,
        -- function(ctx)
        --     return ctx.arrests > 0
        --         and ("Con %d arrestos a cuestas, su sombra es más larga que su nombre."):format(ctx.arrests)
        --         or "Sin grilletes marcados… por ahora."
        -- end,
        function(ctx)
            return ctx.isWanted and "Los postes de recompensa llevan su rostro… y más agujeros que un colador." or ""
        end
    },
    outro = {
        "En resumen: si lo cruzas, quítate el sombrero… y corre.",
        "Este es su legado: polvo, disparos y risas macabras cuando cae el sol.",
        "Ni amigo ni enemigo. Solo una advertencia con sombrero.",
        "Si sobrevive, la historia se contará. Si no, será parte del desierto.",
        "Un último trago, un disparo, y %s %s vuelve a fundirse en la noche…"
    }
}

local function AddFlavorInterludes()
    local interludes = {
        "Dicen que lo vieron en Blackwater… o tal vez fue su fantasma.",
        "El whisky le teme. Las balas lo esquivan por respeto.",
        "Tiene enemigos que rezan por no encontrarlo, y amigos que rezan por hacerlo.",
        "La noche en que llegó, el silencio se escondió bajo la mesa.",
    }
    return interludes[math.random(#interludes)]
end

--[[ local narrativeStyles = {
    ["épico"] = function() return math.random(1, 3) end,
    ["cómico"] = function() return math.random(2, 4) end,
    ["oscuro"] = function() return math.random(3, 5) end,
    ["misterioso"] = function() return math.random(1, 5) end,
    ["trágico"] = function() return 1 end
} ]]

-- Generate a brief biography based on collected data
local function BuildBiography(data)
    -- PREPARE INFO DATA PLAYER
    local ctx = {
        firstname  = data.stats.charinfo.firstname or "Desconocido",
        lastname   = data.stats.charinfo.lastname  or "",
        blood      = data.metadata.bloodtype or "Desconocido",
        guild      = data.stats.job.label or "ningún gremio",
        gang       = data.stats.gang.label or "ninguna banda",
        houses     = #data.houses,
        outfits    = #data.outfits,
        horses     = #data.horses,
        companions = #data.companions,
        walk       = data.animations[1] and (data.animations[1].walk_style or "Normal") or "Normal",
        brawl      = data.animations[1] and (data.animations[1].brawl_style or "Estándar") or "Estándar",
        -- arrests    = data.legal.arrests,
        isWanted   = data.legal.isWanted
    }

    local lines = {}
    -- Intro

    -- local idx = narrativeStyles["épico"] and narrativeStyles["épico"]() or math.random(1, #bioSections.intro)
    -- local intro = bioSections.intro[idx]
    -- local intro = bioSections.intro[math.random(#bioSections.intro)]
    -- table.insert(lines, intro:format(ctx.firstname, ctx.lastname))

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
        -- Concatena las líneas en un solo string
        local bioString = table.concat(lines, " ")
        -- Asigna el string al campo bio de los datos
        data.bio = bioString
        -- DEVUELVE EL STRING
        return bioString
    end

    -- Devuelve un valor por defecto si no se generaron líneas
    return "Sin observaciones notables."
end

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
        bio = "Sin observaciones notables."
    }

    local result = SafeQueryAwait("SELECT * FROM players WHERE citizenid = ?", { citizenid })
    if not result[1] then return cb(data) end
    local pData = result[1]

    -- Sections
    if Config.InvestigationPanels.telegrams.enabled then data.telegrams = FetchTelegrams(citizenid) end
    if Config.InvestigationPanels.outfits.enabledSkins then data.skins = FetchSkins(citizenid) end
    if Config.InvestigationPanels.outfits.enabled then data.outfits = FetchOutfits(citizenid) end

    if Config.InvestigationPanels.dossier.enableHouses then data.houses, data.housekeys = FetchHousesAndKeys(citizenid) end
    if Config.InvestigationPanels.dossier.enableHorses then data.horses = FetchHorses(citizenid) end
    if Config.InvestigationPanels.dossier.enableCompanions then data.companions = FetchCompanions(citizenid) end
    if Config.InvestigationPanels.dossier.enableAnimations then data.animations = FetchAnimations(citizenid) end

    -- Stats & metadata
    if Config.InvestigationPanels.dossier.enabled then

        -- INFO BASIC
        -- print("3. [INVESTIGACIÓN] Datos crudos del jugador desde la BD: ", json.encode(pData))
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

        -- Generar Biografía
        data.bio = BuildBiography(data)

        -- print("10. [INVESTIGACIÓN] Enviando datos finales al cliente: ", json.encode(data))
    end
    cb(data)
end)

-- Mark telegrams as read
RSGCore.Functions.CreateCallback('rsg-multicharacter:server:markTelegramsAsRead', function(source, cb, recipientName)
    MySQL.Async.execute('UPDATE telegrams SET status = 1 WHERE recipient = ? AND status = 0', { recipientName }, function() cb(true) end)
end)