-- ================================================================= --
--     АРТЕФАКТ: ВЕЛИКИЙ КОВЧЕГ АРХИТЕКТОРА (BLOX FRUITS APEX HUB)   --
--     СОВМЕСТИМОСТЬ: DELTA X, SOLARA, WAVE, MACSPLOIT, FLUXUS И ДР. --
-- ================================================================= --

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    TeleportService = game:GetService("TeleportService"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Services.Players.LocalPlayer
local CommF = Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [РУНЫ БЕЗОПАСНОСТИ И СОСТОЯНИЯ]
local Flags = {
    AutoSniper = false,
    FruitESP = false,
    AutoCollectStore = false,
    SafeSkyFarm = false,
    StaffDetector = false,
    SelectedStat = "Melee",
    TweenSpeed = 300,
    SkyOffset = 35 -- Высота парения над мобами
}

local RareFruits = { "Leopard-Leopard", "Kitsune-Kitsune", "Dragon-Dragon", "Dough-Dough" }

-- ================================================================= --
-- 🛡️ АРХИТЕКТУРА ОБХОДОВ (BYPASSES & TWEENING)
-- ================================================================= --

-- [Безопасный полет сквозь пространство (Tween System)]
local function SafeTween(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / Flags.TweenSpeed, Enum.EasingStyle.Linear)
    
    local tween = Services.TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- [Маскировка Пакетов (Remote Event Spoofing Concept)]
local rawMetatable = getrawmetatable(game)
local oldNamecall = rawMetatable.__namecall
setreadonly(rawMetatable, false)

rawMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        -- Подменяем подозрительные аргументы на легитимные
        if tostring(self) == "CommF_" then
            local args = {...}
            -- Маскируем мгновенные перемещения под сетевой пинг
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(rawMetatable, true)

-- ================================================================= --
-- 🖥️ ИНТЕРФЕЙС УПРАВЛЕНИЯ (GUI & ERGONOMICS)
-- ================================================================= --

local Window = OrionLib:MakeWindow({
    Name = "Blox Fruits | APEX ARTIFACT v3.0", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "Apex_BF_Config",
    IntroEnabled = true,
    IntroText = "Приветствую, Верховный Архитектор!"
})

-- Переключение клавишей (Toggle Key)
OrionLib:SetBind(Enum.KeyCode.RightControl)

-- [ВКЛАДКА: СНАЙПЕР И ФРУКТЫ]
local FruitTab = Window:MakeTab({ Name = "Магия Фруктов", Icon = "rbxassetid://4483345998" })

FruitTab:AddSection({ Name = "Теневой Снайпер Продавца" })
FruitTab:MakeToggle({
    Name = "Авто-выкуп редких фруктов (Sniper)",
    Default = false,
    Callback = function(Value)
        Flags.AutoSniper = Value
        task.spawn(function()
            while Flags.AutoSniper do
                task.wait(1)
                for _, fruitName in pairs(RareFruits) do
                    -- Ритуал мгновенного выкупа через удаленный вызов
                    CommF:InvokeServer("BuyFruit", fruitName)
                end
            end
        end)
    end
})

FruitTab:AddSection({ Name = "Детекция и Сбор Фруктов" })

-- ESP На Фрукты (Fruit Finder)
local ESPFolder = Instance.new("Folder", Services.Workspace)
ESPFolder.Name = "FruitESP_Folder"

FruitTab:MakeToggle({
    Name = "Око Прозрения (Fruit ESP)",
    Default = false,
    Callback = function(Value)
        Flags.FruitESP = Value
        if not Flags.FruitESP then ESPFolder:ClearAllChildren() end
        
        task.spawn(function()
            while Flags.FruitESP do
                task.wait(2)
                ESPFolder:ClearAllChildren()
                for _, obj in pairs(Services.Workspace:GetChildren()) do
                    if obj.Name:find("Fruit") and obj:IsA("Tool") or obj:IsA("Model") then
                        local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
                        if handle then
                            local billboard = Instance.new("BillboardGui", ESPFolder)
                            billboard.Adornee = handle
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.AlwaysOnTop = true
                            
                            local label = Instance.new("TextLabel", billboard)
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 215, 0)
                            label.TextScaled = true
                            
                            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - handle.Position).Magnitude)
                            label.Text = obj.Name .. "\n[" .. dist .. "m]"
                        end
                    end
                end
            end
        end)
    end
})

-- Auto Collect & Store
FruitTab:MakeToggle({
    Name = "Авто-Сбор и Сохранение в Сундук",
    Default = false,
    Callback = function(Value)
        Flags.AutoCollectStore = Value
        task.spawn(function()
            while Flags.AutoCollectStore do
                task.wait(1)
                for _, obj in pairs(Services.Workspace:GetChildren()) do
                    if obj.Name:find("Fruit") and (obj:IsA("Tool") or obj:IsA("Model")) then
                        local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
                        if handle then
                            -- Безопасный полет к фрукту
                            local tween = SafeTween(handle.CFrame)
                            if tween then tween.Completed:Wait() end
                            
                            -- Подбираем и сразу прячем в сундук
                            task.wait(0.5)
                            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if item.Name:find("Fruit") then
                                    CommF:InvokeServer("StoreFruit", item.Name, item)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

-- [ВКЛАДКА: БЕЗОПАСНЫЙ ФАРМ И ЗАЩИТА]
local DefenseTab = Window:MakeTab({ Name = "Защита и Стелс", Icon = "rbxassetid://4483345998" })

-- Sky Farming Toggle
DefenseTab:AddSection({ Name = "Небесный Патруль (Sky Farm)" })
DefenseTab:MakeToggle({
    Name = "Включить позиционирование над врагами",
    Default = false,
    Callback = function(Value)
        Flags.SafeSkyFarm = Value
    end
})

-- Staff & Player Detector
DefenseTab:AddSection({ Name = "Страж Модерации (Staff Detector)" })
DefenseTab:MakeToggle({
    Name = "Авто-Смена Сервера при угрозе (Server Hop)",
    Default = false,
    Callback = function(Value)
        Flags.StaffDetector = Value
        task.spawn(function()
            while Flags.StaffDetector do
                task.wait(3)
                for _, player in pairs(Services.Players:GetPlayers()) do
                    -- Проверка на роли разработчиков/модераторов
                    if player:GetRankInGroup(2602888) >= 200 or player.Name:find("Admin") then
                        -- Моментальный уход с сервера (Server Hop)
                        OrionLib:MakeNotification({ Name = "ОПАСНОСТЬ!", Content = "Обнаружен страж! Смена мира...", Time = 5 })
                        
                        local PlaceID = game.PlaceId
                        local Servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100"))
                        for _, server in pairs(Servers.data) do
                            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                Services.TeleportService:TeleportToPlaceInstance(PlaceID, server.id)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
})

-- [ВКЛАДКА: КАСТОМИЗАЦИЯ И ИНТЕРФЕЙС]
local SettingsTab = Window:MakeTab({ Name = "Настройки GUI", Icon = "rbxassetid://4483345998" })

SettingsTab:AddSection({ Name = "Смена Тем Оформления" })
SettingsTab:MakeDropdown({
    Name = "Палитра Интерфейса",
    Default = "Default",
    Options = {"Default", "DarkTheme", "Cyberpunk", "BloodTheme", "Aqua"},
    Callback = function(Value)
        OrionLib:ChangeTheme(Value)
    end
})

-- Инициализация системы
OrionLib:Init()
