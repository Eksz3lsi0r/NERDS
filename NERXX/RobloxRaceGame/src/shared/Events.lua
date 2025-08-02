-- RemoteEvents für Client-Server Kommunikation
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Events Ordner erstellen
local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

-- Race Events
local StartRace = Instance.new("RemoteEvent")
StartRace.Name = "StartRace"
StartRace.Parent = Events

local FinishRace = Instance.new("RemoteEvent")
FinishRace.Name = "FinishRace"
FinishRace.Parent = Events

local UpdateLeaderboard = Instance.new("RemoteEvent")
UpdateLeaderboard.Name = "UpdateLeaderboard"
UpdateLeaderboard.Parent = Events

local CheckpointReached = Instance.new("RemoteEvent")
CheckpointReached.Name = "CheckpointReached"
CheckpointReached.Parent = Events

-- Vehicle Events
local SpawnVehicle = Instance.new("RemoteEvent")
SpawnVehicle.Name = "SpawnVehicle"
SpawnVehicle.Parent = Events

local ResetVehicle = Instance.new("RemoteEvent")
ResetVehicle.Name = "ResetVehicle"
ResetVehicle.Parent = Events

-- Bubble Effects Event
local ToggleBubbles = Instance.new("RemoteEvent")
ToggleBubbles.Name = "ToggleBubbles"
ToggleBubbles.Parent = Events

print("Events setup complete!")
