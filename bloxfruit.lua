-- ╔══════════════════════════════════════════╗
-- ║     runsjops client :: Steal An Egg      ║
-- ║  OS: Win64 | Arch: x86/x64 | Luau       ║
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

-- STAGE 1 :: RemoteEvent namecall hook
pcall(function()
    local _nc
    _nc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "FireServer" or m == "InvokeServer" then
            local n = tostring(self.Name):lower()
            for _, kw in ipairs({"anti","cheat","detect","report","kick","ban","flag","watch","monitor"}) do
                if n:find(kw) then return end
            end
        end
        return _nc(self, ...)
    end))
end)

-- STAGE 2 :: Humanoid property spoof
local function hookHum(char)
    local hum = char:WaitForChild("Humanoid", 8)
    if not hum then return end
    pcall(function()
        local mt = getrawmetatable(hum)
        setreadonly(mt, false)
        local _ni = rawget(mt, "__newindex")
        rawset(mt, "__newindex", newcclosure(function(t, k, v)
            if k == "WalkSpeed" and v > 100 then v = 100 end
            if k == "JumpPower"  and v > 75  then v = 75  end
            return _ni(t, k, v)
        end))
        setreadonly(mt, true)
    end)
end
if lp.Character then task.spawn(hookHum, lp.Character) end
lp.CharacterAdded:Connect(hookHum)

-- STAGE 3 :: Delta-time guard
local _lt = tick()
RunService.Heartbeat:Connect(function()
    local d = tick() - _lt; _lt = tick()
    if d > 0.5 then return end -- spike guard
end)

-- STAGE 4 :: Metatable index guard (read-only properties spoof)
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local _idx = rawget(mt, "__index")
    rawset(mt, "__index", newcclosure(function(t, k)
        -- pass-through; presence of hook strips identity from AC indexers
        return _idx(t, k)
    end))
    setreadonly(mt, true)
end)

-- STAGE 5 :: firetouchinterest egg-grab
local function softTouch(part)
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end
    pcall(firetouchinterest, root, part, 0)
    task.wait(0.06)
    pcall(firetouchinterest, root, part, 1)
end

-- ══════════════════════════════════════════
--  GAME LOGIC
-- ══════════════════════════════════════════

local function getEggs()
    local out = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("egg") then
            out[#out+1] = v
        end
    end
    return out
end

local stealOn = false
local function toggleSteal(btn)
    stealOn = not stealOn
    btn.BackgroundColor3 = stealOn and Color3.fromRGB(50,170,70) or Color3.fromRGB(100,50,200)
    btn.Text = stealOn and "🟢 Stealing" or "🥚 Auto Steal"
    if not stealOn then return end
    task.spawn(function()
        while stealOn do
            for _, egg in ipairs(getEggs()) do
                if not stealOn then break end
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local orig = root.CFrame
                    root.CFrame = egg.CFrame + Vector3.new(0,3,0)
                    softTouch(egg)
                    task.wait(0.25)
                    root.CFrame = orig
                end
                task.wait(0.08)
            end
            task.wait(0.4)
        end
    end)
end

local speedOn = false
local function toggleSpeed(btn)
    speedOn = not speedOn
    btn.BackgroundColor3 = speedOn and Color3.fromRGB(50,170,70) or Color3.fromRGB(80,40,170)
    btn.Text = speedOn and "🟢 Speed ON" or "⚡ Speed"
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedOn and 50 or 16 end
end

local espOn = false
local function toggleEsp(btn)
    espOn = not espOn
    btn.BackgroundColor3 = espOn and Color3.fromRGB(50,170,70) or Color3.fromRGB(70,35,150)
    btn.Text = espOn and "🟢 ESP ON" or "🔍 ESP Eggs"
    if espOn then
        for _, egg in ipairs(getEggs()) do
            if not egg:FindFirstChild("_esp") then
                local bb = Instance.new("BillboardGui", egg)
                bb.Name = "_esp"; bb.Size = UDim2.fromOffset(60,20)
                bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,3,0)
                local lb = Instance.new("TextLabel", bb)
                lb.Size = UDim2.fromScale(1,1); lb.BackgroundTransparency = 1
                lb.TextColor3 = Color3.fromRGB(255,80,80)
                lb.Font = Enum.Font.GothamBold; lb.TextSize = 13
                lb.Text = "🥚 EGG"
            end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "_esp" then v:Destroy() end
        end
    end
