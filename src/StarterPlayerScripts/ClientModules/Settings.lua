local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = {}
Settings.dependencies = {
    modules = {"Menu", "Gui", "ClientData", "MusicController"},
    utilities = {},
    dataStructures = {},
    constants = {}
}
local modules
local utilities
local dataStructures
local constants
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local gui

local Fusion = require(ReplicatedStorage.Fusion)
local State = Fusion.State
local isAFK = State(false)
---- Public Functions ----

function Settings.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants

    gui = modules.Gui.menuGui

    gui.Footer.Settings.Activated:Connect(function()
        modules.Menu.open("Settings")
    end)

    modules.Menu.bindTag("settingButton", function(button)
        local settingName = button.Parent.Parent.Name
        button.Activated:Connect(function()
            local newState = Settings.toggleSetting(settingName)
            if newState ~= nil then
                button.BackgroundTransparency = if newState == true then 0 else 1
            end
        end)
    end)

    Settings.loadSettings()
end

function Settings.loadSettings()
    local settings = modules.ClientData.get("settings")
    if settings then
        -- Set audio --
        if settings.musicEnabled == false then 
            modules.MusicController.mute()
            gui.Menus.Settings.musicEnabled.Frame.button.BackgroundTransparency = 1
        end
        -- Set blood --
        if settings.bloodEnabled == false then 
            gui.Menus.Settings.bloodEnabled.Frame.button.BackgroundTransparency = 1
        end

        -- Set Bottles --
        if settings.bottlesEnabled == false then
            for _, v in ipairs(CollectionService:GetTagged("bottle")) do
                v.Parent = ReplicatedStorage.HiddenBottles
            end
        end
    end
end

function Settings.getSetting(settingName)
    local settings = modules.ClientData.get("settings")
    return settings and settings[settingName]
end

function Settings.toggleSetting(settingName)
    local settings = modules.ClientData.get("settings")
    if settings then 
        settings[settingName] = not settings[settingName] 
        remotes.SetData:FireServer("settings", settings)
        if settingName == "musicEnabled" then
            if settings[settingName] then modules.MusicController.unmute() else modules.MusicController.mute() end
        elseif settingName == "bottlesEnabled" then
            if settings[settingName] then 
                 for _, v in ipairs(CollectionService:GetTagged("bottle")) do
                     v.Parent = workspace
                 end
            else 
                for _, v in ipairs(CollectionService:GetTagged("bottle")) do
                    v.Parent = ReplicatedStorage.HiddenBottles
                end
            end
        end
        return settings[settingName]
    end
end

function Settings.getIsAFK()
    return isAFK
end

function Settings.toggleAFK()
    local newStatus = remotes.ChangeAFKStatus:InvokeServer()
    if newStatus ~= nil then
        isAFK:set(newStatus)
    end
end

return Settings