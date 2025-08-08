--!strict
-- SubwayWorldIntegrator.lua - Vereint alle Subway Surfer Welt-Systeme
-- Löst das Problem der fehlenden Welt, Hindernisse, und Lane-Integration

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Enhanced Module Loading mit Fehlerbehandlung
local function loadModuleSafe(moduleName: string, fallbackValue: any?): any?
	local success, module = pcall(function()
		local moduleScript = script.Parent:FindFirstChild(moduleName)
		if moduleScript and moduleScript:IsA("ModuleScript") then
			return moduleScript -- Return the script, not require it yet
		end
		return nil
	end)

	if success and module then
		print(`✅ [WorldIntegrator] {moduleName} gefunden`)
		return module
	else
		warn(`⚠️ [WorldIntegrator] {moduleName} konnte nicht gefunden werden`)
		return fallbackValue
	end
end

-- Lade Module Scripts (nicht require)
local DynamicWorldGeneratorScript = loadModuleSafe("DynamicWorldGenerator")
local ObstacleServiceScript = loadModuleSafe("ObstacleService")
local WorldBuilderScript = loadModuleSafe("WorldBuilder")

-- Lade Shared Module
local GameConstants = nil
local _SubwaySurfersGameplay = nil

pcall(function()
	local SharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
	if SharedFolder then
		GameConstants = require(SharedFolder:WaitForChild("GameConstants"))
		_SubwaySurfersGameplay = require(SharedFolder:WaitForChild("SubwaySurfersGameplay"))
	end
end)

-- SubwayWorldIntegrator - Master Coordinator
local SubwayWorldIntegrator = {}
SubwayWorldIntegrator.__index = SubwayWorldIntegrator

export type IntegratorState = {
	isInitialized: boolean,
	worldBuilderActive: boolean,
	dynamicGeneratorActive: boolean,
	obstacleServiceActive: boolean,
	activePlayer: Player | nil,
}

function SubwayWorldIntegrator.new()
	local self = setmetatable({}, SubwayWorldIntegrator)

	self.state = {
		isInitialized = false,
		worldBuilderActive = false,
		dynamicGeneratorActive = false,
		obstacleServiceActive = false,
		activePlayer = nil,
	} :: IntegratorState

	self.worldBuilder = nil
	self.dynamicWorldGenerator = nil
	self.obstacleService = nil

	return self
end

-- Handle Player Leave
function SubwayWorldIntegrator:OnPlayerLeaving(player: Player)
	print(`👋 [WorldIntegrator] Player {player.Name} verlässt das Spiel - starte Cleanup`)

	-- Überprüfe ob dieser Player der aktive Player ist
	if not self.state.activePlayer then
		print(`ℹ️ [WorldIntegrator] Kein aktiver Player - {player.Name} Cleanup übersprungen`)
		return
	end

	if self.state.activePlayer.Name ~= player.Name then
		print(
			`ℹ️ [WorldIntegrator] {player.Name} ist nicht der aktive Player ({self.state.activePlayer.Name}) - Cleanup übersprungen`
		)
		return
	end

	print(`🧹 [WorldIntegrator] Starte vollständigen Cleanup für aktiven Player {player.Name}`)

	-- Schritt 1: Stoppe World Generation Systems
	local worldStopSuccess = pcall(function()
		self:StopWorldGeneration()
	end)

	if worldStopSuccess then
		print(`✅ [WorldIntegrator] World Generation erfolgreich gestoppt für {player.Name}`)
	else
		warn(`⚠️ [WorldIntegrator] Fehler beim Stoppen der World Generation für {player.Name}`)
	end

	-- Schritt 2: Player-spezifische Cleanup-Operationen
	local playerCleanupSuccess = pcall(function()
		-- Cleanup DynamicWorldGenerator Player-Referenzen
		if self.dynamicWorldGenerator and self.state.dynamicGeneratorActive then
			if self.dynamicWorldGenerator.clearPlayerData then
				self.dynamicWorldGenerator:clearPlayerData(player)
			end
		end

		-- Cleanup ObstacleService Player-Referenzen
		if self.obstacleService and self.state.obstacleServiceActive then
			if self.obstacleService.cleanupPlayerData then
				self.obstacleService:cleanupPlayerData(player)
			end
		end
	end)

	if playerCleanupSuccess then
		print(`✅ [WorldIntegrator] Player-spezifische Daten bereinigt für {player.Name}`)
	else
		warn(`⚠️ [WorldIntegrator] Fehler bei Player-spezifischer Bereinigung für {player.Name}`)
	end

	-- Schritt 3: State Reset mit expliziter Type-Assertion
	self.state.activePlayer = nil :: Player?

	-- Schritt 4: Prüfe auf verbleibende Player
	local remainingPlayers = Players:GetPlayers()
	local activePlayersCount = #remainingPlayers

	-- Entferne den verlassenden Player aus der Zählung
	if table.find(remainingPlayers, player) then
		activePlayersCount = activePlayersCount - 1
	end

	if activePlayersCount > 0 then
		print(`🔄 [WorldIntegrator] {activePlayersCount} Spieler verbleiben - prüfe auf neuen aktiven Player`)

		-- Versuche einen neuen aktiven Player zu finden
		for _, remainingPlayer in ipairs(remainingPlayers) do
			if remainingPlayer ~= player and remainingPlayer.Character then
				self:OnPlayerJoined(remainingPlayer)
				break
			end
		end
	else
		print(`🏁 [WorldIntegrator] Keine Spieler verbleiben - alle Systeme pausiert`)
	end

	print(`✅ [WorldIntegrator] Cleanup abgeschlossen für Player {player.Name}`)
