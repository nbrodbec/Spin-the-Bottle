local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local CharacterSounds = {}
CharacterSounds.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local sound = SoundService:WaitForChild("CustomSounds").Walking

---- Private Functions ----

local function setupFootsteps(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local defaultSound = rootPart:WaitForChild("Running", 10)
    if defaultSound then defaultSound.Volume = 0 end 

    humanoid.Running:Connect(function(speed)
        if speed > 0 and humanoid:GetState() == Enum.HumanoidStateType.Running then
            sound:Resume()
        else
            sound:Pause() 
        end
    end)
end

local function cleanupFootsteps(character)
   -- local humanoid = character:WaitForChild("Humanoid")

end

local function setupSounds(character)
    setupFootsteps(character)

    -- Silence death sound
    character:WaitForChild("HumanoidRootPart"):WaitForChild("Died").Volume = 0

    -- Silence jumping
    character:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end

local function cleanupSounds(character)
    cleanupFootsteps(character)

end

---- Public Functions ----

function CharacterSounds.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    local player = Players.LocalPlayer
    if player.Character then
        setupFootsteps(player.Character)
    end
    player.CharacterAdded:Connect(setupSounds)
    player.CharacterRemoving:Connect(cleanupSounds)

    local function onPlayerAdded(p)
        p.CharacterAdded:Connect(setupSounds)
        p.CharacterRemoving:Connect(cleanupSounds)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then onPlayerAdded(p) end
    end
end

return CharacterSounds