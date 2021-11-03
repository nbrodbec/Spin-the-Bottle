local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Stress = {}
Stress.dependencies = {
    modules = {"Gui", "GunController"},
    utilities = {"Timer"},
    dataStructures = {},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants

local player = Players.LocalPlayer
local gui
local timer
local sound = SoundService.TenseSound

---- Private Functions ----

local function revertStress()
    gui.Enabled = false
    Lighting.ColorCorrection.Contrast = -0.1
    Lighting.ColorCorrection.Saturation = -0.5
    gui.Timer.Bar.Size = UDim2.new(1, 0, 1, 0)
    gui.Vignette.ImageTransparency = 1
    sound:Stop()
end

---- Public Functions ----

function Stress.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    gui = modules.Gui.stressGui

    timer = utilities.Timer.new(constants.Values.TIME_WITH_GUN)
end

function Stress.beginStress()
    gui.Enabled = true
    Stress.stressed = true
    local barTween = TweenService:Create(gui.Timer.Bar, TweenInfo.new(constants.Values.TIME_WITH_GUN, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 1, 0)})
    barTween:Play()
    
    local vignetteTween = TweenService:Create(gui.Vignette, TweenInfo.new(12, Enum.EasingStyle.Exponential), {ImageTransparency = 0})
    vignetteTween:Play()		
    
    local colTween = TweenService:Create(Lighting:WaitForChild("ColorCorrection"), TweenInfo.new(10, Enum.EasingStyle.Linear), {Contrast = 0.3, Saturation = -1})
    colTween:Play()

    sound:Play()
    modules.GunController.cameraShaker:Start()
    modules.GunController.cameraShaker:StartShake(0.6, 3.5, constants.Values.TIME_WITH_GUN, Vector3.new(0.25, 0.25, 0.25), Vector3.new(1, 1, 4))

    timer:start():yield()
    vignetteTween:Cancel()
    barTween:Cancel()
    colTween:Cancel()
    revertStress()
end

function Stress.endStress()
    Stress.stressed = false
    timer:stop()
end

return Stress