local QBCore = exports['qb-core']:GetCoreObject()
local NextWeather = {}
local FrozenWeather = false
local OverideSnow = false
local CurrentSystem = Config.StartupWeather
local inWeatherSequence = false
local BreakSequence = false
local WeatherChange = false
local OverrideWeather = false
local OverrideSet = false
GlobalState.snowPlowed = false

-- Functions --
function SendAlert(AlertType)
    print('[^3WEATHER SYSTEM^0] Sending NWS Alert: '..AlertType)
    if AlertType == 'WATCH' then
        TriggerEvent('qb-phone:server:sendNewMail', {
            sender = 'Los Santos NWS',
            subject = 'SEVERE THUNDERSTORM WATCH',
            message = 'The National Weather Service has issued a SEVERE THUNDERSTORM WATCH for the following areas: Paleto Bay, Sandy Shores, Los Santos, Grapeseed.',
            button = {}
        }, -1)
    elseif AlertType == 'WARNING' then
        TriggerEvent('qb-phone:server:sendNewMail', {
            sender = 'Los Santos NWS',
            subject = 'SEVERE THUNDERSTORM WARNING',
            message = 'The National Weather Service has issued a SEVERE THUNDERSTORM WARNING for the following areas: Paleto Bay, Sandy Shores, Los Santos, Grapeseed.',
            button = {}
        }, -1)
    elseif AlertType == 'WINTERWATCH' then
        TriggerEvent('qb-phone:server:sendNewMail', {
            sender = 'Los Santos NWS',
            subject = 'WINTER STORM WATCH',
            message = 'The National Weather Service has issued a WINTER STORM WATCH for the following areas: Paleto Bay, Sandy Shores, Los Santos, Grapeseed.',
            button = {}
        }, -1)
    elseif AlertType == 'WINTERWARNING' then
        TriggerEvent('qb-phone:server:sendNewMail', {
            sender = 'Los Santos NWS',
            subject = 'WINTER STORM WARNING',
            message = 'The National Weather Service has issued a WINTER STORM WARNING for the following areas: Paleto Bay, Sandy Shores, Los Santos, Grapeseed.',
            button = {}
        }, -1)
    end    
end

function StartCooldown()
    WeatherCooldown = true
    SetTimeout(Config.WeatherCycleTime * 60000, function()
        while inWeatherSequence or OverrideWeather do -- prevent changing weather on a sequence
            Wait(10000)
        end
        WeatherCooldown = false
    end)
end

function StartCooldownOverride()
    WeatherCooldown = true
    print('[^3WEATHER SYSTEM^0] Dynamic weather temp-disabled for weather: '.. OverrideWeather)
    SetTimeout((Config.WeatherCycleTime  * 1.5) * 60000, function() --slightly longer to ensure it outlasts any other threads
        while inWeatherSequence do -- prevent changing weather on a sequence
            Wait(10000)
        end
        print('[^3WEATHER SYSTEM^0] Dynamic weather re-enabled after override')
        OverrideWeather = false
        WeatherCooldown = false
        OverrideSet = false
    end)
end

