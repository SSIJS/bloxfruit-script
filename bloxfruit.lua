-- language: Luau, file: ps99_ultimate_cyber_hub.lua, target: Roblox / Executor
-- *Pet Simulator 99 - Cyber Enterprise Master Hub v3.0*

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
    if PlayerGui:FindFirstChild("CyberHub_Loader") then PlayerGui.CyberHub_Loader:Destroy() end
end)

-- =========================================================================
-- ЧАСТЬ 1: КИБЕРПАНК-ЛОАДЕР
-- =========================================================================
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "CyberHub_Loader"
LoaderGui.ResetOnSpawn = false
LoaderGui.DisplayOrder = 999999
LoaderGui.Parent = PlayerGui

local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 360, 0, 190)
LoaderFrame.Position = UDim2.new(0.5, -180, 0.5, -95)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
LoaderFrame.BorderSizePixel = 0
LoaderFrame.BackgroundTransparency = 1
LoaderFrame.Parent = LoaderGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 12)
LoaderCorner.Parent = LoaderFrame

local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Thickness = 1.5
LoaderStroke.Color = Color3.fromRGB(0, 255, 200)
LoaderStroke.Transparency = 0.5
LoaderStroke.Parent = LoaderFrame

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 30)
LoaderTitle.Position = UDim2.new(0, 0, 0.15, 0)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 16
LoaderTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
LoaderTitle.Text = "CYBERPARK ENTERPRISE v3.0"
LoaderTitle.Parent = LoaderFrame

local LoaderStatus = Instance.new("TextLabel")
LoaderStatus.Size = UDim2.new(1, -40, 0, 20)
LoaderStatus.Position = UDim2.new(0, 20, 0.45, 0)
LoaderStatus.BackgroundTransparency = 1
LoaderStatus.Font = Enum.Font.GothamMedium
LoaderStatus.TextSize = 12
LoaderStatus.TextColor3 = Color3.fromRGB(180, 180, 200)
LoaderStatus.Text = "Инициализация защищенных модулей..."
LoaderStatus.Parent = LoaderFrame

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0, 300, 0, 4)
BarBg.Position = UDim2.new(0.5, -150, 0.75, 0)
BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
BarBg.BorderSizePixel = 0
BarBg.Parent = LoaderFrame

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(0, 4)
BarBgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg

local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(0, 4)
BarFillCorner.Parent = BarFill

TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
task.wait(0.5)

TweenService:Create(BarFill, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.wait(1.3)

LoaderStatus.Text = "Загрузка интерфейса завершена."
task.wait(0.4)
TweenService:Create(LoaderFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
task.wait(0.3)
LoaderGui:Destroy()

-- =========================================================================
-- ЧАСТЬ 2: ГЛАВНОЕ ОКНО И УПРАВЛЕНИЕ (СВЕРНУТЬ / ЗАКРЫТЬ)
-- =========================================================================
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "CyberHub_Main"
MainGui.ResetOnSpawn = false
MainGui.DisplayOrder = 999999
MainGui.Parent = PlayerGui

-- Верхняя ватермарка (FPS / Пинг / Ник)
local Watermark = Instance.new("Frame")
Watermark.Size = UDim2.new(0, 260, 0, 32)
Watermark.Position = UDim2.new(1, -275, 0, 15)
Watermark.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Watermark.BorderSizePixel = 0
Watermark.Parent = MainGui

local WmCorner = Instance.new("UICorner")
WmCorner.CornerRadius = UDim.new(0, 6)
WmCorner.Parent = Watermark

local WmStroke = Instance.new("UIStroke")
WmStroke.Color = Color3.fromRGB(0, 255, 200)
WmStroke.Transparency = 0.4
WmStroke.Parent = Watermark

local WmText = Instance.new("TextLabel")
WmText.Size = UDim2.new(1, 0, 1, 0)
WmText.BackgroundTransparency = 1
WmText.Font = Enum.Font.GothamBold
WmText.TextSize = 11
WmText.TextColor3 = Color3.fromRGB(220, 240, 255)
WmText.Parent = Watermark

-- Расчет FPS и Пинга в реальном времени
local fCount, lTime, curFps = 0, tick(), 60
RunService.RenderStepped:Connect(function(dt)
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
    WmText.Text = string.format("USER: %s | %d FPS | %dms", LocalPlayer.Name, curFps, ping)
end)

-- Основное окно интерфейса
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 880, 0, 520)
MainFrame.Position = UDim2.new(0.5, -440, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = MainGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Шапка окна
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 400, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "PS99 : CYBERPARK ENTERPRISE HUB"
TitleLabel.Parent = TopBar

-- Кнопка ЗАКРЫТЬ ("X")
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainGui:Destroy()
end)

-- Кнопка СВЕРНУТЬ ("_")
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
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
        MainFrame.Size = UDim2.new(0, 880, 0, 45)
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 880, 0, 520)
        MinimizeBtn.Text = "—"
    end
