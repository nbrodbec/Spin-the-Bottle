local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Menu = {}
Menu.dependencies = {
    modules = {"Gui", "ClientData", "FusionComponent"},
    utilities = {},
    dataStructures = {},
    constants = {"GamepassIDs", "ShopAssets", "GameModes"}
}
local modules
local utilities
local dataStructures
local constants
local gui
local remotes = ReplicatedStorage:WaitForChild("RemoteObjects")
local player = Players.LocalPlayer

---- Public Functions ----

function Menu.init(importedModules, importedUtilities, importedDataStructures, importedConstants)
    modules = importedModules
    utilities = importedUtilities
    dataStructures = importedDataStructures
    constants = importedConstants
    
    gui = modules.Gui.menuGui

    Menu.bindTag("exit", function(button)
        button.Activated:Connect(Menu.closeAll)
    end)

    local audioMenu = gui.Menus.Audio
    audioMenu.Input.FocusLost:Connect(function()
        local id = tonumber(audioMenu.Input.Text)
        if id then
            local success, msg = remotes.ChangeAudio:InvokeServer(id)
            if success then
                audioMenu.Input.UIStroke.Color = Color3.new(0, 1, 0)
                audioMenu.Message.Text = "Success!"
            else
                audioMenu.Input.UIStroke.Color = Color3.new(1, 0, 0)
                audioMenu.Message.Text = msg
            end
        else
            audioMenu.Input.UIStroke.Color = Color3.new(1, 0, 0)
            audioMenu.Message.Text = "ID must be a number!"
        end
    end)

    local audioRequest = gui.Menus.AudioRequest
    audioRequest.Input.FocusLost:Connect(function()
        local id = tonumber(audioRequest.Input.Text)
        if id then
            local success, msg = remotes.RequestMusic:InvokeServer(id)
            if success then
                audioRequest.Input.UIStroke.Color = Color3.new(0, 1, 0)
                audioRequest.Message.Text = "Pending!"
            else
                audioRequest.Input.UIStroke.Color = Color3.new(1, 0, 0)
                audioRequest.Message.Text = msg
            end
        else
            audioRequest.Input.UIStroke.Color = Color3.new(1, 0, 0)
            audioRequest.Message.Text = "ID must be a number!"
        end
    end)

    local gamemodeRequest = gui.Menus.GamemodeRequest
    for id, mode in pairs(constants.GameModes) do
        local button = ReplicatedStorage:WaitForChild("GameModeButton"):Clone()
        button.Text = mode.name
        local debounce = false
        button.Activated:Connect(function()
            if debounce then return end
            debounce = true
            local isPending = remotes.RequestGamemode:InvokeServer(id)
            if isPending then
                button.UIStroke.Color = Color3.new(0, 1, 0)
                button.Text = "Pending!"
                task.wait(3)
                button.UIStroke.Color = Color3.new(1, 1, 1)
                button.Text = mode.name
            else
                button.UIStroke.Color = Color3.new(1, 0, 0)
                button.Text = "A gamemode has already been requested!"
                task.wait(3)
                button.UIStroke.Color = Color3.new(1, 1, 1)
                button.Text = mode.name
            end
            debounce = false
        end)
        button.Parent = gamemodeRequest.ScrollingFrame
    end

    local selectedButton
    Menu.bindTag("ColourButton", function(button)
        button.Activated:Connect(function()
            if selectedButton then
                selectedButton.UIStroke.Transparency = 1
            end
            remotes.ChangeChatColor:FireServer(button.BackgroundColor3)
            selectedButton = button
            button.UIStroke.Transparency = 0
        end)
        
    end)

    local openContentPage = gui.Menus.Shop.Gamepasses
    Menu.bindTag("contentButton", function(button)
        local contentPage = gui.Menus.Shop:FindFirstChild(button.Name)
        if contentPage then
            button.Activated:Connect(function()
                if openContentPage then openContentPage.Visible = false end
                contentPage.Visible = true
                openContentPage = contentPage
            end)
        end
    end)

    Menu.setupShop()
end

local openMenu
function Menu.open(name)
    local menu = gui.Menus:FindFirstChild(name)
    if menu then
        if openMenu ~= name then
            Menu.closeAll()
            openMenu = name
            menu.Visible = true
            gui.Menus.Visible = true
        else
            Menu.closeAll()
        end
    end
end

function Menu.closeAll()
    gui.Menus.Visible = false
    for _, menu in ipairs(gui.Menus:GetChildren()) do
        menu.Visible = false
    end
    openMenu = nil
end

local function updateButton(button)
    button.Purchase.ImageLabel.Visible = false
    button.Purchase.TextLabel.Text = "Equip"
    button.Purchase.TextLabel.Size = UDim2.fromScale(1, 1)
    button.Purchase.TextLabel.Position = UDim2.fromScale(1, 0.5)
end

