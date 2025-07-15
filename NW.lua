loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

createWindow("Velonix Hub - NW", 28)
createLogo(12345678)

function ESP(s)
    if s then
        if espRunning then return end
        espRunning = true

        local function drawESP(player)
            if player == LocalPlayer or espObjects[player] then return end
            local esp = {
                box = Drawing.new("Square"),
                line = Drawing.new("Line"),
                text = Drawing.new("Text"),
                healthText = Drawing.new("Text")
            }
            esp.box.Thickness = 1
            esp.box.Filled = false
            esp.box.Visible = false
            esp.line.Thickness = 1
            esp.line.Visible = false
            for _, text in ipairs({esp.text, esp.healthText}) do
                text.Size = 16
                text.Center = true
                text.Outline = true
                text.OutlineColor = Color3.new()
                text.Visible = false
                text.Font = 2
            end
            esp.healthText.Size = 14
            espObjects[player] = esp
        end

        local function updateESP()
            for player, esp in pairs(espObjects) do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local boxSize = Vector2.new(50, 80)
                        esp.box.Size = boxSize
                        esp.box.Position = Vector2.new(pos.X, pos.Y) - boxSize / 2
                        esp.box.Color = Color3.fromHSV(hum.Health / hum.MaxHealth * 0.33, 1, 1)
                        esp.box.Visible = true
                        esp.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.line.To = Vector2.new(pos.X, pos.Y)
                        esp.line.Color = esp.box.Color
                        esp.line.Visible = true
                        esp.text.Text = player.Name
                        esp.text.Position = Vector2.new(pos.X, pos.Y - 50)
                        esp.text.Visible = true
                        esp.healthText.Text = string.format("%d/%d", hum.Health, hum.MaxHealth)
                        esp.healthText.Position = Vector2.new(pos.X, pos.Y + 50)
                        esp.healthText.Visible = true
                    else
                        for _, obj in pairs(esp) do obj.Visible = false end
                    end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            end
        end

        for _, p in ipairs(Players:GetPlayers()) do drawESP(p) end
        table.insert(connections, Players.PlayerAdded:Connect(drawESP))
        table.insert(connections, Players.PlayerRemoving:Connect(function(p)
            if espObjects[p] then
                for _, obj in pairs(espObjects[p]) do if obj.Remove then obj:Remove() end end
                espObjects[p] = nil
            end
        end))
        table.insert(connections, game:GetService("RunService").RenderStepped:Connect(updateESP))
    else
        espRunning = false
        for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
        for _, esp in pairs(espObjects) do for _, obj in pairs(esp) do if obj.Remove then obj:Remove() end end end
        table.clear(connections)
        table.clear(espObjects)
    end
end

function ESPS(s)
    getgenv().Toggle = s
    getgenv().TC = true

    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer

    local function setupHighlight(v)
        local char = v.Character
        if not char then return end
        if char:FindFirstChild("Totally NOT Esp") then return end

        local highlight = Instance.new("Highlight", char)
        highlight.Name = "Totally NOT Esp"
        highlight.Adornee = char
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = v.TeamColor.Color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0

        local icon = Instance.new("BillboardGui", char)
        icon.Name = "Icon"
        icon.AlwaysOnTop = true
        icon.ExtentsOffset = Vector3.new(0, 1, 0)
        icon.Size = UDim2.new(0, 800, 0, 50)

        local label = Instance.new("TextLabel", icon)
        label.Name = "ESP Text"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 800, 0, 50)
        label.Font = Enum.Font.SciFi
        label.TextColor3 = v.TeamColor.Color
        label.TextSize = 18
        label.TextWrapped = true
        label.Text = v.Name .. " | Distance: 0"
    end

    task.spawn(function()
        while getgenv().Toggle do
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= LP and v.Character then
                    local hrp1 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local hrp2 = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
                    if hrp1 and hrp2 then
                        local dist = math.floor((hrp1.Position - hrp2.Position).Magnitude)
                        setupHighlight(v)
                        local icon = v.Character:FindFirstChild("Icon")
                        if icon then
                            icon["ESP Text"].Text = v.Name .. " | Distance: " .. dist
                        end
                    end
                end
            end
            task.wait(0.2)
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("Totally NOT Esp")
                local i = p.Character:FindFirstChild("Icon")
                if h then h:Destroy() end
                if i then i:Destroy() end
            end
        end
    end)
end

function KillEnemy(s)
    if s then
        spawn(function()
            while wait(0.1) do
                local character = LocalPlayer.Character

                if character and character:FindFirstChild("Humanoid") then
                    for _, v in pairs(game.Workspace:GetDescendants()) do
                        if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("HumanoidRootPart") then
                            local targetPlayer = game.Players:GetPlayerFromCharacter(v.Parent)
                            if targetPlayer and targetPlayer.Team ~= LocalPlayer.Team then
                                local Event = game:GetService("ReplicatedStorage"):WaitForChild("Event")
                                Event:FireServer("shootRifle", "", {v.Parent.HumanoidRootPart})
                                Event:FireServer("shootRifle", "hit", {v})
                            end
                        end
                    end
                end
            end
        end)
        else
        print(" turn off ")
    end