end

-- Hauptinitialisierung - vereint alle Systeme
function SubwayWorldIntegrator:Initialize(): boolean
	if self.state.isInitialized then
		print("🌍 [WorldIntegrator] Already initialized")
		return true
	end

	print("🌍 [WorldIntegrator] Starting Subway Surfers World Integration...")

	-- Schritt 1: Basis-Welt erstellen
	if not self:InitializeWorldBuilder() then
		warn("❌ WorldBuilder initialization failed")
		return false
	end

	-- Schritt 2: Dynamische Welt-Generierung
	if not self:InitializeDynamicWorldGenerator() then
		warn("❌ DynamicWorldGenerator initialization failed")
		return false
	end

	-- Schritt 3: Hindernisse und Collectibles
	if not self:InitializeObstacleService() then
		warn("❌ ObstacleService initialization failed")
		return false
	end

	-- Schritt 4: Player-Management
	self:SetupPlayerManagement()

	self.state.isInitialized = true
	print("✅ [WorldIntegrator] Subway Surfers World fully integrated!")

	return true
end

-- WorldBuilder Integration
function SubwayWorldIntegrator:InitializeWorldBuilder(): boolean
	if not WorldBuilderScript then
		warn("WorldBuilder not available - creating basic world")
		self:CreateBasicWorld()
		return true
	end

	local success, worldBuilderModule = pcall(require, WorldBuilderScript)

	if not success or not worldBuilderModule then
		warn("❌ WorldBuilder module could not be required - using fallback. Error: ", worldBuilderModule)
		self:CreateBasicWorld()
		return true
	end

	self.worldBuilder = worldBuilderModule

	local initSuccess = pcall(function()
		self.worldBuilder.Initialize()
		self.state.worldBuilderActive = true
	end)

	if initSuccess then
		print("✅ WorldBuilder initialized")
	else
		warn("❌ WorldBuilder failed - using fallback")
		self:CreateBasicWorld()
	end

	return true
end

-- DynamicWorldGenerator Integration
function SubwayWorldIntegrator:InitializeDynamicWorldGenerator(): boolean
	if not DynamicWorldGeneratorScript then
		return false
	end

	local success, dynamicWorldGeneratorModule = pcall(require, DynamicWorldGeneratorScript)

	if not success or not dynamicWorldGeneratorModule then
		warn("❌ DynamicWorldGenerator module could not be required. Error: ", dynamicWorldGeneratorModule)
		return false
	end

	local initSuccess = pcall(function()
		self.dynamicWorldGenerator = dynamicWorldGeneratorModule.new()
		self.state.dynamicGeneratorActive = true
	end)

	if initSuccess then
		print("✅ DynamicWorldGenerator ready")
	else
		warn("❌ DynamicWorldGenerator failed")
	end

	return initSuccess
end

-- ObstacleService Integration
function SubwayWorldIntegrator:InitializeObstacleService(): boolean
	if not ObstacleServiceScript then
		return false
	end

	local success, obstacleServiceModule = pcall(require, ObstacleServiceScript)

	if not success or not obstacleServiceModule then
		warn("❌ ObstacleService module could not be required. Error: ", obstacleServiceModule)
		return false
	end

	self.obstacleService = obstacleServiceModule

	local initSuccess = pcall(function()
		self.obstacleService:Initialize()
		self.state.obstacleServiceActive = true
	end)

	if initSuccess then
		print("✅ ObstacleService initialized")
	else
		warn("❌ ObstacleService failed")
	end

	return initSuccess
