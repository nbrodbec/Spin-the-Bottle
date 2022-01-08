local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Marketplace = {}
Marketplace.dependencies = {
    modules = {"Data", "MusicPlayer"},
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

local customMusicId = 0
local customMusicInfo = {}

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

    function MarketplaceService.ProcessReceipt(info)
        local player = Players:GetPlayerByUserId(info.PlayerId)
        if info.ProductId == shopUnlockId then
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
            elseif unlockInfo.type == "gun" then
                local ownedGuns = modules.Data.get(player, "ownedGuns")
                table.insert(ownedGuns, unlockInfo.id)
                modules.Data.set(player, "ownedGuns", ownedGuns)
            else
                return Enum.ProductPurchaseDecision.NotProcessedYet
            end

            modules.Data.save(player)
            shopUnlockInfo[player] = nil
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif info.ProductId == customMusicId then
            local musicInfo = customMusicInfo[player]
            if not musicInfo then return Enum.ProductPurchaseDecision.NotProcessedYet end
            modules.MusicPlayer.addToQueue(musicInfo.id)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end

    function remotes.PlayerHasPass.OnServerInvoke(player, idName)
        if type(idName) == "string" then
            return Marketplace.playerHasPass(player, constants.GamepassIDs[idName])
        elseif type(idName) == "number" then
            return Marketplace.playerHasPass(player, idName)
        end
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

function Marketplace.promptGunPurchase(player, id)
    shopUnlockInfo[player] = {
        type = "gun",
        id = id
    }
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, shopUnlockId)
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

function Marketplace.promptAudioPurchase(player, id)
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
    if success and info.AssetTypeId == 3 then
        customMusicInfo[player] = {
            id = id
        }
        local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, customMusicId)
        if not success then
            print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
            return false, "Unknown Error"
        else
            return true, "Processing..."
        end
    end
    return false, "Invalid ID!"
end


return Marketplace