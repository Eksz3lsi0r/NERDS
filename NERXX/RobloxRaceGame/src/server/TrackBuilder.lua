-- Race Track Builder - Erstellt automatisch eine Rennstrecke
local workspace = game:GetService("Workspace")

-- Track Configuration
local TRACK_CONFIG = {
    width = 20,
    height = 2,
    segments = {
        {pos = Vector3.new(0, 0, 0), size = Vector3.new(20, 2, 100), rotation = 0}, -- Start-Gerade
        {pos = Vector3.new(60, 0, 50), size = Vector3.new(100, 2, 20), rotation = 0}, -- Rechte Gerade
        {pos = Vector3.new(110, 0, 120), size = Vector3.new(20, 2, 100), rotation = 0}, -- Obere Gerade  
        {pos = Vector3.new(50, 0, 170), size = Vector3.new(100, 2, 20), rotation = 0}, -- Linke Gerade
        {pos = Vector3.new(-10, 0, 120), size = Vector3.new(20, 2, 80), rotation = 0}, -- Verbindung zurück
    },
    checkpoints = {
        {pos = Vector3.new(50, 5, 20), name = "Checkpoint1"},
        {pos = Vector3.new(100, 5, 80), name = "Checkpoint2"}, 
        {pos = Vector3.new(60, 5, 150), name = "Checkpoint3"},
        {pos = Vector3.new(10, 5, 100), name = "Checkpoint4"}
    },
    spawn_points = {
        Vector3.new(-5, 5, -20),
        Vector3.new(0, 5, -20),
        Vector3.new(5, 5, -20),
        Vector3.new(10, 5, -20),
        Vector3.new(-5, 5, -25),
        Vector3.new(0, 5, -25),
        Vector3.new(5, 5, -25),
        Vector3.new(10, 5, -25)
    }
}

-- Erstelle Race Track Ordner
local function createRaceTrack()
    -- Lösche alte Strecke falls vorhanden
    local existingTrack = workspace:FindFirstChild("RaceTrack")
    if existingTrack then
        existingTrack:Destroy()
    end
    
    local trackFolder = Instance.new("Folder")
    trackFolder.Name = "RaceTrack"
    trackFolder.Parent = workspace
    
    -- Erstelle Strecken-Segmente
    for i, segment in ipairs(TRACK_CONFIG.segments) do
        local track = Instance.new("Part")
        track.Name = "TrackSegment" .. i
        track.Size = segment.size
        track.Position = segment.pos
        track.Anchored = true
        track.Material = Enum.Material.Concrete
        track.Color = Color3.fromRGB(100, 100, 100)
        track.Parent = trackFolder
        
        -- Füge weiße Linien hinzu
        local line1 = Instance.new("Part")
        line1.Name = "Line1"
        line1.Size = Vector3.new(segment.size.X, 0.1, 2)
        line1.Position = segment.pos + Vector3.new(0, 1.1, segment.size.Z/4)
        line1.Anchored = true
        line1.Material = Enum.Material.Neon
        line1.Color = Color3.fromRGB(255, 255, 255)
        line1.Parent = trackFolder
        
        local line2 = Instance.new("Part")
        line2.Name = "Line2"
        line2.Size = Vector3.new(segment.size.X, 0.1, 2)
        line2.Position = segment.pos + Vector3.new(0, 1.1, -segment.size.Z/4)
        line2.Anchored = true
        line2.Material = Enum.Material.Neon
        line2.Color = Color3.fromRGB(255, 255, 255)
        line2.Parent = trackFolder
    end
    
    print("Race track created!")
    return trackFolder
end

-- Erstelle Checkpoints
local function createCheckpoints()
    local existingCheckpoints = workspace:FindFirstChild("Checkpoints")
    if existingCheckpoints then
        existingCheckpoints:Destroy()
    end
    
    local checkpointsFolder = Instance.new("Folder")
    checkpointsFolder.Name = "Checkpoints"
    checkpointsFolder.Parent = workspace
    
    for i, checkpoint in ipairs(TRACK_CONFIG.checkpoints) do
        local checkpointPart = Instance.new("Part")
        checkpointPart.Name = checkpoint.name
        checkpointPart.Size = Vector3.new(25, 15, 3)
        checkpointPart.Position = checkpoint.pos
        checkpointPart.Anchored = true
        checkpointPart.CanCollide = false
        checkpointPart.Material = Enum.Material.ForceField
        checkpointPart.Transparency = 0.5
        checkpointPart.Parent = checkpointsFolder
        
        -- Wechselnde Farben
        if i % 2 == 1 then
            checkpointPart.Color = Color3.fromRGB(0, 255, 0) -- Grün
        else
            checkpointPart.Color = Color3.fromRGB(255, 255, 0) -- Gelb
        end
        
        -- Checkpoint Nummer
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Front
        gui.Parent = checkpointPart
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "CHECKPOINT " .. i
        label.TextColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
    end
    
    print("Checkpoints created!")
    return checkpointsFolder
