local CollectionService = game:GetService("CollectionService")
local MusicController = {}
MusicController.dependencies = {
    modules = {"Gui"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

---- Public Functions ----

function MusicController.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
end

function MusicController.mute()
    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        for _, descendant in ipairs(musicPlayer:GetDescendants()) do
            if descendant:IsA("Sound") then
                descendant.Volume = 0
            end
        end
    end
end

function MusicController.unmute()
    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        for _, descendant in ipairs(musicPlayer:GetDescendants()) do
            if descendant:IsA("Sound") then
                descendant.Volume = 0.5
            end
        end
    end
end

return MusicController