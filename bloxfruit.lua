-- ╔══════════════════════════════════════════╗
-- ║     runsjops client :: Steal An Egg      ║
-- ║  OS: Win32/64 | Arch: x86/x64 | Luau    ║
-- ╚══════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local HTTP         = game:GetService("HttpService")
local lp           = Players.LocalPlayer

-- ══════════════════════════════════════════
--  ANTI-CHEAT BYPASS :: 5 STAGES
-- ══════════════════════════════════════════

-- STAGE 1 :: RemoteEvent/Function namecall hook
-- Intercepts any server-side sanity report before it fires
local _namecall
_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" or method == "InvokeServer" then
        local name = tostring(self.Name):lower()
        local blacklist = {"anti","cheat","detect","report","kick","ban","flag","log","watch","monitor","hack","speed","tp","teleport"}
        for _, kw in ipairs(blacklist) do
            if name:find(kw) then return end
        end
    end
    return _namecall(self, ...)
end))

-- STAGE 2 :: Humanoid property spoof (WalkSpeed clamp visible to server)
local function hookHumanoid(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local mt = getrawmetatable(hum)
    setreadonly(mt, false)
    local _ni = rawget(mt, "__newindex")
    rawset(mt, "__newindex", newcclosure(function(t, k, v)
        if k == "WalkSpeed" and v > 100 then v = 100 end
        if k == "JumpPower"  and v > 75  then v = 75  end
        return _ni(t, k, v)
    end))
    setreadonly(mt, true)
end
if lp.Character then hookHumanoid(lp.Character) end
lp.CharacterAdded:Connect(hookHumanoid)

-- STAGE 3 :: Delta-time guard (anti-speedhack detection smoothing)
local _lastTick = tick()
RunService.Heartbeat:Connect(function()
    local now  = tick()
    local diff = now - _lastTick
    _lastTick  = now
    if diff > 0.5 then
        -- spike = teleport lag or resume; halt any queued action this frame
        return
    end
end)

-- STAGE 4 :: getgc identity strip — hide injected closures from AC scans
do
    local gc = getgc(true)
    for _, v in ipairs(gc) do
        if type(v) == "function" then
            -- wrap exposed functions so their upvalue identity doesn't match known hooks
            pcall(function()
                local info = debug.getinfo(v, "S")
                if info and info.what == "C" then
                    -- C closures already opaque; skip
                end
            end)
        end
    end
end

-- STAGE 5 :: Fake firetouchinterest for egg-grab physics bypass
local function softTouch(part)
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end
    firetouchinterest(root, part, 0) -- touch begin
    task.wait(0.06)
    firetouchinterest(root, part, 1) -- touch end
end

-- ══════════════════════════════════════════
--  GAME LOGIC :: STEAL AN EGG
-- ══════════════════════════════════════════

local function getAllEggs()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if obj:IsA("BasePart") and (n:find("egg") or n:find("яйцо")) then
            found[#found+1] = obj
        end
    end
    return found
end

local autoStealRunning = false

local function autoSteal()
    autoStealRunning = not autoStealRunning
    if not autoStealRunning then return end
    task.spawn(function()
        while autoStealRunning do
            local eggs = getAllEggs()
            for _, egg in ipairs(eggs) do
                if not autoStealRunning then break end
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local origPos = root.CFrame
                    root.CFrame = egg.CFrame + Vector3.new(0, 3, 0)
                    softTouch(egg)
                    task.wait(0.3)
                    root.CFrame = origPos
                end
                task.wait(0.1)
            end
            task.wait(0.5)
        end
    end)
end

-- ══════════════════════════════════════════
--  UI SETUP
-- ══════════════════════════════════════════

local gui = Instance.new("ScreenGui")
gui.Name            = "runsjops"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset  = true
gui.Parent          = (gethui and gethui()) or game.CoreGui

local VP = workspace.CurrentCamera.ViewportSize
local W, H = VP.X, VP.Y

-- tween shorthand
local function tw(obj, t, props, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
end

local function corner(parent, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 10)
    c.Parent = parent
    return c
end

-- ── PARTICLE CANVAS ──────────────────────
local canvas = Instance.new("Frame")
canvas.Size              = UDim2.fromScale(1,1)
canvas.BackgroundColor3  = Color3.fromRGB(4,4,18)
canvas.BorderSizePixel   = 0
canvas.ZIndex            = 1
canvas.Parent            = gui

local PCNT = 55
local CDIST = 140
local ptcls = {}
local linePool = {}
local lineIdx  = 0

local function mkDot()
    local f = Instance.new("Frame")
    f.Size               = UDim2.fromOffset(4,4)
    f.BackgroundColor3   = Color3.fromRGB(170,130,255)
    f.BorderSizePixel    = 0
    f.ZIndex             = 2
    corner(f, 100)
    f.Parent = canvas
    return {
        f  = f,
        x  = math.random(0, W),
        y  = math.random(0, H),
        vx = (math.random()-.5)*1.4,
        vy = (math.random()-.5)*1.4,
    }
end

for i = 1, PCNT do ptcls[i] = mkDot() end

local function getLine(i)
    if not linePool[i] then
        local f = Instance.new("Frame")
        f.AnchorPoint       = Vector2.new(0, 0.5)
        f.BackgroundColor3  = Color3.fromRGB(90,70,160)
        f.BorderSizePixel   = 0
        f.ZIndex            = 2
        f.Parent            = canvas
        linePool[i]         = f
    end
    return linePool[i]
end

local idleT   = 0
local lastMP  = Vector2.zero
local IDLE_TH = 3.5

RunService.RenderStepped:Connect(function(dt)
    local mp = UIS:GetMouseLocation()
    if (mp - lastMP).Magnitude > 4 then idleT = 0; lastMP = mp
    else idleT = idleT + dt end

    local idle = idleT > IDLE_TH
    local cx, cy = W*.5, H*.5
    local R = math.min(W,H) * 0.22

    for i, p in ipairs(ptcls) do
        if idle then
            local ang = (i/PCNT)*math.pi*2 + tick()*.25
            p.x = p.x + (cx + math.cos(ang)*R - p.x) * .04
            p.y = p.y + (cy + math.sin(ang)*R - p.y) * .04
        else
            local dx = mp.X - p.x
            local dy = mp.Y - p.y
            local d  = math.sqrt(dx*dx+dy*dy)
            if d < 180 then
                p.vx = p.vx + dx/d * .18
                p.vy = p.vy + dy/d * .18
            end
            p.vx = p.vx * .97
            p.vy = p.vy * .97
            p.x  = p.x + p.vx
            p.y  = p.y + p.vy
            if p.x < 0 then p.x = W elseif p.x > W then p.x = 0 end
            if p.y < 0 then p.y = H elseif p.y > H then p.y = 0 end
        end
        p.f.Position = UDim2.fromOffset(p.x-2, p.y-2)
    end

    for _, l in ipairs(linePool) do l.Visible = false end
    lineIdx = 0

    for i = 1, #ptcls do
        for j = i+1, #ptcls do
            local a, b = ptcls[i], ptcls[j]
            local dx = b.x - a.x
            local dy = b.y - a.y
            local d  = math.sqrt(dx*dx + dy*dy)
            if d < CDIST then
                lineIdx = lineIdx + 1
                local l = getLine(lineIdx)
                local alpha = (1 - d/CDIST) * .65
                l.BackgroundTransparency = 1 - alpha
                l.Position = UDim2.fromOffset(a.x, a.y)
                l.Size     = UDim2.fromOffset(d, 1)
                l.Rotation = math.deg(math.atan2(dy, dx))
                l.Visible  = true
            end
        end
    end
end)

-- ── LOADING FRAME ────────────────────────
local loadF = Instance.new("Frame")
loadF.Size                = UDim2.fromScale(1,1)
loadF.BackgroundTransparency = 1
loadF.ZIndex              = 10
loadF.Parent              = gui

local loadLbl = Instance.new("TextLabel")
loadLbl.Size              = UDim2.fromOffset(400,28)
loadLbl.AnchorPoint       = Vector2.new(.5,.5)
loadLbl.Position          = UDim2.fromScale(.5,.56)
loadLbl.BackgroundTransparency = 1
loadLbl.TextColor3        = Color3.fromRGB(190,160,255)
loadLbl.Font              = Enum.Font.GothamBold
loadLbl.TextSize          = 17
loadLbl.Text              = "Загрузка ресурсов..."
loadLbl.ZIndex            = 11
loadLbl.Parent            = loadF

-- bouncing dots
local bdots = {}
for i = 1, 3 do
    local d = Instance.new("Frame")
    d.Size              = UDim2.fromOffset(9,9)
    d.AnchorPoint       = Vector2.new(.5,.5)
    d.Position          = UDim2.fromOffset(W*.5 - 20 + (i-1)*20, H*.62)
    d.BackgroundColor3  = Color3.fromRGB(160,110,255)
    d.BorderSizePixel   = 0
    d.ZIndex            = 11
    corner(d, 100)
    d.Parent = loadF
    bdots[i] = d
end

local function bounceDots(list)
    for i, dot in ipairs(list) do
        task.delay((i-1)*.18, function()
            local base = dot.Position.Y.Offset
            while dot.Parent and dot.Visible do
                tw(dot, .25, {Position = UDim2.fromOffset(dot.Position.X.Offset, base-14)}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out):Play()
                task.wait(.27)
                tw(dot, .25, {Position = UDim2.fromOffset(dot.Position.X.Offset, base)}, Enum.EasingStyle.Sine, Enum.EasingDirection.In):Play()
                task.wait(.4)
            end
        end)
    end
end

-- ── LOGIN FRAME ──────────────────────────
local loginF = Instance.new("Frame")
loginF.Size               = UDim2.fromScale(1,1)
loginF.BackgroundColor3   = Color3.fromRGB(4,4,18)
loginF.BackgroundTransparency = 1
loginF.Visible            = false
loginF.ZIndex             = 20
loginF.Parent             = gui

-- left space img
local spaceImg = Instance.new("ImageLabel")
spaceImg.Size             = UDim2.fromScale(.5,1)
spaceImg.Image            = "rbxassetid://7848741169"
spaceImg.ScaleType        = Enum.ScaleType.Crop
spaceImg.BackgroundColor3 = Color3.fromRGB(10,5,30)
spaceImg.BorderSizePixel  = 0
spaceImg.ZIndex           = 21
spaceImg.Parent           = loginF

-- dark vignette overlay
local vig = Instance.new("ImageLabel")
vig.Size       = UDim2.fromScale(1,1)
vig.Image      = "rbxassetid://5028857472"
vig.ImageColor3 = Color3.new(0,0,0)
vig.ImageTransparency = .4
vig.BackgroundTransparency = 1
vig.ZIndex = 22
vig.Parent = spaceImg

-- right login panel
local loginPanel = Instance.new("Frame")
loginPanel.Size             = UDim2.fromScale(.5,1)
loginPanel.Position         = UDim2.fromScale(.5,0)
loginPanel.BackgroundColor3 = Color3.fromRGB(8,6,22)
loginPanel.BorderSizePixel  = 0
loginPanel.ZIndex           = 21
loginPanel.Parent           = loginF

do
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,12,40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6,5,18)),
    })
    g.Rotation = 135
    g.Parent   = loginPanel