end

function KillAll()
    if KillAll then
        spawn(function()
            while wait(0.1) do
                local character = LocalPlayer.Character

                if character and character:FindFirstChild("Humanoid") then
                    for _, v in pairs(game.Workspace:GetDescendants()) do
                        if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("HumanoidRootPart") then
                            local targetPlayer = game.Players:GetPlayerFromCharacter(v.Parent)
                            if targetPlayer and targetPlayer.Team ~= LocalPlayer.Team then
                                local Event = game:GetService("ReplicatedStorage"):WaitForChild("Event")
                                Event:FireServer("shootRifle", "", {v.Parent.HumanoidRootPart})
                                Event:FireServer("shootRifle", "hit", {v})
                            end
                        end
                    end
                end
            end
        end)
    end
end

function InfiniteAmmo(s)
    if s then
        spawn(function()
            while wait(3) do
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local oh_get_gc = getgc or false
                    local oh_is_x_closure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure or false
                    local oh_get_info = debug.getinfo or getinfo or false
                    local oh_set_upvalue = debug.setupvalue or setupvalue or setupval or false

                    if not oh_get_gc or not oh_get_info or not oh_set_upvalue then
                        createNotify("Velonix Hub", "Your Exploit Doesn't Support This")
                        return
                    end

                    local function oh_find_function(name)
                        for _, v in pairs(oh_get_gc()) do
                            if type(v) == "function" and not oh_is_x_closure(v) then
                                if oh_get_info(v).name == name then
                                    return v
                                end
                            end
                        end
                    end

                    local oh_reload = oh_find_function("reload")
                    if oh_reload then
                        local oh_index = 4  -- Adjust this index if needed
                        local oh_new_value = math.huge
                        oh_set_upvalue(oh_reload, oh_index, oh_new_value)
                    else
                        warn("Reload function not found")
                    end
                end
            end
        end)
    end
end

-- Tabs
createTab("Home", 1)
createTab("Main", 2)
createTab("Player", 3)
createTab("Teleport", 4)
createTab("Credits", 5)

-- Buttons/Toggles/Labels
-- Home Tab
createLabel("Made By Velonix Studio" 1)
-- Main Tab
createButton("Kill All", 2, function()
    KillAll()
end)
createDivider(2)
createButton("GodMode", 2, function()
    local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local team = player.Team and player.Team.Name or "Unknown" -- Ensure player.Team is valid
            print("Current Team: " .. team) -- Debug message to check the team name
            if team == "Japan" then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(-150.50711059570312, 23.0000057220459, -8160.171875)
            elseif team == "USA" then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(-50.992095947265625, 23.0000057220459, 8129.59423828125)
            else
                print("Team not recognized or not found")
            end
        else
            print("Player or HumanoidRootPart not found")
			end 
end)
createDivider(2)
createToggle("Kill Aura", 2, false, function(s)
    KillEnemy()
end)

createToggle("Inf Ammo", 2, false, function(s)
    InfiniteAmmo()
end)

-- Player Tab
createToggle("ESP 1", 3, false, function(s)
    ESP()
end)
createDivider(3)
createToggle("ESP 2", 3, false, function(s)
    ESPS()
end)

