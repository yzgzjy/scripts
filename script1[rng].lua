-- 多技能自动攻击整合脚本（修复拖动 + 缩小UI）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local AttackEvent = ReplicatedStorage:WaitForChild("AttackEvent")
local SkillRemote = ReplicatedStorage:WaitForChild("SkillRemote")

-- ===================== 普通技能配置 =====================
local skills = {
    {name = "BoneThrow", enabled = false, func = function() AttackEvent:FireServer("BoneThrow") end},
    {name = "dash_attack2", enabled = false, func = function() SkillRemote:FireServer("dash_attack2") end},
    {name = "Spinbone", enabled = false, func = function() AttackEvent:FireServer("Spinbone", "Normal") end},
    {name = "KillerKnife", enabled = false, func = function() AttackEvent:FireServer("KillerKnife", Vector3.new(25.597873687744, 164.59527587891, -300.49691772461)) end},
    {name = "HorrorAxe", enabled = false, func = function() AttackEvent:FireServer("HorrorAxe", false, 0.084241390228271) end},
    {name = "BoneWall (R_Skill)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "R_Skill") end},
    {name = "BoneWall (Normal)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "Normal") end}
}

local farmerGB = {enabled = false, speed = 0.1}
local isRunning = false
local loopSpeed = 0.1

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiAttackUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 420)  -- 缩小了尺寸
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "多技能自动攻击"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -56, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 14
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -26, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

-- 速率
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 16)
speedLabel.Position = UDim2.new(0.05, 0, 0, 36)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "普通技能速率："
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.38, 0, 0, 24)
speedBox.Position = UDim2.new(0.05, 0, 0, 54)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = "0.1"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
speedBox.Font = Enum.Font.GothamBold
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)

local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.Size = UDim2.new(0.38, 0, 0, 24)
applySpeedBtn.Position = UDim2.new(0.48, 0, 0, 54)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applySpeedBtn.Text = "应用"
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.TextSize = 12
applySpeedBtn.Font = Enum.Font.Gotham
applySpeedBtn.Parent = mainFrame
Instance.new("UICorner", applySpeedBtn).CornerRadius = UDim.new(0, 5)

-- 技能列表
local skillsFrame = Instance.new("ScrollingFrame")
skillsFrame.Size = UDim2.new(0.9, 0, 0, 175)
skillsFrame.Position = UDim2.new(0.05, 0, 0, 85)
skillsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
skillsFrame.BorderSizePixel = 0
skillsFrame.ScrollBarThickness = 3
skillsFrame.CanvasSize = UDim2.new(0, 0, 0, #skills * 28 + 8)
skillsFrame.Parent = mainFrame
Instance.new("UICorner", skillsFrame).CornerRadius = UDim.new(0, 6)

for i, skill in ipairs(skills) do
    local s = skill  -- 修复闭包

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 24)
    btn.Position = UDim2.new(0, 5, 0, (i-1)*28 + 4)
    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    btn.Text = "[关] " .. s.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = skillsFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        s.enabled = not s.enabled
        btn.BackgroundColor3 = s.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        btn.Text = (s.enabled and "[开] " or "[关] ") .. s.name
    end)
end

-- FarmerGB
local farmerFrame = Instance.new("Frame")
farmerFrame.Size = UDim2.new(0.9, 0, 0, 62)
farmerFrame.Position = UDim2.new(0.05, 0, 0, 270)
farmerFrame.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
farmerFrame.BorderSizePixel = 0
farmerFrame.Parent = mainFrame
Instance.new("UICorner", farmerFrame).CornerRadius = UDim.new(0, 6)

local farmerTitle = Instance.new("TextLabel")
farmerTitle.Size = UDim2.new(1, -8, 0, 16)
farmerTitle.Position = UDim2.new(0, 6, 0, 3)
farmerTitle.BackgroundTransparency = 1
farmerTitle.Text = "FarmerGB（独立速率）"
farmerTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
farmerTitle.TextSize = 11
farmerTitle.Font = Enum.Font.GothamBold
farmerTitle.TextXAlignment = Enum.TextXAlignment.Left
farmerTitle.Parent = farmerFrame

