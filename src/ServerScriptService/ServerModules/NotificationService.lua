local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local NotificationService = {}
NotificationService.dependencies = {
    modules = {},
    utilities = {"Timer"},
    dataStructures = {"Queue"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local queues = {}
local readyPlayers = {}

---- Public Functions ----

function NotificationService.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    remotes.PlayerReadyEvent.OnServerEvent:Connect(function(player)
        readyPlayers[player] = true
    end)
    Players.PlayerRemoving:Connect(function(player)
        readyPlayers[player] = nil
        queues[player] = nil
    end)
    
    RunService.Heartbeat:Connect(function(deltaTime)
        for player, info in pairs(queues) do
            if readyPlayers[player] then
                if not info.timer.running then
                    local nextNotification = info.queue:dequeue()
                    if nextNotification then
                        remotes.NotifyClient:FireClient(player, nextNotification.message)
                        info.timer:start()
                    end
                end
            end
        end
    end)
end

function NotificationService.notifyClient(player, message)
    local info = queues[player] or {queue = dataStructures.Queue.new(), timer = utilities.Timer.new(5)}
    queues[player] = info
    info.queue:enqueue({
        message = message
    })
end

return NotificationService