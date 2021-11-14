local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameLoop = {}
GameLoop.dependencies = {
    modules = {"Seats", "Intermission"},
    utilities = {},
    dataStructures = {"Set"},
    constants = {"Values"}
}
GameLoop.current = nil
GameLoop.running = false

local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")

local players
local livePlayers

---- Private Functions ----

local function onPlayerCountChanged()
    if players.size() >= constants.Values.MIN_PLAYER_COUNT and not GameLoop.running then
        GameLoop.start()
    elseif not GameLoop.running then
        local difference = constants.Values.MIN_PLAYER_COUNT - players.size() 
        remotes.MinimumPlayers:FireAllClients(difference)
    end
end

---- Public Functions ----

function GameLoop.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    players = dataStructures.Set.new(Players:GetPlayers())
    livePlayers = dataStructures.Set.new()

    local debounce = {}
    local events = {}
    local connections = {}
    function remotes.PlayerReady.OnServerInvoke(player)
        
        if not player.Parent then return end
        debounce[player] = true
        events[player] = Instance.new("BindableEvent")

        players[player] = true
        coroutine.wrap(onPlayerCountChanged)()

        debounce[player] = nil
        events[player]:Fire()

        connections[player] = player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if livePlayers[player] then
                    livePlayers[player] = nil
                    modules.Seats.clearSeat(player)
                    -- Kill him!
                end
            end)
        end)
    end
    local function onRemoving(player)
        if debounce[player] then
            events[player].Event:Wait()
            events[player]:Destroy()
            events[player] = nil
        end
        players[player] = nil
        if livePlayers[player] then
            livePlayers[player] = nil
        end
        if connections[player] then
            connections[player]:Disconnect()
            connections[player] = nil
        end

        modules.Seats.clearSeat(player)
        
        coroutine.wrap(onPlayerCountChanged)()
    end
    Players.PlayerRemoving:Connect(onRemoving)
    for player in players:iterate() do
        if not Players:FindFirstChild(player.Name) then
            onRemoving(player)
        end
    end
end

function GameLoop.start()
    while players.size() >= constants.Values.MIN_PLAYER_COUNT do
        GameLoop.running = true
        GameLoop.current = modules.Intermission
        
        livePlayers = dataStructures.Set.new()
        for player in players.iterate() do
            livePlayers[player] = true
        end

        while GameLoop.running do
            local module = GameLoop.current
            module.start(livePlayers, players)
            GameLoop.current = module.next
        end

        for player in livePlayers.iterate() do
            livePlayers[player] = nil
        end
    end
    local difference = constants.Values.MIN_PLAYER_COUNT - players.size() 
    remotes.MinimumPlayers:FireAllClients(difference)
end

function GameLoop.stop()
    GameLoop.running = false
    if GameLoop.current.stop then
        GameLoop.current:stop()
    end
end

return GameLoop