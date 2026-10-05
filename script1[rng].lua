-- 多技能自动攻击（新增 MadBlaster 随机模式）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local AttackEvent = ReplicatedStorage:WaitForChild("AttackEvent")
local SkillRemote = ReplicatedStorage:WaitForChild("SkillRemote")

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

-- MadBlaster 模式： "first" | "random" | "all"
local madBlaster = {
    enabled = false,
    speed = 0.15,
    mode = "first"  -- 默认打第一个
}

local isRunning = false
local loopSpeed = 0.1
local dropdownOpen = false
local isMinimized = false

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiAttackUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 420)
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
title.Size = UDim2.new(1, -70, 1, 0)
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
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.4, 0, 0, 24)
speedBox.Position = UDim2.new(0.05, 0, 0, 40)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedBox.Text = "0.1"
speedBox.PlaceholderText = "普通速率"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 12
speedBox.Font = Enum.Font.Gotham
speedBox.Parent = mainFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)

local applySpeedBtn = Instance.new("TextButton")
applySpeedBtn.Size = UDim2.new(0.35, 0, 0, 24)
applySpeedBtn.Position = UDim2.new(0.5, 0, 0, 40)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applySpeedBtn.Text = "应用"
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.TextSize = 12
applySpeedBtn.Font = Enum.Font.Gotham
applySpeedBtn.Parent = mainFrame
Instance.new("UICorner", applySpeedBtn).CornerRadius = UDim.new(0, 5)

-- 下拉
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0.9, 0, 0, 26)
dropdownBtn.Position = UDim2.new(0.05, 0, 0, 72)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
dropdownBtn.Text = "▼ 普通技能列表"
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextSize = 12
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.Parent = mainFrame
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 5)

local dropdownFrame = Instance.new("ScrollingFrame")
dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
dropdownFrame.Position = UDim2.new(0.05, 0, 0, 100)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.ScrollBarThickness = 3
dropdownFrame.Visible = false
dropdownFrame.Parent = mainFrame
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 5)

for i, skill in ipairs(skills) do
    local s = skill
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 22)
    btn.Position = UDim2.new(0, 3, 0, (i-1)*24 + 3)
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
dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #skills * 24 + 6)

-- FarmerGB
local farmerBtn = Instance.new("TextButton")
farmerBtn.Size = UDim2.new(0.42, 0, 0, 26)
farmerBtn.Position = UDim2.new(0.05, 0, 0, 110)
farmerBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
farmerBtn.Text = "[关] FarmerGB"
farmerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerBtn.TextSize = 11
farmerBtn.Font = Enum.Font.Gotham
farmerBtn.Parent = mainFrame
Instance.new("UICorner", farmerBtn).CornerRadius = UDim.new(0, 5)

local farmerSpeedBox = Instance.new("TextBox")
farmerSpeedBox.Size = UDim2.new(0.2, 0, 0, 26)
farmerSpeedBox.Position = UDim2.new(0.5, 0, 0, 110)
farmerSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
farmerSpeedBox.Text = "0.1"
farmerSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
farmerSpeedBox.TextSize = 11
farmerSpeedBox.Font = Enum.Font.Gotham
farmerSpeedBox.Parent = mainFrame
Instance.new("UICorner", farmerSpeedBox).CornerRadius = UDim.new(0, 5)

-- MadBlaster 区域
local madTitle = Instance.new("TextLabel")
madTitle.Size = UDim2.new(0.9, 0, 0, 18)
madTitle.Position = UDim2.new(0.05, 0, 0, 145)
madTitle.BackgroundTransparency = 1
madTitle.Text = "MadBlaster 模式："
madTitle.TextColor3 = Color3.fromRGB(220, 180, 180)
madTitle.TextSize = 12
madTitle.Font = Enum.Font.GothamBold
madTitle.TextXAlignment = Enum.TextXAlignment.Left
madTitle.Parent = mainFrame

local madFirstBtn = Instance.new("TextButton")
madFirstBtn.Size = UDim2.new(0.28, 0, 0, 26)
madFirstBtn.Position = UDim2.new(0.05, 0, 0, 168)
madFirstBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 70)
madFirstBtn.Text = "第一个"
madFirstBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madFirstBtn.TextSize = 11
madFirstBtn.Font = Enum.Font.Gotham
madFirstBtn.Parent = mainFrame
Instance.new("UICorner", madFirstBtn).CornerRadius = UDim.new(0, 5)

local madRandomBtn = Instance.new("TextButton")
madRandomBtn.Size = UDim2.new(0.28, 0, 0, 26)
madRandomBtn.Position = UDim2.new(0.36, 0, 0, 168)
madRandomBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
madRandomBtn.Text = "随机"
madRandomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madRandomBtn.TextSize = 11
madRandomBtn.Font = Enum.Font.Gotham
madRandomBtn.Parent = mainFrame
Instance.new("UICorner", madRandomBtn).CornerRadius = UDim.new(0, 5)

local madAllBtn = Instance.new("TextButton")
madAllBtn.Size = UDim2.new(0.28, 0, 0, 26)
madAllBtn.Position = UDim2.new(0.67, 0, 0, 168)
madAllBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
madAllBtn.Text = "全部"
madAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madAllBtn.TextSize = 11
madAllBtn.Font = Enum.Font.Gotham
madAllBtn.Parent = mainFrame
Instance.new("UICorner", madAllBtn).CornerRadius = UDim.new(0, 5)

local madEnableBtn = Instance.new("TextButton")
madEnableBtn.Size = UDim2.new(0.42, 0, 0, 26)
madEnableBtn.Position = UDim2.new(0.05, 0, 0, 202)
madEnableBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
madEnableBtn.Text = "[关] 循环开启"
madEnableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madEnableBtn.TextSize = 11
madEnableBtn.Font = Enum.Font.Gotham
madEnableBtn.Parent = mainFrame
Instance.new("UICorner", madEnableBtn).CornerRadius = UDim.new(0, 5)

