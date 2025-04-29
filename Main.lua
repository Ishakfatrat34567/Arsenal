repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GLOBAL SETTINGS
getgenv().AimbotEnabled = false
getgenv().AimbotFOV = 100
getgenv().AimbotSmoothness = 5
getgenv().AimbotTeamCheck = true
getgenv().ESPEnabled = false
getgenv().ESPColor = Color3.fromRGB(255, 0, 0)
getgenv().InfiniteJumpEnabled = false
getgenv().FlyEnabled = false
getgenv().NoSpreadEnabled = false
getgenv().NoRecoilEnabled = false

-- CLEANUP
pcall(function() game.CoreGui:FindFirstChild("GODHUB_UI"):Destroy() end)

-- GUI CREATION
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "GODHUB_UI"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 550, 0, 400)
Main.Position = UDim2.new(0.5, -275, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "IshkebHub"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 1

local TabButtons = {}
local Tabs = {}
local TabHolder = Instance.new("Frame", Main)
TabHolder.Size = UDim2.new(1, 0, 0, 40)
TabHolder.Position = UDim2.new(0, 0, 0, 40)
TabHolder.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, 0, 1, -80)
Pages.Position = UDim2.new(0, 0, 0, 80)
Pages.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", TabHolder)
Layout.FillDirection = Enum.FillDirection.Horizontal
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local function CreateTab(name)
    local Button = Instance.new("TextButton", TabHolder)
    Button.Size = UDim2.new(0, 130, 1, 0)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 18
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)

    local Frame = Instance.new("Frame", Pages)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Visible = false
    Tabs[name] = Frame

    Button.MouseButton1Click:Connect(function()
        for _, tab in pairs(Pages:GetChildren()) do
            tab.Visible = false
        end
        Frame.Visible = true
    end)
end

CreateTab("Aimbot")
CreateTab("ESP")
CreateTab("Player")
CreateTab("Gun Mods")
Tabs["Aimbot"].Visible = true

-- GUI COMPONENTS
local function CreateToggle(tab, name, default, callback)
    local Holder = Instance.new("Frame", tab)
    Holder.Size = UDim2.new(0, 500, 0, 40)
    Holder.Position = UDim2.new(0, 20, 0, #tab:GetChildren() * 45)
    Holder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = name
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 18
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Button = Instance.new("TextButton", Holder)
    Button.Size = UDim2.new(0.3, 0, 1, 0)
    Button.Position = UDim2.new(0.7, 0, 0, 0)
    Button.Text = default and "ON" or "OFF"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 18
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Button.TextColor3 = Color3.new(1,1,1)

    local state = default
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

local function CreateDynamicSlider(tab, name, min, max, default, callback)
    local Frame = Instance.new("Frame", tab)
    Frame.Size = UDim2.new(0, 500, 0, 60)
    Frame.Position = UDim2.new(0, 20, 0, #tab:GetChildren() * 65)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name .. ": " .. tostring(default)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 18
    Title.TextColor3 = Color3.new(1,1,1)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Bar = Instance.new("Frame", Frame)
    Bar.Size = UDim2.new(1, 0, 0.5, 0)
    Bar.Position = UDim2.new(0, 0, 0.5, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    local Fill = Instance.new("Frame", Bar)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * rel) + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Title.Text = name .. ": " .. tostring(val)
        callback(val)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)

    Bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end

-- (STOP HERE TEMPORARILY)

-- == FOV Circle ==
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = true

-- == Closest Target Logic ==
local function getClosestTarget()
    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not getgenv().AimbotTeamCheck or player.Team ~= LocalPlayer.Team then
                local pos, visible = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < getgenv().AimbotFOV and dist < shortest then
                        closest = player.Character.Head
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

-- == Aimbot Logic ==
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = getgenv().AimbotFOV
    FOVCircle.Color = getgenv().ESPColor
    FOVCircle.Transparency = 0.3

    if getgenv().AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 / getgenv().AimbotSmoothness)
        end
    end
end)

