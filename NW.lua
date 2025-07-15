local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Velonix Hub",
    Icon = "door-open",
    Author = "itzC9",
    Folder = "VELONIXHUB",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "rbxassetid://18555523643",
    HasOutline = false,
    KeySystem = { 
        Key = {
        "VXN-A9F4-LK2B",
        "VXN-3G7H-M4P9",
        "VXN-ZX9Q-W4RT",    -- ← Admin key
        "VXN-M0P9-Q1KL" --- ← Lifetime user
        },
        Note = "Velonix-Studio Creation",
         Thumbnail = {
             Image = "rbxassetid://18610378548",
             Title = "Thumbnail"
         },
        URL = "https://velonix-scripts.vercel.app/",
        SaveKey = true,
    },
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "mouse-pointer-2", Desc = "Main Activity" }),
    
    Teleport = Window:Tab({ Title = "Teleport", Icon = "mouse-pointer-2", Desc = "Teleport Activity" }),
    
    Player = Window:Tab({ Title = "Player", Icon = "mouse-pointer-2", Desc = "Player Activity" }),
    
    Credits = Window:Tab({ Title = "Credits", Icon = "youtube", Desc = "Script Developers" }),
    
    WindowTab = Window:Tab({ Title = "Window and File Configuration", Icon = "settings", Desc = "Manage window settings and file configurations." }),
    
    ThemeTab = Window:Tab({ Title = "Create Theme", Icon = "palette", Desc = "Design and apply custom themes." }),
    be = Window:Divider(),
}
Window:SelectTab(1)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local espRunning = false
local connections = {}
local espObjects = {}

-- Function for Infinite Ammo
local function InfiniteAmmo(state)
    print("Infinite Ammo Feature enabled: " .. tostring(state))
    if not state then return end

    task.spawn(function()
        local player = game.Players.LocalPlayer
        local supported = getgc and debug and debug.getinfo and debug.setupvalue

        if not supported then
            if Fluent then
                Fluent:Notify({
                    Title = "Executor Unsupported",
                    Content = "Velonix Hub",
                    SubContent = "Your executor doesn't support memory editing.",
                    Duration = 5
                })
            end
            return
        end

        local function findReloadFunction()
            for _, func in pairs(getgc(true)) do
                if typeof(func) == "function" and not is_synapse_function(func) then
                    local info = debug.getinfo(func)
                    if info and info.name == "reload" then
                        return func
                    end
                end
            end
        end

        local function tryPatch()
            local reloadFunc = findReloadFunction()
            if reloadFunc then
                for i = 1, 10 do
                    local val = debug.getupvalue(reloadFunc, i)
                    if type(val) == "number" and val <= 100 then
                        print("🔫 Ammo override applied at upvalue index:", i)
                        debug.setupvalue(reloadFunc, i, math.huge)
                        return true
                    end
                end
            end
            return false
        end

        -- Main retry logic: Try after 1st, 2nd, and 3rd bullet
        for attempt = 1, 3 do
            local success = tryPatch()
            if success then
                break
            else
                warn("🔁 Retry InfiniteAmmo attempt: " .. attempt)
                task.wait(1.2) -- Give time for shot to fire and func to GC
            end
        end

        if Fluent then
            Fluent:Notify({
                Title = "Velonix Hub",
                Content = "Ammo Hook Complete",
                SubContent = "Infinite Ammo applied or max retry reached.",
                Duration = 4
            })
        end
    end)
end

-- ESP
function ESP(state)
    if state then
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

-- Function for Kill Enemy
local function KillEnemy()
    print("Kill Enemy Feature enabled")
    
    if KillEnemy then
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

function ESPS(state)
    getgenv().Toggle = state
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

Tabs.Main:Toggle({
    Title = "Infinite Ammo",
    Default = false,
    Callback = InfiniteAmmo
})

Tabs.Main:Button({
    Title = "Kill Enemy",
    Default = false,
    Callback = KillEnemy
})

Tabs.Main:Toggle({
    Title = "ESP 1",
    Default = false,
    Callback = ESP
})

Tabs.Main:Toggle({
    Title = "ESP 2",
    Default = false,
    Callback = ESPS
})