function Menu.setupShop()
    local suitFrame = gui.Menus.Shop.Suits
    local animFrame = gui.Menus.Shop.Anims
    local gunFrame = gui.Menus.Shop.Guns
    local suits = constants.ShopAssets.suits
    local anims = constants.ShopAssets.animations
    local guns = constants.ShopAssets.guns

    local itemFrame = ReplicatedStorage.Gui.ShopAvatarItem

    local equippedSuit = modules.ClientData.get("suit")
    local equippedAnim = modules.ClientData.get("deathAnimId")
    local equippedGun = modules.ClientData.get("gun")

    local ownedSuits = modules.ClientData.get("ownedSuits")
    local ownedAnims = modules.ClientData.get("ownedAnims")
    local ownedGuns = modules.ClientData.get("ownedGuns")

    local equippedSuitButton, equippedAnimButton, equippedGunButton

    for id, suit in ipairs(suits) do
        local inGroup
        if suit.groupId then
            inGroup = player:IsInGroup(suit.groupId)
        end
		local frame = itemFrame:Clone()
		frame.LayoutOrder = suit.layoutOrder or 0
        frame.Name = tostring(id)
        frame.Title.Text = suit.name
        frame.Wins.Text = suit.groupId and "Group Member" or string.format("%d Wins", suit.level)   
        frame.Visible = if suit.isCurrentlyAvailable == false and not table.find(ownedSuits, id) and not inGroup then false else true

        local dummy = frame.ViewportFrame.WorldModel.Dummy
        local description = dummy.Humanoid:GetAppliedDescription()
        description.Shirt = suit.shirt
        description.Pants = suit.pants
        
        
        local camera = Instance.new("Camera")
        camera.FieldOfView = 25
        local theta = math.rad(camera.FieldOfView/2)
        local opp = (dummy.Torso.Size.Y + dummy["Left Leg"].Size.Y)/2
        local padding = 0.2
        local adj = (opp+padding)/math.tan(theta)
        local cameraCF = (dummy.Torso.CFrame 
                        - Vector3.new(0, dummy.Torso.Position.Y, 0) 
                        + Vector3.new(0, dummy.Torso.Position.Y+dummy.Torso.Size.Y/2 - opp, 0)) 
                        * CFrame.Angles(0, math.pi, 0) 
                        * CFrame.new(0, 0, adj)
        camera.CFrame = cameraCF
        
        frame.ViewportFrame.CurrentCamera = camera

        frame.Parent = suitFrame
        frame.ViewportFrame.WorldModel.Dummy.Humanoid:ApplyDescription(description)

        local connection
        frame.ViewportFrame.MouseEnter:Connect(function()
            connection = RunService.RenderStepped:Connect(function(dt)
                if not connection.Connected then return end
                camera.CFrame *= CFrame.new(0, 0, -adj) * CFrame.Angles(0, math.pi/2*dt, 0) * CFrame.new(0, 0, adj)
            end)
        end)
        frame.ViewportFrame.MouseLeave:Connect(function()
            connection:Disconnect()
            camera.CFrame = cameraCF
        end)
        
        local canEquip = false
        frame.Activated:Connect(function()
            remotes.EquipSuit:FireServer(id)
            if canEquip then
                if equippedSuitButton then equippedSuitButton.Text = "Equip" end
                equippedSuitButton = frame.Purchase.TextLabel
                equippedSuitButton.Text = "Equipped"
            end
        end)
        if (modules.ClientData.get("wins") >= suit.level and suit.isCurrentlyAvailable) or table.find(ownedSuits, id) then
            updateButton(frame)
            canEquip = true
        elseif inGroup then
            updateButton(frame)
            canEquip = true
        else
            modules.ClientData.getChanged("wins"):Connect(function(wins)
                if wins >= suit.level and not canEquip then
                    updateButton(frame)
                    canEquip = true
                end
            end)
            modules.ClientData.getChanged("ownedSuits"):Connect(function(ownedSuits)
                if table.find(ownedSuits, id)  then
                    updateButton(frame)
                    canEquip = true
                    frame.Visible = true
                end
            end)
        end

        if suit.shirt == equippedSuit.shirt then
            frame.Purchase.TextLabel.Text = "Equipped"
            equippedSuitButton = frame.Purchase.TextLabel
        end
    end

    for id, anim in ipairs(anims) do
        local frame = itemFrame:Clone()
        frame.Name = tostring(id)
        frame.Title.Text = anim.name
        frame.Wins.Text = string.format("%d Wins", anim.level)

        local dummy = frame.ViewportFrame.WorldModel.Dummy
        local animation = Instance.new("Animation")
        local animator = Instance.new("Animator", dummy.Humanoid)
        animation.AnimationId = string.format("rbxassetid://%d", anim.id)
        animation.Parent = dummy

        
        
        local camera = Instance.new("Camera")
        camera.FieldOfView = 40
        local theta = math.rad(camera.FieldOfView/2)
        local opp = (dummy.Torso.Size.Y + dummy["Left Leg"].Size.Y + dummy.Head.Size.Y)/2
        local padding = 0.2
        local adj = (opp+padding)/math.tan(theta)
        local cameraCF = (dummy.Torso.CFrame 
                        - Vector3.new(0, dummy.Torso.Position.Y, 0) 
                        + Vector3.new(0, dummy.Head.Position.Y+dummy.Head.Size.Y/2 - opp, 0)) 
                        * CFrame.Angles(0, math.pi, 0) 
                        * CFrame.new(0, 0, adj)
        camera.CFrame = cameraCF
        frame.ViewportFrame.CurrentCamera = camera
        frame.Parent = animFrame
        local track = animator:LoadAnimation(animation)

        local canEquip = false
        frame.ViewportFrame.MouseEnter:Connect(function()
            track:Play()
        end)

        frame.Activated:Connect(function()
            remotes.EquipAnim:FireServer(id)
            if canEquip then
                if equippedAnimButton then equippedAnimButton.Text = "Equip" end
                equippedAnimButton = frame.Purchase.TextLabel
                equippedAnimButton.Text = "Equipped"
            end
        end)

        if modules.ClientData.get("wins") >= anim.level or table.find(ownedAnims, id) then
            updateButton(frame)
            canEquip = true
        else
            modules.ClientData.getChanged("wins"):Connect(function(wins)
                if wins >= anim.level then
                    updateButton(frame)
                    canEquip = true
                end
            end)
            modules.ClientData.getChanged("ownedAnims"):Connect(function(ownedAnims)
                if not canEquip and table.find(ownedAnims, id) then
                    updateButton(frame)
                    canEquip = true
                end
            end)
        end

        if anim.id == equippedAnim then
            frame.Purchase.TextLabel.Text = "Equipped"
            equippedAnimButton = frame.Purchase.TextLabel
        end
    end

    for id, gun in ipairs(guns) do
        local hasPass
        if gun.gamepassId then
            hasPass = remotes.PlayerHasPass:InvokeServer(gun.gamepassId)
        end
		local frame = itemFrame:Clone()
		frame.LayoutOrder = gun.layoutOrder or 0
        frame.Name = tostring(id)
        frame.Title.Text = gun.name
        frame.Wins.Text = gun.gamepassId and "Gamepass" or string.format("%d Wins", gun.level)   
        frame.Visible = if gun.isCurrentlyAvailable == false and not table.find(ownedGuns, id) and not hasPass then false else true
        
        local model = gun.model:Clone()
        model.Parent = frame.ViewportFrame.WorldModel

        local camera = Instance.new("Camera")
        camera.FieldOfView = 25
        local theta = math.rad(camera.FieldOfView/2)
        local opp = (model.PrimaryPart or model.Handle).Size.Z/2
        local padding = 0.1
        local adj = (opp + padding)/math.tan(theta)
        local cameraCF = (model.PrimaryPart or model.Handle).CFrame * CFrame.Angles(0, -math.pi/2, 0) * CFrame.new(0, 0, adj)
        camera.CFrame = cameraCF
        
        frame.ViewportFrame.CurrentCamera = camera

        frame.Parent = gunFrame

        local connection
        frame.ViewportFrame.MouseEnter:Connect(function()
            connection = RunService.RenderStepped:Connect(function(dt)
                if not connection.Connected then return end
                camera.CFrame *= CFrame.new(0, 0, -adj) * CFrame.Angles(0, math.pi/2*dt, 0) * CFrame.new(0, 0, adj)
            end)
        end)
        frame.ViewportFrame.MouseLeave:Connect(function()
            connection:Disconnect()
            camera.CFrame = cameraCF
        end)

        local canEquip = false
        frame.Activated:Connect(function()
            remotes.EquipGun:FireServer(id)
            if canEquip then
                if equippedGunButton then equippedGunButton.Text = "Equip" end
                equippedGunButton = frame.Purchase.TextLabel
                equippedGunButton.Text = "Equipped"
            end
        end)
        if (modules.ClientData.get("wins") >= gun.level and gun.isCurrentlyAvailable) or table.find(ownedGuns, id) then
            updateButton(frame)
            canEquip = true
        elseif hasPass then
            updateButton(frame)
            canEquip = true
        else
            modules.ClientData.getChanged("wins"):Connect(function(wins)
                if wins >= gun.level and not canEquip then
                    updateButton(frame)
                    canEquip = true
                end
            end)
            modules.ClientData.getChanged("ownedGuns"):Connect(function(ownedGuns)
                if not canEquip and table.find(ownedGuns, id)  then
                    updateButton(frame)
                    canEquip = true
                    frame.Visible = true
                end
            end)
        end

        if id == equippedGun then
            frame.Purchase.TextLabel.Text = "Equipped"
            equippedGunButton = frame.Purchase.TextLabel
        end
    end
end

function Menu.bindTag(tag, fun)
    for i,v in ipairs(CollectionService:GetTagged(tag)) do
        fun(v)
    end
    CollectionService:GetInstanceAddedSignal(tag):Connect(fun)
end

return Menu