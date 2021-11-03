local Seats = {}
Seats.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {"Stack"},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local seats
local playerSeatMap = {}
local playerSeatConnection = {}
local newSeatEvent = Instance.new("BindableEvent")

---- Public Functions ----

function Seats.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    seats = dataStructures.Stack.new()
    for _, model in ipairs(workspace.Seats:GetChildren()) do
        local seat = model:FindFirstChildOfClass("Seat")
        if seat then seats:push(seat) end
    end
end

function Seats.assignSeat(player)
    if not seats:peek() then
        print(player.Name.." is waiting for a seat...")
        newSeatEvent.Event:Wait()
    end
    local seat = seats:pop()
    playerSeatMap[player] = seat

    if not player.Character then player.CharacterAdded:Wait() end
    local humanoid = player.Character:WaitForChild("Humanoid")

    seat:Sit(humanoid)
    humanoid.JumpHeight = 0
end

function Seats.clearSeat(player)
    local seat = playerSeatMap[player]
    if seat then
        seats:push(seat)
        playerSeatMap[player] = nil
        if playerSeatConnection[player] then
            playerSeatConnection[player]:Disconnect()
            playerSeatConnection[player] = nil
        end
        newSeatEvent:Fire()
    end
end

function Seats.getSeat(player)
    return playerSeatMap[player]
end

return Seats