local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")
local Chat = game:GetService("Chat")

local Bartender = {}
Bartender.dependencies = {
    modules = {"Marketplace"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local declineLines = {
    "You already got one of those!",
    "Finish the one you have first...",
    "I'm cutting you off.",
    "You still haven't paid for the last one!",
    "Are you sure you need another?",
    "Slow down there %s..."
}
local acceptLines = {
    "Drink up!",
    "I'll add that to your tab...",
    "Some soda oughta cheer you up",
    "Have a seat, enjoy a soda!",
    "A soda for your troubles",
    "This one's on the house",
    "Do come again",
    "Long day?",
    "Yare yare daze",
    "Why are we still here? Just to suffer?",
    "Go ahead %s",

}

---- Private Functions ----

local function setupBartender(part)
    local randomState = Random.new()
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Ask for drink"
    prompt.ObjectText = "Bartender"
    prompt.RequiresLineOfSight = true
    prompt.ClickablePrompt = true
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 6
    prompt.UIOffset = Vector2.new(0, -100)

    local cooldown = 0.5
    local last = 0
    prompt.Triggered:Connect(function(playerWhoTriggered)
        if (time() - last) <= cooldown then return end
        if not playerWhoTriggered.Character then return end
        if playerWhoTriggered.Character:FindFirstChild("Cream Soda") or playerWhoTriggered.Backpack:FindFirstChild("Cream Soda") then
            Chat:Chat(part, string.format(declineLines[randomState:NextInteger(1, #declineLines)], playerWhoTriggered.DisplayName))
        else
            Chat:Chat(part, string.format(acceptLines[randomState:NextInteger(1, #acceptLines)], playerWhoTriggered.DisplayName))
            ReplicatedStorage["Cream Soda"]:Clone().Parent = playerWhoTriggered.Character
        end
        last = time()
    end)

    prompt.Parent = part
end

local function setupBarDoor(part)
    local debounces = {}
    part.Touched:Connect(function(p)
        if debounces[p] then return end
        debounces[p] = true
        local character = p:FindFirstAncestorWhichIsA("Model")
        if character then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                if not modules.Marketplace.playerHasPass(player, 27482492) then
                    local success = pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, player, 27482492)
                end
            end
        end
        debounces[p] = false
    end)
end

---- Public Functions ----

function Bartender.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    for _, part in ipairs(CollectionService:GetTagged("bartender")) do
        setupBartender(part)
    end
    CollectionService:GetInstanceAddedSignal("bartender"):Connect(setupBartender)

    for _, part in ipairs(CollectionService:GetTagged("bar_door")) do
        setupBarDoor(part)
    end
    CollectionService:GetInstanceAddedSignal("bar_door"):Connect(setupBarDoor)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        if wasPurchased and gamePassId == 27482492 then
            local character = player.Character
            if character then
                for _,v in ipairs(character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        PhysicsService:SetPartCollisionGroup(v, "VIP_Character")
                    end
                end
            end
        end
    end)
end

return Bartender