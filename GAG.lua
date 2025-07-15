--// === Services === --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

--// === Constants & Variables === --
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local PLACE_ID, CURRENT_JOB = game.PlaceId, game.JobId
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buySeedEvent = GameEvents:WaitForChild("BuySeedStock")
local plantSeedEvent = GameEvents:WaitForChild("Plant_RE")
local SELL_POSITION = Vector3.new(87, 3, 0)
local INTERVAL = 240 -- 4 min

--// === State === --
local is_auto_collecting = false
local is_auto_planting = false
local lastPosition = nil
local plant_position = nil
local selected_seed = "Carrot"
local profit_data = {}
local last_profit_check = 0

--// === Settings === --
local settings = {
    auto_buy_seeds = false,
    use_distance_check = false,
    collection_distance = 10,
    collect_nearest_fruit = false,
    auto_sell_inventory = false,
    auto_sell_equipped = false,
    debug_mode = false
}

--// === Anti-AFK === --
LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, "W", false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, "W", false, game)
end)

--// === Core Functions === --
function get_player_farm()
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

function equip_seed(seed)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and humanoid) then return false end

    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:GetAttribute("ITEM_TYPE") == "Seed" and item:GetAttribute("Seed") == seed then
            humanoid:EquipTool(item)
            task.wait()
            if char:FindFirstChildOfClass("Tool") then return true end
        end
    end

    return false
end

function buy_seed(seed)
    local btn = playerGui.Seed_Shop.Frame.ScrollingFrame:FindFirstChild(seed)
    if btn and btn.Main_Frame.Cost_Text.TextColor3 ~= Color3.fromRGB(255, 0, 0) then
        buySeedEvent:FireServer(seed)
    end
end

function auto_collect_fruits()
    while is_auto_collecting do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local farm = get_player_farm()
        local plants = farm and farm.Important and farm.Important.Plants_Physical

        if not (root and plants) then task.wait(1) continue end

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
        task.wait()
    end
end

function auto_plant_seeds(seed)
    while is_auto_planting do
        if not equip_seed(seed) and settings.auto_buy_seeds then
            buy_seed(seed)
            task.wait(0.2)
        end

        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool and plant_position then
            if tool:GetAttribute("Quantity") and tool:GetAttribute("Quantity") > 0 then
                plantSeedEvent:FireServer(plant_position, seed)
            end
        end
        task.wait(0.2)
    end
end

function calculate_profit()
    if os.time() - last_profit_check < 5 then return profit_data end
    last_profit_check = os.time()

    local char, root = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local farm = get_player_farm()
    if not (char and root and farm) then return profit_data end

    local plants = farm.Important:FindFirstChild("Plants_Physical")
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

function auto_farm_loop()
    while is_auto_collecting do
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then lastPosition = hrp.Position end

        buy_seed("Bamboo")
        task.spawn(function() equip_seed("Bamboo") end)
        task.wait(0.7)
        task.spawn(function() auto_plant_seeds("Bamboo") end)
        task.wait(0.7)
        task.spawn(auto_collect_fruits)

        task.wait(3)

        if hrp then
            hrp.CFrame = CFrame.new(SELL_POSITION)
            task.wait(1.5)
            GameEvents.Sell_Inventory:FireServer()
            task.wait(1.5)
            if lastPosition then
                hrp.CFrame = CFrame.new(lastPosition)
            end
        end

        task.wait(INTERVAL)
    end
end

local function tpSHOP()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    root.CFrame = CFrame.new(SELL_POSITION)
    return true
end

function auto_sell_items()
    while is_auto_selling do
        if settings.auto_sell_inventory then
            tpSHOP()
            task.wait(0.5)
            GameEvents.Sell_Inventory:FireServer()
            createNotify("Auto Sell", "Sold entire inventory")
        end
        if settings.auto_sell_equipped then
            tpSHOP()
            task.wait(0.5)
            GameEvents.Sell_Items:FireServer()
            createNotify("Auto Sell", "Sold equipped item")
        end
        
        task.wait(1) -- Delay between sell attempts
    end
end

--// === UI INIT === --
loadstring(game:HttpGet("https://raw.githubusercontent.com/ug32-C9/Velonix-UI-Library/refs/heads/main/Main3.lua"))()

createWindow("Velonix Hub - GaG", 28)
createLogo(121332021347640)

--// Home Tab
createTab("Home", 1)
createLabel("Made By Velonix Team", 1)
createDivider(1)

createToggle("Auto Collect", 1, false, function(s)
    is_auto_collecting = s
    if s then task.spawn(auto_collect_fruits) end
end)

createDivider(1)
createToggle("Auto Farm", 1, false, function(s)
    is_auto_collecting = s
    if s then
        createNotify("[AutoFarm]", "Enabled")
        task.spawn(auto_farm_loop)
    else
        createNotify("[AutoFarm]", "Disabled")
        lastPosition = nil
    end
end)
createDivider(1)
createToggle("Auto Sell Inventory", 1, false, function(s)
    settings.auto_sell_inventory = s
    if s and not is_auto_selling then
        is_auto_selling = true
        task.spawn(auto_sell_items)
    end
end)
createToggle("Auto Sell Equipped", 1, false, function(s)
    settings.auto_sell_equipped = s
    if s and not is_auto_selling then
        is_auto_selling = true
        task.spawn(auto_sell_items)
    end
end)
createDivider(1)
createTextBox(1, "Seed to Plant", function(t)
    selected_seed = t
end)

createDivider(1)
createToggle("Distance Check", 1, false, function(s) settings.use_distance_check = s end)
createDivider(1)
createToggle("Debug Mode", 1, false, function(s) settings.debug_mode = s end)

--// Player Tab
createTab("Player", 2)
local seeds = {"Carrot", "Strawberry", "Blueberry", "Rose", "Orange Tulip", "Stonebite", "Tomato", "Daffodil"}
for _, seed in ipairs(seeds) do
    createToggle("Auto-Buy " .. seed, 2, false, function(s)
        if s then
            buy_seed(seed)
        else
            createNotify("Auto-Buy:", seed .. " disabled.")
        end
    end)
end

--// Profit Tab
createTab("Profit", 3)
createButton("Calculate Profit", 3, function()
    local profit = calculate_profit()
    createNotify("Profit Calculator", string.format("Total Value: $%d\nPlants Ready: %d\nLast Updated: %s", profit.total_value, profit.plant_count, profit.last_updated))
end)
createLabel("Click to calculate current farm profit", 3)

--// Credits Tab
createTab("Credits", 4)
createLabel("-- itzC9", 4)
createLabel("-- GoodGamerYTbro", 4)
createLabel("-- Velonix Studio", 4)

--// Settings Tab
createSettingButton("Rejoin", function()
    TeleportService:TeleportToPlaceInstance(PLACE_ID, CURRENT_JOB, LocalPlayer)
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
    setclipboard("https://discord.gg/SXuNngnYPT")
    createNotify("Discord", "Copied Successfully!")
end)

createNotify("Grow a Garden:", "Velonix Hub Loaded Successfully!")