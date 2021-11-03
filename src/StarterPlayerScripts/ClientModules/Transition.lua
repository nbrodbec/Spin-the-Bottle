local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Transition = {}
Transition.dependencies = {
    modules = {"Gui"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local player = Players.LocalPlayer
local gui

---- Public Functions ----

function Transition.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.transitionGui

end

function Transition.start(t, yield)
    t = t or 2
    local tween = TweenService:Create(
        gui.Fade,
        TweenInfo.new(
            t/2, 
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut,
            0,
            true
        ),
        {BackgroundTransparency = 0}
    )
    tween:Play()
    if yield then tween.Completed:Wait() end
end

return Transition