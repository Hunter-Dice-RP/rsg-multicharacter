lib.locale()

-- To check if the player is logged and prompt unstick
CreateThread(function()
    if LocalPlayer.state['isLoggedIn'] then
        exports['rsg-core']:createPrompt('unstick', Config.UnstickStart, Config.KeyUnstick, locale('cl_unstick'), {
            type = 'client',
            event = 'rsg-multicharacter:client:unstick',
        })
    end
end)

-- To tp from start location
RegisterNetEvent('rsg-multicharacter:client:unstick', function()
    local PlayerPed = PlayerPedId()
    SetEntityCoordsNoOffset(PlayerPed, Config.UnstickEnd, true, true, true)
    FreezeEntityPosition(PlayerPed, false)
end)