local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Death = {}
Death.dependencies = {
    modules = {"Data", "Marketplace"},
    utilities = {},
    dataStructures = {},
    constants = {"GamepassIDs"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

---- Private Functions ----

local function newJoint(oldJoint, character, part, constraint_class)
    local joint_info = oldJoint

    if joint_info == nil then
        return nil
    end

    local part0 = character.Torso
    local part1 = part

    if part0 == nil or part1 == nil then
        return nil
    end
    
    local angle_multiply = CFrame.new()

    if constraint_class == "BallSocketConstraint" then
        angle_multiply = CFrame.Angles(0, 0, -math.pi / 2)
    end

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "ConstraintAttachment"
    attachment0.CFrame = joint_info.C0 * angle_multiply
    attachment0.Parent = part0

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "ConstraintAttachment"
    attachment1.CFrame = joint_info.C1 * angle_multiply
    attachment1.Parent = part1

    local constraint = Instance.new(constraint_class)
    constraint.Name = part0.Name
    
    constraint.Attachment0 = attachment0
    constraint.Attachment1 = attachment1
    
    constraint.Parent = part1
    
    return constraint  
end

local function ragdollify(character)
    local torso = character.Torso

    -- Neck
    local neckConstraint = newJoint(torso.Neck, character, character.Head, "BallSocketConstraint") do
        neckConstraint.MaxFrictionTorque = 20
        neckConstraint.LimitsEnabled = true
        neckConstraint.TwistLimitsEnabled = true
        neckConstraint.UpperAngle = 20
        neckConstraint.TwistLowerAngle = -45
        neckConstraint.TwistUpperAngle = 45
    end

    --Left Shoulder
    local leftShoulderConstraint = newJoint(torso["Left Shoulder"], character, character["Left Arm"], "BallSocketConstraint") do
        leftShoulderConstraint.LimitsEnabled = true
        leftShoulderConstraint.TwistLimitsEnabled = true
        leftShoulderConstraint.UpperAngle = 45
        leftShoulderConstraint.MaxFrictionTorque = 3
    end

    --Right Shoulder
    local rightShoulderConstraint = newJoint(torso["Right Shoulder"], character, character["Right Arm"], "BallSocketConstraint") do
        rightShoulderConstraint.LimitsEnabled = true
        rightShoulderConstraint.TwistLimitsEnabled = true
        rightShoulderConstraint.UpperAngle = 45
        rightShoulderConstraint.MaxFrictionTorque = 3
    end

    --Left Hip
    local leftHipConstraint = newJoint(torso["Left Hip"], character, character["Left Leg"], "BallSocketConstraint") do
        leftHipConstraint.LimitsEnabled = true
        leftHipConstraint.TwistLimitsEnabled = true
        leftHipConstraint.UpperAngle = 45
        leftHipConstraint.MaxFrictionTorque = 3
    end

    --Right Hip
    local rightHipConstraint = newJoint(torso["Right Hip"], character, character["Right Leg"], "BallSocketConstraint") do
        rightHipConstraint.LimitsEnabled = true
        rightHipConstraint.TwistLimitsEnabled = true
        rightHipConstraint.UpperAngle = 45
        rightHipConstraint.MaxFrictionTorque = 3      
    end

    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("Motor6D") then v:Destroy() end
    end
end

---- Public Functions ----

function Death.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            local rootPart = character:WaitForChild("HumanoidRootPart")
            humanoid.BreakJointsOnDeath = false

            local sound = Instance.new("Sound")
            local animation = Instance.new("Animation")
            local id = modules.Data.get(player, "deathAnimId")
            local animTrack
            if id then
                if not character.Parent then character.AncestryChanged:Wait() end
                animation.AnimationId = "rbxassetid://"..id
                animation.Parent = character
                animTrack = humanoid:WaitForChild("Animator"):LoadAnimation(animation)
            end
            
            humanoid.Died:Connect(function()
                sound:Play()
                if animTrack then
                    rootPart.Anchored = true
                    animTrack:Play()
                else 
                    ragdollify(character)
                end
                task.delay(2, function()
                    for i = sound.Volume, 0, -sound.Volume/10 do
                        task.wait(1/10)
                        sound.Volume = i
                    end
                end)
            end)
            sound.SoundId = modules.Data.get(player, "deathSound")
            sound.Parent = character:WaitForChild("Head")
        end)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    function remotes.ChangeAudio.OnServerInvoke(player, id)
        if modules.Marketplace.playerHasPass(player, constants.GamepassIDs.AUDIO) then
            local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
            if success then
                if info.AssetTypeId == 3 then
                    if info.IsPublicDomain then
                        modules.Data.set(player, "deathSound", string.format("rbxassetid://%d", id))
                        if player.Character then
                            if player.Character.Head:FindFirstChild("Sound") then
                                player.Character.Head.Sound.SoundId = string.format("rbxassetid://%d", id)
                            end
                        end
                        return true
                    else
                        return false, "Sound unavailable!"
                    end
                else
                    return false, "Invalid ID!"
                end
            else
                return false, "Invalid ID!"
            end
        end
        return false, "Unexpected Error!"
    end
end

return Death