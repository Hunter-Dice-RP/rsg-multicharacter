local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local charPed = nil
local DataSkin = nil
local cam = nil
local fixedCam = nil
local lightThread = nil
local spawnThread = nil

local selectingChar = true

local isChoosing = false

----------------------------------------------------------------
-- Handlers
----------------------------------------------------------------
local function logprint(key)
    if Config.Debug then print(locale('print_sv_debug'), key) end
end

-- CLEAN PED
local function cleanPed(ped)
    if DoesEntityExist(ped) then
        local model = IsPedMale(ped) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(ped, true, true)
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(model)
        charPed = nil
    end
end

-- CUSTOM NPC RANDOM
local function baseModel(sex)
    local partsBody = (sex == 'mp_male') and {
        {0x158cb7f2, true}, --head
        {361562633, true}, --hair
        {62321923, true}, --hand
        {3550965899, true}, --legs
        {612262189, true}, --Eye
        {319152566, true},
        {0x2CD2CB71, true}, -- shirt
        {0x151EAB71, true}, -- bots
        {0x1A6D27DD, true} -- pants
    } or {
        {0x1E6FDDFB, true}, -- head
        {272798698, true}, -- hair
        {869083847, true}, -- Eye
        {736263364, true}, -- hand
        {0x193FCEC4, true}, -- shirt
        {0x285F3566, true}, -- pants
        {0x134D7E03, true} -- bots
    }
    for _, part in ipairs(partsBody) do
        if charPed and DoesEntityExist(charPed) then
            ApplyShopItemToPed(charPed, part[1], part[2], true, true)
        end
    end
end

-- SPAWN PED
--[[ local function spawnCharPed(model, coords, heading)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    charPed = CreatePed(model, coords.x, coords.y, coords.z, heading, false, false)
    FreezeEntityPosition(charPed, false)
    SetEntityInvincible(charPed, true)
    SetBlockingOfNonTemporaryEvents(charPed, true)
    return charPed
end ]]

----------------------------------------------------------------
-- EXTRA NUI and Character Info
----------------------------------------------------------------
-- INVESTIGATION
local function investigationPed(cid)
    SendNUIMessage({ action = 'clearInvestigationData' })
    Wait(10)
    if cid then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getInvestigationData', function(dataPly)
            SendNUIMessage({ action = 'updateInvestigationData', data = dataPly })
        end, cid)
    end
end

-- ANIMATION
local function iniScenario(ped)
    if not Config.EnableAnimations or not selectingChar or not DoesEntityExist(ped) then return end
    local scene = Config.Scenarios[math.random(#Config.Scenarios)]
    TaskStartScenarioInPlace(ped, scene, -1, true, false, false, false)
end

----------------------------------------------------------------
-- Multicharacter Group Handling
----------------------------------------------------------------
local function GetMulticharacterGroup()
    local groups = {}
    for k, _ in pairs(Config.Multicharacter) do
        table.insert(groups, k)
    end
    if #groups == 0 then
        logprint(locale('print_cl_nocoords'))
        return Config.Multicharacter[Config.DefaultGroup], Config.DefaultGroup
    end
    local randomIndex = math.random(1, #groups)
    local selectedKey = groups[randomIndex]
    return Config.Multicharacter[selectedKey], selectedKey
end

-- Get the selected group and its name
local selectedGroup, groupName = GetMulticharacterGroup()
logprint(locale('print_cl_group').. ": ".. groupName)
logprint(locale('print_cl_coords')..": ".. selectedGroup.ply_coords)

----------------------------------------------------------------
-- Camera and Visual Effects
----------------------------------------------------------------
-- TIMECYCLE
local function applyBlur()
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
end

-- CAMERA
local function skyCam(state)
    if not selectedGroup then logprint(locale('print_cl_no_group')) return end

    if state then
        DoScreenFadeIn(1000)
        applyBlur()

        -- Cam ini (toma general)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, selectedGroup.ini_cam.x, selectedGroup.ini_cam.y, selectedGroup.ini_cam.z)
        SetCamRot(cam, selectedGroup.ini_camrot.x, selectedGroup.ini_camrot.y, selectedGroup.ini_camrot.z)
        SetCamActive(cam, true)

        -- Cam end (nuestro plano perfecto)
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(fixedCam, selectedGroup.end_cam.x, selectedGroup.end_cam.y, selectedGroup.end_cam.z)
        SetCamRot(fixedCam, selectedGroup.end_camrot.x, selectedGroup.end_camrot.y, selectedGroup.end_camrot.z)
        SetCamFov(fixedCam, 60.0)
        -- PointCamAtCoord(fixedCam, 0.0, 0.0, 1.7)    -- Apunta la cam directamente al personaje

        SetCamActive(fixedCam, true)
        SetCamActiveWithInterp(fixedCam, cam, 3900, true, true)
        RenderScriptCams(true, true, 1000, true, false)

        Wait(3900)
        if cam and DoesCamExist(cam) then DestroyCam(cam) end

        -- DestroyCam(groundCam)
        InterP = true
    else
        SetTimecycleModifier('default')

        -- SetCamActive(cam, false)
        -- DestroyCam(cam, true)
        if cam and DoesCamExist(cam) then
            SetCamActive(cam, false)
            DestroyCam(cam, true)
        end
        cam = nil

        --[[ if fixedCam and DoesCamExist(fixedCam) then DestroyCam(fixedCam, true) end
        fixedCam = nil ]]

        RenderScriptCams(false, false, 1, true, true)
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, false)
    end
end

-- LIGHT
local function applyLighOn(bool)
    if not selectedGroup then logprint(locale('print_cl_no_group')) return end
    if lightThread then TerminateThread(lightThread) end
    lightThread = CreateThread(function()
        while selectingChar do
            Wait(1)
            local playerPed = PlayerPedId()
            local coords = bool and selectedGroup.light_coords or GetEntityCoords(playerPed)
            local range = bool and 11.0 or 5.5
            local intensity = bool and 100.0 or 50.0
            DrawLightWithRange(coords.x, coords.y , coords.z + 1.0 , 255, 255, 255, range, intensity)
        end
    end)
end

----------------------------------------------------------------
-- EVENT PRINCIPAL
----------------------------------------------------------------
-- CreateThread(function()
--     while true do
--         Wait(0)
--         if NetworkIsSessionStarted() then
--             Wait(500)
--             TriggerEvent('rsg-multicharacter:client:chooseChar')
--             return
--         end
--     end
-- end)
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(1000) end
    Wait(500)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
end)

