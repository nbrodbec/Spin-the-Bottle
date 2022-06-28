local Permissions = {}
Permissions.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local levels = {
    [1] = 255, -- Owner+
    [2] = 254, -- Dev+
    [3] = 253 -- Contributor+
}

---- Public Functions ----

function Permissions.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
end

function Permissions.hasPermissions(player, level)
    if not level or not levels[level] then return end
    return player:GetRankInGroup(11349686) >= levels[level]
end

return Permissions