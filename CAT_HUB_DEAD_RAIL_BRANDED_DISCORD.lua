if getgenv().CATHUBDeadRailExecuted then
    NotifyToast({ title="WARNING!", content="Script Is Already Loaded, rejoin if you want to re-execute.", duration=8, icon="triangle-exclamation", iconColor="#FFFF00" })
    return
end
getgenv().CATHUBDeadRailExecuted = true

local BaseURL = "https://darahub.pages.dev"
WindUI = loadstring(game:HttpGet(BaseURL .. "/Module/Library/GUI/WindUI-Moded/main.lua"))()
loadstring(game:HttpGet(BaseURL .. "/Module/Library/GUI/LoadAll.lua"))()

Window = WindUI:CreateWindow({
    Title = "CAT HUB | Dead Rail",
    Icon = "rbxassetid://126031329785796",
    Author = "Made By CATJack.gg",
    Folder = "CATHUB/DeadRail",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark", HidePanelBackground = false, NewElements = true, Acrylic = false,
    HideSearchBar = false, SideBarWidth = 200,
    OpenButton = { ShowIconOnly = true }
})
WindUI.TransparencyValue = 0.7
Window:ToggleTransparency(true)
Window:DisableTopbarButtons({ "Fullscreen" })
executor = identifyexecutor()
if type(executor) == "string" then Window:Tag({ Title = executor }) end
Window:Tag({ Title = "v1" })

