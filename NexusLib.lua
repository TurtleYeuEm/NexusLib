--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗██╗     ██╗██████╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝██║     ██║██╔══██╗
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗██║     ██║██████╔╝
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║██║     ██║██╔══██╗
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║███████╗██║██████╔╝
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝╚═════╝
    
    NexusLib v1.1 — A Free UI Library for Roblox
    
    USAGE EXAMPLE:
    ──────────────
    local NexusLib = loadstring(game:HttpGet("RAW_URL"))()
    
    local Win = NexusLib:CreateWindow({
        Name     = "My Script",
        Subtitle = "v1.0",
        Theme    = "Dark",   -- "Dark" | "Midnight" | "Light"
    })
    
    local Tab = Win:CreateTab("Main")
    Tab:CreateSection("Combat")
    
    Tab:CreateToggle({
        Name         = "Auto Farm",
        CurrentValue = false,
        Callback     = function(v) print("AutoFarm:", v) end,
    })
    
    Tab:CreateSlider({
        Name         = "WalkSpeed",
        Range        = {0, 100},
        Increment    = 1,
        CurrentValue = 16,
        Callback     = function(v)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
        end,
    })
    
    Tab:CreateButton({
        Name     = "Teleport",
        Callback = function() print("TP!") end,
    })
    
    Tab:CreateDropdown({
        Name    = "Team",
        Options = {"Red","Blue","Green"},
        Callback = function(v) print("Team:", v) end,
    })
    
    Tab:CreateInput({
        Name            = "Set Name",
        PlaceholderText = "Enter name...",
        Callback        = function(v) print("Name:", v) end,
    })
    
    Win:Notify({
        Title   = "Loaded!",
        Content = "NexusLib ready.",
        Duration = 4,
    })
]]

local NexusLib = {}
NexusLib.__index = NexusLib

-- ── Services ────────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ── Helpers ─────────────────────────────────────────────────────────────────
local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play(); return t
end

local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function MakeDraggable(handle, frame)
    local drag, mousePos, framePos = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; mousePos = i.Position; framePos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    local dragInput
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dragInput and drag then
            local d = i.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + d.X,
                framePos.Y.Scale, framePos.Y.Offset + d.Y)
        end
    end)
end

-- ── Themes ───────────────────────────────────────────────────────────────────
local Themes = {
    Dark = {
        Bg         = Color3.fromRGB(22, 22, 32),
        TopBar     = Color3.fromRGB(16, 16, 25),
        TabBg      = Color3.fromRGB(14, 14, 22),
        El         = Color3.fromRGB(30, 30, 46),
        ElHover    = Color3.fromRGB(38, 38, 58),
        Accent     = Color3.fromRGB(108, 140, 255),
        AccentD    = Color3.fromRGB(74, 105, 220),
        TextP      = Color3.fromRGB(238, 238, 255),
        TextS      = Color3.fromRGB(155, 155, 195),
        TextM      = Color3.fromRGB(88,  88, 125),
        Border     = Color3.fromRGB(42,  42,  65),
        ToggleOn   = Color3.fromRGB(108, 140, 255),
        ToggleOff  = Color3.fromRGB(52,  52,  80),
        Drop       = Color3.fromRGB(24,  24,  38),
        Input      = Color3.fromRGB(18,  18,  28),
        Notif      = Color3.fromRGB(26,  26,  40),
    },
    Midnight = {
        Bg         = Color3.fromRGB(9,  9, 16),
        TopBar     = Color3.fromRGB(6,  6, 11),
        TabBg      = Color3.fromRGB(5,  5,  9),
        El         = Color3.fromRGB(15, 15, 26),
        ElHover    = Color3.fromRGB(22, 22, 36),
        Accent     = Color3.fromRGB(185, 105, 255),
        AccentD    = Color3.fromRGB(140,  70, 210),
        TextP      = Color3.fromRGB(228, 218, 255),
        TextS      = Color3.fromRGB(148, 138, 195),
        TextM      = Color3.fromRGB(85,  80, 120),
        Border     = Color3.fromRGB(28,  28,  50),
        ToggleOn   = Color3.fromRGB(185, 105, 255),
        ToggleOff  = Color3.fromRGB(42,  42,  72),
        Drop       = Color3.fromRGB(12,  12,  22),
        Input      = Color3.fromRGB(10,  10,  18),
        Notif      = Color3.fromRGB(14,  14,  26),
    },
    Light = {
        Bg         = Color3.fromRGB(244, 244, 252),
        TopBar     = Color3.fromRGB(234, 234, 248),
        TabBg      = Color3.fromRGB(226, 226, 242),
        El         = Color3.fromRGB(255, 255, 255),
        ElHover    = Color3.fromRGB(248, 248, 255),
        Accent     = Color3.fromRGB(80,  110, 240),
        AccentD    = Color3.fromRGB(55,   85, 210),
        TextP      = Color3.fromRGB(18,   18,  40),
        TextS      = Color3.fromRGB(80,   80, 120),
        TextM      = Color3.fromRGB(145, 145, 185),
        Border     = Color3.fromRGB(208, 208, 235),
        ToggleOn   = Color3.fromRGB(80,  110, 240),
        ToggleOff  = Color3.fromRGB(188, 188, 215),
        Drop       = Color3.fromRGB(248, 248, 255),
        Input      = Color3.fromRGB(238, 238, 252),
        Notif      = Color3.fromRGB(244, 244, 255),
    },
}

