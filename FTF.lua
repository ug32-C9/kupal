loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PLACE_ID, CURRENT_JOB = game.PlaceId, game.JobId

local LocalPlayer = Players.LocalPlayer
local function isValidCharacter(char)
    return char and char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChild("HumanoidRootPart")
end

-- Fetch remote once
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent", 5)

-- Find nearest player
local function getNearestEnemy()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isValidCharacter(plr.Character) then
            local d = hrp.Position:Distance(plr.Character.HumanoidRootPart.Position)
            if d < dist then
                nearest, dist = plr, d
            end
        end
    end
    return nearest
end

-- Teleport & action helper
local function teleportAndFire(targetPos, actionName)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and remoteEvent then
        char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
        remoteEvent:FireServer("Input", actionName, true)
        task.wait(0.1)
    end
end

-- Kill nearest & freeze
local function KillAll()
    if not remoteEvent then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local startPos = hrp and hrp.Position
    local target = getNearestEnemy()
    if not (hrp and target) then return end

    -- Attack
    teleportAndFire(target.Character.HumanoidRootPart.Position, "Attack")

    -- Freeze Pod
    local nearestPod, bestDist = nil, math.huge
    for _, pod in ipairs(Workspace:GetDescendants()) do
        if pod.Name == "FreezePod" and pod:IsA("BasePart") then
            local occupied = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and isValidCharacter(plr.Character) then
                    if pod.Position:Distance(plr.Character.HumanoidRootPart.Position) < 5 then
                        occupied = true
                        break
                    end
                end
            end
            if not occupied then
                local d = hrp.Position:Distance(pod.Position)
                if d < bestDist then
                    nearestPod, bestDist = pod, d
                end
            end
        end
    end

    if nearestPod then
        teleportAndFire(nearestPod.Position, "Action")
    end

    if startPos then
        char.HumanoidRootPart.Position = startPos
    end
end

-- Windows
createWindow("Velonix Hub", 28)
createLogo(121332021347640)
createOpen(121332021347640)

-- Tabs
createTab("Home", 1)
createTab("Main", 2)
createTab("ESP", 3)
createTab("Tools", 4)


-- Buttons/Toggles/Labels
-- Home Tab
createLabel("Welcome, " .. LocalPlayer.Name .. "!", 1)

-- Main Tab
createButton("Kill All", 2, function()
    KillAll()
end)
createDivider(2)
local autoKillOn = false
createToggle("Auto Kill-All", 2, false, function(state)
    autoKillOn = state
    if state then
        task.spawn(function()
            while autoKillOn do
                KillAll()
                task.wait(0.5)
            end
        end)
    end
end)
-- ESP
local espConfigs = {
    { name = "Computers", className = "ComputerTable" },
    { name = "FreezePods", className = "FreezePod" },
    { name = "ExitDoors", className = "ExitDoor" }
}

for _, cfg in ipairs(espConfigs) do
    createToggle(cfg.name, 3, false, function(state)
    spawn(function()
                local highlights = {}
                while state do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == cfg.className and obj:IsA("BasePart") and not highlights[obj] then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = obj
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = obj
                            highlights[obj] = hl
                        end
                    end
                    task.wait(0.5)
                end
                for obj, hl in pairs(highlights) do
                    hl:Destroy()
                    highlights[obj] = nil
                end
            end)
end)
end
createDivider(3)
createToggle("ESP", 3, false, function(state)
    spawn(function()
            local highlights = {}
            while state do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and isValidCharacter(plr.Character) and not highlights[plr] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = plr.Character
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = plr.Character:FindFirstChild("Hammer") and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                        hl.OutlineColor = hl.FillColor
                        hl.Parent = plr.Character
                        highlights[plr] = hl
                    end
                end
                task.wait(0.3)
            end
            for plr, hl in pairs(highlights) do
                hl:Destroy()
                highlights[plr] = nil
            end
        end)
end)
-- TOOLS
createToggle("Anti-Fail", 4, false, function(state)
    spawn(function()
            while state do
                if remoteEvent then
                    remoteEvent:FireServer("SetPlayerMinigameResult", true)
                end
                task.wait(0.1)
            end
        end)
end)
-- Settings
createSettingButton("Rejoin", function()
    TeleportService:TeleportToPlaceInstance(PLACE_ID, CURRENT_JOB, LocalPlayer)
    if not success then
        createNotify("[Rejoin Failed] " .. tostring(err))
    end
end)
createSettingButton("Small-Server", function()
    local cursor, found = "", false
    repeat
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s", PLACE_ID, cursor ~= "" and "&cursor=" .. cursor or "")
        local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if ok and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= CURRENT_JOB then
                    found = true
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                    break
                end
            end
            cursor = result.nextPageCursor
        else
            break
        end
        task.wait(1)
    until found or not cursor
end)
createNotify("Flee The Facility:", "Velonix Hub Loaded Successfully!")