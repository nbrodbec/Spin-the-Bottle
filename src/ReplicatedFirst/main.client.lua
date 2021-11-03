local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

require(ReplicatedStorage:WaitForChild("MainModule")).init(Players.LocalPlayer.PlayerScripts:WaitForChild("ClientModules"))
require(ReplicatedStorage:WaitForChild("MainModule")).onLoadFinished()