local madSpeedBox = Instance.new("TextBox")
madSpeedBox.Size = UDim2.new(0.2, 0, 0, 26)
madSpeedBox.Position = UDim2.new(0.5, 0, 0, 202)
madSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
madSpeedBox.Text = "0.15"
madSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
madSpeedBox.TextSize = 11
madSpeedBox.Font = Enum.Font.Gotham
madSpeedBox.Parent = mainFrame
Instance.new("UICorner", madSpeedBox).CornerRadius = UDim.new(0, 5)

local madOnceBtn = Instance.new("TextButton")
madOnceBtn.Size = UDim2.new(0.9, 0, 0, 28)
madOnceBtn.Position = UDim2.new(0.05, 0, 0, 238)
madOnceBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
madOnceBtn.Text = "一次性攻击（根据当前模式）"
madOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
madOnceBtn.TextSize = 12
madOnceBtn.Font = Enum.Font.GothamBold
madOnceBtn.Parent = mainFrame
Instance.new("UICorner", madOnceBtn).CornerRadius = UDim.new(0, 5)

-- 总开关
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 34)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 280)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "状态：已停止"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 40)
statusLabel.Position = UDim2.new(0.05, 0, 0, 325)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "MadBlaster 支持：第一个 / 随机 / 全部"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

local originalSize = mainFrame.Size

-- ===================== 功能函数 =====================
local function getPosition(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        return inst:GetPivot().Position
    elseif inst:IsA("BasePart") then
        return inst.Position
    else
        local part = inst:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position
    end
end

local function getSansList()
    local folder = Workspace:FindFirstChild("SpawnedSans")
    if not folder then return {} end
    return folder:GetChildren()
end

local function fireMadBlaster(pos)
    if pos then
        pcall(function()
            AttackEvent:FireServer("MadBlaster", pos)
        end)
    end
end

local function doMadBlasterOnce()
    local list = getSansList()
    if #list == 0 then
        statusLabel.Text = "SpawnedSans 为空"
        return
    end

    if madBlaster.mode == "first" then
        fireMadBlaster(getPosition(list[1]))
        statusLabel.Text = "已攻击第一个"
    elseif madBlaster.mode == "random" then
        local randomInst = list[math.random(1, #list)]
        fireMadBlaster(getPosition(randomInst))
        statusLabel.Text = "已随机攻击一个"
    elseif madBlaster.mode == "all" then
        local count = 0
        for _, inst in ipairs(list) do
            fireMadBlaster(getPosition(inst))
            count += 1
        end
        statusLabel.Text = "已攻击全部 " .. count .. " 个"
    end
end

local function updateModeButtons()
    madFirstBtn.BackgroundColor3 = madBlaster.mode == "first" and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    madRandomBtn.BackgroundColor3 = madBlaster.mode == "random" and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    madAllBtn.BackgroundColor3 = madBlaster.mode == "all" and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
end

-- ===================== 事件 =====================
dropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 110)
        dropdownFrame.Visible = true
        dropdownBtn.Text = "▲ 收起列表"
    else
        dropdownFrame.Size = UDim2.new(0.9, 0, 0, 0)
        dropdownFrame.Visible = false
        dropdownBtn.Text = "▼ 普通技能列表"
    end
end)

applySpeedBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n > 0 then loopSpeed = n end
end)

farmerBtn.MouseButton1Click:Connect(function()
    farmerGB.enabled = not farmerGB.enabled
    farmerBtn.BackgroundColor3 = farmerGB.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    farmerBtn.Text = (farmerGB.enabled and "[开] " or "[关] ") .. "FarmerGB"
end)

madFirstBtn.MouseButton1Click:Connect(function()
    madBlaster.mode = "first"
    updateModeButtons()
    statusLabel.Text = "模式：只攻击第一个"
end)

madRandomBtn.MouseButton1Click:Connect(function()
    madBlaster.mode = "random"
    updateModeButtons()
    statusLabel.Text = "模式：随机攻击一个"
end)

madAllBtn.MouseButton1Click:Connect(function()
    madBlaster.mode = "all"
    updateModeButtons()
    statusLabel.Text = "模式：攻击全部"
end)

madEnableBtn.MouseButton1Click:Connect(function()
    madBlaster.enabled = not madBlaster.enabled
    madEnableBtn.BackgroundColor3 = madBlaster.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    madEnableBtn.Text = (madBlaster.enabled and "[开] " or "[关] ") .. "循环开启"
end)

madOnceBtn.MouseButton1Click:Connect(doMadBlasterOnce)

toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "状态：运行中"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)

        task.spawn(function()
            while isRunning do
                for _, skill in ipairs(skills) do
                    if skill.enabled then pcall(skill.func) end
                end
                task.wait(loopSpeed)
            end
        end)

        task.spawn(function()
            while isRunning do
                if farmerGB.enabled then
                    pcall(function() AttackEvent:FireServer("FarmerGB") end)
                end
                task.wait(farmerGB.speed)
            end
        end)

        task.spawn(function()
            while isRunning do
                if madBlaster.enabled then
                    doMadBlasterOnce()
                end
                task.wait(madBlaster.speed)
            end
        end)
    else
        toggleBtn.Text = "状态：已停止"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- 最小化
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 260, 0, 30)
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child ~= titleBar and child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = originalSize
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        dropdownFrame.Visible = dropdownOpen
        minimizeBtn.Text = "—"
    end
end)

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

updateModeButtons()
print("脚本已加载：MadBlaster 支持 第一个 / 随机 / 全部 模式")