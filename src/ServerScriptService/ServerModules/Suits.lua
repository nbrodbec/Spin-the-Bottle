local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Suits = {}
Suits.dependencies = {
    modules = {"Data"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function Suits.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function onPlayerAdded(player)
        local function onCharacterAdded(character)
            local suit = modules.Data.get(player, "suit")
            local humanoid = character:WaitForChild("Humanoid")
            local description = humanoid:GetAppliedDescription()
            local suitFolder = ServerStorage.Suits:FindFirstChild(suit)
            
            description.Shirt = suit.shirt
            description.Pants = suit.pants

            humanoid:ApplyDescription(description)
        end
        player.CharacterAppearanceLoaded:Connect(onCharacterAdded)
        
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
    end
end

return Suits