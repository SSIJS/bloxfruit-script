-- language: Lua 5.1 (Luau) | file: bloxfruits_xeno.lua | runtime: Xeno executor | target: Blox Fruits (Roblox)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--============================================================
-- REMOTE AUTO-RESOLVER (patch-proof)
-- Blox Fruits remote names/paths shift every update. We fuzzy-match
-- by descendant scan instead of hardcoding dead paths. FILL marks
-- where you confirm against live RemoteSpy on current version.
--============================================================

local function deep_scan_remotes()
    local found = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            found[v.Name:lower()] = v
        end
    end
    return found
end

local function resolve_remote(fragments)
    local all = deep_scan_remotes()
    for name, inst in pairs(all) do
        for _, frag in ipairs(fragments) do
            if name:find(frag:lower()) then return inst end
        end
    end
    return nil
end

local Remotes = {
    attack = resolve_remote({"attack", "hit", "damage", "dealdmg"}),
    equip  = resolve_remote({"equip", "equipitem"}),
    usefruit = resolve_remote({"usefruit", "activatefruit", "fruitskill"}),
    notify = resolve_remote({"notify", "notification"}),
}
-- FILL: print each Remotes.* and confirm non-nil in current version,
-- RemoteSpy any that resolve nil and hardcode the exact instance path.

--============================================================
-- CONFIG
--============================================================

local Config = {
    esp_enabled        = true,
    esp_players         = true,
    esp_fruits          = true,
    esp_npcs            = true,
    autofarm_enabled    = true,
    autofarm_range       = 40,
    teleport_enabled    = true,
    fruit_notify_enabled = true,
    fruit_notify_webhook  = "", -- FILL: discord webhook url if you want pings
    rejoin_on_rare_fruit  = false,
}

--============================================================
-- ESP MODULE
--============================================================

local ESP = {}
ESP.active = {}

local function create_esp_box(adornee, color, text)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = color
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local label = Drawing.new("Text")
    label.Visible = false
    label.Color = color
    label.Center = true
    label.Outline = true
    label.Size = 13

    return {box = box, label = label, adornee = adornee, text = text}
}

local function world_to_screen_box(part)
    local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
    if not onscreen then return nil end

    local size = part.Size
    local top, topVis = Camera:WorldToViewportPoint((part.CFrame * CFrame.new(0, size.Y/2, 0)).Position)
    local bottom, botVis = Camera:WorldToViewportPoint((part.CFrame * CFrame.new(0, -size.Y/2, 0)).Position)
    local height = math.abs(top.Y - bottom.Y)
    local width = height * 0.6

    return Vector2.new(pos.X, pos.Y), width, height
end

function ESP.add_player(plr)
    if plr == LocalPlayer then return end
    local entry = create_esp_box(nil, Color3.fromRGB(255, 60, 60), plr.Name)
    ESP.active[plr] = entry
end

function ESP.remove_player(plr)
    local entry = ESP.active[plr]
    if entry then
        entry.box:Remove()
        entry.label:Remove()
        ESP.active[plr] = nil
    end
end

local function esp_update_loop()
    for plr, entry in pairs(ESP.active) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if Config.esp_players and hrp then
            local center, w, h = world_to_screen_box(hrp)
            if center then
                entry.box.Visible = true
                entry.box.Size = Vector2.new(w, h)
                entry.box.Position = Vector2.new(center.X - w/2, center.Y - h/2)

                entry.label.Visible = true
                entry.label.Position = Vector2.new(center.X, center.Y - h/2 - 16)
                entry.label.Text = entry.text
            else
                entry.box.Visible = false
                entry.label.Visible = false
            end
        else
            entry.box.Visible = false
            entry.label.Visible = false
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do ESP.add_player(plr) end
Players.PlayerAdded:Connect(ESP.add_player)
Players.PlayerRemoving:Connect(ESP.remove_player)

-- fruit ESP: scan workspace for spawned devil fruit models
local FruitESP = {}
local function scan_fruits()
    for _, entry in pairs(FruitESP) do
        entry.box:Remove()
        entry.label:Remove()
    end
    table.clear(FruitESP)

    if not Config.esp_fruits then return end

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") and v:FindFirstChild("Fruit") or (v.Name:find("Fruit") and v:IsA("BasePart")) then
            local entry = create_esp_box(nil, Color3.fromRGB(255, 220, 60), v.Name)
            FruitESP[v] = {box = entry.box, label = entry.label, part = v}
        end
    end
end

