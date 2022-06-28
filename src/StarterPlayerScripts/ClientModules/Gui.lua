local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Gui = {}
Gui.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {"DonationIDs", "GamepassIDs"}
}
local modules
local utilities
local dataStructures
local constants
local player = Players.LocalPlayer

---- Private Functions ----

local function bindTag(tag, fun)
    for i,v in ipairs(CollectionService:GetTagged(tag)) do
        fun(v)
    end
    CollectionService:GetInstanceAddedSignal(tag):Connect(fun)
end

---- Public Functions ----

function Gui.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local playerGui = player:WaitForChild("PlayerGui")
    local gui = ReplicatedStorage:WaitForChild("Gui")

    local timerGui = gui:WaitForChild("IntermissionTimer")
    Gui.timerGui = timerGui:Clone()
    Gui.timerGui.Parent = playerGui

    local stressGui = gui:WaitForChild("ShootTimer")
    Gui.stressGui = stressGui:Clone()
    Gui.stressGui.Parent = playerGui

    local transitionGui = gui:WaitForChild("Transition")
    Gui.transitionGui = transitionGui:Clone()
    Gui.transitionGui.Parent = playerGui

    local minPlayersGui = gui:WaitForChild("MinimumPlayers")
    Gui.minPlayersGui = minPlayersGui:Clone()
    Gui.minPlayersGui.Parent = playerGui

    local menuGui = gui:WaitForChild("Menu")
    Gui.menuGui = menuGui:Clone()
    Gui.menuGui.Parent = playerGui

    local winnerGui = gui:WaitForChild("Winner")
    Gui.winnerGui = winnerGui:Clone()
    Gui.winnerGui.Parent = playerGui

    local announcementGui = gui:WaitForChild("RoundAnnouncement")
    Gui.announcementGui = announcementGui:Clone()
    Gui.announcementGui.Parent = playerGui

    local notificationGui = gui:WaitForChild("Notification")
    Gui.notificationGui = notificationGui:Clone()
    Gui.notificationGui.Parent = playerGui

    bindTag("UnderlinedButton", function(button)
        local underline = button:FindFirstChildWhichIsA("Frame")
        local startSize = button.Size
        if underline then
            local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            button.MouseEnter:Connect(function()
                TweenService:Create(
                    button,
                    tweenInfo,
                    {Size = UDim2.new(startSize.X.Scale, startSize.X.Offset+5, startSize.Y.Scale, startSize.Y.Offset+5)}
                ):Play()
                TweenService:Create(
                    underline,
                    tweenInfo,
                    {Size = UDim2.fromScale(0.8, 0.05)}
                ):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(
                    button,
                    tweenInfo,
                    {Size = startSize}
                ):Play()
                TweenService:Create(
                    underline,
                    tweenInfo,
                    {Size = UDim2.fromScale(0.5, 0.05)}
                ):Play()
            end)
        end
    end)

    bindTag("DonationButton", function(button)
        local amt = button:GetAttribute("amount")
        local id = constants.DonationIDs[amt]
        if id then
            button.Activated:Connect(function()
                local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, id)
                if not success then
                    print("MarketplaceService.PromptProductPurchase Error: "..msg)
                end
            end)
        end
    end)

    bindTag("GamepassButton", function(button)
        local name = button:GetAttribute("gamepassName")
        local id = constants.GamepassIDs[name]
        if id then
            button.Activated:Connect(function()
                local success, msg = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, id)
                if not success then
                    print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
                end
            end)
        end
    end)
end

return Gui