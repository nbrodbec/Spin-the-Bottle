local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Data = {}
Data.dependencies = {
    modules = {},
    utilities = {"Reconcile", "Timer"},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage.RemoteObjects

local dataStore = DataStoreService:GetDataStore("Data")
local template = {
    wins = 0,
    deathSound = "rbxasset://sounds/uuhhh.mp3",
    suit = {
        shirt = 1210857662,
        pants = 6555797786
    },
  --  deathAnimId = nil,
    ownedSuits = {},
    ownedAnims = {},
    corrupted = false,
    version = 1
}

local sessions = {}
local timers = {}
local dataLoaded = Instance.new("BindableEvent")

---- Private Functions ----

local function getData(key)
    local success = false
    local data
    local tries = 0
    while not success and tries <= 3 do
        success, data = pcall(dataStore.GetAsync, dataStore, key)
        tries += 1
    end
    if not success then 
        print(data) 
        data = utilities.Reconcile.reconcile({}, template)
        data.corrupted = true
    end
    return data
end

---- Public Functions ----
local debounce = {}
function Data.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    
    local function onPlayerAdded(player)
        debounce[player] = Instance.new("BindableEvent")
        local data = getData(player.UserId) or {}
        utilities.Reconcile.reconcile(data, template)
        sessions[player] = data
        
        do
            debounce[player]:Fire()
            debounce[player]:Destroy()
            debounce[player] = nil  
            dataLoaded:Fire(player)
        end 
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    Players.PlayerRemoving:Connect(function(player)
        if debounce[player] then
            debounce[player].Event:Wait()
        end
        Data.save(player)
        sessions[player] = nil
    end)

    local closeEvent = Instance.new("BindableEvent")
    game:BindToClose(function()
        for player, session in pairs(sessions) do
            task.spawn(function()
                Data.save(player)
                sessions[player] = nil
                if not next(sessions) then
                    closeEvent:Fire()
                end
            end)
        end
        if next(sessions) then
            closeEvent.Event:Wait()
        end
    end)

    remotes.InitData.OnServerInvoke = Data.get
end

function Data.save(player)
    if timers[player] then
        timers[player]:yield()
    end
    local new = sessions[player]
    if not new then return end

    local success, msg = pcall(dataStore.UpdateAsync, dataStore, player.UserId, function(old)
        if new.corrupted then return end
        if old and old.version ~= new.version then return end
        new.version += 1
        return new
    end)
    if success then
        timers[player] = utilities.Timer.new(6)
        timers[player]:start()
    end
end

function Data.get(player, key)
    if not sessions[player] then
        local p 
        while p ~= player do
            p = dataLoaded.Event:Wait()
        end
    end
    local data = sessions[player]
    if data then
        if key then
            if typeof(key) == "table" then
                local toReturn = {}
                for _, k in ipairs(key) do
                    table.insert(toReturn, data[k])
                end
                return unpack(toReturn)
            else
                return data[key]
            end
        else
            return data
        end
    end
end

function Data.set(player, key, value)
    local data = sessions[player]
    if data then
        data[key] = value
        remotes.SyncData:FireClient(player, key, value)
    end
end

return Data