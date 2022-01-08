local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundSetup = {}
RoundSetup.dependencies = {
    modules = {"BottleSpin"},
    utilities = {"Shuffle"},
    dataStructures = {"Queue"},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local roundDetails
local rounds

---- Private Functions ----

local function mixRounds()
    local pool = {}
    for _, detail in pairs(roundDetails) do
        for i = 1, detail.weight do
            table.insert(pool, detail)
        end
    end
    rounds = dataStructures.Queue.new(utilities.Shuffle(pool))
end

---- Public Functions ----

function RoundSetup.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    RoundSetup.next = modules.BottleSpin
    roundDetails = {
        default = {
            name = "Classic Round",
            timeWithGun = constants.Values.TIME_WITH_GUN,
            nBullets = 1,
            shotsPerPerson = 1,
            weight = 1
        },
        fast = {
            name = "High-Stress Round",
            timeWithGun = 4,
            nBullets = 1,
            shotsPerPerson = 1,
            weight = 1
        },
        quickfire = {
            name = "Quickfire Round",
            timeWithGun = constants.Values.TIME_WITH_GUN,
            nBullets = 6,
            shotsPerPerson = 1,
            weight = 1 
        },
        double = {
            name = "Double-Shot Round",
            timeWithGun = constants.Values.TIME_WITH_GUN,
            nBullets = 1,
            shotsPerPerson = 2,
            weight = 1,
        }
    }

    mixRounds()
end

function RoundSetup.start()
    if rounds:isEmpty() then mixRounds() end
    RoundSetup.details = rounds:dequeue()
    remotes.RoundMode:FireAllClients(RoundSetup.details.name)
    task.wait(3)
end

return RoundSetup