-- ════════════════════════════════════════════════════════════════════════════
--  CreateWindow
-- ════════════════════════════════════════════════════════════════════════════
function NexusLib:CreateWindow(cfg)
    cfg = cfg or {}
    local Name      = cfg.Name          or "NexusLib"
    local Subtitle  = cfg.Subtitle      or "UI Library"
    local LTitle    = cfg.LoadingTitle  or Name
    local LSub      = cfg.LoadingSubtitle or "Loading..."
    local T         = Themes[cfg.Theme] or Themes.Dark

    -- Destroy previous GUI
    pcall(function() CoreGui["NexusLib_"..Name]:Destroy() end)

    local gui = New("ScreenGui", {
        Name            = "NexusLib_"..Name,
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = RunService:IsStudio() and LocalPlayer.PlayerGui or CoreGui,
    })

    -- ── Loading Screen ────────────────────────────────────────────────────
    local LoadF = New("Frame", {
        Size = UDim2.new(0,340,0,182), AnchorPoint = Vector2.new(.5,.5),
        Position = UDim2.new(.5,0,.5,0), BackgroundColor3 = T.Bg,
        BorderSizePixel = 0, Parent = gui,
    })
    New("UICorner", {CornerRadius=UDim.new(0,16), Parent=LoadF})
    New("UIStroke", {Color=T.Border, Thickness=1, Parent=LoadF})

    local accentBar = New("Frame",{Size=UDim2.new(1,0,0,3),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=LoadF})
    New("UICorner",{CornerRadius=UDim.new(0,3),Parent=accentBar})
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Parent=accentBar})

    local icon = New("Frame",{Size=UDim2.new(0,46,0,46),Position=UDim2.new(.5,-23,0,28),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=LoadF})
    New("UICorner",{CornerRadius=UDim.new(0,12),Parent=icon})
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Rotation=45,Parent=icon})
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=string.sub(LTitle,1,1),TextColor3=Color3.new(1,1,1),TextSize=22,Font=Enum.Font.GothamBold,Parent=icon})

    New("TextLabel",{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0,86),BackgroundTransparency=1,Text=LTitle,TextColor3=T.TextP,TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,Parent=LoadF})
    New("TextLabel",{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,110),BackgroundTransparency=1,Text=LSub,TextColor3=T.TextS,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,Parent=LoadF})

    local pgBg = New("Frame",{Size=UDim2.new(1,-40,0,4),Position=UDim2.new(0,20,0,150),BackgroundColor3=T.Border,BorderSizePixel=0,Parent=LoadF})
    New("UICorner",{CornerRadius=UDim.new(1,0),Parent=pgBg})
    local pgFill = New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=pgBg})
    New("UICorner",{CornerRadius=UDim.new(1,0),Parent=pgFill})
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Parent=pgFill})

    Tween(pgFill, TweenInfo.new(1.6,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(1,0,1,0)})

    local spinning = true
    task.spawn(function()
        local a=0
        while spinning do a+=2; icon.Rotation=a; task.wait(1/60) end
    end)

    task.wait(1.9)
    spinning = false

    -- fade out loader
    local fadeInfo = TweenInfo.new(0.35,Enum.EasingStyle.Quad)
    Tween(LoadF, fadeInfo, {BackgroundTransparency=1})
    for _,d in pairs(LoadF:GetDescendants()) do
        pcall(function()
            if d:IsA("TextLabel") then
                Tween(d,fadeInfo,{TextTransparency=1,BackgroundTransparency=1})
            else
                Tween(d,fadeInfo,{BackgroundTransparency=1})
            end
        end)
    end
    task.wait(0.4); LoadF:Destroy()

    -- ── Main Frame ────────────────────────────────────────────────────────
    local Main = New("Frame",{
        Name="Main", Size=UDim2.new(0,630,0,0),
        Position=UDim2.new(.5,-315,.5,0),
        BackgroundColor3=T.Bg, BorderSizePixel=0,
        ClipsDescendants=true, Parent=gui,
    })
    New("UICorner",{CornerRadius=UDim.new(0,14),Parent=Main})
    New("UIStroke",{Color=T.Border,Thickness=1,Parent=Main})

    -- Accent top stripe
    local stripe = New("Frame",{Size=UDim2.new(1,0,0,3),BackgroundColor3=T.Accent,BorderSizePixel=0,ZIndex=5,Parent=Main})
    New("UIGradient",{Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,T.Accent),
        ColorSequenceKeypoint.new(.5,Color3.fromRGB(200,185,255)),
        ColorSequenceKeypoint.new(1,T.AccentD),
    },Parent=stripe})

    -- TopBar
    local TopBar = New("Frame",{
        Size=UDim2.new(1,0,0,50), Position=UDim2.new(0,0,0,3),
        BackgroundColor3=T.TopBar, BorderSizePixel=0, Parent=Main,
    })
    MakeDraggable(TopBar, Main)

    -- Logo badge
    local badge = New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,14,0.5,-15),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=TopBar})
    New("UICorner",{CornerRadius=UDim.new(0,8),Parent=badge})
    New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Rotation=135,Parent=badge})
    New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=string.sub(Name,1,1),TextColor3=Color3.new(1,1,1),TextSize=14,Font=Enum.Font.GothamBold,Parent=badge})

    New("TextLabel",{Size=UDim2.new(0,260,0,22),Position=UDim2.new(0,52,0,6),BackgroundTransparency=1,Text=Name,TextColor3=T.TextP,TextSize=15,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopBar})
    New("TextLabel",{Size=UDim2.new(0,260,0,18),Position=UDim2.new(0,52,0,27),BackgroundTransparency=1,Text=Subtitle,TextColor3=T.TextS,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopBar})

    -- Controls
    local function MakeCtrlBtn(xOff, bgCol, txt)
        local b = New("TextButton",{
            Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,xOff,0.5,-14),
            BackgroundColor3=bgCol, Text=txt,
            TextColor3=Color3.new(1,1,1), TextSize=16, Font=Enum.Font.GothamBold,
            BorderSizePixel=0, Parent=TopBar,
        })
        New("UICorner",{CornerRadius=UDim.new(0,8),Parent=b})
        return b
    end

    local CloseBtn = MakeCtrlBtn(-42, Color3.fromRGB(255,70,70), "×")
    local MinBtn   = MakeCtrlBtn(-76, T.El, "−")

    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn,TweenInfo.new(.12),{BackgroundColor3=Color3.fromRGB(215,45,45)}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn,TweenInfo.new(.12),{BackgroundColor3=Color3.fromRGB(255,70,70)}) end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main,TweenInfo.new(.3,Enum.EasingStyle.Quad),{Size=UDim2.new(0,630,0,0),Position=UDim2.new(.5,-315,.5,0)})
        task.wait(.35); gui:Destroy()
    end)

    local minimized=false
    MinBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        Tween(Main,TweenInfo.new(.3,Enum.EasingStyle.Quart), {Size=UDim2.new(0,630,0,minimized and 53 or 450)})
        MinBtn.Text = minimized and "+" or "−"
    end)

    -- Sidebar
    local Sidebar = New("Frame",{
        Size=UDim2.new(0,158,1,-53), Position=UDim2.new(0,0,0,53),
        BackgroundColor3=T.TabBg, BorderSizePixel=0, Parent=Main,
    })
    local TabList = New("ScrollingFrame",{
        Size=UDim2.new(1,-10,1,-16), Position=UDim2.new(0,5,0,10),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=Sidebar,
    })
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5),Parent=TabList})

    -- Content area
    local Content = New("Frame",{
        Size=UDim2.new(1,-158,1,-53), Position=UDim2.new(0,158,0,53),
        BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true, Parent=Main,
    })
    New("Frame",{Size=UDim2.new(0,1,1,0),BackgroundColor3=T.Border,BorderSizePixel=0,Parent=Content})

    -- ── Notification Container ─────────────────────────────────────────────
    local NotifHolder = New("Frame",{
        Size=UDim2.new(0,300,1,0), Position=UDim2.new(1,-316,0,0),
        BackgroundTransparency=1, Parent=gui,
    })
    local notifLayout = New("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        Padding=UDim.new(0,8), Parent=NotifHolder,
    })
    New("UIPadding",{PaddingBottom=UDim.new(0,16),Parent=NotifHolder})

    -- ── Window Object ──────────────────────────────────────────────────────
    local Window  = {}
    local ActiveTab = nil
    local TabCount  = 0

    function Window:Notify(c)
        c=c or {}
        local N=New("Frame",{
            Size=UDim2.new(1,0,0,68), BackgroundColor3=T.Notif,
            BorderSizePixel=0, Parent=NotifHolder,
        })
        New("UICorner",{CornerRadius=UDim.new(0,12),Parent=N})
        New("UIStroke",{Color=T.Border,Thickness=1,Parent=N})
        local acc=New("Frame",{Size=UDim2.new(0,3,1,-16),Position=UDim2.new(0,0,0,8),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=N})
        New("UICorner",{CornerRadius=UDim.new(1,0),Parent=acc})
        New("TextLabel",{Size=UDim2.new(1,-28,0,20),Position=UDim2.new(0,16,0,11),BackgroundTransparency=1,Text=c.Title or"Notification",TextColor3=T.TextP,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=N})
        New("TextLabel",{Size=UDim2.new(1,-28,0,26),Position=UDim2.new(0,16,0,31),BackgroundTransparency=1,Text=c.Content or"",TextColor3=T.TextS,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=N})
        N.Position=UDim2.new(0,310,1,0)
        Tween(N,TweenInfo.new(.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,1,0)})
        task.delay(c.Duration or 4,function()
            Tween(N,TweenInfo.new(.3,Enum.EasingStyle.Quad),{Position=UDim2.new(0,310,1,0)})
            task.wait(.35); N:Destroy()
        end)
    end

    -- ── CreateTab ─────────────────────────────────────────────────────────
    function Window:CreateTab(tabName)
        tabName = tabName or "Tab"
        TabCount += 1

        local TabScroll = New("ScrollingFrame",{
            Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,10,0,0),
            BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3, ScrollBarImageColor3=T.Accent,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false, Parent=Content,
        })
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7),Parent=TabScroll})
        New("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingRight=UDim.new(0,8),Parent=TabScroll})

        -- Sidebar button
        local TabBtn=New("TextButton",{
            Size=UDim2.new(1,0,0,38), BackgroundColor3=T.TabBg,
            Text="", BorderSizePixel=0, Parent=TabList,
        })
        New("UICorner",{CornerRadius=UDim.new(0,10),Parent=TabBtn})
        local TBLabel=New("TextLabel",{
            Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,16,0,0),
            BackgroundTransparency=1, Text=tabName,
            TextColor3=T.TextS, TextSize=13, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, Parent=TabBtn,
        })
        local TBDot=New("Frame",{
            Size=UDim2.new(0,3,0,20), Position=UDim2.new(0,0,.5,-10),
            BackgroundColor3=T.Accent, BorderSizePixel=0, Visible=false, Parent=TabBtn,
        })
        New("UICorner",{CornerRadius=UDim.new(1,0),Parent=TBDot})

        local thisTab = {Frame=TabScroll, Btn=TabBtn, Lbl=TBLabel, Dot=TBDot}

        local function Activate()
            if ActiveTab then
                ActiveTab.Frame.Visible=false
                Tween(ActiveTab.Btn,TweenInfo.new(.18),{BackgroundColor3=T.TabBg})
                Tween(ActiveTab.Lbl,TweenInfo.new(.18),{TextColor3=T.TextS})
                ActiveTab.Lbl.Font=Enum.Font.Gotham
                ActiveTab.Dot.Visible=false
            end
            TabScroll.Visible=true
            Tween(TabBtn,TweenInfo.new(.18),{BackgroundColor3=T.El})
            TBLabel.Font=Enum.Font.GothamBold
            Tween(TBLabel,TweenInfo.new(.18),{TextColor3=T.TextP})
            TBDot.Visible=true
            ActiveTab=thisTab
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if ActiveTab~=thisTab then Tween(TabBtn,TweenInfo.new(.12),{BackgroundColor3=T.ElHover}) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveTab~=thisTab then Tween(TabBtn,TweenInfo.new(.12),{BackgroundColor3=T.TabBg}) end
        end)
        if TabCount==1 then Activate() end

        -- ── Element helpers ────────────────────────────────────────────────
        local Tab={}

        local function ElBase(h)
            local f=New("Frame",{
                Size=UDim2.new(1,0,0,h or 46),
                BackgroundColor3=T.El, BorderSizePixel=0, Parent=TabScroll,
            })
            New("UICorner",{CornerRadius=UDim.new(0,10),Parent=f})
            f.MouseEnter:Connect(function() Tween(f,TweenInfo.new(.12),{BackgroundColor3=T.ElHover}) end)
            f.MouseLeave:Connect(function() Tween(f,TweenInfo.new(.12),{BackgroundColor3=T.El}) end)
            return f
        end

        local function Label(parent,text,col,sz,fnt,pos,size,xa,wrap,zi)
            local l=New("TextLabel",{
                Size=size or UDim2.new(1,-28,1,0),
                Position=pos or UDim2.new(0,14,0,0),
                BackgroundTransparency=1, Text=text,
                TextColor3=col or T.TextP, TextSize=sz or 13,
                Font=fnt or Enum.Font.GothamSemibold,
                TextXAlignment=xa or Enum.TextXAlignment.Left,
                TextWrapped=wrap or false,
                ZIndex=zi or 1, Parent=parent,
            })
            return l
        end

        -- ── SECTION ───────────────────────────────────────────────────────
        function Tab:CreateSection(n)
            local s=New("TextLabel",{
                Size=UDim2.new(1,0,0,22), BackgroundTransparency=1,
                Text=string.upper(n or "SECTION"), TextColor3=T.TextM,
                TextSize=10, Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=TabScroll,
            })
            New("UIPadding",{PaddingLeft=UDim.new(0,4),Parent=s})
        end

        -- ── SEPARATOR ─────────────────────────────────────────────────────
        function Tab:CreateSeparator()
            New("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,BorderSizePixel=0,Parent=TabScroll})
        end

        -- ── LABEL ─────────────────────────────────────────────────────────
        function Tab:CreateLabel(text)
            local f=ElBase(36)
            Label(f,text,T.TextS,12,Enum.Font.Gotham,UDim2.new(0,14,0,0),UDim2.new(1,-28,1,0),Enum.TextXAlignment.Left,true)
        end

        -- ── BUTTON ────────────────────────────────────────────────────────
        function Tab:CreateButton(c)
            c=c or {}
            local h = c.Description and 62 or 46
            local f=ElBase(h)
            Label(f,c.Name or "Button",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,0),UDim2.new(1,-95,1,0))
            if c.Description then
                Label(f,c.Description,T.TextM,10,Enum.Font.Gotham,UDim2.new(0,14,0,30),UDim2.new(1,-95,0,18))
            end
            local btn=New("TextButton",{
                Size=UDim2.new(0,70,0,28), Position=UDim2.new(1,-82,.5,-14),
                BackgroundColor3=T.Accent, Text="Run",
                TextColor3=Color3.new(1,1,1), TextSize=12, Font=Enum.Font.GothamBold,
                BorderSizePixel=0, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,8),Parent=btn})
            New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Rotation=90,Parent=btn})
            btn.MouseEnter:Connect(function() Tween(btn,TweenInfo.new(.12),{BackgroundColor3=T.AccentD}) end)
            btn.MouseLeave:Connect(function() Tween(btn,TweenInfo.new(.12),{BackgroundColor3=T.Accent}) end)
            btn.MouseButton1Click:Connect(function()
                Tween(btn,TweenInfo.new(.08),{Size=UDim2.new(0,62,0,24),Position=UDim2.new(1,-79,.5,-12)})
                task.wait(.1)
                Tween(btn,TweenInfo.new(.12),{Size=UDim2.new(0,70,0,28),Position=UDim2.new(1,-82,.5,-14)})
                if c.Callback then pcall(c.Callback) end
            end)
        end

        -- ── TOGGLE ────────────────────────────────────────────────────────
        function Tab:CreateToggle(c)
            c=c or {}
            local state=c.CurrentValue or false
            local f=ElBase(46)
            Label(f,c.Name or "Toggle",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,0),UDim2.new(1,-70,1,0))

            local bg=New("Frame",{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-58,.5,-12),BackgroundColor3=state and T.ToggleOn or T.ToggleOff,BorderSizePixel=0,Parent=f})
            New("UICorner",{CornerRadius=UDim.new(1,0),Parent=bg})
            local knob=New("Frame",{Size=UDim2.new(0,18,0,18),Position=state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=bg})
            New("UICorner",{CornerRadius=UDim.new(1,0),Parent=knob})

            local overlay=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=f})
            overlay.MouseButton1Click:Connect(function()
                state=not state
                Tween(bg,TweenInfo.new(.2,Enum.EasingStyle.Quad),{BackgroundColor3=state and T.ToggleOn or T.ToggleOff})
                Tween(knob,TweenInfo.new(.2,Enum.EasingStyle.Quart),{Position=state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)})
                if c.Callback then pcall(c.Callback,state) end
            end)

            local Obj={}
            function Obj:Set(v)
                state=v
                Tween(bg,TweenInfo.new(.2,Enum.EasingStyle.Quad),{BackgroundColor3=state and T.ToggleOn or T.ToggleOff})
                Tween(knob,TweenInfo.new(.2,Enum.EasingStyle.Quart),{Position=state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)})
            end
            return Obj
        end

        -- ── SLIDER ────────────────────────────────────────────────────────
        function Tab:CreateSlider(c)
            c=c or {}
            local mn=c.Range and c.Range[1] or 0
            local mx=c.Range and c.Range[2] or 100
            local inc=c.Increment or 1
            local val=c.CurrentValue or mn

            local f=ElBase(64)
            Label(f,c.Name or "Slider",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,10),UDim2.new(1,-80,0,20))
            local valLbl=New("TextLabel",{Size=UDim2.new(0,58,0,20),Position=UDim2.new(1,-72,0,10),BackgroundTransparency=1,Text=tostring(val),TextColor3=T.Accent,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,Parent=f})

            local track=New("Frame",{Size=UDim2.new(1,-28,0,5),Position=UDim2.new(0,14,0,42),BackgroundColor3=T.Border,BorderSizePixel=0,Parent=f})
            New("UICorner",{CornerRadius=UDim.new(1,0),Parent=track})

            local pct=(val-mn)/(mx-mn)
            local fill=New("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=track})
            New("UICorner",{CornerRadius=UDim.new(1,0),Parent=fill})
            New("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentD)},Parent=fill})

            local knob=New("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(pct,-7,.5,-7),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Parent=track})
            New("UICorner",{CornerRadius=UDim.new(1,0),Parent=knob})
            New("UIStroke",{Color=T.Accent,Thickness=2,Parent=knob})

            local dragging=false
            local hitbox=New("TextButton",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,-8),BackgroundTransparency=1,Text="",Parent=track})

            local function update(i)
                local x=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                local snapped=math.clamp(math.round((mn+x*(mx-mn))/inc)*inc,mn,mx)
                val=snapped; local p=(snapped-mn)/(mx-mn)
                Tween(fill,TweenInfo.new(.05),{Size=UDim2.new(p,0,1,0)})
                Tween(knob,TweenInfo.new(.05),{Position=UDim2.new(p,-7,.5,-7)})
                valLbl.Text=tostring(snapped)
                if c.Callback then pcall(c.Callback,snapped) end
            end

            hitbox.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i) end
            end)
            local di
            hitbox.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement then di=i end
            end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i==di then update(i) end end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
            end)

            local Obj={}
            function Obj:Set(v)
                val=math.clamp(v,mn,mx); local p=(val-mn)/(mx-mn)
                Tween(fill,TweenInfo.new(.2),{Size=UDim2.new(p,0,1,0)})
                Tween(knob,TweenInfo.new(.2),{Position=UDim2.new(p,-7,.5,-7)})
                valLbl.Text=tostring(val)
            end
            return Obj
        end

        -- ── INPUT ─────────────────────────────────────────────────────────
        function Tab:CreateInput(c)
            c=c or {}
            local f=ElBase(56)
            Label(f,c.Name or "Input",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,8),UDim2.new(1,-28,0,18))
            local box=New("TextBox",{
                Size=UDim2.new(1,-28,0,23),Position=UDim2.new(0,14,0,28),
                BackgroundColor3=T.Input, PlaceholderText=c.PlaceholderText or "Type here...",
                PlaceholderColor3=T.TextM, Text=c.CurrentValue or "",
                TextColor3=T.TextP, TextSize=12, Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
                BorderSizePixel=0, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,6),Parent=box})
            New("UIStroke",{Color=T.Border,Thickness=1,Parent=box})
            New("UIPadding",{PaddingLeft=UDim.new(0,8),Parent=box})

            box.Focused:Connect(function()
                Tween(box,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(
                    T.Input.R*255+8, T.Input.G*255+8, T.Input.B*255+12)})
            end)
            box.FocusLost:Connect(function(enter)
                Tween(box,TweenInfo.new(.15),{BackgroundColor3=T.Input})
                if enter and c.Callback then pcall(c.Callback,box.Text) end
                if c.RemoveTextAfterFocusLost then box.Text="" end
            end)
        end

        -- ── DROPDOWN ──────────────────────────────────────────────────────
        function Tab:CreateDropdown(c)
            c=c or {}
            local opts=c.Options or {}
            local sel=c.CurrentOption
            local open=false

            local f=New("Frame",{
                Size=UDim2.new(1,0,0,46), BackgroundColor3=T.El,
                BorderSizePixel=0, ClipsDescendants=false, ZIndex=3, Parent=TabScroll,
            })
            New("UICorner",{CornerRadius=UDim.new(0,10),Parent=f})
            f.MouseEnter:Connect(function() Tween(f,TweenInfo.new(.12),{BackgroundColor3=T.ElHover}) end)
            f.MouseLeave:Connect(function() Tween(f,TweenInfo.new(.12),{BackgroundColor3=T.El}) end)

            Label(f,c.Name or "Dropdown",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,0),UDim2.new(1,-130,1,0),nil,nil,3)

            local dropBtn=New("TextButton",{
                Size=UDim2.new(0,112,0,28), Position=UDim2.new(1,-124,.5,-14),
                BackgroundColor3=T.Drop, Text=sel or "Select...",
                TextColor3=sel and T.TextP or T.TextM, TextSize=11, Font=Enum.Font.Gotham,
                BorderSizePixel=0, ZIndex=3, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,8),Parent=dropBtn})
            New("UIStroke",{Color=T.Border,Thickness=1,Parent=dropBtn})

            local list=New("Frame",{
                Size=UDim2.new(0,112,0,0), Position=UDim2.new(1,-124,1,4),
                BackgroundColor3=T.Drop, BorderSizePixel=0,
                ClipsDescendants=true, ZIndex=10, Visible=false, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,8),Parent=list})
            New("UIStroke",{Color=T.Border,Thickness=1,Parent=list})

            local scroll=New("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
                BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=T.Accent,
                ZIndex=10, Parent=list,
            })
            New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=scroll})

            local function AddOpt(o)
                local ob=New("TextButton",{
                    Size=UDim2.new(1,0,0,30), BackgroundTransparency=1,
                    Text=o, TextColor3=T.TextS, TextSize=12, Font=Enum.Font.Gotham,
                    ZIndex=11, Parent=scroll,
                })
                ob.MouseEnter:Connect(function() Tween(ob,TweenInfo.new(.1),{BackgroundTransparency=0,BackgroundColor3=T.ElHover}) end)
                ob.MouseLeave:Connect(function() Tween(ob,TweenInfo.new(.1),{BackgroundTransparency=1}) end)
                ob.MouseButton1Click:Connect(function()
                    sel=o; dropBtn.Text=o; dropBtn.TextColor3=T.TextP
                    open=false
                    Tween(list,TweenInfo.new(.2,Enum.EasingStyle.Quart),{Size=UDim2.new(0,112,0,0)})
                    task.wait(.22); list.Visible=false
                    if c.Callback then pcall(c.Callback,o) end
                end)
            end
            for _,o in ipairs(opts) do AddOpt(o) end
            scroll.CanvasSize=UDim2.new(0,0,0,#opts*30)

            dropBtn.MouseButton1Click:Connect(function()
                open=not open
                if open then
                    list.Visible=true; list.Size=UDim2.new(0,112,0,0)
                    Tween(list,TweenInfo.new(.25,Enum.EasingStyle.Quart),{Size=UDim2.new(0,112,0,math.min(#opts*30,150))})
                else
                    Tween(list,TweenInfo.new(.2,Enum.EasingStyle.Quart),{Size=UDim2.new(0,112,0,0)})
                    task.wait(.22); list.Visible=false
                end
            end)

            local Obj={}
            function Obj:Set(v) sel=v; dropBtn.Text=v; dropBtn.TextColor3=T.TextP end
            function Obj:Refresh(newOpts)
                opts=newOpts
                for _,ch in pairs(scroll:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _,o in ipairs(opts) do AddOpt(o) end
                scroll.CanvasSize=UDim2.new(0,0,0,#opts*30)
            end
            return Obj
        end

        -- ── KEYBIND ───────────────────────────────────────────────────────
        function Tab:CreateKeybind(c)
            c=c or {}
            local key=c.CurrentKeybind or "None"
            local listening=false
            local f=ElBase(46)
            Label(f,c.Name or "Keybind",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,0),UDim2.new(1,-100,1,0))

            local kBtn=New("TextButton",{
                Size=UDim2.new(0,84,0,28), Position=UDim2.new(1,-96,.5,-14),
                BackgroundColor3=T.Drop, Text="["..key.."]",
                TextColor3=T.Accent, TextSize=12, Font=Enum.Font.GothamBold,
                BorderSizePixel=0, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,8),Parent=kBtn})
            New("UIStroke",{Color=T.Border,Thickness=1,Parent=kBtn})

            kBtn.MouseButton1Click:Connect(function()
                listening=true; kBtn.Text="..."; kBtn.TextColor3=T.TextM
            end)
            UserInputService.InputBegan:Connect(function(i,gp)
                if gp then return end
                if listening then
                    key=i.KeyCode.Name; listening=false
                    kBtn.Text="["..key.."]"; kBtn.TextColor3=T.Accent
                    if c.Callback then pcall(c.Callback,i.KeyCode) end
                elseif i.KeyCode==Enum.KeyCode[key] then
                    if c.HoldCallback then pcall(c.HoldCallback) end
                end
            end)
        end

        -- ── COLOR PICKER ─────────────────────────────────────────────────
        function Tab:CreateColorPicker(c)
            c=c or {}
            local color=c.Color or Color3.fromRGB(255,255,255)
            local f=ElBase(46)
            Label(f,c.Name or "Color",T.TextP,13,Enum.Font.GothamSemibold,UDim2.new(0,14,0,0),UDim2.new(1,-65,1,0))

            local preview=New("Frame",{
                Size=UDim2.new(0,36,0,28), Position=UDim2.new(1,-50,.5,-14),
                BackgroundColor3=color, BorderSizePixel=0, Parent=f,
            })
            New("UICorner",{CornerRadius=UDim.new(0,8),Parent=preview})
            New("UIStroke",{Color=T.Border,Thickness=1,Parent=preview})

            -- Simple hex input on click
            local inp=New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=preview})
            inp.MouseButton1Click:Connect(function()
                -- Open a tiny hex popup
                local popup=New("Frame",{
                    Size=UDim2.new(0,150,0,42), Position=UDim2.new(1,-200,1,4),
                    BackgroundColor3=T.Drop, BorderSizePixel=0, ZIndex=20, Parent=f,
                })
                New("UICorner",{CornerRadius=UDim.new(0,8),Parent=popup})
                New("UIStroke",{Color=T.Border,Thickness=1,Parent=popup})
                local hexBox=New("TextBox",{
                    Size=UDim2.new(1,-16,0,26), Position=UDim2.new(0,8,0,8),
                    BackgroundColor3=T.Input, PlaceholderText="#RRGGBB",
                    PlaceholderColor3=T.TextM, Text="",
                    TextColor3=T.TextP, TextSize=12, Font=Enum.Font.GothamBold,
                    BorderSizePixel=0, ZIndex=21, Parent=popup,
                })
                New("UICorner",{CornerRadius=UDim.new(0,6),Parent=hexBox})
                New("UIPadding",{PaddingLeft=UDim.new(0,6),Parent=hexBox})
                hexBox.FocusLost:Connect(function()
                    local h=hexBox.Text:gsub("#","")
                    if #h==6 then
                        local r=tonumber(h:sub(1,2),16)
                        local g=tonumber(h:sub(3,4),16)
                        local b=tonumber(h:sub(5,6),16)
                        if r and g and b then
                            color=Color3.fromRGB(r,g,b)
                            Tween(preview,TweenInfo.new(.2),{BackgroundColor3=color})
                            if c.Callback then pcall(c.Callback,color) end
                        end
                    end
                    popup:Destroy()
                end)
                task.wait(.05); hexBox:CaptureFocus()
            end)
        end

        return Tab
    end

    -- ── Open animation ─────────────────────────────────────────────────────
    Tween(Main, TweenInfo.new(.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {
        Size=UDim2.new(0,630,0,450),
        Position=UDim2.new(.5,-315,.5,-225),
    })

    return Window
end

return NexusLib