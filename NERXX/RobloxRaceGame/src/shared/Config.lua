-- Spiel-Konfiguration
local Config = {}

-- Race Settings
Config.MAX_PLAYERS = 8
Config.RACE_DURATION = 300 -- 5 Minuten
Config.LAPS_TO_WIN = 3
Config.COUNTDOWN_TIME = 10

-- Vehicle Settings
Config.VEHICLES = {
    {
        Name = "SportsCar",
        Speed = 50,
        Acceleration = 30,
        Handling = 80,
        Color = Color3.fromRGB(255, 0, 0)
    },
    {
        Name = "RaceCar", 
        Speed = 70,
        Acceleration = 50,
        Handling = 90,
        Color = Color3.fromRGB(0, 100, 255)
    },
    {
        Name = "Truck",
        Speed = 30,
        Acceleration = 20,
        Handling = 60,
        Color = Color3.fromRGB(0, 150, 0)
    },
    {
        Name = "Supercar",
        Speed = 90,
        Acceleration = 70,
        Handling = 85,
        Color = Color3.fromRGB(255, 255, 0)
    }
}

-- Bubble Effect Settings  
Config.BUBBLE_SETTINGS = {
    ParticleCount = 50,
    LifeTime = NumberRange.new(2, 4),
    Rate = 25,
    Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0)
    }),
    Colors = {
        Color3.fromRGB(100, 200, 255),
        Color3.fromRGB(150, 255, 200),
        Color3.fromRGB(255, 200, 255)
    }
}

-- Spawn Points (relative to workspace)
Config.SPAWN_POSITIONS = {
    Vector3.new(0, 5, 0),
    Vector3.new(10, 5, 0), 
    Vector3.new(20, 5, 0),
    Vector3.new(30, 5, 0),
    Vector3.new(0, 5, 10),
    Vector3.new(10, 5, 10),
    Vector3.new(20, 5, 10),
    Vector3.new(30, 5, 10)
}

-- Checkpoint Positions
Config.CHECKPOINTS = {
    Vector3.new(50, 5, 0),
    Vector3.new(100, 5, 50),
    Vector3.new(50, 5, 100),
    Vector3.new(0, 5, 50)
}

return Config