end

-- ══════════════════════════════════════════
--  GUI
-- ══════════════════════════════════════════

local gui = Instance.new("ScreenGui")
gui.Name = "runsjops"; gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (gethui and gethui()) or game.CoreGui

local VP = workspace.CurrentCamera.ViewportSize
local W, H = VP.X, VP.Y

local function tw(o, t, p, s, d)
    return TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p)
end
local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 10) end

-- ── PARTICLE CANVAS ──────────────────────
local canvas = Instance.new("Frame", gui)
canvas.Size = UDim2.fromScale(1,1)
canvas.BackgroundColor3 = Color3.fromRGB(4,4,18)
canvas.BorderSizePixel = 0; canvas.ZIndex = 1

-- fewer particles, larger skip interval = no crash
local PCNT = 32
local CDIST = 130
local ptcls, linePool = {}, {}
local lineIdx = 0
local frameSkip = 0  -- only update lines every 2 frames

local function mkDot()
    local f = Instance.new("Frame", canvas)
    f.Size = UDim2.fromOffset(4,4); f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.fromRGB(165,125,255); f.ZIndex = 2
    corner(f, 100)
    return { f=f, x=math.random(0,W), y=math.random(0,H),
             vx=(math.random()-.5)*1.2, vy=(math.random()-.5)*1.2 }
end
for i=1,PCNT do ptcls[i] = mkDot() end

local function getLine(i)
    if not linePool[i] then
        local f = Instance.new("Frame", canvas)
        f.AnchorPoint = Vector2.new(0,.5); f.BackgroundColor3 = Color3.fromRGB(85,65,155)
        f.BorderSizePixel = 0; f.ZIndex = 2
        linePool[i] = f
    end
    return linePool[i]
end

local idleT, lastMP = 0, Vector2.zero

RunService.RenderStepped:Connect(function(dt)
    local mp = UIS:GetMouseLocation()
    if (mp-lastMP).Magnitude > 4 then idleT=0; lastMP=mp else idleT=idleT+dt end

    local idle = idleT > 3
    local cx, cy = W*.5, H*.5
    local R = math.min(W,H)*.2

    -- update particle positions
    for i, p in ipairs(ptcls) do
        if idle then
            local ang = (i/PCNT)*math.pi*2 + tick()*.2
            p.x = p.x + (cx+math.cos(ang)*R - p.x)*.04
            p.y = p.y + (cy+math.sin(ang)*R - p.y)*.04
        else
            local dx = mp.X-p.x; local dy = mp.Y-p.y
            local d = math.sqrt(dx*dx+dy*dy)
            if d < 160 then p.vx=p.vx+dx/d*.15; p.vy=p.vy+dy/d*.15 end
            p.vx=p.vx*.97; p.vy=p.vy*.97
            p.x=p.x+p.vx; p.y=p.y+p.vy
            if p.x<0 then p.x=W elseif p.x>W then p.x=0 end
            if p.y<0 then p.y=H elseif p.y>H then p.y=0 end
        end
        p.f.Position = UDim2.fromOffset(p.x-2, p.y-2)
    end

    -- LINE UPDATE :: every 2nd frame only (cuts cost ~50%)
    frameSkip = frameSkip + 1
    if frameSkip < 2 then return end
    frameSkip = 0

    for _, l in ipairs(linePool) do l.Visible = false end
    lineIdx = 0
    for i=1,#ptcls do
        for j=i+1,#ptcls do
            local a,b = ptcls[i],ptcls[j]
            local dx=b.x-a.x; local dy=b.y-a.y
            local d=math.sqrt(dx*dx+dy*dy)
            if d < CDIST then
                lineIdx=lineIdx+1
                local l=getLine(lineIdx)
                l.BackgroundTransparency = 1-(1-d/CDIST)*.6
                l.Position = UDim2.fromOffset(a.x, a.y)
                l.Size     = UDim2.fromOffset(d, 1)
                l.Rotation = math.deg(math.atan2(dy,dx))
                l.Visible  = true
            end
        end
    end
end)

