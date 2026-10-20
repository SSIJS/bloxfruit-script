--[[
    runsjops client
    Steal An Egg :: Win64 :: Luau
    20.10.2026
]]

-- ┌─────────────────────────────────────┐
-- │            SERVICES                 │
-- └─────────────────────────────────────┘
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local HTTP         = game:GetService("HttpService")
local lp           = Players.LocalPlayer
local cam          = workspace.CurrentCamera

-- ┌─────────────────────────────────────┐
-- │            HELPERS                  │
-- └─────────────────────────────────────┘
local function tween(obj, time, props, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    t:Play(); return t
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(80,60,140)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local function newFrame(parent, props)
    local f = Instance.new("Frame", parent)
    f.BorderSizePixel = 0
    for k,v in pairs(props or {}) do f[k] = v end
    return f
end

local function newLabel(parent, props)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    for k,v in pairs(props or {}) do l[k] = v end
    return l
end

local function newButton(parent, props)
    local b = Instance.new("TextButton", parent)
    b.BorderSizePixel = 0
    for k,v in pairs(props or {}) do b[k] = v end
    -- hover effect
    b.MouseEnter:Connect(function()
        tween(b, .15, {BackgroundColor3 = (b.BackgroundColor3:Lerp(Color3.new(1,1,1), .12))})
    end)
    b.MouseLeave:Connect(function()
        local orig = props and props.BackgroundColor3
        if orig then tween(b, .15, {BackgroundColor3 = orig}) end
    end)
    return b
end

local function newInput(parent, props)
    local t = Instance.new("TextBox", parent)
    t.BorderSizePixel = 0; t.ClearTextOnFocus = false
    for k,v in pairs(props or {}) do t[k] = v end
    return t
end

-- ┌─────────────────────────────────────┐
-- │         ANTI-CHEAT :: 5 STAGES      │
-- └─────────────────────────────────────┘

-- Stage 1: Remote hook - drop AC remotes before they reach server
pcall(function()
    local orig; orig = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local name = self.Name:lower()
            local blocked = {"anticheat","anti_cheat","acheat","detect","report",
                             "kick","ban","flagplayer","hackdetect","speedcheck"}
            for _, kw in ipairs(blocked) do
                if name:find(kw) then return end
            end
        end
        return orig(self, ...)
    end))
end)

-- Stage 2: Humanoid spoof via metatable
local function applyHumHook(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    pcall(function()
        local mt = getrawmetatable(hum)
        setreadonly(mt, false)
        local orig = rawget(mt, "__newindex")
        rawset(mt, "__newindex", newcclosure(function(t, k, v)
            if k == "WalkSpeed" and v > 96  then v = 96  end
            if k == "JumpPower" and v > 72  then v = 72  end
            return orig(t, k, v)
        end))
        setreadonly(mt, true)
    end)
end
if lp.Character then task.spawn(applyHumHook, lp.Character) end
lp.CharacterAdded:Connect(applyHumHook)

-- Stage 3: Heartbeat delta guard (server-side speedhack timer bypass)
local prevTick = tick()
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - prevTick > .45 then prevTick = now; return end -- swallow spike
    prevTick = now
end)

-- Stage 4: Workspace property read spoof
pcall(function()
    local mt = getrawmetatable(workspace)
    setreadonly(mt, false)
    local origIdx = rawget(mt, "__index")
    rawset(mt, "__index", newcclosure(function(t, k)
        return origIdx(t, k)
    end))
    setreadonly(mt, true)
end)

-- Stage 5: firetouchinterest wrapper (grab eggs without touching)
local function grabTouch(part)
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end
    pcall(firetouchinterest, root, part, 0); task.wait(.07)
    pcall(firetouchinterest, root, part, 1)
end