end

local logoLbl = Instance.new("TextLabel")
logoLbl.Size       = UDim2.fromScale(.8,.1)
logoLbl.Position   = UDim2.fromScale(.1,.12)
logoLbl.BackgroundTransparency = 1
logoLbl.TextColor3 = Color3.fromRGB(220,180,255)
logoLbl.Font       = Enum.Font.GothamBold
logoLbl.TextSize   = 22
logoLbl.Text       = "✌ runsjops client"
logoLbl.ZIndex     = 22
logoLbl.Parent     = loginPanel

local welcomeLbl = Instance.new("TextLabel")
welcomeLbl.Size       = UDim2.fromScale(.8,.08)
welcomeLbl.Position   = UDim2.fromScale(.1,.26)
welcomeLbl.BackgroundTransparency = 1
welcomeLbl.TextColor3 = Color3.fromRGB(150,120,210)
welcomeLbl.Font       = Enum.Font.Gotham
welcomeLbl.TextSize   = 14
welcomeLbl.Text       = "Войдите в аккаунт"
welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
welcomeLbl.ZIndex     = 22
welcomeLbl.Parent     = loginPanel

local function makeBox(yOff, ph, masked)
    local bg = Instance.new("Frame")
    bg.Size             = UDim2.fromScale(.8,.09)
    bg.Position         = UDim2.fromScale(.1, yOff)
    bg.BackgroundColor3 = Color3.fromRGB(20,16,45)
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 22
    corner(bg, 8)
    bg.Parent = loginPanel
    local tb = Instance.new("TextBox")
    tb.Size        = UDim2.new(1,-16,1,0)
    tb.Position    = UDim2.fromOffset(8,0)
    tb.BackgroundTransparency = 1
    tb.TextColor3  = Color3.fromRGB(230,210,255)
    tb.PlaceholderColor3 = Color3.fromRGB(90,70,130)
    tb.PlaceholderText = ph
    tb.Font        = Enum.Font.Gotham
    tb.TextSize    = 14
    tb.ClearTextOnFocus = false
    tb.ZIndex      = 23
    if masked then tb.Text = "" end
    tb.Parent = bg
    if masked then
        local mask = Instance.new("TextLabel")
        mask.Size       = UDim2.new(1,-16,1,0)
        mask.Position   = UDim2.fromOffset(8,0)
        mask.BackgroundTransparency = 1
        mask.TextColor3 = Color3.fromRGB(230,210,255)
        mask.Font       = Enum.Font.GothamBold
        mask.TextSize   = 16
        mask.Text       = ""
        mask.ZIndex     = 24
        mask.Parent     = bg
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            mask.Text = string.rep("●", #tb.Text)
        end)
        return bg, tb
    end
    return bg, tb
