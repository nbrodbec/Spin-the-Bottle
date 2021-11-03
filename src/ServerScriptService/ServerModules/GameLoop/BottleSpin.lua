local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BottleSpin = {}
BottleSpin.dependencies = {
    modules = {"Bottle", "Gun", "GameLoop", "Seats", "Leaderstats"},
    utilities = {},
    dataStructures = {},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

---- Public Functions ----

function BottleSpin.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    BottleSpin.next = modules.Gun
end

function BottleSpin.start(players)
    if players.size() <= 1 then
        for winner in players.iterate() do
            -- Award winner
            modules.Leaderstats.addWin(winner)
            winner:LoadCharacter()
            modules.Seats.clearSeat(winner)
            remotes.DisplayWinner:FireAllClients(winner.Name)
        end
        task.wait(constants.Values.DISPLAY_WINNER_TIME)
        modules.GameLoop.stop()
        return
    end
    BottleSpin.next = modules.Gun
    BottleSpin.selectedPlayer = modules.Bottle.selectPlayer(players)
    local seat = modules.Seats.getSeat(BottleSpin.selectedPlayer)
    if seat then
        modules.Bottle.spin(seat)
    end
end

function BottleSpin.stop()
    BottleSpin.selectedPlayer = nil
end

return BottleSpin