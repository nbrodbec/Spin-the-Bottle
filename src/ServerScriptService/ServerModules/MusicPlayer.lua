local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local MusicPlayer = {}
MusicPlayer.dependencies = {
    modules = {"Permissions", "Chat"},
    utilities = {"Shuffle"},
    dataStructures = {"Queue"},
    constants = {"MusicList"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local musicQueue
local customQueue
local pending = {}

local recordScratchSounds = {}

---- Public Functions ----

function MusicPlayer.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    musicQueue = dataStructures.Queue.new()
    customQueue = dataStructures.Queue.new()
    for _, id in ipairs(utilities.Shuffle(constants.MusicList)) do
        local sounds = {}
        for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
            local sound = Instance.new("Sound")
            sound.SoundId = string.format("rbxassetid://%d", id)
            sound.Volume = 0.5
            sound.Parent = musicPlayer
            if not sound.IsLoaded then
                sound.Loaded:Wait()
            end
            table.insert(sounds, sound)
        end
        musicQueue:enqueue(sounds)
    end

    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        local recordScratch = Instance.new("Sound")
        recordScratch.SoundId = "rbxassetid://3325007292"
        recordScratch.Parent = musicPlayer
        table.insert(recordScratchSounds, recordScratch)
    end


    function remotes.RequestMusic.OnServerInvoke(player, id)
        local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
        if success then
            if info.AssetTypeId == 3 then
                if info.IsPublicDomain then
                    MusicPlayer.pendRequest(player, id)
                    if modules.Permissions.hasPermissions(player, 3) then
                        MusicPlayer.confirmRequest(player)
                        modules.Chat.makeSystemMessage(
                            string.format("%s has requested song: %s", player.DisplayName, info.Name),
                            Color3.new(1, 0.901960, 0)
                        )
                        return true
                    else
                        local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, 1235048301)
                        if not success then
                            print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
                        end
                        return true, "Added to queue!"
                    end
                else
                    return false, "Sound unavailable!"
                end
            else
                return false, "Invalid ID!"
            end
        else
            return false, "Invalid ID!"
        end
    end

    task.spawn(MusicPlayer.start)
end

function MusicPlayer.pendRequest(player, id)
    pending[player] = id
end

function MusicPlayer.confirmRequest(player)
    local id = pending[player]
    if id then
        MusicPlayer.addToQueue(id)
        pending[player] = nil
        return id
    end
end

local isCustom = false
local playingSounds
function MusicPlayer.start()
    while true do
        local sounds = customQueue:dequeue()
        if sounds then
            if not isCustom then
                for _, v in ipairs(recordScratchSounds) do
                    v:Play()
                end
                recordScratchSounds[1].Ended:Wait()
            end
            isCustom = true
            playingSounds = sounds
            for _, v in ipairs(sounds) do
                v:Play()
            end
            sounds[1].Ended:Wait()
            for _, v in ipairs(sounds) do
                v:Destroy()
            end
        else
            isCustom = false
            sounds = musicQueue:dequeue()
            if sounds then
                playingSounds = sounds
                musicQueue:enqueue(sounds)
                for _, v in ipairs(sounds) do
                    v:Play()
                end
                sounds[1].Ended:Wait()
            end
        end   
    end
end

function MusicPlayer.addToQueue(id)
    local sounds = {}
    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        local sound = Instance.new("Sound")
        sound.Volume = 0.5
        sound.SoundId = string.format("rbxassetid://%d", id)
        sound.Parent = musicPlayer
        table.insert(sounds, sound)
    end
    
    customQueue:enqueue(sounds)
    if not isCustom and playingSounds then
        for _, playingSound in ipairs(playingSounds) do
            playingSound.TimePosition = playingSound.TimeLength
        end
    end
end

return MusicPlayer