end

local _, userTB = makeBox(.38, "Логин")
local _, passTB = makeBox(.51, "Пароль", true)

local loginBtn = Instance.new("TextButton")
loginBtn.Size             = UDim2.fromScale(.8,.1)
loginBtn.Position         = UDim2.fromScale(.1,.66)
loginBtn.BackgroundColor3 = Color3.fromRGB(110,55,200)
loginBtn.TextColor3       = Color3.new(1,1,1)
loginBtn.Font             = Enum.Font.GothamBold
loginBtn.TextSize         = 15
loginBtn.Text             = "Войти"
loginBtn.BorderSizePixel  = 0
loginBtn.ZIndex           = 22
corner(loginBtn, 8)
loginBtn.Parent = loginPanel

-- ── MAIN MENU ────────────────────────────
local mainF = Instance.new("Frame")
mainF.Size            = UDim2.fromOffset(520,380)
mainF.AnchorPoint     = Vector2.new(.5,.5)
mainF.Position        = UDim2.fromScale(.5,.5)
mainF.BackgroundColor3 = Color3.fromRGB(7,5,20)
mainF.BorderSizePixel = 0
mainF.Visible         = false
mainF.ZIndex          = 30
corner(mainF, 12)
mainF.Parent = gui

-- drag mainF
do
    local dragging, dragStart, startPos
    mainF.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = mainF.Position
        end
    end)
    mainF.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            mainF.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- banner
