-- Silent Command Control v2.6 - GLOBAL NOTIFY READY
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end

local WHITELIST = {
    C9_1234 = true,
    mommytoldimagoodboy = true
}

local REMOTE_NAME = "SilentCommand_Event_C9"
local Remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not Remote or not Remote:IsA("RemoteEvent") then
    Remote = Instance.new("RemoteEvent", ReplicatedStorage)
    Remote.Name = REMOTE_NAME
end

local clientList = {[LocalPlayer.Name] = true}

local function findUser(name)
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name then return p end
    end
end

local function getRandomClient()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if clientList[p.Name] then table.insert(t, p) end
    end
    return #t > 0 and t[math.random(1, #t)] or nil
end

local espRunning = false

Remote.OnClientEvent:Connect(function(sender, cmd, payload)
    if sender == LocalPlayer then return end
    if not WHITELIST[sender.Name] then return end
    if not clientList[LocalPlayer.Name] then return end

    local char = Character()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    cmd = cmd:lower()

    if cmd == "kick" then
        LocalPlayer:Kick("Kicked by admin.")

    elseif cmd == "fling" and hrp then
        hrp.Velocity = Vector3.new(1e4, 1e4, 1e4)

    elseif cmd == "kill" and hum then
        hum.Health = 0

    elseif cmd == "freeze" and hrp then
        hrp.Anchored = true

    elseif cmd == "spin" and hrp then
        if not espRunning then
            espRunning = true
            task.spawn(function()
                while espRunning and hrp and hrp.Parent do
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
                    task.wait()
                end
            end)
        end

    elseif cmd == "explode" and hrp then
        local e = Instance.new("Explosion", workspace)
        e.Position = hrp.Position
        e.BlastRadius = 10
        e.BlastPressure = 1e4

    elseif cmd == "nuke" and hrp then
        local e = Instance.new("Explosion", workspace)
        e.Position = hrp.Position
        e.BlastRadius = 30
        e.BlastPressure = 1e5
        e.ExplosionType = Enum.ExplosionType.Craters
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://138186576"
        s:Play()

    elseif cmd == "notify" and typeof(payload) == "string" then
        StarterGui:SetCore("SendNotification", {
            Title = "Velonix Alert",
            Text = payload,
            Duration = 5
        })
    end
end)

LocalPlayer.Chatted:Connect(function(msg)
    if not WHITELIST[LocalPlayer.Name] then return end

    local parts = msg:split(" ")
    local raw = parts[1]
    if not raw:lower():match("^%?") then return end

    local cmd = raw:sub(2):lower()
    local arg = parts[2]

    if cmd == "notify" then
        local message = table.concat(parts, " ", 2)

        -- Local game broadcast
        for _, p in ipairs(Players:GetPlayers()) do
            if clientList[p.Name] then
                Remote:FireClient(p, LocalPlayer, "notify", message)
            end
        end

        -- Global cross-server notify
        if _G.SendGlobalNotify then
            _G.SendGlobalNotify(message)
        end

    elseif cmd == "jpg" then
        local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
        gui.Name = "ClientListGUI"
        local f = Instance.new("Frame", gui)
        f.Size = UDim2.new(0, 300, 0, 400)
        f.Position = UDim2.new(0.5, -150, 0.5, -200)
        f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", f)
        Instance.new("UIListLayout", f)
        for _, p in ipairs(Players:GetPlayers()) do
            if clientList[p.Name] then
                local l = Instance.new("TextLabel", f)
                l.Size = UDim2.new(1, -10, 0, 20)
                l.Text = p.Name
                l.TextColor3 = Color3.new(1, 1, 1)
                l.BackgroundTransparency = 1
            end
        end
        task.delay(10, function()
            gui:Destroy()
        end)

    elseif cmd == "jp" and arg then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)

    else
        local targets = {}
        if arg == "." then
            for _, p in ipairs(Players:GetPlayers()) do
                if clientList[p.Name] then table.insert(targets, p) end
            end
        elseif arg == "r" then
            local r = getRandomClient()
            if r then table.insert(targets, r) end
        elseif arg:sub(1, 5) == "user/" then
            local u = arg:sub(6)
            local p = findUser(u)
            if p then table.insert(targets, p) end
        end

        for _, p in ipairs(targets) do
            Remote:FireClient(p, LocalPlayer, cmd, arg)
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        clientList[p.Name] = true
    end
end)