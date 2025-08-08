--!strict
-- SubwaySurfer.lua - Integrierte Subway Surfers Gameplay-Funktionen
-- Arbeitet mit GameConstants und SubwaySurfersGameplay zusammen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Sichere Module-Loading mit Fehlerbehandlung
local GameConstants = nil
local SubwaySurfersGameplay = nil

-- Lade Module sicher
pcall(function()
	local SharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
	if SharedFolder then
		GameConstants = require(SharedFolder:WaitForChild("GameConstants", 3))
		SubwaySurfersGameplay = require(SharedFolder:WaitForChild("SubwaySurfersGameplay", 3))
	end
end)

-- Fallback-Funktionen falls Module nicht verfügbar
local function getLanePosition(lane: number): number
	if GameConstants and GameConstants.GetLanePosition then
		return GameConstants.GetLanePosition(lane)
	elseif SubwaySurfersGameplay and SubwaySurfersGameplay.GetLanePosition then
		return SubwaySurfersGameplay.GetLanePosition(lane)
	else
		-- Fallback: Standard Lane-Positionen
		local lanePositions = { [-1] = -8, [0] = 0, [1] = 8 }
		return lanePositions[lane] or 0
	end
end

-- Type Definition für bessere Typsicherheit
export type PlayerState = {
	currentLane: number, -- -1 (links), 0 (mitte), 1 (rechts)
	position: Vector3,
	startPosition: Vector3,
}

-- Enhanced Kollisionserkennung mit Luau Type Safety
function checkCollision(playerPosition: Vector3, obstaclePosition: Vector3, obstacleSize: Vector3): boolean
	-- Berechne die Grenzen des Hindernisses mit erweiterten Bounds
	local obstacleBounds = {
		min = obstaclePosition - obstacleSize / 2,
		max = obstaclePosition + obstacleSize / 2,
	}

	-- 3D-Kollisionserkennung (X, Y, Z-Achsen)
	local collisionX = playerPosition.X >= obstacleBounds.min.X and playerPosition.X <= obstacleBounds.max.X
	local collisionY = playerPosition.Y >= obstacleBounds.min.Y and playerPosition.Y <= obstacleBounds.max.Y
	local collisionZ = playerPosition.Z >= obstacleBounds.min.Z and playerPosition.Z <= obstacleBounds.max.Z

	return collisionX and collisionY and collisionZ
end

-- Modernes 3-Lane System (-1, 0, 1) kompatibel mit GameConstants
function switchLane(playerState: PlayerState, direction: number): boolean
	-- direction: -1 für links, 1 für rechts
	local newLane = playerState.currentLane + direction

	-- Überprüfe Lane-Grenzen (-1 bis 1)
	if newLane < -1 or newLane > 1 then
		return false -- Ungültiger Lane-Wechsel
	end

	-- Aktualisiere Player State
	playerState.currentLane = newLane
	updatePlayerPosition(playerState)

	print(`🏃 Lane-Wechsel zu Lane {newLane} (X: {getLanePosition(newLane)})`)
	return true
end

-- Integrierte Position-Update mit GameConstants
function updatePlayerPosition(playerState: PlayerState)
	-- Nutze GameConstants für konsistente Lane-Positionen
	local laneX = getLanePosition(playerState.currentLane)

	-- Aktualisiere Position unter Beibehaltung von Y und Z
	playerState.position = Vector3.new(
		laneX,
		playerState.startPosition.Y,
		playerState.position.Z -- Behalte aktuelle Z-Position (Fortschritt)
	)
end

-- Utility: Erstelle Player State
function createPlayerState(startPosition: Vector3): PlayerState
	return {
		currentLane = 0, -- Starte in der Mitte
		position = startPosition,
		startPosition = startPosition,
	}
end

-- Utility: Validiere Lane
function isValidLane(lane: number): boolean
	return lane >= -1 and lane <= 1
end

-- Advanced Kollisionserkennung mit Obstacle-Typ
function checkObstacleCollision(
	playerPosition: Vector3,
	obstacleData: any
): { collided: boolean, obstacleType: string? }
	if not obstacleData or not obstacleData.position or not obstacleData.size then
		return { collided = false }
	end

	local collision = checkCollision(playerPosition, obstacleData.position, obstacleData.size)

	return {
		collided = collision,
		obstacleType = obstacleData.type or "UNKNOWN",
	}
end

-- Export für andere Module
return {
	checkCollision = checkCollision,
	switchLane = switchLane,
	updatePlayerPosition = updatePlayerPosition,
	createPlayerState = createPlayerState,
	isValidLane = isValidLane,
	checkObstacleCollision = checkObstacleCollision,
	getLanePosition = getLanePosition,
}