end)

-- Контейнер вкладок слева
local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(0, 200, 1, -60)
TabScroll.Position = UDim2.new(0, 10, 0, 52)
TabScroll.BackgroundTransparency = 1
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
TabScroll.ScrollBarThickness = 2
TabScroll.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabScroll

-- Контейнер страниц справа
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -230, 1, -60)
ContentContainer.Position = UDim2.new(0, 220, 0, 52)
ContentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local CCurve = Instance.new("UICorner")
CCurve.CornerRadius = UDim.new(0, 8)
CCurve.Parent = ContentContainer

local pages = {}
local function createPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name .. "Page"
    p.Size = UDim2.new(1, -10, 1, -10)
    p.Position = UDim2.new(0, 5, 0, 5)
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0, 0, 0, 1100)
    p.ScrollBarThickness = 3
    p.Visible = false
    p.Parent = ContentContainer

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 8)
    l.Parent = p

    pages[name] = p
    return p
end

local farmPage = createPage("Farm")
local petsPage = createPage("Pets")
local eggsPage = createPage("Eggs")
local economyPage = createPage("Economy")
local tpPage = createPage("Teleport")
local visualPage = createPage("Visual")
local miscPage = createPage("Misc")

-- Функция создания переключателей (Toggle)
local function createToggle(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = "   ⚡ " .. text .. " [ ВЫКЛ ]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = page

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(45, 45, 65)
    bs.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 140)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "   ⚡ " .. text .. " [ ВКЛ ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
            btn.Text = "   ⚡ " .. text .. " [ ВЫКЛ ]"
        end
        callback(state)
    end)
end

-- Функция создания обычных кнопок действия
local function createButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Text = "   🔹 " .. text
    btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = page

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback()
    end)
end

-- Создание кнопок вкладок слева
local function createTab(name, targetPage)
    local tBtn = Instance.new("TextButton")
    tBtn.Size = UDim2.new(1, 0, 0, 40)
    tBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    tBtn.Text = "   " .. name
    tBtn.TextColor3 = Color3.fromRGB(170, 170, 200)
    tBtn.TextSize = 12
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextXAlignment = Enum.TextXAlignment.Left
    tBtn.Parent = TabScroll

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 6)
    tc.Parent = tBtn

    tBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        targetPage.Visible = true
    end)
end

createTab("Авто-Фарм", farmPage)
createTabButton = createTab -- alias
createTab("Питомцы", petsPage)
createTab("Яйца и Открытие", eggsPage)
createTab("Экономика", economyPage)
createTab("Телепортация", tpPage)
createTab("Визуал и FPS", visualPage)
createTab("Утилиты и AFK", miscPage)

farmPage.Visible = true

-- =========================================================================
-- ЧАСТЬ 3: РЕАЛИЗАЦИЯ ФУНКЦИОНАЛА
-- =========================================================================

-- Очередь сетевых запросов для защиты от крашей
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