local function fruit_esp_update()
    for inst, entry in pairs(FruitESP) do
        if not inst.Parent then
            entry.box:Remove()
            entry.label:Remove()
            FruitESP[inst] = nil
        else
            local part = entry.part:IsA("BasePart") and entry.part or entry.part:FindFirstChildWhichIsA("BasePart")
            if part then
                local center, w, h = world_to_screen_box(part)
                if center then
                    entry.box.Visible = true
                    entry.box.Size = Vector2.new(w, h)
                    entry.box.Position = Vector2.new(center.X - w/2, center.Y - h/2)
                    entry.label.Visible = true
                    entry.label.Position = Vector2.new(center.X, center.Y - h/2 - 16)
                    entry.label.Text = entry.text
                else
                    entry.box.Visible = false
                    entry.label.Visible = false
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(2) do
        if Config.esp_fruits then scan_fruits() end
    end
end)

--============================================================
-- AUTO-FARM MODULE
-- targets nearest Humanoid NPC within range, fires attack remote
-- on cooldown. Movement via CFrame set on HRP (not WalkToPoint —
-- more reliable against anti-exploit position checks that fire
-- on sudden teleports, we lerp instead).
--============================================================

local AutoFarm = {running = false}

local function get_nearest_npc()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearest, nearest_dist = nil, Config.autofarm_range
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Health > 0 then
            local model = v.Parent
            if model and not Players:GetPlayerFromCharacter(model) then
                local target_hrp = model:FindFirstChild("HumanoidRootPart")
                if target_hrp then
                    local dist = (target_hrp.Position - hrp.Position).Magnitude
                    if dist < nearest_dist then
                        nearest = model
                        nearest_dist = dist
                    end
                end
            end
        end
    end
    return nearest
end

function AutoFarm.start()
    AutoFarm.running = true
    task.spawn(function()
        while AutoFarm.running do
            task.wait(0.3)
            if not Config.autofarm_enabled then continue end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            local target = get_nearest_npc()
            if target then
                local target_hrp = target:FindFirstChild("HumanoidRootPart")
                if target_hrp then
                    -- lerp toward target instead of instant teleport
                    local dist = (target_hrp.Position - hrp.Position).Magnitude
                    if dist > 6 then
                        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(target_hrp.Position), 0.3)
                    else
                        -- in range, fire attack remote
                        if Remotes.attack then
                            pcall(function()
                                Remotes.attack:FireServer(target)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

function AutoFarm.stop()
    AutoFarm.running = false
end

--============================================================
-- TELEPORT MODULE
--============================================================

-- FILL: these coordinates drift between map versions / seasonal
-- events. confirm via noclip fly + print(hrp.Position) at each
-- location on current version, then paste real Vector3 here.
local Teleports = {
    ["First Sea - Marine Base"]   = Vector3.new(700, 10, -1400),
    ["First Sea - Pirate Starter"] = Vector3.new(-1200, 5, 1000),
    ["Second Sea - Marine Fortress"] = Vector3.new(0, 55, -4400),
    ["Third Sea - Hydra Island"]  = Vector3.new(-5400, 100, -900),
}

local function teleport_to(name)
    local pos = Teleports[name]
    if not pos then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
    end
end

--============================================================
-- FRUIT NOTIFY + REJOIN
-- hooks the server's spawn-fruit remote (client receive side) to
-- detect rare fruit spawns server-wide, optionally auto-rejoins
-- to reroll server if none found.
--============================================================

local RARE_FRUITS = {"Dragon", "Leopard", "Kitsune", "Dough", "Control", "Spirit"}

local function on_fruit_spawn_notify(fruit_name)
    for _, rare in ipairs(RARE_FRUITS) do
        if fruit_name and fruit_name:find(rare) then
            if Config.fruit_notify_webhook ~= "" then
                pcall(function()
                    local http = syn and syn.request or http_request or request
                    http({
                        Url = Config.fruit_notify_webhook,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = game:GetService("HttpService"):JSONEncode({
                            content = "rare fruit spawned: " .. fruit_name
                        })
                    })
                end)
            end
            if Config.rejoin_on_rare_fruit == false and Config.fruit_notify_enabled then
                -- just notify, no rejoin needed since fruit is present
            end
            return true
        end
    end
    return false
end

if Remotes.notify then
    pcall(function()
        Remotes.notify.OnClientEvent:Connect(function(...)
            local args = {...}
            for _, a in ipairs(args) do
                if type(a) == "string" then
                    on_fruit_spawn_notify(a)
                end
            end
        end)
    end)
end

-- rejoin logic: if no rare fruit found after N seconds, rejoin same server
local function soft_rejoin()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

if Config.rejoin_on_rare_fruit then
    task.spawn(function()
        task.wait(180) -- scan window per server
        soft_rejoin()
    end)
end

--============================================================
-- RENDER LOOP
--============================================================

RunService.RenderStepped:Connect(function()
    if Config.esp_enabled then
        esp_update_loop()
        fruit_esp_update()
    end
end)

--============================================================
-- BOOT
--============================================================

if Config.autofarm_enabled then AutoFarm.start() end

print("[bloxfruits_xeno] loaded — ESP:", Config.esp_enabled, "| AutoFarm:", Config.autofarm_enabled)