-- == ESP Logic ==
local espObjects = {}
local function createESP(player)
    local box = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line")
    }

    for _, obj in pairs(box) do
        obj.Thickness = 2
        obj.Visible = false
    end

    RunService.RenderStepped:Connect(function()
        if getgenv().ESPEnabled and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character.Head
            local root = player.Character.HumanoidRootPart
            local foot = player.Character:FindFirstChild("LeftFoot") or root

            local top, visTop = Camera:WorldToViewportPoint(head.Position)
            local bottom, visBot = Camera:WorldToViewportPoint(foot.Position)

            if visTop and visBot then
                local height = math.abs(bottom.Y - top.Y)
                local width = height / 2

                box.Box.Position = Vector2.new(top.X - width/2, top.Y)
                box.Box.Size = Vector2.new(width, height)
                box.Box.Color = getgenv().ESPColor
                box.Box.Visible = true

                box.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                box.Tracer.To = Vector2.new(bottom.X, bottom.Y)
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

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        createESP(p)
    end)
end)

-- == Infinite Jump ==
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- == Fly Hack ==
local flying
RunService.RenderStepped:Connect(function()
    if getgenv().FlyEnabled and not flying then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            flying = Instance.new("BodyVelocity", hrp)
            flying.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        end
    elseif not getgenv().FlyEnabled and flying then
        flying:Destroy()
        flying = nil
    end

    if flying then
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        flying.Velocity = move.Unit * 100
    end
end)

-- == Weapon Mods (Remote Fire) ==
local modRemote = ReplicatedStorage:FindFirstChild("WeaponModEvent")
RunService.RenderStepped:Connect(function()
    if modRemote then
        if getgenv().NoSpreadEnabled then
            modRemote:FireServer("NoSpread", true)
        end
        if getgenv().NoRecoilEnabled then
            modRemote:FireServer("NoRecoil", true)
        end
    end
end)

-- == Hook into UI Buttons/Sliders ==
CreateToggle(Tabs["Aimbot"], "Enable Aimbot", false, function(v) getgenv().AimbotEnabled = v end)
CreateToggle(Tabs["Aimbot"], "Team Check", true, function(v) getgenv().AimbotTeamCheck = v end)
CreateDynamicSlider(Tabs["Aimbot"], "Aimbot FOV", 40, 300, getgenv().AimbotFOV, function(v) getgenv().AimbotFOV = v end)
CreateDynamicSlider(Tabs["Aimbot"], "Smoothness", 1, 20, getgenv().AimbotSmoothness, function(v) getgenv().AimbotSmoothness = v end)

CreateToggle(Tabs["ESP"], "Enable ESP", false, function(v) getgenv().ESPEnabled = v end)

CreateToggle(Tabs["Player"], "Infinite Jump", false, function(v) getgenv().InfiniteJumpEnabled = v end)
CreateToggle(Tabs["Player"], "Fly Hack", false, function(v) getgenv().FlyEnabled = v end)

CreateToggle(Tabs["Gun Mods"], "No Spread", false, function(v) getgenv().NoSpreadEnabled = v end)
CreateToggle(Tabs["Gun Mods"], "No Recoil", false, function(v) getgenv().NoRecoilEnabled = v end)
-- == PATCH: Resize Main UI + Control Dragging on Sliders ==

-- Make menu slightly longer
Main.Size = UDim2.new(0, 550, 0, 470) -- Increased height from 400 to 470

-- Improved CreateDynamicSlider that locks dragging
local function CreateDynamicSlider(tab, name, min, max, default, callback)
    local frame = Instance.new("Frame", tab)
    frame.Size = UDim2.new(1, -40, 0, 60)
    frame.Position = UDim2.new(0, 20, 0, #tab:GetChildren() * 65)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name .. ": " .. tostring(default)

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0.5, 0)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)

    local draggingSlider = false

    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max - min) * rel) + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = name .. ": " .. tostring(val)
        if callback then callback(val) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            Main.Draggable = false -- Lock menu dragging while sliding
            update(input)
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
            Main.Draggable = true -- Unlock menu dragging after sliding
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
end
