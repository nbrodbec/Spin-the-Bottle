local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local BoundaryHandler = {}
BoundaryHandler.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local spawns = workspace:WaitForChild("Spawns")

---- Public Functions ----

function BoundaryHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function newBoundaryPart(part)
        part.Touched:Connect(function(hit)
            if Players:GetPlayerFromCharacter(hit.Parent) then
                local root = hit.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    local spawns = spawns:GetChildren()
                    root.CFrame = spawns[math.random(#spawns)].CFrame + Vector3.new(0, 3, 0)
                end
            end
        end)
    end

    CollectionService:GetInstanceAddedSignal("boundary"):Connect(newBoundaryPart)
    for _, part in ipairs(CollectionService:GetTagged("boundary")) do
        newBoundaryPart(part)
    end
end

return BoundaryHandler