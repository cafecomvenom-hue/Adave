-- Evade Ultimate Script v2 by AI Assistant
-- Enhanced with more features, sliders, neon GUI like Overdrive
-- Features: Speed (slider), Jump (slider), Fly (slider), ESP (players/bots), NoClip, Fullbright, AutoFarm, InfiniteStamina, Godmode, AntiAFK, UnlockAll, Teleport to Player
-- Made for Roblox Evade Game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Toggles and Values
local toggles = {
    Speed = false,
    JumpPower = false,
    Fly = false,
    ESP = false,
    NoClip = false,
    Fullbright = false,
    AutoFarm = false,
    InfiniteStamina = false,
    Godmode = false,
    AntiAFK = false,
    UnlockAll = false
}

local values = {
    Speed = 50,
    JumpPower = 100,
    FlySpeed = 50
}

-- Fly vars
local flying = false
local bodyVelocity, bodyGyro

-- ESP
local espHighlights = {}

-- Connections
local noClipConnection, autoFarmConnection, antiAFKConnection, godmodeConnection

-- Fullbright original
local originalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime
}

-- GUI (Enhanced Overdrive style: Neon, Tabs, Animations, Sliders)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvadeUltimateMenuV2"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true -- ✅ CORRIGIDO: Agora aparece automaticamente

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 30, 60)), -- Purple-black gradient
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 20))
}
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke") -- Neon outline
MainStroke.Color = Color3.fromRGB(100, 0, 255) -- Neon purple
MainStroke.Transparency = 0.5
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local Shadow = Instance.new("Frame")
Shadow.Parent = MainFrame
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.8
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0, 5, 0, 5)
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.ZIndex = -1

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 12)
ShadowCorner.Parent = Shadow

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 10)
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Evade Ultimate Menu V2"
TitleLabel.TextColor3 = Color3.fromRGB(200, 150, 255) -- Neon text
TitleLabel.TextScaled = true
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Tabs
local TabFrame = Instance.new("Frame")
TabFrame.Parent = MainFrame
TabFrame.BackgroundTransparency = 1
TabFrame.Position = UDim2.new(0, 0, 0, 50)
TabFrame.Size = UDim2.new(1, 0, 0, 30)

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabFrame
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 10)

local tabs = {"Movement", "Visuals", "Farm", "Misc"}
local tabContainers = {}

for _, tabName in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = TabFrame
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    TabButton.BorderSizePixel = 0
    TabButton.Size = UDim2.new(0, 80, 1, 0)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextScaled = true

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Color3.fromRGB(100, 0, 255)
    TabStroke.Transparency = 0.7
    TabStroke.Parent = TabButton

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = tabName .. "Container"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 10, 0, 80)
    TabContainer.Size = UDim2.new(1, -20, 1, -90)
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 255)
    TabContainer.Visible = false

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabContainers[tabName] = TabContainer

    TabButton.MouseButton1Click:Connect(function()
        for _, container in pairs(tabContainers) do
            container.Visible = false
        end
        TabContainer.Visible = true
    end)
end

-- Default to first tab
tabContainers["Movement"].Visible = true

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Transparency = 1})
    tween:Play()
    tween.Completed:Wait()
    ScreenGui:Destroy()
end)

-- Toggle GUI with Insert (with animation)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if MainFrame.Visible then
            local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Transparency = 1})
            tweenOut:Play()
            tweenOut.Completed:Wait()
            MainFrame.Visible = false
        else
            MainFrame.Transparency = 0
            MainFrame.Visible = true
            local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Transparency = 0})
            tweenIn:Play()
        end
    end
end)

-- Create Toggle Function
local function createToggle(parent, name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(100, 0, 255)
    ToggleStroke.Transparency = 0.8
    ToggleStroke.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextScaled = true
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = ToggleButton

    local function toggleState(state)
        if state then
            ToggleButton.Text = "ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 255) -- Neon on
            toggles[name] = true
        else
            ToggleButton.Text = "OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
            toggles[name] = false
        end
        pcall(callback, state)
    end

    ToggleButton.MouseButton1Click:Connect(function()
        toggleState(not toggles[name])
    end)

    toggleState(false)
end

-- Create Slider Function
local function createSlider(parent, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Parent = SliderFrame
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.Size = UDim2.new(1, -100, 0, 20)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.Text = name .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextScaled = true
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("Frame")
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.Size = UDim2.new(1, -20, 0, 10)

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 5)
    BarCorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = SliderFill

    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBar
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.Text = ""

    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    SliderButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * relativeX
            value = math.floor(value + 0.5)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            SliderLabel.Text = name .. ": " .. value
            values[name] = value
            pcall(callback, value)
        end
    end)

    values[name] = default
    callback(default)
end

-- Add to Tabs
-- Movement Tab
createSlider(tabContainers["Movement"], "Speed", 16, 200, 50, function(val)
    values.Speed = val
    if toggles.Speed then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)
