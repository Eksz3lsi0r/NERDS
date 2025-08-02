-- Bubble Effects Manager für die Hände der Spieler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Warte auf Config
repeat wait() until ReplicatedStorage:FindFirstChild("Config")
local Config = require(ReplicatedStorage.Config)

-- Bubble State
local bubbleEffects = {
    leftHand = nil,
    rightHand = nil,
    enabled = true
}

-- Erstelle Blasen-Partikel-Effekt
local function createBubbleParticles(attachment)
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "HandBubbles"
    particles.Parent = attachment
    
    -- Bubble Texture (verwende Sparkles als Platzhalter)
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    
    -- Bubble Properties
    particles.Lifetime = NumberRange.new(1.5, 3.0)
    particles.Rate = 15
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(3, 8)
    particles.Acceleration = Vector3.new(0, 5, 0) -- Blasen steigen auf
    
    -- Size Animation (klein -> groß -> klein)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.3, 0.5),
        NumberSequenceKeypoint.new(0.7, 0.8),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    
    -- Farbe (verschiedene Blau-/Türkis-Töne)
    local colors = {
        Color3.fromRGB(100, 200, 255), -- Hell-Blau
        Color3.fromRGB(150, 255, 200), -- Türkis
        Color3.fromRGB(200, 230, 255), -- Pastell-Blau
        Color3.fromRGB(120, 255, 255)  -- Cyan
    }
    particles.Color = ColorSequence.new(colors[math.random(#colors)])
    
    -- Transparenz (sichtbar -> durchsichtig)
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.8, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    
    -- Licht-Emission für Glow-Effekt
    particles.LightEmission = 0.6
    particles.LightInfluence = 0.2
    
    return particles
end

-- Setup Blasen für eine Hand
local function setupHandBubbles(hand, side)
    if not hand or not bubbleEffects.enabled then return end
    
    -- Erstelle Attachment für Partikel
    local attachment = hand:FindFirstChild("BubbleAttachment")
    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = "BubbleAttachment"
        attachment.Parent = hand
        
        -- Positioniere Attachment an der Handfläche
        if side == "left" then
            attachment.Position = Vector3.new(0, 0, -0.5)
        else
            attachment.Position = Vector3.new(0, 0, -0.5)
        end
    end
    
    -- Erstelle Partikel-Effekt
    local particles = createBubbleParticles(attachment)
    bubbleEffects[side] = particles
    
    -- Zusätzlicher Glow-Effekt
    local pointLight = Instance.new("PointLight")
    pointLight.Name = "BubbleGlow"
    pointLight.Parent = hand
    pointLight.Color = Color3.fromRGB(150, 200, 255)
    pointLight.Brightness = 0.5
    pointLight.Range = 8
    
    return particles
end

-- Entferne Blasen-Effekte
local function removeBubbleEffects(side)
    if bubbleEffects[side] then
        bubbleEffects[side]:Destroy()
        bubbleEffects[side] = nil
    end
end

-- Update Blasen basierend auf Character
local function updateBubbleEffects()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Erkenne Hand-Parts (R15 und R6 kompatibel)
    local leftHand = player.Character:FindFirstChild("LeftHand") or player.Character:FindFirstChild("Left Arm")
    local rightHand = player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm")
    
    -- Setup oder Update Blasen für linke Hand
    if leftHand and not bubbleEffects.leftHand and bubbleEffects.enabled then
        setupHandBubbles(leftHand, "leftHand")
    elseif not leftHand and bubbleEffects.leftHand then
        removeBubbleEffects("leftHand")
    end
    
    -- Setup oder Update Blasen für rechte Hand
    if rightHand and not bubbleEffects.rightHand and bubbleEffects.enabled then
        setupHandBubbles(rightHand, "rightHand")
    elseif not rightHand and bubbleEffects.rightHand then
        removeBubbleEffects("rightHand")
    end
    
    -- Entferne alle Effekte wenn deaktiviert
    if not bubbleEffects.enabled then
        removeBubbleEffects("leftHand")
        removeBubbleEffects("rightHand") 
        
        -- Entferne auch Glow-Effekte
        if leftHand then
            local glow = leftHand:FindFirstChild("BubbleGlow")
            if glow then glow:Destroy() end
        end
        if rightHand then
            local glow = rightHand:FindFirstChild("BubbleGlow")
            if glow then glow:Destroy() end
        end
    end
end

-- Toggle Blasen on/off
local function toggleBubbles(enabled)
    bubbleEffects.enabled = enabled
    
    if not enabled then
        removeBubbleEffects("leftHand")
        removeBubbleEffects("rightHand")
    end
end

-- Event Handler für Toggle
if ReplicatedStorage:FindFirstChild("Events") then
    local Events = ReplicatedStorage.Events
    if Events:FindFirstChild("ToggleBubbles") then
        Events.ToggleBubbles.OnClientEvent:Connect(function(enabled)
            toggleBubbles(enabled)
        end)
    end
end

-- Main Update Loop
RunService.Heartbeat:Connect(updateBubbleEffects)

-- Character Respawn Handler
player.CharacterAdded:Connect(function()
    -- Reset bubble effects
    bubbleEffects.leftHand = nil
    bubbleEffects.rightHand = nil
    
    -- Warte bis Character geladen ist
    wait(1)
    updateBubbleEffects()
end)

-- Initial Setup
if player.Character then
    updateBubbleEffects()
end

print("Bubble Effects Manager initialized for", player.Name)
