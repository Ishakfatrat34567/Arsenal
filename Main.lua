repeat task.wait() until game:IsLoaded()

-- Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Arsenal ULTIMATE GODHUB | Final Lock", "DarkTheme")

-- Tabs
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Settings")

local ESPTab = Window:NewTab("ESP")
local ESPSection = ESPTab:NewSection("ESP Settings")

local PlayerTab = Window:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Player Enhancements")

local GunModsTab = Window:NewTab("Gun Mods")
local GunModsSection = GunModsTab:NewSection("Weapon Enhancements")

-- Globals
getgenv().AimbotEnabled = false
getgenv().AimbotFOV = 100
getgenv().AimbotSmoothness = 5
getgenv().AimbotTeamCheck = true

getgenv().ESPEnabled = false
getgenv().ESPColor = Color3.fromRGB(255, 0, 0)

getgenv().InfiniteJumpEnabled = false
getgenv().FlyEnabled = false
getgenv().FlyKey = Enum.KeyCode.E -- Default Keybind

getgenv().NoSpreadEnabled = false
getgenv().NoRecoilEnabled = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
-- Team Check
local function isEnemy(player)
    if not LocalPlayer.Team or not player.Team then
        return true
    end
    return LocalPlayer.Team ~= player.Team
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Color = getgenv().ESPColor
FOVCircle.Thickness = 2
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = getgenv().AimbotFOV
end)

-- Closest Enemy to Center
local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character and enemy.Character:FindFirstChild("Head") then
            if not getgenv().AimbotTeamCheck or isEnemy(enemy) then
                local pos, visible = Camera:WorldToViewportPoint(enemy.Character.Head.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < getgenv().AimbotFOV and dist < shortest then
                        closest = enemy.Character.Head
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot Move
RunService.RenderStepped:Connect(function()
    if getgenv().AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target then
            local pos, onScreen = Camera:WorldToViewportPoint(target.Position)
            if onScreen then
                local delta = Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                mousemoverel(delta.X / getgenv().AimbotSmoothness, delta.Y / getgenv().AimbotSmoothness)
            end
        end
    end
end)
local espObjects = {}

local function clearESP()
    for _, obj in pairs(espObjects) do
        for _, item in pairs(obj) do
            if item then item:Remove() end
        end
    end
    espObjects = {}
end

local function createESP(player)
    local box = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }

    for _, l in pairs(box) do
        l.Thickness = 2
        l.Color = getgenv().ESPColor
        l.Visible = false
    end

    RunService.RenderStepped:Connect(function()
        if getgenv().ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local root = player.Character.HumanoidRootPart
            local head = player.Character.Head

            local rootPos, rootVisible = Camera:WorldToViewportPoint(root.Position)
            local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)

            if rootVisible and headVisible then
                local height = math.abs(rootPos.Y - headPos.Y)
                local width = height / 2

                box.Box.Position = Vector2.new(rootPos.X - width/2, headPos.Y)
                box.Box.Size = Vector2.new(width, height)
                box.Box.Color = getgenv().ESPColor
                box.Box.Visible = true

                -- Tracer
                local screenRoot = Vector2.new(rootPos.X, rootPos.Y)
                box.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, 0)
                box.Tracer.To = screenRoot
                box.Tracer.Color = getgenv().ESPColor
                box.Tracer.Visible = true
            else
                box.Box.Visible = false
                box.Tracer.Visible = false
            end
        else
            box.Box.Visible = false
            box.Tracer.Visible = false
        end
    end)

    table.insert(espObjects, box)
end

local function refreshESP()
    clearESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            createESP(p)
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        createESP(p)
    end)
end)
-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly Hack
local FlyVelocity = nil
local Flying = false

local function startFly()
    if Flying then return end
    Flying = true

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyVelocity.Parent = hrp

    RunService.RenderStepped:Connect(function()
        if not Flying or not FlyVelocity then return end
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        FlyVelocity.Velocity = move * 100
    end)
end

local function stopFly()
    Flying = false
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end
end

-- Auto Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if getgenv().AutoRespawnEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
            LocalPlayer:LoadCharacter()
        end)
    end
end)
-- Aimbot
AimbotSection:NewToggle("Enable Aimbot", "Lock onto enemies", function(v) getgenv().AimbotEnabled = v end)
AimbotSection:NewToggle("Enable ESP", "Show Boxes/Tracers", function(v) getgenv().ESPEnabled = v end)
AimbotSection:NewToggle("Team Check", "Ignore teammates", function(v) getgenv().AimbotTeamCheck = v end)
AimbotSection:NewSlider("Aimbot FOV", "FOV Lock Radius", 300, 40, function(v) getgenv().AimbotFOV = v end)
AimbotSection:NewSlider("Aimbot Smoothness", "Smoothness", 10, 1, function(v) getgenv().AimbotSmoothness = v end)

-- ESP
ESPSection:NewColorPicker("ESP/Tracer Color", "Pick ESP Color", Color3.fromRGB(255,0,0), function(color)
    getgenv().ESPColor = color
    refreshESP()
end)

-- Player
PlayerSection:NewToggle("Infinite Jump", "Jump forever", function(v) getgenv().InfiniteJumpEnabled = v end)
PlayerSection:NewToggle("Fly Hack", "Toggle Fly", function(v)
    if v then startFly() else stopFly() end
end)

-- Gun Mods
GunModsSection:NewToggle("No Spread", "Perfect bullet accuracy", function(v) getgenv().NoSpreadEnabled = v end)
GunModsSection:NewToggle("No Recoil", "No gun kickback", function(v) getgenv().NoRecoilEnabled = v end)
