
local Locations = {}

local LoadedResults = false

local CurrentHour   = 0
local RunningTasks  = false

---------------------------------------------------------------
--[[ Local Functions ]]--
---------------------------------------------------------------

local IsTime = function(locationIndex, currentTime) 

    for _, hour in pairs (Config.Locations[locationIndex].StartHours) do 

        if hour == currentTime then 
            return true
        end

    end

    return false

end

---------------------------------------------------------------
--[[ Events ]]--
---------------------------------------------------------------

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end

    Locations = Config.Locations

    for name, location in pairs (Locations) do 

        location.playing         = 0
        location.duration        = 0
        location.repeat_duration = 0
        location.playing_hour    = -1

    end

    LoadedResults = true
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
  
    Locations = nil

end)

RegisterServerEvent("tp_church:server:update_time")
AddEventHandler("tp_church:server:update_time", function(time)
    CurrentHour = time

    if Config.Debug then 
        print('Current Time: ', time)
    end

end)

---------------------------------------------------------------
--[[ General Events ]]--
---------------------------------------------------------------

Citizen.CreateThread(function()
    
    while true do 

        Wait(8000)

        if not LoadedResults then goto continue end

        local players = GetPlayers()

        if #players > 0 then

            local randomIndex = math.random(1, #players)
            local randomPlayer = tonumber(players[randomIndex])

            if randomPlayer then
                TriggerClientEvent("tp_church:client:request_time", randomPlayer)

                Wait(2000)
            end

        end

        for name, location in pairs (Locations) do 

            if location.playing == 0 and location.playing_hour ~= CurrentHour then 

                if IsTime(name, CurrentHour) then

                    location.playing = 1
                    location.playing_hour = CurrentHour

                    TriggerEvent('tp_church:server:tasks')
                    Wait(500) -- mandatory wait

                end

            end

        end

        ::continue::

    end

end)

AddEventHandler('tp_church:server:tasks', function()

    if RunningTasks then 
        return 
    end

    RunningTasks = true
    
    Citizen.CreateThread(function()
        while true do 

            Wait(1000)
    
            if LoadedResults then
                
                local active = false
    
                for name, location in pairs (Locations) do 
                
                    if location.playing == 1 then 
                        
                        active = true
    
                        location.repeat_duration = location.repeat_duration + 1
                        location.duration        = location.duration + 1
    
                        if location.repeat_duration >= location.RepeatEvery then 
            
                            location.repeat_duration = 0
    
                            if Config.Debug then 
                                print('Church: ' .. name .. ' is ringing bells.')
                            end
            
                            local players = GetPlayers()
    
                            for _, playerId in ipairs(players) do
    
                                playerId = tonumber(playerId)
    
                                local playerCoords = GetEntityCoords(GetPlayerPed(playerId)) -- Get the player's coordinates
        
                                -- Calculate the distance between the player and the center
                                local distance = #(location.Coords - playerCoords)
    
                                if distance <= location.MaximumDistance then 
                                    TriggerClientEvent("tp_church:client:play", playerId, name, distance)
                                end
    
                            end
    
                        end
    
                        if location.duration >= (location.TimeLast * 60) then 
    
                            location.duration        = 0
                            location.repeat_duration = 0
                            location.playing         = 0
       
                            if Config.Debug then 
                                print('Church: ' .. name .. ' has been stopped, reached stop time.')
                            end
    
                        end
            
                    end
            
        
                end
    
                -- Stop thread if no locations are active.
                if not active then
                    RunningTasks = false
                    break
                end
    
            end
    
        end

    end)


end)
