local components = script.Parent.Parent

return function(target)
    local button = require(components.ImageButton) {
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0, 0.5)
    }

    button.Parent = target
    return function()
        
    end
end