createToggle(tabContainers["Movement"], "Speed", function(enabled)
    if enabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = values.Speed
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

createSlider(tabContainers["Movement"], "JumpPower", 50, 300, 100, function(val)
    values.JumpPower = val
    if toggles.JumpPower then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)
createToggle(tabContainers["Movement"], "JumpPower", function(enabled)
    if enabled then
        LocalPlayer.Character.Humanoid.JumpPower = values.JumpPower
    else
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

createSlider(tabContainers["Movement"], "FlySpeed", 20, 200, 50, function(val)
    values.FlySpeed = val
end)
createToggle(tabContainers["Movement"], "Fly", function(enabled)
    flying = enabled
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    if enabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp

        RunService.Heartbeat:Connect(function()
            if flying then
                local cam = Workspace.CurrentCamera
                local move = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                bodyVelocity.Velocity = move.Unit * values.FlySpeed
                bodyGyro.CFrame = cam.CFrame
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end)

createToggle(tabContainers["Movement"], "NoClip", function(enabled)
    if noClipConnection then noClipConnection:Disconnect() end
    if enabled then
        noClipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Visuals Tab
createToggle(tabContainers["Visuals"], "ESP", function(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                espHighlights[player] = highlight
            end
        end
        -- ESP for orbs, coins, bots/monsters
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:match("Orb") or obj.Name:match("Coin") then
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.5
                espHighlights[obj] = highlight
            elseif obj:IsA("Model") and (obj.Name:match("Bot") or obj.Name:match("Monster")) then -- For Evade bots
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = Color3.fromRGB(255, 165, 0)
                highlight.FillTransparency = 0.5
                espHighlights[obj] = highlight
            end
        end
    else
        for _, hl in pairs(espHighlights) do
            if hl then hl:Destroy() end
        end
        espHighlights = {}
    end
end)

createToggle(tabContainers["Visuals"], "Fullbright", function(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        Lighting.ColorShift_Top = originalLighting.ColorShift_Top
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
    end
end)

-- Farm Tab
createToggle(tabContainers["Farm"], "AutoFarm", function(enabled)
    if autoFarmConnection then autoFarmConnection:Disconnect() end
    if enabled then
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if (obj.Name:match("Orb") or obj.Name:match("Coin")) and count < 10 then -- Limit to avoid lag
                        character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        count = count + 1
                        wait(0.2)
                    end
                end
            end
        end)
    end
end)

createToggle(tabContainers["Farm"], "InfiniteStamina", function(enabled)
    if enabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if humanoid.WalkSpeed < 16 then humanoid.WalkSpeed = 16 end
            end)
            -- If stamina value exists (game-specific)
            local stamina = LocalPlayer.Character:FindFirstChild("Stamina") -- Adjust if needed
            if stamina and stamina:IsA("NumberValue") then
                stamina.Value = math.huge
                stamina:GetPropertyChangedSignal("Value"):Connect(function()
                    stamina.Value = math.huge
                end)
            end
        end
    end
end)

-- Misc Tab
createToggle(tabContainers["Misc"], "Godmode", function(enabled)
    if godmodeConnection then godmodeConnection:Disconnect() end
    if enabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            godmodeConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                humanoid.Health = math.huge
            end)
        end
    end
end)
createToggle(tabContainers["Misc"], "AntiAFK", function(enabled)
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    if enabled then
        antiAFKConnection = RunService.Heartbeat:Connect(function()
            wait(60) -- Every minute
            LocalPlayer.Character.Humanoid:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
        end)
    end
end)
createToggle(tabContainers["Misc"], "UnlockAll", function(enabled)
    if enabled then
        -- Simulate unlock (adjust for Evade's ReplicatedStorage events)
        for _, item in pairs(ReplicatedStorage:WaitForChild("Items"):GetChildren()) do
            local args = {item.Name, true}
            ReplicatedStorage:WaitForChild("UnlockEvent"):FireServer(unpack(args)) -- Hypothetical, adjust if real event exists
        end
    end
end)
-- Teleport to Player (Dropdown-like)
local TeleportFrame = Instance.new("Frame")
TeleportFrame.Parent = tabContainers["Misc"]
TeleportFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TeleportFrame.Size = UDim2.new(1, -10, 0, 40)
local TeleportLabel = Instance.new("TextLabel")
TeleportLabel.Parent = TeleportFrame
TeleportLabel.Text = "Teleport to:"
TeleportLabel.Position = UDim2.new(0, 10, 0, 0)
TeleportLabel.Size = UDim2.new(0.5, 0, 1, 0)
TeleportLabel.BackgroundTransparency = 1
TeleportLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
local TeleportDropdown = Instance.new("TextButton")
TeleportDropdown.Parent = TeleportFrame
TeleportDropdown.Position = UDim2.new(0.5, 0, 0, 5)
TeleportDropdown.Size = UDim2.new(0.5, -10, 0, 30)
TeleportDropdown.Text = "Select Player"
TeleportDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
TeleportDropdown.MouseButton1Click:Connect(function()
    -- Simple teleport to random or first player for demo; expand to full dropdown if needed
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            break
        end
    end
end)
-- Update Canvas Sizes
for _, container in pairs(tabContainers) do
    local layout = container:FindFirstChildOfClass("UIListLayout")
    container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end
-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    local humanoid = character:WaitForChild("Humanoid")
    if toggles.Speed then humanoid.WalkSpeed = values.Speed end
    if toggles.JumpPower then humanoid.JumpPower = values.JumpPower end
    if toggles.Godmode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
    if toggles.NoClip then
        noClipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
    if toggles.ESP then
        -- Reapply ESP
    end
    if toggles.InfiniteStamina then
        -- Reapply
    end
end)
-- Players added for ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if toggles.ESP then
            local highlight = Instance.new("Highlight")
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            espHighlights[player] = highlight
        end
    end)
end)
-- Workspace children added for dynamic ESP/AutoFarm
Workspace.ChildAdded:Connect(function(child)
    if toggles.ESP and (child.Name:match("Orb") or child.Name:match("Coin") or child.Name:match("Bot") or child.Name:match("Monster")) then
        local highlight = Instance.new("Highlight")
        highlight.Parent = child
        highlight.FillColor = child.Name:match("Orb") and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 165, 0)
        highlight.FillTransparency = 0.5
        espHighlights[child] = highlight
    end
end)
print("✅ Evade Ultimate Script V2 Loaded! GUI apareceu automaticamente.")
