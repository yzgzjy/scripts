-- 多技能自动攻击（MadBlaster 独立 + 对 SpawnedSans 所有实例）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local AttackEvent = ReplicatedStorage:WaitForChild("AttackEvent")
local SkillRemote = ReplicatedStorage:WaitForChild("SkillRemote")

-- 普通技能（共享速率）
local skills = {
    {name = "BoneThrow", enabled = false, func = function() AttackEvent:FireServer("BoneThrow") end},
    {name = "dash_attack2", enabled = false, func = function() SkillRemote:FireServer("dash_attack2") end},
    {name = "Spinbone", enabled = false, func = function() AttackEvent:FireServer("Spinbone", "Normal") end},
    {name = "KillerKnife", enabled = false, func = function() AttackEvent:FireServer("KillerKnife", Vector3.new(25.597873687744, 164.59527587891, -300.49691772461)) end},
    {name = "HorrorAxe", enabled = false, func = function() AttackEvent:FireServer("HorrorAxe", false, 0.084241390228271) end},
    {name = "BoneWall (R_Skill)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "R_Skill") end},
    {name = "BoneWall (Normal)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "Normal") end}
}

-- 独立技能
local farmerGB = {enabled = false, speed = 0.1}
local madBlaster = {enabled = false, speed = 0.15}

local isRunning = false
local loopSpeed = 0.1
local dropdownOpen = false

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiAttackUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 340)
mainFrame.Position = UDim2.new(0.5, -125, 0.55, 0)
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

-- 普通技能速率
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
speedBox.Size = UDim2.new(0.4, 0, 0, 24)
speedBox.Position = UDim2.new(0.05, 0, 0, 54)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = "0.1"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
speedBox.Font = Enum.Font.GothamBold
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)

local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.Size = UDim2.new(0.35, 0, 0, 24)
applySpeedBtn.Position = UDim2.new(0.5, 0, 0, 54)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applySpeedBtn.Text = "应用"
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.TextSize = 12
applySpeedBtn.Font = Enum.Font.Gotham
applySpeedBtn.Parent = mainFrame
Instance.new("UICorner", applySpeedBtn).CornerRadius = UDim.new(0, 5)

-- 下拉按钮
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 28)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 88)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
dropdownBtn.Text = "▼ 选择普通技能"
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextSize = 12
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.Parent = mainFrame
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)

local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 118)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ScrollBarThickness = 3
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 6)

for i, skill in ipairs(skills) do
    local s = skill
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 24)
    btn.Position = UDim2.new(0, 4, 0, (i-1)*26 + 4)
    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    btn.Text = "[关] " .. s.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = dropdownFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        s.enabled = not s.enabled
        btn.BackgroundColor3 = s.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        btn.Text = (s.enabled and "[开] " or "[关] ") .. s.name
    end)
end
dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #skills * 26 + 8)

-- FarmerGB
local farmerFrame = Instance.new("Frame")
farmerFrame.Size = UDim2.new(0.9, 0, 0, 52)
farmerFrame.Position = UDim2.new(0.05, 0, 0, 125)
farmerFrame.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
farmerFrame.BorderSizePixel = 0
farmerFrame.Parent = mainFrame
Instance.new("UICorner", farmerFrame).CornerRadius = UDim.new(0, 6)

local farmerBtn = Instance.new("TextButton")
farmerBtn.Size = UDim2.new(0.42, 0, 0, 24)
farmerBtn.Position = UDim2.new(0.04, 0, 0, 14)
farmerBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
farmerBtn.Text = "[关] FarmerGB"
farmerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerBtn.TextSize = 11
farmerBtn.Font = Enum.Font.Gotham
farmerBtn.Parent = farmerFrame
Instance.new("UICorner", farmerBtn).CornerRadius = UDim.new(0, 4)

local farmerSpeedBox = Instance.new("TextBox")
farmerSpeedBox.Size = UDim2.new(0.25, 0, 0, 24)
farmerSpeedBox.Position = UDim2.new(0.5, 0, 0, 14)
farmerSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
farmerSpeedBox.Text = "0.1"
farmerSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerSpeedBox.TextSize = 11
farmerSpeedBox.Font = Enum.Font.GothamBold
farmerSpeedBox.Parent = farmerFrame
Instance.new("UICorner", farmerSpeedBox).CornerRadius = UDim.new(0, 4)

local farmerApplyBtn = Instance.new("TextButton")
farmerApplyBtn.Size = UDim2.new(0.2, 0, 0, 24)
farmerApplyBtn.Position = UDim2.new(0.77, 0, 0, 14)
farmerApplyBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 140)
farmerApplyBtn.Text = "应用"
farmerApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerApplyBtn.TextSize = 11
farmerApplyBtn.Font = Enum.Font.Gotham
farmerApplyBtn.Parent = farmerFrame
Instance.new("UICorner", farmerApplyBtn).CornerRadius = UDim.new(0, 4)

-- MadBlaster 独立区域
local madFrame = Instance.new("Frame")
madFrame.Size = UDim2.new(0.9, 0, 0, 52)
madFrame.Position = UDim2.new(0.05, 0, 0, 185)
madFrame.BackgroundColor3 = Color3.fromRGB(55, 40, 40)
madFrame.BorderSizePixel = 0
madFrame.Parent = mainFrame
Instance.new("UICorner", madFrame).CornerRadius = UDim.new(0, 6)

