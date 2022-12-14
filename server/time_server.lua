local QBCore = exports['qb-core']:GetCoreObject()
local freezeTime = false
local baseTime = nil
local currentHour, currentMinute, currentSecond = Config.StartupTime.hours, Config.StartupTime.minutes, Config.StartupTime.seconds
local timeOffset = 0
local CurrentScaler = Config.TimeScaler

-- Functions --
function ShiftToMinute(minute)
    timeOffset = timeOffset - ( ( (baseTime+timeOffset) % 60 ) - minute )
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ( ( ((baseTime+timeOffset)/60) % 24 ) - hour ) * 60
end

function OverideGlobalClock(hours, minutes)
    ShiftToHour(hours)
    ShiftToMinute(minutes)
    currentHour = math.floor(((baseTime+timeOffset)/60)%24)
    currentMinute = math.floor((baseTime+timeOffset)%60)
end

-- Threads --
CreateThread(function()
    local startUp = {currentTime = Config.StartupTime}
    baseTime = os.time(os.date("!*t"))/(Config.TimeScaler/1000) + 360
    OverideGlobalClock(startUp.currentTime.hours, startUp.currentTime.minutes)
    GlobalState.currentTime = startUp
    local counter = 0
    while true do
        if not freezeTime then
            counter = counter - 1
            local newBaseTime = os.time(os.date("!*t"))/(Config.TimeScaler/1000) + 360
            baseTime = newBaseTime
            currentHour = math.floor(((baseTime+timeOffset)/60)%24)
            currentMinute = math.floor((baseTime+timeOffset)%60)
            if counter <= 0 then
                counter = 60        
                GlobalState.currentTime = {hours = currentHour, minutes = currentMinute, seconds = currentSecond, TimeScaler = CurrentScaler}
                print('[^2TIME SYSTEM^0] Update time to '..currentHour..':'..currentMinute)
            end
        end
        Wait(4000)
    end
end)

-- COMMANDS --
RegisterCommand('time', function(source, args)
    if source == 0 or QBCore.Functions.HasPermission(source, Config.PermsGroup) then
        local src = source
        local newHours, newMinutes = tonumber(args[1]), tonumber(args[2]) or 0
        local worldid = 0
        if src ~= 0 then
            worldid = GetPlayerRoutingBucket(src)
        end
        if newHours then
            if worldid ~= 0 then
                if not WorldData[worldid] then WorldData[worldid] = {} end
                WorldData[worldid].hours = newHours
                WorldData[worldid].minutes = newMinutes
                TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
                TriggerClientEvent('QBCore:Notify', src, 'Time set to '..WorldData[worldid].hours..':'..WorldData[worldid].minutes..' in dimmension: '..worldid, 'success')
            else
                OverideGlobalClock(newHours, newMinutes or 0)
                GlobalState.currentTime = {hours = currentHour, minutes = currentMinute, seconds = currentSecond, TimeScaler = CurrentScaler} -- force instant sync
                if src == 0 then 
                    print('[^2TIME SYSTEM^0] Time set to '..currentHour..':'..currentMinute)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Time set to '..currentHour..':'..currentMinute, 'success')
                end
            end
        else
            if worldid ~= 0 then
                if not WorldData[worldid] then WorldData[worldid] = {} end
                WorldData[worldid].hours = nil
                WorldData[worldid].minutes = nil
                TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
                TriggerClientEvent('QBCore:Notify', src, 'Time set to '..currentHour..':'..currentMinute..' in dimmension: '..worldid, 'success')
            else
                if src == 0 then 
                    print('[^2TIME SYSTEM^0] You must specify at least an hour!')
                else
                    TriggerClientEvent('QBCore:Notify', src, 'You must specify at least an hour!', 'error')
                end
            end
        end
    end
end, false)

RegisterCommand('freezetime', function(source, args)
    if source == 0 or QBCore.Functions.HasPermission(source, Config.PermsGroup) then
        if tonumber(args[1]) or not freezeTime then
            if tonumber(args[1]) then
                OverideGlobalClock(args[1], args[2] or 0)
            else
                freezeTime = true
                CurrentScaler = 999999999
            end
            if source == 0 then 
                print('[^2TIME SYSTEM^0] Frozen time to '..currentHour..':'..currentMinute)
            else
                TriggerClientEvent('QBCore:Notify', source, 'Frozen time to '..currentHour..':'..currentMinute, 'success')
            end
            GlobalState.currentTime = {hours = currentHour, minutes = currentMinute, seconds = currentSecond, TimeScaler = 999999999} -- force instant sync
            TriggerClientEvent('ParadoxTime:client:setOverrideData', -1, GlobalState.currentTime)
        else
            freezeTime = false
            CurrentScaler = Config.TimeScaler
            if source == 0 then 
                print('[^2TIME SYSTEM^0] Time unfrozen')
            else
                TriggerClientEvent('QBCore:Notify', source, 'Time unfrozen', 'success')
            end
        end
        GlobalState.currentTime = {hours = currentHour, minutes = currentMinute, seconds = currentSecond, TimeScaler = CurrentScaler} -- force instant sync
        TriggerClientEvent('ParadoxTime:client:setOverrideData', -1, GlobalState.currentTime)
    end
end, false)