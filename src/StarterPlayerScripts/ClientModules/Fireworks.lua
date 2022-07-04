local SoundService = game:GetService("SoundService")
local Fireworks = {}
Fireworks.dependencies = {
    modules = {},
    utilities = {"Shuffle"},
    dataStructures = {"Queue"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local soundIds = {
    269146157,
    8390138483,
    138080762
}
local soundObjects = {}

---- Public Functions ----

function Fireworks.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    

    for _, id in ipairs(soundIds) do
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..tostring(id)
        sound.Volume = 0.15
        local effect = Instance.new("PitchShiftSoundEffect")
        effect.Octave = 0.60
        sound.Parent = SoundService
        effect.Parent = sound

        table.insert(soundObjects, sound)
    end

    task.spawn(function()
        while true do
            utilities.Shuffle(soundObjects)
            for i, sound in ipairs(soundObjects) do
                sound:Play()
                sound.Ended:Wait()
                task.wait(math.random(1, 20))
            end
        end
    end)
end

return Fireworks