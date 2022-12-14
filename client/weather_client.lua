ServerWeather = GlobalState.currentWeather
SnowEnabled = false
WeatherOverideData = nil -- Allows fun stuff
OverideSnow = false

-- Some startup shit --
CreateThread(function ()
    RemoveIpl('alamo_ice') -- NVE addon resource
    SetWind(0.1)
    WaterOverrideSetStrength(0.5)
    Wait(5000)
    SetWeatherTypeNowPersist(ServerWeather.currentWeather)
    TriggerEvent('chat:addSuggestion', '/weather', 'Set the current weather', {{name = 'weather', help = 'Weather name or blank for list'}})
    TriggerEvent('chat:addSuggestion', '/freezeweather', 'Freeze current weather', {})
end)

-- loads/unloads the snow fx particles if needed
function UpdateWeatherParticles(enable)
	if enable == true then
		SnowEnabled = true
        -- GlobalState.snowPlowed is something you can set in another script!
        if not GlobalState.snowPlowed then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true) 
        end
		RequestScriptAudioBank('ICE_FOOTSTEPS', false) -- Icey footsteps
		RequestScriptAudioBank('SNOW_FOOTSTEPS', false) -- Snowy footsteps
		RequestNamedPtfxAsset('core_snow') -- Last part here is the blowing snow PTFX
		while not HasNamedPtfxAssetLoaded('core_snow') do Citizen.Wait(100) end
		UseParticleFxAssetNextCall('core_snow')
        ForceSnowPass(true)
        RequestIpl('alamo_ice') -- NVE addon resource
        WaterOverrideSetStrength(0.9)
	else
		SnowEnabled = false
		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
		ReleaseScriptAudioBank('ICE_FOOTSTEPS')
		ReleaseScriptAudioBank('SNOW_FOOTSTEPS')
        ForceSnowPass(false)
		if HasNamedPtfxAssetLoaded('core_snow') then RemoveNamedPtfxAsset('core_snow') end
        RemoveIpl('alamo_ice') -- NVE addon resource
        WaterOverrideSetStrength(0.5)
	end
    TriggerEvent('ParadoxWeather:client:snowToggled', enable)
end

function toboolean(str)
    local bool = false
    if tostring(str) == "true" then
        bool = true
    end
    return bool
end


AddStateBagChangeHandler('currentWeather' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
    if not value then return end
    Wait(250)
    ServerWeather = value
    if WeatherOverideData or WeatherBucket then return end
    SetRainLevel(-1.0)
    SetWeatherTypeOvertimePersist(ServerWeather.currentWeather, 60.0)

    if ServerWeather.WindDirection then
        SetWindDirection(math.rad(ServerWeather.WindDirection))
    end
    
    if ServerWeather.WindSpeed then
        SetWind(ServerWeather.WindSpeed / 5)
    end
    
    if (ServerWeather.HasSnow or OverideSnow) and not SnowEnabled then
        UpdateWeatherParticles(true)
    elseif not (ServerWeather.HasSnow or OverideSnow) and SnowEnabled then
        if SnowEnabled then
            UpdateWeatherParticles(false)
        end
    end

end)

AddStateBagChangeHandler('snowEnabled' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
    if not value then return end
    OverideSnow = toboolean(value)
    UpdateWeatherParticles(OverideSnow)
end)

-- GlobalState.snowPlowed is something you can set in another script!
AddStateBagChangeHandler('snowPlowed' --[[key filter]], nil --[[bag filter]], function(bagName, key, value, _unused, replicated)
    if not value then return end
    if value and SnowEnabled then
        print('SNOW PLOWED')
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false) 
    end
end)


RegisterNetEvent('ParadoxWeather:client:setOverrideData', function(data)
    if data then
        WeatherOverideData = data
        if WeatherOverideData == 'EXTRASUNNY' then
            UpdateWeatherParticles(false)
        end
        SetWeatherTypePersist(WeatherOverideData)
        SetWeatherTypeNow(WeatherOverideData)
        SetWeatherTypeNowPersist(WeatherOverideData)
    else -- RESET TO GLOBAL
        WeatherOverideData = nil
        ServerWeather = GlobalState.currentWeather
        SetRainLevel(-1.0)
        if ServerWeather.WindDirection then
            SetWindDirection(math.rad(ServerWeather.WindDirection))
        end
        
        if ServerWeather.WindSpeed then
            SetWind(ServerWeather.WindSpeed / 5)
        end
        
        if ServerWeather.HasSnow then
            UpdateWeatherParticles(true)
        else
            if SnowEnabled then
                UpdateWeatherParticles(false)
            end
        end
    
        SetWeatherTypeOvertimePersist(ServerWeather.currentWeather, 15)
    end
end)