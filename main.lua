local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Защита от дублирования интерфейса
if game:GetService("CoreGui"):FindFirstChild("TruePremiumMenu") then
	game:GetService("CoreGui").TruePremiumMenu:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TruePremiumMenu"
screenGui.ResetOnSpawn = false
pcall(function()
	screenGui.Parent = game:GetService("CoreGui") -- Пытаемся засунуть в CoreGui, чтобы админы не видели в PlayerGui
end)
if not screenGui.Parent then
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

-- ================= КНОПКА-ЗНАЧОК (ПЕРЕТАСКИВАЕМАЯ) =================
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 50, 0, 50)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
openButton.TextColor3 = Color3.fromRGB(0, 255, 150)
openButton.Text = "⚡"
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 22
openButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 25) -- Круглая
btnCorner.Parent = openButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 255, 150)
btnStroke.Thickness = 2
btnStroke.Parent = openButton

-- Логика перетаскивания иконки (для мобилок и ПК)
local iconDragging, iconDragStart, iconStartPos
openButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		iconDragging = true
		iconDragStart = input.Position
		iconStartPos = openButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then iconDragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - iconDragStart
		openButton.Position = UDim2.new(iconStartPos.X.Scale, iconStartPos.X.Offset + delta.X, iconStartPos.Y.Scale, iconStartPos.Y.Offset + delta.Y)
	end
end)

-- ================= КРАСИВОЕ ОСНОВНОЕ МЕНЮ =================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 480)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 255, 150)
frameStroke.Thickness = 1.5
frameStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "PREMIUM MENU"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame

local function createModButton(text, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = UDim2.new(0.05, 0, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Parent = mainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 60)
	stroke.Thickness = 1
	stroke.Parent = btn
	
	return btn, stroke
end

local function createTextBox(placeholder, yOffset)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.9, 0, 0, 35)
	box.Position = UDim2.new(0.05, 0, 0, yOffset)
	box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 12
	box.Text = ""
	box.Parent = mainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = box
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 50)
	stroke.Thickness = 1
	stroke.Parent = box
	
	return box
end

-- Создаем кнопки и поля
local btnWH, strWH = createModButton("WallHack: ВЫКЛ", 60)
local btnHitbox, strHitbox = createModButton("Big Hitboxes: ВЫКЛ", 105)
local btnFly, strFly = createModButton("Fly Mode: ВЫКЛ", 150)
local btnTpClick, strTpClick = createModButton("Double Tap TP: ВЫКЛ", 195)
local btnInfJump, strInfJump = createModButton("Inf Jump: ВЫКЛ", 240)
local btnNoclip, strNoclip = createModButton("Noclip V3: ВЫКЛ", 285)

local inputFlySpeed = createTextBox("Скорость Полёта (Базово 50)", 335)
local inputSpeed = createTextBox("Скорость бега", 380)
local inputJump = createTextBox("Сила прыжка", 425)

-- Открытие/Закрытие по нажатию на значок
openButton.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
closeButton.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

-- Перетаскивание основного меню
local dragging, dragStart, startPos
titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true dragStart = input.Position startPos = mainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function toggleColor(btn, stroke, state, textOn, textOff)
	if state then 
		btn.BackgroundColor3 = Color3.fromRGB(0, 50, 30)
		btn.TextColor3 = Color3.fromRGB(0, 255, 150)
		stroke.Color = Color3.fromRGB(0, 255, 150)
		btn.Text = textOn
	else 
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		stroke.Color = Color3.fromRGB(50, 50, 60)
		btn.Text = textOff 
	end
end

local whEnabled, hitboxEnabled, flyEnabled, tpEnabled, infJumpEnabled, noclipEnabled = false, false, false, false, false, false
local flySpeed = 50

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar hrp = newChar:WaitForChild("HumanoidRootPart") humanoid = newChar:WaitForChild("Humanoid")
end)

-- 🎯 HITBOXES (Большие головы)
btnHitbox.MouseButton1Click:Connect(function()
	hitboxEnabled = not hitboxEnabled
	toggleColor(btnHitbox, strHitbox, hitboxEnabled, "Big Hitboxes: ВКЛ", "Big Hitboxes: ВЫКЛ")
end)