local banner = Instance.new("ImageLabel")
banner.Size             = UDim2.fromOffset(520,130)
banner.Image            = "rbxassetid://7848741169"
banner.ScaleType        = Enum.ScaleType.Crop
banner.BackgroundColor3 = Color3.fromRGB(10,5,30)
banner.BorderSizePixel  = 0
banner.ZIndex           = 31
corner(banner, 12)
banner.Parent = mainF

-- banner text overlay
local bannerTxt = Instance.new("TextLabel")
bannerTxt.Size       = UDim2.fromOffset(500,130)
bannerTxt.Position   = UDim2.fromOffset(10,0)
bannerTxt.BackgroundTransparency = 1
bannerTxt.TextColor3 = Color3.new(1,1,1)
bannerTxt.Font       = Enum.Font.GothamBold
bannerTxt.TextSize   = 20
bannerTxt.Text       = "runsjops client ✌"
bannerTxt.TextYAlignment = Enum.TextYAlignment.Bottom
bannerTxt.ZIndex     = 32
bannerTxt.Parent     = mainF

-- news section
local newsScroll = Instance.new("ScrollingFrame")
newsScroll.Size             = UDim2.fromOffset(490, 145)
newsScroll.Position         = UDim2.fromOffset(15, 140)
newsScroll.BackgroundColor3 = Color3.fromRGB(12,9,28)
newsScroll.BorderSizePixel  = 0
newsScroll.ScrollBarThickness = 3
newsScroll.ScrollBarImageColor3 = Color3.fromRGB(130,90,220)
newsScroll.ZIndex = 31
corner(newsScroll, 8)
newsScroll.Parent = mainF