function WeatherSequence(weathersequence, weathername)
    if not inWeatherSequence then
        CreateThread(function()
            local currentName = weathername
            inWeatherSequence = true
            for id,SequenceData in ipairs(weathersequence) do
                if CurrentSystem == currentName then 
                    SequenceData.currentWeather = SequenceData.Weather
                    GlobalState.currentWeather = SequenceData
                    print('[^3WEATHER SYSTEM^0] Next weather: '..SequenceData.currentWeather.. ' | System: '..CurrentSystem..' | Step: '..id..'/'..#weathersequence)
                    if SequenceData.Time then
                        Wait((SequenceData.Time) * 60000)
                    end
                end
            end
            inWeatherSequence = false
        end)
    end
end

CreateThread(function()
    GlobalState.currentWeather = {currentWeather = Config.StartupWeather}
    StartCooldown()
    while true do
        Wait(5000)
        if FrozenWeather then return end
        if not WeatherCooldown and not OverrideWeather then
            math.randomseed(GetGameTimer())
            local RandomNo = math.random(1, #Config.WeatherPool)
            local RandomWeather = Config.WeatherPool[RandomNo]
            NextWeather = Config.WeatherEvents[RandomWeather]
            CurrentSystem = RandomWeather
            GlobalState.snowPlowed = false
            TriggerEvent('prdx_smallmissions:server:resetPlowedNodes')
            if NextWeather.Alert then
                SendAlert(NextWeather.Alert)
            end

            if NextWeather.Sequence then
                WeatherSequence(NextWeather.Sequence, CurrentSystem)
            elseif NextWeather.Options then
                local LuckyWeatherOption = math.random(1, #NextWeather.Options)
                NextWeather.currentWeather = NextWeather.Options[LuckyWeatherOption]
                GlobalState.currentWeather = NextWeather
                print('[^3WEATHER SYSTEM^0] Next weather: '..NextWeather.currentWeather.. ' | System: '..CurrentSystem)
            else
                GlobalState.currentWeather = NextWeather
                print('[^3WEATHER SYSTEM^0] Next weather: '..CurrentSystem)
            end
            StartCooldown()
        elseif OverrideWeather and not OverrideSet then
            -- Break an ongoing sequence --
            NextWeather = {currentWeather = OverrideWeather}
            CurrentSystem = OverrideWeather

            if Config.WeatherEvents[CurrentSystem] then 
                NextWeather = Config.WeatherEvents[CurrentSystem]
                if NextWeather.Alert then
                    SendAlert(NextWeather.Alert)
                end

                if NextWeather.Sequence then
                    WeatherSequence(NextWeather.Sequence, CurrentSystem)
                elseif NextWeather.Options then
                    local LuckyWeatherOption = math.random(1, #NextWeather.Options)
                    NextWeather.currentWeather = NextWeather.Options[LuckyWeatherOption]
                    GlobalState.currentWeather = NextWeather
                    print('[^3WEATHER SYSTEM^0] Next weather: '..NextWeather.currentWeather.. ' | System: '..CurrentSystem)
                else
                    GlobalState.currentWeather = NextWeather
                    print('[^3WEATHER SYSTEM^0] Next weather: '..CurrentSystem)
                end
            end
            OverrideSet = true
            StartCooldownOverride()
        end
    end
end)

-- COMMANDS --
RegisterCommand('weather', function(source, args)
    local src = source
    if source == 0 or QBCore.Functions.HasPermission(src, tostring(Config.PermsGroup)) or QBCore.Shared.DevMode then
        if args[1] then
            local ChosenWeather = args[1]:upper()
            local worldid = 0
            if src ~= 0 then
                worldid = GetPlayerRoutingBucket(src)
            end
            BreakSequence = true
            if Config.WeatherEvents[ChosenWeather] then
                if worldid ~= 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Sequences are not supported in dimmensions! | Dimmension: '..worldid, 'error')
                    return
                end
                OverrideWeather = ChosenWeather                
            else
                if worldid == 0 then
                    local ValidWeather = false
                    for k,WeatherName in pairs(Config.ValidWeathers) do
                        if WeatherName == ChosenWeather then
                            ValidWeather = true
                            break
                        end
                    end
                    if ValidWeather then
                        if src == 0 then
                            print('[^3WEATHER SYSTEM^0] Overriden weather to: '..ChosenWeather)
                        else
                            TriggerClientEvent('QBCore:Notify', src, 'Set weather to: '.. ChosenWeather, 'success')
                        end
                        OverrideWeather = ChosenWeather                
                    else
                        if src == 0 then 
                            print('[^3WEATHER SYSTEM^0] Valid Weathers: '..Config.WeatherStr)
                        else
                            TriggerClientEvent('QBCore:Notify', src, 'Valid Weathers: '..Config.WeatherStr, 'error')
                        end
                    end
                else
                    if not WorldData[worldid] then WorldData[worldid] = {} end
                    WorldData[worldid].weather = ChosenWeather
                    TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
                    TriggerClientEvent('QBCore:Notify', src, 'Set weather to: '..ChosenWeather..' | Dimmension: '..worldid, 'success')

                end
            end
        else
            if src == 0 then 
                print('[^3WEATHER SYSTEM^0] Valid Weathers: '..Config.WeatherStr)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Current weather forcast: '.. CurrentSystem, 'success')
                TriggerClientEvent('QBCore:Notify', src, 'Valid Weathers: '..Config.WeatherStr, 'error')
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Current weather forcast: '.. CurrentSystem, 'success')
    end
end, false)

RegisterCommand('freezeweather', function(source)
    if source == 0 or QBCore.Functions.HasPermission(source, tostring(Config.PermsGroup)) or QBCore.Shared.DevMode then
        FrozenWeather = not FrozenWeather -- Temp freeze out the loop until we complete whatever we requested first!
        if source == 0 then 
            print('[^3WEATHER SYSTEM^0] Dynamic Weather:', FrozenWeather)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Dynamic Weather: '..FrozenWeather, 'error')
        end
    end
end, false)

RegisterCommand('skipweather', function(source)
    if source == 0 or QBCore.Functions.HasPermission(source, tostring(Config.PermsGroup)) or QBCore.Shared.DevMode then
        if inWeatherSequence then
            CurrentSystem = false
            if source == 0 then 
                print('[^3WEATHER SYSTEM^0] Skipping weather system')
            else
                TriggerClientEvent('QBCore:Notify', source, 'Skipping weather system', 'error')
            end
        else
            if source == 0 then 
                print('[^3WEATHER SYSTEM^0] Only available during a sequence')
            else
                TriggerClientEvent('QBCore:Notify', source, 'Only available during a sequence', 'error')
            end
        end
    end
end, false)

RegisterCommand('enablesnow', function(source, args)
    if source == 0 or QBCore.Functions.HasPermission(source, tostring(Config.PermsGroup) or QBCore.Shared.DevMode) and args then
        if args[1] then
            local worldid = 0
            if source ~= 0 then
                worldid = GetPlayerRoutingBucket(source)
            end
            if worldid == 0 then
                GlobalState.snowEnabled = args[1]
                OverideSnow = args[1]
                if source == 0 then 
                    print('[^3WEATHER SYSTEM^0] Snow enabled:', GlobalState.snowEnabled)
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Snow enabled: '..GlobalState.snowEnabled, 'success')
                end
            else
                if worldid ~= 0 then
                    if not WorldData[worldid] then WorldData[worldid] = {} end
                    WorldData[worldid].HasSnow = args[1]
                    TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
                    TriggerClientEvent('QBCore:Notify', source, 'Snow enabled: '..tostring(WorldData[worldid].HasSnow)..' in dimmension: '..worldid, 'success')
                end
            end
        else
            if source == 0 then 
                print('[^3WEATHER SYSTEM^0] Argument needed (true or false)')
            else
                TriggerClientEvent('QBCore:Notify', source, 'Argument needed (true or false)', 'error')
            end
        end
    end
end, false)