-- ┌─────────────────────────────────────┐
-- │            GAME LOGIC               │
-- └─────────────────────────────────────┘
local function findEggs()
    local t = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("egg") then t[#t+1] = v end
    end
    return t
end

local stealLoop = false
local function toggleSteal(btn)
    stealLoop = not stealLoop
    if stealLoop then
        btn.Text = "🟢 Stealing"
        btn.BackgroundColor3 = Color3.fromRGB(40,160,65)
        task.spawn(function()
            while stealLoop do
                for _, egg in ipairs(findEggs()) do
                    if not stealLoop then break end
                    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local orig = root.CFrame
                        root.CFrame = egg.CFrame + Vector3.new(0,3,0)
                        grabTouch(egg); task.wait(.2)
                        root.CFrame = orig
                    end; task.wait(.06)
                end; task.wait(.35)
            end
        end)
    else
        btn.Text = "🥚 Auto Steal"
        btn.BackgroundColor3 = Color3.fromRGB(95,50,190)
    end
end

local speedLoop = false
local function toggleSpeed(btn)
    speedLoop = not speedLoop
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if speedLoop then
        btn.Text = "🟢 Speed ON"
        btn.BackgroundColor3 = Color3.fromRGB(40,160,65)
        if hum then hum.WalkSpeed = 48 end
    else
        btn.Text = "⚡ Speed"
        btn.BackgroundColor3 = Color3.fromRGB(75,38,165)
        if hum then hum.WalkSpeed = 16 end
    end
end

local espActive = false
local function toggleEsp(btn)
    espActive = not espActive
    if espActive then
        btn.Text = "🟢 ESP ON"
        btn.BackgroundColor3 = Color3.fromRGB(40,160,65)
        for _, egg in ipairs(findEggs()) do
            if not egg:FindFirstChild("_esp") then
                local bb = Instance.new("BillboardGui", egg)
                bb.Name = "_esp"; bb.AlwaysOnTop = true
                bb.Size = UDim2.fromOffset(55,18); bb.StudsOffset = Vector3.new(0,3,0)
                local lb = Instance.new("TextLabel", bb)
                lb.Size=UDim2.fromScale(1,1); lb.BackgroundTransparency=1
                lb.TextColor3=Color3.fromRGB(255,75,75); lb.Font=Enum.Font.GothamBold
                lb.TextSize=12; lb.Text="🥚 EGG"
            end
        end
    else
        btn.Text = "🔍 ESP Eggs"
        btn.BackgroundColor3 = Color3.fromRGB(65,32,145)
        for _,v in ipairs(workspace:GetDescendants()) do
            if v.Name == "_esp" then v:Destroy() end
        end
    end
end

-- ┌─────────────────────────────────────┐
-- │              GUI ROOT               │
-- └─────────────────────────────────────┘
local W = cam.ViewportSize.X
local H = cam.ViewportSize.Y

local gui = Instance.new("ScreenGui")
gui.Name = "runsjops_v2"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (pcall(gethui) and gethui()) or game.CoreGui

-- ┌─────────────────────────────────────┐
-- │         PARTICLE BACKGROUND         │
-- └─────────────────────────────────────┘
local bgFrame = newFrame(gui, {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(4,4,16),
    ZIndex = 1
})

-- pre-allocate all objects once — NO per-frame creation
local DOTS   = 24           -- safe count
local CDIST  = 125
local SKIP   = 3            -- update lines every 3 frames
local skipCounter = 0
local dots, lines = {}, {}

do  -- dot pool
    for i = 1, DOTS do
        local f = newFrame(bgFrame, {
            Size = UDim2.fromOffset(5,5),
            BackgroundColor3 = Color3.fromRGB(160,120,255),
            ZIndex = 2
        })
        addCorner(f, 100)
        dots[i] = {
            f  = f,
            x  = math.random(20, W-20),
            y  = math.random(20, H-20),
            vx = (math.random()-.5)*1.3,
            vy = (math.random()-.5)*1.3,
        }
    end
end

do  -- line pool: maximum connections = DOTS*(DOTS-1)/2 = 276
    local maxLines = DOTS*(DOTS-1)/2
    for i = 1, maxLines do
        local f = newFrame(bgFrame, {
            AnchorPoint = Vector2.new(0,.5),
            BackgroundColor3 = Color3.fromRGB(80,60,150),
            ZIndex = 2,
            Visible = false
        })
        lines[i] = f
    end
end

local idleTime = 0
local lastMouse = Vector2.zero
local visibleLines = 0

RunService.RenderStepped:Connect(function(dt)
    -- skip if bg not visible (login/menu phase still shows particles)
    if not bgFrame.Visible then return end

    local mp = UIS:GetMouseLocation()
    local moved = (mp - lastMouse).Magnitude > 3
    if moved then idleTime = 0; lastMouse = mp else idleTime += dt end

    local idle = idleTime > 3.5
    local cx, cy = W*.5, H*.5
    local orbitR = math.min(W,H) * .21

    -- update dot positions
    for i, d in ipairs(dots) do
        if idle then
            local ang = (i/DOTS)*math.pi*2 + tick()*.22
            d.x += (cx + math.cos(ang)*orbitR - d.x) * .045
            d.y += (cy + math.sin(ang)*orbitR - d.y) * .045
        else
            local dx = mp.X - d.x
            local dy = mp.Y - d.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < 170 and dist > 0 then
                d.vx += dx/dist * .16
                d.vy += dy/dist * .16
            end
            d.vx *= .975; d.vy *= .975
            d.x  += d.vx; d.y  += d.vy
            if d.x < 0 then d.x = W elseif d.x > W then d.x = 0 end
            if d.y < 0 then d.y = H elseif d.y > H then d.y = 0 end
        end
        d.f.Position = UDim2.fromOffset(d.x - 2, d.y - 2)
    end

    -- update lines only every SKIP frames
    skipCounter += 1
    if skipCounter < SKIP then return end
    skipCounter = 0

    -- hide previous visible lines
    for i = 1, visibleLines do
        lines[i].Visible = false
    end

    local li = 0
    for i = 1, DOTS do
        for j = i+1, DOTS do
            local a, b = dots[i], dots[j]
            local dx = b.x - a.x
            local dy = b.y - a.y
            local d  = math.sqrt(dx*dx + dy*dy)
            if d < CDIST then
                li += 1
                local ln = lines[li]
                local alpha = (1 - d/CDIST) * .6
                ln.BackgroundTransparency = 1 - alpha
                ln.Position = UDim2.fromOffset(a.x, a.y)
                ln.Size     = UDim2.fromOffset(d, 1)
                ln.Rotation = math.deg(math.atan2(dy, dx))
                ln.Visible  = true
            end
        end
    end
    visibleLines = li
end)

-- ┌─────────────────────────────────────┐
-- │           LOADING SCREEN            │
-- └─────────────────────────────────────┘
local loadLayer = newFrame(gui, {
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
    ZIndex = 10
})

local loadText = newLabel(loadLayer, {
    Size = UDim2.fromOffset(400, 28),
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.57),
    TextColor3 = Color3.fromRGB(185,150,255),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    Text = "Загрузка ресурсов...",
    ZIndex = 11
})

