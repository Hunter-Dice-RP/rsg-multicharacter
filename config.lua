Config = {}

Config.StarterHorse = true
Config.StarterHorseModel = 'a_c_horse_mp_mangy_backup'
Config.StarterHorseStable = 'valentine'
Config.StarterHorseName = 'Caballo de iniciación'

Config.DefaultNumberOfCharacters = 5 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}

-- locations
Config.STATE = {
    -- light
    LIGHTCOORDS_ENABLE = true, -- true/false in false coords PED
    LIGHT_POS = vector3(-558.3, -3775.70, 239.12),
    -- spawn player
    SPAWN_POS = vector3(-558.91, -3776.25, 237.63),
    SPAWN_HEADING = -45.0,-- 80.5485
    -- npc access
    SPAWN_INI = vector3(-562.91, -3776.25, 237.63),  -- 2698.6965, -1406.6420, 45.6350
    -- interior
    INTERTIOR = vector3(-558.9098, -3775.616, 238.59), -- -558.9098, -3775.616, 238.59, 137.98
    -- cam INITIAL
    CAM_INI = vector3(-564.315, -3775.421, 239.40), -- 2695.3130, -1405.9708, 46.6530)
    CAM_INI_ROT = vector3(-15.0, 0.0, 210.0), -- 0.0, 0.0, 262.3594
    -- cam POS
    CAM_POS = vector3(-557.5, -3775.40, 239.22), -- 2695.3130, -1405.9708, 46.6530
    CAM_POS_ROT = vector3(-10.0, 0.0, 95.0), -- 0.0, 0, 262.3594
    -- time fade important!
    FADE_DURATION = 500
}

Config.KeyUnstick = 0xF3830D8E -- 'J'
Config.UnstickStart = vector3(-549.77, -3778.38, 238.60)
Config.UnstickEnd = vector3(-169.47, 629.38, 114.03)

-- animations
Config.EnableAnimations = true -- TRUE/FALSE
Config.scenarios = {
    "WORLD_HUMAN_STERNGUY_IDLES",
    "WORLD_HUMAN_BADASS",
    "WORLD_HUMAN_DRINK_CHAMPAGNE",
    "WORLD_HUMAN_COFFEE_DRINK",
    "WORLD_HUMAN_SMOKE_CIGAR",
    "WORLD_HUMAN_SMOKE_NERVOUS_STRESSED",
    "WORLD_HUMAN_WRITE_NOTEBOOK",
    "WORLD_HUMAN_WAITING_IMPATIENT",
    "WORLD_HUMAN_SMOKE",
}

-- Configuración de la música para el panel de melodías
Config.Music = {
    -- Ejemplo: { label = "El Lamento del Forajido", path = "sad_story" },
    --          { label = "Polka del Saloon", path = "polka_beat" }
    { label = "Melodía del Coyote", path = "song/coyote-canyon.mp3" },
    { label = "Ritmo de la Curiosidad", path = "song/curiosity-rag.mp3" },
    { label = "Ritmo Outlaws", path = "song/dirty-outlaws.mp3" },
    { label = "Ritmo Outlaws Echoes", path = "song/dirty-outlaws-echoes.mp3" },
    { label = "Ritmo Ruso", path = "song/the-russian.mp3" },
    { label = "Ritmo WW", path = "song/western-wild.mp3" },
    { label = "Ritmo old native Western", path = "song/western_native_3.mp3" },
    { label = "Ritmo Native Western", path = "song/western_native_2.mp3" },
    { label = "Ritmo Native", path = "song/western_native_1.mp3" },
    { label = "Ritmo Old  Western", path = "song/western_main_2.mp3" },
    { label = "Ritmo Western", path = "song/western_main_1.mp3" },
    { label = "Ritmo Wild West", path = "song/western_5.mp3" },
    { label = "Ritmo Desert", path = "song/western_4.mp3" },
    { label = "Ritmo West", path = "song/western_3.mp3" },
    { label = "Ritmo Wild", path = "song/western_2.mp3" },
    { label = "Ritmo West", path = "song/western_1.mp3" },
    { label = "Ritmo", path = "song/main_1.mp3" }
}

-- Activa o desactiva cada panel y personaliza su icono y título.
-- Iconos de: https://fonts.google.com/icons

Config.InvestigationPanels = {
    dossier = {
        enabled = true, -- true/false toogle in nui
        icon = "fingerprint",
        title = "Ficha de Filiación",

        -- others part server call info
        enableHorses = true, -- true / false - info rsg-horses
        enableCompanions = true, -- true / false - info hdrp-companion
        enableAnimations = false, -- true / false - info animations (rsg-animations or we_emotes)
        enableHouses = true,  -- true / false - info rex-houses
    },
    telegrams = {
        enabled = true, -- true / false - toogle in nui and info rsg-telegram
        icon = "mail",
        title = "Telegramas"
    },
    outfits = {
        enabled = true, -- toogle in nui and rsg-wardrobe
        icon = "style",
        title = "Catálogo de Atuendos",

        -- others part server call info
        enabledSkins = true, -- rsg-appearance
    },
    music = {
        enabled = true, -- toogle in nui and Disabled Music by default, you can enable it if you have a music system
        icon = "music_note",
        title = "Melodías"
    }
}