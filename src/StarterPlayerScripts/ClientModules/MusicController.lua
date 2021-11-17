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
    
    local isMuted = false
    modules.Gui.menuGui.Footer.Mute.Activated:Connect(function()
        if isMuted then
            MusicController.unpause()
            modules.Gui.menuGui.Footer.Mute.ImageRectOffset = Vector2.new(684, 324)
        else
            MusicController.pause()
            modules.Gui.menuGui.Footer.Mute.ImageRectOffset = Vector2.new(4, 404)
        end
        isMuted = not isMuted
    end)
end

function MusicController.pause()
    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        for _, descendant in ipairs(musicPlayer:GetDescendants()) do
            if descendant:IsA("Sound") then
                descendant.Volume = 0
            end
        end
    end
end

function MusicController.unpause()
    for _, musicPlayer in ipairs(CollectionService:GetTagged("speaker")) do
        for _, descendant in ipairs(musicPlayer:GetDescendants()) do
            if descendant:IsA("Sound") then
                descendant.Volume = 0.5
            end
        end
    end
end

return MusicController