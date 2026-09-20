--[[
  Blox Fruits — шаблон скрипта
  Функции: Auto Farm / Fast Attack / Teleport / ESP / Server Hop
  Внимание: нарушает ToS Roblox, риск永久ного бана
]]

-- ========== 1. Базовое окружение ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== 2. Конфиг ==========
local Config = {
    AutoFarmLevel = true,          -- авто-прокачка уровня
    FastAttack = true,             -- быстрая атака
    AutoFarmMastery = false,       -- авто-прокачка мастерства
    BossESP = true,                -- подсветка боссов
    PlayerTracker = false,         -- трекер игроков
    AutoFruitSniper = true,        -- авто-сбор фруктов
    BypassTeleport = true,         -- безопасный телепорт
    ServerHopOnAdmin = true,       -- смена сервера при админе
}

-- ========== 3. Безопасный телепорт (имитация движения) ==========
local function SafeTeleport(position)
    if not Config.BypassTeleport then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        return
    end
    -- Пошаговое перемещение, чтобы античит не кикнул за мгновенный скачок
    local currentPos = LocalPlayer.Character.HumanoidRootPart.Position
    local distance = (position - currentPos).Magnitude
    local steps = math.floor(distance / 10) -- шаг 10 единиц
    for i = 1, steps do
        local newPos = currentPos:Lerp(position, i / steps)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end
end

-- ========== 4. Поиск ближайшего NPC ==========
local function GetNearestNPC(maxDistance)
    local nearest, minDist = nil, maxDistance or 500
    for _, obj in pairs(workspace.Enemies:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    nearest, minDist = obj, dist
                end
            end
        end
    end
    return nearest
end

-- ========== 5. Auto Farm Level ==========
local function AutoFarmLevel()
    if not Config.AutoFarmLevel then return end
    local npc = GetNearestNPC(300)
    if npc then
        SafeTeleport(npc.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
        -- Автоатака
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
        -- Обычный удар
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(
            Instance.new("Animation", LocalPlayer.Character)
        )
    end
end

-- ========== 6. Fast Attack ==========
local function EnableFastAttack()
    if not Config.FastAttack then return end
    -- Уменьшение кулдауна (зависит от конкретного инструмента)
    local function HookTool(tool)
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local oldActivate = tool.Activate
            tool.Activate = function(self)
                oldActivate(self)
                task.wait(0.1) -- минимальный кулдаун
            end
        end
    end
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then HookTool(child) end
    end)
    for _, child in pairs(LocalPlayer.Character:GetChildren()) do
        if child:IsA("Tool") then HookTool(child) end
    end
end

-- ========== 7. Boss ESP / Player Tracker ==========
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "BloxFruitsESP"

local function CreateESP(object, color)
    if object:FindFirstChild("ESPHighlight") then return end
    local highlight = Instance.new("Highlight", espFolder)
    highlight.Name = "ESPHighlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function UpdateESP()
    if Config.BossESP then
        for _, boss in pairs(workspace.Enemies:GetChildren()) do
            if boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                CreateESP(boss, Color3.fromRGB(255, 0, 0)) -- красный
            end
        end
    end
    if Config.PlayerTracker then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateESP(player.Character, Color3.fromRGB(0, 255, 0)) -- зелёный
            end
        end
    end
end

-- ========== 8. Fruit Sniper ==========
local function AutoFruitSniper()
    if not Config.AutoFruitSniper then return end
    workspace.ChildAdded:Connect(function(child)
        if child.Name:match("Fruit") or child:FindFirstChild("Fruit") then
            local fruitPos = child.Position or child:FindFirstChild("Handle").Position
            SafeTeleport(fruitPos)
            task.wait(0.2)
            local proximityPrompt = child:FindFirstChildOfClass("ProximityPrompt")
            if proximityPrompt then
                proximityPrompt:InputHoldBegin()
                task.wait(0.5)
                proximityPrompt:InputHoldEnd()
            end
        end
    end)
end

-- ========== 9. Server Hop ==========
local function ServerHop()
    local url = "https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if success and response.data then
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(
                    game.PlaceId, server.id, LocalPlayer
                )
                return
            end
        end
    end
end

-- ========== 10. Главный цикл ==========
RunService.Heartbeat:Connect(function()
    pcall(AutoFarmLevel)
    pcall(UpdateESP)
end)

-- Инициализация
EnableFastAttack()
AutoFruitSniper()

-- Детект админа (нужны доп. проверки)
Players.PlayerAdded:Connect(function(player)
    if Config.ServerHopOnAdmin and player.UserId == 1 then -- пример ID
        ServerHop()
    end
end)

print("[Blox Fruits Script] Загружен. Используй осторожно.")
