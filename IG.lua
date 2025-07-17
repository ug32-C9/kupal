loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/main/Main3.lua"))()

local function bypassAntiCheat()
    local rootFrame = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("rootFrame")
    if rootFrame then
        rootFrame:Destroy()
    end

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "TeleportService" or method == "FireServer" then
            return
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

createWindow("Velonix Hub - Ink Game", 28)
createLogo(12345678)
createNotify("Velonix Hub", "Anti-Cheat bypassed! Teleport freely")
bypassAntiCheat()

createTab("Home", 1)
createLabel("Ink Game Hacks v1.0", 1)
createDivider(1)
createButton("Rejoin Server", 1, function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

createTab("Player", 2)
createToggle("Enable MP5 Mods", 2, false, function(state)
    local MP5 = game:GetService("ReplicatedStorage").Weapons.Guns:FindFirstChild("MP5")
    if state then
        if MP5 then
            if not _G.OriginalValues then
                _G.OriginalValues = {
                    MaxBullets = MP5.MaxBullets.Value,
                    Spread = MP5.Spread.Value,
                    BulletsPerFire = MP5.BulletsPerFire.Value,
                    FireRateCD = MP5.FireRateCD.Value
                }
            end
            MP5.MaxBullets.Value = 6969
            MP5.Spread.Value = 0
            MP5.BulletsPerFire.Value = 3
            MP5.FireRateCD.Value = 0
            createNotify("Gun Mod", "MP5 modifications applied!")
        else
            createNotify("Error", "MP5 not found in ReplicatedStorage!")
        end
    else
        if _G.OriginalValues and MP5 then
            MP5.MaxBullets.Value = _G.OriginalValues.MaxBullets
            MP5.Spread.Value = _G.OriginalValues.Spread
            MP5.BulletsPerFire.Value = _G.OriginalValues.BulletsPerFire
            MP5.FireRateCD.Value = _G.OriginalValues.FireRateCD
            createNotify("Gun Mod", "MP5 values restored!")
        end
    end
end)

createToggle("Red Light Green Light Godmode", 2, false, function(state)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local lplr = Players.LocalPlayer
    local UIS = game:GetService("UserInputService")
    local RLGL_OriginalNamecall = nil
    local RLGL_Connection = nil
    local lastRootPartCFrame = nil
    local isGreenLight = true

    if state then
        local TrafficLightImage = lplr:FindFirstChild("PlayerGui") and
            lplr.PlayerGui:FindFirstChild("ImpactFrames") and
            lplr.PlayerGui.ImpactFrames:FindFirstChild("TrafficLightEmpty")

        if TrafficLightImage and ReplicatedStorage:FindFirstChild("Effects") then
            local Lights = ReplicatedStorage.Effects:FindFirstChild("Images") and ReplicatedStorage.Effects.Images:FindFirstChild("TrafficLights")
            if Lights and Lights:FindFirstChild("GreenLight") then
                isGreenLight = TrafficLightImage.Image == Lights.GreenLight.Image
            end
        end

        local function updateCFrame()
            local char = lplr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                lastRootPartCFrame = root.CFrame
            end
        end

        updateCFrame()

        RLGL_Connection = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Effects").OnClientEvent:Connect(function(data)
            if data.EffectName ~= "TrafficLight" then return end
            isGreenLight = data.GreenLight == true
            updateCFrame()
        end)

        RLGL_OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local args = { ... }
            local method = getnamecallmethod()
            if tostring(self) == "rootCFrame" and method == "FireServer" then
                if state and not isGreenLight and lastRootPartCFrame then
                    args[1] = lastRootPartCFrame
                    return RLGL_OriginalNamecall(self, unpack(args))
                end
            end
            return RLGL_OriginalNamecall(self, ...)
        end)

        _G.RLGL_Connection = RLGL_Connection
        _G.RLGL_OriginalNamecall = RLGL_OriginalNamecall
        createNotify("RedLightGodmode", "Enabled")
    else
        if _G.RLGL_Connection then
            pcall(function() _G.RLGL_Connection:Disconnect() end)
            _G.RLGL_Connection = nil
        end
        if _G.RLGL_OriginalNamecall then
            hookmetamethod(game, "__namecall", _G.RLGL_OriginalNamecall)
            _G.RLGL_OriginalNamecall = nil
        end
        createNotify("RedLightGodmode", "Disabled")
    end
end)

createTab("Game", 3)
-- Dalgona Section
createButton("Auto-Complete Dalgona", 3, function()
    local args = {{Completed = true}}
    local remote = game:GetService("ReplicatedStorage").Remotes:FindFirstChild("DALGONATEMPREMPTE")
    if remote then
        bypassAntiCheat()
        remote:FireServer(unpack(args))
        createNotify("Dalgona", "Task completed automatically!")
    else
        createNotify("Error", "Remote event not found!")
    end
end)
createDivider(3)

