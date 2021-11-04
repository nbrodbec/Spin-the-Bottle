local Players = game:GetService("Players")

local Death = {}
Death.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local player = Players.LocalPlayer

---- Private Functions ----

local function zoomOut()
    player.CameraMode = Enum.CameraMode.Classic
    player.CameraMinZoomDistance = 10
    player.CameraMinZoomDistance = 0
end

---- Public Functions ----

function Death.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        zoomOut()
        humanoid.Seated:Connect(function()
            player.CameraMode = Enum.CameraMode.LockFirstPerson
        end)
        humanoid.Died:Connect(zoomOut)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then onCharacterAdded(player.Character) end
end

return Death