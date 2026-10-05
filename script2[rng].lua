-- SpawnedSans 环绕控制（新增围绕地图中心）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- ===================== 配置 =====================
local orbitSansEnabled = false
local orbitCenterEnabled = false

local orbitSpeed = 2
local orbitDistance = 10
local centerDistance = 30          -- 围绕中心的距离
local orbitAngle = 0
local centerAngle = 0

local centerPosition = nil        -- 地图中心 / 玩家开启时的位置
local BEHIND_DISTANCE = 5
local UPDATE_RATE = 0.03

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpawnedSansOrbitUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 320)
mainFrame.Position = UDim2.new(0.5, -135, 0.6, 0)
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
title.Text = "环绕控制"
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

-- 环绕 Sans
local sansOrbitBtn = Instance.new("TextButton")
sansOrbitBtn.Size = UDim2.new(0.9, 0, 0, 32)
sansOrbitBtn.Position = UDim2.new(0.05, 0, 0, 42)
sansOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
sansOrbitBtn.Text = "环绕 Sans：关闭"
sansOrbitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sansOrbitBtn.TextSize = 13
sansOrbitBtn.Font = Enum.Font.GothamBold
sansOrbitBtn.Parent = mainFrame
Instance.new("UICorner", sansOrbitBtn).CornerRadius = UDim.new(0, 6)

-- 环绕地图中心
local centerOrbitBtn = Instance.new("TextButton")
centerOrbitBtn.Size = UDim2.new(0.9, 0, 0, 32)
centerOrbitBtn.Position = UDim2.new(0.05, 0, 0, 80)
centerOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
centerOrbitBtn.Text = "环绕地图中心：关闭"
centerOrbitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
centerOrbitBtn.TextSize = 13
centerOrbitBtn.Font = Enum.Font.GothamBold
centerOrbitBtn.Parent = mainFrame
Instance.new("UICorner", centerOrbitBtn).CornerRadius = UDim.new(0, 6)

-- 速度
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 20)
speedLabel.Position = UDim2.new(0.05, 0, 0, 122)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "环绕速度："
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.4, 0, 0, 26)
speedBox.Position = UDim2.new(0.45, 0, 0, 119)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = "2"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
speedBox.Font = Enum.Font.GothamBold
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

-- Sans 距离
local distLabel = Instance.new("TextLabel")
distLabel.Size = UDim2.new(0.4, 0, 0, 20)
distLabel.Position = UDim2.new(0.05, 0, 0, 155)
distLabel.BackgroundTransparency = 1
distLabel.Text = "Sans距离："
distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distLabel.TextSize = 12
distLabel.Font = Enum.Font.Gotham
distLabel.TextXAlignment = Enum.TextXAlignment.Left
distLabel.Parent = mainFrame

local distBox = Instance.new("TextBox")
distBox.Size = UDim2.new(0.4, 0, 0, 26)
distBox.Position = UDim2.new(0.45, 0, 0, 152)
distBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
distBox.Text = "10"
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distBox.TextSize = 13
distBox.Font = Enum.Font.GothamBold
distBox.Parent = mainFrame
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 6)

-- 中心距离
local centerDistLabel = Instance.new("TextLabel")
centerDistLabel.Size = UDim2.new(0.4, 0, 0, 20)
centerDistLabel.Position = UDim2.new(0.05, 0, 0, 188)
centerDistLabel.BackgroundTransparency = 1
centerDistLabel.Text = "中心距离："
centerDistLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
centerDistLabel.TextSize = 12
centerDistLabel.Font = Enum.Font.Gotham
centerDistLabel.TextXAlignment = Enum.TextXAlignment.Left
centerDistLabel.Parent = mainFrame

local centerDistBox = Instance.new("TextBox")
centerDistBox.Size = UDim2.new(0.4, 0, 0, 26)
centerDistBox.Position = UDim2.new(0.45, 0, 0, 185)
centerDistBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
centerDistBox.Text = "30"
centerDistBox.TextColor3 = Color3.fromRGB(255, 255, 255)
centerDistBox.TextSize = 13
centerDistBox.Font = Enum.Font.GothamBold
centerDistBox.Parent = mainFrame
Instance.new("UICorner", centerDistBox).CornerRadius = UDim.new(0, 6)

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.9, 0, 0, 28)
applyBtn.Position = UDim2.new(0.05, 0, 0, 220)
applyBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applyBtn.Text = "应用速度 / 距离"
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.TextSize = 13
applyBtn.Font = Enum.Font.Gotham
applyBtn.Parent = mainFrame
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 258)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "开启中心环绕时会记录当前位置为圆心"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- ===================== 逻辑 =====================
local isMinimized = false
local originalSize = mainFrame.Size

