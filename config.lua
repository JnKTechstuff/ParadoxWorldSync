Config = Config or {}
Config.PermsGroup = 'god'

-- Preset Dimmensions --
Config.PresetWorlds = {
    [666666] = { -- HALLOWEEN UNDERWORLD
        weather = 'HALLOWEEN',
        hours = 23,
        minutes = 59,
        blackout = true,
    },
    [1225] = { -- Christmas Land
        weather = 'SNOW',
        HasSnow = true, -- Optional
    }
}

--- TIME OPTIONS ---
Config.TimeScaler = 4000 -- MS per minute in GTA time (2000ms is normal for a 48 minute day)
Config.StartupTime = {
    hours = 16, 
    minutes = 00,
    seconds = 00
}

--- Weather Options ---
Config.WeatherPool = {} -- Leave blank (Probability Pool)
Config.WeatherStr = '' -- leave blank
Config.StartupWeather = 'CLOUDS'
Config.WeatherCycleTime = 24 -- minutes (MUST BE LONGER THAN THE LONGEST SEQUENCE)
Config.WeatherEvents = {
    ['SUNNY'] = {
        Probability = 5,
        WindSpeed = 0.0,
        WindDirection = 0.0, -- Storms come from the south 
        Options = {'EXTRASUNNY', 'CLEAR', 'SMOG'},
    },
    ['CLOUDY'] = {
        Probability = 10,
        WindSpeed = 0.5,
        WindDirection = 0.0, -- Storms come from the south 
        Options = {'OVERCAST', 'CLOUDS', 'SNOWLIGHT'},
    },
    ['SNOWING'] = {
        Probability = 3,
        WindDirection = 180.0, -- Storms come from the south 
        Alert = 'WINTERWATCH',
        Sequence = {
            [1] = {
                Weather = 'OVERCAST',
                Time = 10, -- Minutes
                WindSpeed = 0.0,
            },
            [2] = {
                Weather = 'SNOWLIGHT',
                Time = 10, -- Minutes
                WindSpeed = 0.1,
            },
            [3] = {
                Weather = 'SNOW',
                Time = 5, -- Minutes
                WindSpeed = 0.3,
            },
            [4] = {
                Weather = 'SNOWLIGHT',
                Time = 10, -- Minutes
                WindSpeed = 0.1,
            },
            [5] = {
                Weather = 'OVERCAST',
                Time = 5, -- Minutes
                WindSpeed = 0.0,
            },
            [6] = {
                Weather = 'CLOUDS',
                Time = 5, -- Minutes
                WindSpeed = 0.0,
            },
        },
    },
    ['SNOWSTORM'] = {
        Probability = 2,
        WindDirection = 120.0, -- Storms come from the south 
        Alert = 'WINTERWARNING',
        Sequence = {
            [1] = {
                Weather = 'OVERCAST',
                Time = 10, -- Minutes
                WindSpeed = 0.5,
            },
            [2] = {
                Weather = 'SNOWLIGHT',
                Time = 5, -- Minutes
                WindSpeed = 1.0,
            },
            [3] = {
                Weather = 'SNOW',
                Time = 5, -- Minutes
                WindSpeed = 1.0,
            },
            [4] = {
                Weather = 'SNOW',
                Time = 10, -- Minutes
                WindSpeed = 1.0,
                HasSnow = true,
            },
            [5] = {
                Weather = 'BLIZZARD',
                Time = 14, -- Minutes
                WindSpeed = 3.0,
                HasSnow = true,
            },
            [6] = {
                Weather = 'SNOW',
                Time = 15, -- Minutes
                WindSpeed = 2.0,
                HasSnow = true,
            },
            [7] = {
                Weather = 'SNOWLIGHT',
                Time = 20, -- Minutes
                WindSpeed = 1.0,
                HasSnow = true,
            },
            [8] = {
                Weather = 'OVERCAST',
                WindSpeed = 0.5,
                Time = 15, -- Minutes
                HasSnow = true,
            },
            [9] = {
                Weather = 'CLOUDS',
                WindSpeed = 0.5,
                Time = 15, -- Minutes
                HasSnow = true,
            },
            [10] = {
                Weather = 'CLEAR',
                WindSpeed = 0.5,
                Time = 15, -- Minutes
                HasSnow = true,
            },
            [11] = {
                Weather = 'EXTRASUNNY',
                WindSpeed = 0.5,
            },
        },
    },
    -- NON AUTO CHOOSING --
    -- Removing Probability removes the auto-choosing --
    ['RAINSHOWER'] = {
        WindDirection = 240.0, -- Storms come from the south 
        Sequence = {
            [1] = {
                Weather = 'CLOUDS',
                Time = 2, -- Minutes
                WindSpeed = 0.5,
            },
            [2] = {
                Weather = 'OVERCAST',
                Time = 8, -- Minutes
                WindSpeed = 1.0,
            },
            [3] = {
                Weather = 'RAIN',
                Time = 10, -- Minutes
                WindSpeed = 2.0,
            },
            [4] = {
                Weather = 'CLEARING',
                Time = 4, -- Minutes
                WindSpeed = 1.0,
            },
            [5] = {
                Weather = 'CLOUDS',
                Time = 10, -- Minutes
                WindSpeed = 0.5,
            },
            [6] = {
                Weather = 'EXTRASUNNY',
                WindSpeed = 0.0,
            },
        },
    },
    ['RAINSTORM'] = {
        WindDirection = 280.0, -- Storms come from the south 
        Sequence = {
            [1] = {
                Weather = 'CLOUDS',
                Time = 4, -- Minutes
                WindSpeed = 0.5,
            },
            [2] = {
                Weather = 'OVERCAST',
                Time = 8, -- Minutes
                WindSpeed = 1.0,
            },
            [3] = {
                Weather = 'RAIN',
                Time = 10, -- Minutes
                WindSpeed = 3.5,
            },
            [4] = {
                Weather = 'CLEARING',
                Time = 6, -- Minutes
                WindSpeed = 1.5,
            },
            [5] = {
                Weather = 'CLOUDS',
                WindSpeed = 0.5,
            },
        },
    },
    ['SMALLSTORM'] = {
        WindDirection = 120.0, -- Storms come from the south 
        Alert = 'WATCH',
        Sequence = {
            [1] = {
                Weather = 'CLOUDS',
                Time = 4, -- Minutes
                WindSpeed = 0.5,
            },
            [2] = {
                Weather = 'RAIN',
                Time = 4, -- Minutes
                WindSpeed = 1.0,
            },
            [3] = {
                Weather = 'THUNDER',
                Time = 4, -- Minutes
                WindSpeed = 3.0,
            },
            [4] = {
                Weather = 'RAIN',
                Time = 10, -- Minutes
                WindSpeed = 2.0,
            },
            [5] = {
                Weather = 'CLEARING',
                Time = 6, -- Minutes
                WindSpeed = 1.0,
            },
            [6] = {
                Weather = 'EXTRASUNNY',
                WindSpeed = 0.5,
            },
        },
    },
    ['BIGSTORM'] = {
        WindDirection = 180.0, -- Storms come from the south 
        Alert = 'WARNING',
        Sequence = {
            [1] = {
                Weather = 'OVERCAST',
                Time = 2, -- Minutes
                WindSpeed = 4.0,
            },
            [2] = {
                Weather = 'RAIN',
                Time = 4, -- Minutes
                WindSpeed = 8.0,
            },
            [3] = {
                Weather = 'THUNDER',
                Time = 7, -- Minutes
                WindSpeed = 12.0,
            },
            [4] = {
                Weather = 'RAIN',
                Time = 2, -- Minutes
                WindSpeed = 12.0,
            },
            [5] = {
                Weather = 'THUNDER',
                Time = 2, -- Minutes
                WindSpeed = 12.0,
            },
            [6] = {
                Weather = 'CLEARING',
                Time = 3, -- Minutes
                WindSpeed = 3.0,
            },
            [7] = {
                Weather = 'EXTRASUNNY',
                WindSpeed = 0.0,
            },
        },
    },    
}

Config.ValidWeathers = {
    'BLIZZARD',
    'CLEAR',
    'CLEARING',
    'CLOUDS',
    'EXTRASUNNY',
    'FOGGY',
    'HALLOWEEN',
    'NEUTRAL',
    'OVERCAST',
    'RAIN',
    'SMOG',
    'SNOW',
    'SNOWLIGHT',
    'THUNDER',
    'XMAS',
}

CreateThread(function () -- Generate Probability Pool
    for WeatherSystem,Data in pairs(Config.WeatherEvents) do
        if Data.Probability then 
            for i=1, Data.Probability do
                Config.WeatherPool[#Config.WeatherPool+1] = WeatherSystem
            end
        end
    end

    for WeatherSystem,Data in pairs(Config.WeatherEvents) do
        Config.WeatherStr = WeatherSystem..', '..Config.WeatherStr
    end
end)