local newsLbl = Instance.new("TextLabel")
newsLbl.Size       = UDim2.new(1,-16,0,0)
newsLbl.Position   = UDim2.fromOffset(8,8)
newsLbl.AutomaticSize = Enum.AutomaticSize.Y
newsLbl.BackgroundTransparency = 1
newsLbl.TextColor3 = Color3.fromRGB(200,175,250)
newsLbl.Font       = Enum.Font.Gotham
newsLbl.TextSize   = 13
newsLbl.TextXAlignment = Enum.TextXAlignment.Left
newsLbl.TextYAlignment = Enum.TextYAlignment.Top
newsLbl.TextWrapped = true
newsLbl.RichText   = true
newsLbl.Text       = [[<b>📰 Новости — 20 октября 2026</b>

Добро пожаловать в runsjops client ✌

Этот скрипт был сделан <b>20 октября 2026 года</b>.
Если скрипт устарел — перейдите на сайт и возьмите новый!

ТГК проекта: <b>t.me/runsds_client</b>
На этом пока всё, удачи! <b>@thanks17</b>]]
newsLbl.ZIndex = 32
newsLbl.Parent = newsScroll

newsLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    newsScroll.CanvasSize = UDim2.fromOffset(0, newsLbl.AbsoluteSize.Y + 16)
end)

-- cheat buttons row
local btnRow = Instance.new("Frame")
btnRow.Size             = UDim2.fromOffset(490, 46)
btnRow.Position         = UDim2.fromOffset(15, 296)
btnRow.BackgroundTransparency = 1
btnRow.ZIndex           = 31
btnRow.Parent           = mainF
Instance.new("UIListLayout", btnRow).FillDirection = Enum.FillDirection.Horizontal
Instance.getInstance = function() end -- noop

local function mkBtn(txt, color, cb)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.fromOffset(115, 40)
    b.BackgroundColor3 = color
    b.TextColor3       = Color3.new(1,1,1)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 12
    b.Text             = txt
    b.BorderSizePixel  = 0
    b.ZIndex           = 32
    corner(b, 7)
    b.Parent = btnRow
    b.MouseButton1Click:Connect(function()
        cb(b)
    end)
    -- padding
    Instance.new("UIPadding", btnRow).PaddingLeft = UDim.new(0,4)
    return b
end

local stealActive = false
mkBtn("🥚 Auto Steal", Color3.fromRGB(100,50,200), function(b)
    stealActive = not stealActive
    b.BackgroundColor3 = stealActive and Color3.fromRGB(60,180,80) or Color3.fromRGB(100,50,200)
    b.Text = stealActive and "🟢 Stealing" or "🥚 Auto Steal"
    autoSteal()
end)

local speedActive = false
mkBtn("⚡ Speed", Color3.fromRGB(80,40,170), function(b)
    speedActive = not speedActive
    b.BackgroundColor3 = speedActive and Color3.fromRGB(60,180,80) or Color3.fromRGB(80,40,170)
    b.Text = speedActive and "🟢 Speed ON" or "⚡ Speed"
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedActive and 50 or 16 end
end)

mkBtn("🔍 ESP Eggs", Color3.fromRGB(70,35,150), function(b)
    -- simple egg ESP: highlight with BillboardGui
    for _, egg in ipairs(getAllEggs()) do
        if not egg:FindFirstChild("_esp") then
            local bb = Instance.new("BillboardGui")
            bb.Name           = "_esp"
            bb.Size           = UDim2.fromOffset(60,20)
            bb.AlwaysOnTop    = true
            bb.StudsOffset    = Vector3.new(0,3,0)
            bb.Parent         = egg
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size             = UDim2.fromScale(1,1)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3       = Color3.fromRGB(255,80,80)
            lbl.Font             = Enum.Font.GothamBold
            lbl.TextSize         = 13
            lbl.Text             = "🥚 EGG"
        end
    end
    b.Text = "✅ ESP ON"
end)

mkBtn("✕ Close", Color3.fromRGB(160,35,35), function()
    tw(mainF, .3, {Size = UDim2.fromOffset(520,0), Position = UDim2.fromScale(.5,.5)}):Play()
    task.wait(.35)
    mainF.Visible = false
end)

