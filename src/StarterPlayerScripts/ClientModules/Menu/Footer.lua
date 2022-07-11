local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Footer = {}
Footer.dependencies = {
    modules = {"Gui", "Menu", "FusionComponent", "Settings"},
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

local gui

---- Public Functions ----

function Footer.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    gui = modules.Gui.menuGui
    local isOpen = State(false)
    
    local footer = New "Frame" {
        Size = UDim2.new(1, -8, 0.05, 0),
        Position = UDim2.new(0, 4, 1, -4),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,

        [Children] = {
            New "UIListLayout" {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4)
            },

            modules.FusionComponent.new "ImageButton" {
                Image = "rbxassetid://3926307971",
                ImageRectOffset = Vector2.new(324, 124),
                ImageRectSize = Vector2.new(36, 36),
                Size = UDim2.fromScale(0, 1),
                LayoutOrder = 0,
                Callback = function()
                    modules.Menu.open("Settings")
                end
            },

            modules.FusionComponent.new "ListDivider" {
                Landscape = true,
                LayoutOrder = 1
            },

            New "Frame" {
                Size = Spring(Computed(function()
                    if isOpen:get() then
                        return UDim2.new(11.5, 27, 1, 0)
                    else
                        return UDim2.fromScale(1, 1)
                    end
                end), 30),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                LayoutOrder = 2,

                [Children] = {

                    New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 4)
                    },

                    modules.FusionComponent.new "ImageButton" {
                        Image = "rbxassetid://3926305904",
                        ImageRectOffset = Computed(function()
                            if isOpen:get() then
                                return Vector2.new(284, 4)
                            else
                                return Vector2.new(604, 684)
                            end
                        end),
                        ImageRectSize = Computed(function()
                            if isOpen:get() then
                                return Vector2.new(24, 24)
                            else
                                return Vector2.new(36, 36)
                            end
                        end),
                        Size = UDim2.fromScale(0, 1),
                        LayoutOrder = 0,
                        Callback = function()
                            isOpen:set(not isOpen:get())
                        end
                    },
                    modules.FusionComponent.new "ListDivider" {
                        Landscape = true,
                        LayoutOrder = -1
                    },
                    modules.FusionComponent.new "TextButton" {
                        Text = "Request Gamemode",
                        Size = UDim2.fromScale(0, 1),
                        LayoutOrder = -2,
                        Callback = function()
                            modules.Menu.open("GamemodeRequest")
                        end
                    },
                    modules.FusionComponent.new "ListDivider" {
                        Landscape = true,
                        LayoutOrder = -3
                    },
                    modules.FusionComponent.new "TextButton" {
                        Text = "Request Music",
                        Size = UDim2.fromScale(0, 1),
                        LayoutOrder = -4,
                        Callback = function()
                            modules.Menu.open("AudioRequest")
                        end
                    },
                    modules.FusionComponent.new "ListDivider" {
                        Landscape = true,
                        LayoutOrder = -5
                    },
                    modules.FusionComponent.new "TextButton" {
                        Text = Computed(function()
                            if modules.Settings.getIsAFK():get() then
                                return "AFK Mode: On"
                            else
                                return "AFK Mode: Off"
                            end
                        end),
                        Size = UDim2.fromScale(0, 1),
                        LayoutOrder = -6,
                        Callback = function()
                            modules.Settings.toggleAFK()
                        end
                    }
                }
            },
        }
    }

    footer.Parent = gui
end

return Footer