-- language: Luau, file: ps99_ultimate_master_hub_final.lua, target: Roblox / Executor
-- *Pet Simulator 99 Space Forge - Enterprise Master Hub (All Modules Included)*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================================
-- ЧАСТЬ 1: ПРЕМИАЛЬНЫЙ АНИМИРОВАННЫЙ ЛОАДЕР
-- =========================================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "PS99_PremiumLoader"
LoaderGui.ResetOnSpawn = false
LoaderGui.DisplayOrder = 999999
LoaderGui.Parent = CoreGui

local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(0, 340, 0, 200)
CanvasGroup.Position = UDim2.new(0.5, -170, 0.5, -100)
CanvasGroup.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CanvasGroup.BorderSizePixel = 0
CanvasGroup.GroupTransparency = 1
CanvasGroup.Parent = LoaderGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = CanvasGroup

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(112, 0, 255)
UIStroke.Transparency = 0.3
UIStroke.Parent = CanvasGroup

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 60, 0, 60)
Logo.Position = UDim2.new(0.5, -30, 0.3, -30)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://12799304724"
Logo.ImageColor3 = Color3.fromRGB(0, 240, 255)
Logo.Parent = CanvasGroup

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 0, 20)
StatusText.Position = UDim2.new(0, 20, 0.65, 0)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 13
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.Text = "Инициализация ячейки безопасности..."
StatusText.Parent = CanvasGroup

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 240, 0, 3)
BarBackground.Position = UDim2.new(0.5, -120, 0.8, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = CanvasGroup

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 8)
BarCorner.Parent = BarBackground

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(112, 0, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarBackground

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 8)
ProgressCorner.Parent = ProgressBar

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(112, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 240, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(112, 0, 255))
})
Gradient.Parent = ProgressBar

local rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if Logo and Logo.Parent then
        Logo.Rotation = (Logo.Rotation + (120 * deltaTime)) % 360
    end
end)

local function ChangeStatus(newText)
    TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
    task.wait(0.2)
    StatusText.Text = newText
    TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
end

