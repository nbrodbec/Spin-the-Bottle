local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Leaderstats = {}
Leaderstats.dependencies = {
    modules = {"Data"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants

local leaderstatStore = DataStoreService:GetOrderedDataStore("leaderstats")


---- Private Functions ----

local function set(player, value)
    local success, msg 
    local tries = 0
    while not success and tries <= 3 do
        success, msg = pcall(leaderstatStore.UpdateAsync, leaderstatStore, player.UserId, function(old)
            if old and value > old then
                return value
            elseif not old then
                return value
            end
        end) 
        tries += 1
    end
    if not success then
        print(msg)
    end
end

local function commaVal(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

---- Public Functions ----

function Leaderstats.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    Players.PlayerAdded:Connect(function(player)
        local leaderstats = Instance.new("Model")
        leaderstats.Name = "leaderstats"
        local wins = Instance.new("IntValue", leaderstats)
        wins.Name = "Wins"
        wins.Value = modules.Data.get(player, "wins") or 0

        leaderstats.Parent = player
    end)

    task.spawn(function()
        for _, board in ipairs(CollectionService:GetTagged("leaderboard")) do
            Leaderstats.updateBoard(board)
        end
        task.wait(60)
    end)
end

function Leaderstats.updateBoard(board)
    local leaderboardGui = board:FindFirstChildWhichIsA("SurfaceGui")
    if not leaderboardGui then return end
    for _, entry in ipairs(leaderboardGui.ScrollingFrame:GetChildren()) do
        if entry:IsA("GuiObject") then
            entry:Destroy()
        end
    end

    local entries = Leaderstats.getTopN(50)
    for i, entry in ipairs(entries) do
        local entryGui = ReplicatedStorage.LeaderboardFrame:Clone()
        entryGui.details.place.Text = string.format("%d.", i)
        entryGui.wins.Text = string.format("%s wins", commaVal(entry.value))

        local success, name, image
        success, name = pcall(Players.GetNameFromUserIdAsync, Players, entry.key)
        if success then
            entryGui.details.username.Text = name
        else
            entryGui.details.username.Text = "[Error]"
        end

        success, image = pcall(Players.GetUserThumbnailAsync, Players, entry.key, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if success then
            entryGui.details.thumbnail.Image = image
        end

        entryGui.Parent = leaderboardGui.ScrollingFrame
    end
end

function Leaderstats.addWin(player)
    local wins = modules.Data.get(player, "wins")
    if wins then
        wins += 1
        modules.Data.set(player, "wins", wins)
        set(player, wins)
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            leaderstats.Wins.Value = wins
        end
    end
end

function Leaderstats.setWins(player, n)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats.Wins.Value = n
    end
end

function Leaderstats.getTopN(n)
    local success, pages
    local tries = 0
    while not success and tries <= 3 do
        success, pages = pcall(leaderstatStore.GetSortedAsync, leaderstatStore, false, n, 1)
        tries += 1
    end
    if success then
        return pages:GetCurrentPage()
    else
        print(pages)
        return {}
    end
end

return Leaderstats