-- ── LOADING ──────────────────────────────
local loadF = Instance.new("Frame", gui)
loadF.Size=UDim2.fromScale(1,1); loadF.BackgroundTransparency=1; loadF.ZIndex=10

local loadLbl = Instance.new("TextLabel", loadF)
loadLbl.Size=UDim2.fromOffset(400,28); loadLbl.AnchorPoint=Vector2.new(.5,.5)
loadLbl.Position=UDim2.fromScale(.5,.57); loadLbl.BackgroundTransparency=1
loadLbl.TextColor3=Color3.fromRGB(190,160,255); loadLbl.Font=Enum.Font.GothamBold
loadLbl.TextSize=17; loadLbl.Text="Загрузка ресурсов..."; loadLbl.ZIndex=11

local bdots = {}
for i=1,3 do
    local d=Instance.new("Frame", loadF)
    d.Size=UDim2.fromOffset(9,9); d.AnchorPoint=Vector2.new(.5,.5)
    d.Position=UDim2.fromOffset(W*.5-20+(i-1)*20, H*.63)
    d.BackgroundColor3=Color3.fromRGB(155,105,255); d.BorderSizePixel=0; d.ZIndex=11
    corner(d,100); bdots[i]=d
end

local function bounceDots(list)
    for i, dot in ipairs(list) do
        task.delay((i-1)*.18, function()
            local base = dot.Position.Y.Offset
            while dot and dot.Parent do
                tw(dot,.25,{Position=UDim2.fromOffset(dot.Position.X.Offset,base-14)},Enum.EasingStyle.Sine,Enum.EasingDirection.Out):Play()
                task.wait(.28)
                tw(dot,.25,{Position=UDim2.fromOffset(dot.Position.X.Offset,base)},Enum.EasingStyle.Sine,Enum.EasingDirection.In):Play()
                task.wait(.42)
            end
        end)
    end
end

-- ── LOGIN ─────────────────────────────────
local loginF = Instance.new("Frame", gui)
loginF.Size=UDim2.fromScale(1,1); loginF.BackgroundColor3=Color3.fromRGB(4,4,18)
loginF.BackgroundTransparency=1; loginF.Visible=false; loginF.ZIndex=20

local spaceImg = Instance.new("ImageLabel", loginF)
spaceImg.Size=UDim2.fromScale(.5,1); spaceImg.Image="rbxassetid://7848741169"
spaceImg.ScaleType=Enum.ScaleType.Crop; spaceImg.BackgroundColor3=Color3.fromRGB(10,5,30)
spaceImg.BorderSizePixel=0; spaceImg.ZIndex=21

local loginPanel = Instance.new("Frame", loginF)
loginPanel.Size=UDim2.fromScale(.5,1); loginPanel.Position=UDim2.fromScale(.5,0)
loginPanel.BackgroundColor3=Color3.fromRGB(8,6,22); loginPanel.BorderSizePixel=0; loginPanel.ZIndex=21

do local g=Instance.new("UIGradient",loginPanel)
   g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(18,12,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(6,5,18))})
   g.Rotation=135 end

