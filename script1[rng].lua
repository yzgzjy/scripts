-- 多技能自动攻击（双列表折叠版 - 紧凑）
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local AttackEvent = ReplicatedStorage:WaitForChild("AttackEvent")
local SkillRemote = ReplicatedStorage:WaitForChild("SkillRemote")

-- 普通技能
local normalSkills = {
    {name = "BoneThrow", enabled = false, func = function() AttackEvent:FireServer("BoneThrow") end},
    {name = "dash_attack2", enabled = false, func = function() SkillRemote:FireServer("dash_attack2") end},
    {name = "Spinbone", enabled = false, func = function() AttackEvent:FireServer("Spinbone", "Normal") end},
    {name = "KillerKnife", enabled = false, func = function() AttackEvent:FireServer("KillerKnife", Vector3.new(25.597873687744, 164.59527587891, -300.49691772461)) end},
    {name = "HorrorAxe", enabled = false, func = function() AttackEvent:FireServer("HorrorAxe", false, 0.084241390228271) end},
    {name = "BoneWall (R_Skill)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "R_Skill") end},
    {name = "BoneWall (Normal)", enabled = false, func = function() AttackEvent:FireServer("BoneWall", "Normal") end}
}

-- 独立技能
local specialSkills = {
    {
        name = "FarmerGB",
        enabled = false,
        speed = 0.1,
        func = function() AttackEvent:FireServer("FarmerGB") end
    },
    {
        name = "AntiErrorGB",
        enabled = false,
        speed = 0.1,
        func = function()
            AttackEvent:FireServer("AntiErrorGB", Vector3.new(131.50534057617188, 128.61033630371094, -630.021728515625))
        end
    }
}

local madBlaster = {
    enabled = false,
    speed = 0.15,
    mode = "first" -- first / random / all
}

local isRunning = false
local loopSpeed = 0.1
local normalOpen = false
local specialOpen = false
local isMinimized = false

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiAttackUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
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

-- 普通速率
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.4, 0, 0, 24)
speedBox.Position = UDim2.new(0.05, 0, 0, 38)
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
applySpeedBtn.Position = UDim2.new(0.5, 0, 0, 38)
applySpeedBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 160)
applySpeedBtn.Text = "应用"
applySpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedBtn.TextSize = 12
applySpeedBtn.Font = Enum.Font.Gotham
applySpeedBtn.Parent = mainFrame
Instance.new("UICorner", applySpeedBtn).CornerRadius = UDim.new(0, 5)

-- 普通技能折叠按钮
local normalBtn = Instance.new("TextButton")
normalBtn.Size = UDim2.new(0.9, 0, 0, 26)
normalBtn.Position = UDim2.new(0.05, 0, 0, 70)
normalBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
normalBtn.Text = "▼ 普通技能"
normalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
normalBtn.TextSize = 12
normalBtn.Font = Enum.Font.Gotham
normalBtn.Parent = mainFrame
Instance.new("UICorner", normalBtn).CornerRadius = UDim.new(0, 5)

local normalFrame = Instance.new("ScrollingFrame")
normalFrame.Size = UDim2.new(0.9, 0, 0, 0)
normalFrame.Position = UDim2.new(0.05, 0, 0, 98)
normalFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
normalFrame.BorderSizePixel = 0
normalFrame.ScrollBarThickness = 3
normalFrame.Visible = false
normalFrame.Parent = mainFrame
Instance.new("UICorner", normalFrame).CornerRadius = UDim.new(0, 5)

for i, skill in ipairs(normalSkills) do
    local s = skill
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 22)
    btn.Position = UDim2.new(0, 3, 0, (i-1)*24 + 3)
    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    btn.Text = "[关] " .. s.name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = normalFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        s.enabled = not s.enabled
        btn.BackgroundColor3 = s.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        btn.Text = (s.enabled and "[开] " or "[关] ") .. s.name
    end)
