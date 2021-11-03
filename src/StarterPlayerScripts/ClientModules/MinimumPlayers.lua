local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MinimumPlayers = {}
MinimumPlayers.dependencies = {
    modules = {"Gui", "DisplayWinner"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local gui

---- Public Functions ----

function MinimumPlayers.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.minPlayersGui

    remotes.MinimumPlayers.OnClientEvent:Connect(function(diff)
        MinimumPlayers.update(diff)
        MinimumPlayers.show()
    end)
end

function MinimumPlayers.show()
    modules.DisplayWinner.hide()
    gui.Enabled = true
end

function MinimumPlayers.hide()
    gui.Enabled = false
end

function MinimumPlayers.update(diff)
    gui.diff.Text = string.format("%d more player%s required for the game to start", diff, diff > 1 and "s are" or " is")
end

return MinimumPlayers