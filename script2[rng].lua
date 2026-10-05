-- SpawnedSans 控制脚本（玩家环绕 + 可调速度距离）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- ===================== 配置 =====================
local orbitEnabled = false
local orbitSpeed = 2          -- 环绕速度（越大越快）
local orbitDistance = 10      -- 与 Sans 的距离
local orbitAngle = 0

local teleportBehindEnabled = false
local BEHIND_DISTANCE = 5
local UPDATE_RATE = 0.03

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpawnedSansUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 260)
mainFrame.Position = UDim2.new(0.5, -130, 0.65, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SpawnedSans 环绕控制"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -60, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- 环绕开关
local orbitBtn = Instance.new("TextButton")
orbitBtn.Size = UDim2.new(0.9, 0, 0, 36)
orbitBtn.Position = UDim2.new(0.05, 0, 0, 42)
orbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
orbitBtn.Text = "环绕 Sans：关闭"
orbitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitBtn.TextSize = 14
orbitBtn.Font = Enum.Font.GothamBold
orbitBtn.Parent = mainFrame
Instance.new("UICorner", orbitBtn).CornerRadius = UDim.new(0, 8)

-- 速度
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0, 88)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "环绕速度："
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.4, 0, 0, 26)
speedBox.Position = UDim2.new(0.45, 0, 0, 85)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = "2"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
speedBox.Font = Enum.Font.GothamBold
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

-- 距离
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(0.4, 0, 0, 20)
distLabel.Position = UDim2.new(0.05, 0, 0, 122)
distLabel.BackgroundTransparency = 1
distLabel.Text = "环绕距离："
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 12
distLabel.Font = Enum.Font.Gotham
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = mainFrame

local distBox = Instance.new("TextBox")
distBox.Size = UDim2.new(0.4, 0, 0, 26)
distBox.Position = UDim2.new(0.45, 0, 0, 119)
distBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
distBox.Text = "10"
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distBox.TextSize = 13
distBox.Font = Enum.Font.GothamBold
distBox.Parent = mainFrame
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 6)

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.9, 0, 0, 28)
applyBtn.Position = UDim2.new(0.05, 0, 0, 155)
applyBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applyBtn.Text = "应用速度 / 距离"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.TextSize = 13
applyBtn.Font = Enum.Font.Gotham
applyBtn.Parent = mainFrame
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

-- 传送到身后（保留）
local behindBtn = Instance.new("TextButton")
behindBtn.Size = UDim2.new(0.9, 0, 0, 32)
behindBtn.Position = UDim2.new(0.05, 0, 0, 192)
behindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
behindBtn.Text = "传送到 Sans 身后：关闭"
behindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
behindBtn.TextSize = 13
behindBtn.Font = Enum.Font.GothamBold
behindBtn.Parent = mainFrame
Instance.new("UICorner", behindBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 230)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "准备就绪"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- ===================== 逻辑 =====================
local isMinimized = false
local originalSize = mainFrame.Size

local function getSansFolder()
    return Workspace:FindFirstChild("SpawnedSans")
end

local function getFirstSans()
    local folder = getSansFolder()
    if not folder then return nil end
    return folder:GetChildren()[1]
end

local function getSansPosition(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        return inst:GetPivot().Position
    elseif inst:IsA("BasePart") then
        return inst.Position
    else
        local part = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
        return part and part.Position
    end
end

-- 环绕逻辑
local function doOrbit(dt)
    if not hrp then return end
    local sans = getFirstSans()
    local sansPos = getSansPosition(sans)
    if not sansPos then return end

    orbitAngle = orbitAngle + (orbitSpeed * dt)

    local offset = Vector3.new(
        math.cos(orbitAngle) * orbitDistance,
        0,
        math.sin(orbitAngle) * orbitDistance
    )

    local targetPos = sansPos + offset
    hrp.CFrame = CFrame.new(targetPos, sansPos)  -- 面向 Sans
end

-- 传送到身后
local function teleportBehind()
    if not hrp then return end
    local sans = getFirstSans()
    local sansPos = getSansPosition(sans)
    if not sansPos then return end

    local dir = (hrp.Position - sansPos)
    if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, 1) end
    dir = dir.Unit

    local targetPos = sansPos + dir * BEHIND_DISTANCE
    hrp.CFrame = CFrame.new(targetPos, sansPos)
end

-- 主循环
task.spawn(function()
    local last = tick()
    while true do
        local now = tick()
        local dt = now - last
        last = now

        if orbitEnabled then
            pcall(doOrbit, dt)
        end
        if teleportBehindEnabled then
            pcall(teleportBehind)
        end
        task.wait(UPDATE_RATE)
    end
end)

-- 按钮事件
orbitBtn.MouseButton1Click:Connect(function()
    orbitEnabled = not orbitEnabled
    if orbitEnabled then
        orbitBtn.Text = "环绕 Sans：开启"
        orbitBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "正在环绕中..."
    else
        orbitBtn.Text = "环绕 Sans：关闭"
        orbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        statusLabel.Text = "环绕已停止"
    end
end)

behindBtn.MouseButton1Click:Connect(function()
    teleportBehindEnabled = not teleportBehindEnabled
    if teleportBehindEnabled then
        behindBtn.Text = "传送到 Sans 身后：开启"
        behindBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    else
        behindBtn.Text = "传送到 Sans 身后：关闭"
        behindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

applyBtn.MouseButton1Click:Connect(function()
    local s = tonumber(speedBox.Text)
    local d = tonumber(distBox.Text)
    if s and s > 0 then
        orbitSpeed = s
    end
    if d and d > 0 then
        orbitDistance = d
    end
    statusLabel.Text = string.format("速度: %.1f | 距离: %.1f", orbitSpeed, orbitDistance)
end)

-- 最小化
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 260, 0, 32)
        for _, c in pairs(mainFrame:GetChildren()) do
            if c ~= titleBar and c:IsA("GuiObject") then
                c.Visible = false
            end
        end
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = originalSize
        for _, c in pairs(mainFrame:GetChildren()) do
            if c:IsA("GuiObject") then
                c.Visible = true
            end
        end
        minimizeBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    orbitEnabled = false
    teleportBehindEnabled = false
    screenGui.Enabled = false
end)

-- 拖动
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function()
    dragging = false
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("SpawnedSans 环绕脚本已加载")