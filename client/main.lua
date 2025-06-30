--[[ RegisterNUICallback('disconnectButton', function(data, cb)
    if charPed and DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
    end
    charPed = nil
    TriggerServerEvent('rsg-multicharacter:server:disconnect')
    cb('ok')
end) ]]

local RSGCore = exports['rsg-core']:GetCoreObject()
-- local CamManager = exports['rsg-menubase']:GetCamManager()

local charPed = nil
local DataSkin = nil
local selectingChar = false

local cam = nil
local fixedCam = nil

----------------------------------------------------------------
-- Handlers
----------------------------------------------------------------
-- ANIMATION
local function iniScenario(ped)
    if not selectingChar or not ped or not DoesEntityExist(ped) then return end
    if DoesEntityExist(ped) then
        local scene = Config.scenarios[math.random(#Config.scenarios)]
        TaskStartScenarioInPlace(ped, scene, -1, true, false, false, false)
    end
end

-- CLEAN PED
local function cleanPed(ped)
    if DoesEntityExist(ped) then
        local model = IsPedMale(ped) and 'mp_male' or 'mp_female'
        SetEntityAsMissionEntity(ped, true, true)
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(model)
        ped = nil
    end
end

-- LIGHT
local function applyLighOn(bool)
    while selectingChar do
        Wait(1)
        if bool then
            -- LIGHT COORDS
            DrawLightWithRange(Config.STATE.LIGHT_POS.x, Config.STATE.LIGHT_POS.y , Config.STATE.LIGHT_POS.z + 1.0 , 255, 255, 255, 5.5, 100.0)
        else
            -- LIGHT PED
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            DrawLightWithRange(coords.x, coords.y , coords.z + 1.0 , 255, 255, 255, 5.5, 50.0)
        end
    end
end

-- TIMECYCLE
local function applyBlur()
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
end

-- CAMERA
local function SetupInmersiveCam(bool)
    local playerPed = PlayerPedId()
    if bool then
        -- DoScreenFadeIn(1000)
        -- applyBlur()

        -- Cam ini (toma general)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, Config.STATE.CAM_INI.x, Config.STATE.CAM_INI.y, Config.STATE.CAM_INI.z)
        SetCamRot(cam, Config.STATE.CAM_INI_ROT.x, Config.STATE.CAM_INI_ROT.y, Config.STATE.CAM_INI_ROT.z) -- Apuntando hacia el área general del spawn
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, true, false)

        -- Cam end (nuestro plano perfecto)
        -- Posicionan la cam a la DERECHA del personaje para que éste aparezca a la IZQUIERDA
        fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(fixedCam, Config.STATE.CAM_POS.x, Config.STATE.CAM_POS.y, Config.STATE.CAM_POS.z)
        SetCamRot(fixedCam, Config.STATE.CAM_POS_ROT.x, Config.STATE.CAM_POS_ROT.y, Config.STATE.CAM_POS_ROT.z) -- Apuntando hacia el área general del spawn
        SetCamFov(fixedCam, 60.0)
        -- Apunta la cam directamente al personaje
        -- PointCamAtCoord(fixedCam, 0.0, 0.0, 1.7)
        SetCamActive(fixedCam, true)

        -- active cam interior
        local sleep = 2000
        SetCamActiveWithInterp(fixedCam, cam, sleep, true, true)
        Wait(sleep)
        -- CreateThread(function()
        --     Wait(2000)
        --     if cam and DoesCamExist(cam) then
        --         DestroyCam(cam, false)
        --         cam = nil
        --     end
        -- end)
        DestroyAllCams(true)
        RenderScriptCams(false, false, 0, true, false)
        -- WHAT IS CAMERA groundCam ???
        -- WHAT IS InterP ???
        -- if groundCam and DoesCamExist(groundCam) then
        --     DestroyCam(groundCam, false)
        --     groundCam = nil
        -- end
        -- InterP = true

    else

        SetTimecycleModifier('default')
        if cam and DoesCamExist(cam) then
            SetCamActive(cam, false)
            DestroyCam(cam, true)
        end
        if fixedCam and DoesCamExist(fixedCam) then
            SetCamActive(fixedCam, false)
            DestroyCam(fixedCam, true)
        end
        DestroyAllCams(true)
        RenderScriptCams(false, false, 0, true, false)
        cam = nil
        fixedCam = nil
        FreezeEntityPosition(playerPed, false)
    end
end

