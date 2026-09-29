-- NIGHT SHIFT HUB | BLOX FRUITS ARCHITECTURE
-- Чистый UI-каркас на базе Orion Library. Безопасная структура.

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexsoftware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "Night Shift Hub | Blox Fruits", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "NightShiftCenter"
})

-- Создаем основные вкладки, которые обычно нужны для таких задач
local TabFarm = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TabCombat = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TabTeleport = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Наполняем архитектуру элементами управления

TabFarm:AddToggle({
    Name = "Auto Farm Level (Template)",
    Default = false,
    Callback = function(Value)
        print("Auto Farm status: ", Value)
        -- Здесь должна размещаться логика атаки мобов. 
        -- Центр предоставляет только интерфейс, без инжектов.
    end    
})

TabFarm:AddDropdown({
    Name = "Select Weapon",
    Default = "Melee",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Callback = function(Value)
        print("Selected Weapon: ", Value)
    end    
})

TabCombat:AddToggle({
    Name = "Player ESP (Template)",
    Default = false,
    Callback = function(Value)
        print("ESP status: ", Value)
    end    
})

TabTeleport:AddButton({
    Name = "Teleport to Sea 1",
    Callback = function()
        print("Initiating CFrame teleport to Sea 1...")
        -- Локальное изменение координат персонажа
    end    
})

TabTeleport:AddButton({
    Name = "Teleport to Sea 2",
    Callback = function()
        print("Initiating CFrame teleport to Sea 2...")
    end    
})

-- Инициализируем интерфейс
OrionLib:Init()