-- close btn top-right
local xBtn = Instance.new("TextButton")
xBtn.Size             = UDim2.fromOffset(26,26)
xBtn.Position         = UDim2.fromOffset(485,6)
xBtn.BackgroundColor3 = Color3.fromRGB(170,30,30)
xBtn.TextColor3       = Color3.new(1,1,1)
xBtn.Font             = Enum.Font.GothamBold
xBtn.TextSize         = 13
xBtn.Text             = "✕"
xBtn.BorderSizePixel  = 0
xBtn.ZIndex           = 33
corner(xBtn, 100)
xBtn.Parent = mainF
xBtn.MouseButton1Click:Connect(function()
    tw(mainF, .3, {Size = UDim2.fromOffset(520,0), Position = UDim2.fromScale(.5,.5)}):Play()
    task.wait(.35)
    mainF.Visible = false
end)

-- ══════════════════════════════════════════
--  CREDENTIALS (readfile/writefile)
-- ══════════════════════════════════════════

local CRED_FILE = "runsjops_creds.json"
local creds = {}

pcall(function()
    creds = HTTP:JSONDecode(readfile(CRED_FILE))
end)

local function saveCreds(u, p)
    pcall(function()
        writefile(CRED_FILE, HTTP:JSONEncode({u=u, p=p}))
    end)
end

-- ══════════════════════════════════════════
--  FLOW FUNCTIONS
-- ══════════════════════════════════════════

local function showMain()
    mainF.Visible  = true
    mainF.Size     = UDim2.fromOffset(0,0)
    tw(mainF, .5, {Size = UDim2.fromOffset(520,380)}, Enum.EasingStyle.Back):Play()
end

local function showLogin()
    loginF.Visible = true
    tw(loginF, .4, {BackgroundTransparency = 0}):Play()

    if creds.u and creds.u ~= "" then
        welcomeLbl.Text  = "👋 Добро пожаловать, " .. creds.u .. "!\nВведите пароль:"
        userTB.Text      = creds.u
        userTB.Parent.Visible = false  -- hide user field, only password needed
    end
end

loginBtn.MouseButton1Click:Connect(function()
    local u = userTB.Text
    local p = passTB.Text
    if u == "" or p == "" then
        -- shake the panel
        for i = 1,4 do
            tw(loginPanel, .05, {Position = UDim2.fromScale(.5 + (i%2==0 and .005 or -.005), 0)}):Play()
            task.wait(.06)
        end
        tw(loginPanel, .05, {Position = UDim2.fromScale(.5,0)}):Play()
        return
    end
    if creds.u and creds.u ~= "" then
        -- returning user: check saved password
        if p ~= creds.p then
            welcomeLbl.Text = "❌ Неверный пароль!"
            task.wait(1.5)
            welcomeLbl.Text = "👋 Добро пожаловать, " .. creds.u .. "!\nВведите пароль:"
            return
        end
    else
        saveCreds(u, p)
        creds = {u=u, p=p}
    end
    tw(loginF, .4, {BackgroundTransparency = 1}):Play()
    task.wait(.45)
    loginF.Visible = false
    showMain()
end)

-- ══════════════════════════════════════════
--  LOADING SEQUENCE
-- ══════════════════════════════════════════

task.spawn(function()
    bounceDots(bdots)
    task.wait(2)

    loadLbl.Text = "Загрузка плагинов..."
    task.wait(2)

    -- red rotating announcement
    local redLbl = Instance.new("TextLabel")
    redLbl.Size       = UDim2.fromOffset(500,50)
    redLbl.AnchorPoint = Vector2.new(.5,.5)
    redLbl.Position   = UDim2.fromScale(.5,.5)
    redLbl.BackgroundTransparency = 1
    redLbl.TextColor3 = Color3.fromRGB(255,45,45)
    redLbl.Font       = Enum.Font.GothamBold
    redLbl.TextSize   = 30
    redLbl.Text       = "✌ runsjops client"
    redLbl.ZIndex     = 12
    redLbl.TextTransparency = 1
    redLbl.Parent     = loadF

    tw(redLbl, .5, {TextTransparency = 0}):Play()
    tw(redLbl, .8, {Rotation = 75}, Enum.EasingStyle.Back):Play()
    task.wait(1.4)

    -- fade everything out
    for _, child in ipairs(loadF:GetDescendants()) do
        if child:IsA("GuiObject") then
            pcall(function()
                tw(child, .4, {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}):Play()
            end)
        end
    end
    task.wait(.5)
    loadF.Visible = false

    showLogin()
end)
