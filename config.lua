Config = {}

Config.Debug = true -- Define if debug mode is enabled (default is true)    

-- SETTINGS SLOTS PLAYER
Config.DefaultNumberOfCharacters = 5 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}

-- START HORSE & COMPANION  ✅
Config.StarterHorse = true -- Define if the horse should be given to the player (RSG-HORSE)
Config.StarterHorseModel = 'a_c_horse_mp_mangy_backup' -- Define the model of the horse
Config.StarterHorseStable = 'valentine' -- Define the stable where the horse will be stored

Config.StarterCompanion = true -- Define if the companion should be given to the player (HDRP-COMAPNION)
Config.StarterCompanionModel = 'a_c_doghusky_01' -- Define the model of the companion
Config.StarterCompanionStable = 'valentine' -- Define the stable where the companion will be stored

-- TP SECURITY ✅
Config.KeyUnstick = 0xF3830D8E -- Define the key to unstick the player (default is ['J'])
Config.UnstickStart = vector3(-549.77, -3778.38, 238.60) -- Define the start position for unstick (default is vector3(-549.77, -3778.38, 238.60))
Config.UnstickEnd = vector3(-169.47, 629.38, 114.03) -- Define the end position for unstick (default is vector3(-169.47, 629.38, 114.03))

-- Turn each panel on or off and customize its icon and title. ✅
Config.InvPanels = {
    dossier = {
        enabled = true, -- true/false toogle in nui
        icon = "fingerprint", -- Icons: https://fonts.google.com/icons
        title = "Ficha de Filiación",
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
    },
    music = {
        enabled = true, -- toogle in nui and Disabled Music by default, you can enable it if you have a music system
        icon = "music_note",
        title = "Melodías"
    }
}

-- Define the investigation EXTRA configuration Bio ✅
Config.Investigation = {
    dossier = {
        -- others part server call info
        enableHouses = true,  -- true / false - rex-houses
        enableHorses = true, -- true / false - rsg-horses
        enableCompanions = true, -- true / false - hdrp-companion

        enableAnimations = false, -- true / false - animations (rsg-animations or we_emotes)
        sqlAnimations = 'wd_emotemenu' -- Define the SQL animations table ('rsg-animations' or 'wd_emotemenu')
    },
    outfits = {
        -- others part server call info
        enabledSkins = true, -- rsg-appearance
    },
}

-- Animations Player Scene
Config.EnableAnimations = true -- true/false toogle in nui and rsg-animations or we_emotes
Config.Scenarios = { -- add scenes 
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

-- Important! Need Config.InvPanels.music.enabled = true
Config.Music = {-- add file.mp3 in html/song
    { label = "Cañón del Coyote", path = "song/coyote-canyon.mp3" },
    { label = "Curiosidad Errante", path = "song/curiosity-rag.mp3" },
    { label = "Balada Forajida", path = "song/dirty-outlaws.mp3" },
    { label = "Ecos de Forajidos", path = "song/dirty-outlaws-echoes.mp3" },
    { label = "Sombras del Zar", path = "song/the-russian.mp3" },
    { label = "Espíritu Salvaje", path = "song/western-wild.mp3" },
    { label = "Alma del Oeste", path = "song/western_native_3.mp3" },
    { label = "Viejo Sendero", path = "song/western_native_2.mp3" },
    { label = "Raíces del Oeste", path = "song/western_native_1.mp3" },
    { label = "Herencia Fronteriza", path = "song/western_main_2.mp3" },
    { label = "Llanuras del Oeste", path = "song/western_main_1.mp3" },
    { label = "Desenfreno Salvaje", path = "song/western_5.mp3" },
    { label = "Arena y Sol", path = "song/western_4.mp3" },
    { label = "Cabalgata del Oeste", path = "song/western_3.mp3" },
    { label = "Galopar Salvaje", path = "song/western_2.mp3" },
    { label = "Horizonte del Oeste", path = "song/western_1.mp3" },
    { label = "Espuelas y Polvo", path = "song/main_1.mp3" }
}

-- Settings to coords spawn adn camera
Config.Fade_duration = 500 -- important! Time in milliseconds for fade in and fade out
Config.enabledLight = true -- true/false when to 'false' take coords PED or NPC
Config.DefaultGroup = "origin" -- Define the default group for multicharacter (origin, essential, dressy)
Config.Multicharacter = {
    origin ={
        ply_coords = vector3(-558.91, -3776.25, 237.63),    -- spawn player
        ply_heading = 90.0,
        charPed_coords = vector3(-562.91, -3776.25, 237.63),    -- charPed
        -- interior
        interior = vector3(-558.9098, -3775.616, 238.59), -- -558.9098, -3775.616, 238.59, 137.98
        light_coords = vector3(-558.3, -3775.70, 239.12),-- Define the light position
        -- cameras
        ini_cam = vector3(-555.925, -3778.709, 238.597),    -- cam INITIAL
        ini_camrot = vector3(-20.0, 0.0, 83),
        end_cam = vector3(-561.206, -3776.224, 239.597),    -- cam END
        end_camrot = vector3(-20.0, 0, 270.0)
    },
    essential ={
        ply_coords = vector3(-558.91, -3776.25, 237.63),    -- spawn player
        ply_heading = -45.0,
        charPed_coords = vector3(-562.91, -3776.25, 237.63),    -- charPed
        -- interior
        interior = vector3(-558.9098, -3775.616, 238.59), -- -558.9098, -3775.616, 238.59, 137.98
        light_coords = vector3(-558.3, -3775.70, 239.12),-- Define the light position
        -- cameras
        ini_cam = vector3(-564.315, -3775.421, 239.40),    -- cam INITIAL
        ini_camrot = vector3(-15.0, 0.0, 210.0),
        end_cam = vector3(-557.5, -3775.40, 239.22),    -- cam END
        end_camrot = vector3(-10.0, 0.0, 95.0)
    },
    dressy = { -- K3nm
        ply_coords = vector3(-558.91, -3776.25, 237.63),--  SPAWN_POS = 
        ply_heading = 80.5485, --  SPAWN_HEADING = 
        charPed_coords = vector3(2698.6965, -1406.6420, 45.6350), -- SPAWN_INI = 
        -- interior
        interior = vector3(-558.9098, -3775.616, 238.59), -- INTERTIOR = 
        light_coords = vector3(-558.3, -3775.70, 239.12),-- Define the light position
        -- cameras
        ini_cam = vector3(2695.3130, -1405.9708, 46.6530), -- CAM_INI = 
        ini_camrot = vector3(0.0, 0.0, 262.3594), -- CAM_INI_ROT 
        end_cam = vector3(2695.3130, -1405.9708, 46.6530),   -- CAM_POS 
        end_camrot = vector3(0.0, 0, 262.3594), -- CAM_POS_ROT 
    }
}