task.spawn(function()
	while true do
		if hitboxEnabled then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
					local head = player.Character.Head
					head.Size = Vector3.new(4, 4, 4) -- Увеличиваем в 4 раза
					head.Transparency = 0.5 -- Делаем полупрозрачными, чтобы видеть куда стрелять
					head.CanCollide = false
				end
			end
		else
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
					local head = player.Character.Head
					head.Size = Vector3.new(2, 1, 1) -- Возвращаем стандарт
					head.Transparency = 0
				end
			end
		end
		task.wait(1)
	end
end)

-- 🚀 FLY MODE СО СКОРОСТЬЮ
btnFly.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	toggleColor(btnFly, strFly, flyEnabled, "Fly Mode: ВКЛ", "Fly Mode: ВЫКЛ")
	
	if flyEnabled then
		local bv = Instance.new("BodyVelocity", hrp)
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Name = "FlyVelocity"
		
		local bg = Instance.new("BodyGyro", hrp)
		bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bg.CFrame = hrp.CFrame
		bg.Name = "FlyGyro"
		
		task.spawn(function()
			while flyEnabled and hrp and humanoid do
				local cam = workspace.CurrentCamera
				local moveDir = humanoid.MoveDirection
				
				if moveDir.Magnitude > 0 then
					bv.Velocity = moveDir * flySpeed
				else
					bv.Velocity = Vector3.new(0, 0, 0)
				end
				
				bg.CFrame = cam.CFrame
				task.wait()
			end
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end)
	end
end)

inputFlySpeed.FocusLost:Connect(function()
	local num = tonumber(inputFlySpeed.Text)
	if num then flySpeed = num end
end)

-- Double Tap TP
local lastClickTime = 0
btnTpClick.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	toggleColor(btnTpClick, strTpClick, tpEnabled, "Double Tap TP: ВКЛ", "Double Tap TP: ВЫКЛ")
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if tpEnabled and not processed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		local currentTime = tick()
		if currentTime - lastClickTime < 0.3 then
			local cam = workspace.CurrentCamera
			local unitRay = cam:ScreenPointToRay(input.Position.X, input.Position.Y)
			local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
			
			if raycastResult and hrp then
				hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
			end
			lastClickTime = 0
		else
			lastClickTime = currentTime
		end
	end
end)

-- Inf Jump
btnInfJump.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	toggleColor(btnInfJump, strInfJump, infJumpEnabled, "Inf Jump: ВКЛ", "Inf Jump: ВЫКЛ")
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Noclip V3
btnNoclip.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	toggleColor(btnNoclip, strNoclip, noclipEnabled, "Noclip V3: ВКЛ", "Noclip V3: ВЫКЛ")
end)

RunService.RenderStepped:Connect(function()
	if noclipEnabled and character then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	elseif not noclipEnabled and character then
		if humanoid:GetState() == Enum.HumanoidStateType.Physics then humanoid:ChangeState(Enum.HumanoidStateType.Running) end
	end
end)

-- WH
task.spawn(function()
	while true do
		if whEnabled then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character then
					if not player.Character:FindFirstChild("Highlight") then
						pcall(function() Instance.new("Highlight", player.Character) end)
					end
				end
			end
		end
		task.wait(1)
	end
end)

btnWH.MouseButton1Click:Connect(function()
	whEnabled = not whEnabled
	toggleColor(btnWH, strWH, whEnabled, "WallHack: ВКЛ", "WallHack: ВЫКЛ")
	if not whEnabled then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
		end
	end
end)

-- Скорость и прыжки
inputSpeed.FocusLost:Connect(function()
	if humanoid then
		local num = tonumber(inputSpeed.Text)
		if num then humanoid.WalkSpeed = num end
	end
end)

inputJump.FocusLost:Connect(function()
	if humanoid then
		local num = tonumber(inputJump.Text)
		if num then humanoid.UseJumpPower = true humanoid.JumpPower = num end
	end
end)
