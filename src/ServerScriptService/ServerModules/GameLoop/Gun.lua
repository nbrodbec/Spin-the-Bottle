local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = {}
Gun.dependencies = {
    modules = {"BottleSpin", "Seats", "Marketplace", "RoundSetup", "Data"},
    utilities = {"Timer"},
    dataStructures = {},
    constants = {"Values", "GamepassIDs", "ShopAssets"}
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
local generator = Random.new(os.time())
function Gun.start(players)
    local player = modules.BottleSpin.selectedPlayer
    if not player.Parent then return end
    if modules.RoundSetup.details.onGunStart then
        modules.RoundSetup.details.onGunStart()
    end

    local gunID = modules.Data.get(player, "gun")
    local gun = gunID and constants.ShopAssets.guns[gunID] and constants.ShopAssets.guns[gunID].model:Clone() or ReplicatedStorage.GunModels.Gun:Clone()
    gun.Parent = workspace
    local weld = Instance.new("ManualWeld")
    weld.Parent = gun.Handle
    weld.Part0 = player.Character["Right Arm"]
    weld.Part1 = gun.Handle
    weld.C0 = CFrame.new(0, -player.Character['Right Arm'].Size.Y/2, 0) * CFrame.Angles(-math.pi/2, 0, 0)

    for i = 1, modules.RoundSetup.details.shotsPerPerson do
        local list = {}
        for p in players.iterate() do if p ~= player then table.insert(list, p) end end
        if #list == 0 then break end

        timer = utilities.Timer.new(modules.RoundSetup.details.timeWithGun)
        local chance = (modules.RoundSetup.details.nBullets)/(total-blanks)
        local isBlank = generator:NextNumber() > chance
        if isBlank then 
            blanks += 1 
        else
            blanks = 0
        end

        remotes.GiveGunEvent:FireClient(player, list, gun, isBlank, modules.RoundSetup.details.timeWithGun)
        local playerShot
        local connection; connection = remotes.TargetChosen.OnServerEvent:Connect(function(p, target)
            if p == player and target and players[target] then
                playerShot = target
                timer:stop()
                remotes.TargetChosen:FireAllClients(player, gun, isBlank, playerShot)
            end
        end)
        timer:start():yield()
        
        connection:Disconnect()
        if playerShot then
            if not isBlank then
                if math.random() <= modules.RoundSetup.details.backfireProbability then
                    playerShot = player
                end
                if playerShot.Character then
                    local humanoid = playerShot.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:TakeDamage(humanoid.MaxHealth+10)
                    end
                    players[playerShot] = nil
                    modules.Seats.clearSeat(playerShot)
                end
            end
        else
            if player.Character then
                player.Character.Humanoid.Health = 0
                players[player] = nil
                modules.Seats.clearSeat(player)
                break
            end
        end
        task.wait(1)
    end
    
    gun:Destroy()

    if modules.RoundSetup.details.onGunEnd then
        modules.RoundSetup.details.onGunEnd()
    end
end

function Gun.stop()
    
end

return Gun