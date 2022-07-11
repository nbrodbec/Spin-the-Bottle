local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring


local function TextLabel(props)
    local defaultSize = props.Size or UDim2.fromScale(0.05, 0.05)
    local dominantAxis = if defaultSize.X.Scale > defaultSize.Y.Scale then Enum.DominantAxis.Width else Enum.DominantAxis.Height
    
    local label = New "TextLabel" {
        Size = defaultSize,
        Position = props.Position or UDim2.new(),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = props.Text,
        TextScaled = true,
        Font = Enum.Font.Merriweather,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
        LayoutOrder = props.LayoutOrder or 1,

        [Children] = {
            New "UIAspectRatioConstraint" {
                AspectRatio = 3.5,
                AspectType = Enum.AspectType.ScaleWithParentSize,
                DominantAxis = dominantAxis
            },
            (function()
                if props.Underlined then
                    return New "Frame" {
                        Size = UDim2.fromScale(0.8, 0.05),
                        Position = UDim2.fromScale(0.5, 1),
                        AnchorPoint = Vector2.new(0.5, 0)
                    }
                end
            end)()
        }
    }

    return label
end

return TextLabel