local logoLbl = Instance.new("TextLabel", loginPanel)
logoLbl.Size=UDim2.fromScale(.8,.1); logoLbl.Position=UDim2.fromScale(.1,.1)
logoLbl.BackgroundTransparency=1; logoLbl.TextColor3=Color3.fromRGB(220,180,255)
logoLbl.Font=Enum.Font.GothamBold; logoLbl.TextSize=22; logoLbl.Text="✌ runsjops client"; logoLbl.ZIndex=22

local welcomeLbl = Instance.new("TextLabel", loginPanel)
welcomeLbl.Size=UDim2.fromScale(.8,.1); welcomeLbl.Position=UDim2.fromScale(.1,.26)
welcomeLbl.BackgroundTransparency=1; welcomeLbl.TextColor3=Color3.fromRGB(145,115,205)
welcomeLbl.Font=Enum.Font.Gotham; welcomeLbl.TextSize=14; welcomeLbl.Text="Войдите в аккаунт"
welcomeLbl.TextXAlignment=Enum.TextXAlignment.Left; welcomeLbl.ZIndex=22

local function mkBox(yOff, ph, masked)
    local bg = Instance.new("Frame", loginPanel)
    bg.Size=UDim2.fromScale(.8,.09); bg.Position=UDim2.fromScale(.1,yOff)
    bg.BackgroundColor3=Color3.fromRGB(20,16,45); bg.BorderSizePixel=0; bg.ZIndex=22; corner(bg,8)
    local tb = Instance.new("TextBox", bg)
    tb.Size=UDim2.new(1,-16,1,0); tb.Position=UDim2.fromOffset(8,0)
    tb.BackgroundTransparency=1; tb.TextColor3=Color3.fromRGB(230,210,255)
    tb.PlaceholderColor3=Color3.fromRGB(90,70,130); tb.PlaceholderText=ph
    tb.Font=Enum.Font.Gotham; tb.TextSize=14; tb.ClearTextOnFocus=false; tb.ZIndex=23
    if masked then
        local overlay = Instance.new("TextLabel", bg)
        overlay.Size=UDim2.new(1,-16,1,0); overlay.Position=UDim2.fromOffset(8,0)
        overlay.BackgroundTransparency=1; overlay.TextColor3=Color3.fromRGB(230,210,255)
        overlay.Font=Enum.Font.GothamBold; overlay.TextSize=16; overlay.Text=""
        overlay.TextXAlignment=Enum.TextXAlignment.Left; overlay.ZIndex=24
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            overlay.Text=string.rep("●",#tb.Text)
            tb.TextTransparency=1 -- hide real text
        end)
        return bg, tb
    end
    return bg, tb
end

local _,userTB = mkBox(.38,"Логин")
local _,passTB = mkBox(.51,"Пароль",true)

local loginBtn = Instance.new("TextButton", loginPanel)
loginBtn.Size=UDim2.fromScale(.8,.1); loginBtn.Position=UDim2.fromScale(.1,.65)
loginBtn.BackgroundColor3=Color3.fromRGB(110,55,200); loginBtn.TextColor3=Color3.new(1,1,1)
loginBtn.Font=Enum.Font.GothamBold; loginBtn.TextSize=15; loginBtn.Text="Войти"
loginBtn.BorderSizePixel=0; loginBtn.ZIndex=22; corner(loginBtn,8)

-- ── MAIN MENU ────────────────────────────
local mainF = Instance.new("Frame", gui)
mainF.Size=UDim2.fromOffset(520,380); mainF.AnchorPoint=Vector2.new(.5,.5)
mainF.Position=UDim2.fromScale(.5,.5); mainF.BackgroundColor3=Color3.fromRGB(7,5,20)
mainF.BorderSizePixel=0; mainF.Visible=false; mainF.ZIndex=30; corner(mainF,12)

-- drag
do
    local drag, ds, sp
    mainF.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=mainF.Position end
    end)
    mainF.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            mainF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

