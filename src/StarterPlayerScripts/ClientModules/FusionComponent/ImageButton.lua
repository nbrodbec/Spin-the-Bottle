local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring


local function ImageButton(props)
    local isHovering = State(false)
    local isClicking = State(false)
    local defaultSize = props.Size or UDim2.fromScale(0.05, 0.05)
    local dominantAxis = if defaultSize.X.Scale > defaultSize.Y.Scale then Enum.DominantAxis.Width else Enum.DominantAxis.Height

    local button = New "Frame" {
        Size = defaultSize,
        Position = props.Position or UDim2.new(),
        BackgroundTransparency = 1,
        LayoutOrder = props.LayoutOrder or 1,

        [Children] = {
            New "UIAspectRatioConstraint" {
                AspectRatio = 1,
                AspectType = Enum.AspectType.ScaleWithParentSize,
                DominantAxis = dominantAxis
            },
            New "ImageButton" {
                Size = Spring(Computed(function()
                    if isClicking:get() then
                        return UDim2.fromScale(0.975, 0.975)
                    elseif isHovering:get() then
                        return UDim2.fromScale(1, 1)
                    else
                        return UDim2.fromScale(0.95, 0.95)
                    end
                end), 30),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = props.Image or "",
                ImageRectOffset = props.ImageRectOffset or Vector2.new(),
                ImageRectSize = props.ImageRectSize or Vector2.new(),

                [OnEvent "MouseEnter"] = function()
                    isHovering:set(true)
                end,
                [OnEvent "MouseLeave"] = function()
                    isHovering:set(false)
                    isClicking:set(false)
                end,
                [OnEvent "MouseButton1Down"] = function()
                    isClicking:set(true)
                end,
                [OnEvent "MouseButton1Up"] = function()
                    isClicking:set(false)
                end,
                [OnEvent "Activated"] = function()
                    if props.Callback then
                        props.Callback()
                    end
                end
            }
        }
    }

    button.Parent = props.Parent
    return button
end

return ImageButton