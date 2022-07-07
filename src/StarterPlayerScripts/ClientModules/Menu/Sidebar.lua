local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Sidebar = {}
Sidebar.dependencies = {
    modules = {"Gui", "Menu", "FusionComponent"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local gui
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")

---- Public Functions ----

function Sidebar.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.menuGui

    modules.FusionComponent.new "TextButton" {
        Text = "Shop",
        Size = UDim2.fromScale(0.8, 0),
        Parent = gui.Sidebar,
        Underlined = true,
        Callback = function()
            modules.Menu.open("Shop")
        end
    }

    modules.FusionComponent.new "TextButton" {
        Text = "Death Audio",
        Size = UDim2.fromScale(0.8, 0),
        Parent = gui.Sidebar,
        Underlined = true,
        Callback = function()
            if remotes.PlayerHasPass:InvokeServer("AUDIO") then
                modules.Menu.open("Audio")
            else
                local success, msg = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, constants.GamepassIDs.AUDIO)
                if not success then
                    print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
                end
            end
        end
    }

    modules.FusionComponent.new "TextButton" {
        Text = "VIP",
        Size = UDim2.fromScale(0.8, 0),
        Parent = gui.Sidebar,
        Underlined = true,
        Callback = function()
            if remotes.PlayerHasPass:InvokeServer("VIP") then
                modules.Menu.open("VIP")
            else
                local success, msg = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, constants.GamepassIDs.VIP)
                if not success then
                    print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
                end
            end
        end
    }

    modules.FusionComponent.new "TextButton" {
        Text = "Donate",
        Size = UDim2.fromScale(0.8, 0),
        Parent = gui.Sidebar,
        Underlined = true,
        Callback = function()
            modules.Menu.open("Donation")
        end
    }

end

return Sidebar