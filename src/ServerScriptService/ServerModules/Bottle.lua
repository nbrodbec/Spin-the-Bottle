local RunService = game:GetService("RunService")

local Bottle = {}
Bottle.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants

local bottle = workspace.Components.Bottle.Bottle

---- Private Functions ----

local function getAngleFromBottle(target)
    local position = Vector3.new(target.Position.X, bottle.Position.Y, target.Position.Z)
    
    local relativePoint = bottle.CFrame:PointToObjectSpace(position).Unit
    local theta = math.atan2(relativePoint.X, relativePoint.Z)
    return theta < 0 and theta + 2*math.pi or theta
end

---- Public Functions ----

function Bottle.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

end

function Bottle.spin(target)
    local totalTheta = getAngleFromBottle(target) + 4*math.pi
    local a = math.rad(constants.Values.BOTTLE_DECEL)
    local vInitial = math.sqrt(2 * a * totalTheta)
    local v = vInitial
    bottle.Spin:Play()
    while v > 0 do
        local dt = RunService.Heartbeat:Wait()
        v -= a*dt
        local theta = v*dt
        bottle.CFrame *= CFrame.Angles(0, theta, 0)
    end
    bottle.Spin:Stop()
end

local generator = Random.new()
function Bottle.selectPlayer(players)
    local list = {}
    for player in players.iterate() do
        table.insert(list, player)
    end
    return list[generator:NextInteger(1, #list)]
end

return Bottle