end

-- Player Management Setup
function SubwayWorldIntegrator:SetupPlayerManagement()
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerJoined(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerLeaving(player)
	end)

	-- Handle existing players
	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerJoined(player)
	end
end

-- Handle Player Join
function SubwayWorldIntegrator:OnPlayerJoined(player: Player)
	print(`🎮 [WorldIntegrator] Player {player.Name} joined - setting up world`)

	self.state.activePlayer = player

	-- Warte auf Character
	local character = player.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)

	if rootPart then
		-- Setze Player auf Startposition
		local startPos = Vector3.new(0, 5, 0)
		local rootPartCFrame = rootPart :: BasePart
		rootPartCFrame.CFrame = CFrame.lookAt(startPos, startPos + Vector3.new(0, 0, 100))

		-- Starte World Generation wenn verfügbar
		self:StartWorldGeneration(startPos)

		print(`✅ Player {player.Name} positioned and world systems started`)
	end
end

-- Start World Generation
function SubwayWorldIntegrator:StartWorldGeneration(playerPosition: Vector3)
	-- Start DynamicWorldGenerator
	if self.dynamicWorldGenerator and self.state.dynamicGeneratorActive then
		pcall(function()
			self.dynamicWorldGenerator:start(playerPosition)
		end)
	end

	-- Start ObstacleService
	if self.obstacleService and self.state.obstacleServiceActive then
		pcall(function()
			self.obstacleService:StartSpawning()
		end)
	end

	print("🌍 World generation systems started")
end

-- Stop World Generation
function SubwayWorldIntegrator:StopWorldGeneration()
	-- Stop DynamicWorldGenerator
	if self.dynamicWorldGenerator then
		pcall(function()
			self.dynamicWorldGenerator:stop()
		end)
	end

	-- Stop ObstacleService
	if self.obstacleService then
		pcall(function()
			self.obstacleService:StopSpawning()
		end)
	end

	print("🛑 World generation systems stopped")
end

-- Fallback: Create Basic World
function SubwayWorldIntegrator:CreateBasicWorld()
	print("🏗️ Creating basic Subway Surfers world...")

	local workspace = game:GetService("Workspace")

	-- Main Track Platform
	local mainTrack = Instance.new("Part")
	mainTrack.Name = "SubwayTrack"
	mainTrack.Size = Vector3.new(24, 2, 1000)
	mainTrack.Position = Vector3.new(0, -1, 500)
	mainTrack.Material = Enum.Material.Concrete
	mainTrack.BrickColor = BrickColor.new("Dark stone grey")
	mainTrack.Anchored = true
	mainTrack.Parent = workspace

	-- Lane Markers
	local function getLanePos(lane: number): number
		if GameConstants and GameConstants.GetLanePosition then
			return GameConstants.GetLanePosition(lane)
		else
			return lane * 8
		end
	end

	for lane = -1, 1 do
		local marker = Instance.new("Part")
		marker.Name = `LaneMarker_{lane}`
		marker.Size = Vector3.new(0.5, 0.2, 1000)
		marker.Position = Vector3.new(getLanePos(lane), 0.1, 500)
		marker.Material = Enum.Material.Neon
		marker.BrickColor = BrickColor.new("Bright yellow")
		marker.Anchored = true
		marker.Parent = workspace
	end

	print("✅ Basic world created with lane markers")
end

-- Update Loop für Koordination
function SubwayWorldIntegrator:StartUpdateLoop()
	RunService.Heartbeat:Connect(function()
		if not self.state.activePlayer then
			return
		end

		local character = self.state.activePlayer.Character
		if not character then
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

		-- Update DynamicWorldGenerator mit Player-Position
		if self.dynamicWorldGenerator and self.state.dynamicGeneratorActive then
			pcall(function()
				self.dynamicWorldGenerator:updatePlayerPosition(rootPart.Position)
			end)
		end
	end)
end

-- Status Check
function SubwayWorldIntegrator:GetStatus(): { [string]: any }
	return {
		initialized = self.state.isInitialized,
		worldBuilder = self.state.worldBuilderActive,
		dynamicGenerator = self.state.dynamicGeneratorActive,
		obstacleService = self.state.obstacleServiceActive,
		activePlayer = if self.state.activePlayer then self.state.activePlayer.Name else "None",
	}
end

return SubwayWorldIntegrator