local farmerBtn = Instance.new("TextButton")
farmerBtn.Size = UDim2.new(0.42, 0, 0, 24)
farmerBtn.Position = UDim2.new(0.04, 0, 0, 24)
farmerBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
farmerBtn.Text = "[关] FarmerGB"
farmerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerBtn.TextSize = 11
farmerBtn.Font = Enum.Font.Gotham
farmerBtn.Parent = farmerFrame
Instance.new("UICorner", farmerBtn).CornerRadius = UDim.new(0, 4)

local farmerSpeedBox = Instance.new("TextBox")
farmerSpeedBox.Size = UDim2.new(0.25, 0, 0, 24)
farmerSpeedBox.Position = UDim2.new(0.5, 0, 0, 24)
farmerSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
farmerSpeedBox.Text = "0.1"
farmerSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerSpeedBox.TextSize = 11
farmerSpeedBox.Font = Enum.Font.GothamBold
farmerSpeedBox.Parent = farmerFrame
Instance.new("UICorner", farmerSpeedBox).CornerRadius = UDim.new(0, 4)

local farmerApplyBtn = Instance.new("TextButton")
farmerApplyBtn.Size = UDim2.new(0.2, 0, 0, 24)
farmerApplyBtn.Position = UDim2.new(0.77, 0, 0, 24)
farmerApplyBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 140)
farmerApplyBtn.Text = "应用"
farmerApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerApplyBtn.TextSize = 11
farmerApplyBtn.Font = Enum.Font.Gotham
farmerApplyBtn.Parent = farmerFrame
Instance.new("UICorner", farmerApplyBtn).CornerRadius = UDim.new(0, 4)

-- 总开关
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 36)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 345)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "状态：已停止"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 16)
statusLabel.Position = UDim2.new(0.05, 0, 0, 388)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "UI已缩小 + 支持拖动"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- ===================== 逻辑 =====================
local isMinimized = false
local originalSize = mainFrame.Size

applySpeedBtn.MouseButton1Click:Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num > 0 then
        loopSpeed = num
        statusLabel.Text = "普通技能速率 → " .. num
    end
end)

farmerBtn.MouseButton1Click:Connect(function()
    farmerGB.enabled = not farmerGB.enabled
    farmerBtn.BackgroundColor3 = farmerGB.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    farmerBtn.Text = (farmerGB.enabled and "[开] " or "[关] ") .. "FarmerGB"
end)

farmerApplyBtn.MouseButton1Click:Connect(function()
    local num = tonumber(farmerSpeedBox.Text)
    if num and num > 0 then
        farmerGB.speed = num
        statusLabel.Text = "FarmerGB 速率 → " .. num
    end
end)

local function toggle()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "状态：运行中"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
        statusLabel.Text = "正在运行..."

        task.spawn(function()
            while isRunning do
                for _, skill in ipairs(skills) do
                    if skill.enabled then
                        pcall(skill.func)
                    end
                end
                task.wait(loopSpeed)
            end
        end)

        task.spawn(function()
            while isRunning do
                if farmerGB.enabled then
                    pcall(function()
                        AttackEvent:FireServer("FarmerGB")
                    end)
                end
                task.wait(farmerGB.speed)
            end
        end)
    else
        toggleBtn.Text = "状态：已停止"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        statusLabel.Text = "已停止"
    end
end

toggleBtn.MouseButton1Click:Connect(toggle)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 260, 0, 30)
        for _, c in pairs(mainFrame:GetChildren()) do
            if c ~= titleBar and c:IsA("GuiObject") then c.Visible = false end
        end
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = originalSize
        for _, c in pairs(mainFrame:GetChildren()) do
            if c:IsA("GuiObject") then c.Visible = true end
        end
        minimizeBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    screenGui.Enabled = false
end)

-- ===================== 拖动支持（已修复） =====================
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("多技能脚本已加载（UI缩小 + 拖动修复）") 
