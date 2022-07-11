local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Header = {}
Header.dependencies = {
    modules = {"Gui", "Menu", "FusionComponent", "ClientData"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring

---- Public Functions ----

function Header.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

    local header = New "Frame" {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        [Children] = {
            New "UIPadding" {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 104),
                PaddingRight = UDim.new(0, 60)
            },

            -- Right-aligned frame
            New "Frame" {
                Size = UDim2.fromScale(1,1),
                BackgroundTransparency = 1,
                [Children] = {
                    New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 4)
                    },
                    modules.FusionComponent.new "ImageButton" {
                        Size = UDim2.fromScale(0, 1),
                        Image = "rbxassetid://3926307971",
                        ImageRectOffset = Vector2.new(324, 364),
                        ImageRectSize = Vector2.new(36, 36),
                        LayoutOrder = 0
                    },
                    modules.FusionComponent.new "TextLabel" {
                        Size = UDim2.fromScale(0, .7),
                        Text = "Coins:",
                        TextXAlignment = Enum.TextXAlignment.Right,
                        LayoutOrder = -2
                    },
                    modules.FusionComponent.new "TextLabel" {
                        Size = UDim2.fromScale(0, .8),
                        Text = Spring(modules.ClientData.getState("coins"), 20),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = -1
                    }
                }
            }
        }
    }

    header.Parent = modules.Gui.menuGui
end

return Header