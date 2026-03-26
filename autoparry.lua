-- BLADE BALL PARRY FIXED
-- Lightweight, No Lag, 100% Work

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInput = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Konfigurasi
local PARRY_KEY = "F"
local ACTIVE = true
local PARRY_COOLDOWN = 0
local PARRY_DELAY_MS = 0.08

-- ========== FUNGSI PARRY ==========
local function Parry()
    if tick() - PARRY_COOLDOWN < 0.15 then return end
    PARRY_COOLDOWN = tick()
    
    VirtualInput:SendKeyEvent(true, PARRY_KEY, false, game)
    wait(PARRY_DELAY_MS)
    VirtualInput:SendKeyEvent(false, PARRY_KEY, false, game)
end

-- ========== DETEKSI BOLA DARI GAME OBJECT ==========
-- Blade Ball punya object khusus, biasanya di workspace dengan nama tertentu
local function GetGameBall()
    -- Cek semua part di workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Part") then
            local name = obj.Name:lower()
            -- Blade Ball biasanya bola bernama "Ball" atau "BladeBall"
            if name:find("ball") or name:find("blade") or name == "Handle" then
                return obj
            end
        end
        -- Cek juga di dalam model
        if obj:IsA("Model") then
            for _, part in ipairs(obj:GetChildren()) do
                if part:IsA("Part") then
                    local name = part.Name:lower()
                    if name:find("ball") or name:find("blade") then
                        return part
                    end
                end
            end
        end
    end
    return nil
end

-- ========== CEK APAKAH BOLA MENDEKAT ==========
local function IsBallNear()
    local char = LP.Character
    if not char then return false end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local ball = GetGameBall()
    if not ball then return false end
    
    local distance = (ball.Position - root.Position).Magnitude
    
    -- Parry saat jarak dekat (15 stud)
    -- Tanpa velocity check biar ringan
    return distance < 18
end

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    
    if IsBallNear() then
        Parry()
    end
end)

-- ========== MANUAL PARRY ==========
Mouse.KeyDown:Connect(function(key)
    if key:lower() == "f" then
        Parry()
    end
end)

-- ========== GUI MINIMAL ==========
local gui = Instance.new("ScreenGui")
gui.Name = "ParryGUI"
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 70)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "⚡ Blade Parry"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 22)
status.BackgroundTransparency = 1
status.Text = "STATUS: ACTIVE"
status.TextColor3 = Color3.fromRGB(0, 255, 0)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 22)
toggle.Position = UDim2.new(0.5, -25, 0, 45)
toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 10
toggle.Font = Enum.Font.GothamBold
toggle.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = toggle

toggle.MouseButton1Click:Connect(function()
    ACTIVE = not ACTIVE
    if ACTIVE then
        toggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        toggle.Text = "ON"
        status.Text = "STATUS: ACTIVE"
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        toggle.Text = "OFF"
        status.Text = "STATUS: OFF"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Auto ON
toggle.MouseButton1Click:Fire()

print("BLADE PARRY LOADED - Tekan F untuk parry manual | Jarak parry: 18 stud")
