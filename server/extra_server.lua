local QBCore = exports['qb-core']:GetCoreObject()
WorldData = Config.PresetWorlds or {}
GlobalState.currentBlackout = false

QBCore.Functions.CreateCallback('ParadoxWorld:server:GetDimmensionData', function(source, cb, WorldID)
    cb(WorldData)
end)

RegisterNetEvent('ParadoxWorld:server:setWorldData', function(worldid, weather, hours, minutes, blackout)
    WorldData[worldid] = {
        weather = weather,
        hours = hours,
        minutes = minutes,
        blackout = blackout,
    }
    TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
end)

RegisterCommand('blackout', function(source, args)
    if source == 0 or QBCore.Functions.HasPermission(source, Config.PermsGroup) then
        if args[1] ~= nil then
            local worldid = 0
            if source ~= 0 then
                worldid = GetPlayerRoutingBucket(source)
            end
            if worldid == 0 then
                GlobalState.currentBlackout = args[1]
                if source == 0 then 
                    print('[^5WORLD SYNC SYSTEM^0] Blackout enabled:', GlobalState.currentBlackout)
                else
                    TriggerClientEvent('QBCore:Notify', source, 'Blackout enabled: '..GlobalState.currentBlackout, 'error')
                end
            else
                if not WorldData[worldid] then WorldData[worldid] = {} end
                WorldData[worldid].blackout = args[1]
                TriggerClientEvent('ParadoxWorld:client:updateBucketData', -1, worldid, WorldData)
                TriggerClientEvent('QBCore:Notify', source, 'Blackout enabled: '..WorldData[worldid].blackout..' in dimmension: '..worldid, 'success')
            end
        else
            if source == 0 then 
                print('[^5WORLD SYNC SYSTEM^0] You must specify an argument (true or false)')
            else
                TriggerClientEvent('QBCore:Notify', source, 'You must specify an argument (true or false)', 'error')
            end
        end
    end
end, false)

RegisterNetEvent('ParadoxWorld:server:setBlackout', function(BlackoutState)
    if BlackoutState == nil then
        BlackoutState = not GlobalState.currentBlackout
    end
    BlackoutState = tostring(BlackoutState)
    GlobalState.currentBlackout = BlackoutState
    print('[^5WORLD SYNC SYSTEM^0] Blackout enabled:', BlackoutState)
end)