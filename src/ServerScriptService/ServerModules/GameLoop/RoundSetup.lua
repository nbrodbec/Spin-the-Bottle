local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundSetup = {}
RoundSetup.dependencies = {
    modules = {"BottleSpin", "Permissions", "Chat"},
    utilities = {"Shuffle"},
    dataStructures = {"Queue"},
    constants = {"Values", "GameModes"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local rounds
local customRounds
local pendingRounds = {}

---- Private Functions ----

local function mixRounds()
    local pool = {}
    for _, detail in pairs(constants.GameModes) do
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

    customRounds = dataStructures.Queue.new()

    RoundSetup.next = modules.BottleSpin
    mixRounds()

    function remotes.RequestGamemode.OnServerInvoke(player, id)
        if id and constants.GameModes[id] then
            if customRounds:isEmpty() then
                RoundSetup.pendRound(player, id)
                if modules.Permissions.hasPermissions(player, 3) then
                    RoundSetup.confirmRound(player)
                    modules.Chat.makeSystemMessage(
                        string.format("%s has requested gamemode: %s", player.DisplayName, constants.GameModes[id].name),
                        Color3.fromRGB(234, 0, 255)
                    )
                    return true
                else
                    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, 1235125981)
                    if not success then
                        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
                    end
                    return true
                end
            else
                return false
            end
        end
    end
end

function RoundSetup.start()
    if rounds:isEmpty() then mixRounds() end
    RoundSetup.details = customRounds:dequeue() or rounds:dequeue()
    remotes.RoundMode:FireAllClients(RoundSetup.details.name)
    task.wait(3)
end

function RoundSetup.pendRound(player, roundId)
    pendingRounds[player] = roundId
end

function RoundSetup.confirmRound(player)
    local roundId = pendingRounds[player]
    if roundId then
        customRounds:enqueue(constants.GameModes[roundId])
        pendingRounds[player] = nil
        return constants.GameModes[roundId]
    end
end

return RoundSetup