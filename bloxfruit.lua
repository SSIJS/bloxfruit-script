-- language: Luau, file: ps99_advanced_forge.lua, target: Roblox / Executor
-- *Advanced Pet Simulator 99 Space Forge GUI with complete utility modules*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание главного окна
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaceForgeAdvancedGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 420)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "FORGE | PS99 [Space Forge Master Hub]"
Title.TextColor3 = Color3.fromRGB(0, 240, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Контейнер для кнопок
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

-- Функция создания красивых кнопок
local function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = ScrollingFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. Визуальная накрутка алмазов
createButton("Визуальные алмазы (1,000,000)", function()
    pcall(function()
        local diamondsLabel = PlayerGui:FindFirstChild("Main", true) and PlayerGui.Main:FindFirstChild("Diamonds", true)
        if diamondsLabel and diamondsLabel:IsA("TextLabel") then
            local current = tonumber(diamondsLabel.Text:gsub("[^%d]", "")) or 0
            diamondsLabel.Text = tostring(current + 1000000)
        end
    end)
end)

-- 2. Авто-фарм руды и Mining Chests (Телепортация к объектам Space Forge)
local autoMining = false
createButton("Авто-фарм руды (Mining Chests)", function()
    autoMining = not autoMining
    task.spawn(function()
        while autoMining do
            task.wait(0.5)
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("ore") or obj.Name:lower():find("chest") or obj.Name:lower():find("crystal") then
                        if obj:IsA("Model") and obj.PrimaryPart then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                            break
                        elseif obj:IsA("BasePart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                            break
                        end
                    end
                end
            end)
        end
    end)
end)

-- 3. Авто-клик по сундукам и блокам
local autoClicker = false
createButton("Авто-кликер по объектам", function()
    autoClicker = not autoClicker
    task.spawn(function()
        while autoClicker do
            task.wait(0.1)
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end)
end)

-- 4. Сбор всех предметов на карте (Item Loot Collect)
createButton("Сбор выпавших предметов (Loot)", function()
    pcall(function()
        for _, item in ipairs(workspace:GetDescendants()) do
            if item.Name:lower():find("coin") or item.Name:lower():find("diamond") or item.Name:lower():find("loot") then
                if item:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    item.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end)
end)

-- 5. Увеличение скорости передвижения (WalkSpeed)
local speedEnabled = false
createButton("Ускорить персонажа (WalkSpeed x2)", function()
    speedEnabled = not speedEnabled
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedEnabled and 32 or 16
        end
    end)
end)

-- 6. Обход анти-афк (Anti-AFK)
createButton("Включить Анти-АФК", function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)
end)