Tabs = {
    Main     = Window:Tab({ Title = "Main",     Icon = "layout-grid" }),
    Player   = Window:Tab({ Title = "Player",   Icon = "user" }),
    Visuals  = Window:Tab({ Title = "Visuals",  Icon = "camera" }),
    ESP      = Window:Tab({ Title = "ESP",      Icon = "eye" }),
    Combat   = Window:Tab({ Title = "Combat",   Icon = "swords" }),
    Misc     = Window:Tab({ Title = "Misc",     Icon = "wrench" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
    info     = Window:Tab({ Title = "info",     Icon = "info" }),
}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local MarketplaceService= game:GetService("MarketplaceService")
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer

socialsModule = loadstring(game:HttpGet(BaseURL .. "/Module/info.lua"))()
socialsModule(Tabs)

Tabs.info:Section({ Title = "CAT HUB Community", TextSize = 20 })
Tabs.info:Paragraph({ Title = "Credits", Desc = "CAT HUB | Made by CATJack.gg" })
Tabs.info:Button({ Title = "Join CAT HUB Discord", Desc = "Open the CAT HUB community invite", Icon = "message-circle", Callback = function()
    local invite = "https://discord.gg/bRdE4sfddp"
    local copied = pcall(function() setclipboard(invite) end)
    WindUI:Notify({ Title = "CAT HUB Discord", Content = copied and "Discord invite copied to clipboard" or invite, Duration = 5 })
end })

local jobId, placeId, StartTime = game.JobId, game.PlaceId, tick()
local EngineTargetMegaBytes = 3000
local FrameCount, LastTime, CurrentFPS = 0, tick(), 0
RunService.RenderStepped:Connect(function()
    FrameCount += 1
    local now = tick()
    if now - LastTime >= 1 then CurrentFPS = FrameCount; FrameCount = 0; LastTime = now end
end)

local function loadECS()
    local ok, result = pcall(function()
        local universe = ReplicatedStorage.Shared.Universe
        return {
            world      = require(universe.ECS.world),
            comps      = require(universe.ECS.components),
            replicator = require(ReplicatedStorage.Client.Universe.Replication.clientReplicator),
            remotes    = require(universe.Remotes),
            actionable = universe.Network.RemoteEvent.Actionable,
            pickup     = universe.Network.RemoteEvent.Pickup,
        }
    end)
    if not ok then return nil end
    local shopOk, shopFn = pcall(function()
        return require(ReplicatedStorage.Shared.Game.Shop.isShopItem)
    end)
    result.isShopItem = shopOk and shopFn or function() return false end
    return result
end

local ECS = loadECS()
local function ecsGet(id, comp)
    if not ECS then return nil end
    local ok, v = pcall(ECS.world.get, ECS.world, id, comp)
    return ok and v or nil
end
local function ecsHas(id, comp)
    if not ECS then return false end
    local ok, v = pcall(ECS.world.has, ECS.world, id, comp)
    return ok and v or false
end
local function ecsMyPosition()
    if not ECS then return nil end
    local state = ECS.world:get_resource(ECS.comps.ClientStateResource)
    local char = state and state.localCharacter
    if not char then return nil end
    local t = ecsGet(char, ECS.comps.Transform)
    if not t then return nil end
    return t.Position or t.p
end

function convertToDetailedTime(S, ms)
    local y = math.floor(S/31536000); S%=31536000
    local mo= math.floor(S/2592000);  S%=2592000
    local w = math.floor(S/604800);   S%=604800
    local d = math.floor(S/86400);    S%=86400
    local h = math.floor(S/3600);     S%=3600
    local m = math.floor(S/60);       local s = S%60
    return {Years=y,Months=mo,Weeks=w,Days=d,Hours=h,Minutes=m,Seconds=s,Milliseconds=ms or 0}
end
function GetServerUptimeString()
    local t=time(); local ms=math.floor((t-math.floor(t))*1000)
    local u=convertToDetailedTime(math.floor(t),ms)
    return string.format("<font color='#FFD700'>%dY</font> <font color='#FFA500'>%dMth</font> <font color='#FF8C00'>%dW</font> <font color='#32CD32'>%dD</font> <font color='#00CED1'>%dH</font> <font color='#1E90FF'>%dMin</font> <font color='#9370DB'>%dSec</font> <font color='#FF69B4'>%dMS</font>",u.Years,u.Months,u.Weeks,u.Days,u.Hours,u.Minutes,u.Seconds,u.Milliseconds)
end
function GetLastJoinedString()
    local c=os.time(); local j=c-math.floor(time()); local jt=os.date("*t",j)
    local ap=jt.hour>=12 and "PM" or "AM"; local h12=jt.hour%12; if h12==0 then h12=12 end
    local ms=math.floor((time()-math.floor(time()))*1000)
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return string.format("<font color='#87CEEB'>%02d:%02d:%02d.%03d %s</font> - <font color='#98FB98'>%s %d, %d</font>",h12,jt.min,jt.sec,ms,ap,mn[jt.month],jt.day,jt.year)
end
function GetScriptRuntime()
    local e=tick()-StartTime; local ms=math.floor((e-math.floor(e))*1000)
    local r=convertToDetailedTime(math.floor(e),ms)
    return string.format("<font color='#FFD700'>%dY</font> <font color='#FFA500'>%dMth</font> <font color='#FF8C00'>%dW</font> <font color='#32CD32'>%dD</font> <font color='#00CED1'>%dH</font> <font color='#1E90FF'>%dMin</font> <font color='#9370DB'>%dSec</font> <font color='#FF69B4'>%dMS</font>",r.Years,r.Months,r.Weeks,r.Days,r.Hours,r.Minutes,r.Seconds,r.Milliseconds)
end
function GetExecutedSince() return string.format("<font color='#87CEEB'>%s</font>", os.date("%I:%M:%S %p", StartTime)) end
function GetOSClock()
    local n=os.date("*t"); local ap=n.hour>=12 and "PM" or "AM"; local h12=n.hour%12; if h12==0 then h12=12 end
    return string.format("<font color='#FFD700'>%02d:%02d:%02d %s</font>",h12,n.min,n.sec,ap)
end
function GetCalendarDate()
    local n=os.date("*t")
    local mn={"January","February","March","April","May","June","July","August","September","October","November","December"}
    local sf="th"
    if n.day==1 or n.day==21 or n.day==31 then sf="st"
    elseif n.day==2 or n.day==22 then sf="nd"
    elseif n.day==3 or n.day==23 then sf="rd" end
    return string.format("<font color='#98FB98'>%s %d%s, %d</font>",mn[n.month],n.day,sf,n.year)
end
function GetGPUInfo() local v=string.format("%.2f",Stats.RenderGPUFrameTime*1000); local c=tonumber(v)<10 and "#32CD32" or (tonumber(v)<30 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%s ms</font>",c,v) end
function GetCPUInfo() local v=string.format("%.2f",Stats.RenderCPUFrameTime*1000); local c=tonumber(v)<10 and "#32CD32" or (tonumber(v)<30 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%s ms</font>",c,v) end
function GetRAMInfo() local r=Stats:GetTotalMemoryUsageMb(); local p=math.floor((r/EngineTargetMegaBytes)*100); local c=p<50 and "#32CD32" or (p<80 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%.2f MB / %d MB (%d%%)</font>",c,r,EngineTargetMegaBytes,p) end
function GetNetworkSent() local s=Stats.DataSendKbps; local c=s<100 and "#32CD32" or (s<500 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%.2f KB/s</font>",c,s) end
function GetNetworkReceived() local s=Stats.DataReceiveKbps; local c=s<100 and "#32CD32" or (s<500 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%.2f KB/s</font>",c,s) end
function GetPing() local p=math.clamp(Stats.Network.ServerStatsItem["Data Ping"]:GetValue(),10,700); local c=p<100 and "#32CD32" or (p<200 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%d ms</font>",c,math.floor(p)) end
function GetFPS() local c=CurrentFPS>=60 and "#32CD32" or (CurrentFPS>=30 and "#FFD700" or "#FF6666"); return string.format("<font color='%s'>%d fps</font>",c,CurrentFPS) end

local TotalFriends, OnlineFriends, OfflineFriends = 0, 0, 0
function UpdateFriendData()
    pcall(function()
        local total, online = 0, 0
        local list = Players:GetFriendsAsync(LocalPlayer.UserId)
        while true do
            for _ in list:GetCurrentPage() do total += 1 end
            if list.IsFinished then break else list:AdvanceToNextPageAsync() end
        end
        for _ in pairs(LocalPlayer:GetFriendsOnline()) do online += 1 end
        TotalFriends, OnlineFriends, OfflineFriends = total, online, total-online
    end)
end

Tabs.Main:Section({ Title = "Server Information", TextSize = 20 })
Tabs.Main:Divider()
ServerInfoParagraph = Tabs.Main:Paragraph({ Title = "In Server For", Desc = GetServerUptimeString() })
task.spawn(function() while task.wait() do pcall(function() ServerInfoParagraph:SetDesc(GetServerUptimeString()) end) end end)
Tabs.Main:Paragraph({ Title = "Joinned Started", Desc = GetLastJoinedString() })
local placeName = "Unknown"
pcall(function() local p = MarketplaceService:GetProductInfo(placeId); if p and p.Name then placeName = p.Name end end)
Tabs.Main:Paragraph({ Title = "Game", Desc = placeName })
local maxPlayers = Players.MaxPlayers
CurrentPlayersParagraph = Tabs.Main:Paragraph({ Title = "Current Players", Desc = #Players:GetPlayers() .. " / " .. maxPlayers })
task.spawn(function() while task.wait(1) do pcall(function() CurrentPlayersParagraph:SetDesc(#Players:GetPlayers() .. " / " .. maxPlayers) end) end end)
Tabs.Main:Paragraph({ Title = "Server ID", Desc = string.sub(jobId, 1, 30) .. "..." })
Tabs.Main:Space()
Tabs.Main:Section({ Title = "Client Information", TextSize = 20 })
Tabs.Main:Divider()
ScriptRuntimeParagraph = Tabs.Main:Paragraph({ Title = "Script Running For", Desc = GetScriptRuntime() })
task.spawn(function() while task.wait() do pcall(function() ScriptRuntimeParagraph:SetDesc(GetScriptRuntime()) end) end end)
Tabs.Main:Paragraph({ Title = "Executed Since", Desc = GetExecutedSince() })
Tabs.Main:Space()
Tabs.Main:Section({ Title = "System Information", TextSize = 20 })
Tabs.Main:Divider()
OSClockParagraph = Tabs.Main:Paragraph({ Title = "OS Clock", Desc = GetOSClock() })
task.spawn(function() while task.wait() do pcall(function() OSClockParagraph:SetDesc(GetOSClock()) end) end end)
CalendarParagraph = Tabs.Main:Paragraph({ Title = "Calendar", Desc = GetCalendarDate() })
task.spawn(function() while task.wait(60) do pcall(function() CalendarParagraph:SetDesc(GetCalendarDate()) end) end end)
GPUParagraph = Tabs.Main:Paragraph({ Title = "GPU", Desc = GetGPUInfo() })
CPUParagraph = Tabs.Main:Paragraph({ Title = "CPU", Desc = GetCPUInfo() })
RAMParagraph = Tabs.Main:Paragraph({ Title = "RAM", Desc = GetRAMInfo() })
SentParagraph = Tabs.Main:Paragraph({ Title = "Sent", Desc = GetNetworkSent() })
ReceivedParagraph = Tabs.Main:Paragraph({ Title = "Received", Desc = GetNetworkReceived() })
PingParagraph = Tabs.Main:Paragraph({ Title = "Ping", Desc = GetPing() })
FPSParagraph = Tabs.Main:Paragraph({ Title = "FPS", Desc = GetFPS() })
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            GPUParagraph:SetDesc(GetGPUInfo()); CPUParagraph:SetDesc(GetCPUInfo()); RAMParagraph:SetDesc(GetRAMInfo())
            SentParagraph:SetDesc(GetNetworkSent()); ReceivedParagraph:SetDesc(GetNetworkReceived())
            PingParagraph:SetDesc(GetPing()); FPSParagraph:SetDesc(GetFPS())
        end)
    end
end)
Tabs.Main:Space()
Tabs.Main:Section({ Title = "Player Information", TextSize = 20 })
Tabs.Main:Divider()
Tabs.Main:Paragraph({ Title = "Username", Desc = LocalPlayer.Name })
Tabs.Main:Paragraph({ Title = "Display Name", Desc = LocalPlayer.DisplayName })
Tabs.Main:Paragraph({ Title = "User ID", Desc = tostring(LocalPlayer.UserId) })
local accStr = "Unknown"
pcall(function() local a = LocalPlayer.AccountAge; if a then accStr = os.date("%B %d, %Y", os.time() - a*86400) end end)
Tabs.Main:Paragraph({ Title = "Account Created", Desc = accStr })
Tabs.Main:Space()
Tabs.Main:Section({ Title = "Friends Data", TextSize = 20 })
Tabs.Main:Divider()
FriendsOnlineParagraph = Tabs.Main:Paragraph({ Title = "Online Friends", Desc = "0" })
FriendsOfflineParagraph = Tabs.Main:Paragraph({ Title = "Offline Friends", Desc = "0" })
FriendsTotalParagraph = Tabs.Main:Paragraph({ Title = "Total Friends", Desc = "0" })
local function refreshFriendParagraphs() UpdateFriendData(); FriendsOnlineParagraph:SetDesc(tostring(OnlineFriends)); FriendsOfflineParagraph:SetDesc(tostring(OfflineFriends)); FriendsTotalParagraph:SetDesc(tostring(TotalFriends)) end
task.spawn(function() pcall(refreshFriendParagraphs); while task.wait(30) do pcall(refreshFriendParagraphs) end end)
Tabs.Main:Space()
Tabs.Main:Section({ Title = "Server Tools", TextSize = 20 })
Tabs.Main:Divider()
Tabs.Main:Button({
    Title = "Advanced Server Hop", Icon = "server",
    Callback = function()
        pcall(function() loadstring(game:HttpGet("https://darahub.pages.dev/raw-script/Tools/Advanced%20Server%20Hop.lua"))() end)
        WindUI:Notify({ Title = "Success", Content = "Advanced Server Hop Loaded", Duration = 3 })
    end
})

Tabs.Player:Section({ Title = "Movement", TextSize = 20 })
Tabs.Player:Divider()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local function getRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
end

local doubleJumpAvailable, doubleJumpGroundedAt = true, 0
local doubleJumpRequestConnection, doubleJumpGroundConnection
local function stopDoubleJump()
    if doubleJumpRequestConnection then doubleJumpRequestConnection:Disconnect(); doubleJumpRequestConnection=nil end
    if doubleJumpGroundConnection then doubleJumpGroundConnection:Disconnect(); doubleJumpGroundConnection=nil end
end
local function startDoubleJump()
    stopDoubleJump(); doubleJumpAvailable=true; doubleJumpGroundedAt=tick()
    doubleJumpGroundConnection = RunService.Heartbeat:Connect(function()
        local c=LocalPlayer.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
        if h and h.FloorMaterial ~= Enum.Material.Air then doubleJumpAvailable=true; doubleJumpGroundedAt=tick() end
    end)
    doubleJumpRequestConnection = UserInputService.JumpRequest:Connect(function()
        local c=LocalPlayer.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
        if h and doubleJumpAvailable and h.FloorMaterial == Enum.Material.Air and tick()-doubleJumpGroundedAt > 0.2 then
            doubleJumpAvailable=false; h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
DoubleJumpToggle = Tabs.Player:Toggle({ Title="Double Jump", Flag="DoubleJumpToggle", Value=false,
    Callback=function(s) if s then startDoubleJump() else stopDoubleJump() end end })
Tabs.Player:Space()

local noclipConnection
local function setNoclip(state)
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection=nil end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local c=LocalPlayer.Character
            if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end)
    else
        local c=LocalPlayer.Character
        if c then for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=true end end end
    end
end
NoclipToggle = Tabs.Player:Toggle({ Title="Noclip", Flag="NoclipToggle", Value=false, Callback=function(s) setNoclip(s) end })
Tabs.Player:Space()

local isOnMobile = false
pcall(function() isOnMobile = table.find({ Enum.Platform.Android, Enum.Platform.IOS }, UserInputService:GetPlatform()) ~= nil end)
local vflySpeed, vflyQE = 5, false
local vflyConnection, vflyKeyDown, vflyKeyUp, vflyControlModule
local vflyKeys, vflyUp, vflyDown = {}, false, false
local vflyVelocityName = "VFlyVelocity_" .. math.random(1000, 9999)
local vflyGyroName = "VFlyGyro_" .. math.random(1000, 9999)
local mobileConnections, mobileJumpButton, mobileJumpRect, downButton = {}, nil, nil, nil

local function destroyMobileButtons()
    for _, c in ipairs(mobileConnections) do c:Disconnect() end
    table.clear(mobileConnections)
    if mobileJumpButton and mobileJumpButton.Parent and mobileJumpRect then mobileJumpButton.ImageRectOffset = mobileJumpRect end
    mobileJumpButton, mobileJumpRect = nil, nil
    if downButton then downButton:Destroy(); downButton = nil end
    vflyUp, vflyDown = false, false
end

local function createMobileButtons()
    destroyMobileButtons()
    local tg = PlayerGui:FindFirstChild("TouchGui") or PlayerGui:WaitForChild("TouchGui", 5)
    local cf = tg and tg:FindFirstChild("TouchControlFrame")
    local jb = cf and cf:FindFirstChild("JumpButton")
    if not jb then return end
    mobileJumpButton = jb; mobileJumpRect = jb.ImageRectOffset
    local pressed = Vector2.new(146, 146)
    local b = Instance.new("ImageButton")
    b.Name = "DownWardJumpBtn"; b.Size = jb.Size; b.Image = jb.Image
    b.ImageRectOffset = mobileJumpRect; b.ImageRectSize = jb.ImageRectSize
    b.BackgroundTransparency = 1; b.AnchorPoint = Vector2.new(1, 0); b.AutoButtonColor = false
    b.Position = UDim2.new(1, 0, jb.Position.Y.Scale, jb.Position.Y.Offset); b.Rotation = 180
    b.Parent = cf; downButton = b
    local function align()
        if not b.Parent or not jb.Parent then return end
        local d = b.AbsolutePosition.X - (jb.AbsolutePosition.X + jb.AbsoluteSize.X)
        b.Position = UDim2.new(1, b.Position.X.Offset + (d - 1), b.Position.Y.Scale, b.Position.Y.Offset)
    end
    local function bind(t, dn, up)
        table.insert(mobileConnections, t.MouseButton1Down:Connect(dn))
        table.insert(mobileConnections, t.MouseButton1Up:Connect(up))
        table.insert(mobileConnections, t.MouseLeave:Connect(up))
    end
    bind(jb, function() vflyUp = true; jb.ImageRectOffset = pressed end, function() vflyUp = false; jb.ImageRectOffset = mobileJumpRect or jb.ImageRectOffset end)
    bind(b,  function() vflyDown = true; b.ImageRectOffset = pressed end,  function() vflyDown = false; b.ImageRectOffset = mobileJumpRect or b.ImageRectOffset end)
    table.insert(mobileConnections, b:GetPropertyChangedSignal("AbsoluteSize"):Connect(align))
    if workspace.CurrentCamera then table.insert(mobileConnections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(align)) end
    align()
end

local function getVFlyBodies(root)
    local v = root:FindFirstChild(vflyVelocityName)
    if not v then
        v = Instance.new("BodyVelocity"); v.Name = vflyVelocityName
        v.MaxForce = Vector3.new(9e9, 9e9, 9e9); v.Velocity = Vector3.zero; v.Parent = root
    end
    local g = root:FindFirstChild(vflyGyroName)
    if not g then
        g = Instance.new("BodyGyro"); g.Name = vflyGyroName
        g.MaxTorque = Vector3.new(9e9, 9e9, 9e9); g.P = 9e4; g.CFrame = root.CFrame; g.Parent = root
    end
    return v, g
end

local function stopVFly()
    if vflyConnection then vflyConnection:Disconnect(); vflyConnection = nil end
    if vflyKeyDown then vflyKeyDown:Disconnect(); vflyKeyDown = nil end
    if vflyKeyUp then vflyKeyUp:Disconnect(); vflyKeyUp = nil end
    table.clear(vflyKeys); vflyControlModule = nil
    local root = getRootPart(LocalPlayer.Character)
    if root then
        local v = root:FindFirstChild(vflyVelocityName); if v then v:Destroy() end
        local g = root:FindFirstChild(vflyGyroName); if g then g:Destroy() end
    end
    destroyMobileButtons()
end

local function startVFly()
    stopVFly()
    if not getRootPart(LocalPlayer.Character) then return false end
    if isOnMobile then
        pcall(function()
            local pm = LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 5)
            vflyControlModule = require(pm:WaitForChild("ControlModule", 5))
        end)
        createMobileButtons()
    else
        vflyKeyDown = UserInputService.InputBegan:Connect(function(i, p) if not p then vflyKeys[i.KeyCode] = true end end)
        vflyKeyUp   = UserInputService.InputEnded:Connect(function(i) vflyKeys[i.KeyCode] = nil end)
    end
    vflyConnection = RunService.RenderStepped:Connect(function()
        local root = getRootPart(LocalPlayer.Character)
        local cam = workspace.CurrentCamera
        if not root or not cam then return end
        local velocity = getVFlyBodies(root)
        local ccf = cam.CFrame
        local move = Vector3.zero
        local up, down = vflyUp, vflyDown
        if isOnMobile then
            if vflyControlModule then
                local d = vflyControlModule:GetMoveVector()
                move = ccf.RightVector * d.X - ccf.LookVector * d.Z
            end
        else
            local x = (vflyKeys[Enum.KeyCode.D] and 1 or 0) - (vflyKeys[Enum.KeyCode.A] and 1 or 0)
            local z = (vflyKeys[Enum.KeyCode.W] and 1 or 0) - (vflyKeys[Enum.KeyCode.S] and 1 or 0)
            move = ccf.RightVector * x + ccf.LookVector * z
            if vflyQE then
                up = up or vflyKeys[Enum.KeyCode.E] == true
                down = down or vflyKeys[Enum.KeyCode.Q] == true
            end
        end
        local speed = vflySpeed * 50
        local vert = (up and 1 or 0) - (down and 1 or 0)
        velocity.Velocity = move * speed + Vector3.new(0, vert * speed, 0)
    end)
    return true
end

VehicleFlyToggle = Tabs.Player:Toggle({ Title = "Vehicle Fly", Flag = "VehicleFlyToggle", Desc = "Fly while seated in a vehicle or on foot", Value = false,
    Callback = function(s) if s then if not startVFly() then VehicleFlyToggle:Set(false) end else stopVFly() end end })
VehicleFlySpeedInput = Tabs.Player:Input({ Title = "Vehicle Fly Speed", Flag = "VehicleFlySpeedInput", Placeholder = "Enter speed value", Value = tostring(vflySpeed), NumbersOnly = true,
    Callback = function(v) local n = tonumber(v); if n and n > 0 then vflySpeed = n end end })
VehicleQEflyToggle = Tabs.Player:Toggle({ Title = "Q/E Vertical Fly", Flag = "VehicleQEflyToggle", Desc = "E to go up, Q to go down (PC)", Value = false,
    Callback = function(s) vflyQE = s end })

LocalPlayer.CharacterAdded:Connect(function()
    if vflyConnection then stopVFly(); if VehicleFlyToggle then VehicleFlyToggle:Set(false) end end
end)

Tabs.Combat:Section({ Title = "Auto Swing", TextSize = 20 })
Tabs.Combat:Divider()
local SWING_RANGE = 15
local swingPerTime = 1
local trackedNPCs = {}
local swingConnection, descendantConnection
local function getSwingRemote()
    local ok, r = pcall(function() return ReplicatedStorage.Shared.Universe.Network.RemoteEvent.SwingMelee end)
    return ok and r or nil
end
local descendantUsers = 0
local function normalizeName(n) return (string.lower(n):gsub("[%s_]", "")) end
local function getMeleeNames()
    local ok, f = pcall(function() return ReplicatedStorage.Assets.Tools.Weapon.Melee end)
    if not ok or not f then return nil, 0 end
    local names, c = {}, 0
    for _, t in ipairs(f:GetChildren()) do names[normalizeName(t.Name)] = true; c += 1 end
    return names, c
end
local function findMeleeTool(names)
    local c = LocalPlayer.Character
    if not c then return nil end
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and names[normalizeName(ch.Name)] then return ch end end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and names[normalizeName(ch.Name)] then return ch end end end
    return nil
end
local function trackNPC(h)
    local m = h.Parent
    if m and m:IsA("Model") and not trackedNPCs[m] and not Players:GetPlayerFromCharacter(m) then trackedNPCs[m] = h end
end
local function startNPCTracking()
    descendantUsers += 1
    if descendantUsers > 1 then return end
    for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("Humanoid") then trackNPC(o) end end
    descendantConnection = workspace.DescendantAdded:Connect(function(o) if o:IsA("Humanoid") then trackNPC(o) end end)
end
local function stopNPCTracking()
    if descendantUsers == 0 then return end
    descendantUsers -= 1
    if descendantUsers > 0 then return end
    if descendantConnection then descendantConnection:Disconnect(); descendantConnection = nil end
    table.clear(trackedNPCs)
end
local function getClosestNPCId()
    local c = LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position; local bestId, bestDist
    for m, h in pairs(trackedNPCs) do
        if not m.Parent then trackedNPCs[m] = nil
        elseif h.Health > 0 then
            local id = m:GetAttribute("ServerEntityId")
            local nr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if id and nr then
                local d = (nr.Position - pos).Magnitude
                if d <= SWING_RANGE and (not bestDist or d < bestDist) then bestId, bestDist = id, d end
            end
        end
    end
    return bestId
end
local autoSwingTracking = false
local stopAutoSwing, startAutoSwing
do
    local swingTool, swingRun = nil, 0
    local toolConnections = {}
    local function clearToolConnections()
        for _, c in ipairs(toolConnections) do c:Disconnect() end
        table.clear(toolConnections)
    end
    local function watchTools(names, run)
        clearToolConnections()
        local function refresh()
            if swingRun == run then swingTool = findMeleeTool(names) end
        end
        local function watch(container)
            if not container then return end
            table.insert(toolConnections, container.ChildAdded:Connect(function(ch)
                if ch:IsA("Tool") then refresh() end
            end))
            table.insert(toolConnections, container.ChildRemoved:Connect(function(ch)
                if ch:IsA("Tool") then task.defer(refresh) end
            end))
        end
        watch(LocalPlayer.Character)
        watch(LocalPlayer:FindFirstChildOfClass("Backpack"))
        table.insert(toolConnections, LocalPlayer.CharacterAdded:Connect(function()
            task.spawn(function()
                LocalPlayer:WaitForChild("Backpack", 5)
                if swingRun == run then watchTools(names, run) end
            end)
        end))
        refresh()
    end
    stopAutoSwing = function()
        swingRun += 1
        clearToolConnections(); swingTool = nil
        if swingConnection then swingConnection:Disconnect(); swingConnection = nil end
        if autoSwingTracking then autoSwingTracking = false; stopNPCTracking() end
    end
    startAutoSwing = function()
        stopAutoSwing()
        local R = getSwingRemote()
        if not R then WindUI:Notify({ Title = "Auto Swing", Content = "SwingMelee remote not found", Duration = 3 }); return false end
        local names, count = getMeleeNames()
        if not names or count == 0 then WindUI:Notify({ Title = "Auto Swing", Content = "No melee weapons found", Duration = 3 }); return false end
        autoSwingTracking = true; startNPCTracking()
        watchTools(names, swingRun)
        swingConnection = RunService.Heartbeat:Connect(function()
            local w = swingTool
            if not w or not w.Parent then return end
            local id = getClosestNPCId()
            if id then for _ = 1, swingPerTime do R:FireServer(w, 0, id) end end
        end)
        return true
    end
end
AutoSwingToggle = Tabs.Combat:Toggle({ Title = "Auto Swing", Flag = "AutoSwingToggle", Value = false,
    Callback = function(s) if s then if not startAutoSwing() then AutoSwingToggle:Set(false) end else stopAutoSwing() end end })
SwingPerTimeInput = Tabs.Combat:Input({ Title = "Swing Per Time", Flag = "SwingPerTimeInput", Desc = "How many swings are fired per frame", Icon = "swords", Placeholder = "1", Value = tostring(swingPerTime),
    Callback = function(v) local n = tonumber(v); if n then swingPerTime = math.max(math.floor(n), 1) end end })
Tabs.Combat:Space()

Tabs.Combat:Section({ Title = "OP Swing", TextSize = 20 })
Tabs.Combat:Divider()
local opSwingDelay, opSwingsPerDelay = 0.05, 2
local opHolding, opLoopId, ClientMeleeHandler, originalMeleeHandler = false, 0, nil, nil
local opCharacterConnection, opTracking, opSwingEnabled, opHookFn, opInputBegan, opInputEnded
local function stopOpHolding() opHolding = false; opLoopId += 1 end
local function startOpHolding()
    local c = LocalPlayer.Character; if not c then return end
    local tool = c:FindFirstChildWhichIsA("Tool"); if not tool then return end
    local R = getSwingRemote(); if not R then return end
    local at = workspace:GetServerTimeNow()
    local mouse = LocalPlayer:GetMouse()
    local lv = mouse.Hit and mouse.Hit.LookVector or c:GetPivot().LookVector
    opHolding = true; opLoopId += 1; local id = opLoopId
    task.spawn(function()
        while opHolding and opLoopId == id and tool.Parent == c do
            local tid = getClosestNPCId()
            if tid then
                for _ = 1, opSwingsPerDelay do
                    if not opHolding or opLoopId ~= id then break end
                    R:FireServer(tool, at, lv); R:FireServer(tool, 0, tid)
                end
            end
            task.wait(opSwingDelay)
        end
    end)
end
local function stopOpSwing()
    opSwingEnabled = false; stopOpHolding()
    if ClientMeleeHandler and opHookFn and ClientMeleeHandler._meleeActionHandler == opHookFn then
        ClientMeleeHandler._meleeActionHandler = originalMeleeHandler
    end
    if opTracking then opTracking = false; stopNPCTracking() end
    if opCharacterConnection then opCharacterConnection:Disconnect(); opCharacterConnection = nil end
    if opInputBegan then opInputBegan:Disconnect(); opInputBegan = nil end
    if opInputEnded then opInputEnded:Disconnect(); opInputEnded = nil end
end
local function rebindMeleeInput()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local t = c and c:FindFirstChildWhichIsA("Tool")
    if h and t then h:UnequipTools(); task.wait(0.15); if opSwingEnabled then h:EquipTool(t) end end
end
local function startOpSwing()
    stopOpSwing()
    local ok, mod = pcall(function() return require(ReplicatedStorage.Client.Game.Melee.ClientMeleeHandler) end)
    if not ok or type(mod) ~= "table" then WindUI:Notify({ Title = "OP Swing", Content = "ClientMeleeHandler not found", Duration = 3 }); return false end
    ClientMeleeHandler = mod
    if not originalMeleeHandler and mod._meleeActionHandler ~= opHookFn then originalMeleeHandler = mod._meleeActionHandler end
    if not opHookFn then
        opHookFn = function(name, state, obj)
            if opSwingEnabled then
                if state == Enum.UserInputState.Begin then startOpHolding()
                elseif state == Enum.UserInputState.End then stopOpHolding() end
            end
            if originalMeleeHandler then return originalMeleeHandler(name, state, obj) end
        end
    end
    mod._meleeActionHandler = opHookFn
    opSwingEnabled = true; opTracking = true; startNPCTracking()
    opCharacterConnection = LocalPlayer.CharacterAdded:Connect(stopOpHolding)
    opInputBegan = UserInputService.InputBegan:Connect(function(i, p)
        if not p and i.UserInputType == Enum.UserInputType.MouseButton1 then startOpHolding() end
    end)
    opInputEnded = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then stopOpHolding() end
    end)
    task.spawn(rebindMeleeInput); return true
end
OpSwingToggle = Tabs.Combat:Toggle({ Title = "OP Swing", Flag = "OpSwingToggle", Value = false,
    Callback = function(s) if s then if not startOpSwing() then OpSwingToggle:Set(false) end else stopOpSwing() end end })
OpSwingDelayInput = Tabs.Combat:Input({ Title = "OP Swing Delay", Flag = "OpSwingDelayInput", Desc = "Seconds to wait between bursts (0 = every frame)", Icon = "timer", Placeholder = "0.05", Value = tostring(opSwingDelay),
    Callback = function(v) local n = tonumber(v); if n then opSwingDelay = math.max(n, 0) end end })
OpSwingsPerDelayInput = Tabs.Combat:Input({ Title = "OP Swings Per Delay", Flag = "OpSwingsPerDelayInput", Desc = "How many swings are fired in each burst", Icon = "swords", Placeholder = "2", Value = tostring(opSwingsPerDelay),
    Callback = function(v) local n = tonumber(v); if n then opSwingsPerDelay = math.max(math.floor(n), 1) end end })

Tabs.Visuals:Section({ Title = "Lighting", TextSize = 20 })
Tabs.Visuals:Divider()
local fogOriginal, fogConnection
local function stopLoopNoFog()
    if fogConnection then fogConnection:Disconnect(); fogConnection = nil end
    if fogOriginal then
        Lighting.FogStart = fogOriginal.FogStart; Lighting.FogEnd = fogOriginal.FogEnd
        local a = Lighting:FindFirstChildOfClass("Atmosphere")
        if a and fogOriginal.Density then a.Density = fogOriginal.Density; a.Haze = fogOriginal.Haze end
        fogOriginal = nil
    end
end
local function startLoopNoFog()
    stopLoopNoFog()
    local a = Lighting:FindFirstChildOfClass("Atmosphere")
    fogOriginal = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, Density = a and a.Density, Haze = a and a.Haze }
    fogConnection = RunService.Heartbeat:Connect(function()
        Lighting.FogStart = 100000; Lighting.FogEnd = 100000
        local c = Lighting:FindFirstChildOfClass("Atmosphere")
        if c then c.Density = 0; c.Haze = 0 end
    end)
end
LoopNoFogToggle = Tabs.Visuals:Toggle({ Title = "Loop Remove Fog", Flag = "LoopNoFogToggle", Value = false,
    Callback = function(s) if s then startLoopNoFog() else stopLoopNoFog() end end })
Tabs.Visuals:Space()

local fbOriginal, fbConnection
local function stopLoopFullBright()
    if fbConnection then fbConnection:Disconnect(); fbConnection = nil end
    if fbOriginal then
        Lighting.Brightness = fbOriginal.Brightness; Lighting.Ambient = fbOriginal.Ambient
        Lighting.OutdoorAmbient = fbOriginal.OutdoorAmbient
        Lighting.ColorShift_Top = fbOriginal.ColorShift_Top; Lighting.ColorShift_Bottom = fbOriginal.ColorShift_Bottom
        fbOriginal = nil
    end
end
local function startLoopFullBright()
    stopLoopFullBright()
    fbOriginal = { Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ColorShift_Top = Lighting.ColorShift_Top, ColorShift_Bottom = Lighting.ColorShift_Bottom }
    local w = Color3.fromRGB(255, 255, 255)
    fbConnection = RunService.Heartbeat:Connect(function()
        Lighting.Brightness = 1; Lighting.Ambient = w; Lighting.OutdoorAmbient = w
        Lighting.ColorShift_Top = w; Lighting.ColorShift_Bottom = w
    end)
end
LoopFullBrightToggle = Tabs.Visuals:Toggle({ Title = "Loop Full Bright", Flag = "LoopFullBrightToggle", Value = false,
    Callback = function(s) if s then startLoopFullBright() else stopLoopFullBright() end end })
Tabs.Visuals:Space()
Tabs.Visuals:Divider()
Tabs.Visuals:Section({ Title = "Camera", TextSize = 20 })
Tabs.Visuals:Divider()

local stretchHorizontal, stretchVertical = 0.8, 0.8
local cameraStretchConnection
local function stopCameraStretch() if cameraStretchConnection then cameraStretchConnection:Disconnect(); cameraStretchConnection = nil end end
local function startCameraStretch()
    stopCameraStretch()
    cameraStretchConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam then cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, stretchHorizontal, 0, 0, 0, stretchVertical, 0, 0, 0, 1) end
    end)
end
CameraStretchToggle = Tabs.Visuals:Toggle({ Title = "Camera Stretch", Flag = "CameraStretchToggle", Value = false,
    Callback = function(s) if s then startCameraStretch() else stopCameraStretch() end end })
CameraStretchHorizontalInput = Tabs.Visuals:Input({ Title = "Camera Stretch Horizontal", Flag = "CameraStretchHorizontalInput", Placeholder = "0.80", Value = tostring(stretchHorizontal),
    Callback = function(v) local n = tonumber(v); if n then stretchHorizontal = n end end })
CameraStretchVerticalInput = Tabs.Visuals:Input({ Title = "Camera Stretch Vertical", Flag = "CameraStretchVerticalInput", Placeholder = "0.80", Value = tostring(stretchVertical),
    Callback = function(v) local n = tonumber(v); if n then stretchVertical = n end end })

local mobColor = Color3.fromRGB(255, 255, 0)
local espSettings = {
    Player = { Names = false, Boxes = false, BoxType = "2D", Distance = false, Health = false, State = false, Highlights = false, Tracers = false },
    Mob    = { Names = false, Boxes = false, BoxType = "2D", Distance = false, Health = false, State = false, Highlights = false, Tracers = false },
    Item   = { Names = false, Boxes = false, BoxType = "2D", Distance = false, Highlights = false, Tracers = false }
}
local espElements = { Player = {}, Mob = {} }
local tracerEntries, tracerGui, espConnection = {}, nil, nil
local mobTrackingActive = false

local function getDistanceFromCamera(pos)
    local cam = workspace.CurrentCamera; if not cam then return 0 end
    return (pos - cam.CFrame.Position).Magnitude
end
local function calculateBoxScale(d) if d <= 17 then return 1 end return math.max(17/d, 0.013) end
local function getCharacterState(c)
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return "Unknown" end
    if h.Health <= 0 then return "Dead" end
    if h.MoveDirection.Magnitude > 0 then return "Moving" end
    return "Idle"
end
local function getHealthColor(h, m) local p = h/math.max(m, 1); if p > 0.6 then return "#00ff00" elseif p > 0.3 then return "#ffa500" end return "#ff0000" end
local function destroyESPChild(c, n)
    local d = c:FindFirstChild(n); if d then d:Destroy() end
    local r = c:FindFirstChild("HumanoidRootPart"); local ir = r and r:FindFirstChild(n); if ir then ir:Destroy() end
end
local function create2DBox(c, col, sc)
    destroyESPChild(c, "ESP_2DBox")
    local r = c:FindFirstChild("HumanoidRootPart")
    local bb = Instance.new("BillboardGui"); bb.Name = "ESP_2DBox"; bb.Adornee = r or c; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 80*sc, 0, 100*sc); bb.StudsOffset = Vector3.zero; bb.ClipsDescendants = false; bb.Parent = r or c
    local f = Instance.new("Frame"); f.Name = "BoxFrame"; f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Parent = bb
    local st = Instance.new("UIStroke"); st.Thickness = math.max(2.5*sc, 2); st.Transparency = 0; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Color = col; st.Parent = f
    return { billboard = bb, stroke = st }
end
local function update2DBox(b, col, sc) b.stroke.Color = col; b.stroke.Thickness = math.max(2.5*sc, 2); b.billboard.Size = UDim2.new(0, 80*sc, 0, 100*sc) end
local function remove2DBox(c) destroyESPChild(c, "ESP_2DBox") end
local function create3DBox(c, col, sz)
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return nil end
    local e = c:FindFirstChild("ESP_3DBox"); if e then e:Destroy() end
    local f = Instance.new("Folder"); f.Name = "ESP_3DBox"; f.Parent = c
    local x, y, z = sz.X/2, sz.Y/2, sz.Z/2
    local edges = {
        {Vector3.new(0, y, z),   Vector3.new(sz.X, 0.1, 0.1)}, {Vector3.new(0, y, -z),  Vector3.new(sz.X, 0.1, 0.1)},
        {Vector3.new(-x, y, 0),  Vector3.new(0.1, 0.1, sz.Z)}, {Vector3.new(x, y, 0),   Vector3.new(0.1, 0.1, sz.Z)},
        {Vector3.new(0, -y, z),  Vector3.new(sz.X, 0.1, 0.1)}, {Vector3.new(0, -y, -z), Vector3.new(sz.X, 0.1, 0.1)},
        {Vector3.new(-x, -y, 0), Vector3.new(0.1, 0.1, sz.Z)}, {Vector3.new(x, -y, 0),  Vector3.new(0.1, 0.1, sz.Z)},
        {Vector3.new(-x, 0, z),  Vector3.new(0.1, sz.Y, 0.1)}, {Vector3.new(x, 0, z),   Vector3.new(0.1, sz.Y, 0.1)},
        {Vector3.new(-x, 0, -z), Vector3.new(0.1, sz.Y, 0.1)}, {Vector3.new(x, 0, -z),  Vector3.new(0.1, sz.Y, 0.1)}
    }
    for _, e2 in ipairs(edges) do
        local a = Instance.new("BoxHandleAdornment")
        a.Adornee = r; a.Size = e2[2]; a.CFrame = CFrame.new(e2[1]); a.Color3 = col; a.Transparency = 0.2; a.ZIndex = 10; a.AlwaysOnTop = true; a.Parent = f
    end
    return f
end
local function update3DBoxColor(c, col) local f = c:FindFirstChild("ESP_3DBox"); if f then for _, a in ipairs(f:GetChildren()) do a.Color3 = col end end end
local function remove3DBox(c) local f = c:FindFirstChild("ESP_3DBox"); if f then f:Destroy() end end
local function createHighlight(c, col)
    local e = c:FindFirstChild("ESP_Highlight"); if e then e:Destroy() end
    local hl = Instance.new("Highlight"); hl.Name = "ESP_Highlight"; hl.Adornee = c; hl.FillColor = col; hl.OutlineColor = col
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.3; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = c
    return hl
end
local function updateHighlight(hl, col) hl.FillColor = col; hl.OutlineColor = col end
local function removeHighlight(c) local hl = c:FindFirstChild("ESP_Highlight"); if hl then hl:Destroy() end end
local function createBillboard(c, col)
    destroyESPChild(c, "ESP_Billboard")
    local r = c:FindFirstChild("HumanoidRootPart")
    local bb = Instance.new("BillboardGui"); bb.Name = "ESP_Billboard"; bb.Adornee = r or c; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 350, 0, 100); bb.StudsOffset = Vector3.new(0, 3, 0); bb.ClipsDescendants = false
    bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; bb.Parent = r or c
    local tl = Instance.new("TextLabel"); tl.Name = "InfoLabel"; tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
    tl.Text = ""; tl.TextColor3 = col; tl.TextSize = 10; tl.Font = Enum.Font.GothamBold; tl.RichText = true
    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); tl.TextStrokeTransparency = 0
    tl.TextXAlignment = Enum.TextXAlignment.Center; tl.TextYAlignment = Enum.TextYAlignment.Top
    tl.TextWrapped = true; tl.LineHeight = 1.2; tl.Parent = bb
    return { billboard = bb, textLabel = tl }
end
local function updateBillboard(d, name, dist, col, hp, mhp, state)
    local lines = {}
    if name then table.insert(lines, name) end
    local details = {}
    if hp and mhp then table.insert(details, string.format('<font color="%s">Health: %.0f / %.0f</font>', getHealthColor(hp, mhp), hp, mhp)) end
    if dist then table.insert(details, "Distance: " .. string.format("%.0f", dist)) end
    if state then table.insert(details, "State: " .. state) end
    if #details > 0 then table.insert(lines, table.concat(details, " | ")) end
    d.textLabel.Text = table.concat(lines, "\n"); d.textLabel.TextColor3 = col
end
local function removeTargetESP(c, esp)
    if esp.box2D then remove2DBox(c) end
    if esp.box3D then remove3DBox(c) end
    if esp.highlight then removeHighlight(c) end
    if esp.billboard then destroyESPChild(c, "ESP_Billboard") end
end

local ItemESP = {
    entries = {},
    active = false,
    color = Color3.fromRGB(0, 255, 255),
    connection = nil,
}

local function iecCreateLabel(part)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_ItemLabel"; bb.Adornee = part; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 200, 0, 50); bb.StudsOffset = Vector3.new(0, 2, 0); bb.ClipsDescendants = false
    bb.Parent = part
    local tl = Instance.new("TextLabel"); tl.Name = "InfoLabel"; tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1; tl.TextColor3 = ItemESP.color; tl.TextSize = 10
    tl.Font = Enum.Font.GothamBold; tl.TextStrokeTransparency = 0; tl.TextWrapped = true; tl.Parent = bb
    return bb
end
local function iecCreateHighlight(inst)
    local hl = Instance.new("Highlight"); hl.Name = "ESP_ItemHighlight"; hl.Adornee = inst
    hl.FillColor = ItemESP.color; hl.OutlineColor = ItemESP.color
    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0.3
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = inst
    return hl
end
local function iecCreate2DBox(part)
    local bb = Instance.new("BillboardGui"); bb.Name = "ESP_ItemBox2D"; bb.Adornee = part
    bb.AlwaysOnTop = true; bb.Size = UDim2.fromScale(3, 3); bb.ClipsDescendants = false; bb.Parent = part
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.Parent = bb
    local st = Instance.new("UIStroke"); st.Thickness = 2; st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; st.Color = ItemESP.color; st.Parent = f
    return bb
end

local function iecRender(entry, settings, dist, name)
    local esp = entry.esp or {}; entry.esp = esp
    local part = entry.part
    if not part or not part.Parent then return end
    local function drop(k) if esp[k] then esp[k]:Destroy(); esp[k] = nil end end
    if settings.Boxes then
        if not esp.box2D or not esp.box2D.Parent then esp.box2D = iecCreate2DBox(part) end
    else drop("box2D") end
    if settings.Highlights then
        if not esp.highlight or not esp.highlight.Parent then esp.highlight = iecCreateHighlight(entry.model) end
    else drop("highlight") end
    if settings.Names or settings.Distance then
        if not esp.label or not esp.label.Parent then esp.label = iecCreateLabel(part) end
        local lines = {}
        if settings.Names then table.insert(lines, name) end
        if settings.Distance then table.insert(lines, string.format("Distance: %.0f", dist)) end
        esp.label.InfoLabel.Text = table.concat(lines, "\n")
    else drop("label") end
end

local function iecClear(entry)
    if entry.esp then for _, inst in pairs(entry.esp) do inst:Destroy() end end
    entry.esp = nil
end

local function iecUpdate()
    if not ECS then return end
    local settings = espSettings.Item
    local myPos = ecsMyPosition()
    local alive = {}
    for id in ECS.world:query(ECS.comps.Storable, ECS.comps.ObjectId, ECS.comps.ModelInstance) do
        local model = ecsGet(id, ECS.comps.ModelInstance)
        if model and model.Parent then
            local name = ecsGet(id, ECS.comps.ObjectId)
            local t = ecsGet(id, ECS.comps.Transform)
            local pos = t and (t.Position or t.p) or model:GetPivot().Position
            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) or model
            local dist = myPos and (pos - myPos).Magnitude or getDistanceFromCamera(pos)
            alive[model] = true
            local entry = ItemESP.entries[model]
            if not entry then
                entry = { model = model, part = part }
                ItemESP.entries[model] = entry
            else
                entry.part = part
            end
            iecRender(entry, settings, dist, name or model.Name)
        end
    end
    for model, entry in pairs(ItemESP.entries) do
        if not alive[model] then
            iecClear(entry)
            ItemESP.entries[model] = nil
        end
    end
end

local function iecClearAll()
    for _, entry in pairs(ItemESP.entries) do iecClear(entry) end
    ItemESP.entries = {}
end

local function iecStart()
    if ItemESP.active then return end
    ItemESP.active = true
    ItemESP.connection = RunService.RenderStepped:Connect(function() pcall(iecUpdate) end)
end
local function iecStop()
    if not ItemESP.active then return end
    ItemESP.active = false
    if ItemESP.connection then ItemESP.connection:Disconnect(); ItemESP.connection = nil end
    iecClearAll()
end

local function cleanupKind(kind) for c, esp in pairs(espElements[kind]) do removeTargetESP(c, esp) end espElements[kind] = {} end
local function cleanupTracerESP()
    for _, d in pairs(tracerEntries) do if d.pivot then d.pivot:Destroy() end end
    tracerEntries = {}
    if tracerGui then tracerGui:Destroy(); tracerGui = nil end
end
local function cleanupAllESP() cleanupKind("Player"); cleanupKind("Mob"); iecClearAll(); cleanupTracerESP() end
local function getTracerGui()
    if tracerGui and tracerGui.Parent then return tracerGui end
    local g = Instance.new("ScreenGui"); g.Name = "Tracer GUI"; g.ResetOnSpawn = false; g.IgnoreGuiInset = true
    g.DisplayOrder = -2147483648; g.Parent = PlayerGui; tracerGui = g; return g
end
local function ensureTracer(key, col)
    local d = tracerEntries[key]
    if d and d.pivot and d.pivot.Parent then d.line.BackgroundColor3 = col; return d end
    local pivot = Instance.new("Frame"); pivot.Name = "Tracer"; pivot.AnchorPoint = Vector2.new(0.5, 0.5)
    pivot.Position = UDim2.fromScale(0.5, 1); pivot.Size = UDim2.fromOffset(1, 1); pivot.BackgroundTransparency = 1
    pivot.Visible = false; pivot.ZIndex = -2147483648; pivot.Parent = getTracerGui()
    local line = Instance.new("Frame"); line.Name = "Line"; line.AnchorPoint = Vector2.new(0.5, 1)
    line.Position = UDim2.fromScale(0.5, 0.5); line.Size = UDim2.fromOffset(2, 0); line.BackgroundColor3 = col
    line.BorderSizePixel = 0; line.ZIndex = -2147483648; line.Parent = pivot
    d = { pivot = pivot, line = line, lastPos = d and d.lastPos or nil }; tracerEntries[key] = d; return d
end
local function drawTracer(d, wp, col)
    local cam = workspace.CurrentCamera
    if not cam or not wp then d.pivot.Visible = false; return end
    d.line.BackgroundColor3 = col
    local sp = cam:WorldToViewportPoint(wp); local vp = cam.ViewportSize
    local dx = sp.X - vp.X*0.5; local dy = sp.Y - vp.Y
    if sp.Z < 0 then dx = -dx; dy = -dy end
    if dx ~= dx or dy ~= dy then d.pivot.Visible = false; return end
    d.pivot.Visible = true
    d.pivot.Rotation = math.deg(math.atan2(dx, -dy))
    d.line.Size = UDim2.fromOffset(2, math.sqrt(dx*dx + dy*dy))
end
local function updateTracerESP()
    local pT, mT, iT = espSettings.Player.Tracers, espSettings.Mob.Tracers, espSettings.Item.Tracers
    if not pT and not mT and not iT then
        if next(tracerEntries) or tracerGui then cleanupTracerESP() end
        return
    end
    local alive = {}
    if pT then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                alive[pl] = true
                local col = pl.TeamColor.Color
                local d = ensureTracer(pl, col)
                local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                if r then d.lastPos = r.Position end
                if d.lastPos then drawTracer(d, d.lastPos, col) else d.pivot.Visible = false end
            end
        end
    end
    if mT then
        for m, h in pairs(trackedNPCs) do
            if m.Parent and h.Health > 0 then
                alive[m] = true
                local d = ensureTracer(m, mobColor)
                local r = m:FindFirstChild("HumanoidRootPart")
                if r then d.lastPos = r.Position end
                if d.lastPos then drawTracer(d, d.lastPos, mobColor) else d.pivot.Visible = false end
            end
        end
    end
    if iT then
        for model, entry in pairs(ItemESP.entries) do
            if model.Parent and entry.part and entry.part.Parent then
                alive[model] = true
                local d = ensureTracer(model, ItemESP.color)
                d.lastPos = entry.part.Position
                drawTracer(d, entry.part.Position, ItemESP.color)
            end
        end
    end
    for k, d in pairs(tracerEntries) do
        if not alive[k] then d.pivot:Destroy(); tracerEntries[k] = nil end
    end
end

local function updateTarget(kind, c, root, hum, col, dispName)
    local settings = espSettings[kind]
    local esp = espElements[kind][c]; if not esp then esp = {}; espElements[kind][c] = esp end
    local d = getDistanceFromCamera(root.Position)
    local sc = calculateBoxScale(d)
    local hp, mhp = hum.Health, hum.MaxHealth

    if settings.Boxes then
        if settings.BoxType == "2D" then
            if not esp.box2D or not esp.box2D.billboard.Parent then esp.box2D = create2DBox(c, col, sc) end
            update2DBox(esp.box2D, col, sc)
            if esp.box3D then remove3DBox(c); esp.box3D = nil end
        else
            if not esp.box3D or not esp.box3D.Parent then esp.box3D = create3DBox(c, col, Vector3.new(2, hum.HipHeight + 5, 2)) end
            update3DBoxColor(c, col)
            if esp.box2D then remove2DBox(c); esp.box2D = nil end
        end
    else
        if esp.box2D then remove2DBox(c); esp.box2D = nil end
        if esp.box3D then remove3DBox(c); esp.box3D = nil end
    end
    if settings.Highlights then
        if not esp.highlight or not esp.highlight.Parent then esp.highlight = createHighlight(c, col) end
        updateHighlight(esp.highlight, col)
    elseif esp.highlight then removeHighlight(c); esp.highlight = nil end
    if settings.Names or settings.Distance or settings.Health or settings.State then
        if not esp.billboard or not esp.billboard.billboard.Parent then esp.billboard = createBillboard(c, col) end
        updateBillboard(esp.billboard,
            settings.Names and dispName or nil,
            settings.Distance and d or nil,
            col,
            settings.Health and hp or nil,
            settings.Health and mhp or nil,
            settings.State and getCharacterState(c) or nil)
    elseif esp.billboard then destroyESPChild(c, "ESP_Billboard"); esp.billboard = nil end
end
local function sweepKind(kind, curr) for c, esp in pairs(espElements[kind]) do if not curr[c] then removeTargetESP(c, esp); espElements[kind][c] = nil end end end
local function updatePlayerESP()
    local curr = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local c = pl.Character; local r = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then curr[c] = true; updateTarget("Player", c, r, h, pl.TeamColor.Color, pl.Name) end
        end
    end
    sweepKind("Player", curr)
end
local function updateMobESP()
    local curr = {}
    for m, h in pairs(trackedNPCs) do
        if not m.Parent then trackedNPCs[m] = nil else
            local r = m:FindFirstChild("HumanoidRootPart")
            if r and h.Health > 0 then curr[m] = true; updateTarget("Mob", m, r, h, mobColor, m:GetAttribute("EntityName") or m.Name) end
        end
    end
    sweepKind("Mob", curr)
end
local function hasEnabledOption(s)
    for k, v in pairs(s) do if k ~= "BoxType" and v then return true end end
    return false
end
local function onESPRenderStepped()
    if not workspace.CurrentCamera then return end
    if hasEnabledOption(espSettings.Player) then updatePlayerESP() else cleanupKind("Player") end
    if hasEnabledOption(espSettings.Mob) then updateMobESP() else cleanupKind("Mob") end
    updateTracerESP()
end
local function refreshESP()
    local mobNeeded = hasEnabledOption(espSettings.Mob)
    if mobNeeded and not mobTrackingActive then mobTrackingActive = true; startNPCTracking()
    elseif not mobNeeded and mobTrackingActive then mobTrackingActive = false; stopNPCTracking(); cleanupKind("Mob") end

    local itemNeeded = hasEnabledOption(espSettings.Item)
    if itemNeeded then iecStart() else iecStop() end

    local anyEnabled = mobNeeded or itemNeeded or hasEnabledOption(espSettings.Player)
    if anyEnabled and not espConnection then
        espConnection = RunService.RenderStepped:Connect(onESPRenderStepped)
    elseif not anyEnabled and espConnection then
        espConnection:Disconnect(); espConnection = nil; cleanupAllESP()
    end
end
local function stopESP()
    for _, s in pairs(espSettings) do for k in pairs(s) do if k ~= "BoxType" then s[k] = false end end end
    refreshESP(); cleanupAllESP()
end
local function addESPToggle(kind, key, title, flag, desc)
    return Tabs.ESP:Toggle({ Title = title, Flag = flag, Desc = desc, Value = false,
        Callback = function(s) espSettings[kind][key] = s; refreshESP() end })
end
local function addESPBoxType(kind, title, flag)
    return Tabs.ESP:Dropdown({ Title = title, Flag = flag, Values = { "2D", "3D" }, Value = "2D",
        Callback = function(v) espSettings[kind].BoxType = v end })
end

local tracerWarning = "Warning: this may hurt performance and make the game laggy."

Tabs.ESP:Section({ Title = "Player ESP", TextSize = 20 })
Tabs.ESP:Divider()
addESPToggle("Player", "Names", "Player Names", "PlayerNames")
addESPToggle("Player", "Boxes", "Player Boxes", "PlayerBoxes")
addESPBoxType("Player", "Player Box Type", "PlayerBoxType")
addESPToggle("Player", "Distance", "Player Distance", "PlayerDistance")
addESPToggle("Player", "Health", "Player Health", "PlayerHealth")
addESPToggle("Player", "State", "Player State", "PlayerState")
addESPToggle("Player", "Highlights", "Player Highlights", "PlayerHighlights")
addESPToggle("Player", "Tracers", "Player Tracers", "PlayerTracerESP", tracerWarning)

Tabs.ESP:Divider()
Tabs.ESP:Section({ Title = "Mob ESP", TextSize = 20 })
Tabs.ESP:Divider()
addESPToggle("Mob", "Names", "Mob Names", "MobNames")
addESPToggle("Mob", "Boxes", "Mob Boxes", "MobBoxes")
addESPBoxType("Mob", "Mob Box Type", "MobBoxType")
addESPToggle("Mob", "Distance", "Mob Distance", "MobDistance")
addESPToggle("Mob", "Health", "Mob Health", "MobHealth")
addESPToggle("Mob", "State", "Mob State", "MobState")
addESPToggle("Mob", "Highlights", "Mob Highlights", "MobHighlights")
addESPToggle("Mob", "Tracers", "Mob Tracers", "MobTracerESP", tracerWarning)

Tabs.ESP:Divider()
Tabs.ESP:Section({ Title = "Item ESP", TextSize = 20 })
Tabs.ESP:Divider()
addESPToggle("Item", "Names", "Item Names", "ItemNames")
addESPToggle("Item", "Boxes", "Item Boxes", "ItemBoxes")
addESPToggle("Item", "Distance", "Item Distance", "ItemDistance")
addESPToggle("Item", "Highlights", "Item Highlights", "ItemHighlights")
addESPToggle("Item", "Tracers", "Item Tracers", "ItemTracerESP", tracerWarning)

local cameraCleanup
local cameraSensitivityUI
do
    local CAMERA_FOV_KEY = "CATHUBFov"
    local cameraModule
    local function getCameraController()
        if cameraModule == nil then
            local ok, m = pcall(function() return require(ReplicatedStorage.Shared.Universe.Camera) end)
            cameraModule = ok and m or false
        end
        return cameraModule and cameraModule.Instance or nil
    end
    Tabs.Visuals:Space(); Tabs.Visuals:Divider()
    Tabs.Visuals:Section({ Title = "Game Camera", TextSize = 20 })
    Tabs.Visuals:Divider()

    local thirdPersonConnection, thirdPersonActive, thirdPersonOriginal
    local function stopThirdPerson()
        if thirdPersonConnection then thirdPersonConnection:Disconnect(); thirdPersonConnection = nil end
        if thirdPersonActive then
            thirdPersonActive = false
            workspace:SetAttribute("IsThirdpersonAllowed", thirdPersonOriginal)
            local c = getCameraController(); if c then c:DoZoom(0, true) end
        end
    end
    local function startThirdPerson()
        stopThirdPerson()
        local c = getCameraController(); if not c then return false end
        thirdPersonActive = true
        thirdPersonOriginal = workspace:GetAttribute("IsThirdpersonAllowed")
        workspace:SetAttribute("IsThirdpersonAllowed", true)
        if c.Zoom < c.MinZoom then c:DoZoom(12, true) end
        thirdPersonConnection = RunService.Heartbeat:Connect(function()
            if workspace:GetAttribute("IsThirdpersonAllowed") ~= true then workspace:SetAttribute("IsThirdpersonAllowed", true) end
        end)
        return true
    end
    ForceThirdPersonToggle = Tabs.Visuals:Toggle({ Title = "Force Third Person", Flag = "ForceThirdPersonToggle", Value = false,
        Callback = function(s) if s then if not startThirdPerson() then WindUI:Notify({ Title = "Third Person", Content = "Game camera not found", Duration = 3 }); ForceThirdPersonToggle:Set(false) end else stopThirdPerson() end end })

    local fovEnabled, fovTarget, fovConnection = false, 70, nil
    local function stopFov()
        if fovConnection then fovConnection:Disconnect(); fovConnection = nil end
        local c = getCameraController(); if c and c.fov then c.fov[CAMERA_FOV_KEY] = nil end
    end
    local function startFov()
        stopFov()
        fovConnection = RunService.RenderStepped:Connect(function()
            local c = getCameraController(); if not c or not c.fov then return end
            local own = c.fov[CAMERA_FOV_KEY]; if type(own) ~= "number" then own = 0 end
            local others = c:GetFovAll() - own
            c:SetFov(CAMERA_FOV_KEY, fovTarget - others)
        end)
    end
    CustomFovToggle = Tabs.Visuals:Toggle({ Title = "Custom FOV", Flag = "CustomFovToggle", Value = false,
        Callback = function(s) fovEnabled = s; if s then startFov() else stopFov() end end })
    CustomFovSlider = Tabs.Visuals:Slider({ Title = "Field of View", Flag = "CustomFovSlider", Step = 1, Value = { Min = 1, Max = 120, Default = 70 },
        Callback = function(v) fovTarget = tonumber(v) or 70 end })

    local SENSITIVITY_KEY = "CATHUBSensitivity"
    local sensitivityValue, sensitivityConnection = 1, nil
    local function stopSensitivity()
        if sensitivityConnection then sensitivityConnection:Disconnect(); sensitivityConnection = nil end
        local c = getCameraController(); if c and c.sensitivities then c.sensitivities[SENSITIVITY_KEY] = nil end
    end
    local function startSensitivity()
        stopSensitivity()
        sensitivityConnection = RunService.Heartbeat:Connect(function()
            local c = getCameraController()
            if c and c.sensitivities and c.sensitivities[SENSITIVITY_KEY] ~= sensitivityValue then c.sensitivities[SENSITIVITY_KEY] = sensitivityValue end
        end)
    end
    cameraSensitivityUI = function()
        Tabs.Settings:Space()
        Tabs.Settings:Section({ Title = "Camera Sensitivity", TextSize = 20 })
        Tabs.Settings:Divider()
        CameraSensitivityToggle = Tabs.Settings:Toggle({ Title = "Camera Sensitivity", Flag = "CameraSensitivityToggle", Value = false,
            Callback = function(s) if s then startSensitivity() else stopSensitivity() end end })
        CameraSensitivitySlider = Tabs.Settings:Slider({ Title = "Sensitivity Multiplier", Flag = "CameraSensitivitySlider", Step = 0.05, Value = { Min = 0.1, Max = 20, Default = 1 },
            Callback = function(v) sensitivityValue = tonumber(v) or 1 end })
    end

    local aim = { enabled = false, part = "Head", types = { Mob = true }, smoothness = 10, maxDistance = 1000, wallCheck = false, showFov = false, fovRadius = 100, fovColor = Color3.fromRGB(0, 255, 0), tracking = false, bound = false }
    local fovGui, fovCircle, fovStroke
    local function updateFovCircle()
        if not aim.showFov then if fovGui then fovGui.Enabled = false end return end
        if not fovGui or not fovGui.Parent then
            fovGui = Instance.new("ScreenGui"); fovGui.Name = "DaraAimbotFOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true; fovGui.Parent = PlayerGui
            fovCircle = Instance.new("Frame"); fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.fromScale(0.5, 0.5)
            fovCircle.BackgroundTransparency = 1; fovCircle.BorderSizePixel = 0; fovCircle.Parent = fovGui
            local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(1, 0); cr.Parent = fovCircle
            fovStroke = Instance.new("UIStroke"); fovStroke.Thickness = 2; fovStroke.Parent = fovCircle
        end
        fovGui.Enabled = true
        fovCircle.Size = UDim2.fromOffset(aim.fovRadius*2, aim.fovRadius*2)
        fovStroke.Color = aim.fovColor
    end
    local function syncAimbotTracking()
        local needed = aim.enabled and aim.types.Mob == true
        if needed and not aim.tracking then aim.tracking = true; startNPCTracking()
        elseif not needed and aim.tracking then aim.tracking = false; stopNPCTracking() end
    end
    local function selectAimPart(c)
        if aim.part == "Head" then return c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
        elseif aim.part == "Legs" then return c:FindFirstChild("LowerTorso") or c:FindFirstChild("Left Leg") or c:FindFirstChild("HumanoidRootPart") end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
    end
    local function isVisible(cam, part, c)
        if not aim.wallCheck then return true end
        local ignore = { c }; if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
        local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignore
        local o = cam.CFrame.Position
        return workspace:Raycast(o, part.Position - o, params) == nil
    end
    local function evaluate(cam, center, c, h)
        if not h or h.Health <= 0 then return nil end
        local p = selectAimPart(c); if not p then return nil end
        if (p.Position - cam.CFrame.Position).Magnitude > aim.maxDistance then return nil end
        local s, on = cam:WorldToViewportPoint(p.Position); if not on then return nil end
        local d = (Vector2.new(s.X, s.Y) - center).Magnitude
        if d > aim.fovRadius then return nil end
        if not isVisible(cam, p, c) then return nil end
        return p, d
    end
    local function aimStep(dt)
        if not aim.enabled then return end
        local ctrl = getCameraController(); local cam = workspace.CurrentCamera
        if not ctrl or not cam or not ctrl.Rotations or not ctrl.Rotations.MouseLook then return end
        local mh = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not mh or mh.Health <= 0 then return end
        local center = cam.ViewportSize/2; local bestPart, bestDist
        if aim.types.Mob then
            for m, h in pairs(trackedNPCs) do
                if m.Parent then
                    local p, d = evaluate(cam, center, m, h)
                    if p and (not bestDist or d < bestDist) then bestPart, bestDist = p, d end
                end
            end
        end
        if not bestPart then return end
        local dir = bestPart.Position - ctrl:GetPositionCharacter()
        if dir.Magnitude < 0.001 then return end
        dir = dir.Unit
        local tPitch = math.deg(math.asin(math.clamp(dir.Y, -1, 1)))
        local tYaw = math.deg(math.atan2(-dir.X, -dir.Z))
        local cur = ctrl.Rotations.MouseLook
        local dYaw = ((tYaw - cur.Y + 180) % 360) - 180
        local dPitch = tPitch - cur.X
        local f = math.clamp(1 - (aim.smoothness/20), 0.001, 1)
        local a = math.clamp(f * math.min(dt*60, 1), 0, 1)
        ctrl.Rotations.MouseLook = Vector3.new(math.clamp(cur.X + dPitch*a, -80, 80), cur.Y + dYaw*a, cur.Z)
    end
    local function startAimbot() if aim.bound then return end aim.bound = true; RunService:BindToRenderStep("CATHUBAimbot", Enum.RenderPriority.Camera.Value - 2, aimStep) end
    local function stopAimbot() if aim.bound then aim.bound = false; pcall(function() RunService:UnbindFromRenderStep("CATHUBAimbot") end) end end

    Tabs.Combat:Space()
    Tabs.Combat:Section({ Title = "Aimbot", TextSize = 20 })
    Tabs.Combat:Divider()
    AimbotToggle = Tabs.Combat:Toggle({ Title = "Aimbot", Flag = "AimbotToggle", Value = false,
        Callback = function(s)
            if s and not getCameraController() then WindUI:Notify({ Title = "Aimbot", Content = "Game camera not found", Duration = 3 }); AimbotToggle:Set(false); return end
            aim.enabled = s; if s then startAimbot() else stopAimbot() end; syncAimbotTracking()
        end })
    Tabs.Combat:Dropdown({ Title = "Aim Part", Flag = "AimPartDropdown", Values = { "Head", "Body", "Legs" }, Value = "Head",
        Callback = function(v) aim.part = v end })
    Tabs.Combat:Slider({ Title = "Smoothness", Flag = "AimSmoothnessSlider", Desc = "Higher = smoother aim", Step = 0.01, Value = { Min = 0.01, Max = 20, Default = 10 },
        Callback = function(v) aim.smoothness = tonumber(v) or 10 end })
    Tabs.Combat:Input({ Title = "Aimbot Max Distance", Flag = "AimMaxDistanceInput", Placeholder = "1000", Value = tostring(aim.maxDistance),
        Callback = function(v) local n = tonumber(v); if n and n > 0 then aim.maxDistance = n end end })
    Tabs.Combat:Toggle({ Title = "Wall Check", Flag = "AimWallCheckToggle", Value = false, Callback = function(s) aim.wallCheck = s end })
    Tabs.Combat:Space()
    Tabs.Combat:Section({ Title = "Aimbot FOV", TextSize = 20 })
    Tabs.Combat:Divider()
    Tabs.Combat:Toggle({ Title = "Show FOV Circle", Flag = "AimShowFovToggle", Value = false, Callback = function(s) aim.showFov = s; updateFovCircle() end })
    Tabs.Combat:Slider({ Title = "FOV Radius", Flag = "AimFovRadiusSlider", Step = 1, Value = { Min = 10, Max = 800, Default = 100 },
        Callback = function(v) aim.fovRadius = tonumber(v) or 100; updateFovCircle() end })
    Tabs.Combat:Colorpicker({ Title = "FOV Circle Color", Flag = "AimFovColorPicker", Default = aim.fovColor,
        Callback = function(c) aim.fovColor = c; updateFovCircle() end })

    cameraCleanup = function()
        stopAimbot(); aim.enabled = false; syncAimbotTracking()
        if fovGui then fovGui:Destroy(); fovGui = nil end
        stopThirdPerson(); stopFov(); stopSensitivity()
    end
end

Tabs.Misc:Section({ Title = "Utility", TextSize = 20 })
Tabs.Misc:Divider()
local antiAfkConnection
local function stopAntiAfk() if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end end
AntiAfkToggle = Tabs.Misc:Toggle({ Title = "Anti AFK", Flag = "AntiAfkToggle", Value = false,
    Callback = function(s)
        stopAntiAfk()
        if s then
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                local cam = workspace.CurrentCamera
                VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
            end)
        end
    end })

Tabs.Misc:Space()
Tabs.Misc:Section({ Title = "Auto Pilot", TextSize = 20 })
Tabs.Misc:Divider()

local autopilot = {
    enabled = false,
    keybind = Enum.KeyCode.RightShift
}

local autopilotControls
local autopilotPatched = setmetatable({}, { __mode = "k" })

local function isSitting()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0 and h.Sit and h.SeatPart ~= nil
end

local function patchAutopilotController(controller)
    if not controller or autopilotPatched[controller] then return end
    autopilotPatched[controller] = true

    local originalGetMoveVector = controller.GetMoveVector
    controller.GetMoveVector = function(self, ...)
        local moveVector = originalGetMoveVector(self, ...)
        if not autopilot.enabled or not isSitting() then return moveVector end
        if not self:IsMoveVectorCameraRelative() then return moveVector end
        if moveVector.Magnitude > 0 then return moveVector end
        return Vector3.new(0, 0, -1)
    end
end

local function stopAutopilot()
    autopilot.enabled = false
    pcall(function() RunService:UnbindFromRenderStep("CATHUBAutoPilot") end)
end

local function startAutopilot()
    if not autopilotControls then
        local ok, controls = pcall(function()
            local pm = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5)
            return require(pm):GetControls()
        end)
        if not ok or not controls then return false end
        autopilotControls = controls
    end
    pcall(function() RunService:UnbindFromRenderStep("CATHUBAutoPilot") end)
    RunService:BindToRenderStep("CATHUBAutoPilot", Enum.RenderPriority.Input.Value - 1, function()
        patchAutopilotController(autopilotControls:GetActiveController())
    end)
    autopilot.enabled = true
    return true
