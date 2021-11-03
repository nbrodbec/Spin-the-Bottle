local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Chat = {}
Chat.dependencies = {
    modules = {"Marketplace"},
    utilities = {},
    dataStructures = {},
    constants = {"GamepassIDs"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local ChatService

---- Public Functions ----

function Chat.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

    ChatService.SpeakerAdded:Connect(function(name)
        local player = Players:FindFirstChild(name)
        local speaker = ChatService:GetSpeaker(name)
        if player and modules.Marketplace.playerHasPass(player, constants.GamepassIDs.VIP) then
            Chat.addTag(player, {
                TagText = "VIP",
                TagColor = Color3.new(0.898039, 1, 0)
            })
        end
    end)

    -- TODO: add rate limiter
    remotes.ChangeChatColor.OnServerEvent:Connect(function(player, color3)
        if modules.Marketplace.playerHasPass(player, constants.GamepassIDs.VIP) then
            if typeof(color3) == "Color3" then
                Chat.changeNameColor(player, color3)
            end
        end
    end)
end

function Chat.addTag(player, tag)
    local speaker = ChatService:GetSpeaker(player.Name)
    local tags = speaker:GetExtraData("Tags")
    table.insert(tags, tag)
    speaker:SetExtraData("Tags", tags)
end

function Chat.changeNameColor(player, color)
    local speaker = ChatService:GetSpeaker(player.Name)
    speaker:SetExtraData("NameColor", color)
end

return Chat