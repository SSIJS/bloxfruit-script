-- language: Luau, file: ps99_enterprise_hub_fixed.lua, target: Roblox / Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    if PlayerGui:FindFirstChild("EnterpriseHub_Main") then PlayerGui.EnterpriseHub_Main:Destroy() end
    if PlayerGui:FindFirstChild("PS99_Loader") then PlayerGui.PS99_Loader:Destroy() end
    if PlayerGui:FindFirstChild("EnterpriseHub_Watermark") then PlayerGui.EnterpriseHub_Watermark:Destroy() end
end)

-- =========================================================================
-- ВАТЕРМАРКА
-- =========================================================================
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "EnterpriseHub_Watermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.DisplayOrder = 999998
WatermarkGui.Parent = PlayerGui

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.new(0, 160, 0, 30)
WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = WatermarkGui
Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 6)

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Size = UDim2.new(1, 0, 1, 0)
WatermarkText.BackgroundTransparency = 1
WatermarkText.Font = Enum.Font.GothamBold
WatermarkText.TextSize = 12
WatermarkText.TextColor3 = Color3.fromRGB(200, 200, 220)
WatermarkText.Text = "Enterprise Hub"
WatermarkText.Parent = WatermarkFrame

-- =========================================================================
-- ЗАГРУЗКА
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
Instance.new("UICorner", CanvasGroup).CornerRadius = UDim.new(0, 12)

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
StatusText.Text = "Инициализация ядра..."
StatusText.Parent = CanvasGroup

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 240, 0, 3)
BarBackground.Position = UDim2.new(0.5, -120, 0.8, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = CanvasGroup
Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(0, 8)

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarBackground
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 8)

local rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if Logo and Logo.Parent then
        Logo.Rotation = (Logo.Rotation + (120 * deltaTime)) % 360
    end
end)

