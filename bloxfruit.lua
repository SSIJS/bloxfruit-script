-- language: Luau, file: ps99_space_forge_master.lua, target: Roblox / Executor
-- *Master Hub Script for Pet Simulator 99 (Space Forge Update) with advanced automation, raycast farming, and UI framework*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Окружение и Защита от детекта
local CoreGuiConfig = Instance.new("ScreenGui")
CoreGuiConfig.Name = "RobloxNetworkConfig"
CoreGuiConfig.ResetOnSpawn = false
CoreGuiConfig.DisplayOrder = 999999
CoreGuiConfig.Parent = PlayerGui

-- Главное окно (CanvasGroup для плавной анимации скрытия/показа)
local CanvasGroup = Instance.new("CanvasGroup")
CanvasGroup.Size = UDim2.new(0, 750, 0, 450)
CanvasGroup.Position = UDim2.new(0.5, -375, 0.5, -225)
CanvasGroup.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
CanvasGroup.BorderSizePixel = 0
CanvasGroup.GroupTransparency = 0
CanvasGroup.Active = true
CanvasGroup.Draggable = true
CanvasGroup.Parent = CoreGuiConfig

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = CanvasGroup

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 45, 65)
MainStroke.Parent = CanvasGroup

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "  FORGE | PET SIMULATOR 99 [SPACE FORGE MASTER HUB]"
TitleLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = CanvasGroup

-- Контейнер для вкладок/модулей
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Size = UDim2.new(1, -20, 1, -60)
ScrollingContent.Position = UDim2.new(0, 10, 0, 50)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingContent.ScrollBarThickness = 5
ScrollingContent.Parent = CanvasGroup

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)
UIList.Parent = ScrollingContent

local function createToggleSection(titleText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
    btn.Text = "  " .. titleText .. ": [ ВЫКЛ ]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ScrollingContent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(50, 50, 75)
    stroke.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 95)
            btn.Text = "  " .. titleText .. ": [ ВКЛ ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
            btn.Text = "  " .. titleText .. ": [ ВЫКЛ ]"
        end
        callback(active)
    end)
end

-- Модуль 1: Умный Авто-Фарм в Space Forge (Зональный фокус через Raycast / позиционирование)
local autoFarmRunning = false
createToggleSection("Авто-Фарм Зоны (Space Forge Mining)", function(state)
    autoFarmRunning = state
    task.spawn(function()
        while autoFarmRunning do
            task.wait(0.15)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                -- Поиск объектов в текущей зоне фокуса
                local mapFolder = workspace:FindFirstChild("Map")
                if mapFolder then
                    for _, zone in ipairs(mapFolder:GetChildren()) do
                        local breakables = zone:FindFirstChild("Breakables")
                        if breakables then
                            for _, obj in ipairs(breakables:GetChildren()) do
                                if not autoFarmRunning then break end
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                                if targetPart then
                                    root.CFrame = targetPart.CFrame + Vector3.new(0, 4, 0)
                                    task.wait(0.1)
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

-- Модуль 2: Авто-Сбор Лута (Magnet / Drops Teleport)
local autoLootRunning = false
createToggleSection("Авто-Сбор Дропа (Гемы, Монеты, Лутбеги)", function(state)
    autoLootRunning = state
    task.spawn(function()
        while autoLootRunning do
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

-- Модуль 3: Ускоритель FPS / Режим Оптимизации (Ultra FPS Boost)
createToggleSection("Ultra FPS Boost (Отключение текстур и частиц)", function(state)
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

-- Модуль 4: Защита от AFK (Anti-Idle)
createToggleSection("Защита от AFK (Anti-Idle Kick)", function(state)
    task.spawn(function()
        while state do
            task.wait(120)
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

-- Управление видимостью по клавише RightControl
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.RightControl then
        CanvasGroup.Visible = not CanvasGroup.Visible
    end
end)

print("[*] Space Forge Master Hub успешно развернут.")
