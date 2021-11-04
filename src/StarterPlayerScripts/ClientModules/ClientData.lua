local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientData = {}
ClientData.dependencies = {
    modules = {},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local data
local events = {}

---- Public Functions ----

function ClientData.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    data = remotes.InitData:InvokeServer()
    remotes.SyncData.OnClientEvent:Connect(ClientData.set)
end

function ClientData.get(...)
    local keys = {...}
    local toReturn = {}
    for _, key in ipairs(keys) do
        if data[key] then table.insert(toReturn, data[key]) end
    end
    return unpack(toReturn)
end

function ClientData.set(key, value)
    data[key] = value
    if events[key] then events[key]:Fire(value) end 
end

function ClientData.getChanged(keyName)
    local event = events[keyName] or Instance.new("BindableEvent")
    events[keyName] = event
    return event.Event
end

return ClientData