-- language: Luau, file: ps99_ultimate_enterprise_hub.lua, target: Roblox / Executor
-- *Pet Simulator 99 - Enterprise Master Hub v5.0 (Custom Loader + Full Features)*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Очистка старых копий
pcall(function()
    if PlayerGui:FindFirstChild("EnterpriseHub_Main") then PlayerGui.EnterpriseHub_Main:Destroy() end
    if PlayerGui:FindFirstChild("PS99_Loader") then PlayerGui.PS99_Loader:Destroy() end
end)

-- =========================================================================
-- ЧАСТЬ 1: ТА САМАЯ ИМБОВАЯ И КРАСИВАЯ ЗАГРУЗКА
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
    TweenService:Create(ProgressBar, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {Size = UDim2.new(0.35, 0, 1, 0)}):Play()
    task.wait(1.0)

    ChangeStatus("Загрузка таблиц сетевых эмуляций...")
    TweenService:Create(ProgressBar, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {Size = UDim2.new(0.75, 0, 1, 0)}):Play()
    task.wait(1.0)

    ChangeStatus("Инициализация графического интерфейса...")
    TweenService:Create(ProgressBar, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.8)

    ChangeStatus("Готово. Запуск...")
    task.wait(0.5)

    TweenService:Create(CanvasGroup, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 340, 0, 0),
        Position = UDim2.new(0.5, -170, 0.5, 0),
        GroupTransparency = 1
    }):Play()
    task.wait(0.4)
    if rotationConnection then rotationConnection:Disconnect() end
    LoaderGui:Destroy()

    -- =========================================================================
    -- ЧАСТЬ 2: ГЛАВНОЕ МЕНЮ (ПЛАВНОЕ СВОРАЧИВАНИЕ И РАЗВЕРТЫВАНИЕ)
    -- =========================================================================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "EnterpriseHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 999999
    MainGui.Parent = PlayerGui

    -- Главное окно (CanvasGroup для плавной анимации)
    local MainCanvas = Instance.new("CanvasGroup")
    MainCanvas.Size = UDim2.new(0, 880, 0, 540)
    MainCanvas.Position = UDim2.new(0.5, -440, 0.5, -270)
    MainCanvas.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    MainCanvas.BorderSizePixel = 0
    MainCanvas.GroupTransparency = 1
    MainCanvas.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainCanvas

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.2
    MainStroke.Color = Color3.fromRGB(112, 0, 255)
    MainStroke.Transparency = 0.4
    MainStroke.Parent = MainCanvas

    -- Плавное появление меню
    TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {GroupTransparency = 0}):Play()

    -- Верхняя панель перетаскивания (Drag)
    local DragFrame = Instance.new("Frame")
    DragFrame.Size = UDim2.new(1, 0, 0, 48)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Active = true
    DragFrame.Parent = MainCanvas

    local dragging, dragInput, dragStart, startPos
    DragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainCanvas.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    DragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Левая панель навигации (Сайдбар)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainCanvas

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    -- Заголовок в сайдбаре
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, -20, 0, 48)
    LogoText.Position = UDim2.new(0, 20, 0, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 16
    LogoText.TextColor3 = Color3.fromRGB(0, 240, 255)
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.Text = "⚡ ENTERPRISE HUB"
    LogoText.Parent = Sidebar

    local Sep = Instance.new("Frame")
    Sep.Size = UDim2.new(1, -30, 0, 1)
    Sep.Position = UDim2.new(0, 15, 0, 50)
    Sep.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Sep.BorderSizePixel = 0
    Sep.Parent = Sidebar

    -- Скролл вкладок
    local NavList = Instance.new("ScrollingFrame")
    NavList.Size = UDim2.new(1, 0, 1, -65)
    NavList.Position = UDim2.new(0, 0, 0, 60)
    NavList.BackgroundTransparency = 1
    NavList.CanvasSize = UDim2.new(0, 0, 0, 450)
    NavList.ScrollBarThickness = 0
    NavList.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 6)
    NavLayout.Parent = NavList

    -- Кнопки управления окном (Справа сверху)
    local TopControls = Instance.new("Frame")
    TopControls.Size = UDim2.new(0, 100, 0, 48)
    TopControls.Position = UDim2.new(1, -110, 0, 0)
    TopControls.BackgroundTransparency = 1
    TopControls.Parent = MainCanvas

    -- Кнопка ЗАКРЫТЬ ("✕")
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 70)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize, CloseBtn.Font = 13, Enum.Font.GothamBold
    CloseBtn.Parent = TopControls
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainCanvas, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
        task.wait(0.25)
        MainGui:Destroy()
    end)

    -- Кнопка ПЛАВНОГО СВОРЫВАНИЯ / РАЗВЕРТЫВАНИЯ ("—")
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    MinimizeBtn.Position = UDim2.new(1, -74, 0.5, -16)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize, MinimizeBtn.Font = 13, Enum.Font.GothamBold
    MinimizeBtn.Parent = TopControls
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            -- Плавное сворачивание меню в компактную панель
            TweenService:Create(MainCanvas, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 48)
            }):Play()
            for _, child in ipairs(MainCanvas:GetChildren()) do
                if child ~= Sidebar and child ~= TopControls and child ~= DragFrame and child ~= MainCorner and child ~= MainStroke then
                    child.Visible = false
                end
            end
            Sidebar.Visible = false
            MinimizeBtn.Text = "+"
        else
            -- Плавное развертывание обратно
            for _, child in ipairs(MainCanvas:GetChildren()) do
                child.Visible = true
            end
            Sidebar.Visible = true
            TweenService:Create(MainCanvas, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 540)
            }):Play()
            MinimizeBtn.Text = "—"
        end
    end)

    -- Область контента
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -240, 1, -55)
    ContentArea.Position = UDim2.new(0, 230, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainCanvas

    local pages = {}
    local activePage = nil

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -20, 1, -10)
        page.Position = UDim2.new(0, 10, 0, 5)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 1200)
        page.ScrollBarThickness = 3
        page.Visible = false
        page.Parent = ContentArea

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = page

        pages[name] = page
        return page
    end

    -- Переименованные и новые разделы
    local dashboardPage = createPage("Dashboard")
    local farmPage = createPage("Farm")
    local petsPage = createPage("Pets")
    local eggsPage = createPage("Eggs")
    local economyPage = createPage("Economy")
    local teleportsPage = createPage("Teleports")
    local visualsPage = createPage("Visuals")
    local utilsPage = createPage("Utils")

    -- Плавное переключение страниц (Fade-in + сдвиг)
    local function switchPage(targetPage)
        if activePage == targetPage then return end
        for _, p in pairs(pages) do
            if p.Visible then
                p.Visible = false
            end
        end
        activePage = targetPage
        targetPage.Visible = true

        pcall(function()
            for _, child in ipairs(targetPage:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Position = child.Position + UDim2.new(0, 0, 0, 8)
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = child.Position - UDim2.new(0, 0, 0, 8)}):Play()
                end
            end
        end)
    end

    local function createTab(displayName, targetPage)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 40)
        btn.Position = UDim2.new(0, 8, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. displayName
        btn.TextColor3 = Color3.fromRGB(160, 160, 175)
        btn.TextSize, btn.Font = 13, Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = NavList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(NavList:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 1}):Play()
                    b.TextColor3 = Color3.fromRGB(160, 160, 175)
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 30), BackgroundTransparency = 0}):Play()
            btn.TextColor3 = Color3.fromRGB(0, 240, 255)
            switchPage(targetPage)
        end)
    end

    createTab("Главная (Dashboard)", dashboardPage)
    createTab("Авто-Фарм", farmPage)
    createTab("Питомцы", petsPage)
    createTab("Яйца", eggsPage)
    createTab("Экономика", economyPage)
    createTab("Телепортация", teleportsPage)
    createTab("Визуал & FPS", visualsPage)
    createTab("Утилиты & AFK", utilsPage)

    dashboardPage.Visible = true
    activePage = dashboardPage

    -- Вспомогательные функции UI для элементов
    local function createToggle(page, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        btn.Text = "   ⚡ " .. text .. " [ ВЫКЛ ]"
        btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        btn.TextSize, btn.Font = 13, Enum.Font.GothamSemibold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Color3.fromRGB(35, 35, 50)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(112, 0, 255)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = "   ⚡ " .. text .. " [ ВКЛ ]"
            else
                btn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.Text = "   ⚡ " .. text .. " [ ВЫКЛ ]"
            end
            callback(state)
        end)
    end

    local function createButton(page, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        btn.Text = "   🔹 " .. text
        btn.TextColor3 = Color3.fromRGB(220, 220, 240)
        btn.TextSize, btn.Font = 13, Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        btn.MouseButton1Click:Connect(function() callback() end)
    end

    -- Наполнение вкладки Dashboard (Главная)
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -10, 0, 100)
    infoCard.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    infoCard.Parent = dashboardPage
    Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 8)
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -30, 1, 0)
    infoText.Position = UDim2.new(0, 15, 0, 0)
    infoText.BackgroundTransparency = 1
    infoText.Font = Enum.Font.GothamMedium
    infoText.TextSize = 13
    infoText.TextColor3 = Color3.fromRGB(200, 200, 220)
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Text = "Добро пожаловать в Enterprise Hub!\nИспользуйте меню слева для переключения разделов.\nНажмите [RightControl], чтобы скрыть/показать интерфейс."
    infoText.Parent = infoCard

    -- =========================================================================
    -- ЧАСТЬ 3: РЕАЛИЗАЦИЯ ИГРОВОГО ФУНКЦИОНАЛА
    -- =========================================================================
    local NetQueue = {}
    task.spawn(function()
        while true do
            task.wait(0.03)
            if #NetQueue > 0 then
                local action = table.remove(NetQueue, 1)
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    if net then
                        local remote = net:FindFirstChild(action.Name)
                        if remote then remote:FireServer(unpack(action.Args)) end
                    end
                end)
            end
        end
    end)

    -- Авто-фарм
    local smartFarm = false
    createToggle(farmPage, "Умный авто-фарм монет и сундуков", function(st)
        smartFarm = st
        task.spawn(function()
            while smartFarm do
                task.wait(0.1)
                pcall(function()
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        for _, zone in ipairs(map:GetChildren()) do
                            local breakables = zone:FindFirstChild("Breakables")
                            if breakables then
                                for i, obj in ipairs(breakables:GetChildren()) do
                                    if not smartFarm then break end
                                    table.insert(NetQueue, {Name = "Breakables_PetAttack", Args = {"Pet_" .. (i%8+1), obj.Name}})
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)

    local autoLoot = false
    createToggle(farmPage, "Авто-сбор лута и алмазов", function(st)
        autoLoot = st
        task.spawn(function()
            while autoLoot do
                task.wait(0.15)
                pcall(function()
                    local drops = workspace:FindFirstChild("Drops")
                    local char = LocalPlayer.Character
                    if drops and char and char:FindFirstChild("HumanoidRootPart") then
                        local pos = char.HumanoidRootPart.CFrame
                        for _, d in ipairs(drops:GetChildren()) do
                            local p = d:IsA("Model") and (d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")) or d
                            if p and p:IsA("BasePart") then p.CFrame = pos end
                        end
                    end
                end)
            end
        end)
    end)

    -- Питомцы
    createToggle(petsPage, "Авто-экипировка лучших питомцев", function(st)
        task.spawn(function()
            while st do
                task.wait(5)
                pcall(function() table.insert(NetQueue, {Name = "Pets_EquipBest", Args = {}}) end)
            end
        end)
    end)
    createButton(petsPage, "Конвертировать всех в Золото", function()
        pcall(function() table.insert(NetQueue, {Name = "GoldenPets_ConvertAll", Args = {}}) end)
    end)
    createButton(petsPage, "Конвертировать всех в Радугу", function()
        pcall(function() table.insert(NetQueue, {Name = "RainbowPets_ConvertAll", Args = {}}) end)
    end)

    -- Яйца
    createToggle(eggsPage, "Пропуск анимации вылупления", function(st)
        pcall(function()
            local eggGui = PlayerGui:FindFirstChild("EggOpeningGui", true)
            if eggGui then eggGui.Enabled = not st end
        end)
    end)
    createToggle(eggsPage, "Авто-открытие выбранного яйца (x99)", function(st)
        task.spawn(function()
            while st do
                task.wait(0.5)
                pcall(function() table.insert(NetQueue, {Name = "Eggs_Open", Args = {"Spawn Egg", 99}}) end)
            end
        end)
    end)

    -- Экономика
    createToggle(economyPage, "Снайпер дешевых стендов (Booths)", function(st)
        task.spawn(function()
            while st do
                task.wait(0.3)
                pcall(function()
                    local plaza = workspace:FindFirstChild("TradingPlaza")
                    local booths = plaza and plaza:FindFirstChild("Booths")
                    if booths then
                        for _, b in ipairs(booths:GetChildren()) do
                            local l = b:FindFirstChild("Listing")
                            if l and l.Value then
                                table.insert(NetQueue, {Name = "Booths_PurchaseItem", Args = {b.Name, l.Value}})
                            end
                        end
                    end
                end)
            end
        end)
    end)

    -- Телепортация
    createButton(teleportsPage, "Телепорт в Торговую Плазу", function()
        TeleportService:Teleport(8737899170, LocalPlayer)
    end)
    createButton(teleportsPage, "Телепорт на Спавн (World 1)", function()
        TeleportService:Teleport(8737860132, LocalPlayer)
    end)

    -- Визуал & FPS
    createToggle(visualsPage, "Режим черного экрана (Макс FPS)", function(st)
        RunService:Set3dRenderingEnabled(not st)
        if st then pcall(function() workspace.Terrain:Clear() end) end
    end)

    -- Утилиты & AFK
    createToggle(utilsPage, "Надежная защита от AFK-кика", function(st)
        task.spawn(function()
            while st do
                task.wait(45)
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
    end)

    -- Скрытие меню по RightControl
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainCanvas.Visible = not MainCanvas.Visible
        end
    end)

    print("[*] Enterprise Master Hub успешно запущен.")
end)
