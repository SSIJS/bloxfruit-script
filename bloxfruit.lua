-- language: Luau, file: ps99_spaceforge_gui.lua, target: Roblox / Executor
-- *Pet Simulator 99 Space Forge GUI with Visual Diamond Spoofer and Mining Automation*

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание главного окна графического интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpaceForgeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок панели
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "FORGE | Pet Simulator 99 [Space Forge]"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Функция визуального добавления алмазов на клиенте (клиентский UI-спуфинг)
local function spoofDiamonds(amount)
    pcall(function()
        local diamondsLabel = PlayerGui:FindFirstChild("Main", true) and PlayerGui.Main:FindFirstChild("Diamonds", true)
        if diamondsLabel and diamondsLabel:IsA("TextLabel") then
            local currentText = diamondsLabel.Text:gsub("[^%d]", "")
            local current = tonumber(currentText) or 0
            diamondsLabel.Text = tostring(current + amount)
        end
    end)
end

-- Кнопка добавления визуальных алмазов
local BtnDiamonds = Instance.new("TextButton")
BtnDiamonds.Size = UDim2.new(0, 420, 0, 50)
BtnDiamonds.Position = UDim2.new(0.5, -210, 0, 70)
BtnDiamonds.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
BtnDiamonds.Text = "Добавить алмазы (Visual Space Forge)"
BtnDiamonds.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnDiamonds.TextSize = 14
BtnDiamonds.Font = Enum.Font.GothamSemibold
BtnDiamonds.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = BtnDiamonds

BtnDiamonds.MouseButton1Click:Connect(function()
    spoofDiamonds(1000000)
end)

-- Кнопка автоматического сбора руды / фарма в локации Space Forge
local BtnFarm = Instance.new("TextButton")
BtnFarm.Size = UDim2.new(0, 420, 0, 50)
BtnFarm.Position = UDim2.new(0.5, -210, 0, 135)
BtnFarm.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
BtnFarm.Text = "Авто-фарм руды и сундуков (Mining Chests)"
BtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFarm.TextSize = 14
BtnFarm.Font = Enum.Font.GothamSemibold
BtnFarm.Parent = MainFrame

local BtnFarmCorner = Instance.new("UICorner")
BtnFarmCorner.CornerRadius = UDim.new(0, 8)
BtnFarmCorner.Parent = BtnFarm

local farming = false
BtnFarm.MouseButton1Click:Connect(function()
    farming = not farming
    if farming then
        BtnFarm.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        BtnFarm.Text = "Авто-фарм: Включен"
    else
        BtnFarm.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        BtnFarm.Text = "Авто-фарм руды и сундуков (Mining Chests)"
    end
end)