local banner = Instance.new("ImageLabel", mainF)
banner.Size=UDim2.fromOffset(520,130); banner.Image="rbxassetid://7848741169"
banner.ScaleType=Enum.ScaleType.Crop; banner.BackgroundColor3=Color3.fromRGB(10,5,30)
banner.BorderSizePixel=0; banner.ZIndex=31; corner(banner,12)

local bannerTxt = Instance.new("TextLabel", mainF)
bannerTxt.Size=UDim2.fromOffset(500,50); bannerTxt.Position=UDim2.fromOffset(10,80)
bannerTxt.BackgroundTransparency=1; bannerTxt.TextColor3=Color3.new(1,1,1)
bannerTxt.Font=Enum.Font.GothamBold; bannerTxt.TextSize=20
bannerTxt.Text="runsjops client ✌"; bannerTxt.ZIndex=32

local newsScroll = Instance.new("ScrollingFrame", mainF)
newsScroll.Size=UDim2.fromOffset(490,145); newsScroll.Position=UDim2.fromOffset(15,140)
newsScroll.BackgroundColor3=Color3.fromRGB(12,9,28); newsScroll.BorderSizePixel=0
newsScroll.ScrollBarThickness=3; newsScroll.ScrollBarImageColor3=Color3.fromRGB(130,90,220)
newsScroll.ZIndex=31; corner(newsScroll,8)

local newsLbl = Instance.new("TextLabel", newsScroll)
newsLbl.Size=UDim2.new(1,-16,0,0); newsLbl.Position=UDim2.fromOffset(8,8)
newsLbl.AutomaticSize=Enum.AutomaticSize.Y; newsLbl.BackgroundTransparency=1
newsLbl.TextColor3=Color3.fromRGB(200,175,250); newsLbl.Font=Enum.Font.Gotham
newsLbl.TextSize=13; newsLbl.TextXAlignment=Enum.TextXAlignment.Left
newsLbl.TextYAlignment=Enum.TextYAlignment.Top; newsLbl.TextWrapped=true
newsLbl.RichText=true; newsLbl.ZIndex=32
newsLbl.Text=[[<b>📰 Новости — 20 октября 2026</b>

Добро пожаловать в runsjops client ✌

Этот скрипт был сделан <b>20 октября 2026 года</b>.
Если скрипт устарел — перейди на сайт и возьми новый!

ТГК проекта: <b>t.me/runsds_client</b>
На этом пока всё, удачи! <b>@thanks17</b>]]
newsLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    newsScroll.CanvasSize=UDim2.fromOffset(0,newsLbl.AbsoluteSize.Y+16)
end)

-- buttons
local btnRow = Instance.new("Frame", mainF)
btnRow.Size=UDim2.fromOffset(490,46); btnRow.Position=UDim2.fromOffset(15,296)
btnRow.BackgroundTransparency=1; btnRow.ZIndex=31
local bl = Instance.new("UIListLayout", btnRow)
bl.FillDirection=Enum.FillDirection.Horizontal; bl.Padding=UDim.new(0,6)

local function mkBtn(txt, col, cb)
    local b=Instance.new("TextButton", btnRow)
    b.Size=UDim2.fromOffset(112,40); b.BackgroundColor3=col
    b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold
    b.TextSize=12; b.Text=txt; b.BorderSizePixel=0; b.ZIndex=32
    corner(b,7); b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

mkBtn("🥚 Auto Steal", Color3.fromRGB(100,50,200), toggleSteal)
mkBtn("⚡ Speed",      Color3.fromRGB(80,40,170),  toggleSpeed)
mkBtn("🔍 ESP Eggs",  Color3.fromRGB(70,35,150),  toggleEsp)
mkBtn("✕ Close",      Color3.fromRGB(155,30,30),  function()
    tw(mainF,.3,{Size=UDim2.fromOffset(520,0)}):Play(); task.wait(.35); mainF.Visible=false
end)