task.spawn(function()
    TweenService:Create(CanvasGroup, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 340, 0, 200),
        Position = UDim2.new(0.5, -170, 0.5, -100)
    }):Play()
    task.wait(1.0)
    TweenService:Create(ProgressBar, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.2)

    TweenService:Create(CanvasGroup, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 340, 0, 0),
        Position = UDim2.new(0.5, -170, 0.5, 0),
        GroupTransparency = 1
    }):Play()
    task.wait(0.4)
    if rotationConnection then rotationConnection:Disconnect() end
    LoaderGui:Destroy()

    -- =========================================================================
    -- ГЛАВНОЕ МЕНЮ (БЕЗ ОБВОДОК, БЕЗ СМАЙЛИКОВ, ИСПРАВЛЕНО СВОРАЧИВАНИЕ)
    -- =========================================================================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "EnterpriseHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 999999
    MainGui.Parent = PlayerGui

    local MainCanvas = Instance.new("CanvasGroup")
    MainCanvas.Size = UDim2.new(0, 880, 0, 520)
    MainCanvas.Position = UDim2.new(0.5, -440, 0.5, -260)
    MainCanvas.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    MainCanvas.BorderSizePixel = 0
    MainCanvas.GroupTransparency = 1
    MainCanvas.Parent = MainGui
    Instance.new("UICorner", MainCanvas).CornerRadius = UDim.new(0, 10)

    TweenService:Create(MainCanvas, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {GroupTransparency = 0}):Play()

    -- Перетаскивание
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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

    -- Сайдбар
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

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(0, 150, 0, 26)
    LogoText.Position = UDim2.new(0, 20, 0, 20)
    LogoText.BackgroundTransparency = 1
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 16
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextXAlignment = Enum.TextXAlignment.Left
    LogoText.Text = "Enterprise Hub"
    LogoText.Parent = Sidebar

    local NavList = Instance.new("ScrollingFrame")
    NavList.Size = UDim2.new(1, 0, 1, -85)
    NavList.Position = UDim2.new(0, 0, 0, 75)
    NavList.BackgroundTransparency = 1
    NavList.CanvasSize = UDim2.new(0, 0, 0, 400)
    NavList.ScrollBarThickness = 0
    NavList.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavList

    -- Кнопки управления окном
    local TopControls = Instance.new("Frame")
    TopControls.Size = UDim2.new(0, 100, 0, 45)
    TopControls.Position = UDim2.new(1, -110, 0, 0)
    TopControls.BackgroundTransparency = 1
    TopControls.Parent = MainCanvas

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -32, 0.5, -14)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    CloseBtn.TextSize, CloseBtn.Font = 14, Enum.Font.GothamBold
    CloseBtn.Parent = TopControls

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainCanvas, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {GroupTransparency = 1}):Play()
        task.wait(0.2)
        MainGui:Destroy()
        WatermarkGui:Destroy()
    end)

    -- Контейнер содержимого (для скрытия при сворачивании)
    local ContainerWrapper = Instance.new("Frame")
    ContainerWrapper.Size = UDim2.new(1, -220, 1, -45)
    ContainerWrapper.Position = UDim2.new(0, 220, 0, 45)
    ContainerWrapper.BackgroundTransparency = 1
    ContainerWrapper.Parent = MainCanvas

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Position = UDim2.new(1, -68, 0.5, -14)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
    MinimizeBtn.TextSize, MinimizeBtn.Font = 14, Enum.Font.GothamBold
    MinimizeBtn.Parent = TopControls

    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            ContainerWrapper.Visible = false
            Sidebar.Visible = false
            TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 45)
            }):Play()
            MinimizeBtn.Text = "+"
        else
            TweenService:Create(MainCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 880, 0, 520)
            }):Play()
            task.wait(0.15)
            Sidebar.Visible = true
            ContainerWrapper.Visible = true
            MinimizeBtn.Text = "-"
        end
    end)

    -- Страницы
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -20, 1, -15)
    ContentArea.Position = UDim2.new(0, 10, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = ContainerWrapper

    local pages = {}
    local activePage = nil

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 1000)
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

    local mainPage = createPage("Main")
    local farmPage = createPage("Farm")
    local petsPage = createPage("Pets")
    local eggsPage = createPage("Eggs")
    local shopPage = createPage("Shop")
    local tpPage = createPage("Teleport")
    local miscPage = createPage("Misc")

    local function switchPage(targetPage)
        if activePage == targetPage then return end
        for _, p in pairs(pages) do p.Visible = false end
        activePage = targetPage
        targetPage.Visible = true
    end

    local function createTab(displayName, targetPage)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 38)
        btn.Position = UDim2.new(0, 8, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        btn.BackgroundTransparency = 1
        btn.Text = "   " .. displayName
        btn.TextColor3 = Color3.fromRGB(150, 150, 165)
        btn.TextSize, btn.Font = 13, Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = NavList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(NavList:GetChildren()) do
                if b:IsA("TextButton") then
                    TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(16, 16, 20), BackgroundTransparency = 1}):Play()
                    b.TextColor3 = Color3.fromRGB(150, 150, 165)
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), BackgroundTransparency = 0}):Play()
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            switchPage(targetPage)
        end)
    end

    createTab("Главная", mainPage)
    createTab("Авто-Фарм", farmPage)
    createTab("Питомцы", petsPage)
    createTab("Яйца", eggsPage)
    createTab("Экономика", shopPage)
    createTab("Телепортация", tpPage)
    createTab("Утилиты и AFK", miscPage)

    mainPage.Visible = true
    activePage = mainPage

    local function createCard(page, titleText, descText)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 85)
        card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        card.BorderSizePixel = 0
        card.Parent = page
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -30, 0, 22)
        title.Position = UDim2.new(0, 16, 0, 14)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = titleText
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -30, 0, 20)
        desc.Position = UDim2.new(0, 16, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.TextSize, desc.TextColor3 = 12, Color3.fromRGB(140, 140, 155)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = descText
        desc.Parent = card

        return card
    end

    local function createToggle(page, text, callback)
        local card = createCard(page, text, "Нажмите для включения функции")
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 32)
        btn.Position = UDim2.new(1, -105, 0.5, -16)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.Text = "ВЫКЛ"
        btn.TextColor3 = Color3.fromRGB(180, 180, 195)
        btn.TextSize, btn.Font = 12, Enum.Font.GothamBold
        btn.Parent = card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 40)
            btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 195)
            btn.Text = state and "ВКЛ" or "ВЫКЛ"
            callback(state)
        end)
    end

    createCard(mainPage, "Статус Enterprise Hub", "Все системы активны, обход защиты работает стабильно.")

    -- Функционал
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

    createToggle(farmPage, "Умный авто-фарм монет и сундуков", function(st)
        task.spawn(function()
            while st do
                task.wait(0.1)
                pcall(function()
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        for _, zone in ipairs(map:GetChildren()) do
                            local breakables = zone:FindFirstChild("Breakables")
                            if breakables then
                                for i, obj in ipairs(breakables:GetChildren()) do
                                    if not st then break end
                                    table.insert(NetQueue, {Name = "Breakables_PetAttack", Args = {"Pet_" .. (i%8+1), obj.Name}})
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end)

    createToggle(farmPage, "Авто-сбор лута и алмазов", function(st)
        task.spawn(function()
            while st do
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

    createToggle(petsPage, "Авто-экипировка лучших питомцев", function(st)
        task.spawn(function()
            while st do
                task.wait(5)
                pcall(function() table.insert(NetQueue, {Name = "Pets_EquipBest", Args = {}}) end)
            end
        end)
    end)

    createToggle(eggsPage, "Пропуск анимации вылупления", function(st)
        pcall(function()
            local eggGui = PlayerGui:FindFirstChild("EggOpeningGui", true)
            if eggGui then eggGui.Enabled = not st end
        end)
    end)

    createToggle(eggsPage, "Авто-открытие яиц (x99)", function(st)
        task.spawn(function()
            while st do
                task.wait(0.5)
                pcall(function() table.insert(NetQueue, {Name = "Eggs_Open", Args = {"Spawn Egg", 99}}) end)
            end
        end)
    end)

    createToggle(shopPage, "Снайпер торговых стендов", function(st)
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

    local tpCard1 = createCard(tpPage, "Торговая Плаза", "Быстрое перемещение в Trading Plaza")
    local tpBtn1 = Instance.new("TextButton", tpCard1)
    tpBtn1.Size = UDim2.new(0, 100, 0, 32)
    tpBtn1.Position = UDim2.new(1, -115, 0.5, -16)
    tpBtn1.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    tpBtn1.Text, tpBtn1.TextColor3, tpBtn1.TextSize, tpBtn1.Font = "Перейти", Color3.fromRGB(255, 255, 255), 12, Enum.Font.GothamBold
    Instance.new("UICorner", tpBtn1).CornerRadius = UDim.new(0, 6)
    tpBtn1.MouseButton1Click:Connect(function() TeleportService:Teleport(8737899170, LocalPlayer) end)

    createToggle(miscPage, "Защита от AFK-кика", function(st)
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

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainCanvas.Visible = not MainCanvas.Visible
        end
    end)

    print("[*] Enterprise Hub успешно запущен.")
end)
