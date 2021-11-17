local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local MusicPlayer = {}
MusicPlayer.dependencies = {
    modules = {},
    utilities = {"Shuffle"},
    dataStructures = {"Queue"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local musicIds = {
    474829770,
    4919760420,
    1835749037,
    1841979451,
    1837566969
}
local musicQueue
local customQueue
local soundObjects

---- Public Functions ----

function MusicPlayer.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    musicQueue = dataStructures.Queue.new()
    customQueue = dataStructures.Queue.new()
    soundObjects = dataStructures.Queue.new()
    for _, id in ipairs(utilities.Shuffle(musicIds)) do
        local sound = Instance.new("Sound")
        sound.SoundId = string.format("rbxassetid://%d", id)
        sound.Volume = 0.5
        sound.Parent = CollectionService:GetTagged("speaker")[1]
        if not sound.IsLoaded then
            sound.Loaded:Wait()
        end
        musicQueue:enqueue(sound)
    end
    task.spawn(MusicPlayer.start)
end

function MusicPlayer.start()
    while true do
        local sound = customQueue:dequeue()
        if sound then
            -- Using custom sound
            sound:Play()
            sound.Ended:Wait()
            soundObjects:enqueue(sound)
        else
            sound = musicQueue:dequeue()
            if sound then
                musicQueue:enqueue(sound)
                sound:Play()
                sound.Ended:Wait()
            end
        end   
    end
end

function MusicPlayer.addToQueue(id)
    local sound = soundObjects:dequeue()
    if not sound then
        sound = Instance.new("Sound")
        sound.Volume = 0.5
        sound.Parent = CollectionService:GetTagged("speaker")[1]
    end
    sound.SoundId = string.format("rbxassetid://%d", id)
    customQueue:enqueue(sound)
end

return MusicPlayer