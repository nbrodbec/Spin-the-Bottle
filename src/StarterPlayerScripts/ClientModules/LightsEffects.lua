local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightingService = game:GetService("Lighting")

local LightsEffects = {}
LightsEffects.dependencies = {
    modules = {"Gui"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local blackScreen

---- Public Functions ----

function LightsEffects.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    remotes.LightsOff.OnClientEvent:Connect(LightsEffects.lightsOff)
    remotes.LightsOn.OnClientEvent:Connect(LightsEffects.lightsOn)

    blackScreen = modules.Gui.transitionGui.Fade
end

function LightsEffects.lightsOn()
    if not workspace.Components.LIGHT.SurfaceLight.Enabled then
        workspace.Components.LIGHT.LightBuzz:Play()
        workspace.Components.LIGHT.Material = Enum.Material.Neon
        workspace.Components.LIGHT.SurfaceLight.Enabled = true
        blackScreen.BackgroundTransparency = 1
        
        LightingService.Atmosphere.Density = 0.3
        LightingService.Atmosphere.Offset = 0.25
        LightingService.Atmosphere.Haze = 1
        LightingService.Brightness = 2.7
    end
end

function LightsEffects.lightsOff()
    if workspace.Components.LIGHT.SurfaceLight.Enabled then
        workspace.Components.LIGHT.GlassSmash:Play()
        workspace.Components.LIGHT.Material = Enum.Material.SmoothPlastic
        workspace.Components.LIGHT.SurfaceLight.Enabled = false
        blackScreen.BackgroundTransparency = 0.05
        
        LightingService.Atmosphere.Density = 1
        LightingService.Atmosphere.Offset = 0
        LightingService.Atmosphere.Haze = 0
        LightingService.Brightness = 0
    end
end

return LightsEffects