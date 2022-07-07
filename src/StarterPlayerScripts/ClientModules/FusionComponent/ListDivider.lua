local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local State = Fusion.State
local Computed = Fusion.Computed
local Spring = Fusion.Spring


local function ListDivider(props)
    return New "Frame" {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = if props.Landscape then UDim2.new(0, 1, 1, 0) else UDim2.new(1, 0, 0, 1),
        LayoutOrder = props.LayoutOrder or 1
    }
end

return ListDivider