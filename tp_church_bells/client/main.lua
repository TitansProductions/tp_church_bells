
---------------------------------------------------------------
--[[ Events ]]--
---------------------------------------------------------------

RegisterNetEvent("tp_church:client:request_time")
AddEventHandler("tp_church:client:request_time", function(data)
    local hour = GetClockHours()

    TriggerServerEvent("tp_church:server:update_time", hour)
end)

RegisterNetEvent("tp_church:client:play")
AddEventHandler("tp_church:client:play", function(locationIndex, distance)
    local LocationData = Config.Locations[locationIndex]

    local volume = LocationData.StartVolume - ((distance / LocationData.MaximumDistance) ^ 2)
    volume = math.max(0.1, volume)

    TriggerEvent('InteractSound_CL:PlayOnOne', LocationData.SoundSource, volume)
end)


