local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundAnnouncement = {}
RoundAnnouncement.dependencies = {
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

function RoundAnnouncement.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.announcementGui
    remotes.RoundMode.OnClientEvent:Connect(RoundAnnouncement.announce)
end

function RoundAnnouncement.announce(msg)
    gui.RoundName.Text = msg
    gui.Enabled = true
    task.delay(3, function ()
        gui.Enabled = false
    end)
end

return RoundAnnouncement