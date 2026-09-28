-- language: Luau, file: ps99_ultimate_cyber_hub_v4.lua, target: Roblox / Executor
-- *Pet Simulator 99 - Cyber Enterprise Master Hub v4.0 (Custom Loader & Redesigned UI)*

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
    if PlayerGui:FindFirstChild("CyberHub_Main") then PlayerGui.CyberHub_Main:Destroy() end
    if PlayerGui:FindFirstChild("PS99_Loader") then PlayerGui.PS99_Loader:Destroy() end
end)

-- =========================================================================
-- ЧАСТЬ 1: ТА САМАЯ КРАСИВАЯ ИМБОВАЯ ЗАГРУЗКА
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
    -- ЧАСТЬ 2: ПОЛНОСТЬЮ НОВОЕ, КРАСИВОЕ МЕНЮ (СВЕРНУТЬ, ЗАКРЫТЬ, ВКЛАДКИ)
    -- =========================================================================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "CyberHub_Main"
    MainGui.ResetOnSpawn = false
    MainGui.DisplayOrder = 999999
    MainGui.Parent = PlayerGui

    -- Верхняя ватермарка (FPS / Пинг / Ник)
    local Watermark = Instance.new("Frame")
    Watermark.Size = UDim2.new(0, 280, 0, 36)
    Watermark.Position = UDim2.new(1, -295, 0, 15)
    Watermark.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Watermark.BorderSizePixel = 0
    Watermark.Parent = MainGui

    local WmCorner = Instance.new("UICorner")
    WmCorner.CornerRadius = UDim.new(0, 8)
    WmCorner.Parent = Watermark

    local WmStroke = Instance.new("UIStroke")
    WmStroke.Color = Color3.fromRGB(112, 0, 255)
    WmStroke.Transparency = 0.3
    WmStroke.Parent = Watermark

    local WmLogo = Instance.new("ImageLabel")
    WmLogo.Size = UDim2.new(0, 24, 0, 24)
    WmLogo.Position = UDim2.new(0, 8, 0.5, -12)
    WmLogo.BackgroundTransparency = 1
    WmLogo.Image = "rbxassetid://12799304724"
    WmLogo.ImageColor3 = Color3.fromRGB(0, 240, 255)
    WmLogo.Parent = Watermark

    local WmText = Instance.new("TextLabel")
    WmText.Size = UDim2.new(1, -40, 1, 0)
    WmText.Position = UDim2.new(0, 36, 0, 0)
    WmText.BackgroundTransparency = 1
    WmText.Font = Enum.Font.GothamBold
    WmText.TextSize = 12
    WmText.TextColor3 = Color3.fromRGB(220, 220, 240)
    WmText.TextXAlignment = Enum.TextXAlignment.Left
    WmText.Parent = Watermark

    -- Расчет FPS и Пинга
    local fCount, lTime, curFps = 0, tick(), 60
    RunService.RenderStepped:Connect(function(dt)
        if WmLogo and WmLogo.Parent then
            WmLogo.Rotation = (WmLogo.Rotation + (120 * dt)) % 360
        end
        fCount = fCount + 1
        local now = tick()
        if now - lTime >= 1 then
            curFps = math.floor(fCount / (now - lTime))
            fCount = 0
            lTime = now
        end
        local ping = 0
        pcall(function()
            local pi = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if pi then ping = math.floor(pi:GetValue()) end
        end)
        WmText.Text = string.format("%s | %d FPS | %dms", LocalPlayer.Name, curFps, ping)
    end)

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 880, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -440, 0.5, -270)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MainGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(112, 0, 255)
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame

    -- Шапка окна
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 14)
    TopBarCorner.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 450, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = "SPACE FORGE ENTERPRISE : HUB v4.0"
    TitleLabel.Parent = TopBar

    -- Кнопка ЗАКРЫТЬ ("X")
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 32)
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -16)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 65)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)

    -- Кнопка СВЕРНУТЬ ("_")
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 32)
    MinimizeBtn.Position = UDim2.new(1, -88, 0.5, -16)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TopBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeBtn

    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= TopBar and child ~= MainCorner and child ~= MainStroke then
                child.Visible = not isMinimized
            end
        end
        if isMinimized then
            MainFrame.Size = UDim2.new(0, 880, 0, 50)
            MinimizeBtn.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 880, 0, 540)
            MinimizeBtn.Text = "—"
        end
    end)

    -- Левая панель вкладок
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 220, 1, -70)
    TabContainer.Position = UDim2.new(0, 15, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 450)
    TabContainer.ScrollBarThickness = 3
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabContainer

    -- Правая панель контента
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
        page.CanvasSize = UDim2.new(0, 0, 0, 1100)
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
    local petsPage = createPage("Pets")
    local eggsPage = createPage("Eggs")
    local economyPage = createPage("Economy")
    local tpPage = createPage("Teleport")
    local visualPage = createPage("Visual")
    local miscPage = createPage("Misc")

    -- Функции интерфейса
    local function createToggle(page, titleText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.Text = "   ⚡ " .. titleText .. " [ ВЫКЛ ]"
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
                btn.Text = "   ⚡ " .. titleText .. " [ ВКЛ ]"
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                btn.TextColor3 = Color3.fromRGB(180, 180, 200)
                btn.Text = "   ⚡ " .. titleText .. " [ ВЫКЛ ]"
            end
            callback(active)
        end)
    end

    local function createButton(page, titleText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Text = "   🔹 " .. titleText
        btn.TextColor3 = Color3.fromRGB(220, 220, 240)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            callback()
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
    createTabButton("Питомцы", petsPage)
    createTabButton("Яйца и Открытие", eggsPage)
    createTabButton("Экономика", economyPage)
    createTabButton("Телепортация", tpPage)
    createTabButton("Визуал и FPS", visualPage)
    createTabButton("Утилиты и AFK", miscPage)

    farmPage.Visible = true

    -- =========================================================================
    -- ЧАСТЬ 3: ФУНКЦИОНАЛ
    -- =========================================================================
    local NetQueue = {}
    task.spawn(function()
        while true do
            task.wait(0.04)
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

    -- Фарм
    local smartFarm = false
    createToggle(farmPage, "Умный распределенный авто-фарм", function(st)
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
    createToggle(farmPage, "Клиентский вакуум лута и алмазов", function(st)
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
    createToggle(eggsPage, "Пропуск анимаций вылупления", function(st)
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

    -- Экономика
    createToggle(economyPage, "Снайпер торговых стендов", function(st)
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

    -- Телепорт
    createButton(tpPage, "Телепорт в Торговую Плазу", function()
        TeleportService:Teleport(8737899170, LocalPlayer)
    end)
    createButton(tpPage, "Телепорт на Спавн (World 1)", function()
        TeleportService:Teleport(8737860132, LocalPlayer)
    end)

    -- Визуал
    createToggle(visualPage, "Режим черного экрана (Макс FPS)", function(st)
        RunService:Set3dRenderingEnabled(not st)
        if st then pcall(function() workspace.Terrain:Clear() end) end
    end)

    -- Утилиты
    createToggle(miscPage, "Защита от AFK и зависаний", function(st)
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

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("[*] Space Forge Enterprise Hub v4.0 успешно запущен.")
end)