-- Hide & Seek Section
createToggle("Hide & Seek ESP", 3, false, function(state)
    if state then
        local function createHighlight(character, color)
            local highlight = Instance.new("Highlight")
            highlight.Adornee = character
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.Parent = character
            return highlight
        end

        _G.ESP_Highlights = {}

        local function updateESP()
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local roleColor = Color3.fromRGB(0, 0, 255)
                    if player:FindFirstChild("Seeker") or player.Character:FindFirstChild("Seeker") then
                        roleColor = Color3.fromRGB(255, 0, 0)
                    end
                    if not _G.ESP_Highlights[player] then
                        _G.ESP_Highlights[player] = createHighlight(player.Character, roleColor)
                    else
                        _G.ESP_Highlights[player].FillColor = roleColor
                        _G.ESP_Highlights[player].OutlineColor = roleColor
                    end
                end
            end
        end

        updateESP()

        _G.ESP_Connections = {
            PlayersAdded = game:GetService("Players").PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    wait(1)
                    updateESP()
                end)
            end),
            CharacterAdded = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(updateESP),
            Heartbeat = game:GetService("RunService").Heartbeat:Connect(updateESP)
        }

        createNotify("ESP", "Hide & Seek ESP activated!")
    else
        if _G.ESP_Highlights then
            for _, highlight in pairs(_G.ESP_Highlights) do
                highlight:Destroy()
            end
            _G.ESP_Highlights = nil
        end

        if _G.ESP_Connections then
            for _, conn in pairs(_G.ESP_Connections) do
                conn:Disconnect()
            end
            _G.ESP_Connections = nil
        end
    end
end)
createLabel("Blue = Hider | Red = Seeker", 3)
createButton("Teleport: Hide & Seek Safe Spot", 3, function()
    local char = game.Players.LocalPlayer.Character
    if char then
        char:MoveTo(Vector3.new(229.9, 1005.3, 169.4))
        createNotify("Teleport", "Teleported to Hide & Seek safe spot!")
    end
end)
createDivider(3)

-- Glass Bridge Section
createButton("Reveal Glass Bridge", 3, function()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
        return
    end
    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                local transparency = 0.5
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                            Transparency = transparency,
                            Color = targetColor
                        }):Play()
                    end
                end
                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
            end
        end
    end
    createNotify("Glass Bridge", "All tiles revealed!")
end)

createButton("Glass Troll (Touch Fake Glass)", 3, function()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
        return
    end
    
    local localPlayer = game.Players.LocalPlayer
    
    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true
                
                if isBreakable then
                    -- Create a copy of a safe tile (green) but make it appear red for us
                    local fakeClone = tileModel:Clone()
                    fakeClone.Name = "TrollGlass"
                    fakeClone.Parent = workspace
                    
                    -- Position it exactly where the original is
                    fakeClone:SetPrimaryPartCFrame(tileModel.PrimaryPart.CFrame)
                    
                    -- Make it look red for us
                    for _, part in pairs(fakeClone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0.5
                            part.Color = Color3.fromRGB(255, 0, 0)
                        end
                    end
                    
                    -- Add highlight to show it's a troll tile
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = fakeClone
                    
                    -- Make original tile non-collidable
                    for _, part in pairs(tileModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- Make the clone only collidable for local player
                    for _, part in pairs(fakeClone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanTouch = false
                            part.Touched:Connect(function(hit)
                                if hit.Parent == localPlayer.Character then
                                    firetouchinterest(primaryPart, hit, 0) -- Touch original part
                                    firetouchinterest(primaryPart, hit, 1) -- Untouch
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
    createNotify("Glass Troll", "Fake glass replaced! Only you can touch them")
end)

createButton("Teleport: End of Glass Bridge", 3, function()
    local char = game.Players.LocalPlayer.Character
    if char then
        char:MoveTo(Vector3.new(-203.9, 520.7, -1534.3485))
        createNotify("Teleport", "Teleported to end of Glass Bridge!")
    end
end)
createDivider(3)

-- Red Light Green Light Section
createButton("Teleport: RLGL Finish Line", 3, function()
    local char = game.Players.LocalPlayer.Character
    if char then
        char:MoveTo(Vector3.new(-100.8, 1030, 115))
        createNotify("Teleport", "Teleported to RLGL finish line!")
    end
end)

createTab("Teleport", 4)
createButton("Teleport to Random Player", 4, function()
    local players = game:GetService("Players"):GetPlayers()
    local target = players[math.random(2, #players)]
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    createNotify("Teleport", "Teleported to "..target.Name)
end)
createButton("Teleport to Safe Zone", 4, function()
    local safeSpot = Vector3.new(-108, 329.1, 462.1)
    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safeSpot)
    createNotify("Teleport", "Teleported to safe zone!")
end)

createSettingButton("Destroy UI", function()
    game:GetService("CoreGui").VelonixHub:Destroy()
end)
createSettingButton("Anti-Cheat Status", function()
    createNotify("Security", "rootFrame spoofed\nTeleport unlocked\nGame Version: 7267")
end)