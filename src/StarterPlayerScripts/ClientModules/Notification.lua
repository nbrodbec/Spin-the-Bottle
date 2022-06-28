local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Notification = {}
Notification.dependencies = {
    modules = {"Gui"},
    utilities = {"Timer"},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local gui
local tweenInfo = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.In
)

local tweenIn, tweenOut

---- Public Functions ----

function Notification.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.notificationGui
    tweenIn = TweenService:Create(
        gui.Frame,
        tweenInfo,
        {
            Position = UDim2.new(1, -10, 1, -10)
        }
    )

    tweenOut = TweenService:Create(
        gui.Frame,
        tweenInfo,
        {
            Position = UDim2.new(1, -10, 1.25, 2)
        }
    )

    remotes.NotifyClient.OnClientEvent:Connect(Notification.notify)
end

function Notification.notify(message)
    local timer = utilities.Timer.new(5)
    gui.Frame.Position = UDim2.new(1, -10, 1.25, 2)
    gui.Frame.Message.Text = message
    local connection; connection = gui.Frame.Exit.Activated:Connect(function()
        timer:stop()
    end)

    tweenIn:Play()
    timer:start():yield()
    connection:Disconnect()
    tweenOut:Play()
end

return Notification