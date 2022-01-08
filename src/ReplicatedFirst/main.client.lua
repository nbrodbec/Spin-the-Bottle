local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local loadingUI = ReplicatedFirst:WaitForChild("Intro"):Clone()
loadingUI.Parent = PlayerGui

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local TweenService = game:GetService("TweenService")
local loadables = {
    loadingUI,
    "rbxassetid://7384029571",
    SoundService, 
    "rbxassetid://474829770",
    "rbxassetid://4919760420",
    "rbxassetid://1835749037",
    "rbxassetid://1841979451",
    "rbxassetid://1837566969"
}
local loaded = false
local loadedEvent = Instance.new("BindableEvent")
coroutine.wrap(function()
	for i = 1, #loadables do
		ContentProvider:PreloadAsync({loadables[i]})
	end
	loaded = true
    loadedEvent:Fire()
end)()
local moduleLoaded = false
local moduleLoadedEvent = Instance.new("BindableEvent")
coroutine.wrap(function()
    require(ReplicatedStorage:WaitForChild("MainModule")).init(player.PlayerScripts:WaitForChild("ClientModules"))
    moduleLoaded = true
    moduleLoadedEvent:Fire()
end)()

-- begin intro

local logo = loadingUI.Frame.logo
local top = logo.top
local bottom = logo.bottom
local cover = loadingUI.Frame.black
local text = loadingUI.Frame.title
local loadingBar = loadingUI.Frame.radialLoad

local sound = Instance.new("Sound", SoundService)
sound.SoundId = "rbxassetid://7384029571"
if not sound.IsLoaded then sound.Loaded:Wait() end

local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)

local function openMouth(t)
    local tween = TweenService:Create(
        bottom,
        TweenInfo.new(
            t/2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.InOut,
            0,
            true
        ),
        {
            Position = UDim2.fromScale(0, 0.1)
        }
    )
    tween:Play()
    return tween
end

local function tiltHead(t, theta)
    local tween = TweenService:Create(
        logo,
        TweenInfo.new(
            t/2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.InOut,
            0,
            true
        ),
        {
            Rotation = theta,
            Size = UDim2.fromScale(1.25, 1.25)
        }
    )   
    tween:Play()
    return tween
end

local function map(x, inMin, inMax, outMin, outMax)
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end


local fadeTween = TweenService:Create(
    cover,
    fadeInfo,
    {
        BackgroundTransparency = 1
    }
)
fadeTween:Play()
fadeTween.Completed:Wait()

sound:Play()

tiltHead(0.2, 35)
openMouth(0.2).Completed:Wait()

tiltHead(0.2, -35)
openMouth(0.2).Completed:Wait()

tiltHead(0.3, 30)
openMouth(0.3).Completed:Wait()

tiltHead(0.3, -30)
openMouth(0.3).Completed:Wait()

tiltHead(0.3, 20)
openMouth(0.3).Completed:Wait()

tiltHead(0.3, -20)
openMouth(0.3).Completed:Wait()

tiltHead(0.75, 10)
openMouth(0.75)

for i = 1, 200 do
    text.UIGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(i/200, 1),
        NumberSequenceKeypoint.new(1, 1)
    })
    RunService.RenderStepped:Wait()
end

loadingBar.Visible = true
TweenService:Create(
    loadingBar.ImageLabel,
    fadeInfo,
    {
        ImageTransparency = 0
    }
):Play()

local t = -math.pi/2
while not (loaded and moduleLoaded and not sound.IsPlaying) do
    t += RunService.RenderStepped:Wait()
    if t > math.pi/2 then t = -math.pi/2 end
    loadingBar.Rotation = math.sin(2*t)*360
end

-- end intro


local fadeOutTween = TweenService:Create(
    cover,
    fadeInfo,
    {
        BackgroundTransparency = 0
    }
)
fadeOutTween:Play()
fadeOutTween.Completed:Wait()

logo.Visible = false
loadingBar.Visible = false

local fadeOutTween2 = TweenService:Create(
    loadingUI.Frame,
    fadeInfo,
    {
        BackgroundTransparency = 1
    }
)
fadeOutTween2:Play()
fadeOutTween2.Completed:Wait()

loadingUI:Destroy()

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

require(ReplicatedStorage.MainModule).onLoadFinished()


