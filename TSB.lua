loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local PLACE_ID, CURRENT_JOB = game.PlaceId, game.JobId

-- Globals
local dashActive, comboActive, espRunning, autoBlockActive = false, false, false, false
local dashConnection, comboConnection, blockConnection
local espObjects, connections = {}, {}

-- Utility: Closest target (for combo)
local function getClosestTarget()
	local closest, shortest = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if dist < shortest then
				closest, shortest = player.Character.HumanoidRootPart, dist
			end
		end
	end
	return closest
end

-- ESP
local function createESP()
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

		-- Configs
		esp.box.Thickness = 1
		esp.box.Filled = false
		esp.box.Visible = false

		esp.line.Thickness = 1
		esp.line.Visible = false

		for _, text in ipairs({esp.text, esp.healthText}) do
			text.Size, text.Center, text.Outline, text.OutlineColor, text.Visible, text.Font = 16, true, true, Color3.new(), false, 2
		end

		esp.healthText.Size = 14
		espObjects[player] = esp
	end

	local function updateESP()
		for player, esp in pairs(espObjects) do
			local char, hrp, hum = player.Character, player.Character and player.Character:FindFirstChild("HumanoidRootPart"), player.Character and player.Character:FindFirstChildOfClass("Humanoid")
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
	table.insert(connections, RunService.RenderStepped:Connect(updateESP))
end

local function removeESP()
	if not espRunning then return end
	espRunning = false
	for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
	for _, esp in pairs(espObjects) do for _, obj in pairs(esp) do if obj.Remove then obj:Remove() end end end
	table.clear(connections)
	table.clear(espObjects)
end

-- Combat
local function AutoCombo()
	comboActive = true
	comboConnection = RunService.Heartbeat:Connect(function()
		local target = getClosestTarget()
		if target and (target.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 15 then
			mouse1press()
			wait(0.1)
			mouse1release()
		end
	end)
end

local function AutoComboOFF()
	comboActive = false
	if comboConnection then comboConnection:Disconnect() end
end

local function antideathON()
	dashActive = true
	dashConnection = RunService.Heartbeat:Connect(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum and hum.Health / hum.MaxHealth <= 0.2 then
			keypress(Enum.KeyCode.Q)
			wait(0.1)
			keyrelease(Enum.KeyCode.Q)
		end
	end)
end

local function antideathOFF()
	dashActive = false
	if dashConnection then dashConnection:Disconnect() end
end

local function AutoBlockOn()
	autoBlockActive = true
	blockConnection = RunService.Heartbeat:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
				local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if enemyHRP and myHRP and (enemyHRP.Position - myHRP.Position).Magnitude <= 12 then
					keypress(Enum.KeyCode.F)
					wait(0.2)
					keyrelease(Enum.KeyCode.F)
				end
			end
		end
	end)
end

local function AutoBlockOff()
	autoBlockActive = false
	if blockConnection then blockConnection:Disconnect() end
end

-- UI Integration
createWindow("Velonix-TSB", 28)
createLogo(121332021347640)

createTab("Home", 1)
createLabel("Credits: Founder: itzC9", 1)
createLabel("Scripter: GoodgamerYT", 1)

createTab("Player", 2)
createToggle("Auto-Combo", 2, false, function(s) if s then AutoCombo() else AutoComboOFF() end end)
createToggle("Auto Block", 2, false, function(s) if s then AutoBlockOn() else AutoBlockOff() end end)
createToggle("Anti-Death", 2, false, function(s) if s then antideathON() else antideathOFF() end end)

createTab("Visual", 3)
createToggle("ESP", 3, false, function(s) if s then createESP() else removeESP() end end)

-- Settings Buttons
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
    if not success then
        createNotify("[Small-Server Failed] " .. tostring(err))
    end
end)
createSettingButton("Anti-Lag", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then v.Enabled = false
		elseif v:IsA("MeshPart") then v.Material = Enum.Material.Plastic end
	end
end)

createSettingButton("Boost FPS", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").FogEnd = 100000
	game:GetService("Lighting").Brightness = 1
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0 end
	end
end)

createSettingButton("Low-Grahics", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	local lighting = game:GetService("Lighting")
	lighting.GlobalShadows = false lighting.FogStart = 0 lighting.FogEnd = 9e9 lighting.Brightness = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then obj.Enabled = false
		elseif obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
	end
	if workspace:FindFirstChildOfClass("Terrain") then
		local terrain = workspace.Terrain
		terrain.WaterWaveSize, terrain.WaterWaveSpeed, terrain.WaterReflectance, terrain.WaterTransparency = 0, 0, 0, 0
	end
end)

createNotify("The Strongest Battleground:", "Velonix Hub Loaded Successfully!")