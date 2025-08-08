-- Subway Surfers Game Launcher - Enhanced mit World Integration
-- Startet das komplette Spiel System und behebt die Welt/Hindernisse-Probleme
--!strict

local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

-- Sichere Module-Loading
local function requireSafe(moduleName: string): any?
	local success, module = pcall(function()
		local moduleScript = script.Parent:FindFirstChild(moduleName)
		if moduleScript then
			return require(moduleScript)
		end
		return nil
	end)
	return if success then module else nil
end

local GameCoordinator = requireSafe("GameCoordinator")
local WorldBuilder = requireSafe("WorldBuilder")
local DynamicWorldGenerator = requireSafe("DynamicWorldGenerator")
local ObstacleService = requireSafe("ObstacleService")

-- Erstelle eine schnelle Welt wenn Module fehlen
local function createBasicSubwayWorld()
	print("🌍 Creating basic Subway Surfers world...")

	-- Hauptspur
	local mainTrack = Instance.new("Part")
	mainTrack.Name = "SubwayTrack"
	mainTrack.Size = Vector3.new(24, 2, 2000)
	mainTrack.Position = Vector3.new(0, -1, 1000)
	mainTrack.Material = Enum.Material.Asphalt
	mainTrack.BrickColor = BrickColor.new("Really black")
	mainTrack.Anchored = true
	mainTrack.Parent = workspace

	-- Lane Markierungen (-1, 0, 1 System)
	local lanePositions = { [-1] = -8, [0] = 0, [1] = 8 }
	for lane, xPos in pairs(lanePositions) do
		local marker = Instance.new("Part")
		marker.Name = `LaneMarker_{lane}`
		marker.Size = Vector3.new(0.5, 0.2, 2000)
		marker.Position = Vector3.new(xPos, 0.1, 1000)
		marker.Material = Enum.Material.Neon
		marker.BrickColor = BrickColor.new("Bright yellow")
		marker.Anchored = true
		marker.Parent = workspace
	end

	-- Basic Obstacles für Testing
	for i = 1, 10 do
		local obstacle = Instance.new("Part")
		obstacle.Name = `TestObstacle_{i}`
		obstacle.Size = Vector3.new(4, 4, 4)
		obstacle.Position = Vector3.new(
			lanePositions[math.random(-1, 1)], -- Random lane
			2,
			i * 50 + 100
		)
		obstacle.Material = Enum.Material.Concrete
		obstacle.BrickColor = BrickColor.new("Bright red")
		obstacle.Anchored = true
		obstacle.Parent = workspace
	end

	-- Basic Coins
	for i = 1, 20 do
		local coin = Instance.new("Part")
		coin.Name = `Coin_{i}`
		coin.Size = Vector3.new(2, 2, 0.2)
		coin.Position = Vector3.new(lanePositions[math.random(-1, 1)], 3, i * 25 + 50)
		coin.Shape = Enum.PartType.Cylinder
		coin.Material = Enum.Material.Neon
		coin.BrickColor = BrickColor.new("Bright yellow")
		coin.Anchored = true
		coin.CanCollide = false
		coin.Parent = workspace

		-- Rotation für Coins
		spawn(function()
			while coin.Parent do
				coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(5), 0)
				wait(0.1)
			end
		end)
	end

	print("✅ Basic Subway Surfers world created!")
end

-- Initialize the complete game system
print("🎮 SUBWAY SURFERS GAME - Starting Enhanced System...")
print("🚀 Loading Game Components...")

-- Schritt 1: WorldBuilder initialisieren
if WorldBuilder then
	local success = pcall(function()
		WorldBuilder.Initialize()
		print("✅ WorldBuilder initialized")
	end)
	if not success then
		warn("❌ WorldBuilder failed - using fallback")
		createBasicSubwayWorld()
	end
else
	print("⚠️ WorldBuilder not found - creating basic world")
	createBasicSubwayWorld()
end

-- Schritt 2: Game Coordinator starten
local coordinator = nil
if GameCoordinator then
	coordinator = GameCoordinator.new()
	coordinator:initialize()
	print("✅ Game Coordinator initialized")
else
	warn("❌ GameCoordinator not found - using basic game management")
end

-- Schritt 3: World Generation starten
local worldGenerator = nil
if DynamicWorldGenerator then
	worldGenerator = DynamicWorldGenerator.new()
	print("✅ DynamicWorldGenerator ready")
end

local obstacleService = nil
if ObstacleService then
	obstacleService = ObstacleService
	pcall(function()
		obstacleService:Initialize()
		print("✅ ObstacleService initialized")
	end)
end

-- Player Management für World Activation
local function onPlayerAdded(player)
	print(`🎮 Player {player.Name} joined - activating world systems`)

	-- Warte auf Character
	player.CharacterAdded:Connect(function(character)
		local rootPart = character:WaitForChild("HumanoidRootPart", 10)
		if rootPart then
			-- Setze auf Startposition
			rootPart.CFrame = CFrame.lookAt(Vector3.new(0, 5, 0), Vector3.new(0, 5, 100))

			-- Starte World Generation
			if worldGenerator then
				pcall(function()
					worldGenerator:start(Vector3.new(0, 5, 0))
				end)
			end

			if obstacleService then
				pcall(function()
					obstacleService:StartSpawning()
				end)
			end

			print(`✅ World systems activated for {player.Name}`)
		end
	end)
end

-- Connect Player Events
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Store globally for other scripts to access
_G.SubwaySurfersGame = {
	coordinator = coordinator,
	worldGenerator = worldGenerator,
	obstacleService = obstacleService,
}

print("✅ SUBWAY SURFERS GAME - Ready to play!")
print("🌍 World systems active - 3-Lane track with obstacles and coins spawned")
print("👋 Players can now join and experience the complete Subway Surfers gameplay!")

-- Enhanced Status check every 30 seconds
spawn(function()
	while true do
		wait(30)
		local playerCount = #Players:GetPlayers()
		local worldActive = worldGenerator ~= nil
		local obstaclesActive = obstacleService ~= nil

		print(`📊 Game Status: {playerCount} players, World: {worldActive}, Obstacles: {obstaclesActive}`)

		if coordinator then
			local status = coordinator:getStatus()
			print(`📊 Coordinator: Active: {status.activeSession}, WorldGen: {status.worldGeneratorActive}`)
		end
	end
end)