-- 1. ФАРМ
local farmActive = false
createToggle(farmPage, "Умный авто-фарм монет и сундуков", function(st)
    farmActive = st
    task.spawn(function()
        while farmActive do
            task.wait(0.1)
            pcall(function()
                local map = workspace:FindFirstChild("Map")
                if map then
                    for _, zone in ipairs(map:GetChildren()) do
                        local breakables = zone:FindFirstChild("Breakables")
                        if breakables then
                            for i, obj in ipairs(breakables:GetChildren()) do
                                if not farmActive then break end
                                table.insert(NetQueue, {Name = "Breakables_PetAttack", Args = {"Pet_" .. (i%6+1), obj.Name}})
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

local autoLoot = false
createToggle(farmPage, "Авто-сбор лута и бриллиантов", function(st)
    autoLoot = st
    task.spawn(function()
        while autoLoot do
            task.wait(0.2)
            pcall(function()
                local drops = workspace:FindFirstChild("Drops")
                local char = LocalPlayer.Character
                if drops and char and char:FindFirstChild("HumanoidRootPart") then
                    local rootPos = char.HumanoidRootPart.CFrame
                    for _, drop in ipairs(drops:GetChildren()) do
                        local p = drop:IsA("Model") and (drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")) or drop
                        if p and p:IsA("BasePart") then p.CFrame = rootPos end
                    end
                end
            end)
        end
    end)
end)

-- 2. ПИТОМЦЫ
createToggle(petsPage, "Авто-экипировка лучших питомцев", function(st)
    task.spawn(function()
        while st do
            task.wait(5)
            pcall(function()
                table.insert(NetQueue, {Name = "Pets_EquipBest", Args = {}})
            end)
        end
    end)
end)

createButton(petsPage, "Конвертировать всех питомцев в Золото", function()
    pcall(function()
        table.insert(NetQueue, {Name = "GoldenPets_ConvertAll", Args = {}})
    end)
end)

createButton(petsPage, "Конвертировать всех питомцев в Радугу", function()
    pcall(function()
        table.insert(NetQueue, {Name = "RainbowPets_ConvertAll", Args = {}})
    end)
end)

-- 3. ЯЙЦА
createToggle(eggsPage, "Мгновенное открытие яиц (Быстро)", function(st)
    pcall(function()
        local eggGui = PlayerGui:FindFirstChild("EggOpeningGui", true)
        if eggGui then eggGui.Enabled = not st end
    end)
end)

createToggle(eggsPage, "Авто-открытие выбранного яйца (x99)", function(st)
    task.spawn(function()
        while st do
            task.wait(0.5)
            pcall(function()
                table.insert(NetQueue, {Name = "Eggs_Open", Args = {"Spawn Egg", 99}})
            end)
        end
    end)
end)

-- 4. ЭКОНОМИКА
createToggle(economyPage, "Снайпер дешевых стендов (Booths)", function(st)
    task.spawn(function()
        while st do
            task.wait(0.4)
            pcall(function()
                local plaza = workspace:FindFirstChild("TradingPlaza")
                local booths = plaza and plaza:FindFirstChild("Booths")
                if booths then
                    for _, b in ipairs(booths:GetChildren()) do
                        local list = b:FindFirstChild("Listing")
                        if list and list.Value then
                            table.insert(NetQueue, {Name = "Booths_PurchaseItem", Args = {b.Name, list.Value}})
                        end
                    end
                end
            end)
        end
    end)
end)

-- 5. ТЕЛЕПОРТАЦИЯ
createButton(tpPage, "Телепорт в Торговую Плазу (Trading Plaza)", function()
    pcall(function()
        TeleportService:Teleport(8737899170, LocalPlayer)
    end)
end)

createButton(tpPage, "Телепорт на Спавн (World 1)", function()
    pcall(function()
        TeleportService:Teleport(8737860132, LocalPlayer)
    end)
end)

createButton(tpPage, "Телепорт в Зал Ожидания / Подарочные зоны", function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end)
end)

-- 6. ВИЗУАЛ И FPS
createToggle(visualPage, "Режим черного экрана (Максимальный FPS)", function(st)
    RunService:Set3dRenderingEnabled(not st)
    if st then
        pcall(function() workspace.Terrain:Clear() end)
    end
end)

createToggle(visualPage, "Удалить анимации и FX других игроков", function(st)
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, v in ipairs(p.Character:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = not st end
                end
            end
        end
    end)
end)

-- 7. УТИЛИТЫ И AFK
createToggle(miscPage, "Надежная защита от AFK-кика", function(st)
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

createButton(miscPage, "Снять все эффекты и дебаффы", function()
    pcall(function()
        table.insert(NetQueue, {Name = "Player_ClearEffects", Args = {}})
    end)
end)

-- Горячая клавиша для скрытия по RightControl
UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[*] Cyberpunk Enterprise Hub v3.0 успешно запущен и готов к работе.")
