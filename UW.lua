loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

createWindow("Velonix Hub - UW", 28)
createLogo(121332021347640)

-- Function 
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ENABLE_AutoShoot = false
local ENABLE_AutoDig = false
local ENABLE_Hitbox = false

function AutoShoot()
	if not ENABLE_AutoShoot then 
		warn("🚫 AutoShoot is disabled.") 
		return 
	end

	local Remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Remote"):WaitForChild("ShotTarget")
	local myTeam = Player.Team
	local weaponName = "Sniper"

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Player
			and player.Team ~= myTeam
			and player.Character
			and player.Character:FindFirstChild("HumanoidRootPart")
			and player.Character:FindFirstChild("Humanoid")
			and player.Character.Humanoid.Health > 0 then

			local position = player.Character.HumanoidRootPart.Position
			Remote:FireServer(position, weaponName)
			wait(0.1)
		end
	end
end

function AutoDig()
	if not ENABLE_AutoDig then 
		warn("🚫 AutoDig is disabled.") 
		return 
	end

	while ENABLE_AutoDig do
		local args = { -1 }
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("Remote"):WaitForChild("Dig"):FireServer(unpack(args))
		wait(0.5)
	end
end

function Hitbox()
	if not ENABLE_Hitbox then 
		warn("🚫 Hitbox is disabled.") 
		return 
	end

	while ENABLE_Hitbox do
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= Player
				and player.Character
				and player.Character:FindFirstChild("HumanoidRootPart")
				and player.Character:FindFirstChild("Humanoid") then

				local Hit = player.Character.HumanoidRootPart
				if Hit then
					Hit.Size = Vector3.new(90, 90, 90)
					Hit.Transparency = 0.6
				end
			end
		end
		wait(0.5)
	end
end

-- 🟢 START THREADS (ASYNC)
task.spawn(AutoDig)
task.spawn(Hitbox)
task.spawn(function()
	while wait(2) do AutoShoot() end
end)

createTab("Home", 1)
createLabel("Credits: Made By itzC9" 1)
createButton("Bypass Anti-Cheat [Beta]", 1, function()
    print("coming soon!")
end)
createToggle("AutoShoot Enemy", 1, false, function(s)
    if AutoShoot then
        ENABLE_AutoShoot = true
    else
        ENABLE_AutoShoot = false
    end
end)
createDivider(1)
createToggle("Auto Dig", 1, false, function(s)
    if AutoDig then
        ENABLE_AutoDig = true
    else
        ENABLE_AutoDig = false
    end
end)
createDivider(1)
createToggle("Hitbox", 1, false, function(s)
    if AutoDig then
        ENABLE_Hitbox = true
    else
        ENABLE_Hitbox = false
    end
end)

-- Settings
createSettingButton("Rejoin", function()
    print("Setting Button clicked!") 
end)

createNotify("UndergroundWar Hub:", "Velonix Hub Loaded Successfully!")