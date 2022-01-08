local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterController = {}
CharacterController.dependencies = {
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

function CharacterController.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function onPlayerAdded(player)
        local function onCharacterAdded(character)
            local function setGroup(part)
                if not part:IsA("BasePart") then return end
                PhysicsService:SetPartCollisionGroup(part, "Character")
            end
            for _, v in ipairs(character:GetDescendants()) do
                setGroup(v)
            end
            character.DescendantAdded:Connect(setGroup)

            local head = character:WaitForChild("Head")
            for _, particle in ipairs(ReplicatedStorage.Effects.Blood:GetChildren()) do
                particle:Clone().Parent = head
            end
        end
        player.CharacterAdded:Connect(onCharacterAdded)
        if player.Character then
            onCharacterAdded(player.Character)
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, p in ipairs(Players:GetPlayers()) do
        onPlayerAdded(p)
    end
end

return CharacterController