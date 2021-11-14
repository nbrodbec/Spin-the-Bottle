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

function Intermission.start(startTime)
    modules.MinimumPlayers.hide()
    modules.DisplayWinner.hide()
    gui.Enabled = true
    startTime -= 1.5
    local timeLeft = startTime - DateTime.now().UnixTimestampMillis/1000
    local lastSecond = 0
    while DateTime.now().UnixTimestampMillis/1000 < startTime do
        timeLeft = startTime - DateTime.now().UnixTimestampMillis/1000
        local t = math.floor(timeLeft)
        RunService.Heartbeat:Wait()
        local m = math.floor(t/60)
        local s = t % 60
        gui.Timer.Text = string.format("%.1d:%.2d", m, s)

        if t%2 == 1 and not SoundService.ClockTick.Playing then
            lastSecond = t
            SoundService.ClockTick:Play()
        end
    end
    modules.Transition.start(3)
    Intermission.stop()
    modules.Menu.closeAll()
end

function Intermission.stop()
    gui.Enabled = false
end

return Intermission