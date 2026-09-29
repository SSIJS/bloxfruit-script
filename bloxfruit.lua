-- ==========================================
-- BLOX FRUITS HUB BASE ENGINE
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- Главный эндпоинт Blox Fruits (через него идет 90% всех действий)
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Глобальная таблица настроек
getgenv().BloxHub = {
    AutoFarm = false,
    AutoStats = false,
    FastAttack = false,
    
    SelectWeapon = "Melee", -- "Melee" / "Sword" / "Blox Fruit"
    StatPoint = "Melee",    -- "Melee" / "Defense" / "Sword" / "Gun" / "Demon Fruit"
}

-- ==========================================
-- 1. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==========================================
local Utils = {}

-- Универсальный вызов команд Blox Fruits
function Utils:InvokeComm(...)
    return CommF:InvokeServer(...)
end

-- Плавное перемещение (Tween) для обхода античита
function Utils:TweenTo(targetCFrame, speed)
    speed = speed or 300
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local distance = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)

    local tween = TweenService:Create(char.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

-- Автоматическое взятие оружия в руки
function Utils:EquipWeapon(weaponType)
    local backpack = LocalPlayer.Backpack
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == weaponType then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

-- Noclip (прохождение сквозь стены во время полета)
RunService.Stepped:Connect(function()
    if getgenv().BloxHub.AutoFarm and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ==========================================
-- 2. МОДУЛЬ: FAST ATTACK (Быстрая атака)
-- ==========================================
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().BloxHub.FastAttack then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(500, 500))
            end)
        end
    end
end)

-- ==========================================
-- 3. МОДУЛЬ: AUTO STATS (Авто-прокачка)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().BloxHub.AutoStats then
            pcall(function()
                -- Команда серверу на добавление очка характеристик
                Utils:InvokeComm("AddPoint", getgenv().BloxHub.StatPoint, 1)
            end)
        end
    end
end)

-- ==========================================
-- 4. МОДУЛЬ: AUTO FARM LEVEL
-- ==========================================
local AutoFarm = {}

-- База данных квестов (для примера взяты начальные уровни Первого Моря)
function AutoFarm:GetQuestData()
    local level = LocalPlayer.Data.Level.Value

    if level >= 1 and level < 10 then
        return "BanditQuest1", 1, "Bandit", CFrame.new(1059, 16, 1549)
    elseif level >= 10 and level < 15 then
        return "JungleQuest", 1, "Monkey", CFrame.new(-1598, 36, 153)
    elseif level >= 15 and level < 30 then
        return "JungleQuest", 2, "Gorilla", CFrame.new(-1598, 36, 153)
    end
    
    return nil
end

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().BloxHub.AutoFarm then
            pcall(function()
                local questName, questLevel, mobName, questCFrame = AutoFarm:GetQuestData()
                
                if not questName then return end

                -- Проверяем, взят ли квест прямо сейчас
                local hasQuest = LocalPlayer.PlayerGui.Main.Quest.Visible

                if not hasQuest then
                    -- Летим к NPC и берем квест через CommF_
                    Utils:TweenTo(questCFrame)
                    if (LocalPlayer.Character.HumanoidRootPart.Position - questCFrame.Position).Magnitude < 15 then
                        Utils:InvokeComm("StartQuest", questName, questLevel)
                    end
                else
                    -- Ищем нужного моба
                    local targetMob = nil
                    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
                        if mob.Name == mobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                            targetMob = mob
                            break
                        end
                    end

                    if targetMob then
                        -- Зависаем на 8-10 studs выше моба, чтобы он не мог попасть по нам
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0)
                        Utils:EquipWeapon(getgenv().BloxHub.SelectWeapon)
                        getgenv().BloxHub.FastAttack = true
                    else
                        -- Если мобов рядом нет, летим к их точке спавна
                        Utils:TweenTo(questCFrame * CFrame.new(0, 30, 0))
                    end
                end
            end)
        end
    end
end)

print("[BloxHub] Ядро под Blox Fruits успешно запущено!")

-- ==========================================
-- УПРАВЛЕНИЕ (Для привязки к твоему UI):
-- ==========================================
-- getgenv().BloxHub.AutoFarm = true   -- Включит фарм
-- getgenv().BloxHub.AutoStats = true  -- Включит авто-статы
-- getgenv().BloxHub.StatPoint = "Melee" -- Куда вливать очки