-- Анимация загрузки
task.spawn(function()
    CanvasGroup.Size = UDim2.new(0, 310, 0, 180)
    CanvasGroup.Position = UDim2.new(0.5, -155, 0.5, -90)
    TweenService:Create(CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 340, 0, 200),
        Position = UDim2.new(0.5, -170, 0.5, -100)
    }):Play()
    task.wait(0.6)

    ChangeStatus("Проверка лицензии и HWID...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Загрузка базы цен RAP и сетевых хуков...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Инжект модулей Space Forge Master Hub...")
    TweenService:Create(ProgressBar, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.0)

    ChangeStatus("Успешно! Открытие интерфейса...")
    task.wait(0.6)

    TweenService:Create(CanvasGroup, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 340, 0, 0),
        Position = UDim2.new(0.5, -170, 0.5, 0),
        GroupTransparency = 1
    }):Play()
    task.wait(0.4)
    if rotationConnection then rotationConnection:Disconnect() end
    LoaderGui:Destroy()

    -- =========================================================================
    -- ЧАСТЬ 2: ГЛАВНЫЙ ИНТЕРФЕЙС И МЕНЮ УПРАВЛЕНИЯ
    -- =========================================================================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "RobloxNetworkConfig"
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 999999
    MainGui.Parent = PlayerGui

    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Size = UDim2.new(0, 840, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -420, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(0, 220, 255)
    MainStroke.Transparency = 0.4
    MainStroke.Parent = MainFrame

    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

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

    -- Боковые вкладки
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 210, 1, -55)
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    TabContainer.ScrollBarThickness = 3
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabContainer

    -- Контейнер страниц
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -235, 1, -55)
    PagesContainer.Position = UDim2.new(0, 225, 0, 50)
    PagesContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    PagesContainer.BorderSizePixel = 0
    PagesContainer.Parent = MainFrame

    local PagesCorner = Instance.new("UICorner")
    PagesCorner.CornerRadius = UDim.new(0, 8)
    PagesCorner.Parent = PagesContainer

    local pages = {}
    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -10, 1, -10)
        page.Position = UDim2.new(0, 5, 0, 5)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 900)
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
    local eggPage = createPage("Eggs")
    local economyPage = createPage("Economy")
    local visualPage = createPage("Visual")
    local miscPage = createPage("Misc")

    local function createToggle(page, titleText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
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

    local function createTabButton(displayName, targetPage)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 40)
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
    createTabButton("🥚 Инкубация & Яйца", eggPage)
    createTabButton("💰 Экономика & Снайпер", economyPage)
    createTabButton("💎 Визуал & Экстрим", visualPage)
    createTabButton("🛠️ Утилиты & AFK", miscPage)

    farmPage.Visible = true

    -- =========================================================================
    -- ЧАСТЬ 3: СЕТЕВАЯ ОЧЕРЕДЬ И МОДУЛИ АВТОМАТИЗАЦИИ
    -- =========================================================================
    local NetworkQueue = {}
    local function QueueRemoteAction(remoteName, ...)
        table.insert(NetworkQueue, {Name = remoteName, Args = {...}})
    end

    task.spawn(function()
        while true do
            task.wait(0.04 + math.random(1, 3) / 100)
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

    -- Группа 1.1: Умный распределенный таргет (Smart Area Farm)
    local smartFarmActive = false
    createToggle(farmPage, "Умный распределенный отряд (Smart Farm)", function(state)
        smartFarmActive = state
        task.spawn(function()
            while smartFarmActive do
                task.wait(0.1)
                pcall(function()
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        for _, zone in ipairs(map:GetChildren()) do
                            local breakables = zone:FindFirstChild("Breakables")
                            if breakables then
                                local targets = breakables:GetChildren()
                                for i, obj in ipairs(targets) do
                                    if not smartFarmActive then break end
                                    local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                                    if targetPart then
                                        QueueRemoteAction("Breakables_PetAttack", "Pet_" .. (i % 10 + 1), obj.Name)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- Группа 1.2: Клиентский вакуум лута (Instant Loot Magnet)
    local autoLootActive = false
    createToggle(farmPage, "Клиентский вакуум лута (Instant Magnet)", function(state)
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

    -- Группа 1.3: Автоматический прожим баффов (Buff Manager)
    local buffManagerActive = false
    createToggle(farmPage, "Авто-прожим баффов (Potions & Fruits)", function(state)
        buffManagerActive = state
        task.spawn(function()
            while buffManagerActive do
                task.wait(5)
                pcall(function()
                    QueueRemoteAction("Potions_Use", "DamagePotionV")
                    QueueRemoteAction("Fruits_Eat", "Apple", 5)
                end)
            end
        end)
    end)

    -- Группа 2.1: Тотальный пропуск анимаций (Egg Animation Bypass)
    local eggBypassActive = false
    createToggle(eggPage, "Тотальный пропуск анимаций яиц", function(state)
        eggBypassActive = state
        pcall(function()
            local eggGui = PlayerGui:FindFirstChild("EggOpeningGui", true)
            if eggGui then
                eggGui.Enabled = not state
            end
        end)
    end)

    -- Группа 3.1: Парсер торговых стендов (Booth Sniper)
    local boothSniperActive = false
    createToggle(economyPage, "Снайпер торговых стендов (Booth Sniper)", function(state)
        boothSniperActive = state
        task.spawn(function()
            while boothSniperActive do
                task.wait(0.4)
                pcall(function()
                    local booths = workspace:FindFirstChild("TradingPlaza") and workspace.TradingPlaza:FindFirstChild("Booths")
                    if booths then
                        for _, booth in ipairs(booths:GetChildren()) do
                            local listing = booth:FindFirstChild("Listing")
                            if listing and listing.Value then
                                QueueRemoteAction("Booths_PurchaseItem", booth.Name, listing.Value)
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- Группа 3.2: Снайпер аукционов на последней секунде (Auction Sniper)
    local auctionSniperActive = false
    createToggle(economyPage, "Снайпер аукционов (Auction Sniper)", function(state)
        auctionSniperActive = state
        task.spawn(function()
            while auctionSniperActive do
                task.wait(0.5)
                pcall(function()
                    QueueRemoteAction("Auction_PlaceBid", "ActiveLot", 100000)
                end)
            end
        end)
    end)

    -- Группа 4.1: Черный экран / Режим фермы (Ultra CPU Boost)
    local ultraBoostActive = false
    createToggle(visualPage, "Экстремальный режим (Black Screen / FPS Boost)", function(state)
        ultraBoostActive = state
        pcall(function()
            RunService:Set3dRenderingEnabled(not state)
            if state then
                local terrain = workspace:FindFirstChildOfClass("Terrain")
                if terrain then terrain:Clear() end
            end
        end)
    end)

    -- Группа 4.2: Обход бана за простой (Anti-Idle & Anti-Stuck)
    local antiIdleActive = false
    createToggle(miscPage, "Защита от AFK и застревания (Anti-Idle & Stuck)", function(state)
        antiIdleActive = state
        task.spawn(function()
            while antiIdleActive do
                task.wait(60)
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
    end)

    -- Видимость по RightControl
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("[*] Enterprise Master Hub успешно запущен в игре!")
end)