Tabs.Teleport:Button({
    Title = "Japan Lobby",
    Desc = "Japan Spawn Point",
    Callback = function()
    WindUI:Notify({
            Title = "Notification",
            Content = "Teleported to Japan Lobby.",
            Icon = "bell",
            Duration = 5,
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-4.103087425231934, -295.5, -36.644065856933594)
    end
})

Tabs.Teleport:Button({
    Title = "America Lobby",
    Desc = "America Spawn Point",
    Callback = function()
    WindUI:Notify({
            Title = "Notification",
            Content = "Teleported to America Lobby.",
            Icon = "bell",
            Duration = 5,
        })
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(15.000070571899414, -295.5, 46.504608154296875)
    end
})

Tabs.Teleport:Button({
    Title = "Island A",
    Desc = "Teleport To A",
    Callback = function()
    WindUI:Notify({
            Title = "Notification",
            Content = "Teleported to A.",
            Icon = "bell",
            Duration = 5,
        })
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
    end
})

Tabs.Teleport:Button({
    Title = "Island B",
    Desc = "Teleport To B",
    Callback = function()
    WindUI:Notify({
            Title = "Notification",
            Content = "Teleported to B.",
            Icon = "bell",
            Duration = 5,
        })
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
    end
})

Tabs.Teleport:Button({
    Title = "Island C",
    Desc = "Teleport To C",
    Callback = function()
    WindUI:Notify({
            Title = "Notification",
            Content = "Teleported To C.",
            Icon = "bell",
            Duration = 5,
        })
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
    end
})

Tabs.Teleport:Button({
    Title = "America Harbour",
    Desc = "Teleport To America",
    Callback = function()
       WindUI:Notify({
    Title = "Notification",
    Content = "Teleported To America",
    Icon = "bell",
    Duration = 5,})
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-50.992095947265625, 23.0000057220459, 8129.59423828125)
    end
})

Tabs.Teleport:Button({
    Title = "Japan Harbour",
    Desc = "Teleport To Japan",
    Callback = function()
        WindUI:Notify({
        Title = "Notification",
        Content = "Teleported To Japan",
        Icon = "bell",
        Duration = 5,})
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-150.50711059570312, 23.0000057220459, -8160.171875)
    end
})

             --[[ PLAYER TAB ]]--
---------------->>>>>>>>>>>><<<<<<<<<<<<<<-----------------


Tabs.Player:Button({
    Title = "GodMode",
    Desc = "Gives you godmode (use in lobby)",
    Callback = function()
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
    end
})

Tabs.Player:Button({
    Title = "Respawn",
    Desc = "Respawn Back Where Died",
    Locked = true,
})

Tabs.Player:Button({
    Title = "Reset",
    Desc = "Refresh your character",
    Locked = true,
})

Tabs.Player:Button({
    Title = "Inf Jump",
    Desc = "Gives you Infinity Jump",
    Locked = true,
})

Tabs.Player:Button({
    Title = "WalkSpeed",
    Desc = "Gives you 50% WalkSpeed",
    Locked = true,
})

Tabs.Player:Button({
    Title = "Jump Power",
    Desc = "Gives you 50% Jump Power",
    Locked = true,
})

Tabs.Credits:Button({
    Title = "Made By itzC9",
    Desc = "Discord: ug32#0000",
    Locked = true,
})


WindUI:Notify({
    Title = "Notification",
    Content = "Velonix Hub Loaded!",
    Icon = "bell",
    Duration = 5,
})

-- Configuration


local HttpService = game:GetService("HttpService")

local folderPath = "Velonix"
makefolder(folderPath)

local function SaveFile(fileName, data)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    local jsonData = HttpService:JSONEncode(data)
    writefile(filePath, jsonData)
end

local function LoadFile(fileName)
    local filePath = folderPath .. "/" .. fileName .. ".json"
    if isfile(filePath) then
        local jsonData = readfile(filePath)
        return HttpService:JSONDecode(jsonData)
    end
end

local function ListFiles()
    local files = {}
    for _, file in ipairs(listfiles(folderPath)) do
        local fileName = file:match("([^/]+)%.json$")
        if fileName then
            table.insert(files, fileName)
        end
    end
    return files
end

Tabs.WindowTab:Section({ Title = "Window" })

