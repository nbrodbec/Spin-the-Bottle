local RunService = game:GetService("RunService")

local Fan = {}
Fan.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function Fan.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local fan = workspace:WaitForChild("ClientFan")
    local speed = math.pi / 3
    RunService.Stepped:Connect(function(time, deltaTime)
        fan.CFrame *= CFrame.Angles(0, speed*deltaTime, 0)
    end)
end

return Fan