----------------------------------------------------------------
-- NUI and Character Events
----------------------------------------------------------------
-- OPEN NUI
local function openCharMenu(state)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(state, state)
        SendNUIMessage({
            action = "ui",
            toggle = state,
            nChar = result,

            panelConfig = Config.InvPanels,
            musicConfigData = json.encode(Config.Music),
            -- text = locales
        })
        isChoosing = state
        --choosingCharacter = state
        Wait(100)
        skyCam(state)     -- CAM
    end)
end

-- STOP NUI
RegisterNetEvent('rsg-multicharacter:client:closeNUI', function()
    -- DeleteEntity(charPed)
    cleanPed(charPed)

    SetNuiFocus(false, false)
    isChoosing = false
end)

-- EVENT PRINCIPAL
RegisterNetEvent('rsg-multicharacter:client:chooseChar', function()

    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, false, false)
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    -- LOAD INTERIOR COORDS AND PED POSITION

    if not selectedGroup then logprint(locale('print_cl_no_group')) return end
    GetInteriorAtCoords(selectedGroup.interior.x, selectedGroup.interior.y, selectedGroup.interior.z)
    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, selectedGroup.charPed_coords.x, selectedGroup.charPed_coords.y, selectedGroup.charPed_coords.z)
    Wait(1500)

    -- OFF LOADSCREEN
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(10)
    -- SYNC OFF
    exports.weathersync:setMyTime(0, 0, 0, 0, true)

    -- NUI
    openCharMenu(true)
    applyLighOn(Config.enabledLight)
end)

-- STOP RESOURCE
AddEventHandler('onResourceStop', function(resource)
    -- if (GetCurrentResourceName() == resource) then
    --     DeleteEntity(charPed)
    --     SetModelAsNoLongerNeeded(charPed)
    -- end

    if (GetCurrentResourceName() ~= resource) then return end
    selectingChar = false

    SetTimecycleModifier('default')
    DestroyAllCams(true)
    RenderScriptCams(false, false, 0, true, false)
    cam = nil
    fixedCam = nil

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)

    cleanPed(charPed)
    DataSkin = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "ui", toggle = false })
end)