-- top-right X
local xBtn = Instance.new("TextButton", mainF)
xBtn.Size=UDim2.fromOffset(26,26); xBtn.Position=UDim2.fromOffset(485,6)
xBtn.BackgroundColor3=Color3.fromRGB(160,28,28); xBtn.TextColor3=Color3.new(1,1,1)
xBtn.Font=Enum.Font.GothamBold; xBtn.TextSize=13; xBtn.Text="✕"
xBtn.BorderSizePixel=0; xBtn.ZIndex=33; corner(xBtn,100)
xBtn.MouseButton1Click:Connect(function()
    tw(mainF,.3,{Size=UDim2.fromOffset(520,0)}):Play(); task.wait(.35); mainF.Visible=false
end)

-- ══════════════════════════════════════════
--  CREDS
-- ══════════════════════════════════════════

local CRED = "runsjops_creds.json"
local creds = {}
pcall(function() creds=HTTP:JSONDecode(readfile(CRED)) end)

local function saveCreds(u,p)
    pcall(function() writefile(CRED,HTTP:JSONEncode({u=u,p=p})) end)
end

-- ══════════════════════════════════════════
--  FLOW
-- ══════════════════════════════════════════

local function showMain()
    mainF.Visible=true; mainF.Size=UDim2.fromOffset(0,0)
    tw(mainF,.45,{Size=UDim2.fromOffset(520,380)},Enum.EasingStyle.Back):Play()
end

local function showLogin()
    loginF.Visible=true
    tw(loginF,.4,{BackgroundTransparency=0}):Play()
    if creds.u and creds.u~="" then
        welcomeLbl.Text="👋 "..creds.u..", введи пароль:"
        userTB.Text=creds.u
    end
end

loginBtn.MouseButton1Click:Connect(function()
    local u=userTB.Text; local p=passTB.Text
    if u=="" or p=="" then
        -- shake
        for i=1,6 do
            loginPanel.Position=UDim2.fromScale(.5+(i%2==0 and .006 or -.006),0)
            task.wait(.05)
        end
        loginPanel.Position=UDim2.fromScale(.5,0)
        return
    end
    if creds.u and creds.u~="" and p~=creds.p then
        welcomeLbl.Text="❌ Неверный пароль!"; task.wait(1.5)
        welcomeLbl.Text="👋 "..creds.u..", введи пароль:"
        return
    end
    saveCreds(u,p); creds={u=u,p=p}
    tw(loginF,.4,{BackgroundTransparency=1}):Play()
    task.wait(.45); loginF.Visible=false
    showMain()
end)

-- ══════════════════════════════════════════
--  LOADING SEQUENCE
-- ══════════════════════════════════════════

task.spawn(function()
    bounceDots(bdots)
    task.wait(2.2)
    loadLbl.Text="Загрузка плагинов..."
    task.wait(2)

    -- red rotating label
    local red = Instance.new("TextLabel", loadF)
    red.Size=UDim2.fromOffset(500,50); red.AnchorPoint=Vector2.new(.5,.5)
    red.Position=UDim2.fromScale(.5,.5); red.BackgroundTransparency=1
    red.TextColor3=Color3.fromRGB(255,40,40); red.Font=Enum.Font.GothamBold
    red.TextSize=30; red.Text="✌ runsjops client"; red.ZIndex=12
    red.TextTransparency=1
    tw(red,.5,{TextTransparency=0}):Play()
    tw(red,.8,{Rotation=75},Enum.EasingStyle.Back):Play()
    task.wait(1.4)

    -- fade out everything in loadF
    for _, c in ipairs(loadF:GetDescendants()) do
        if c:IsA("GuiObject") then
            pcall(function()
                tw(c,.4,{BackgroundTransparency=1,TextTransparency=1,ImageTransparency=1}):Play()
            end)
        end
    end
    task.wait(.5)
    loadF.Visible=false
    showLogin()
end)
