local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AFKStatusHandler = {}
AFKStatusHandler.dependencies = {
    modules = {"GameLoop", "Intermission"},
    utilities = {"RateLimiter"},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local afkList = {}

---- Public Functions ----

function AFKStatusHandler.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local rateLimiter = utilities.RateLimiter.new(5)
    function remotes.ChangeAFKStatus.OnServerInvoke(player)
        if rateLimiter:check(player) then
            if afkList[player] then
                modules.GameLoop.addPlayer(player)
                afkList[player] = nil
                return false
            else
                modules.GameLoop.removePlayer(player)
                afkList[player] = true
                return true
            end
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        afkList[player] = nil
    end)

    modules.Intermission.begin.Event:Connect(function()
        for player in pairs(afkList) do
            modules.GameLoop.addPlayer(player)
            afkList[player] = nil
        end
    end)
end

return AFKStatusHandler