local function getFirstSans()
    local folder = Workspace:FindFirstChild("SpawnedSans")
    if not folder then return nil end
    return folder:GetChildren()[1]
end

local function getPosition(inst)
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

-- 环绕 Sans
local function doSansOrbit(dt)
    if not hrp then return end
    local sans = getFirstSans()
    local sansPos = getPosition(sans)
    if not sansPos then return end

    orbitAngle = orbitAngle + (orbitSpeed * dt)
    local offset = Vector3.new(
        math.cos(orbitAngle) * orbitDistance,
        0,
        math.sin(orbitAngle) * orbitDistance
    )
    local targetPos = sansPos + offset
    hrp.CFrame = CFrame.new(targetPos, sansPos)
end

-- 环绕地图中心 / 玩家记录点
local function doCenterOrbit(dt)
    if not hrp or not centerPosition then return end

    centerAngle = centerAngle + (orbitSpeed * dt)
    local offset = Vector3.new(
        math.cos(centerAngle) * centerDistance,
        0,
        math.sin(centerAngle) * centerDistance
    )
    local targetPos = centerPosition + offset
    hrp.CFrame = CFrame.new(targetPos, centerPosition)
end

-- 主循环
task.spawn(function()
    local last = tick()
    while true do
        local now = tick()
        local dt = now - last
        last = now

        if orbitSansEnabled then
            pcall(doSansOrbit, dt)
        end
        if orbitCenterEnabled then
            pcall(doCenterOrbit, dt)
        end
        task.wait(UPDATE_RATE)
    end
end)

-- 按钮事件
sansOrbitBtn.MouseButton1Click:Connect(function()
    orbitSansEnabled = not orbitSansEnabled
    if orbitSansEnabled then
        orbitCenterEnabled = false
        centerOrbitBtn.Text = "环绕地图中心：关闭"
        centerOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

        sansOrbitBtn.Text = "环绕 Sans：开启"
        sansOrbitBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "正在环绕 Sans"
    else
        sansOrbitBtn.Text = "环绕 Sans：关闭"
        sansOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        statusLabel.Text = "已停止"
    end
end)

centerOrbitBtn.MouseButton1Click:Connect(function()
    orbitCenterEnabled = not orbitCenterEnabled
    if orbitCenterEnabled then
        orbitSansEnabled = false
        sansOrbitBtn.Text = "环绕 Sans：关闭"
        sansOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

        -- 记录当前玩家位置作为圆心（如果没有地图中心）
        if hrp then
            centerPosition = hrp.Position
            statusLabel.Text = "已记录当前位置为圆心\n正在环绕中心"
        else
            statusLabel.Text = "无法获取玩家位置"
            orbitCenterEnabled = false
            return
        end

        centerOrbitBtn.Text = "环绕地图中心：开启"
        centerOrbitBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    else
        centerOrbitBtn.Text = "环绕地图中心：关闭"
        centerOrbitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        statusLabel.Text = "已停止"
    end
end)

applyBtn.MouseButton1Click:Connect(function()
    local s = tonumber(speedBox.Text)
    local d = tonumber(distBox.Text)
    local cd = tonumber(centerDistBox.Text)

    if s and s > 0 then orbitSpeed = s end
    if d and d > 0 then orbitDistance = d end
    if cd and cd > 0 then centerDistance = cd end

    statusLabel.Text = string.format("速度:%.1f | Sans距离:%.1f | 中心距离:%.1f", orbitSpeed, orbitDistance, centerDistance)
end)

-- 最小化
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 270, 0, 32)
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
    orbitSansEnabled = false
    orbitCenterEnabled = false
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

print("环绕脚本已加载（支持环绕Sans + 环绕地图中心）")