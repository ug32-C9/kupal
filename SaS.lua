loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

-- UI Initialization
createWindow("Velonix Hub", 28)
createLogo(12345678)

-- // Home Tab
createTab("Home", 1)
createLabel("Credits: Developer: itzC9", 1)

-- Weapon Add Buttons
local weapons = {
    { name = "Mystic", weapon = "Mystic Reaper" },
    { name = "Blood Axe", weapon = "Bloodvine Axe" },
    { name = "Ice Blade", weapon = "Ice Blade" }
}

for _, data in ipairs(weapons) do
    createButton(data.name, 1, function()
        local event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("AddWeaponToBase")
        event:FireServer(data.weapon)
    end)
end

-- // Settings Actions
createSettingButton("Rejoin", function()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
    if not success then
        createNotify("[Rejoin Failed] " .. tostring(err))
    end
end)
createSettingButton("Small-Server", function()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")

    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    for _, server in ipairs(servers) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
            break
        end
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

    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
        end
    end
end)

createSettingButton("No Effects", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        end
    end

    if workspace:FindFirstChildOfClass("Terrain") then
        local terrain = workspace.Terrain
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0
    end
end)

createNotify("Steal a Sword:", "Velonix Hub Loaded Successfully!")