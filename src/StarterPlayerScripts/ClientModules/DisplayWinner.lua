local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DisplayWinner = {}
DisplayWinner.dependencies = {
    modules = {"Gui"},
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

function DisplayWinner.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.winnerGui
    remotes.DisplayWinner.OnClientEvent:Connect(DisplayWinner.display)
end

function DisplayWinner.display(winnerName)
    -- Git Test! v2
    gui.diff.Text = winnerName
    gui.Enabled = true
end

function DisplayWinner.hide()
    gui.Enabled = false
end

return DisplayWinner