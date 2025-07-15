loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PLACE_ID, CURRENT_JOB = game.PlaceId, game.JobId

-- States
local aimAssistActive = false
local aimConnection
local useCameraAim = true -- false = mouse lock, true = camera movement

-- FOV
local fovSize = 100
local fovEnabled = false
local fovCircle

-- Optional configs
local enableTeamCheck = false
local enableVisibleCheck = false

-- FOV Circle Rendering
local function fovON()
	if fovCircle then return end
	fovCircle = Drawing.new("Circle")
	fovCircle.Thickness = 2
	fovCircle.Radius = fovSize
	fovCircle.Filled = false
	fovCircle.Visible = true
	fovCircle.Color = Color3.fromRGB(255, 255, 255)

	RunService:BindToRenderStep("FOVFollow", Enum.RenderPriority.Camera.Value + 1, function()
		fovCircle.Position = UserInputService:GetMouseLocation()
	end)
end

local function fovOFF()
	if fovCircle then
		fovCircle:Remove()
		fovCircle = nil
	end
	RunService:UnbindFromRenderStep("FOVFollow")
end

-- Target Finder
local function getClosestTarget()
	local closest, minDist = nil, math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if enableTeamCheck and plr.Team == LocalPlayer.Team then continue end
			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local pos, visible = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
				if not enableVisibleCheck or visible then
					local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
					if dist < minDist and (not fovEnabled or dist <= fovSize) then
						minDist = dist
						closest = plr.Character.HumanoidRootPart
					end
				end
			end
		end
	end

	return closest
end

-- Aimbot Logic
local function AssistOn()
	if aimAssistActive then return end
	aimAssistActive = true

	aimConnection = RunService.RenderStepped:Connect(function()
		local target = getClosestTarget()
		if target then
			if useCameraAim then
				local direction = (target.Position - Camera.CFrame.Position).Unit
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
			else
				mousemoverel((UserInputService:GetMouseLocation().X - Camera:WorldToViewportPoint(target.Position).X) / 2, 0)
			end
		end
	end)
end

local function AssistOff()
	aimAssistActive = false
	if aimConnection then aimConnection:Disconnect() aimConnection = nil end
end

-- UI
createWindow("Velonix Hub - Universal", 28)
createLogo(121332021347640)

createTab("Player", 1)
createToggle("Aim Assist", 1, false, function(state)
	if state then AssistOn() else AssistOff() end
end)

createToggle("Camera Aim (Not Mouse Lock)", 1, true, function(state)
	useCameraAim = state
end)

createTab("FOV", 2)
createToggle("FOV Circle", 2, false, function(state)
	if state then fovON() else fovOFF() end
end)

createTextBox(2, "FOV Radius", function(input)
	local num = tonumber(input)
	if num then
		fovSize = num
		if fovCircle then fovCircle.Radius = fovSize end
	end
end)

-- Performance Settings
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
		if v:IsA("Texture") or v:IsA("Decal") then
			v.Transparency = 1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
			v.Enabled = false
		elseif v:IsA("MeshPart") then
			v.Material = Enum.Material.Plastic
		end
	end
end)

createSettingButton("Boost FPS", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	local lighting = game:GetService("Lighting")
	lighting.GlobalShadows = false
	lighting.FogEnd = 100000
	lighting.Brightness = 1
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end
	end
end)

createSettingButton("Low-Graphics", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	local lighting = game:GetService("Lighting")
	lighting.GlobalShadows = false
	lighting.FogStart = 0
	lighting.FogEnd = 9e9
	lighting.Brightness = 0

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
			obj.Enabled = false
		elseif obj:IsA("Texture") or obj:IsA("Decal") then
			obj:Destroy()
		end
	end

	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.WaterWaveSize = 0
		terrain.WaterWaveSpeed = 0
		terrain.WaterReflectance = 0
		terrain.WaterTransparency = 0
	end
end)

createNotify("Universal Hub:", "Velonix Hub Loaded Successfully!")