local madBtn = Instance.new("TextButton")
madBtn.Size = UDim2.new(0.42, 0, 0, 24)
madBtn.Position = UDim2.new(0.04, 0, 0, 14)
madBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
madBtn.Text = "[关] MadBlaster"
madBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madBtn.TextSize = 11
madBtn.Font = Enum.Font.Gotham
madBtn.Parent = madFrame
Instance.new("UICorner", madBtn).CornerRadius = UDim.new(0, 4)

local madSpeedBox = Instance.new("TextBox")
madSpeedBox.Size = UDim2.new(0.25, 0, 0, 24)
madSpeedBox.Position = UDim2.new(0.5, 0, 0, 14)
madSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
madSpeedBox.Text = "0.15"
madSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
madSpeedBox.TextSize = 11
madSpeedBox.Font = Enum.Font.GothamBold
madSpeedBox.Parent = madFrame
Instance.new("UICorner", madSpeedBox).CornerRadius = UDim.new(0, 4)

local madApplyBtn = Instance.new("TextButton")
madApplyBtn.Size = UDim2.new(0.2, 0, 0, 24)
madApplyBtn.Position = UDim2.new(0.77, 0, 0, 14)
madApplyBtn.BackgroundColor3 = Color3.fromRGB(140, 70, 70)
madApplyBtn.Text = "应用"
madApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madApplyBtn.TextSize = 11
madApplyBtn.Font = Enum.Font.Gotham
madApplyBtn.Parent = madFrame
Instance.new("UICorner", madApplyBtn).CornerRadius = UDim.new(0, 4)

-- 总开关
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 34)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 250)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "状态：已停止"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 295)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "MadBlaster 已独立，对SpawnedSans所有实例"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- ===================== 逻辑 =====================
local function getPosition(inst)
    if inst:IsA("Model") then
        return inst:GetPivot().Position
    elseif inst:IsA("BasePart") then
        return inst.Position
    else
        local part = inst:FindFirstChildWhichIsA("BasePart")
        if part then return part.Position end
    end
    return nil
end

local function updateDropdown()
    if dropdownOpen then
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 120)
        dropdownFrame.Visible = true
        dropdownBtn.Text = "▲ 收起技能列表"
        farmerFrame.Position = UDim2.new(0.05, 0, 0, 245)
        madFrame.Position = UDim2.new(0.05, 0, 0, 305)
        toggleBtn.Position = UDim2.new(0.05, 0, 0, 370)
        statusLabel.Position = UDim2.new(0.05, 0, 0, 415)
        mainFrame.Size = UDim2.new(0, 250, 0, 450)
    else
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
        dropdownFrame.Visible = false
        dropdownBtn.Text = "▼ 选择普通技能"
        farmerFrame.Position = UDim2.new(0.05, 0, 0, 125)
        madFrame.Position = UDim2.new(0.05, 0, 0, 185)
        toggleBtn.Position = UDim2.new(0.05, 0, 0, 250)
        statusLabel.Position = UDim2.new(0.05, 0, 0, 295)
        mainFrame.Size = UDim2.new(0, 250, 0, 340)
    end
end

dropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    updateDropdown()
end)

applySpeedBtn.MouseButton1Click:Connect(function()
    local num = tonumber(speedBox.Text)
    if num and num > 0 then loopSpeed = num end
end)

farmerBtn.MouseButton1Click:Connect(function()
    farmerGB.enabled = not farmerGB.enabled
    farmerBtn.BackgroundColor3 = farmerGB.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    farmerBtn.Text = (farmerGB.enabled and "[开] " or "[关] ") .. "FarmerGB"
end)

farmerApplyBtn.MouseButton1Click:Connect(function()
    local num = tonumber(farmerSpeedBox.Text)
    if num and num > 0 then farmerGB.speed = num end
end)

madBtn.MouseButton1Click:Connect(function()
    madBlaster.enabled = not madBlaster.enabled
    madBtn.BackgroundColor3 = madBlaster.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    madBtn.Text = (madBlaster.enabled and "[开] " or "[关] ") .. "MadBlaster"
end)

madApplyBtn.MouseButton1Click:Connect(function()
    local num = tonumber(madSpeedBox.Text)
    if num and num > 0 then madBlaster.speed = num end
end)

local function toggle()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "状态：运行中"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)

        -- 普通技能
        task.spawn(function()
            while isRunning do
                for _, skill in ipairs(skills) do
                    if skill.enabled then pcall(skill.func) end
                end
                task.wait(loopSpeed)
            end
        end)

        -- FarmerGB
        task.spawn(function()
            while isRunning do
                if farmerGB.enabled then
                    pcall(function() AttackEvent:FireServer("FarmerGB") end)
                end
                task.wait(farmerGB.speed)
            end
        end)

        -- MadBlaster（对 SpawnedSans 下每个实例）
        task.spawn(function()
            while isRunning do
                if madBlaster.enabled then
                    local folder = Workspace:FindFirstChild("SpawnedSans")
                    if folder then
                        for _, inst in ipairs(folder:GetChildren()) do
                            local pos = getPosition(inst)
                            if pos then
                                pcall(function()
                                    AttackEvent:FireServer("MadBlaster", pos)
                                end)
                            end
                        end
                    end
                end
                task.wait(madBlaster.speed)
            end
        end)
    else
        toggleBtn.Text = "状态：已停止"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end

toggleBtn.MouseButton1Click:Connect(toggle)

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    screenGui:Destroy()
end)

-- 拖动
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function() dragging = false end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("脚本已加载：MadBlaster 独立速率，并对 SpawnedSans 所有实例发动")