end
normalFrame.CanvasSize = UDim2.new(0, 0, 0, #normalSkills * 24 + 6)

-- 独立技能折叠按钮
local specialBtn = Instance.new("TextButton")
specialBtn.Size = UDim2.new(0.9, 0, 0, 26)
specialBtn.Position = UDim2.new(0.05, 0, 0, 105)
specialBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
specialBtn.Text = "▼ 独立技能 (Farmer/Anti/Mad)"
specialBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
specialBtn.TextSize = 12
specialBtn.Font = Enum.Font.Gotham
specialBtn.Parent = mainFrame
Instance.new("UICorner", specialBtn).CornerRadius = UDim.new(0, 5)

local specialFrame = Instance.new("Frame")
specialFrame.Size = UDim2.new(0.9, 0, 0, 0)
specialFrame.Position = UDim2.new(0.05, 0, 0, 133)
specialFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
specialFrame.BorderSizePixel = 0
specialFrame.Visible = false
specialFrame.Parent = mainFrame
Instance.new("UICorner", specialFrame).CornerRadius = UDim.new(0, 5)

-- 独立技能内容
local function createSpecialContent()
    specialFrame:ClearAllChildren()
    Instance.new("UICorner", specialFrame).CornerRadius = UDim.new(0, 5)

    local y = 6

    -- FarmerGB
    local fBtn = Instance.new("TextButton")
    fBtn.Size = UDim2.new(0.55, 0, 0, 24)
    fBtn.Position = UDim2.new(0.03, 0, 0, y)
    fBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    fBtn.Text = "[关] FarmerGB"
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.TextSize = 11
    fBtn.Font = Enum.Font.Gotham
    fBtn.Parent = specialFrame
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 4)

    local fSpeed = Instance.new("TextBox")
    fSpeed.Size = UDim2.new(0.35, 0, 0, 24)
    fSpeed.Position = UDim2.new(0.62, 0, 0, y)
    fSpeed.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    fSpeed.Text = "0.1"
    fSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    fSpeed.TextSize = 11
    fSpeed.Font = Enum.Font.Gotham
    fSpeed.Parent = specialFrame
    Instance.new("UICorner", fSpeed).CornerRadius = UDim.new(0, 4)

    fBtn.MouseButton1Click:Connect(function()
        specialSkills[1].enabled = not specialSkills[1].enabled
        fBtn.BackgroundColor3 = specialSkills[1].enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        fBtn.Text = (specialSkills[1].enabled and "[开] " or "[关] ") .. "FarmerGB"
    end)
    fSpeed.FocusLost:Connect(function()
        local n = tonumber(fSpeed.Text)
        if n and n > 0 then specialSkills[1].speed = n end
    end)

    y = y + 30

    -- AntiErrorGB
    local aBtn = Instance.new("TextButton")
    aBtn.Size = UDim2.new(0.55, 0, 0, 24)
    aBtn.Position = UDim2.new(0.03, 0, 0, y)
    aBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    aBtn.Text = "[关] AntiErrorGB"
    aBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aBtn.TextSize = 11
    aBtn.Font = Enum.Font.Gotham
    aBtn.Parent = specialFrame
    Instance.new("UICorner", aBtn).CornerRadius = UDim.new(0, 4)

    local aSpeed = Instance.new("TextBox")
    aSpeed.Size = UDim2.new(0.35, 0, 0, 24)
    aSpeed.Position = UDim2.new(0.62, 0, 0, y)
    aSpeed.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    aSpeed.Text = "0.1"
    aSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    aSpeed.TextSize = 11
    aSpeed.Font = Enum.Font.Gotham
    aSpeed.Parent = specialFrame
    Instance.new("UICorner", aSpeed).CornerRadius = UDim.new(0, 4)

    aBtn.MouseButton1Click:Connect(function()
        specialSkills[2].enabled = not specialSkills[2].enabled
        aBtn.BackgroundColor3 = specialSkills[2].enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        aBtn.Text = (specialSkills[2].enabled and "[开] " or "[关] ") .. "AntiErrorGB"
    end)
    aSpeed.FocusLost:Connect(function()
        local n = tonumber(aSpeed.Text)
        if n and n > 0 then specialSkills[2].speed = n end
    end)

    y = y + 30

    -- MadBlaster 模式
    local modeLabel = Instance.new("TextLabel")
    modeLabel.Size = UDim2.new(0.9, 0, 0, 18)
    modeLabel.Position = UDim2.new(0.05, 0, 0, y)
    modeLabel.BackgroundTransparency = 1
    modeLabel.Text = "MadBlaster 模式："
    modeLabel.TextColor3 = Color3.fromRGB(220, 180, 180)
    modeLabel.TextSize = 11
    modeLabel.Font = Enum.Font.Gotham
    modeLabel.TextXAlignment = Enum.TextXAlignment.Left
    modeLabel.Parent = specialFrame

    y = y + 20

    local function makeModeBtn(text, mode, x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.28, 0, 0, 22)
        btn.Position = UDim2.new(x, 0, 0, y)
        btn.BackgroundColor3 = madBlaster.mode == mode and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.Parent = specialFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            madBlaster.mode = mode
            createSpecialContent() -- 刷新颜色
        end)
    end

    makeModeBtn("第一个", "first", 0.03)
    makeModeBtn("随机", "random", 0.36)
    makeModeBtn("全部", "all", 0.69)

    y = y + 28

    local mBtn = Instance.new("TextButton")
    mBtn.Size = UDim2.new(0.55, 0, 0, 24)
    mBtn.Position = UDim2.new(0.03, 0, 0, y)
    mBtn.BackgroundColor3 = madBlaster.enabled and Color3.fromRGB(40, 140, 70) or Color3.fromRGB(80, 50, 50)
    mBtn.Text = (madBlaster.enabled and "[开] " or "[关] ") .. "MadBlaster"
    mBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mBtn.TextSize = 11
    mBtn.Font = Enum.Font.Gotham
    mBtn.Parent = specialFrame
    Instance.new("UICorner", mBtn).CornerRadius = UDim.new(0, 4)

    local mSpeed = Instance.new("TextBox")
    mSpeed.Size = UDim2.new(0.35, 0, 0, 24)
    mSpeed.Position = UDim2.new(0.62, 0, 0, y)
    mSpeed.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    mSpeed.Text = tostring(madBlaster.speed)
    mSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
    mSpeed.TextSize = 11
    mSpeed.Font = Enum.Font.Gotham
    mSpeed.Parent = specialFrame
    Instance.new("UICorner", mSpeed).CornerRadius = UDim.new(0, 4)

    mBtn.MouseButton1Click:Connect(function()
        madBlaster.enabled = not madBlaster.enabled
        createSpecialContent()
    end)
    mSpeed.FocusLost:Connect(function()
        local n = tonumber(mSpeed.Text)
        if n and n > 0 then madBlaster.speed = n end
    end)

    y = y + 30

    local onceBtn = Instance.new("TextButton")
    onceBtn.Size = UDim2.new(0.94, 0, 0, 24)
    onceBtn.Position = UDim2.new(0.03, 0, 0, y)
    onceBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    onceBtn.Text = "一次性攻击（当前模式）"
    onceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    onceBtn.TextSize = 11
    onceBtn.Font = Enum.Font.GothamBold
    onceBtn.Parent = specialFrame
    Instance.new("UICorner", onceBtn).CornerRadius = UDim.new(0, 4)

    onceBtn.MouseButton1Click:Connect(function()
        -- 触发一次
        local list = Workspace:FindFirstChild("SpawnedSans") and Workspace.SpawnedSans:GetChildren() or {}
        if #list == 0 then return end
        local function getPos(inst)
            if inst:IsA("Model") then return inst:GetPivot().Position end
            if inst:IsA("BasePart") then return inst.Position end
            local p = inst:FindFirstChildWhichIsA("BasePart", true)
            return p and p.Position
        end
        if madBlaster.mode == "first" then
            AttackEvent:FireServer("MadBlaster", getPos(list[1]))
        elseif madBlaster.mode == "random" then
            AttackEvent:FireServer("MadBlaster", getPos(list[math.random(1, #list)]))
        else
            for _, inst in ipairs(list) do
                local pos = getPos(inst)
                if pos then AttackEvent:FireServer("MadBlaster", pos) end
            end
        end
    end)
end

createSpecialContent()

-- 总开关
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 34)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 140)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "状态：已停止"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 180)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "点击上方按钮展开列表"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local originalSize = mainFrame.Size

-- ===================== 布局更新 =====================
local function updateLayout()
    local y = 70
    normalBtn.Position = UDim2.new(0.05, 0, 0, y)
    y = y + 28

    if normalOpen then
        normalFrame.Position = UDim2.new(0.05, 0, 0, y)
        normalFrame.Size = UDim2.new(0.9, 0, 0, 120)
        normalFrame.Visible = true
        normalBtn.Text = "▲ 普通技能"
        y = y + 125
    else
        normalFrame.Size = UDim2.new(0.9, 0, 0, 0)
        normalFrame.Visible = false
        normalBtn.Text = "▼ 普通技能"
    end

    specialBtn.Position = UDim2.new(0.05, 0, 0, y)
    y = y + 28

    if specialOpen then
        specialFrame.Position = UDim2.new(0.05, 0, 0, y)
        specialFrame.Size = UDim2.new(0.9, 0, 0, 160)
        specialFrame.Visible = true
        specialBtn.Text = "▲ 独立技能"
        y = y + 165
    else
        specialFrame.Size = UDim2.new(0.9, 0, 0, 0)
        specialFrame.Visible = false
        specialBtn.Text = "▼ 独立技能 (Farmer/Anti/Mad)"
    end

    toggleBtn.Position = UDim2.new(0.05, 0, 0, y)
    y = y + 42
    statusLabel.Position = UDim2.new(0.05, 0, 0, y)

    mainFrame.Size = UDim2.new(0, 250, 0, y + 40)
end

normalBtn.MouseButton1Click:Connect(function()
    normalOpen = not normalOpen
    updateLayout()
end)

specialBtn.MouseButton1Click:Connect(function()
    specialOpen = not specialOpen
    updateLayout()
end)

applySpeedBtn.MouseButton1Click:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n > 0 then loopSpeed = n end
end)

