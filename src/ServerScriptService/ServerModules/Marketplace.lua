local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Marketplace = {}
Marketplace.dependencies = {
    modules = {"Data"},
    utilities = {},
    dataStructures = {},
    constants = {"GamepassIDs"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local gamepassCache = {}

---- Private Functions ----

local function playerHasPass(player, id)
    local success, hasPass = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, id)
    if success then
        return hasPass
    else
        print("MarketplaceService.UserOwnsGamePassAsync Error: "..hasPass)
        return false
    end
end

---- Public Functions ----

function Marketplace.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    local function playerAdded(player)
        gamepassCache[player] = {}
    end

    Players.PlayerAdded:Connect(playerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerRemoving:Connect(function(player)
        gamepassCache[player] = nil
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if wasPurchased and gamepassCache[player] then
            print("Gamepass purchased!")
            gamepassCache[player][gamePassId] = true
        end
    end)

    function MarketplaceService.ProcessReceipt(info)
        print("Processing")
        local player = Players:GetPlayerByUserId(info.PlayerId)
        local perks = modules.Data.get(player, "perks")
        perks[info.ProductId] = true
        modules.Data.save(player)
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    function remotes.PlayerHasPass.OnServerInvoke(player, name)
        if name and constants.GamepassIDs[name] then
            local id = constants.GamepassIDs[name]
            return Marketplace.playerHasPass(player, id)
        end
    end
end

function Marketplace.playerHasPass(player, id)
    local playerCache = gamepassCache[player]
    if playerCache then
        if playerCache[id] == nil then
            playerCache[id] = playerHasPass(player, id)
        end
        return playerCache[id]
    end
end

function Marketplace.playerHasPerk(player, id)
    local perks = modules.Data.get(player, "perks")
    if perks[id] then
        return true
    else
        return false
    end
end

function Marketplace.promptPurchase(player, id)
    local success, msg = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, id)
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

function Marketplace.promptPerkPurchase(player, id)
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, id)
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

return Marketplace