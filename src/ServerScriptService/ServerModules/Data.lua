local Players = game:GetService("Players")
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

local dataStore = DataStoreService:GetDataStore("Data")
local template = {
    wins = 0,
    deathSound = "rbxasset://sounds/uuhhh.mp3",
    suit = {
        shirt = 1210857662,
        pants = 6555797786
    },
    corrupted = false,
    version = 1
}

local sessions = {}
local timers = {}

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
    if debounce[player] then debounce[player].Event:Wait() end
    local data = sessions[player]
    if data then
        return data[key]
    end
end

function Data.set(player, key, value)
    local data = sessions[player]
    if data then
        data[key] = value
    end
end

return Data