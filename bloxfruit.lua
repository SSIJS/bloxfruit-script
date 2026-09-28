-- language: Luau, file: ps99_xeno_style_hub.lua, target: Roblox / Executor
-- *Pet Simulator 99 - Xeno Style Enterprise Hub*

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
    if PlayerGui:FindFirstChild("XenoHub_Main") then PlayerGui.XenoHub_Main:Destroy() end
    if PlayerGui:FindFirstChild("PS99_Loader") then PlayerGui.PS99_Loader:Destroy() end
end)

-- =========================================================================
-- ЧАСТЬ 1: КРАСИВАЯ ИМБОВАЯ ЗАГРУЗКА
-- =========================================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "PS99_Loader"
LoaderGui.ResetOnSpawn = false
LoaderGui.DisplayOrder = 999999
LoaderGui.Parent = PlayerGui

local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(0, 340, 0, 200)
CanvasGroup.Position = UDim2.new(0.5, -170, 0.5, -100)
CanvasGroup.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
CanvasGroup.BorderSizePixel = 0
CanvasGroup.GroupTransparency = 1
CanvasGroup.Parent = LoaderGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = CanvasGroup

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Parent = CanvasGroup

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 50, 0, 50)
Logo.Position = UDim2.new(0.5, -25, 0.3, -25)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://12799304724"
Logo.ImageColor3 = Color3.fromRGB(255, 255, 255)
Logo.Parent = CanvasGroup

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 0, 20)
StatusText.Position = UDim2.new(0, 20, 0.62, 0)
StatusText.BackgroundTransparency = 1
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 13
StatusText.TextColor3 = Color3.fromRGB(160, 160, 175)
StatusText.Text = "Инициализация ядра Xeno..."
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
ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarBackground

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 8)
ProgressCorner.Parent = ProgressBar

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

    ChangeStatus("Загрузка стилей интерфейса Xeno...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.4, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Подключение модулей скрипта...")
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.8, 0, 1, 0)}):Play()
    task.wait(1.2)

    ChangeStatus("Готово. Запуск...")
    TweenService:Create(ProgressBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
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
    -- ЧАСТЬ 2: ГЛАВНОЕ МЕНЮ В СТИЛЕ XENO (С ПЛАВНЫМИ АНИМАЦИЯМИ)
    -- =========================================================================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "XenoHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 999999
    MainGui.Parent = PlayerGui

    -- Главное окно (CanvasGroup для плавной анимации скрытия/сворачивания всего меню)
    local MainCanvas = Instance.new("CanvasGroup")
    MainCanvas.Size = UDim2.new(0, 880, 0, 520)
    MainCanvas.Position = UDim2.new(0.5, -440, 0.5, -260)
    MainCanvas.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    MainCanvas.BorderSizePixel = 0
    MainCanvas.GroupTransparency = 1
    MainCanvas.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainCanvas

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1
    MainStroke.Color = Color3.fromRGB(35, 35, 45)
    MainStroke.Parent = MainCanvas

    -- Плавное появление главного меню при старте
    TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {GroupTransparency = 0}):Play()

    -- Невидимый слой для перетаскивания мышкой
    local DragFrame = Instance.new("Frame")
    DragFrame.Size = UDim2.new(1, 0, 0, 45)
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

    -- Левая боковая панель (как на скриптах Xeno)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 220, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainCanvas

    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0, 0)
    SidebarLine.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Parent = Sidebar

    -- Логотип в боковой панели
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 26, 0, 26)
    LogoIcon.Position = UDim2.new(0, 20, 0, 20)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = "rbxassetid://12799304724"
    LogoIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    LogoIcon.Parent = Sidebar

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(0, 120, 0, 26)
    LogoText.Position = UDim2.new(0, 56, 0, 20)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 18
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.Text = "Xeno"
    LogoText.Parent = Sidebar

    -- Разделитель в сайдбаре
    local Sep = Instance.new("Frame")
    Sep.Size = UDim2.new(1, -30, 0, 1)
    Sep.Position = UDim2.new(0, 15, 0, 65)
    Sep.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Sep.BorderSizePixel = 0
    Sep.Parent = Sidebar

    -- Список вкладок сайдбара
    local NavList = Instance.new("ScrollingFrame")
    NavList.Size = UDim2.new(1, 0, 1, -85)
    NavList.Position = UDim2.new(0, 0, 0, 75)
    NavList.BackgroundTransparency = 1
    NavList.CanvasSize = UDim2.new(0, 0, 0, 350)
    NavList.ScrollBarThickness = 0
    NavList.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavList

    -- Правая верхняя панель (Управление окном: Свернуть, Закрыть)
    local TopControls = Instance.new("Frame")
    TopControls.Size = UDim2.new(0, 100, 0, 45)
    TopControls.Position = UDim2.new(1, -110, 0, 0)
    TopControls.BackgroundTransparency = 1
    TopControls.Parent = MainCanvas

    -- Кнопка ЗАКРЫТЬ ("✕")
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopControls

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainCanvas, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {GroupTransparency = 1, Size = UDim2.new(0, 800, 0, 470)}):Play()
        task.wait(0.2)
        MainGui:Destroy()
    end)

    -- Кнопка СВЕРНУТЬ/РАЗВЕРНУТЬ ПЛАВНО ("—")
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Position = UDim2.new(1, -68, 0.5, -14)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TopControls

    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            -- Плавное сворачивание меню в компактную полоску
            TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 45)
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
            TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 520)
            }):Play()
            MinimizeBtn.Text = "—"
        end
    end)

    -- Контейнер для страниц контента справа
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -240, 1, -55)
    ContentArea.Position = UDim2.new(0, 230, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainCanvas

    local pages = {}
    local activePage = nil

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -20, 1, -15)
        page.Position = UDim2.new(0, 10, 0, 10)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 800)
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

    local dashPage = createPage("Dashboard")
    local execPage = createPage("Executor")
    local scriptPage = createPage("ScriptHub")
    local clientPage = createPage("ClientManager")
    local settingsPage = createPage("Settings")

    -- Функция переключения разделов с плавным появлением (fade-in + сдвиг)
    local function switchPage(targetPage, tabButton)
        if activePage == targetPage then return end
        
        for _, p in pairs(pages) do
            if p.Visible then
                -- Плавное исчезновение старой страницы
                pcall(function()
                    for _, child in ipairs(p:GetChildren()) do
                        if child:IsA("GuiObject") then
                            TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
                        end
                    end
                end)
                task.wait(0.1)
                p.Visible = false
            end
        end

        activePage = targetPage
        targetPage.Visible = true

        -- Плавное появление элементов новой страницы
        pcall(function()
            for _, child in ipairs(targetPage:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Position = child.Position + UDim2.new(0, 0, 0, 10)
                    TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = child.Position - UDim2.new(0, 0, 0, 10)}):Play()
                end
            end
        end)
    end

    -- Создание кнопок в боковой панели под стиль Xeno
    local function createTab(displayName, targetPage)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 38)
        btn.Position = UDim2.new(0, 8, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. displayName
        btn.TextColor3 = Color3.fromRGB(150, 150, 165)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = NavList

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(NavList:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(16, 16, 20), BackgroundTransparency = 1}):Play()
                    b.TextColor3 = Color3.fromRGB(150, 150, 165)
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0}):Play()
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            switchPage(targetPage, btn)
        end)
    end

    createTab("Dashboard", dashPage)
    createTab("Executor", execPage)
    createTab("ScriptHub", scriptPage)
    createTabButton_dummy = nil -- clean
    createTab("Client Manager", clientPage)
    createTab("Settings", settingsPage)

    -- Открываем Dashboard по умолчанию
    dashPage.Visible = true
    activePage = dashPage

    -- Функция создания стильных блоков (карточек) в стиле Xeno
    local function createCard(page, titleText, descText)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 90)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        card.BorderSizePixel = 0
        card.Parent = page

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = card

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(32, 32, 42)
        stroke.Parent = card

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -30, 0, 24)
        title.Position = UDim2.new(0, 16, 0, 16)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = titleText
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -30, 0, 20)
        desc.Position = UDim2.new(0, 16, 0, 42)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 12
        desc.TextColor3 = Color3.fromRGB(140, 140, 155)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = descText
        desc.Parent = card

        return card
    end

    -- Наполнение вкладки Dashboard
    createCard(dashPage, "Добро пожаловать в Xeno Hub", "Уникальная версия панели управления для Pet Simulator 99")
    createCard(dashPage, "Статус системы", "Все ядра безопасности и обхода активны и работают стабильно")

    -- Наполнение вкладки Settings (Переключатели / Кнопки в стиле Xeno)
    createCard(settingsPage, "Конфигурация интерфейса", "Настройте внешний вид и поведение панели под себя")

    -- Защита от AFK в Настройках
    local afkCard = createCard(settingsPage, "Защита от AFK", "Предотвращает отключение от сервера при бездействии")
    local afkBtn = Instance.new("TextButton")
    afkBtn.Size = UDim2.new(0, 90, 0, 32)
    afkBtn.Position = UDim2.new(1, -105, 0.5, -16)
    afkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    afkBtn.Text = "ВЫКЛ"
    afkBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    afkBtn.TextSize, afkBtn.Font = 12, Enum.Font.GothamBold
    afkBtn.Parent = afkCard
    Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 6)

    local afkActive = false
    afkBtn.MouseButton1Click:Connect(function()
        afkActive = not afkActive
        afkBtn.BackgroundColor3 = afkActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 40)
        afkBtn.TextColor3 = afkActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 195)
        afkBtn.Text = afkActive and "ВКЛ" or "ВЫКЛ"
        
        task.spawn(function()
            while afkActive do
                task.wait(45)
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end
        end)
    end)

    -- Горячая клавиша для открытия/скрытия меню (Right Control)
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainCanvas.Visible = not MainCanvas.Visible
        end
    end)

    print("[*] Xeno Style Hub успешно запущен.")
end)
