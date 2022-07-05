local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FusionComponent = {}
FusionComponent.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local components = {}

---- Public Functions ----

function FusionComponent.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    for _, module in ipairs(script:GetChildren()) do
        if module:IsA("ModuleScript") then
            components[module.Name] = require(module)
        end
    end
end

function FusionComponent.new(arg)
    if components[arg] then
        return components[arg]
    elseif New(arg) then
        return New(arg)
    else
        error(string.format("%s component does not exist!", arg))
    end
end

return FusionComponent