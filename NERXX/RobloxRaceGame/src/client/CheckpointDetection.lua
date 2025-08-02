-- Checkpoint Detection System
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Warte auf Events
repeat wait() until ReplicatedStorage:FindFirstChild("Events")
local Events = ReplicatedStorage.Events

-- Checkpoint-Erkennungs-System für Server
local function setupCheckpointDetection()
    local checkpointsFolder = workspace:WaitForChild("Checkpoints")
    
    for _, checkpoint in pairs(checkpointsFolder:GetChildren()) do
        if checkpoint:IsA("Part") then
            -- Touch Event für Checkpoint
            checkpoint.Touched:Connect(function(hit)
                local humanoid = hit.Parent:FindFirstChild("Humanoid")
                if humanoid then
                    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                    if player then
                        local checkpointId = tonumber(checkpoint.Name:match("%d+"))
                        if checkpointId then
                            Events.CheckpointReached:FireServer(checkpointId)
                        end
                    end
                end
            end)
        end
    end
end

-- Warte auf Workspace-Setup
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Checkpoints" then
        setupCheckpointDetection()
    end
end)

-- Falls Checkpoints bereits existieren
if workspace:FindFirstChild("Checkpoints") then
    setupCheckpointDetection()
end

print("Checkpoint Detection initialized!")
