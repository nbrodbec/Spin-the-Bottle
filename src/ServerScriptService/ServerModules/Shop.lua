local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shop = {}
Shop.dependencies = {
    modules = {"Suits", "Data", "Marketplace", "NotificationService"},
    utilities = {},
    dataStructures = {},
    constants = {"ShopAssets"}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

---- Public Functions ----

function Shop.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    remotes.EquipSuit.OnServerEvent:Connect(Shop.handleSuitClick)
    remotes.EquipAnim.OnServerEvent:Connect(Shop.handleAnimClick)
    remotes.EquipGun.OnServerEvent:Connect(Shop.handleGunClick)

    Players.PlayerAdded:Connect(Shop.setupInventory)
    for _, p in ipairs(Players:GetPlayers()) do
        Shop.setupInventory(p)
    end
end

function Shop.handleSuitClick(player, id)
    local suit = constants.ShopAssets.suits[id]
    local wins, ownedSuits = modules.Data.get(player, {"wins", "ownedSuits"})
    local ownsSuit = table.find(ownedSuits, id) ~= nil
    if wins >= suit.level or ownsSuit then
        local currentSuit = modules.Data.get(player, "suit")
        currentSuit.shirt = suit.shirt
        currentSuit.pants = suit.pants

        if not ownsSuit then table.insert(ownedSuits, id) end

        modules.Suits.applySuit(player, suit)
    elseif not suit.groupId and not suit.gamepassId then
        modules.Marketplace.promptSuitPurchase(player, id)
    end
end

function Shop.handleAnimClick(player, id)
    local anim = constants.ShopAssets.animations[id]
    local wins, ownedAnims = modules.Data.get(player, {"wins", "ownedAnims"})
    local ownsAnim = table.find(ownedAnims, id) ~= nil
    if wins >= anim.level or ownsAnim then
        if not ownsAnim then table.insert(ownedAnims, id) end
        modules.Data.set(player, "deathAnimId", anim.id)
    elseif not anim.groupId and not anim.gamepassId then
        modules.Marketplace.promptAnimPurchase(player, id)
    end
end

function Shop.handleGunClick(player, id)
    local gun = constants.ShopAssets.guns[id]
    local wins, ownedGuns = modules.Data.get(player, {"wins", "ownedGuns"})
    local ownsGun = table.find(ownedGuns, id)
    if wins >= gun.level or ownsGun then
        if not ownsGun then table.insert(ownedGuns, id) end
        modules.Data.set(player, "gun", id)
    elseif gun.gamepassId and modules.Marketplace.playerHasPass(player, gun.gamepassId) then
        modules.Data.set(player, "gun", id)
    elseif gun.gamepassId then
        local success, msg = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, gun.gamepassId)
        if not success then warn(msg) end
    else
        modules.Marketplace.promptGunPurchase(player, id)
    end
end

function Shop.setupInventory(player)
    local ownedGuns, ownedSuits, ownedAnims = modules.Data.get(player, {"ownedGuns", "ownedSuits", "ownedAnims"})
    local equippedGun, equippedSuit, equippedAnim = modules.Data.get(player, {"gun", "suit", "deathAnim"})

    for id, suit in ipairs(constants.ShopAssets.suits) do
        local groupId = suit.groupId
        if groupId then
            if player:IsInGroup(groupId) then
                if not table.find(ownedSuits, id) then
                    table.insert(ownedSuits, id)
                end
            else
                if table.find(ownedSuits, id) then
                    table.remove(ownedSuits, table.find(ownedSuits, id))
                    if equippedSuit.shirt == suit.shirt then
                        equippedSuit.shirt = constants.ShopAssets.suits[7].shirt
                        equippedSuit.pants = constants.ShopAssets.suits[7].pants
                    end
                end
                modules.NotificationService.notifyClient(player, "Join the Skum Studios group for an awesome free in-game suit!")
            end
        end
    end
    modules.Data.set(player, "ownedSuits", ownedSuits)
end

return Shop