-- TXT NUI
local locales = {}

-- OPEN NUI
local function openCharMenu(bool)
    SetupInmersiveCam(bool)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
            panelConfig = Config.InvestigationPanels,
            musicConfigData = json.encode(Config.Music),
            text = locales
        })
    end)

end

-- CLOSE MOUSE NUI
RegisterNetEvent('rsg-multicharacter:client:closeNUI', function()
    cleanPed(charPed)
    SetNuiFocus(false, false)
end)

-- STOP RESOURCE
AddEventHandler('onResourceStop', function(resource)
    if (GetCurrentResourceName() ~= resource) then return end
    selectingChar = false
    -- openCharMenu(false)

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

local function StopCharacterSelectionCam()
    --if not selectingChar then return end
    DoScreenFadeOut(Config.STATE.FADE_DURATION)
    Wait(Config.STATE.FADE_DURATION)

    selectingChar = false

    SetTimecycleModifier('default')
    DestroyAllCams(true)
    --CamManager.Destroy()
    RenderScriptCams(false, false, 0, true, false)
    cam = nil
    fixedCam = nil

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)

    cleanPed(charPed)
    DataSkin = nil

    openCharMenu(false)
end

----------------------------------------------------------------
-- EVENT PRINCIPAL
----------------------------------------------------------------
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(1000) end
    Wait(500)
    TriggerEvent('rsg-multicharacter:client:chooseChar')
end)

RegisterNetEvent('rsg-multicharacter:client:chooseChar', function()
    selectingChar = true

    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, false, false)
    DoScreenFadeOut(250)
    Wait(250)

    FreezeEntityPosition(playerPed, true)

    -- LOAD INTERIOR COORDS AND PED POSITION
    GetInteriorAtCoords(Config.STATE.INTERTIOR.x, Config.STATE.INTERTIOR.y, Config.STATE.INTERTIOR.z)
    SetEntityCoords(playerPed, Config.STATE.SPAWN_INI.x, Config.STATE.SPAWN_INI.y, Config.STATE.SPAWN_INI.z, false, false, false, true)
    SetEntityHeading(playerPed, Config.STATE.SPAWN_HEADING)
    Wait(1500)

    -- OFF LOADSCREEN
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(10)
    -- SYNC OFF
    exports.weathersync:setMyTime(0, 0, 0, 0, true)

    -- CAM, NUI, BLUR AND LIGHT ON
    -- SetupInmersiveCam(true)
    openCharMenu(true)

    applyBlur()
    DoScreenFadeIn(1000)
    applyLighOn(Config.STATE.LIGHTCOORDS_ENABLE)

end)

----------------------------------------------------------------
-- HELPERS NUI
----------------------------------------------------------------
-- CUSTOM NPC RANDOM
local function baseModel(ped, sex)
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
        ApplyShopItemToPed(ped, part[1], part[2], true, true)
    end
end

----------------------------------------------------------------
-- NUI CALLBACKS
----------------------------------------------------------------

-- LOAD CHAR AND INVESTIGATION
-- Visually seeing the char
RegisterNUICallback('cDataPed', function(data, cb)
    cleanPed(charPed)

    local function createAndShowPed(randomModel, skin, clothes, citizenid, bool)
        CreateThread(function()
            local model = joaat(randomModel)
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            charPed = CreatePed(model, Config.STATE.SPAWN_POS.x, Config.STATE.SPAWN_POS.y, Config.STATE.SPAWN_POS.z, Config.STATE.SPAWN_HEADING, false, false)

            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            SetBlockingOfNonTemporaryEvents(charPed, true)

            if skin then
                while not IsPedReadyToRender(charPed) do
                    Wait(1)
                end
                exports['rsg-appearance']:ApplySkinMultiChar(skin, charPed, clothes)
            else
                baseModel(charPed, model == `mp_male` and 'mp_male' or 'mp_female')
            end

            Wait(50)

            iniScenario(charPed)

            -- PLAYER INVESTIGATION
            if citizenid then
                -- Clean
                SendNUIMessage({ action = 'clearInvestigationData' })
                Wait(10)
                -- LOAD 
                RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getInvestigationData', function(investigationData)
                    SendNUIMessage({ action = 'updateInvestigationData', data = investigationData })
                end, citizenid)
            end
            -- END

            cb('ok')
        end)
    end

    local cData = data.cData
    if cData ~= nil then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getAppearance', function(appearance)
            -- if not appearance then cb('ok'); return end
            DataSkin = appearance.skin or {}
            local sex = tonumber(appearance.skin.sex) == 1 and `mp_male` or `mp_female`
            local clothesTable = appearance.clothes or {}
            if sex ~= nil then
                createAndShowPed(sex, DataSkin, clothesTable, cData.citizenid, true)
                -- LOAD PLAYER INVESTIGATION
                -- RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:getInvestigationData', function(investigationData)
                --     SendNUIMessage({ action = 'updateInvestigationData', data = investigationData })
                -- end, cData.citizenid)
                -- END
            else
                -- createAndShowPed(sex, DataSkin, clothesTable, cData.citizenid, true)
            end
        end, cData.citizenid)
    else
        local sex = ({`mp_male`, `mp_female`})[math.random(2)]
        createAndShowPed(sex, nil, nil, nil, false)
        -- SendNUIMessage({ action = 'clearInvestigationData' })
    end
    cb('ok')