-- bouncing dots loader
local loaderDots = {}
for i = 1, 3 do
    local d = newFrame(loadLayer, {
        Size = UDim2.fromOffset(9,9),
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.fromOffset(W*.5 - 18 + (i-1)*18, H*.635),
        BackgroundColor3 = Color3.fromRGB(150,100,255),
        ZIndex = 11
    })
    addCorner(d, 100)
    loaderDots[i] = d
end

local function startBounce(dotList)
    for i, dot in ipairs(dotList) do
        task.delay((i-1)*.17, function()
            local baseY = dot.Position.Y.Offset
            while dot and dot.Parent and loadLayer.Visible do
                tween(dot,.24,{Position=UDim2.fromOffset(dot.Position.X.Offset, baseY-13)},Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
                task.wait(.26)
                tween(dot,.24,{Position=UDim2.fromOffset(dot.Position.X.Offset, baseY)},Enum.EasingStyle.Sine,Enum.EasingDirection.In)
                task.wait(.4)
            end
        end)
    end
end

-- ┌─────────────────────────────────────┐
-- │             LOGIN SCREEN            │
-- └─────────────────────────────────────┘
local loginLayer = newFrame(gui, {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(4,4,16),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 20
})

-- left: space image
local spaceSide = Instance.new("ImageLabel", loginLayer)
spaceSide.Size = UDim2.fromScale(.5,1)
spaceSide.Image = "rbxassetid://7848741169"
spaceSide.ScaleType = Enum.ScaleType.Crop
spaceSide.BackgroundColor3 = Color3.fromRGB(8,4,24)
spaceSide.BorderSizePixel = 0
spaceSide.ZIndex = 21

-- gradient over image
local imgGrad = Instance.new("UIGradient", spaceSide)
imgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(.6, Color3.fromRGB(10,8,25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,15,50))
})
imgGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, .1),
    NumberSequenceKeypoint.new(1, .7)
})
imgGrad.Rotation = 90