-- 总开关逻辑
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "状态：运行中"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)

        task.spawn(function()
            while isRunning do
                for _, skill in ipairs(normalSkills) do
                    if skill.enabled then pcall(skill.func) end
                end
                task.wait(loopSpeed)
            end
        end)

        task.spawn(function()
            while isRunning do
                for _, skill in ipairs(specialSkills) do
                    if skill.enabled then
                        pcall(skill.func)
                        task.wait(skill.speed)
                    end
                end
                task.wait(0.03)
            end
        end)

        task.spawn(function()
            while isRunning do
                if madBlaster.enabled then
                    local list = Workspace:FindFirstChild("SpawnedSans") and Workspace.SpawnedSans:GetChildren() or {}
                    if #list > 0 then
                        local function getPos(inst)
                            if inst:IsA("Model") then return inst:GetPivot().Position end
                            if inst:IsA("BasePart") then return inst.Position end
                            local p = inst:FindFirstChildWhichIsA("BasePart", true)
                            return p and p.Position
                        end
                        if madBlaster.mode == "first" then
                            AttackEvent:FireServer("MadBlaster", getPos(list[1]))
                        elseif madBlaster.mode == "random" then
                            AttackEvent:FireServer("MadBlaster", getPos(list[math.random(1,#list)]))
                        else
                            for _, inst in ipairs(list) do
                                local pos = getPos(inst)
                                if pos then AttackEvent:FireServer("MadBlaster", pos) end
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
end)

-- 最小化
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 250, 0, 30)
        for _, c in ipairs(mainFrame:GetChildren()) do
            if c ~= titleBar and c:IsA("GuiObject") then c.Visible = false end
        end
        minimizeBtn.Text = "+"
    else
        updateLayout()
        for _, c in ipairs(mainFrame:GetChildren()) do
            if c:IsA("GuiObject") then c.Visible = true end
        end
        normalFrame.Visible = normalOpen
        specialFrame.Visible = specialOpen
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

updateLayout()
print("紧凑双列表版已加载")