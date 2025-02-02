local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Intermission = {}
Intermission.dependencies = {
    modules = {"Gui", "MinimumPlayers", "Transition", "DisplayWinner", "Menu"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local gui

---- Public Functions ----

function Intermission.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.timerGui

    remotes.StartIntermission.OnClientEvent:Connect(function(t)
        Intermission.start(t)
    end)
end

local aborted = false
function Intermission.start(startTime)
    modules.MinimumPlayers.hide()
    modules.DisplayWinner.hide()
    gui.Enabled = true
    startTime -= 1.5
    local timeLeft = startTime - workspace:GetServerTimeNow()
    while workspace:GetServerTimeNow() < startTime and gui.Enabled do
        timeLeft = startTime - workspace:GetServerTimeNow()
        local t = math.floor(timeLeft)
        RunService.Heartbeat:Wait()
        local m = math.floor(t/60)
        local s = t % 60
        gui.Timer.Text = string.format("%.1d:%.2d", m, s)

        if t%2 == 1 and not SoundService.ClockTick.Playing then
            SoundService.ClockTick:Play()
        end
    end

    if aborted then
        aborted = false
    else
        modules.Transition.start(3)
    end
    
    gui.Enabled = false
    modules.Menu.closeAll()
end

function Intermission.stop()
    gui.Enabled = false
    aborted = true
end

return Intermission