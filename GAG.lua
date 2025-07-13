loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Constants
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local PLACE_ID, CURRENT_JOB = game.PlaceId, game.JobId

-- Game Events
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buySeedEvent = GameEvents:WaitForChild("BuySeedStock")
local plantSeedEvent = GameEvents:WaitForChild("Plant_RE")

-- Settings
local settings = {
    auto_buy_seeds = false,
    use_distance_check = false,
    collection_distance = 10,
    collect_nearest_fruit = false,
    debug_mode = false
}

-- State Variables
local plant_position = nil
local is_auto_planting = false
local is_auto_collecting = false
local profit_data = {}
local last_profit_check = 0

-- Anti-AFK
local function antiAfk()
    return LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
    end)
end
antiAfk()

local function get_player_farm()
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

local function calculate_profit()
    if os.time() - last_profit_check < 5 then return profit_data end
    last_profit_check = os.time()

    local character, root = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local farm = get_player_farm()
    if not (character and root and farm) then return profit_data end

    local plants = farm.Important:FindFirstChild("Plants_Physical")
    if not plants then return profit_data end

    local total_value, plant_count = 0, 0

    for _, plant in ipairs(plants:GetChildren()) do
        for _, d in ipairs(plant:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local dist = (root.Position - d.Parent.Position).Magnitude
                if not settings.use_distance_check or dist <= settings.collection_distance then
                    total_value += d.Parent:GetAttribute("Value") or 0
                    plant_count += 1
                end
            end
        end
    end

    profit_data = {
        total_value = total_value,
        plant_count = plant_count,
        last_updated = os.date("%X")
    }
    return profit_data
end

local function buy_seed(seed)
    local btn = playerGui.Seed_Shop.Frame.ScrollingFrame:FindFirstChild(seed)
    if btn and btn.Main_Frame.Cost_Text.TextColor3 ~= Color3.fromRGB(255, 0, 0) then
        createNotify("Buy Seed", "Buying: " .. seed)
        buySeedEvent:FireServer(seed)
    end
end

local function equip_seed(seed)
    local char = LocalPlayer.Character
    if not char then return createNotify("Equip Error", "No Character") and false end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return createNotify("Equip Error", "No Humanoid") and false end

    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:GetAttribute("ITEM_TYPE") == "Seed" and item:GetAttribute("Seed") == seed then
            humanoid:EquipTool(item)
            task.wait()
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped and equipped:GetAttribute("Seed") == seed then return equipped end
        end
    end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and equipped:GetAttribute("Seed") == seed then return equipped end

    createNotify("Equip Error", "Seed not found: " .. seed)
    return false
end

function auto_collect_fruits()
    while is_auto_collecting do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local farm = get_player_farm()
        local plants = farm and farm.Important and farm.Important.Plants_Physical

        if not (root and plants) then
            createNotify("Collect Error", "Missing Character or Farm")
            task.wait(0.5)
            continue
        end

        if settings.collect_nearest_fruit then
            local closest, minDist = nil, math.huge
            for _, plant in ipairs(plants:GetChildren()) do
                for _, d in ipairs(plant:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        local dist = (root.Position - d.Parent.Position).Magnitude
                        if (not settings.use_distance_check or dist <= settings.collection_distance) and dist < minDist then
                            closest = d
                            minDist = dist
                        end
                    end
                end
            end
            if closest then fireproximityprompt(closest) end
        else
            for _, plant in ipairs(plants:GetChildren()) do
                for _, d in ipairs(plant:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Enabled then
                        local dist = (root.Position - d.Parent.Position).Magnitude
                        if not settings.use_distance_check or dist <= settings.collection_distance then
                            fireproximityprompt(d)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end

function auto_plant_seeds(seed)
    while is_auto_planting do
        local tool = equip_seed(seed)
        if not tool and settings.auto_buy_seeds then
            buy_seed(seed)
            task.wait(0.2)
            tool = equip_seed(seed)
        end

        if tool and plant_position then
            local quantity = tool:GetAttribute("Quantity")
            if quantity and quantity > 0 then
                plantSeedEvent:FireServer(plant_position, seed)
            end
        end
        task.wait(0.2)
    end
end

local farm = get_player_farm()
if farm and farm.Important and farm.Important.Plant_Locations then
    local pos = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
    plant_position = pos and pos.Position or Vector3.new(0, 0, 0)
else
    plant_position = Vector3.new(0, 0, 0)
end

createWindow("Velonix-GaG", 28)
createLogo(121332021347640)

-- Home Tab
createTab("Home", 1)
createLabel("Made By Velonix Team", 1)
createDivider(1)
createToggle("Auto Collect", 1, false, function(s)
    is_auto_collecting = s
    if s then task.spawn(auto_collect_fruits) end
end)
createDivider(1)
local selected_seed = "Carrot"
createTextBox(1, "Seed to Plant", function(t) selected_seed = t end)
createDivider(1)
createToggle("Distance Check", 1, false, function(s) settings.use_distance_check = s end)
createDivider(1)
createToggle("Debug Mode", 1, false, function(s) settings.debug_mode = s end)

-- Player Tab
createTab("Player", 2)
local seeds = {"Carrot", "Strawberry", "Blueberry", "Rose", "Orange Tulip", "Stonebite", "Tomato", "Daffodil"}
for _, seed in ipairs(seeds) do
    createToggle("Auto-Buy " .. seed, 2, false, function(s)
        if s then
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer(seed)
        else
            createNotify("Auto-Buy:", seed .. " disabled.")
        end
    end)
end

-- Profit Tab
createTab("Profit", 3)
createButton("Calculate Profit", 3, function()
    local profit = calculate_profit()
    createNotify("Profit Calculator", string.format("Total Value: $%d\nPlants Ready: %d\nLast Updated: %s", profit.total_value, profit.plant_count, profit.last_updated))
end)
createLabel("Click to calculate current farm profit", 3)

-- Credits Tab
createTab("Credits", 4)
createLabel("-- itzC9", 4)
createLabel("-- GoodGamerYT", 4)
createLabel("-- Velonix Studio", 4)

-- Settings
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
end)

createSettingButton("Discord", function()
    setclipboard("https://discord.gg/czwp9fWzkz")
end)

createNotify("Grow a Garden:", "Velonix Hub Loaded Successfully!")