end

local function setAutopilot(state)
    stopAutopilot()
    if state and not startAutopilot() then
        WindUI:Notify({ Title = "Auto Pilot", Content = "Could not load the control module", Duration = 3 })
        if AutoPilotToggle then AutoPilotToggle:Set(false) end
    end
end

AutoPilotToggle = Tabs.Misc:Toggle({
    Title = "Auto Pilot",
    Flag = "AutoPilotToggle",
    Value = false,
    Callback = function(s) setAutopilot(s) end
})

if Tabs.Misc.Keybind then
    Tabs.Misc:Keybind({
        Title = "Auto Pilot Keybind",
        Flag = "AutoPilotKeybind",
        Desc = "Press this key to toggle Auto Pilot",
        Value = "RightShift",
        Callback = function(key)
            local ok, code = pcall(function() return Enum.KeyCode[key] end)
            if ok and code then autopilot.keybind = code end
        end
    })
end

ShowAutoPilotButtonToggle = Tabs.Misc:Toggle({
    Title = "Show Auto Pilot Button",
    Flag = "ShowAutoPilotButton",
    Value = false,
    Callback = function(state)
        if ButtonLib and ButtonLib.AutoPilotToggle then ButtonLib.AutoPilotToggle:SetVisible(state) end
    end
})

