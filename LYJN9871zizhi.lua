repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end

pcall(function()
	if _G.ThunderIntro_Stop then _G.ThunderIntro_Stop() end
end)

local function resolveGuiParent()
	local ok, res = pcall(function() return (gethui and gethui()) end)
	if ok and res then return res end
	ok, res = pcall(function() return (get_hidden_gui and get_hidden_gui()) end)
	if ok and res then return res end
	ok, res = pcall(function() return (gethiddengui and gethiddengui()) end)
	if ok and res then return res end
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
	if pg then return pg end
	return game:GetService("CoreGui")
end

local guiParent = resolveGuiParent()

local BLUE  = Color3.fromRGB(64, 145, 255)

local function Start(opts)
	opts = opts or {}
	local SIZE            = opts.size or 210
	local STROKE_THICK    = 18
	local CORNER          = 18
	local DURATION        = opts.duration or 6 
	local SPIN_STEP_DEG   = 90
	local SPIN_STEP_TIME  = 0.90
	local BREATH_MIN, BREATH_MAX = 0.98, 1.02

	local gui = Instance.new("ScreenGui")
	gui.Name = "ThunderIntro"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
	local ok = pcall(function() gui.Parent = guiParent end)
	if not ok then
		local fallback = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
		if fallback then gui.Parent = fallback end
	end

	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(SIZE, SIZE)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.Parent = gui

	local ring = Instance.new("Frame")
	ring.Size = UDim2.fromScale(1, 1)
	ring.BackgroundTransparency = 1
	ring.Parent = root
	local cornerRing = Instance.new("UICorner") cornerRing.CornerRadius = UDim.new(0, CORNER) cornerRing.Parent = ring
	local ringStroke = Instance.new("UIStroke")
	ringStroke.Thickness = STROKE_THICK
	ringStroke.Color = BLUE
	pcall(function() ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	ringStroke.Parent = ring

	local glow = Instance.new("Frame")
	glow.Size = UDim2.fromScale(1, 1)
	glow.BackgroundTransparency = 1
	glow.ZIndex = ring.ZIndex - 1
	glow.Parent = root
	local cornerGlow = Instance.new("UICorner") cornerGlow.CornerRadius = UDim.new(0, CORNER) cornerGlow.Parent = glow
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Thickness = 30
	glowStroke.Color = BLUE
	glowStroke.Transparency = 0.75
	pcall(function() glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end)
	glowStroke.Parent = glow

	local inner = Instance.new("Frame")
	local innerSize = SIZE - STROKE_THICK * 2
	inner.Size = UDim2.fromOffset(innerSize, innerSize)
	inner.AnchorPoint = Vector2.new(0.5, 0.5)
	inner.Position = UDim2.fromScale(0.5, 0.5)
	inner.BackgroundTransparency = 1
	inner.ZIndex = 5
	inner.Parent = root

	
	local thunderText = Instance.new("TextLabel")
	thunderText.Size = UDim2.fromScale(0.7, 0.7)
	thunderText.AnchorPoint = Vector2.new(0.5, 0.5)
	thunderText.Position = UDim2.fromScale(0.5, 0.5)
	thunderText.BackgroundTransparency = 1
	thunderText.Text = "Sa Hub"
	thunderText.TextColor3 = BLUE
	thunderText.TextScaled = true
	thunderText.Font = Enum.Font.GothamBlack
	thunderText.Rotation = -8.56
	thunderText.TextTransparency = 0.10
	thunderText.ZIndex = 7
	thunderText.Parent = inner

	
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,220,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
	}
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	}
	gradient.Parent = thunderText

	local ringScale = Instance.new("UIScale", ring) ringScale.Scale = 1

	local alive, hbConn = true, nil
	_G.ThunderIntro_Stop = function()
		if not alive then return end
		alive = false
		if hbConn then hbConn:Disconnect() end
		if gui and gui.Parent then gui:Destroy() end
	end
	
	-- Spin
	task.spawn(function()
		while alive do
			local tw1 = TweenService:Create(ring, TweenInfo.new(SPIN_STEP_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = ring.Rotation + SPIN_STEP_DEG})
			local tw2 = TweenService:Create(glow, TweenInfo.new(SPIN_STEP_TIME,   Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Rotation = glow.Rotation + SPIN_STEP_DEG})
			tw1:Play() tw2:Play()
			tw1.Completed:Wait()
		end
	end)
	-- Breathe
	task.spawn(function()
		while alive do
			TweenService:Create(ringScale, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = BREATH_MAX}):Play()
			task.wait(0.6)
			TweenService:Create(ringScale, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Scale = BREATH_MIN}):Play()
			task.wait(0.6)
		end
	end)

	-- Gradient sheen animation
	task.spawn(function()
		while alive do
			for i = 0,360,10 do
				gradient.Rotation = i
				task.wait(0.03)
			end
		end
	end)

	-- Auto fade + destroy
	if DURATION and DURATION > 0 then
		task.delay(DURATION, function()
			if not alive then return end
			local ti = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(ringStroke,  ti, {Transparency = 1}):Play()
			TweenService:Create(glowStroke,  ti, {Transparency = 1}):Play()
			TweenService:Create(thunderText, ti, {TextTransparency = 1}):Play()
			task.wait(0.45)
			_G.ThunderIntro_Stop()
		end)
	end

	return gui
