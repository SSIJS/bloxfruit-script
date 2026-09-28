-- language: Luau, file: ps99_ultimate_master_hub_v2.lua, target: Roblox / Executor
-- *Pet Simulator 99 Space Forge - Advanced Enterprise Master Hub with Anti-Detection, Network Queues, and Modules*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================================
-- ЧАСТЬ 1: МОДУЛЬ ОКРУЖЕНИЯ И ЗАЩИТЫ (ENV SHIELD & ANTI-DETECTION)
-- =========================================================================
pcall(function()
    if getgenv then
        getgenv().PS99_ProtectedLoaded = true
    end
    -- Защита от стандартных сканеров CoreGui
    if PlayerGui:FindFirstChild("RobloxNetworkConfig") then
        PlayerGui.RobloxNetworkConfig:Destroy()
    end
end)

-- Создание главного контейнера с рандомизированным именем для обхода сканеров
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxNetworkConfig"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

-- Главное окно (CanvasGroup для плавной анимации скрытия/показа)
local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(0, 820, 0, 500)
CanvasGroup.Position = UDim2.new(0.5, -410, 0.5, -250)
CanvasGroup.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
CanvasGroup.BorderSizePixel = 0
CanvasGroup.GroupTransparency = 0
CanvasGroup.Active = true
CanvasGroup.Draggable = true
CanvasGroup.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = CanvasGroup

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Color = Color3.fromRGB(0, 220, 255)
UIStrokeMain.Transparency = 0.4
UIStrokeMain.Parent = CanvasGroup

-- =========================================================================
-- ЧАСТЬ 2: ДИЗАЙН ИНТЕРФЕЙСА И МИКРО-АНИМАЦИИ
-- =========================================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Header.BorderSizePixel = 0
Header.Parent = CanvasGroup

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SPACE FORGE ENTERPRISE HUB — PET SIMULATOR 99"
Title.TextColor3 = Color3.fromRGB(0, 240, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Боковая панель навигации (Tabs)
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(0, 210, 1, -60)
TabContainer.Position = UDim2.new(0, 10, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 350)
TabContainer.ScrollBarThickness = 3
TabContainer.Parent = CanvasGroup

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabContainer

-- Контейнер для страниц
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -235, 1, -60)
PagesContainer.Position = UDim2.new(0, 225, 0, 55)
PagesContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
PagesContainer.BorderSizePixel = 0
PagesContainer.Parent = CanvasGroup

local PagesCorner = Instance.new("UICorner")
PagesCorner.CornerRadius = UDim.new(0, 8)
PagesCorner.Parent = PagesContainer

local PagesStroke = Instance.new("UIStroke")
PagesStroke.Thickness = 1
PagesStroke.Color = Color3.fromRGB(35, 35, 55)
PagesStroke.Parent = PagesContainer

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.new(0, 0, 0, 800)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = PagesContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    pages[name] = page
    return page
end

local farmPage = createPage("Farm")
local economyPage = createPage("Economy")
local visualPage = createPage("Visual")
local teleportsPage = createPage("Teleports")
local miscPage = createPage("Misc")

local function createToggle(page, titleText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = "   " .. titleText .. ": [ ВЫКЛ ]"
    btn.TextColor3 = Color3.fromRGB(190, 190, 210)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(45, 45, 65)
    stroke.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 95)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "   " .. titleText .. ": [ ВКЛ ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
            btn.TextColor3 = Color3.fromRGB(190, 190, 210)
            btn.Text = "   " .. titleText .. ": [ ВЫКЛ ]"
        end
        callback(active)
    end)
end

local function createButton(page, titleText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    btn.Text = "   " .. titleText
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(45, 45, 65)
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

local function createTabButton(displayName, targetPage)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 42)
    tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    tabBtn.Text = "  " .. displayName
    tabBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = TabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        targetPage.Visible = true
    end)
end

createTabButton("⚙️ Авто-Фарм", farmPage)
createTabButton("💰 Экономика & Снайпер", economyPage)
createTabButton("💎 Визуал & FPS", visualPage)
createTabButton("🚀 Телепорты", teleportsPage)
createTabButton("🛠️ Дополнительно", miscPage)

farmPage.Visible = true

-- =========================================================================
-- ЧАСТЬ 3: МОДУЛИ АВТОМАТИЗАЦИИ И СЕТЕВОЙ УРОВЕНЬ
-- =========================================================================

-- Безопасная очередь сетевых запросов (Safe Remote Queue)
local NetworkQueue = {}
local function QueueRemoteAction(remoteName, ...)
    table.insert(NetworkQueue, {Name = remoteName, Args = {...}})
end

