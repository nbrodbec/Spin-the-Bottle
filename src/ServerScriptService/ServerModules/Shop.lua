local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shop = {}
Shop.dependencies = {
    modules = {"Suits", "Data", "Marketplace"},
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
end

function Shop.handleSuitClick(player, id)
    local suit = constants.ShopAssets.suits[id]
    local wins, ownedSuits = modules.Data.get(player, {"wins", "ownedSuits"})
    if wins >= suit.level or table.find(ownedSuits, id) then
        local currentSuit = modules.Data.get(player, "suit")
        currentSuit.shirt = suit.shirt
        currentSuit.pants = suit.pants

        modules.Suits.applySuit(player, suit)
    else
        modules.Marketplace.promptSuitPurchase(player, id)
    end
end

function Shop.handleAnimClick(player, id)
    local anim = constants.ShopAssets.animations[id]
    local wins, ownedAnims = modules.Data.get(player, {"wins", "ownedAnims"})
    if wins >= anim.level or table.find(ownedAnims, id) then
        modules.Data.set(player, "deathAnimId", anim.id)
    else
        modules.Marketplace.promptAnimPurchase(player, id)
    end
end

return Shop