-- Teleport Tab
createButton("Japan Lobby", 4, function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-4.103087425231934, -295.5, -36.644065856933594)
end)
createDivider(4)
createButton("America Lobby", 4, function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(15.000070571899414, -295.5, 46.504608154296875)
end)
createButton("Teleport A", 4, function()
        -- LocalPlayer setup
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")

        -- Character handling
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        LocalPlayer.CharacterAdded:Connect(function(character)
            Character = character
        end)

        -- Island positions
        local IslandPositions = {
            IslandA = { X = nil, Y = nil, Z = nil },
            IslandB = { X = nil, Y = nil, Z = nil },
            IslandC = { X = nil, Y = nil, Z = nil },
        }

        -- Function to set island positions
        local function SetIslandPositions()
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v.Name == "Island" then
                    local flag = v:FindFirstChild("Flag")
                    if flag then
                        local post = flag:FindFirstChild("Post")
                        if post and post:IsA("BasePart") then
                            local position = post.Position
                            local islandCode = v:FindFirstChild("IslandCode")
                            if islandCode and islandCode:IsA("StringValue") then
                                if islandCode.Value == "A" then
                                    IslandPositions.IslandA.X, IslandPositions.IslandA.Y, IslandPositions.IslandA.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "B" then
                                    IslandPositions.IslandB.X, IslandPositions.IslandB.Y, IslandPositions.IslandB.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "C" then
                                    IslandPositions.IslandC.X, IslandPositions.IslandC.Y, IslandPositions.IslandC.Z = position.X, position.Y, position.Z
                                end
                            end
                        end
                    end
                end
            end
        end
        local function TeleportToIslandA()
            SetIslandPositions()
            if IslandPositions.IslandA.X then
                Character.HumanoidRootPart.CFrame = CFrame.new(IslandPositions.IslandA.X, IslandPositions.IslandA.Y, IslandPositions.IslandA.Z)
            end
        end
        TeleportToIslandA()
        LocalPlayer.Chatted:Connect(function(message)
            local nm = string.lower(message)
            if nm == ";tpa" then
                TeleportToIslandA()
            end
        end)
end)
createButton("Teleport B", 4, function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        LocalPlayer.CharacterAdded:Connect(function(character)
            Character = character
        end)
        local IslandPositions = {
            IslandA = { X = nil, Y = nil, Z = nil },
            IslandB = { X = nil, Y = nil, Z = nil },
            IslandC = { X = nil, Y = nil, Z = nil },
        }
        local function SetIslandPositions()
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v.Name == "Island" then
                    local flag = v:FindFirstChild("Flag")
                    if flag then
                        local post = flag:FindFirstChild("Post")
                        if post and post:IsA("BasePart") then
                            local position = post.Position
                            local islandCode = v:FindFirstChild("IslandCode")
                            if islandCode and islandCode:IsA("StringValue") then
                                if islandCode.Value == "A" then
                                    IslandPositions.IslandA.X, IslandPositions.IslandA.Y, IslandPositions.IslandA.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "B" then
                                    IslandPositions.IslandB.X, IslandPositions.IslandB.Y, IslandPositions.IslandB.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "C" then
                                    IslandPositions.IslandC.X, IslandPositions.IslandC.Y, IslandPositions.IslandC.Z = position.X, position.Y, position.Z
                                end
                            end
                        end
                    end
                end
            end
        end
        local function TeleportToIslandB()
            SetIslandPositions()
            if IslandPositions.IslandB.X then
                Character.HumanoidRootPart.CFrame = CFrame.new(IslandPositions.IslandB.X, IslandPositions.IslandB.Y, IslandPositions.IslandB.Z)
            end
        end
        TeleportToIslandB()
        LocalPlayer.Chatted:Connect(function(message)
            local nm = string.lower(message)
            if nm == ";tpb" then
                TeleportToIslandB()
            end
        end)
end)
createButton("Teleport C", 4, function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Workspace = game:GetService("Workspace")
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        LocalPlayer.CharacterAdded:Connect(function(character)
            Character = character
        end)
        local IslandPositions = {
            IslandA = { X = nil, Y = nil, Z = nil },
            IslandB = { X = nil, Y = nil, Z = nil },
            IslandC = { X = nil, Y = nil, Z = nil },
        }
        local function SetIslandPositions()
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") and v.Name == "Island" then
                    local flag = v:FindFirstChild("Flag")
                    if flag then
                        local post = flag:FindFirstChild("Post")
                        if post and post:IsA("BasePart") then
                            local position = post.Position
                            local islandCode = v:FindFirstChild("IslandCode")
                            if islandCode and islandCode:IsA("StringValue") then
                                if islandCode.Value == "A" then
                                    IslandPositions.IslandA.X, IslandPositions.IslandA.Y, IslandPositions.IslandA.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "B" then
                                    IslandPositions.IslandB.X, IslandPositions.IslandB.Y, IslandPositions.IslandB.Z = position.X, position.Y, position.Z
                                elseif islandCode.Value == "C" then
                                    IslandPositions.IslandC.X, IslandPositions.IslandC.Y, IslandPositions.IslandC.Z = position.X, position.Y, position.Z
                                end
                            end
                        end
                    end
                end
            end
        end
        spawn(function()
            while true do
                SetIslandPositions()
                wait(10)
            end
        end)
        SetIslandPositions()
        if IslandPositions.IslandC.X then
            Character.HumanoidRootPart.CFrame = CFrame.new(IslandPositions.IslandC.X, IslandPositions.IslandC.Y, IslandPositions.IslandC.Z)
        end
end)

createButton("Japan Lobby", 4, function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-150.50711059570312, 23.0000057220459, -8160.171875)
end)
createDivider(4)
createButton("America Lobby", 4, function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50.992095947265625, 23.0000057220459, 8129.59423828125)
end)

-- Credits Tab
createLabel("-- Developers" 5)
createLabel("C9_1234 - Owner" 5)
createLabel("GoodGamerYTbro - Co-Owner" 5)
createLabel("Velonix Team - All Contributers" 5)
-- Settings
createSettingButton("Discord", function()
    setclipboard("https://discord.gg/SXuNngnYPT")
    createNotify("Discord", "Copied Successfully!")
end)

createNotify("Title","Description")