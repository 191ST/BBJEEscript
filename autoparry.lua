-- BLADE BALL PARRY - XENO OPTIMIZED
-- Disesuaikan untuk executor Xeno, minim lag, parry akurat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Konfigurasi (sesuaikan jika perlu)
local PARRY_KEY = "F"  -- ganti ke key yang dipakai game
local ACTIVE = true
local LAST_PARRY = 0
local PARRY_RANGE = 20  -- jarak parry dalam stud

-- ========== FUNGSI PARRY UNTUK XENO ==========
local function DoParry()
    if tick() - LAST_PARRY < 0.18 then return end
    LAST_PARRY = tick()
    
    -- Method 1: VirtualInput (umum)
    pcall(function()
        VirtualInput:SendKeyEvent(true, PARRY_KEY, false, game)
        wait(0.05)
        VirtualInput:SendKeyEvent(false, PARRY_KEY, false, game)
    end)
    
    -- Method 2: Fallback untuk Xeno (keypress simulation)
    pcall(function()
        local ks = game:GetService("KeybindService")
        if ks and ks:FindFirstChild(PARRY_KEY) then
            ks[PARRY_KEY]:Fire()
        end
    end)
end

-- ========== DETEKSI BOLA AKURAT ==========
local function FindBall()
    -- Blade Ball specific: biasanya bola ada di workspace dengan nama tertentu
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            -- Daftar kemungkinan nama bola di Blade Ball
            if name:find("ball") or name:find("blade") or name:find("bullet") or name == "Handle" then
                return v
            end
            -- Cek berdasarkan ukuran (bola biasanya radius 2-5)
            if v.Size.X > 2 and v.Size.X < 8 and v.Size.Y > 2 and v.Size.Y < 8 then
                if v.Size.Z > 2 and v.Size.Z < 8 then
                    return v
                end
            end
        end
    end
    return nil
end

-- ========== CEK JARAK ==========
local function IsBallInRange()
    local char = LP.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local ball = FindBall()
    if not ball then return false end
    
    local distance = (ball.Position - root.Position).Magnitude
    return distance < PARRY_RANGE
end

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function()
    if ACTIVE and IsBallInRange() then
        DoParry()
    end
end)

-- ========== TELEPORT KE BOLA (opsional) ==========
local function TeleportToBall()
    local ball = FindBall()
    local char = LP.Character
    if ball and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = ball.CFrame * CFrame.new(0, 3, 0)
        end
    end
end

-- ========== GUI MINIMAL UNTUK XENO ==========
local gui = Instance.new("ScreenGui")
gui.Name = "BladeParry"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 95)
main.Position = UDim2.new(0, 8, 0, 8)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundTransparency = 1
title.Text = "⚡ BLADE PARRY"
title.TextColor3 = Color3.fromRGB(255, 180, 50)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 26)
status.BackgroundTransparency = 1
status.Text = "● ACTIVE"
status.TextColor3 = Color3.fromRGB(0, 255, 100)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.Parent = main

local rangeText = Instance.new("TextLabel")
rangeText.Size = UDim2.new(1, 0, 0, 18)
rangeText.Position = UDim2.new(0, 0, 0, 46)
rangeText.BackgroundTransparency = 1
rangeText.Text = "Range: " .. PARRY_RANGE .. " stud"
rangeText.TextColor3 = Color3.fromRGB(180, 180, 180)
rangeText.TextSize = 10
rangeText.Font = Enum.Font.Gotham
rangeText.Parent = main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 70, 0, 24)
toggleBtn.Position = UDim2.new(0, 8, 0, 66)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 70)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = main

local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0, 70, 0, 24)
teleBtn.Position = UDim2.new(0, 90, 0, 66)
teleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
teleBtn.Text = "TP BALL"
teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBtn.TextSize = 12
teleBtn.Font = Enum.Font.GothamBold
teleBtn.Parent = main

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local teleCorner = Instance.new("UICorner")
teleCorner.CornerRadius = UDim.new(0, 6)
teleCorner.Parent = teleBtn

toggleBtn.MouseButton1Click:Connect(function()
    ACTIVE = not ACTIVE
    if ACTIVE then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 70)
        toggleBtn.Text = "ON"
        status.Text = "● ACTIVE"
        status.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
        toggleBtn.Text = "OFF"
        status.Text = "○ OFF"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

teleBtn.MouseButton1Click:Connect(function()
    TeleportToBall()
    status.Text = "⚡ TELEPORTED"
    wait(0.5)
    status.Text = ACTIVE and "● ACTIVE" or "○ OFF"
end)

-- ========== KEYBINDS ==========
Mouse.KeyDown:Connect(function(key)
    local k = key:lower()
    if k == "f" then
        DoParry()
    elseif k == "t" then
        TeleportToBall()
    elseif k == "r" then
        ACTIVE = not ACTIVE
        if ACTIVE then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 70)
            toggleBtn.Text = "ON"
            status.Text = "● ACTIVE"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
            toggleBtn.Text = "OFF"
            status.Text = "○ OFF"
        end
    end
end)

-- Auto start
toggleBtn.MouseButton1Click:Fire()

print("[XENO] Blade Parry Loaded")
print("F = Parry manual | R = Toggle Auto | T = Teleport to Ball")