end)

-- SELECT LIST
RegisterNUICallback('selectCharacter', function(data, cb)
    selectingChar = false
    local cData = data.cData
    if DataSkin ~= nil then
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData)
        StopCharacterSelectionCam()

        Wait(5000)
        TriggerServerEvent('rsg-appearance:server:LoadSkin')
        Wait(500)
        TriggerServerEvent('rsg-appearance:server:LoadClothes', 1)
    else
        DoScreenFadeOut(10)
        TriggerServerEvent('rsg-multicharacter:server:loadUserData', cData, true)
        StopCharacterSelectionCam()
    end

    cb('ok')
end)

-- LIST
RegisterNUICallback('setupCharacters', function(data, cb)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({ action = "setupCharacters", characters = result })
    end)
    cb('ok')
end)

-- RESTART TIME CYCLE
RegisterNUICallback('removeBlur', function(data, cb)
    SetTimecycleModifier('default')
    cb('ok')
end)

-- NEW PLAYER
RegisterNUICallback('createNewCharacter', function(data, cb)
    StopCharacterSelectionCam()
    DoScreenFadeOut(150)
    Wait(200)
    TriggerEvent("rsg-multicharacter:client:closeNUI")
    DoScreenFadeIn(1000)
    local playerPed = PlayerPedId()
    -- Control the appearance script
    CreateThread(function()
        Wait(500)
        DoScreenFadeIn(1000)
        FreezeEntityPosition(playerPed, false)
        TriggerEvent('rsg-appearance:client:OpenCreator', data)
    end)
    cb('ok')
end)

-- DEL PLAYER
RegisterNUICallback('removeCharacter', function(data, cb)
    cleanPed(charPed)
    TriggerServerEvent('rsg-multicharacter:server:deleteCharacter', data.citizenid)
    -- TriggerEvent('rsg-multicharacter:client:chooseChar')
    Wait(200)
    RSGCore.Functions.TriggerCallback("rsg-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({ action = "setupCharacters", characters = result })
    end)
    cb('ok')
end)

-- CLOSE
RegisterNUICallback('closeUI', function(data, cb)
    StopCharacterSelectionCam()
    cb('ok')
end)

-- TELEGRAM READ
RegisterNUICallback('markTelegramsRead', function(data, cb)
    if data.citizenid then
        RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:markTelegramsAsRead', function()
            cb('ok')
        end, data.citizenid)
    end
end)

-- OUTFIT CHANGE
-- RegisterNUICallback('markOutfitChange', function(data, cb)
--     if data.citizenid then
--         RSGCore.Functions.TriggerCallback('rsg-multicharacter:server:markOutfitAsChange', function()
--             TriggerServerEvent('rsg-appearance:server:LoadClothes', 1)
--             cb('ok')
--         end, data.citizenid)
--     end
-- end)

----------------------------------------------------------------
-- unstick player from start location
----------------------------------------------------------------
CreateThread(function()
    if LocalPlayer.state['isLoggedIn'] then
        exports['rsg-core']:createPrompt('unstick', Config.UnstickStart, Config.KeyUnstick, 'Set Me Free!', {
            type = 'client',
            event = 'rsg-multicharacter:client:unstick',
        })
    end
end)

RegisterNetEvent('rsg-multicharacter:client:unstick', function()
    local playerPed = PlayerPedId()
    SetEntityCoordsNoOffset(playerPed, Config.UnstickEnd, true, true, true)
    FreezeEntityPosition(playerPed, false)
end)