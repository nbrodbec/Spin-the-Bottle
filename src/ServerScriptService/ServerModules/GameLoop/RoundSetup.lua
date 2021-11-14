local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundSetup = {}
RoundSetup.dependencies = {
    modules = {"BottleSpin"},
    utilities = {},
    dataStructures = {},
    constants = {"Values"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local roundDetails

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
            timeWithGun = constants.Values.TIME_WITH_GUN
        },
        special = {
            name = "High-Stress Round",
            timeWithGun = 4,
            probability = 1/30
        },
    }
end

function RoundSetup.start()
    if math.random() <= roundDetails.special.probability then
        RoundSetup.details = roundDetails.special
    else
        RoundSetup.details = roundDetails.default
    end
    remotes.RoundMode:FireAllClients(RoundSetup.details.name)
    task.wait(3)
end

return RoundSetup