-- right: form panel
local formPanel = newFrame(loginLayer, {
    Size = UDim2.fromScale(.5,1),
    Position = UDim2.fromScale(.5,0),
    BackgroundColor3 = Color3.fromRGB(8,6,20),
    ZIndex = 21
})

do
    local g = Instance.new("UIGradient", formPanel)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16,11,38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6,5,16))
    })
    g.Rotation = 140
end

local formTitle = newLabel(formPanel, {
    Size = UDim2.fromScale(.8,.09),
    Position = UDim2.fromScale(.1,.1),
    TextColor3 = Color3.fromRGB(215,175,255),
    Font = Enum.Font.GothamBold,
    TextSize = 23,
    Text = "✌ runsjops client",
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22
})

local welcomeText = newLabel(formPanel, {
    Size = UDim2.fromScale(.8,.07),
    Position = UDim2.fromScale(.1,.24),
    TextColor3 = Color3.fromRGB(140,110,200),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    Text = "Войдите в аккаунт",
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22
})

local function makeInputBox(yPct, placeholder, isPassword)
    local bg = newFrame(formPanel, {
        Size = UDim2.fromScale(.8,.09),
        Position = UDim2.fromScale(.1, yPct),
        BackgroundColor3 = Color3.fromRGB(18,14,40),
        ZIndex = 22
    })
    addCorner(bg, 8); addStroke(bg, Color3.fromRGB(55,40,100), 1)

    local tb = newInput(bg, {
        Size = UDim2.new(1,-16,1,0),
        Position = UDim2.fromOffset(8,0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(230,210,255),
        PlaceholderColor3 = Color3.fromRGB(85,65,125),
        PlaceholderText = placeholder,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23
    })
    bg.MouseEnter:Connect(function() tween(bg,.15,{BackgroundColor3=Color3.fromRGB(24,18,52)}) end)
    bg.MouseLeave:Connect(function() tween(bg,.15,{BackgroundColor3=Color3.fromRGB(18,14,40)}) end)

    if isPassword then
        local mask = newLabel(bg, {
            Size = UDim2.new(1,-16,1,0),
            Position = UDim2.fromOffset(8,0),
            TextColor3 = Color3.fromRGB(230,210,255),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 24
        })
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            mask.Text = string.rep("●", #tb.Text)
            tb.TextTransparency = 1
        end)
    end
    return bg, tb
end

local _, userBox = makeInputBox(.36, "Логин")
local _, passBox = makeInputBox(.49, "Пароль", true)

local loginBtn = newButton(formPanel, {
    Size = UDim2.fromScale(.8,.1),
    Position = UDim2.fromScale(.1,.64),
    BackgroundColor3 = Color3.fromRGB(105,52,195),
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    Text = "Войти",
    ZIndex = 22
})
addCorner(loginBtn, 8)

-- ┌─────────────────────────────────────┐
-- │             MAIN MENU               │
-- └─────────────────────────────────────┘
local menu = newFrame(gui, {
    Size = UDim2.fromOffset(520, 390),
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    BackgroundColor3 = Color3.fromRGB(7,5,20),
    Visible = false,
    ZIndex = 30
})
addCorner(menu, 12)
addStroke(menu, Color3.fromRGB(70,50,130), 1)

-- drag
do
    local drag, origin, startPos
    menu.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; origin = i.Position; startPos = menu.Position
        end
    end)
    menu.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - origin
            menu.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- banner
