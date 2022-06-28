local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Marketplace = {}
Marketplace.dependencies = {
    modules = {"Data", "MusicPlayer", "Chat", "RoundSetup"},
    utilities = {},
    dataStructures = {},
    constants = {"GamepassIDs", "ShopAssets"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local shopUnlockIds = {
    [1217983283] = 50,
    [1235023917] = 100,
    [1235024065] = 200,
    [1235024075] = 500,
}
local shopUnlockInfo = {}

local customMusicId = 1235048301
local customRoundId = 1235125981

local function getShopUnlockId(player, price)
    local wins = modules.Data.get(player, "wins")
    local closestId, difference = 1217983283, math.huge
    local diff = math.abs(price - wins)
    for id, amt in pairs(shopUnlockIds) do
        local dif = math.abs(amt - diff)
        if dif < difference then
            closestId, difference = id, dif
        end
    end
    return closestId
end

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
        if shopUnlockIds[info.ProductId] then
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
            local id = modules.MusicPlayer.confirmRequest(player)
            if id then
                local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id)
                if success then
                    modules.Chat.makeSystemMessage(
                        string.format("%s has requested song: %s", player.DisplayName, info.Name),
                        Color3.new(1, 0.901960, 0)
                    )
                end
                return Enum.ProductPurchaseDecision.PurchaseGranted
            else
                return Enum.ProductPurchaseDecision.NotProcessedYet 
            end
        elseif info.ProductId == customRoundId then
            local details = modules.RoundSetup.confirmRound(player)
            modules.Chat.makeSystemMessage(
                        string.format("%s has requested gamemode: %s", player.DisplayName, details.name),
                        Color3.fromRGB(234, 0, 255)
                    )
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
    print("Prompting...")
    local price = constants.ShopAssets.suits[id].level
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, getShopUnlockId(player, price))
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

function Marketplace.promptAnimPurchase(player, id)
    shopUnlockInfo[player] = {
        type = "animation",
        id = id
    }
    local price = constants.ShopAssets.animations[id].level
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, getShopUnlockId(player, price))
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

function Marketplace.promptGunPurchase(player, id)
    shopUnlockInfo[player] = {
        type = "gun",
        id = id
    }
    local price = constants.ShopAssets.guns[id].level
    local success, msg = pcall(MarketplaceService.PromptProductPurchase, MarketplaceService, player, getShopUnlockId(player, price))
    if not success then
        print("MarketplaceService.PromptGamePassPurchase Error: "..msg)
    end
end

return Marketplace