end

Start({duration = 6})

local function getSecureGuiParent()
    local target = nil
    if gethui then
        target = gethui()
    elseif syn and syn.protect_gui then
        local folder = Instance.new("Folder")
        syn.protect_gui(folder)
        folder.Parent = game:GetService("CoreGui")
        target = folder
    elseif get_hidden_gui then
        target = get_hidden_gui()
    else
        target = game:GetService("CoreGui")
    end
    return target
end

print("反挂机开启")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)

local Sound = Instance.new("Sound")
        Sound.Parent = game.SoundService
        Sound.SoundId = ""
        Sound.Volume = 3
        Sound.PlayOnRemove = true
        Sound:Destroy()
        
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/windui.lua"))()

local Window = WindUI:CreateWindow({
        Title = "SA Hub",
        Icon = "shield-user",
        Author = "作者:冷屿",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
        Resizable = true,
        SideBarWidth = 200,
        Background = "video:https://github.com/knbm1051/tu/raw/refs/heads/main/mmexport1784473470373.mp4",
        BackgroundImageTransparency = 0.42,
        HideSearchBar = false,
        ScrollBarEnabled = true,
        User = {
            Enabled = true,
            Anonymous = false,
            Callback = function()
                print("clicked")
            end,
    },
})
        
Window:EditOpenButton({
    Title = "打开SA Hub",
    Icon = "shield-check",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))
    }),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local tag = Window:Tag({
    Title = "持续更新中",
    Icon = "",
    Color = Color3.fromRGB(255, 0, 0),
    Radius = 3,
})

local MainTab = Window:Tab({ Title = "通用", Icon = "" })

MainTab:Button({
    Title = "无敌少侠飞行",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
    end
})

MainTab:Button({
    Title = "翻译",
    Desc = "",
    Locked = false,
    Callback = function()
    Q = "主群1072347228"
Script = "公益汉化脚本"
loadstring(game:HttpGet("https://raw.githubusercontent.com/dream6-e/GB/refs/heads/main/HHP.lua"))()
    end
})

local MainTab = Window:Tab({ Title = "平民队伍", Icon = "" })

MainTab:Button({
    Title = "购买解密电路",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
	"purchase",
	{
		isRestaurant = false,
		item = game:GetService("ReplicatedStorage"):WaitForChild("Stuff"):WaitForChild("Black Market"):WaitForChild("1"):WaitForChild("Decryption Circuit")
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PlayerFunc"):InvokeServer(unpack(args))
    end
})

MainTab:Button({
    Title = "购买撬锁装置",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
	"purchase",
	{
		isRestaurant = false,
		item = game:GetService("ReplicatedStorage"):WaitForChild("Stuff"):WaitForChild("Black Market"):WaitForChild("2"):WaitForChild("Lockpick Device")
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PlayerFunc"):InvokeServer(unpack(args))
    end
})

MainTab:Button({
    Title = "购买工作人员喷漆",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
	"purchase",
	{
		isRestaurant = false,
		item = game:GetService("ReplicatedStorage"):WaitForChild("Stuff"):WaitForChild("Black Market"):WaitForChild("8"):WaitForChild("Crew Graffiti")
	}
}
game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("PlayerFunc"):InvokeServer(unpack(args))

    end
})

local MainTab = Window:Tab({ Title = "医疗队伍", Icon = "" })

MainTab:Button({
    Title = "补充医疗箱",
    Desc = "",
    Locked = false,
    Callback = function()
     local args = {
    [1] = "repairReplenishItem",
    [2] = "MT First Aid Kit"
}
game:GetService("ReplicatedStorage").Remote.PlayerFunc:InvokeServer(unpack(args))

    end
})

MainTab:Button({
    Title = "补充绷带",
    Desc = "",
    Locked = false,
    Callback = function()
    local args = {
    [1] = "repairReplenishItem",
    [2] = "MT Bandage"
}
game:GetService("ReplicatedStorage").Remote.PlayerFunc:InvokeServer(unpack(args))

    end
})