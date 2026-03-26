-- Blade Ball Advanced Hub
-- Modern GUI dengan Auto Parry yang lebih akurat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== VARIABLES ====================
local autoParry = false
local espEnabled = false
local speedEnabled = false
local airJumpEnabled = false
local antiAFKEnabled = false
local aimbotEnabled = false
local originalSpeed = 16
local speedValue = 45
local ball = nil
local ballVelocity = nil
local lastParryTime = 0
local parryCooldown = 0.25
local guiOpen = true

-- ==================== MODERN GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBallHub"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background Blur
local blur = Instance.new("BlurEffect")
blur.Size = 8
blur.Parent = game:GetService("Lighting")

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 520)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Corner Radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Shadow
local shadow = Instance.new("UIGradient")
shadow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
shadow.Rotation = 90
shadow.Parent = mainFrame

-- Glow Effect
local glow = Instance.new("UIGradient")
glow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 50, 150)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 100, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 50, 150))
})
glow.Transparency = NumberSequence.new(0.8)
glow.Parent = mainFrame

-- Header with gradient
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 80, 140))
})
headerGradient.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚔️ BLADE BALL HUB ⚔️"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local version = Instance.new("TextLabel")
version.Size = UDim2.new(0, 80, 0, 20)
version.Position = UDim2.new(1, -90, 1, -25)
version.BackgroundTransparency = 1
version.Text = "v2.0.0"
version.TextColor3 = Color3.fromRGB(150, 150, 150)
version.TextSize = 12
version.Font = Enum.Font.Gotham
version.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiOpen = false
    screenGui:Enabled = false
    blur.Enabled = false
end)

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(1, -90, 0, 12)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local minimized = false
local originalSize = mainFrame.Size

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 380, 0, 60) or originalSize
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
    tween:Play()
end)

-- Content Container (Scrollable)
local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, 0, 1, -70)
scrollContainer.Position = UDim2.new(0, 0, 0, 70)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollContainer.ScrollBarThickness = 4
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
scrollContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollContainer

-- ==================== FUNCTION TO CREATE MODERN BUTTONS ====================
local function createCard(parent, titleText, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -24, 0, 80)
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    card.BackgroundTransparency = 0.3
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = parent
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card
    
    return card
end

local function createModernToggle(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 42)
    btn.Position = UDim2.new(1, -160, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 21)
    btnCorner.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(1, -32, 0, 11)
    indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 90)
        local tween = TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor})
        tween:Play()
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
    
    return btn, indicator
end

local function createSliderModern(parent, yPos, text, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 28)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = defaultVal
    local function updateSlider(val)
        value = math.clamp(val, minVal, maxVal)
        local percent = (value - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. math.floor(value)
        callback(value)
    end
    
    local dragging = false
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + (maxVal - minVal) * percent)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            updateSlider(minVal + (maxVal - minVal) * percent)
        end
    end)
    
    updateSlider(defaultVal)
    return frame
end

-- ==================== CREATE UI CARDS ====================
-- Combat Card
local combatCard = createCard(scrollContainer, "⚔️ COMBAT", 1)
local apBtn, apIndicator = createModernToggle(combatCard, 15, "Auto Parry", function(state)
    autoParry = state
end)

-- Movement Card
local moveCard = createCard(scrollContainer, "🏃 MOVEMENT", 2)
local speedBtn, speedIndicator = createModernToggle(moveCard, 15, "Speed Boost", function(state)
    speedEnabled = state
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = state and speedValue or originalSpeed
    end
end)

local speedSlider = createSliderModern(moveCard, 55, "Speed", 20, 100, 45, function(val)
    speedValue = val
    if speedEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end
end)

local jumpBtn, jumpIndicator = createModernToggle(moveCard, 110, "Air Jump", function(state)
    airJumpEnabled = state
end)

-- Visual Card
local visualCard = createCard(scrollContainer, "👁️ VISUALS", 3)
local espBtn, espIndicator = createModernToggle(visualCard, 15, "Ball ESP", function(state)
    espEnabled = state
end)

-- Utility Card
local utilCard = createCard(scrollContainer, "🔧 UTILITY", 4)
local afkBtn, afkIndicator = createModernToggle(utilCard, 15, "Anti AFK", function(state)
    antiAFKEnabled = state
end)

local aimBtn, aimIndicator = createModernToggle(utilCard, 55, "Aimbot", function(state)
    aimbotEnabled = state
end)

-- Status Card
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -24, 0, 60)
statusCard.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusCard.BackgroundTransparency = 0.3
statusCard.BorderSizePixel = 0
statusCard.LayoutOrder = 5
statusCard.Parent = scrollContainer

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 1, -20)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 STATUS: READY"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusCard

