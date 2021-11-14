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

local shopUnlockId = 1217983283
local shopUnlockInfo = {}

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
     
    end

    Players.PlayerAdded:Connect(playerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerRemoving:Connect(function(player)
     
    end)

    function MarketplaceService.ProcessReceipt(info)
        local player = Players:GetPlayerByUserId(info.PlayerId)
        local unlockInfo = shopUnlockInfo[player]
        if not unlockInfo then return Enum.ProductPurchaseDecision.NotProcessedYet end

        if unlockInfo.type == "suit" then
            local ownedSuits = modules.Data.get(player, "ownedSuits")
            table.insert(ownedSuits, unlockInfo.id)
            modules.Data.set(player, "ownedSuits", ownedSuits)
        elseif unlockInfo.type == "animation" then
            local ownedAnims = modules.Data.get(player, "ownedAnims")
            table.insert(ownedAnims, unlockInfo.id)
            modules.Data.set(player, "ownedAnims", ownedAnims)
        else
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        modules.Data.save(player)
        shopUnlockInfo[player] = nil
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    function remotes.PlayerHasPass.OnServerInvoke(player, idName)
        return Marketplace.playerHasPass(player, constants.GamepassIDs[idName])
    end
end

function Marketplace.playerHasPass(player, id)
    return playerHasPass(player, id)
end

function Marketplace.promptSuitPurchase(player, id)
    shopUnlockInfo[player] = {
        type = "suit",
        id = id
    }
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, shopUnlockId)
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

function Marketplace.promptAnimPurchase(player, id)
    shopUnlockInfo[player] = {
        type = "animation",
        id = id
    }
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, shopUnlockId)
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end


return Marketplace