end

-- Erstelle Spawn Points
local function createSpawnPoints()
    local existingSpawns = workspace:FindFirstChild("SpawnPoints")
    if existingSpawns then
        existingSpawns:Destroy()
    end
    
    local spawnsFolder = Instance.new("Folder")
    spawnsFolder.Name = "SpawnPoints"
    spawnsFolder.Parent = workspace
    
    for i, pos in ipairs(TRACK_CONFIG.spawn_points) do
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Position = pos
        spawn.Size = Vector3.new(4, 1, 6)
        spawn.Material = Enum.Material.Neon
        spawn.Color = Color3.fromRGB(0, 255, 255)
        spawn.Anchored = true
        spawn.Parent = spawnsFolder
        
        -- Spawn Nummer
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Top
        gui.Parent = spawn
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = tostring(i)
        label.TextColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = gui
    end
    
    print("Spawn points created!")
    return spawnsFolder
end

-- Erstelle Start/Ziel Linie
local function createStartFinishLine()
    local startLine = Instance.new("Part")
    startLine.Name = "StartFinishLine"
    startLine.Size = Vector3.new(25, 1, 3)
    startLine.Position = Vector3.new(2.5, 2, -10)
    startLine.Anchored = true
    startLine.Material = Enum.Material.Neon
    startLine.CanCollide = false
    startLine.Parent = workspace
    
    -- Schachbrett-Muster (schwarz-weiß)
    startLine.Color = Color3.fromRGB(255, 255, 255)
    
    -- "START/FINISH" Text
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Top
    gui.Parent = startLine
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🏁 START / FINISH 🏁"
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    
    print("Start/Finish line created!")
    return startLine
end

-- Erstelle Umgebung (Gras, Bäume, etc.)
local function createEnvironment()
    -- Grundboden
    local ground = Instance.new("Part")
    ground.Name = "Ground"
    ground.Size = Vector3.new(300, 1, 300)
    ground.Position = Vector3.new(50, -10, 80)
    ground.Anchored = true
    ground.Material = Enum.Material.Grass
    ground.Color = Color3.fromRGB(0, 150, 0)
    ground.Parent = workspace
    
    -- Einige Bäume zur Dekoration
    for i = 1, 10 do
        local tree = Instance.new("Part")
        tree.Name = "Tree" .. i
        tree.Size = Vector3.new(3, 15, 3)
        tree.Position = Vector3.new(
            math.random(-50, 150),
            7,
            math.random(20, 140)
        )
        tree.Anchored = true
        tree.Material = Enum.Material.Wood
        tree.Color = Color3.fromRGB(101, 67, 33)
        tree.Shape = Enum.PartType.Cylinder
        tree.Parent = workspace
        
        -- Baumkrone
        local leaves = Instance.new("Part")
        leaves.Name = "Leaves" .. i
        leaves.Size = Vector3.new(8, 8, 8)
        leaves.Position = tree.Position + Vector3.new(0, 10, 0)
        leaves.Anchored = true
        leaves.Material = Enum.Material.Grass
        leaves.Color = Color3.fromRGB(0, 100, 0)
        leaves.Shape = Enum.PartType.Ball
        leaves.Parent = workspace
    end
    
    print("Environment created!")
end

-- Main Setup Function
local function setupRaceWorld()
    print("Creating race world...")
    
    createRaceTrack()
    createCheckpoints()
    createSpawnPoints() 
    createStartFinishLine()
    createEnvironment()
    
    -- Setze Lighting für bessere Atmosphäre
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 2
    lighting.Ambient = Color3.fromRGB(100, 100, 100)
    lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    
    -- Skybox
    local sky = Instance.new("Sky")
    sky.Name = "RacingSky"
    sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
    sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
    sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
    sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
    sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
    sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
    sky.Parent = lighting
    
    print("Race world setup completed!")
end

-- Führe Setup aus
setupRaceWorld()
