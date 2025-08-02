-- Client-seitiges Hauptscript
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Warte auf Events und Config
repeat wait() until ReplicatedStorage:FindFirstChild("Events")
repeat wait() until ReplicatedStorage:FindFirstChild("Config")
local Config = require(ReplicatedStorage.Config)
local Events = ReplicatedStorage.Events

-- UI Elemente
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceUI"
screenGui.Parent = playerGui

-- Leaderboard
local leaderboardFrame = Instance.new("Frame")
leaderboardFrame.Name = "Leaderboard"
leaderboardFrame.Size = UDim2.new(0, 300, 0, 400)
leaderboardFrame.Position = UDim2.new(1, -320, 0, 20)
leaderboardFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
leaderboardFrame.BackgroundTransparency = 0.3
leaderboardFrame.Parent = screenGui

local leaderboardTitle = Instance.new("TextLabel")
leaderboardTitle.Name = "Title"
leaderboardTitle.Size = UDim2.new(1, 0, 0, 40)
leaderboardTitle.Position = UDim2.new(0, 0, 0, 0)
leaderboardTitle.BackgroundTransparency = 1
leaderboardTitle.Text = "🏁 LEADERBOARD 🏁"
leaderboardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
leaderboardTitle.TextScaled = true
leaderboardTitle.Font = Enum.Font.GothamBold
leaderboardTitle.Parent = leaderboardFrame

local leaderboardList = Instance.new("ScrollingFrame")
leaderboardList.Name = "List"
leaderboardList.Size = UDim2.new(1, -10, 1, -50)
leaderboardList.Position = UDim2.new(0, 5, 0, 45)
leaderboardList.BackgroundTransparency = 1
leaderboardList.ScrollBarThickness = 8
leaderboardList.Parent = leaderboardFrame

-- Vehicle Spawn UI
local spawnFrame = Instance.new("Frame")
spawnFrame.Name = "VehicleSpawn"
spawnFrame.Size = UDim2.new(0, 400, 0, 200)
spawnFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
spawnFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
spawnFrame.BackgroundTransparency = 0.2
spawnFrame.Parent = screenGui

local spawnTitle = Instance.new("TextLabel")
spawnTitle.Name = "Title"
spawnTitle.Size = UDim2.new(1, 0, 0, 40)
spawnTitle.BackgroundTransparency = 1
spawnTitle.Text = "🚗 WÄHLE DEIN AUTO 🚗"
spawnTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnTitle.TextScaled = true
spawnTitle.Font = Enum.Font.GothamBold
spawnTitle.Parent = spawnFrame

-- Vehicle Buttons
for i, vehicle in ipairs(Config.VEHICLES) do
    local button = Instance.new("TextButton")
    button.Name = "Vehicle" .. i
    button.Size = UDim2.new(0.2, -5, 0, 60)
    button.Position = UDim2.new(0.05 + (i-1) * 0.22, 0, 0, 50)
    button.BackgroundColor3 = vehicle.Color
    button.Text = vehicle.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.Gotham
    button.Parent = spawnFrame
    
    button.MouseButton1Click:Connect(function()
        Events.SpawnVehicle:FireServer(i)
        spawnFrame.Visible = false
    end)
end

-- Bubble Toggle Button
local bubbleButton = Instance.new("TextButton")
bubbleButton.Name = "BubbleToggle"
bubbleButton.Size = UDim2.new(0, 150, 0, 40)
bubbleButton.Position = UDim2.new(1, -170, 1, -60)
bubbleButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
bubbleButton.Text = "🫧 BLASEN AN"
bubbleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bubbleButton.TextScaled = true
bubbleButton.Font = Enum.Font.Gotham
bubbleButton.Parent = screenGui

local bubblesEnabled = true
bubbleButton.MouseButton1Click:Connect(function()
    bubblesEnabled = not bubblesEnabled
    bubbleButton.Text = bubblesEnabled and "🫧 BLASEN AN" or "🫧 BLASEN AUS"
    bubbleButton.BackgroundColor3 = bubblesEnabled and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(150, 150, 150)
    Events.ToggleBubbles:FireServer(bubblesEnabled)
end)

-- Race Status UI
local raceStatusFrame = Instance.new("Frame")
raceStatusFrame.Name = "RaceStatus"
raceStatusFrame.Size = UDim2.new(0, 600, 0, 100)
raceStatusFrame.Position = UDim2.new(0.5, -300, 0, 20)
raceStatusFrame.BackgroundTransparency = 1
raceStatusFrame.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Warte auf andere Spieler..."
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextStrokeTransparency = 0
statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Parent = raceStatusFrame

-- Controls UI
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "Controls"
controlsFrame.Size = UDim2.new(0, 300, 0, 150)
controlsFrame.Position = UDim2.new(0, 20, 1, -170)
controlsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlsFrame.BackgroundTransparency = 0.5
controlsFrame.Parent = screenGui

