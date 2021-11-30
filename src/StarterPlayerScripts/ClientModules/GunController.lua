local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunController = {}
GunController.dependencies = {
    modules = {"Stress"},
    utilities = {"Timer", "CameraShaker"},
    dataStructures = {},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local player = Players.LocalPlayer

local timer
local otherPlayers
local startingC0

---- Private Functions ----

local function getPlayerAtCursor()
    local camera = workspace.CurrentCamera
    local cameraToMouse = camera.CFrame.LookVector

    local closestTheta = 2*math.pi
    local closestPlayer
    for _, p in ipairs(otherPlayers) do
        if not (p.Parent and p.Character) then continue end
        local cameraToPlayer = (p.Character.Head.Position - camera.CFrame.Position).Unit
        local theta = math.acos(cameraToPlayer:Dot(cameraToMouse))
        if theta < closestTheta then
            closestTheta = theta
            closestPlayer = p
        end
    end
    return closestPlayer
end

local function disableJumpButton()
    local touchGui = player.PlayerGui:FindFirstChild("TouchGui")
    if touchGui then
        local jumpButton = touchGui.TouchControlFrame:FindFirstChild("JumpButton")
        if jumpButton then
            jumpButton:Destroy()
        end
    end
end

local gun
local marker
local isBlank
local killed

---- Public Functions ----

function GunController.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    GunController.cameraShaker = utilities.CameraShaker.new(Enum.RenderPriority.Last.Value, function(shakeCf)
        workspace.CurrentCamera.CFrame *= shakeCf
    end)
    remotes.GiveGunEvent.OnClientEvent:Connect(function(players, g, blank)
        timer = utilities.Timer.new(constants.Values.TIME_WITH_GUN)
        timer:start()
        task.spawn(modules.Stress.beginStress)
        GunController.giveGun()

        otherPlayers = players
        gun = g
        isBlank = blank

        timer:yield()
        task.wait(1)
        GunController.removeGun()
    end)
    remotes.UpdateGunJoint.OnClientEvent:Connect(GunController.updateJoint)
    remotes.TargetChosen.OnClientEvent:Connect(function(p, g, blank)
        if p == player then return end
        if not blank then
            for _, child in ipairs(g.Muzzle:GetChildren()) do
                if child:IsA("ParticleEmitter") or child:IsA("Light") then
                    child.Enabled = true
                    task.delay(0.1, function()
                        child.Enabled = false
                    end)
                end
            end
            GunController.cameraShaker:Start()
            GunController.cameraShaker:Shake(utilities.CameraShaker.Presets.Bump)
            task.delay(1, function()
                GunController.cameraShaker:Stop()
            end)
            g.Muzzle.Sound:Play()
        else
            g.Muzzle.Blank:Play()
        end
    end)
end

local connection
function GunController.giveGun(model)
    disableJumpButton()
    gun = model
    marker = ReplicatedStorage.Arrow:Clone()
    marker.Parent = workspace
    ContextActionService:BindAction("shoot", GunController.shoot, true, Enum.UserInputType.MouseButton1)
    ContextActionService:SetTitle("shoot", "Fire")
    ContextActionService:BindAction("aim", GunController.aim, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
    killed = nil
    local t = 0
    connection = RunService.Heartbeat:Connect(function(deltaTime)
        t += deltaTime
        if t > 0.1 then
            t -= 0.1
            remotes.UpdateGunJoint:FireServer(player.Character.Torso["Right Shoulder"].C0)
        end
        if marker then
            marker.CFrame *= CFrame.Angles(0, 0, t*math.pi/2)
        end
    end)
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            connection:Disconnect()
            GunController.cameraShaker:Stop()
        end)
    end
end

local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function GunController.updateJoint(p, cframe)
    local char = p.Character 
    if not char then return end
    if p ~= player then
        local joint = char.Torso["Right Shoulder"]
        TweenService:Create(joint, tweenInfo, {C0 = cframe}):Play()
    end
end

function GunController.removeGun()
    if connection then connection:Disconnect() end
    if player.Character and player.Character.Humanoid.Health > 0 then
        player.Character.Torso["Right Shoulder"].C0 = startingC0
        remotes.UpdateGunJoint:FireServer(startingC0)
    end
    ContextActionService:UnbindAction("shoot")
    ContextActionService:UnbindAction("aim")
    modules.Stress.endStress()
    gun = nil
    marker:Destroy()
    marker = nil
end

function GunController.shoot(actionName, state, object)
    if state ~= Enum.UserInputState.Begin then return end
    if not timer.running then return end
    timer:stop()
    modules.Stress.endStress()
    killed = killed or getPlayerAtCursor()
    remotes.TargetChosen:FireServer(killed)
    if not isBlank then
        for _, child in ipairs(gun.Muzzle:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Light") then
                child.Enabled = true
                task.delay(0.1, function()
                    child.Enabled = false
                end)
            end
        end

        GunController.cameraShaker:Shake(utilities.CameraShaker.Presets.Bump)
        task.delay(1, function()
            GunController.cameraShaker:Stop()
        end)
        gun.Muzzle.Sound:Play()
    else
        GunController.cameraShaker:Stop()
        gun.Muzzle.Blank:Play()
    end
end


function GunController.aim(actionName, state, object)
    if state == Enum.UserInputState.Change then
        local mouse = player:GetMouse()
        local joint = player.Character.Torso["Right Shoulder"]
        if not startingC0 then startingC0 = joint.C0 end

        local arm = player.Character["Right Arm"]
        local target = getPlayerAtCursor() if not target then print(false) end
        killed = target
        target = target and target.Character.Head.Position or mouse.Hit.Position

        local pivotPos = (joint.Part0.CFrame * startingC0).Position
        
        local cframe = CFrame.lookAt(
            pivotPos,
            target
        ) * CFrame.Angles(0, 0, 0) * CFrame.new(arm.Size.X/2, -arm.Size.X/2, 0)
        joint.C0 = joint.Part0.CFrame:Inverse() * cframe * joint.C1

        marker.CFrame = (marker.CFrame - marker.CFrame.Position) + Vector3.new(0, 2, 0) + target
    end
    return Enum.ContextActionResult.Pass
end

return GunController