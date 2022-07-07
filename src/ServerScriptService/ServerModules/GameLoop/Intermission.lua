local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Intermission = {}
Intermission.dependencies = {
    modules = {"Seats", "BottleSpin", "RoundSetup", "GameLoop"},
    utilities = {"Timer"},
    dataStructures = {},
    constants = {"Values"}
}
Intermission.begin = Instance.new("BindableEvent")
local modules
local utilities
local dataStructures
local constants

local remotes = ReplicatedStorage.RemoteObjects
local timer

---- Public Functions ----

function Intermission.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    timer = utilities.Timer.new(constants.Values.INTERMISSION_TIME)
    timer:useServerTime()
    Intermission.next = modules.RoundSetup
end

function Intermission.start(livePlayers, players)
    local startTime = DateTime.now().UnixTimestampMillis/1000 + constants.Values.INTERMISSION_TIME
    remotes.StartIntermission:FireAllClients(startTime)
    Intermission.begin:Fire()

    timer:start():yield()

    if modules.GameLoop.running then
        for player in players.iterate() do
            modules.Seats.assignSeat(player)
            livePlayers[player] = true
        end
    else
        -- Abort
        
    end
end

function Intermission.stop()
    timer:stop()
end

return Intermission