-- ==================== AUTO PARRY IMPROVED ====================
-- Better ball detection
local function getBall()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("ball") then
            return obj
        end
        if obj:IsA("BasePart") and obj.Name:lower():find("blade") then
            return obj
        end
        if obj:IsA("BasePart") and obj:FindFirstChild("Handle") and obj.Handle.Name:lower():find("ball") then
            return obj.Handle
        end
    end
    return nil
end

-- Get ball velocity
local function getBallVelocity(ballPart)
    local vel = ballPart:FindFirstChild("Velocity")
    if vel then
        return vel.Value
    end
    local assemblyVel = ballPart:GetAttribute("Velocity")
    if assemblyVel then
        return assemblyVel
    end
    return ballPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
end

-- Predict if ball is coming towards player
local function isBallComingTowardsPlayer(ballPos, ballVel, playerPos)
    local toPlayer = (playerPos - ballPos).Unit
    local velDir = ballVel.Unit
    local dot = toPlayer:Dot(velDir)
    return dot > 0.3 and ballVel.Magnitude > 25
end

-- Auto parry main loop
RunService.RenderStepped:Connect(function()
    ball = getBall()
    
    if autoParry and ball and ball:IsA("BasePart") then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local distance = (ball.Position - root.Position).Magnitude
            local ballVel = getBallVelocity(ball)
            local isComing = isBallComingTowardsPlayer(ball.Position, ballVel, root.Position)
            
            -- Parry condition: ball is close AND coming towards player AND cooldown passed
            if distance < 20 and isComing and tick() - lastParryTime > parryCooldown then
                lastParryTime = tick()
                VirtualInput:SendKeyEvent(true, "F", false, game)
                task.wait(0.03)
                VirtualInput:SendKeyEvent(false, "F", false, game)
                statusLabel.Text = "🟡 STATUS: PARRY TRIGGERED"
                task.wait(0.2)
                statusLabel.Text = autoParry and "🟢 STATUS: AUTO PARRY ACTIVE" or "🟢 STATUS: READY"
            end
        end
    end
    
    -- Update status label when auto parry on/off
    if autoParry and statusLabel.Text ~= "🟢 STATUS: AUTO PARRY ACTIVE" then
        statusLabel.Text = "🟢 STATUS: AUTO PARRY ACTIVE"
    elseif not autoParry and statusLabel.Text ~= "🟢 STATUS: READY" and not autoParry then
        statusLabel.Text = "🟢 STATUS: READY"
    end
end)

-- ==================== ESP ====================
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(255, 50, 50)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.4
highlight.OutlineTransparency = 0

RunService.RenderStepped:Connect(function()
    if espEnabled then
        ball = getBall()
        if ball then
            highlight.Parent = ball
        else
            highlight.Parent = nil
        end
    else
        highlight.Parent = nil
    end
end)

-- ==================== AIR JUMP ====================
local jumpCount = 0
UserInputService.JumpRequest:Connect(function()
    if airJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            if humanoid.FloorMaterial == Enum.Material.Air then
                if jumpCount < 1 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    jumpCount = jumpCount + 1
                    task.wait(0.5)
                    jumpCount = 0
                end
            else
                jumpCount = 0
            end
        end
    end
end)

-- ==================== AIMBOT (Auto Aim at Ball) ====================
if aimbotEnabled then
    RunService.RenderStepped:Connect(function()
        if aimbotEnabled and ball then
            local cam = workspace.CurrentCamera
            local viewportPoint = cam:WorldToViewportPoint(ball.Position)
            if viewportPoint.Z > 0 then
                mousemoverel(viewportPoint.X - Mouse.X, viewportPoint.Y - Mouse.Y)
            end
        end
    end)
end

-- ==================== ANTI AFK ====================
RunService.RenderStepped:Connect(function()
    if antiAFKEnabled then
        local vu = game:GetService("VirtualUser")
        pcall(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

-- ==================== CHARACTER RESPAWN HANDLER ====================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    if speedEnabled and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedValue
    end
    originalSpeed = 16
end)

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not guiOpen then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        VirtualInput:SendKeyEvent(true, "F", false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, "F", false, game)
    elseif input.KeyCode == Enum.KeyCode.R then
        espEnabled = not espEnabled
        if espBtn then
            local newColor = espEnabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 90)
            local tween = TweenService:Create(espIndicator, TweenInfo.new(0.2), {BackgroundColor3 = newColor})
            tween:Play()
        end
    elseif input.KeyCode == Enum.KeyCode.T then
        ball = getBall()
        if ball and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end
end)

-- ==================== DRAG FUNCTION ====================
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("⚔️ Blade Ball Hub v2.0 Loaded | F=Parry | R=Toggle ESP | T=Teleport")