function ScanObjectEntries(folder, requires)
    local entries, all = {}, {}
    if not folder then return entries end
    if not ECS then ECS = loadECS() end
    local compNames, hasNames = {}, false
    if ECS and type(ECS.comps) == "table" then
        for k, v in pairs(ECS.comps) do
            local t = type(v)
            if t == "table" or t == "function" or t == "userdata" or t == "number" then compNames[v] = tostring(k); hasNames = true end
        end
    end
    local function describe(module)
        local okR, data = pcall(require, module)
        if not okR or type(data) ~= "table" or type(data.components) ~= "table" then return nil, nil, nil end
        local displayName
        local parts, caps = {}, {}
        for comp, val in pairs(data.components) do
            local cname = compNames[comp]
            if cname then
                caps[cname] = true
                local tv = type(val)
                if not string.find(cname, "Path$") and (tv == "string" or tv == "number" or tv == "boolean") then
                    if cname == "Name" then displayName = tostring(val)
                    else table.insert(parts, cname .. ": " .. tostring(val)) end
                end
            end
        end
        if type(data.tags) == "table" then
            for _, tag in pairs(data.tags) do
                local tname = compNames[tag]
                if tname then caps[tname] = true end
            end
        end
        table.sort(parts)
        return displayName, (#parts > 0 and table.concat(parts, " | ") or nil), caps
    end
    local seen, usedTitles, count = {}, {}, 0
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("ModuleScript") then
            if not seen[d.Name] then
                seen[d.Name] = true
                local displayName, details, caps = describe(d)
                local title = displayName or d.Name
                if usedTitles[title] then title = d.Name end
                usedTitles[title] = true
                local e = { Title = title, Id = d.Name, Desc = details }
                table.insert(all, e)
                local matches = true
                if requires and caps and hasNames then
                    matches = false
                    for _, r in ipairs(requires) do
                        if caps[r] then matches = true; break end
                    end
                end
                if matches then table.insert(entries, e) end
            end
            count += 1
            if count % 40 == 0 then task.wait() end
        end
    end
    if #entries == 0 then entries = all end
    table.sort(entries, function(x, y) return x.Title < y.Title end)
    return entries
end

function CreateListFilter(opts)
    local titleToId, idToTitle, selected = {}, {}, {}
    local dropdown
    local function toSet(values)
        local set = {}
        if type(values) == "table" then
            for _, n in ipairs(values) do
                local title = type(n) == "table" and n.Title or n
                if title ~= nil then set[titleToId[tostring(title)] or tostring(title)] = true end
            end
        end
        return set
    end
    dropdown = opts.Tab:Dropdown({ Title = opts.Title, Flag = opts.Flag, Desc = opts.Desc or "Empty = everything", Values = {}, Value = {}, Multi = true, AllowNone = true, SearchBarEnabled = true,
        Callback = function(v) selected = toSet(v); opts.OnChange(selected) end })
    opts.Tab:Button({ Title = "Refresh " .. opts.Title,
        Callback = function()
            local entries = opts.Scan()
            if #entries == 0 then WindUI:Notify({ Title = opts.Title, Content = "No items found", Duration = 3 }); return end
            table.clear(titleToId); table.clear(idToTitle)
            local view = {}
            for _, e in ipairs(entries) do
                titleToId[e.Title] = e.Id; idToTitle[e.Id] = e.Title
                table.insert(view, { Title = e.Title, Desc = e.Desc })
            end
            local sel = {}
            for id in pairs(selected) do if idToTitle[id] then table.insert(sel, idToTitle[id]) end end
            if dropdown and dropdown.Refresh then dropdown:Refresh(view, sel) end
            WindUI:Notify({ Title = opts.Title, Content = #entries .. " found", Duration = 3 })
        end })
    return dropdown
end

local farmCleanup
do
    local farm = {
        collectAll = false, bond = false, minDistance = 15,
        filters = { bring = {}, nearby = {}, pickup = {} },
        filterNorm = { bring = {}, nearby = {}, pickup = {} },
        nearby = false, pickup = false, moneyBag = false, moneyBagDistance = 15,
        auraRange = 15, nearbyDistance = 15, delay = 0.25,
        bringDelay = 0.1, nearbyDelay = 0.1, pickupDelay = 0.1, bondDelay = 0.1,
        collectRun = 0, autoRetry = false, emptyPasses = 0, lastRetry = 0
    }

    local function getMyPos() return ecsMyPosition() end

    local function retryRun()
        pcall(function() ReplicatedStorage.Shared.Universe.Network.RemoteEvent.ResetCharacter:FireServer() end)
        pcall(function() ReplicatedStorage.Remotes.EndDecision:FireServer(false) end)
        WindUI:Notify({ Title = "Auto Retry", Content = "No bonds left, retrying", Duration = 3 })
    end

    local function collectPass(modules)
        if not ECS then return end
        local world, comps = modules.world, modules.comps
        local state = world:get_resource(comps.ClientStateResource)
        local character = state and state.localCharacter
        if not character then return end
        if not world:has(character, comps.Sack) then
            world:add(character, comps.Sack)
            world:set(character, comps.Sack, { contents = {}, maxContents = 10 })
        end
        local myPos = getMyPos(); if not myPos then return end

        local bondNear, bondFar = {}, {}
        local bondTotal = 0
        local checked = 0
        for id in world:query(comps.Storable, comps.ObjectId) do
            if not (farm.collectAll or farm.bond or farm.moneyBag or farm.nearby or farm.pickup) then return end
            local objectId = world:get(id, comps.ObjectId)
            if objectId == "bond" then bondTotal += 1 end
            local isBond = (farm.bond and objectId == "bond") or (farm.moneyBag and objectId == "money_bag")
            local function allowed(key) return next(farm.filters[key]) == nil or farm.filterNorm[key][normalizeName(tostring(objectId))] == true end
            local isBring = not isBond and farm.collectAll and allowed("bring")
            local isNearby = not isBond and farm.nearby and allowed("nearby")
            local isPickup = not isBond and farm.pickup and allowed("pickup")
            if isBond or isBring or isNearby or isPickup then
                local serverEntity = modules.replicator:get_server_entity(id)
                if serverEntity and serverEntity ~= id then
                    local t = world:get(id, comps.Transform)
                    local pos = t and (t.Position or t.p)
                    local dist = pos and (pos - myPos).Magnitude or math.huge
                    if isBond then
                        local range = objectId == "money_bag" and farm.moneyBagDistance or farm.nearbyDistance
                        if dist <= range then table.insert(bondNear, serverEntity)
                        else table.insert(bondFar, serverEntity) end
                    else
                        if isBring and dist > farm.minDistance then
                            modules.remotes.Store:FireServer(serverEntity); modules.remotes.Store:FireServer()
                            if farm.bringDelay > 0 then task.wait(farm.bringDelay) end
                        end
                        if isNearby and dist <= farm.nearbyDistance then
                            if world:has(id, comps.Actionable) then
                                modules.actionable:FireServer(serverEntity)
                                if farm.nearbyDelay > 0 then task.wait(farm.nearbyDelay) end
                            end
                        end
                        if isPickup and dist <= farm.auraRange then
                            if world:has(id, comps.Pickupable) then
                                modules.pickup:FireServer(serverEntity)
                                if farm.pickupDelay > 0 then task.wait(farm.pickupDelay) end
                            end
                        end
                    end
                end
            end
            checked += 1
            if checked % 20 == 0 then task.wait() end
        end

        if farm.bond and farm.autoRetry then
            if bondTotal == 0 then
                farm.emptyPasses += 1
                if farm.emptyPasses >= 3 and os.clock() - farm.lastRetry > 15 then
                    farm.emptyPasses = 0
                    farm.lastRetry = os.clock()
                    retryRun()
                    return
                end
            else
                farm.emptyPasses = 0
            end
        end

        if #bondNear > 0 then
            for _, sr in ipairs(bondNear) do
                modules.actionable:FireServer(sr)
                if farm.bondDelay > 0 then task.wait(farm.bondDelay) end
            end
            return
        end
        for _, sr in ipairs(bondFar) do
            if not (farm.bond or farm.moneyBag) then return end
            modules.remotes.Store:FireServer(sr); modules.remotes.Store:FireServer(); modules.actionable:FireServer(sr)
            if farm.bondDelay > 0 then task.wait(farm.bondDelay) end
        end
    end

    local function refreshCollect()
        local needed = farm.collectAll or farm.bond or farm.moneyBag or farm.nearby or farm.pickup
        farm.collectRun += 1
        farm.emptyPasses = 0
        if not needed then return end
        local run = farm.collectRun
        task.spawn(function()
            while farm.collectRun == run do
                if not ECS then ECS = loadECS() end
                if not ECS then
                    WindUI:Notify({ Title = "Auto Collect", Content = "Game item modules not found", Duration = 3 })
                    farm.collectAll = false; farm.bond = false; farm.moneyBag = false; farm.nearby = false; farm.pickup = false
                    return
                end
                pcall(collectPass, ECS)
                task.wait(farm.delay)
            end
        end)
    end

    local function addFilter(title, flag, key, requires)
        CreateListFilter({
            Tab = Tabs.Misc, Title = title, Flag = flag,
            Scan = function()
                local ok, folder = pcall(function() return ReplicatedStorage.Shared.Universe.Object.Objects end)
                if not ok or not folder then return {} end
                return ScanObjectEntries(folder, requires)
            end,
            OnChange = function(set)
                farm.filters[key] = set
                local norm = {}
                for n in pairs(set) do norm[normalizeName(n)] = true end
                farm.filterNorm[key] = norm
            end
        })
    end
    local function addToggle(title, flag, desc, field)
        Tabs.Misc:Toggle({ Title = title, Flag = flag, Value = false, Desc = desc,
            Callback = function(s) farm[field] = s; refreshCollect() end })
    end

    Tabs.Misc:Space()
    Tabs.Misc:Section({ Title = "Bring Items", TextSize = 20 })
    Tabs.Misc:Divider()
    addToggle("Bring Items", "AutoCollectToggle", "Brings items to you (skips nearby)", "collectAll")
    addFilter("Bring Item Filter", "BringFilterDropdown", "bring", { "Pickupable", "Actionable" })
    Tabs.Misc:Input({ Title = "Ignore Bring Distance", Flag = "BringDistanceInput", Desc = "Items within this range are ignored", Placeholder = "15", Value = tostring(farm.minDistance),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.minDistance = n end end })
    Tabs.Misc:Input({ Title = "Bring Delay", Flag = "BringDelayInput", Placeholder = "0.1", Value = tostring(farm.bringDelay),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.bringDelay = n end end })

    Tabs.Misc:Space()
    Tabs.Misc:Section({ Title = "Collect Nearby", TextSize = 20 })
    Tabs.Misc:Divider()
    addToggle("Collect Nearby Items", "CollectNearbyToggle", "Collects items within range of you", "nearby")
    addFilter("Collect Nearby Filter", "NearbyFilterDropdown", "nearby", { "Actionable" })
    Tabs.Misc:Input({ Title = "Nearby Distance", Flag = "NearbyDistanceInput", Placeholder = "15", Value = tostring(farm.nearbyDistance),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.nearbyDistance = n end end })
    Tabs.Misc:Input({ Title = "Collect Nearby Delay", Flag = "NearbyDelayInput", Placeholder = "0.1", Value = tostring(farm.nearbyDelay),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.nearbyDelay = n end end })

    Tabs.Misc:Space()
    Tabs.Misc:Section({ Title = "Item Aura", TextSize = 20 })
    Tabs.Misc:Divider()
    addToggle("Item Aura", "ItemAuraToggle", "Picks up every item within range below", "pickup")
    addFilter("Item Aura Filter", "PickupFilterDropdown", "pickup", { "Pickupable" })
    Tabs.Misc:Input({ Title = "Aura Range", Flag = "AuraRangeInput", Placeholder = "15", Value = tostring(farm.auraRange),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.auraRange = n end end })
    Tabs.Misc:Input({ Title = "Item Aura Delay", Flag = "PickupDelayInput", Placeholder = "0.1", Value = tostring(farm.pickupDelay),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.pickupDelay = n end end })

    Tabs.Misc:Space()
    Tabs.Misc:Section({ Title = "Auto Farm", TextSize = 20 })
    Tabs.Misc:Divider()
    addToggle("Auto Farm Bond", "AutoFarmBondToggle", "Collects bonds near first, then brings far bonds", "bond")
    Tabs.Misc:Toggle({ Title = "Auto Retry When No Bond Left", Type = "Checkbox", Flag = "AutoRetryNoBondToggle", Desc = "Needs Auto Farm Bond. Resets and declines the next run when no bonds are left", Value = false,
        Callback = function(s) farm.autoRetry = s; farm.emptyPasses = 0 end })
    Tabs.Misc:Space()
    addToggle("Auto Collect Money Bag", "AutoCollectMoneyBagToggle", "Collects money bags near first, then brings far ones", "moneyBag")
    Tabs.Misc:Input({ Title = "Money Bag Distance", Flag = "MoneyBagDistanceInput", Placeholder = "15", Value = tostring(farm.moneyBagDistance),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.moneyBagDistance = n end end })
    Tabs.Misc:Input({ Title = "Bond / Money Bag Delay", Flag = "BondDelayInput", Placeholder = "0.1", Value = tostring(farm.bondDelay),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then farm.bondDelay = n end end })

    local weldHook = { active = false, original = nil, raw = false, world = nil, cache = nil, cachedAt = 0, cachedFor = nil }
    local function findWeldTarget(modules, dragged)
        local now = os.clock()
        if weldHook.cachedFor == dragged and now - weldHook.cachedAt < 0.25 then return weldHook.cache end
        local world, comps = modules.world, modules.comps
        local draggedModel = world:get(dragged, comps.ModelInstance); if not draggedModel then return nil end
        local origin = draggedModel:GetPivot().Position
        local bestEntity, bestDist
        for id in world:query(comps.WeldSurface, comps.ModelInstance) do
            if id ~= dragged and not modules.isShopItem(id) then
                local model = world:get(id, comps.ModelInstance)
                if model and model.Parent and not model:IsDescendantOf(draggedModel) then
                    local d = (model:GetPivot().Position - origin).Magnitude
                    if not bestDist or d < bestDist then bestEntity, bestDist = id, d end
                end
            end
        end
        weldHook.cache = bestEntity; weldHook.cachedAt = now; weldHook.cachedFor = dragged
        return bestEntity
    end
    local function stopWeldAnywhere()
        if not weldHook.active then return end
        weldHook.active = false
        local w = weldHook.world
        if w then if weldHook.raw then w.insert_resource = weldHook.original else w.insert_resource = nil end end
        weldHook.world = nil; weldHook.original = nil; weldHook.cache = nil
    end
    local function startWeldAnywhere()
        stopWeldAnywhere()
        if not ECS then ECS = loadECS() end
        if not ECS then return false end
        local world, comps = ECS.world, ECS.comps
        local original = world.insert_resource
        if type(original) ~= "function" then return false end
        weldHook.world = world; weldHook.original = rawget(world, "insert_resource"); weldHook.raw = weldHook.original ~= nil; weldHook.active = true
        world.insert_resource = function(self, component, value, ...)
            if weldHook.active and component == comps.DraggingStateResource and type(value) == "table" then
                local dragged = value.draggingEntity
                if dragged and not value.weldTarget and world:has(dragged, comps.Weldable) and not ECS.isShopItem(dragged) then
                    local target = findWeldTarget(ECS, dragged)
                    if target then value = table.clone(value); value.weldTarget = target end
                end
            end
            return original(self, component, value, ...)
        end
        return true
    end
    Tabs.Misc:Space()
    Tabs.Misc:Section({ Title = "Weld", TextSize = 20 })
    Tabs.Misc:Divider()
    WeldAnywhereToggle = Tabs.Misc:Toggle({ Title = "Weld Anywhere", Flag = "WeldAnywhereToggle", Value = false,
        Callback = function(s) if s then if not startWeldAnywhere() then WindUI:Notify({ Title = "Weld Anywhere", Content = "Could not hook the weld system", Duration = 3 }); WeldAnywhereToggle:Set(false) end else stopWeldAnywhere() end end })

    farmCleanup = function()
        stopWeldAnywhere()
        farm.collectAll = false; farm.bond = false; farm.moneyBag = false; farm.nearby = false; farm.pickup = false
        farm.collectRun += 1
    end
end

local extraCleanups = {}

do
    local BANDAGE_FAST_TIME = 0.05
    local bandage = { connections = {}, watched = {}, enabled = false }
    local function patchBandageScript(cs)
        if not (getconnections and getfenv and debug and debug.getconstants and debug.setconstant) then return end
        for _, conn in ipairs(getconnections(RunService.RenderStepped)) do
            local fn = conn.Function
            if type(fn) == "function" then
                local ok, env = pcall(getfenv, fn)
                if ok and type(env) == "table" and rawget(env, "script") == cs then
                    local okC, consts = pcall(debug.getconstants, fn)
                    if okC then for i, v in pairs(consts) do if v == 3.7 then pcall(debug.setconstant, fn, i, BANDAGE_FAST_TIME) end end end
                end
            end
        end
    end
    local function watchTool(tool)
        if not bandage.enabled or bandage.watched[tool] or not tool:IsA("Tool") then return end
        task.spawn(function()
            local cs = tool:WaitForChild("BandageClient", 5)
            if not cs or not bandage.enabled or bandage.watched[tool] then return end
            bandage.watched[tool] = true
            table.insert(bandage.connections, tool.Equipped:Connect(function() task.delay(0.1, patchBandageScript, cs) end))
            if tool.Parent == LocalPlayer.Character then task.delay(0.1, patchBandageScript, cs) end
        end)
    end
    local function watchContainer(c)
        for _, ch in ipairs(c:GetChildren()) do watchTool(ch) end
        table.insert(bandage.connections, c.ChildAdded:Connect(watchTool))
    end
    local function stopBandage()
        bandage.enabled = false
        for _, c in ipairs(bandage.connections) do c:Disconnect() end
        table.clear(bandage.connections); table.clear(bandage.watched)
    end
    local function startBandage()
        stopBandage(); bandage.enabled = true
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack"); if bp then watchContainer(bp) end
        if LocalPlayer.Character then watchContainer(LocalPlayer.Character) end
        table.insert(bandage.connections, LocalPlayer.CharacterAdded:Connect(function(c)
            table.clear(bandage.watched); watchContainer(c)
            local nb = LocalPlayer:WaitForChild("Backpack", 5); if nb then watchContainer(nb) end
        end))
    end
    Tabs.Main:Toggle({ Title = "Remove Bandage Cooldown", Flag = "RemoveBandageCooldownToggle", Value = false,
        Callback = function(s)
            if s then if not (getconnections and debug and debug.setconstant) then WindUI:Notify({ Title = "Bandage", Content = "Your executor does not support this", Duration = 3 }) end; startBandage() else stopBandage() end
        end })
    table.insert(extraCleanups, stopBandage)
end

do
    local GUN_PELLETS = 15
    local gun = { enabled = false, range = 50, scanDelay = 0.05, filter = {}, allowed = {}, run = 0, tracking = false, lastShotAt = 0, lastReloadAt = 0 }
    local function gunKey(n) return (string.lower(n):gsub("[^%w]", "")) end
    local function getGunFolder() local ok, f = pcall(function() return ReplicatedStorage.Assets.Tools.Weapon.Gun end); return ok and f or nil end
    local function getGunObjectFolder()
        local ok, f = pcall(function() return ReplicatedStorage.Shared.Universe.Object.Objects.Weapon.Gun end)
        return ok and f or nil
    end
    local function getGunNames()
        local names, seen = {}, {}
        local f = getGunObjectFolder()
        if f then
            for _, d in ipairs(f:GetDescendants()) do
                if d:IsA("ModuleScript") and not seen[d.Name] then seen[d.Name] = true; table.insert(names, d.Name) end
            end
        end
        if #names == 0 then
            local tf = getGunFolder()
            if tf then for _, ch in ipairs(tf:GetChildren()) do table.insert(names, ch.Name) end end
        end
        table.sort(names); return names
    end
    local function rebuildAllowed()
        local a = {}
        if next(gun.filter) ~= nil then for n in pairs(gun.filter) do a[gunKey(n)] = true end
        else for _, n in ipairs(getGunNames()) do a[gunKey(n)] = true end end
        gun.allowed = a
    end
    local function getWeaponConfig(tool)
        local cfg = tool:FindFirstChild("WeaponConfiguration"); local state = tool:FindFirstChild("ClientWeaponState")
        if not cfg or not state then return nil end
        return { fireDelay = cfg:FindFirstChild("FireDelay"), autoFireDelay = cfg:FindFirstChild("AutoFireDelay"), currentAmmo = state:FindFirstChild("CurrentAmmo"), isReloading = state:FindFirstChild("IsReloading"), lastFireTime = state:FindFirstChild("LastFireTime"), bulletType = cfg:FindFirstChild("BulletType") }
    end
    local function hasAmmo(wc)
        if not wc then return true end
        local bt = wc.bulletType and wc.bulletType.Value
        if not bt or bt == "" then return true end
        local c = LocalPlayer:GetAttribute(bt .. "Ammo"); if c ~= nil then return c > 0 end
        return true
    end
    local function triggerReload(tool)
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        r = r and r:FindFirstChild("Weapon"); r = r and r:FindFirstChild("Reload")
        if r then r:FireServer(0, tool) end
    end
    local function isGunReady(tool, wc)
        if not wc then return false end
        if wc.isReloading and wc.isReloading.Value then return false end
        local ammo = wc.currentAmmo and wc.currentAmmo.Value
        if ammo ~= nil and ammo <= 0 then
            if hasAmmo(wc) and tick() - gun.lastReloadAt >= 2 then gun.lastReloadAt = tick(); triggerReload(tool) end
            return false
        end
        if not hasAmmo(wc) then return false end
        return true
    end
    local function getFireDelay(wc)
        if not wc then return 0.15 end
        local fd = wc.fireDelay and wc.fireDelay.Value or 0.15
        local afd = wc.autoFireDelay and wc.autoFireDelay.Value
        return math.max(0.05, afd and math.max(afd, fd) or fd)
    end
    local function getNextFireTime(wc)
        if not wc then return 0 end
        local lft = wc.lastFireTime and wc.lastFireTime.Value or 0
        return lft + getFireDelay(wc)
    end
    local function findReadyGun(c)
        local function try(tool)
            if not (tool:IsA("Tool") and gun.allowed[gunKey(tool.Name)]) then return nil, nil end
            local wc = getWeaponConfig(tool); if not wc then return nil, nil end
            if wc.isReloading and wc.isReloading.Value then return nil, nil end
            return tool, wc
        end
        for _, ch in ipairs(c:GetChildren()) do local t, wc = try(ch); if t then return t, wc end end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then for _, ch in ipairs(bp:GetChildren()) do local t, wc = try(ch); if t then return t, wc end end end
        return nil, nil
    end
    local function gunStep()
        local c = LocalPlayer.Character; local root = getRootPart(c); if not root then return end
        local r = ReplicatedStorage:FindFirstChild("Remotes"); r = r and r:FindFirstChild("Weapon"); r = r and r:FindFirstChild("Shoot")
        if not r then return end
        local tool, wc = findReadyGun(c); if not tool then return end
        local fd = getFireDelay(wc); local now = tick()
        if now - gun.lastShotAt < fd then return end
        local sNow = workspace:GetServerTimeNow()
        if sNow < getNextFireTime(wc) then return end
        if not isGunReady(tool, wc) then return end
        local bp, bh, bd = nil, nil, gun.range
        for m, h in pairs(trackedNPCs) do
            if m.Parent and h.Health > 0 then
                local p = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if p then local d = (p.Position - root.Position).Magnitude; if d <= bd then bp, bh, bd = p, h, d end end
            end
        end
        if bp then
            local hits = {}; for i = 1, GUN_PELLETS do hits[tostring(i)] = bh end
            local o = root.Position + Vector3.new(0, 1.5, 0)
            r:FireServer(workspace:GetServerTimeNow(), tool, CFrame.lookAt(o, bp.Position), hits)
            gun.lastShotAt = tick()
        end
    end
    local function stopGunAura()
        gun.run += 1; gun.enabled = false
        if gun.tracking then gun.tracking = false; stopNPCTracking() end
    end
    local function startGunAura()
        stopGunAura(); gun.enabled = true; gun.tracking = true; gun.lastShotAt = 0; gun.lastReloadAt = 0
        startNPCTracking(); rebuildAllowed()
        local run = gun.run
        task.spawn(function() while gun.run == run do pcall(gunStep); task.wait(gun.scanDelay) end end)
    end
    Tabs.Combat:Space()
    Tabs.Combat:Section({ Title = "Gun Aura", TextSize = 20 })
    Tabs.Combat:Divider()
    Tabs.Combat:Toggle({ Title = "Gun Aura", Flag = "GunAuraToggle", Value = false,
        Callback = function(s) if s then startGunAura() else stopGunAura() end end })
    CreateListFilter({
        Tab = Tabs.Combat, Title = "Gun Filter", Flag = "GunFilterDropdown", Desc = "Empty = every gun",
        Scan = function()
            local f = getGunObjectFolder()
            return f and ScanObjectEntries(f) or {}
        end,
        OnChange = function(set) gun.filter = set; rebuildAllowed() end
    })
    Tabs.Combat:Input({ Title = "Gun Aura Range", Flag = "GunAuraRangeInput", Placeholder = "50", Value = tostring(gun.range),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then gun.range = n end end })
    Tabs.Combat:Input({ Title = "Gun Scan Delay", Flag = "GunScanDelayInput", Desc = "How fast the aura ticks (seconds). Min 0.01.", Placeholder = "0.05", Value = tostring(gun.scanDelay),
        Callback = function(v) local n = tonumber(v); if n and n >= 0.01 then gun.scanDelay = n end end })
    local reload = { run = 0, last = setmetatable({}, { __mode = "k" }) }
    local function reloadStep()
        local c = LocalPlayer.Character
        if not c then return end
        for _, tool in ipairs(c:GetChildren()) do
            if tool:IsA("Tool") then
                local wc = getWeaponConfig(tool)
                if wc then
                    local ammo = wc.currentAmmo and wc.currentAmmo.Value
                    local reloading = wc.isReloading and wc.isReloading.Value
                    if ammo ~= nil and ammo <= 0 and not reloading and hasAmmo(wc) and tick() - (reload.last[tool] or 0) >= 2 then
                        reload.last[tool] = tick()
                        triggerReload(tool)
                    end
                end
            end
        end
    end
    local function stopAutoReload() reload.run += 1 end
    local function startAutoReload()
        stopAutoReload()
        local run = reload.run
        task.spawn(function() while reload.run == run do pcall(reloadStep); task.wait(0.1) end end)
    end
    Tabs.Combat:Space()
    Tabs.Combat:Section({ Title = "Auto Reload", TextSize = 20 })
    Tabs.Combat:Divider()
    Tabs.Combat:Toggle({ Title = "Auto Reload", Flag = "AutoReloadToggle", Desc = "Reloads your equipped gun when its magazine is empty", Value = false,
        Callback = function(s) if s then startAutoReload() else stopAutoReload() end end })
    table.insert(extraCleanups, stopAutoReload)
    table.insert(extraCleanups, stopGunAura)
end

if ButtonLib and ButtonLib.Create then
    ButtonLib.Create:Toggle({
        Text = "Auto Pilot",
        Flag = "AutoPilotToggle",
        Default = false,
        Visible = false,
        Callback = function(s)
            if AutoPilotToggle then AutoPilotToggle:Set(s) end
        end
    }).Position = UDim2.new(0.5, -125, 0.4, 0)
end

if ButtonLib and ButtonLib.Create then
    local vflyButton = ButtonLib.Create:Toggle({
        Text = "VFlight",
        Flag = "VFlight",
        Default = false,
        Visible = false,
        Callback = function(state)
            if VehicleFlyToggle then VehicleFlyToggle:Set(state) end
        end
    })
    vflyButton.Position = UDim2.new(0.5, -125, 0.47, 0)
end

ShowVFlyButtonToggle = Tabs.Player:Toggle({
    Title = "Vehicle Fly Button",
    Flag = "ShowVFlyButton",
    Value = false,
    Callback = function(state)
        if ButtonLib and ButtonLib.VFlight then ButtonLib.VFlight:SetVisible(state) end
    end
})

do
    local HEAL_ITEMS = { "Bandage", "Snake Oil" }
    local ITEM_RULES = {
        ["Bandage"]   = { passTool = false, equip = false },
        ["Snake Oil"] = { passTool = true,  equip = true },
    }
    local heal = { minHealth = 50, uses = 1, delay = 1, run = 0, selected = { ["Bandage"] = true, ["Snake Oil"] = true } }

    local function scanContainer(container, key)
        if not container then return nil end
        for _, ch in ipairs(container:GetChildren()) do
            if ch:IsA("Tool") and normalizeName(ch.Name) == key then return ch end
        end
        return nil
    end
    local function findHealItem()
        for _, itemName in ipairs(HEAL_ITEMS) do
            if heal.selected[itemName] then
                local key = normalizeName(itemName)
                local tool = scanContainer(LocalPlayer.Character, key) or scanContainer(LocalPlayer:FindFirstChildOfClass("Backpack"), key)
                local remote = tool and tool:FindFirstChild("Use")
                if remote and remote:IsA("RemoteEvent") then return tool, remote, itemName end
            end
        end
        return nil
    end
    local function useHealItem()
        local used = 0
        for _ = 1, heal.uses do
            local tool, remote, itemName = findHealItem()
            if not remote then break end
            local rule = ITEM_RULES[itemName]
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local previous
            if rule.equip and humanoid and tool.Parent ~= character then
                previous = character:FindFirstChildWhichIsA("Tool")
                humanoid:EquipTool(tool)
                task.wait(0.15)
            end
            if rule.passTool then remote:FireServer(tool) else remote:FireServer() end
            used += 1
            if previous and previous.Parent and humanoid then
                task.wait(0.1)
                humanoid:EquipTool(previous)
            end
        end
        return used
    end
    local function healStep()
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 or h.Health >= h.MaxHealth then return false end
        if h.Health > heal.minHealth then return false end
        return useHealItem() > 0
    end
    local function stopAutoHeal() heal.run += 1 end
    local function startAutoHeal()
        stopAutoHeal()
        local run = heal.run
        task.spawn(function()
            while heal.run == run do
                local ok, healed = pcall(healStep)
                if ok and healed then task.wait(heal.delay) else task.wait(0.1) end
            end
        end)
    end

    Tabs.Player:Space()
    Tabs.Player:Section({ Title = "Auto Heal", TextSize = 20 })
    Tabs.Player:Divider()
    AutoHealToggle = Tabs.Player:Toggle({ Title = "Auto Heal", Flag = "AutoHealToggle", Desc = "Uses a heal item when your health is at or below Min Health", Value = false,
        Callback = function(s) if s then startAutoHeal() else stopAutoHeal() end end })
    Tabs.Player:Dropdown({ Title = "Heal Items", Flag = "HealItemsDropdown", Desc = "Uses the first one found, in this order: Bandage, Snake Oil", Values = HEAL_ITEMS, Value = { "Bandage", "Snake Oil" }, Multi = true, AllowNone = true,
        Callback = function(v)
            local set = {}
            if type(v) == "table" then for _, n in ipairs(v) do set[n] = true end end
            heal.selected = set
        end })
    Tabs.Player:Input({ Title = "Min Health To Heal", Flag = "HealMinHealthInput", Desc = "Heals when your health is at or below this value", Placeholder = "50", Value = tostring(heal.minHealth),
        Callback = function(v) local n = tonumber(v); if n and n >= 0 then heal.minHealth = n end end })
    Tabs.Player:Input({ Title = "Uses Per Heal", Flag = "HealUsesInput", Desc = "How many times the Use remote is fired per heal", Placeholder = "1", Value = tostring(heal.uses),
        Callback = function(v) local n = tonumber(v); if n then heal.uses = math.max(math.floor(n), 1) end end })
    Tabs.Player:Input({ Title = "Heal Delay", Flag = "HealDelayInput", Desc = "Seconds to wait after each auto heal (min 0.1)", Placeholder = "1", Value = tostring(heal.delay),
        Callback = function(v) local n = tonumber(v); if n then heal.delay = math.max(n, 0.1) end end })
    Tabs.Player:Button({ Title = "Manual Heal", Desc = "Uses the selected items now, ignoring the health check", Icon = "heart",
        Callback = function()
            if useHealItem() == 0 then WindUI:Notify({ Title = "Heal", Content = "No Bandage / Snake Oil with a Use remote found", Duration = 3 }) end
        end })
    table.insert(extraCleanups, stopAutoHeal)
end

do
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local originals = setmetatable({}, { __mode = "k" })
    local connections = {}
    local enabled = false
    local function apply(prompt)
        if not enabled or not prompt:IsA("ProximityPrompt") then return end
        if originals[prompt] == nil then originals[prompt] = prompt.HoldDuration end
        if prompt.HoldDuration ~= 0 then prompt.HoldDuration = 0 end
    end
    local function stopInstantPrompt()
        enabled = false
        for _, c in ipairs(connections) do c:Disconnect() end
        table.clear(connections)
        for prompt, hold in pairs(originals) do
            if prompt.Parent then prompt.HoldDuration = hold end
        end
        table.clear(originals)
    end
    local function startInstantPrompt()
        stopInstantPrompt(); enabled = true
        for _, o in ipairs(workspace:GetDescendants()) do apply(o) end
        table.insert(connections, workspace.DescendantAdded:Connect(apply))
        table.insert(connections, ProximityPromptService.PromptShown:Connect(apply))
    end
    Tabs.Main:Space()
    Tabs.Main:Section({ Title = "Interaction", TextSize = 20 })
    Tabs.Main:Divider()
    Tabs.Main:Toggle({ Title = "Instant Proximity Prompt", Flag = "InstantPromptToggle", Desc = "Removes the hold time on proximity prompts", Value = false,
        Callback = function(s) if s then startInstantPrompt() else stopInstantPrompt() end end })
    table.insert(extraCleanups, stopInstantPrompt)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == autopilot.keybind and AutoPilotToggle then
        AutoPilotToggle:Set(not autopilot.enabled)
    end
end)

Window:OnDestroy(function()
    for _, fn in ipairs(extraCleanups) do pcall(fn) end
    if farmCleanup then farmCleanup() end
    if cameraCleanup then cameraCleanup() end
    stopESP(); stopLoopNoFog(); stopLoopFullBright(); stopCameraStretch()
    stopVFly(); setNoclip(false); stopDoubleJump(); stopAntiAfk()
    stopAutoSwing(); stopOpSwing()
    stopAutopilot()
    if ButtonLib then ButtonLib:DestroyScreengui() end
end)

Tabs.Settings:Section({ Title = "Config Manager", TextSize = 20 })
Tabs.Settings:Divider()
local ConfigManager = Window.ConfigManager
local CurrentConfigName = "default"
local AutoLoadConfig = "default"
local AutoLoadEnabled = false
local AutoSaveEnabled = false
local ConfigListDropdown = nil
local AUTOLOAD_FILE = "CATHUB/AutoLoad/Game/DeadRail/AutoLoad.json"

function FileExists(p) if isfile then return pcall(readfile, p) end return false end
function WriteFile(p, c) if writefile then return pcall(writefile, p, c) end return false end
function ReadFile(p)
    if readfile then local ok, c = pcall(readfile, p); if ok then return c end end
    return ""
end
function loadAutoLoadSettings()
    if FileExists(AUTOLOAD_FILE) then
        local c = ReadFile(AUTOLOAD_FILE)
        if c ~= "" then
            local ok, d = pcall(function() return HttpService:JSONDecode(c) end)
            if ok and d then AutoLoadConfig = d.configName or "default"; AutoLoadEnabled = d.enabled or false; return true end
        end
    end
    AutoLoadConfig = "default"; AutoLoadEnabled = false; return false
end
function saveAutoLoadSettings()
    if not WriteFile(AUTOLOAD_FILE, "") and makefolder then
        pcall(function() makefolder("CATHUB") end)
        pcall(function() makefolder("CATHUB/AutoLoad") end)
        pcall(function() makefolder("CATHUB/AutoLoad/Game") end)
        pcall(function() makefolder("CATHUB/AutoLoad/Game/DeadRail") end)
    end
    local ok, j = pcall(function() return HttpService:JSONEncode({ enabled = AutoLoadEnabled, configName = AutoLoadConfig }) end)
    if ok then WriteFile(AUTOLOAD_FILE, j) end
end
loadAutoLoadSettings()

ConfigNameInput = Tabs.Settings:Input({ Title = "Config Name", Flag = "ConfigNameInput", Desc = "Name for your config file", Icon = "file-cog", Placeholder = "default", Value = CurrentConfigName,
    Callback = function(v) if v ~= "" then CurrentConfigName = v end end })
Tabs.Settings:Space()
AutoLoadToggle = Tabs.Settings:Toggle({ Title = "Auto Load", Flag = "AutoLoadToggle", Desc = "Automatically load this config when script starts", Value = AutoLoadEnabled,
    Callback = function(s)
        AutoLoadEnabled = s
        if s then AutoLoadConfig = CurrentConfigName; WindUI:Notify({ Title = "Auto-Load", Content = "Config '" .. CurrentConfigName .. "' will load automatically on startup", Duration = 3 }) end
        saveAutoLoadSettings()
    end })
AutoSaveToggle = Tabs.Settings:Toggle({ Title = "Auto Save", Flag = "AutoSaveToggle", Desc = "Automatically save changes to config every second", Value = AutoSaveEnabled,
    Callback = function(s)
        AutoSaveEnabled = s
        if s then
            WindUI:Notify({ Title = "Auto-Save", Content = "Config will save automatically every second", Duration = 2 })
            task.spawn(function()
                while AutoSaveEnabled do
                    if CurrentConfigName ~= "" then pcall(function() Window.CurrentConfig = ConfigManager:Config(CurrentConfigName); Window.CurrentConfig:Save() end) end
                    task.wait(1)
                end
            end)
        else
            WindUI:Notify({ Title = "Auto-Save", Content = "Auto-save disabled", Duration = 2 })
        end
    end })
Tabs.Settings:Space()

function refreshConfigList()
    local all = ConfigManager:AllConfigs() or {}
    if not table.find(all, "default") then
        local d = ConfigManager:Config("default")
        if d and d.Save then d:Save() end
        table.insert(all, 1, "default")
    end
    table.sort(all, function(a, b) return a:lower() < b:lower() end)
    local dv = table.find(all, CurrentConfigName) and CurrentConfigName or "default"
    if ConfigListDropdown and ConfigListDropdown.Refresh then ConfigListDropdown:Refresh(all, dv) end
end
ConfigListDropdown = Tabs.Settings:Dropdown({ Title = "Existing Configs", Flag = "ConfigListDropdown", Desc = "Select from saved configs", Values = { "default" }, Value = "default",
    Callback = function(v)
        CurrentConfigName = v
        ConfigNameInput:Set(v)
        if AutoLoadEnabled then AutoLoadConfig = v; saveAutoLoadSettings() end
        if ConfigManager:GetConfig(v) then WindUI:Notify({ Title = "Config Selected", Content = "Config '" .. v .. "' selected", Duration = 2 }) end
    end })
Tabs.Settings:Space()
SaveConfigButton = Tabs.Settings:Button({ Title = "Save Config", Desc = "Save current settings to config", Icon = "save",
    Callback = function()
        if CurrentConfigName == "" then WindUI:Notify({ Title = "Error", Content = "Please enter a config name", Duration = 3 }); return end
        Window.CurrentConfig = ConfigManager:Config(CurrentConfigName)
        if Window.CurrentConfig:Save() then
            WindUI:Notify({ Title = "Config Saved", Content = "Config '" .. CurrentConfigName .. "' saved successfully", Duration = 3 })
            if AutoLoadEnabled then AutoLoadConfig = CurrentConfigName; saveAutoLoadSettings() end
            task.wait(0.5); refreshConfigList()
        else WindUI:Notify({ Title = "Error", Content = "Failed to save config", Duration = 3 }) end
    end })
Tabs.Settings:Space()
LoadConfigButton = Tabs.Settings:Button({ Title = "Load Config", Desc = "Load settings from selected config", Icon = "folder-open",
    Callback = function()
        if CurrentConfigName == "" then WindUI:Notify({ Title = "Error", Content = "Please enter a config name", Duration = 3 }); return end
        Window.CurrentConfig = ConfigManager:CreateConfig(CurrentConfigName)
        if Window.CurrentConfig:Load() then
            WindUI:Notify({ Title = "Config Loaded", Content = "Config '" .. CurrentConfigName .. "' loaded successfully", Duration = 3 })
            if AutoLoadEnabled then AutoLoadConfig = CurrentConfigName; saveAutoLoadSettings() end
        else WindUI:Notify({ Title = "Error", Content = "Config '" .. CurrentConfigName .. "' not found or empty", Duration = 3 }) end
    end })
Tabs.Settings:Space()
DeleteConfigButton = Tabs.Settings:Button({ Title = "Delete Config", Desc = "Delete selected config", Icon = "trash-2", Color = Color3.fromHex("#ff4830"),
    Callback = function()
        if CurrentConfigName == "default" then WindUI:Notify({ Title = "Error", Content = "Cannot delete default config", Duration = 3 }); return end
        if ConfigManager:DeleteConfig(CurrentConfigName) then
            WindUI:Notify({ Title = "Config Deleted", Content = "Config '" .. CurrentConfigName .. "' deleted", Duration = 3 })
            CurrentConfigName = "default"; ConfigNameInput:Set("default")
            if AutoLoadEnabled then AutoLoadConfig = "default"; saveAutoLoadSettings() end
            task.wait(0.5); refreshConfigList()
        else WindUI:Notify({ Title = "Error", Content = "Failed to delete config or config doesn't exist", Duration = 3 }) end
    end })
Tabs.Settings:Space()
RefreshConfigButton = Tabs.Settings:Button({ Title = "Refresh Config List", Desc = "Update the list of available configs", Icon = "refresh-cw",
    Callback = function() refreshConfigList(); WindUI:Notify({ Title = "Config List Refreshed", Content = "Config list updated", Duration = 2 }) end })
task.spawn(function()
    task.wait(0.5); refreshConfigList(); ConfigNameInput:Set("default")
    if AutoLoadEnabled then
        CurrentConfigName = AutoLoadConfig; ConfigNameInput:Set(CurrentConfigName); task.wait(1)
        Window.CurrentConfig = ConfigManager:Config(CurrentConfigName)
        if Window.CurrentConfig:Load() then WindUI:Notify({ Title = "Auto-Loaded", Content = "Config '" .. CurrentConfigName .. "' loaded automatically", Duration = 3 }) end
    end
end)

Tabs.Settings:Section({ Title = "Personalize", TextSize = 20 })
Tabs.Settings:Divider()
themes = {}
for tn in pairs(WindUI:GetThemes()) do table.insert(themes, tn) end
table.sort(themes)
ThemeDropdown = Tabs.Settings:Dropdown({ Title = "Select Theme", Flag = "ThemeDropdown", Values = themes, SearchBarEnabled = true, MenuWidth = 280, Value = themes[1],
    Callback = function(t) WindUI:SetTheme(t) end })
TransparencySlider = Tabs.Settings:Slider({ Title = "Window Transparency", Step = 0.01, Flag = "TransparencySlider", Value = { Min = 0, Max = 1, Default = WindUI.TransparencyValue },
    Callback = function(v) WindUI.TransparencyValue = tonumber(v); Window:ToggleTransparency(tonumber(v) > 0) end })

if cameraSensitivityUI then cameraSensitivityUI() end