local themeValues = {}
for name, _ in pairs(WindUI:GetThemes()) do
    table.insert(themeValues, name)
end

local themeDropdown = Tabs.WindowTab:Dropdown({
    Title = "Select Theme",
    Multi = false,
    AllowNone = false,
    Value = nil,
    Values = themeValues,
    Callback = function(theme)
        WindUI:SetTheme(theme)
    end
})
themeDropdown:Select(WindUI:GetCurrentTheme())

local ToggleTransparency = Tabs.WindowTab:Toggle({
    Title = "Toggle Window Transparency",
    Callback = function(e)
        Window:ToggleTransparency(e)
    end,
    Value = WindUI:GetTransparency()
})

Tabs.WindowTab:Section({ Title = "Save" })

local fileNameInput = ""
Tabs.WindowTab:Input({
    Title = "Write File Name",
    PlaceholderText = "Enter file name",
    Callback = function(text)
        fileNameInput = text
    end
})

Tabs.WindowTab:Button({
    Title = "Save File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.WindowTab:Section({ Title = "Load" })

local filesDropdown
local files = ListFiles()

filesDropdown = Tabs.WindowTab:Dropdown({
    Title = "Select File",
    Multi = false,
    AllowNone = true,
    Values = files,
    Callback = function(selectedFile)
        fileNameInput = selectedFile
    end
})

Tabs.WindowTab:Button({
    Title = "Load File",
    Callback = function()
        if fileNameInput ~= "" then
            local data = LoadFile(fileNameInput)
            if data then
                WindUI:Notify({
                    Title = "File Loaded",
                    Content = "Loaded data: " .. HttpService:JSONEncode(data),
                    Duration = 5,
                })
                if data.Transparent then 
                    Window:ToggleTransparency(data.Transparent)
                    ToggleTransparency:SetValue(data.Transparent)
                end
                if data.Theme then WindUI:SetTheme(data.Theme) end
            end
        end
    end
})

Tabs.WindowTab:Button({
    Title = "Overwrite File",
    Callback = function()
        if fileNameInput ~= "" then
            SaveFile(fileNameInput, { Transparent = WindUI:GetTransparency(), Theme = WindUI:GetCurrentTheme() })
        end
    end
})

Tabs.WindowTab:Button({
    Title = "Refresh List",
    Callback = function()
        filesDropdown:Refresh(ListFiles())
    end
})

local currentThemeName = WindUI:GetCurrentTheme()
local themes = WindUI:GetThemes()

local ThemeAccent = themes[currentThemeName].Accent
local ThemeOutline = themes[currentThemeName].Outline
local ThemeText = themes[currentThemeName].Text
local ThemePlaceholderText = themes[currentThemeName].PlaceholderText

function updateTheme()
    WindUI:AddTheme({
        Name = currentThemeName,
        Accent = ThemeAccent,
        Outline = ThemeOutline,
        Text = ThemeText,
        PlaceholderText = ThemePlaceholderText
    })
    WindUI:SetTheme(currentThemeName)
end

local CreateInput = Tabs.ThemeTab:Input({
    Title = "Theme Name",
    Value = currentThemeName,
    Callback = function(name)
        currentThemeName = name
    end
})

Tabs.ThemeTab:Colorpicker({
    Title = "Background Color",
    Default = Color3.fromHex(ThemeAccent),
    Callback = function(color)
        ThemeAccent = color:ToHex()
    end
})

Tabs.ThemeTab:Colorpicker({
    Title = "Outline Color",
    Default = Color3.fromHex(ThemeOutline),
    Callback = function(color)
        ThemeOutline = color:ToHex()
    end
})

Tabs.ThemeTab:Colorpicker({
    Title = "Text Color",
    Default = Color3.fromHex(ThemeText),
    Callback = function(color)
        ThemeText = color:ToHex()
    end
})

Tabs.ThemeTab:Colorpicker({
    Title = "Placeholder Text Color",
    Default = Color3.fromHex(ThemePlaceholderText),
    Callback = function(color)
        ThemePlaceholderText = color:ToHex()
    end
})

Tabs.ThemeTab:Button({
    Title = "Update Theme",
    Callback = function()
        updateTheme()
    end
})