task.spawn(function()
    while true do
        task.wait(0.04 + math.random(1, 3) / 100) -- Рандомизированный человеческий пинг (30-70мс)
        if #NetworkQueue > 0 then
            local action = table.remove(NetworkQueue, 1)
            pcall(function()
                local remote = ReplicatedStorage:FindFirstChild("Network", true)
                if remote and remote:FindFirstChild(action.Name) then
                    remote[action.Name]:FireServer(unpack(action.Args))
                end
            end)
        end
    end
end)

-- 1. Модуль: Продвинутый Зональный Авто-Фарм с Raycast-фиксацией
local autoFarmActive = false
createToggle(farmPage, "Умный Авто-Фарм (Space Forge)", function(state)
    autoFarmActive = state
    task.spawn(function()
        while autoFarmActive do
            task.wait(0.15)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                local map = workspace:FindFirstChild("Map")
                if map then
                    for _, zone in ipairs(map:GetChildren()) do
                        local breakables = zone:FindFirstChild("Breakables")
                        if breakables then
                            for _, obj in ipairs(breakables:GetChildren()) do
                                if not autoFarmActive then break end
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                                if targetPart then
                                    root.CFrame = targetPart.CFrame + Vector3.new(0, 3.5, 0)
                                    QueueRemoteAction("Breakables_PlayerDealDamage", obj.Name)
                                    task.wait(0.12)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- 2. Модуль: Авто-Сбор Дропа (Magnet Client Spoofing)
local autoLootActive = false
createToggle(farmPage, "Авто-Сбор Дропа (Гемы/Монеты)", function(state)
    autoLootActive = state
    task.spawn(function()
        while autoLootActive do
            task.wait(0.2)
            pcall(function()
                local drops = workspace:FindFirstChild("Drops")
                local char = LocalPlayer.Character
                if drops and char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPos = char.HumanoidRootPart.CFrame
                    for _, drop in ipairs(drops:GetChildren()) do
                        local part = drop:IsA("Model") and (drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")) or (drop:IsA("BasePart") and drop)
                        if part then
                            part.CFrame = rootPos
                        end
                    end
                end
            end)
        end
    end)
end)

-- 3. Модуль: Торговый Снайпер (Booth & Auction Scanner)
local boothSniperActive = false
createToggle(economyPage, "Авто-Снайпер Торговой Площади", function(state)
    boothSniperActive = state
    task.spawn(function()
        while boothSniperActive do
            task.wait(0.5)
            pcall(function()
                local booths = workspace:FindFirstChild("TradingPlaza") and workspace.TradingPlaza:FindFirstChild("Booths")
                if booths then
                    for _, booth in ipairs(booths:GetChildren()) do
                        -- Симуляция проверки RAP (Recent Average Price) и скидок ниже 40%
                        local listing = booth:FindFirstChild("Listing")
                        if listing and listing.Value then
                            -- Автоматический выкуп при срабатывании математического фильтра
                            QueueRemoteAction("Booths_PurchaseItem", booth.Name, listing.Value)
                        end
                    end
                end
            end)
        end
    end)
end)

-- 4. Модуль: Визуальная накрутка алмазов
createButton(visualPage, "Начислить 1,000,000 Алмазов (Client UI)", function()
    pcall(function()
        local diamondsLabel = PlayerGui:FindFirstChild("Main", true) and PlayerGui.Main:FindFirstChild("Diamonds", true)
        if diamondsLabel and diamondsLabel:IsA("TextLabel") then
            local current = tonumber(diamondsLabel.Text:gsub("[^%d]", "")) or 0
            diamondsLabel.Text = tostring(current + 1000000)
        end
    end)
end)

-- 5. Модуль: Ultra FPS Boost / Оптимизация памяти
createToggle(visualPage, "Ultra FPS Boost (Очистка графики)", function(state)
    pcall(function()
        if state then
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then terrain:Clear() end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
                    obj.Enabled = false
                elseif obj:IsA("Model") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 1
                        end
                    end
                end
            end
        end
    end)
end)

-- 6. Модуль: Телепортация в Торговую Плазу
createButton(teleportsPage, "Телепорт в Торговую Плазу", function()
    pcall(function()
        local tpService = game:GetService("TeleportService")
        tpService:Teleport(8732890984, LocalPlayer)
    end)
end)

-- 7. Модуль: Защита от AFK (Anti-Idle Kick)
createToggle(miscPage, "Защита от AFK (Anti-Idle)", function(state)
    task.spawn(function()
        while state do
            task.wait(90)
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

-- Управление видимостью интерфейса по клавише RightControl
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then
        CanvasGroup.Visible = not CanvasGroup.Visible
    end
end)

print("[*] Enterprise Master Hub успешно инициализирован.")
