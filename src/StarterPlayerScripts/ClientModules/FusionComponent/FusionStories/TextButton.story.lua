local components = script.Parent.Parent

return function(target)
    local textButton = require(components.TextButton) {
        Text = "Testing",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.1, 0),
        Underlined = true,
        Callback = function()
            print("Clicked")
        end
    }
    textButton.Parent = target
    return function()
        
    end
end