-- BLADE BALL ULTIMATE PARRY
-- Fokus: Auto Parry 100% Work, GUI Simple

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInput = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Konfigurasi
local ParryKey = "F"
local ParryDelay = 0.12  -- delay dalam detik
local Active = true
local LastParry = 0
local Ball = nil
local BallPart = nil

-- ========== DETEKSI BOLA PALING AKURAT ==========
local function FindBall()
    -- Method 1: Langsung cari di workspace
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Part") and (v.Name:lower():find("ball") or v.Name:lower():find("blade")) then
            return v
        end
        if v:IsA("Model") and v.Name:lower():find("ball") then
            for _, part in pairs(v:GetDescendants()) do
                if part:IsA("Part") then return part end
            end
        end
    end
    
    -- Method 2: Cari berdasarkan ukuran/posisi (bola biasanya bulat)
    local nearest = nil
    local minDist = math.huge
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local rootPos = char.HumanoidRootPart.Position
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") and v.Size.X > 2 and v.Size.X < 10 and v.Size.Y > 2 and v.Size.Y < 10 then
                local dist = (v.Position - rootPos).Magnitude
                if dist < minDist and dist < 100 then
                    minDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- ========== DAPATKAN VELOCITY BOLA ==========
local function GetBallVelocity(ball)
    local vel = ball.AssemblyLinearVelocity
    if vel and vel.Magnitude > 0 then return vel end
    
    vel = ball:FindFirstChild("Velocity")
    if vel and vel.Value and vel.Value.Magnitude > 0 then return vel.Value end
    
    vel = ball:GetAttribute("Velocity")
    if vel and type(vel) == "Vector3" and vel.Magnitude > 0 then return vel end
    
    return Vector3.new(0,0,0)
end

-- ========== PREDIKSI APAKAH BOLA MENUJU PEMAIN ==========
local function IsComingToPlayer(ballPos, ballVel, playerPos)
    local directionToPlayer = (playerPos - ballPos).Unit
    local ballDirection = ballVel.Unit
    local dot = directionToPlayer:Dot(ballDirection)
    
    -- Dot > 0 artinya bola bergerak mendekati pemain
    -- Minimal kecepatan 20 stud/detik agar tidak false positive
    return dot > 0.2 and ballVel.Magnitude > 20
end

-- ========== EKSEKUSI PARRY ==========
local function DoParry()
    if tick() - LastParry < 0.2 then return end  -- cooldown anti spam
    LastParry = tick()
    
    -- Kirim key press
    VirtualInput:SendKeyEvent(true, ParryKey, false, game)
    task.wait(ParryDelay)
    VirtualInput:SendKeyEvent(false, ParryKey, false, game)
    
    -- Optional: efek visual feedback
    print("[PARRY] Executed at " .. tick())
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if not Active then return end
    
    local char = LP.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Update bola setiap frame
    Ball = FindBall()
    if not Ball then return end
    
    local ballPos = Ball.Position
    local playerPos = root.Position
    local distance = (ballPos - playerPos).Magnitude
    
    -- Jika bola terlalu jauh, skip
    if distance > 35 then return end
    
    -- Dapatkan velocity
    local ballVel = GetBallVelocity(Ball)
    
    -- Cek apakah bola bergerak CEPAT dan MENUJU pemain
    local isComing = IsComingToPlayer(ballPos, ballVel, playerPos)
    local isFast = ballVel.Magnitude > 25
    
    -- KONDISI PARRY:
    -- 1. Jarak < 20 stud
    -- 2. Bola bergerak cepat
    -- 3. Bola menuju pemain
    if distance < 22 and isFast and isComing then
        DoParry()
    end
end)

-- ========== SIMPLE GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParryHub"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.4
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTIMATE PARRY"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 25)
StatusText.Position = UDim2.new(0, 0, 0, 28)
StatusText.BackgroundTransparency = 1
StatusText.Text = "STATUS: ACTIVE"
StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusText.TextSize = 12
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleBtn.Position = UDim2.new(0.5, -40, 0, 60)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    if Active then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleBtn.Text = "ON"
        StatusText.Text = "STATUS: ACTIVE"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "OFF"
        StatusText.Text = "STATUS: OFF"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Manual parry via keybind
Mouse.KeyDown:Connect(function(key)
    if key:lower() == "f" then
        DoParry()
    end
end)

-- Auto enable
ToggleBtn.MouseButton1Click:Fire()

-- Debug print
print("[ULTIMATE PARRY] Loaded - Auto parry aktif")
print("Tekan F untuk parry manual | GUI di pojok kiri atas")