local controlsText = Instance.new("TextLabel")
controlsText.Size = UDim2.new(1, 0, 1, 0)
controlsText.BackgroundTransparency = 1
controlsText.Text = "🎮 STEUERUNG:\nWASD - Fahren\nSpace - Bremse\nR - Reset Auto"
controlsText.TextColor3 = Color3.fromRGB(255, 255, 255)
controlsText.TextScaled = true
controlsText.Font = Enum.Font.Gotham
controlsText.Parent = controlsFrame

-- Bubble Effects System
local currentBubbles = {}

local function createBubbleEffect(part)
    if not bubblesEnabled or not part then return end
    
    local attachment = Instance.new("Attachment")
    attachment.Name = "BubbleAttachment"
    attachment.Parent = part
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "BubbleEffect"
    particles.Parent = attachment
    
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Lifetime = Config.BUBBLE_SETTINGS.LifeTime
    particles.Rate = Config.BUBBLE_SETTINGS.Rate
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Speed = NumberRange.new(2, 8)
    particles.Size = Config.BUBBLE_SETTINGS.Size
    particles.Color = ColorSequence.new(Config.BUBBLE_SETTINGS.Colors[math.random(#Config.BUBBLE_SETTINGS.Colors)])
    particles.LightEmission = 0.8
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    
    return particles
end

local function updateBubbles()
    if not player.Character then return end
    
    local leftHand = player.Character:FindFirstChild("LeftHand")
    local rightHand = player.Character:FindFirstChild("RightHand")
    
    -- Fallbacks für R6
    if not leftHand then leftHand = player.Character:FindFirstChild("Left Arm") end
    if not rightHand then rightHand = player.Character:FindFirstChild("Right Arm") end
    
    -- Erstelle Blasen-Effekte für Hände
    if leftHand and not currentBubbles.left then
        currentBubbles.left = createBubbleEffect(leftHand)
    end
    
    if rightHand and not currentBubbles.right then
        currentBubbles.right = createBubbleEffect(rightHand)
    end
    
    -- Entferne Effekte wenn Blasen deaktiviert
    if not bubblesEnabled then
        for side, effect in pairs(currentBubbles) do
            if effect then
                effect:Destroy()
                currentBubbles[side] = nil
            end
        end
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        Events.ResetVehicle:FireServer()
    end
end)

-- Checkpoint Detection
local function checkForCheckpoints()
    if not player.Character or not player.Character.PrimaryPart then return end
    
    local playerPosition = player.Character.PrimaryPart.Position
    
    for i, checkpointPos in ipairs(Config.CHECKPOINTS) do
        local distance = (playerPosition - checkpointPos).Magnitude
        if distance < 15 then -- Checkpoint erreicht
            Events.CheckpointReached:FireServer(i)
        end
    end
end

-- Event Handlers
Events.UpdateLeaderboard.OnClientEvent:Connect(function(leaderboard)
    -- Lösche alte Einträge
    for _, child in pairs(leaderboardList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Erstelle neue Einträge
    for i, entry in ipairs(leaderboard) do
        local entryLabel = Instance.new("TextLabel")
        entryLabel.Name = "Entry" .. i
        entryLabel.Size = UDim2.new(1, -10, 0, 30)
        entryLabel.Position = UDim2.new(0, 5, 0, (i-1) * 35)
        entryLabel.BackgroundTransparency = 1
        entryLabel.Text = string.format("%d. %s - Runde %d (%.1fs)", 
            entry.position, entry.name, entry.lap, entry.time)
        entryLabel.TextColor3 = i == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
        entryLabel.TextScaled = true
        entryLabel.Font = Enum.Font.Gotham
        entryLabel.TextXAlignment = Enum.TextXAlignment.Left
        entryLabel.Parent = leaderboardList
    end
    
    leaderboardList.CanvasSize = UDim2.new(0, 0, 0, #leaderboard * 35)
end)

Events.StartRace.OnClientEvent:Connect(function(status, value)
    if status == "countdown" then
        statusLabel.Text = "🏁 RENNEN STARTET IN " .. value .. " 🏁"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    elseif status == "start" then
        statusLabel.Text = "🏎️ RENNEN LÄUFT! 🏎️"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

Events.FinishRace.OnClientEvent:Connect(function(leaderboard)
    statusLabel.Text = "🏆 RENNEN BEENDET! 🏆"
    statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    
    if leaderboard[1] then
        local winner = leaderboard[1].name
        if winner == player.Name then
            statusLabel.Text = "🎉 DU HAST GEWONNEN! 🎉"
        else
            statusLabel.Text = "🏆 GEWINNER: " .. winner .. " 🏆"
        end
    end
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    updateBubbles()
    checkForCheckpoints()
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function()
    wait(1) -- Warte bis Character vollständig geladen
    currentBubbles = {} -- Reset bubble effects
    spawnFrame.Visible = true -- Zeige Fahrzeug-Auswahl wieder
end)

print("Race Client initialized for " .. player.Name)
