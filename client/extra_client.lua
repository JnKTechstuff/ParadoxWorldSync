TimeBucket, WeatherBucket, BlackoutBucket = false, false, false
BlackoutOveride = false
CurrentWorldData = {}

function UpdateBucket()
    if not CurrentWorldData then return end
    SetArtificialLightsState(false)
    SetArtificialLightsStateAffectsVehicles(false)
    if CurrentWorldData[LocalPlayer.state.bucket] then
        local BucketData = CurrentWorldData[LocalPlayer.state.bucket]
        if not TimeOverideData then
            if BucketData.hours then
                TimeBucket = true -- Activate bucket bypass
                NetworkOverrideClockTime(BucketData.hours, BucketData.minutes, 0)
                NetworkOverrideClockMillisecondsPerGameMinute(999999999)       
            else
                NetworkOverrideClockMillisecondsPerGameMinute(ServerTime.TimeScaler)
                NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, 0)
                TimeBucket = false
            end  
        end  
        
        if BucketData.blackout then
            BlackoutBucket = true
            SetArtificialLightsState(toboolean(BucketData.blackout))
            SetArtificialLightsStateAffectsVehicles(false)
        else
            SetArtificialLightsState(toboolean(GlobalState.currentBlackout) or false)
            SetArtificialLightsStateAffectsVehicles(false)
            BlackoutBucket = false
        end
        if toboolean(BucketData.HasSnow) then
            UpdateWeatherParticles(true)
        else
            UpdateWeatherParticles(false)
        end    
        if not WeatherOverideData then
            if BucketData.weather then
                WeatherBucket = true
                SetWeatherTypeNowPersist(BucketData.weather)
            else
                SetWeatherTypeNowPersist(ServerWeather.currentWeather)
                WeatherBucket = false
            end 
        end
    end
end

AddStateBagChangeHandler('bucket' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
    if not value or not bagName then return end
    local plyId = tonumber(bagName:gsub('player:', ''), 10)
    if plyId ~= GetPlayerServerId(PlayerId()) then return end
    value = tonumber(value)
    if value == 0 then
        -- UNSET OVERRIDES --
        TimeBucket = false
        WeatherBucket = false
        BlackoutBucket = false
        NetworkOverrideClockMillisecondsPerGameMinute(ServerTime.TimeScaler)
        NetworkOverrideClockTime(ServerTime.hours, ServerTime.minutes, 0)
        SetWeatherTypeNowPersist(ServerWeather.currentWeather)
        SetArtificialLightsState(false)
        SetArtificialLightsStateAffectsVehicles(false)
        if GlobalState.currentBlackout then
            SetArtificialLightsState(toboolean(GlobalState.currentBlackout))
        end
        if (ServerWeather.HasSnow or OverideSnow) then
            UpdateWeatherParticles(true)
        else
            UpdateWeatherParticles(false)
        end
    elseif not WeatherOverideData and not TimeOverideData then
        QBCore.Functions.TriggerCallback("ParadoxWorld:server:GetDimmensionData", function(WorldData)
            if WorldData then
                CurrentWorldData = WorldData
            end
            UpdateBucket()
        end, value)
    end
end)

RegisterNetEvent('ParadoxWorld:client:updateBucketData', function(bucket, data)
    if not bucket or not data then return end
    local currentBucket = LocalPlayer.state.bucket
    if currentBucket and currentBucket == bucket then
        CurrentWorldData = data
        UpdateBucket()
    end
end)

AddStateBagChangeHandler('currentBlackout' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
    if value == nil or BlackoutOveride or BlackoutBucket then return end
    -- Can do cooler shut off sequence if we want in here --
    SetArtificialLightsState(toboolean(value))
    SetArtificialLightsStateAffectsVehicles(false)
end)