QBCore = exports['qb-core']:GetCoreObject()
ServerTime = GlobalState.currentTime
TimeOverideData = nil -- Allows fun stuff

-- Some startup shit --
CreateThread(function ()
    NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, ServerTime.seconds)
    NetworkOverrideClockMillisecondsPerGameMinute(Config.TimeScaler) -- Double time
    TriggerEvent('chat:addSuggestion', '/time', 'Set the current time', {{name = 'hour', help = 'HH'}, {name = 'minute', help = 'mm'}})
    TriggerEvent('chat:addSuggestion', '/freezetime', 'Sets time and freezes it', {{name = 'hour', help = 'HH'}, {name = 'minute', help = 'mm'}})
end)

AddStateBagChangeHandler('currentTime' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated) -- Keep time updated
    if not value then return end
    Wait(150)
    ServerTime = GlobalState.currentTime -- Update time
    if TimeOverideData or TimeBucket then return end -- Break out so we don't override

    -- Start Time Sync --
    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local TimeVariance = math.abs(minutes - ServerTime.minutes)
   -- print('Time variance:', TimeVariance)
    if TimeVariance > 11 and TimeVariance <= 60 then -- Check for end of hour so a slight error doesnt become huge because of a hour tickover
        if math.abs(hours - ServerTime.hours) <= 1 then
            local debugBefore = TimeVariance
            TimeVariance = math.abs(minutes - ServerTime.minutes) - 60
            --print('New time variance:', TimeVariance, 'Old time variance:', debugBefore)
        end
    end
    --print('Update', TimeVariance, minutes - ServerTime.minutes, minutes, ServerTime.minutes)
    if hours ~= ServerTime.hours and math.abs(hours - ServerTime.hours) > 1 then 
        NetworkOverrideClockMillisecondsPerGameMinute(ServerTime.TimeScaler)
        NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, seconds)
    elseif TimeVariance >= 10 then -- BIG CHANGE
        NetworkOverrideClockMillisecondsPerGameMinute(ServerTime.TimeScaler)
        NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, seconds)
    -- This should basically dynamically redo the time-per-minute (we don't care) to variance slightly to catch up to/slow down to the current time
    -- This will hopefully find an equilibrium for all people based on their current FPS.
    -- Should prevent any "Stuttery Sky"
    elseif TimeVariance >= 3 and TimeVariance < 10 then
        if minutes - ServerTime.minutes >= 3 then -- Ahead
            local Scaler = (ServerTime.TimeScaler) + ((TimeVariance * 1000) / (ServerTime.TimeScaler / 100))
            NetworkOverrideClockMillisecondsPerGameMinute(math.ceil(Scaler))
            --NetworkOverrideClockTime(hours, minutes, seconds)
            --print('Current Time Scaler Ahead:', math.ceil(Scaler), hours, minutes, seconds, GetMillisecondsPerGameMinute())
        elseif minutes - ServerTime.minutes <= -3 then -- Behind
            local Scaler = (ServerTime.TimeScaler) - ((TimeVariance * 1000) / (ServerTime.TimeScaler / 100))
            NetworkOverrideClockMillisecondsPerGameMinute(math.ceil(Scaler))
           -- NetworkOverrideClockTime(hours, minutes, seconds)
            --print('Current Time Scaler Behind:', math.ceil(Scaler), hours, minutes, seconds, GetMillisecondsPerGameMinute())
        end
    end
end)

RegisterNetEvent('ParadoxTime:client:setOverrideData', function(data)
    if data then
        TimeOverideData = data
        local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
        if hours ~= TimeOverideData.hours or math.abs(minutes - TimeOverideData.minutes) >= 2 then -- Buffer for error of margin
            NetworkOverrideClockTime(TimeOverideData.hours, TimeOverideData.minutes, TimeOverideData.seconds)
        end
        NetworkOverrideClockMillisecondsPerGameMinute(TimeOverideData.TimeScaler)
    else -- RESET TO GLOBAL
        TimeOverideData = nil
        ServerTime = GlobalState.currentTime -- Update time JIC
        local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
        if hours ~= ServerTime.hours or math.abs(minutes - ServerTime.minutes) >= 2 then -- Buffer for error of margin
            NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, seconds)
        end
        NetworkOverrideClockMillisecondsPerGameMinute(ServerTime.TimeScaler)
    end
end)