local banner = Instance.new("ImageLabel", menu)
banner.Size = UDim2.fromOffset(520,128)
banner.Image = "rbxassetid://7848741169"
banner.ScaleType = Enum.ScaleType.Crop
banner.BackgroundColor3 = Color3.fromRGB(8,4,22)
banner.BorderSizePixel = 0; banner.ZIndex = 31
addCorner(banner, 12)

-- banner bottom fade
local bannerFade = Instance.new("UIGradient", banner)
bannerFade.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(.6, 0),
    NumberSequenceKeypoint.new(1, .85)
})
bannerFade.Rotation = 90

newLabel(menu, {
    Size = UDim2.fromOffset(490,50),
    Position = UDim2.fromOffset(15,80),
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    Text = "runsjops client ✌",
    ZIndex = 32
})

-- news
local newsFrame = newFrame(menu, {
    Size = UDim2.fromOffset(490,148),
    Position = UDim2.fromOffset(15,138),
    BackgroundColor3 = Color3.fromRGB(11,8,26),
    ZIndex = 31
})
addCorner(newsFrame, 8); addStroke(newsFrame, Color3.fromRGB(45,33,90), 1)

local newsScroll = Instance.new("ScrollingFrame", newsFrame)
newsScroll.Size = UDim2.fromScale(1,1)
newsScroll.BackgroundTransparency = 1; newsScroll.BorderSizePixel = 0
newsScroll.ScrollBarThickness = 3
newsScroll.ScrollBarImageColor3 = Color3.fromRGB(110,80,200)
newsScroll.CanvasSize = UDim2.fromOffset(0,0); newsScroll.ZIndex = 32

local newsContent = newLabel(newsScroll, {
    Size = UDim2.new(1,-16,0,0),
    Position = UDim2.fromOffset(8,8),
    AutomaticSize = Enum.AutomaticSize.Y,
    TextColor3 = Color3.fromRGB(195,170,245),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    RichText = true,
    ZIndex = 33,
    Text = [[<b>📰 20 октября 2026</b>

Добро пожаловать в <b>runsjops client</b> ✌

Скрипт был сделан <b>20 октября 2026</b>.
Если устарел — зайди на сайт за новым!

ТГК: <b>t.me/runsds_client</b>
Удачи! — <b>@thanks17</b>]]
})
newsContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    newsScroll.CanvasSize = UDim2.fromOffset(0, newsContent.AbsoluteSize.Y + 18)
end)

-- buttons
local btnContainer = newFrame(menu, {
    Size = UDim2.fromOffset(490,44),
    Position = UDim2.fromOffset(15,302),
    BackgroundTransparency = 1,
    ZIndex = 31
})
do
    local layout = Instance.new("UIListLayout", btnContainer)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0,6)
end

local function addBtn(label, color, callback)
    local b = newButton(btnContainer, {
        Size = UDim2.fromOffset(114,44),
        BackgroundColor3 = color,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Text = label,
        ZIndex = 32
    })
    addCorner(b, 7)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

addBtn("🥚 Auto Steal", Color3.fromRGB(95,50,190), toggleSteal)
addBtn("⚡ Speed",      Color3.fromRGB(75,38,165), toggleSpeed)
addBtn("🔍 ESP Eggs",  Color3.fromRGB(65,32,145), toggleEsp)
addBtn("✕ Закрыть",   Color3.fromRGB(150,28,28), function()
    tween(menu,.28,{Size=UDim2.fromOffset(520,0), Position=UDim2.fromScale(.5,.5)},Enum.EasingStyle.Quad)
    task.wait(.3); menu.Visible = false
end)

