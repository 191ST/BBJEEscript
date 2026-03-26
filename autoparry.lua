-- Blade Ball Utility Script by Request
-- Gunakan dengan risiko sendiri. Akun bisa kena ban.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variabel utama
local autoParry = false
local espEnabled = false
local speedEnabled = false
local originalSpeed = 16
local speedValue = 32
local ball = nil
local highlight = Instance.new("Highlight")
local guiEnabled = true

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBallUtility"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Blade Ball Utility"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    guiEnabled = false
end)

-- Function to create toggle buttons
local function createToggle(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 35)
    btn.Position = UDim2.new(0.5, -120, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.Parent = parent
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(45, 45, 55)
        callback(state)
    end)
    return btn
end

-- Function to create slider
local function createSlider(parent, yPos, text, minVal, maxVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 45)
    frame.Position = UDim2.new(0.5, -120, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": 0"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 15)
    slider.Position = UDim2.new(0, 0, 0, 22)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local value = minVal
    local function updateSlider(val)
        value = math.clamp(val, minVal, maxVal)
        local percent = (value - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. math.floor(value)
        callback(value)
    end
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + (maxVal - minVal) * percent)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + (maxVal - minVal) * percent)
        end
    end)
    
    updateSlider(minVal)
    return frame
end

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 240, 0, 25)
statusLabel.Position = UDim2.new(0.5, -120, 0, 270)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.Parent = mainFrame

-- Create buttons
local autoParryBtn = createToggle(mainFrame, 45, "Auto Parry", function(state)
    autoParry = state
    statusLabel.Text = state and "Status: Auto Parry ON" or "Status: Ready"
end)

local espBtn = createToggle(mainFrame, 90, "ESP Ball", function(state)
    espEnabled = state
    if not state and highlight then
        highlight.Parent = nil
    end
end)

local speedBtn = createToggle(mainFrame, 135, "Speed Boost", function(state)
    speedEnabled = state
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = state and speedValue or originalSpeed
    end
end)

-- Speed slider
local speedSlider = createSlider(mainFrame, 190, "Speed Value", 20, 80, function(val)
    speedValue = val
    if speedEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
end)

-- Anti AFK
local antiAFKEnabled = false
local antiAFKBtn = createToggle(mainFrame, 245, "Anti AFK", function(state)
    antiAFKEnabled = state
end)

-- Function to find ball
local function findBall()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:lower():find("ball") or obj.Name:lower():find("blade") or obj:IsA("Part") and obj.Name:find("Ball") then
            return obj
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name:lower():find("ball") or obj.Name:lower():find("blade")) then
            return obj
        end
    end
    return nil
end

-- Update ball reference
local function updateBall()
    ball = findBall()
    if espEnabled and ball then
        highlight.Parent = ball
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    elseif espEnabled and not ball then
        highlight.Parent = nil
    end
end

-- Auto parry logic
local lastParry = 0
RunService.RenderStepped:Connect(function()
    updateBall()
    
    if autoParry and ball and ball:IsA("BasePart") then
        -- Check if ball is moving towards player
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local direction = (root.Position - ball.Position).Unit
            local velocity = ball:FindFirstChild("Velocity") or ball:FindFirstChild("AssemblyLinearVelocity")
            local velMag = 0
            if velocity then
                velMag = typeof(velocity) == "Vector3" and velocity.Magnitude or (velocity.Value and velocity.Value.Magnitude) or 0
            end
            
            -- If ball is close and moving fast
            local distance = (ball.Position - root.Position).Magnitude
            if distance < 25 and velMag > 30 and tick() - lastParry > 0.3 then
                lastParry = tick()
                VirtualInput:SendKeyEvent(true, "F", false, game)
                task.wait(0.05)
                VirtualInput:SendKeyEvent(false, "F", false, game)
            end
        end
    end
    
    -- Anti AFK
    if antiAFKEnabled then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Handle character respawn
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if speedEnabled and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedValue
    end
    originalSpeed = 16
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not guiEnabled then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- Manual parry
        VirtualInput:SendKeyEvent(true, "F", false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, "F", false, game)
    elseif input.KeyCode == Enum.KeyCode.R then
        -- Toggle ESP
        espEnabled = not espEnabled
        espBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.T then
        -- Teleport to ball (if exists)
        if ball and ball:IsA("BasePart") and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
            end
        end
    end
end)

-- Status message
print("Blade Ball Utility Loaded | Keybinds: F=Parry | R=Toggle ESP | T=Teleport to Ball")
