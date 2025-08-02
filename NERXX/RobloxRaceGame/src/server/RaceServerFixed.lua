-- Server-seitiges Hauptscript für das Rennspiel
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Warte auf Events und Config
repeat wait() until ReplicatedStorage:FindFirstChild("Events")
repeat wait() until ReplicatedStorage:FindFirstChild("Config")
local Config = require(ReplicatedStorage.Config)
local Events = ReplicatedStorage.Events

-- Game State
local GameState = {
    players = {},
    race_active = false,
    race_start_time = 0,
    leaderboard = {}
}

-- Erstelle benötigte Ordner
if not workspace:FindFirstChild("Vehicles") then
    local vehiclesFolder = Instance.new("Folder")
    vehiclesFolder.Name = "Vehicles"
    vehiclesFolder.Parent = workspace
end

if not workspace:FindFirstChild("Checkpoints") then
    local checkpointsFolder = Instance.new("Folder")
    checkpointsFolder.Name = "Checkpoints" 
    checkpointsFolder.Parent = workspace
    
    -- Erstelle Checkpoint-Parts
    for i, pos in ipairs(Config.CHECKPOINTS) do
        local checkpoint = Instance.new("Part")
        checkpoint.Name = "Checkpoint" .. i
        checkpoint.Size = Vector3.new(20, 10, 2)
        checkpoint.Position = pos
        checkpoint.Anchored = true
        checkpoint.CanCollide = false
        checkpoint.Material = Enum.Material.ForceField
        checkpoint.Color = Color3.fromRGB(0, 255, 0)
        checkpoint.Transparency = 0.5
        checkpoint.Parent = checkpointsFolder
    end
end

-- Forward declarations
local updateLeaderboard, createVehicle, startRace, endRace, resetRace

-- Player Management
local function setupPlayer(player)
    GameState.players[player.UserId] = {
        player = player,
        vehicle = nil,
        current_lap = 0,
        checkpoints_passed = {},
        race_time = 0,
        position = 0,
        bubbles_active = true
    }
    
    -- Aktualisiere Leaderboard
    updateLeaderboard()
    
    print(player.Name .. " joined the race!")
end

local function removePlayer(player)
    if GameState.players[player.UserId] then
        -- Entferne Fahrzeug falls vorhanden
        local playerData = GameState.players[player.UserId]
        if playerData.vehicle then
            playerData.vehicle:Destroy()
        end
        
        GameState.players[player.UserId] = nil
        updateLeaderboard()
        
        print(player.Name .. " left the race!")
    end
end

-- Leaderboard System
function updateLeaderboard()
    local leaderboard = {}
    
    for userId, data in pairs(GameState.players) do
        table.insert(leaderboard, {
            name = data.player.Name,
            lap = data.current_lap,
            time = data.race_time,
            position = data.position
        })
    end
    
    -- Sortiere nach Runden und Zeit
    table.sort(leaderboard, function(a, b)
        if a.lap == b.lap then
            return a.time < b.time
        end
        return a.lap > b.lap
    end)
    
    -- Aktualisiere Positionen
    for i, entry in ipairs(leaderboard) do
        entry.position = i
        for userId, data in pairs(GameState.players) do
            if data.player.Name == entry.name then
                data.position = i
                break
            end
        end
    end
    
    GameState.leaderboard = leaderboard
    Events.UpdateLeaderboard:FireAllClients(leaderboard)
end

