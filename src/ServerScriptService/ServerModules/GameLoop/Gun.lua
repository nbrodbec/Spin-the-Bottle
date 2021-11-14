local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = {}
Gun.dependencies = {
    modules = {"BottleSpin", "Seats", "Marketplace", "RoundSetup"},
    utilities = {"Timer"},
    dataStructures = {},
    constants = {"Values", "GamepassIDs"}
}
Gun.killStreaks = {}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects
local timer

---- Public Functions ----

function Gun.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    
    Gun.next = modules.BottleSpin
    -- TODO: put a rate limiter here
    remotes.UpdateGunJoint.OnServerEvent:Connect(function(player, cf)
        if player == modules.BottleSpin.selectedPlayer then
            remotes.UpdateGunJoint:FireAllClients(player, cf)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player == modules.BottleSpin.selectedPlayer then
            timer:stop()
        end
    end)
end

local blanks = 0
local total = 6
function Gun.start(players)
    local player = modules.BottleSpin.selectedPlayer
    if not player.Parent then return end

    timer = utilities.Timer.new(modules.RoundSetup.details.timeWithGun)
    local chance = 1/(total-blanks)
    local isBlank = math.random() > chance
    if isBlank then 
        blanks += 1 
    else
        blanks = 0
    end

    local list = {}
    for p in players.iterate() do if p ~= player then table.insert(list, p) end end

    local gun = modules.Marketplace.playerHasPass(player, constants.GamepassIDs.VIP) and 
                ReplicatedStorage.VIPGun:Clone() or
                ReplicatedStorage.Gun:Clone()
    gun.Parent = workspace
    local weld = Instance.new("ManualWeld")
    weld.Parent = gun.Handle
    weld.Part0 = player.Character["Right Arm"]
    weld.Part1 = gun.Handle
    weld.C0 = CFrame.new(0, -player.Character['Right Arm'].Size.Y/2, 0) * CFrame.Angles(-math.pi/2, 0, 0)

    remotes.GiveGunEvent:FireClient(player, list, gun, isBlank, modules.RoundSetup.details.timeWithGun)
    local playerShot
    local connection; connection = remotes.TargetChosen.OnServerEvent:Connect(function(p, target)
        if p == player and target and players[target] then
            playerShot = target
            timer:stop()
            remotes.TargetChosen:FireAllClients(player, gun, isBlank)
        end
    end)
    timer:start():yield()
    
    connection:Disconnect()
    if playerShot then
        if not isBlank then
            Gun.killStreaks[player] = Gun.killStreaks[player] and Gun.killStreaks[player] + 1 or 1
            if playerShot.Character then
                playerShot.Character.Humanoid.Health = 0
                players[playerShot] = nil
                modules.Seats.clearSeat(playerShot)
            end
        else
            Gun.killStreaks[player] = 0
        end
    else
        Gun.killStreaks[player] = 0
        if player.Character then
            player.Character.Humanoid.Health = 0
            players[player] = nil
            modules.Seats.clearSeat(player)
        end
    end
    task.wait(1)
    gun:Destroy()
end

function Gun.stop()
    
end

return Gun