-- top-right close
local xClose = newButton(menu, {
    Size = UDim2.fromOffset(26,26),
    Position = UDim2.fromOffset(485,7),
    BackgroundColor3 = Color3.fromRGB(145,25,25),
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Text = "✕",
    ZIndex = 33
})
addCorner(xClose, 100)
xClose.MouseButton1Click:Connect(function()
    tween(menu,.28,{Size=UDim2.fromOffset(520,0), Position=UDim2.fromScale(.5,.5)},Enum.EasingStyle.Quad)
    task.wait(.3); menu.Visible = false
end)

-- ┌─────────────────────────────────────┐
-- │         CREDENTIALS STORE           │
-- └─────────────────────────────────────┘
local CRED_PATH = "rj_creds.json"
local creds = {}
pcall(function() creds = HTTP:JSONDecode(readfile(CRED_PATH)) end)

local function saveCreds(u, p)
    pcall(function() writefile(CRED_PATH, HTTP:JSONEncode({u=u, p=p})) end)
end

-- ┌─────────────────────────────────────┐
-- │            FLOW CONTROL             │
-- └─────────────────────────────────────┘
local function showMenu()
    menu.Visible = true
    menu.Size = UDim2.fromOffset(0,0)
    tween(menu,.45,{Size=UDim2.fromOffset(520,390)},Enum.EasingStyle.Back)
end

local function showLogin()
    loginLayer.Visible = true
    tween(loginLayer,.4,{BackgroundTransparency=0})
    if creds.u and creds.u ~= "" then
        welcomeText.Text = "👋 " .. creds.u .. ", введи пароль:"
        userBox.Text = creds.u
    end
end

loginBtn.MouseButton1Click:Connect(function()
    local u = userBox.Text
    local p = passBox.Text
    if u == "" or p == "" then
        -- shake animation
        for i = 1, 5 do
            formPanel.Position = UDim2.fromScale(.5 + (i%2==0 and .005 or -.005), 0)
            task.wait(.05)
        end
        formPanel.Position = UDim2.fromScale(.5, 0)
        return
    end
    if creds.u and creds.u ~= "" then
        if p ~= creds.p then
            local orig = welcomeText.Text
            welcomeText.Text = "❌ Неверный пароль!"
            welcomeText.TextColor3 = Color3.fromRGB(255,80,80)
            task.wait(1.5)
            welcomeText.Text = orig
            welcomeText.TextColor3 = Color3.fromRGB(140,110,200)
            return
        end
    else
        saveCreds(u,p); creds = {u=u, p=p}
    end
    tween(loginLayer,.38,{BackgroundTransparency=1})
    task.wait(.42); loginLayer.Visible = false
    showMenu()
end)

-- ┌─────────────────────────────────────┐
-- │          LOADING SEQUENCE           │
-- └─────────────────────────────────────┘
task.spawn(function()
    startBounce(loaderDots)
    task.wait(2.3)

    loadText.Text = "Загрузка плагинов..."
    task.wait(2)

    -- red spinning label
    local splash = newLabel(loadLayer, {
        Size = UDim2.fromOffset(500,50),
        AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.fromScale(.5,.5),
        TextColor3 = Color3.fromRGB(255,38,38),
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        Text = "✌ runsjops client",
        TextTransparency = 1,
        ZIndex = 12
    })
    tween(splash,.4,{TextTransparency=0})
    tween(splash,.75,{Rotation=75},Enum.EasingStyle.Back)
    task.wait(1.35)

    -- fade out all loadLayer children
    for _, child in ipairs(loadLayer:GetDescendants()) do
        if child:IsA("GuiObject") then
            pcall(tween, child, .35, {
                BackgroundTransparency = 1,
                TextTransparency = 1,
                ImageTransparency = 1
            })
        end
    end
    task.wait(.4)
    loadLayer.Visible = false
    showLogin()
end)