-- Vehicle System
function createVehicle(player, vehicleType)
    local vehicleConfig = Config.VEHICLES[vehicleType] or Config.VEHICLES[1]
    local spawnPos = Config.SPAWN_POSITIONS[math.min(#Config.SPAWN_POSITIONS, player.UserId % #Config.SPAWN_POSITIONS + 1)]
    
    -- Erstelle Fahrzeug-Model
    local vehicle = Instance.new("Model")
    vehicle.Name = player.Name .. "'s " .. vehicleConfig.Name
    vehicle.Parent = workspace:FindFirstChild("Vehicles")
    
    -- Hauptteil des Autos
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(6, 2, 12)
    body.Material = Enum.Material.Neon
    body.Color = vehicleConfig.Color
    body.Position = spawnPos
    body.Parent = vehicle
    
    -- Seat für den Spieler
    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriverSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = spawnPos + Vector3.new(0, 1.5, 2)
    seat.MaxSpeed = vehicleConfig.Speed
    seat.Torque = vehicleConfig.Acceleration * 1000
    seat.TurnSpeed = (vehicleConfig.Handling / 100) * 50
    seat.Parent = vehicle
    
    -- Verbinde Seat mit Body
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = body
    weld.Part1 = seat
    weld.Parent = body
    
    -- Räder
    for i = 1, 4 do
        local wheel = Instance.new("Part")
        wheel.Name = "Wheel" .. i
        wheel.Size = Vector3.new(2, 4, 4)
        wheel.Shape = Enum.PartType.Cylinder
        wheel.Material = Enum.Material.Plastic
        wheel.BrickColor = BrickColor.new("Really black")
        wheel.Parent = vehicle
        
        -- Positioniere Räder
        local x = (i <= 2) and -3.5 or 3.5
        local z = (i == 1 or i == 3) and 4 or -4
        wheel.Position = spawnPos + Vector3.new(x, -1, z)
        wheel.Orientation = Vector3.new(0, 0, 90)
        
        -- Verbinde Räder mit Body
        local wheelWeld = Instance.new("WeldConstraint")
        wheelWeld.Part0 = body
        wheelWeld.Part1 = wheel
        wheelWeld.Parent = body
    end
    
    -- PrimaryPart setzen
    vehicle.PrimaryPart = body
    
    -- Speichere Fahrzeug in GameState
    if GameState.players[player.UserId] then
        GameState.players[player.UserId].vehicle = vehicle
    end
    
    return vehicle
end

-- Race Management
function startRace()
    if GameState.race_active then return end
    
    GameState.race_active = true
    GameState.race_start_time = tick()
    
    -- Countdown
    for i = Config.COUNTDOWN_TIME, 1, -1 do
        Events.StartRace:FireAllClients("countdown", i)
        wait(1)
    end
    
    Events.StartRace:FireAllClients("start", 0)
    print("Race started!")
    
    -- Race Timer
    spawn(function()
        while GameState.race_active do
            wait(1)
            local elapsed = tick() - GameState.race_start_time
            
            -- Update player times
            for userId, data in pairs(GameState.players) do
                data.race_time = elapsed
            end
            
            updateLeaderboard()
            
            -- Check for race end
            if elapsed >= Config.RACE_DURATION then
                endRace()
                break
            end
        end
    end)
end

function endRace()
    GameState.race_active = false
    Events.FinishRace:FireAllClients(GameState.leaderboard)
    print("Race ended!")
    
    -- Reset nach 10 Sekunden  
    wait(10)
    resetRace()
end

function resetRace()
    -- Reset player data
    for userId, data in pairs(GameState.players) do
        data.current_lap = 0
        data.checkpoints_passed = {}
        data.race_time = 0
        data.position = 0
        
        -- Reset vehicle position
        if data.vehicle and data.vehicle.PrimaryPart then
            local spawnPos = Config.SPAWN_POSITIONS[math.min(#Config.SPAWN_POSITIONS, userId % #Config.SPAWN_POSITIONS + 1)]
            data.vehicle:SetPrimaryPartCFrame(CFrame.new(spawnPos))
        end
    end
    
    updateLeaderboard()
    print("Race reset!")
end

-- Event Handlers
Events.SpawnVehicle.OnServerEvent:Connect(function(player, vehicleType)
    createVehicle(player, vehicleType or 1)
end)

Events.ResetVehicle.OnServerEvent:Connect(function(player)
    local playerData = GameState.players[player.UserId]
    if playerData and playerData.vehicle and playerData.vehicle.PrimaryPart then
        local spawnPos = Config.SPAWN_POSITIONS[math.min(#Config.SPAWN_POSITIONS, player.UserId % #Config.SPAWN_POSITIONS + 1)]
        playerData.vehicle:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0, 5, 0)))
    end
end)

Events.CheckpointReached.OnServerEvent:Connect(function(player, checkpointId)
    local playerData = GameState.players[player.UserId]
    if not playerData or not GameState.race_active then return end
    
    -- Verhindere mehrfaches Passieren desselben Checkpoints
    if playerData.checkpoints_passed[checkpointId] then return end
    
    playerData.checkpoints_passed[checkpointId] = true
    
    -- Check ob alle Checkpoints passiert wurden
    local checkpointsPassed = 0
    for _ in pairs(playerData.checkpoints_passed) do
        checkpointsPassed = checkpointsPassed + 1
    end
    
    if checkpointsPassed >= #Config.CHECKPOINTS then
        playerData.current_lap = playerData.current_lap + 1
        playerData.checkpoints_passed = {}
        
        print(player.Name .. " completed lap " .. playerData.current_lap)
        
        -- Check für Rennende
        if playerData.current_lap >= Config.LAPS_TO_WIN then
            endRace()
        end
    end
    
    updateLeaderboard()
end)

Events.ToggleBubbles.OnServerEvent:Connect(function(player, enabled)
    local playerData = GameState.players[player.UserId]
    if playerData then
        playerData.bubbles_active = enabled
    end
end)

-- Player Events
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removePlayer)

-- Auto-start race wenn genug Spieler da sind
spawn(function()
    while true do
        wait(5)
        local playerCount = 0
        for _ in pairs(GameState.players) do
            playerCount = playerCount + 1
        end
        
        if playerCount >= 2 and not GameState.race_active then
            startRace()
        end
    end
end)

print("Race Server initialized!")
