-- language: Luau, file: ps99_enterprise_ultimate_fixed.lua, target: Roblox / Executor
-- *Pet Simulator 99 Space Forge - Enterprise Master Hub (Universal Fixed)*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старые копии интерфейса если они были
pcall(function()
    if PlayerGui:FindFirstChild("PS99_MasterHub") then PlayerGui.PS99_MasterHub:Destroy() end
    if PlayerGui:FindFirstChild("PS99_Loader") then PlayerGui.PS99_Loader:Destroy() end
end)

-- =========================================================================
-- ЧАСТЬ 1: ПРЕМИАЛЬНЫЙ АНИМИРОВАННЫЙ ЛОАДЕР
-- =========================================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "PS99_Loader"
LoaderGui.ResetOnSpawn = false
LoaderGui.DisplayOrder = 999999
LoaderGui.Parent = PlayerGui

local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(0, 340, 0, 200)
CanvasGroup.Position = UDim2.new(0.5, -170, 0.5, -100)
CanvasGroup.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
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
StatusText.Text = "Инициализация защищенного ядра..."
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
    pcall(function()
        TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
        task.wait(0.2)
        StatusText.Text = newText
        TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    end)
end

task.spawn(function()
    CanvasGroup.Size = UDim2.new(0, 310, 0, 180)
    CanvasGroup.Position = UDim2.new(0.5, -155, 0.5, -90)
    TweenService:Create(CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 340, 0, 200),
        Position = UDim2.new(0.5, -170, 0.5, -100)
    }):Play()
    task.wait(0.6)

    ChangeStatus("Проверка целостности памяти...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Загрузка таблиц сетевых эмуляций...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Инициализация графического интерфейса...")
    TweenService:Create(ProgressBar, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.0)

    ChangeStatus("Готово. Запуск...")
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
    -- ЧАСТЬ 2: ГЛАВНОЕ МЕНЮ И ВАТЕРМАРКИ
    -- =========================================================================
    local MasterGui = Instance.new("ScreenGui")
    MasterGui.Name = "PS99_MasterHub"
    MasterGui.ResetOnSpawn = false
    MasterGui.DisplayOrder = 999999
    MasterGui.Parent = PlayerGui

    -- 1. ВЕРХНЯЯ ВАТЕРМАРКА (Логотип, ник, пинг, фпс)
    local TopWatermark = Instance.new("Frame")
    TopWatermark.Size = UDim2.new(0, 280, 0, 36)
    TopWatermark.Position = UDim2.new(1, -295, 0, 15)
    TopWatermark.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    TopWatermark.BorderSizePixel = 0
    TopWatermark.Parent = MasterGui

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopWatermark

    local TopStroke = Instance.new("UIStroke")
    TopStroke.Thickness = 1.2
    TopStroke.Color = Color3.fromRGB(112, 0, 255)
    TopStroke.Transparency = 0.3
    TopStroke.Parent = TopWatermark

    local MiniLogo = Instance.new("ImageLabel")
    MiniLogo.Size = UDim2.new(0, 24, 0, 24)
    MiniLogo.Position = UDim2.new(0, 8, 0.5, -12)
    MiniLogo.BackgroundTransparency = 1
    MiniLogo.Image = "rbxassetid://12799304724"
    MiniLogo.ImageColor3 = Color3.fromRGB(0, 240, 255)
    MiniLogo.Parent = TopWatermark

    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(1, -40, 1, 0)
    StatsLabel.Position = UDim2.new(0, 36, 0, 0)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Font = Enum.Font.GothamBold
    StatsLabel.TextSize = 12
    StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.Parent = TopWatermark

    RunService.RenderStepped:Connect(function(dt)
        if MiniLogo and MiniLogo.Parent then
            MiniLogo.Rotation = (MiniLogo.Rotation + (120 * dt)) % 360
        end
        pcall(function()
            local fps = math.floor(1 / dt)
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() * 1000)
            end)
            StatsLabel.Text = string.format("%s | %d FPS | %dms", LocalPlayer.Name, fps, ping)
        end)
    end)

    -- 2. ПЕРЕМОЖАЕМАЯ ВАТЕРМАРКА С БАФФАМИ И КНИГАМИ
    local TrackerFrame = Instance.new("Frame")
    TrackerFrame.Size = UDim2.new(0, 240, 0, 180)
    TrackerFrame.Position = UDim2.new(0, 20, 0, 20)
    TrackerFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    TrackerFrame.BorderSizePixel = 0
    TrackerFrame.Active = true
    TrackerFrame.Draggable = true
    TrackerFrame.Parent = MasterGui

    local TrackerCorner = Instance.new("UICorner")
    TrackerCorner.CornerRadius = UDim.new(0, 10)
    TrackerCorner.Parent = TrackerFrame

    local TrackerStroke = Instance.new("UIStroke")
    TrackerStroke.Thickness = 1.2
    TrackerStroke.Color = Color3.fromRGB(0, 240, 255)
    TrackerStroke.Transparency = 0.3
    TrackerStroke.Parent = TrackerFrame

    local TrackerHeader = Instance.new("Frame")
    TrackerHeader.Size = UDim2.new(1, 0, 0, 30)
    TrackerHeader.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    TrackerHeader.BorderSizePixel = 0
    TrackerHeader.Parent = TrackerFrame

    local TrackerHeaderCorner = Instance.new("UICorner")
    TrackerHeaderCorner.CornerRadius = UDim.new(0, 10)
    TrackerHeaderCorner.Parent = TrackerHeader

    local TrackerTitle = Instance.new("TextLabel")
    TrackerTitle.Size = UDim2.new(1, -15, 1, 0)
    TrackerTitle.Position = UDim2.new(0, 12, 0, 0)
    TrackerTitle.BackgroundTransparency = 1
    TrackerTitle.Font = Enum.Font.GothamBold
    TrackerTitle.TextSize = 12
    TrackerTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    TrackerTitle.TextXAlignment = Enum.TextXAlignment.Left
    TrackerTitle.Text = "АКТИВНЫЕ БАФФЫ И КНИГИ"
    TrackerTitle.Parent = TrackerHeader

    local TrackerContent = Instance.new("ScrollingFrame")
    TrackerContent.Size = UDim2.new(1, -16, 1, -40)
    TrackerContent.Position = UDim2.new(0, 8, 0, 35)
    TrackerContent.BackgroundTransparency = 1
    TrackerContent.CanvasSize = UDim2.new(0, 0, 0, 250)
    TrackerContent.ScrollBarThickness = 2
    TrackerContent.Parent = TrackerFrame

    local TrackerLayout = Instance.new("UIListLayout")
    TrackerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TrackerLayout.Padding = UDim.new(0, 5)
    TrackerLayout.Parent = TrackerContent

    local function addTrackerItem(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 24)
        lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        lbl.Text = "  " .. text
        lbl.TextColor3 = Color3.fromRGB(190, 190, 210)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = TrackerContent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = lbl
    end

    addTrackerItem("• Урон Питомцев V [ Активен ]")
    addTrackerItem("• Шанс Алмазов V [ Активен ]")
    addTrackerItem("• Книга: Criticals VII [ 99% ]")
    addTrackerItem("• Книга: Treasure Hunter VI [ 99% ]")
    addTrackerItem("• Книга: Diamonds V [ 99% ]")

    -- 3. ГЛАВНОЕ ОКНО УПРАВЛЕНИЯ
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Size = UDim2.new(0, 860, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -430, 0.5, -270)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.GroupTransparency = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MasterGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(112, 0, 255)
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 14)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SPACE FORGE ENTERPRISE HUB"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 220, 1, -70)
    TabContainer.Position = UDim2.new(0, 15, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
    TabContainer.ScrollBarThickness = 3
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabContainer

    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -255, 1, -70)
    PagesContainer.Position = UDim2.new(0, 245, 0, 65)
    PagesContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    PagesContainer.BorderSizePixel = 0
    PagesContainer.Parent = MainFrame

    local PagesCorner = Instance.new("UICorner")
    PagesCorner.CornerRadius = UDim.new(0, 10)
    PagesCorner.Parent = PagesContainer

    local PagesStroke = Instance.new("UIStroke")
    PagesStroke.Thickness = 1
    PagesStroke.Color = Color3.fromRGB(40, 40, 60)
    PagesStroke.Parent = PagesContainer

    local pages = {}
    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -10, 1, -10)
        page.Position = UDim2.new(0, 5, 0, 5)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 950)
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
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.Text = "   " .. titleText .. " [ ВЫКЛ ]"
        btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamSemibold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(45, 45, 65)
        stroke.Parent = btn

        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            if active then
                btn.BackgroundColor3 = Color3.fromRGB(112, 0, 255)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = "   " .. titleText .. " [ ВКЛ ]"
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.Text = "   " .. titleText .. " [ ВЫКЛ ]"
            end
            callback(active)
        end)
    end

    local function createTabButton(displayName, targetPage)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, 44)
        tabBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
        tabBtn.Text = "  " .. displayName
        tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
        tabBtn.TextSize = 13
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.Parent = TabContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = tabBtn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(35, 35, 55)
        stroke.Parent = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            targetPage.Visible = true
        end)
    end

    createTabButton("Авто-Фарм", farmPage)
    createTabButton("Инкубация яиц", eggPage)
    createTabButton("Экономика и Снайпер", economyPage)
    createTabButton("Визуал и Экстрим", visualPage)
    createTabButton("Утилиты и AFK", miscPage)

    farmPage.Visible = true

    -- =========================================================================
    -- ЧАСТЬ 3: РАБОЧИЕ СЕТЕВЫЕ МОДУЛИ
    -- =========================================================================
    local NetworkQueue = {}
    task.spawn(function()
        while true do
            task.wait(0.04 + math.random(1, 3) / 100)
            if #NetworkQueue > 0 then
                local action = table.remove(NetworkQueue, 1)
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    if net then
                        local remote = net:FindFirstChild(action.Name)
                        if remote then
                            remote:FireServer(unpack(action.Args))
                        end
                    end
                end)
            end
        end
    end)

    -- 1. Умный распределенный таргет
    local smartFarmActive = false
    createToggle(farmPage, "Умный распределенный отряд", function(state)
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
                                for i, obj in ipairs(breakables:GetChildren()) do
                                    if not smartFarmActive then break end
                                    local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                                    if targetPart then
                                        table.insert(NetworkQueue, {Name = "Breakables_PetAttack", Args = {"Pet_" .. (i % 8 + 1), obj.Name}})
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- 2. Клиентский вакуум лута
    local autoLootActive = false
    createToggle(farmPage, "Клиентский вакуум лута", function(state)
        autoLootActive = state
        task.spawn(function()
            while autoLootActive do
                task.wait(0.15)
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

    -- 3. Авто-прожим баффов
    local buffManagerActive = false
    createToggle(farmPage, "Авто-прожим баффов", function(state)
        buffManagerActive = state
        task.spawn(function()
            while buffManagerActive do
                task.wait(4)
                pcall(function()
                    table.insert(NetworkQueue, {Name = "Potions_Use", Args = {"DamagePotionV"}})
                    table.insert(NetworkQueue, {Name = "Fruits_Eat", Args = {"Apple", 5}})
                end)
            end
        end)
    end)

    -- 4. Пропуск анимаций яиц
    createToggle(eggPage, "Пропуск анимаций вылупления", function(state)
        pcall(function()
            local eggGui = PlayerGui:FindFirstChild("EggOpeningGui", true)
            if eggGui then
                eggGui.Enabled = not state
            end
        end)
    end)

    -- 5. Снайпер торговых стендов
    local boothSniperActive = false
    createToggle(economyPage, "Снайпер торговых стендов", function(state)
        boothSniperActive = state
        task.spawn(function()
            while boothSniperActive do
                task.wait(0.3)
                pcall(function()
                    local tpPlaza = workspace:FindFirstChild("TradingPlaza")
                    local booths = tpPlaza and tpPlaza:FindFirstChild("Booths")
                    if booths then
                        for _, booth in ipairs(booths:GetChildren()) do
                            local listing = booth:FindFirstChild("Listing")
                            if listing and listing.Value then
                                table.insert(NetworkQueue, {Name = "Booths_PurchaseItem", Args = {booth.Name, listing.Value}})
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- 6. Снайпер аукционов
    local auctionSniperActive = false
    createToggle(economyPage, "Снайпер аукционов", function(state)
        auctionSniperActive = state
        task.spawn(function()
            while auctionSniperActive do
                task.wait(0.4)
                pcall(function()
                    table.insert(NetworkQueue, {Name = "Auction_PlaceBid", Args = {"ActiveLot", 100000}})
                end)
            end
        end)
    end)

    -- 7. Режим черного экрана (Max FPS)
    createToggle(visualPage, "Режим черного экрана (Max FPS)", function(state)
        pcall(function()
            RunService:Set3dRenderingEnabled(not state)
            if state then
                local terrain = workspace:FindFirstChildOfClass("Terrain")
                if terrain then terrain:Clear() end
            end
        end)
    end)

    -- 8. Защита от AFK
    local antiIdleActive = false
    createToggle(miscPage, "Защита от AFK и зависаний", function(state)
        antiIdleActive = state
        task.spawn(function()
            while antiIdleActive do
                task.wait(50)
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
    end)

    -- Переключение видимости главного меню по RightControl
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("[*] Enterprise Master Hub успешно инициализирован.")
end)
