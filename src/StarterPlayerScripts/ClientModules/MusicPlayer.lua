local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local MusicPlayer = {}
MusicPlayer.dependencies = {
    modules = {"Gui"},
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

---- Public Functions ----

function MusicPlayer.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    musicQueue = dataStructures.Queue.new()
    for _, id in ipairs(utilities.Shuffle(musicIds)) do
        local sound = Instance.new("Sound")
        sound.SoundId = string.format("rbxassetid://%d", id)
        sound.Parent = CollectionService:GetTagged("speaker")[1]
        if not sound.IsLoaded then
            sound.Loaded:Wait()
        end
        musicQueue:enqueue(sound)
    end
    task.spawn(MusicPlayer.start)

    local isMuted = false
    modules.Gui.menuGui.Mute.Activated:Connect(function()
        if isMuted then
            MusicPlayer.unpause()
            modules.Gui.menuGui.Mute.ImageRectOffset = Vector2.new(684, 324)
        else
            MusicPlayer.pause()
            modules.Gui.menuGui.Mute.ImageRectOffset = Vector2.new(4, 404)
        end
        isMuted = not isMuted
    end)
end

function MusicPlayer.start()
    while true do
        local sound = musicQueue:dequeue()
        if sound then
            musicQueue:enqueue(sound)
            sound:Play()
            sound.Ended:Wait()
        end
    end
end

function MusicPlayer.pause()
    local sound = musicQueue:peekTail()
    if sound then sound:Pause() end
end

function MusicPlayer.unpause()
    local sound = musicQueue:peekTail()
    if sound then sound:Resume() end
end

return MusicPlayer