----------------------------------------------------------------
-- NUI CALLBACKS
----------------------------------------------------------------
-- LOAD CHAR AND INVESTIGATION
-- Visually seeing the char
RegisterNUICallback('cDataPed', function(data, cb) -- Visually seeing the char
    local cData = data.cData

    -- SetEntityAsMissionEntity(charPed, true, true)
    -- DeleteEntity(charPed)
    cleanPed(charPed)

    if not selectedGroup then logprint(locale('print_cl_no_group')) return end
    if cData ~= nil then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
            local skinTable = appearance.skin or {}
            DataSkin = appearance.skin
            local clothesTable = appearance.clothes or {}
            local sex = tonumber(skinTable.sex) == 1 and `mp_male` or `mp_female`
            if sex ~= nil then
                if spawnThread then TerminateThread(spawnThread) end
                spawnThread = CreateThread(function ()
                    RequestModel(sex)
                    while not HasModelLoaded(sex) do Wait(0) end
                    Wait(100)
                    charPed = CreatePed(sex, selectedGroup.ply_coords.x, selectedGroup.ply_coords.y, selectedGroup.ply_coords.z, selectedGroup.ply_heading, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    while not IsPedReadyToRender(charPed) do
                        Wait(1)
                    end
                    exports['rsg-appearance']:ApplySkinMultiChar(skinTable, charPed, clothesTable)
                end)

                Wait(50)

                iniScenario(charPed)
                investigationPed(cData.citizenid)

            else
                if spawnThread then TerminateThread(spawnThread) end
                spawnThread = CreateThread(function()
                    local randommodels = {
                        "mp_male",
                        "mp_female",
                    }
                    local randomModel = randommodels[math.random(1, #randommodels)]
                    local model = joaat(randomModel)
                    RequestModel(model)
                    while not HasModelLoaded(model) do Wait(0) end
                    Wait(100)
                    baseModel(randomModel)
                    charPed = CreatePed(model, selectedGroup.ply_coords.x, selectedGroup.ply_coords.y, selectedGroup.ply_coords.z, selectedGroup.ply_heading, false, false)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                end)
                Wait(50)

                iniScenario(charPed)
                investigationPed(cData.citizenid)
            end
        end, cData.citizenid)
    else
        if spawnThread then TerminateThread(spawnThread) end
        spawnThread = CreateThread(function()
            local randommodels = {
                "mp_male",
                "mp_female",
            }
            local randomModel = randommodels[math.random(1, #randommodels)]
            local model = joaat(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            charPed = CreatePed(model, selectedGroup.ply_coords.x, selectedGroup.ply_coords.y, selectedGroup.ply_coords.z, selectedGroup.ply_heading, false, false)
            Wait(100)
            baseModel(randomModel)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            NetworkSetEntityInvisibleToNetwork(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
        Wait(50)

        iniScenario(charPed)
        investigationPed()
    end
    cb('ok')
end)

-- CLOSE
RegisterNUICallback('closeUI', function(data, cb)
    openCharMenu(false)
    cb('ok')
end)

-- SELECT LIST
RegisterNUICallback('selectCharacter', function(data, cb)
    selectingChar = false
    local cData = data.cData
    if DataSkin ~= nil then
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)

        openCharMenu(false)
        -- local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        -- SetEntityAsMissionEntity(charPed, true, true)
        -- DeleteEntity(charPed)
        cleanPed(charPed)

        Wait(5000)
        TriggerServerEvent('rsg-appearance:server:LoadSkin')
        Wait(500)
        TriggerServerEvent('rsg-appearance:server:LoadClothes', 1)
        -- SetModelAsNoLongerNeeded(model)
    else
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData, true)
        openCharMenu(false)

        -- local model = IsPedMale(charPed) and 'mp_male' or 'mp_female'
        -- SetEntityAsMissionEntity(charPed, true, true)
        -- DeleteEntity(charPed)
        -- SetModelAsNoLongerNeeded(model)
        cleanPed(charPed)
    end
    cb('ok')
end)

-- LIST
RegisterNUICallback('setupCharacters', function(data, cb) -- Present char info
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
    cb('ok')
end)

-- RESTART TIME CYCLE
RegisterNUICallback('removeBlur', function(data, cb)
    SetTimecycleModifier('default')
    cb('ok')
end)

-- NEW PLAYER
RegisterNUICallback('createNewCharacter', function(data, cb) -- Creating a char
    selectingChar = false
    DoScreenFadeOut(150)
    Wait(200)
    TriggerEvent("rsg-multicharacter:client:closeNUI")
    DestroyAllCams(true)

    -- SetModelAsNoLongerNeeded(charPed)
    -- DeleteEntity(charPed)
    cleanPed(charPed)

    DoScreenFadeIn(1000)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    TriggerEvent('rsg-appearance:client:OpenCreator', data)
    cb('ok')
end)

-- DEL PLAYER
RegisterNUICallback('removeCharacter', function(data, cb) -- Removing a char
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    Wait(200)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({ action = "setupCharacters", characters = result })
    end)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
    cb('ok')
end)

-- DISCONNECT
--[[ RegisterNUICallback('disconnectButton', function(data, cb)
    cleanPed(charPed)
    TriggerServerEvent('rsg-multicharacter:server:disconnect')
    cb('ok')
end) ]]