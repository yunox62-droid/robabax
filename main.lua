local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrueModMenu_V13"
screenGui.ResetOnSpawn = false

pcall(function()
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end)

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 50, 0, 50)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Text = "MENU"
openButton.Font = Enum.Font.SourceSansBold
openButton.TextSize = 16
openButton.Parent = screenGui

local uiCornerObj = Instance.new("UICorner")
uiCornerObj.CornerRadius = UDim.new(0, 10)
uiCornerObj.Parent = openButton

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 460) -- Немного увеличил высоту для новой кнопки
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local uiCornerFrame = Instance.new("UICorner")
uiCornerFrame.CornerRadius = UDim.new(0, 15)
uiCornerFrame.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "True Mod Menu"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Parent = mainFrame

local function createModButton(text, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = UDim2.new(0.05, 0, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Parent = mainFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	return btn
end

local function createTextBox(placeholder, yOffset)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.9, 0, 0, 35)
	box.Position = UDim2.new(0.05, 0, 0, yOffset)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.Font = Enum.Font.SourceSansBold
	box.TextSize = 14
	box.Text = ""
	box.Parent = mainFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = box
	return box
end

local btnAim = createModButton("Aim Assist: ВЫКЛ", 50)
local btnWH = createModButton("WallHack: ВЫКЛ", 90)
local btnTpClick = createModButton("Double Tap TP: ВЫКЛ", 130)
local btnInfJump = createModButton("Inf Jump: ВЫКЛ", 170)
local btnNoclip = createModButton("Noclip V2: ВЫКЛ", 210)

local inputSpeed = createTextBox("Введите скорость (Напр. 60)", 260)
local inputJump = createTextBox("Введите силу прыжка (Напр. 100)", 310)

openButton.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
closeButton.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

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

local function toggleColor(btn, state, textOn, textOff)
	if state then btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) btn.Text = textOn
	else btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) btn.Text = textOff end
end

local aimEnabled, whEnabled, tpEnabled, infJumpEnabled, noclipEnabled = false, false, false, false, false
local highlights = {}

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar hrp = newChar:WaitForChild("HumanoidRootPart") humanoid = newChar:WaitForChild("Humanoid")
end)

-- МОДУЛЬ AIM С ПРОВЕРКОЙ СТЕН
btnAim.MouseButton1Click:Connect(function()
	aimEnabled = not aimEnabled
	toggleColor(btnAim, aimEnabled, "Aim Assist: ВКЛ", "Aim Assist: ВЫКЛ")
end)

local function isVisible(targetPart)
	local cam = workspace.CurrentCamera
	if not cam or not hrp then return false end
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	-- Игнорируем в луче себя и фейковые визуальные объекты
	raycastParams.FilterDescendantsInstances = {character, screenGui}
	
	local direction = targetPart.Position - cam.CFrame.Position
	local result = workspace:Raycast(cam.CFrame.Position, direction, raycastParams)
	
	-- Если луч ни обо что не ударился или ударился в самого противника/его части - значит он виден!
	if not result or result.Instance:IsDescendantOf(targetPart.Parent) then
		return true
	end
	return false
end

local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
			if player.Character.Humanoid.Health > 0 then
				local head = player.Character.Head
				local dist = (hrp.Position - head.Position).Magnitude
				
				if dist < shortestDistance then
					-- Делаем проверку на видимость только для самого близкого найденного, чтобы не лагало
					if isVisible(head) then
						closestPlayer = player
						shortestDistance = dist
					end
				end
			end
		end
	end
	return closestPlayer
end

RunService.RenderStepped:Connect(function()
	if aimEnabled and character and humanoid and humanoid.Health > 0 then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local cam = workspace.CurrentCamera
			local head = target.Character.Head
			
			-- Плавная доводка (smoothness). 0.15 - чем меньше, тем плавнее наводка.
			local targetCFrame = CFrame.new(cam.CFrame.Position, head.Position)
			cam.CFrame = cam.CFrame:Lerp(targetCFrame, 0.15)
		end
	end
end)

-- Double Tap TP
local lastClickTime = 0
btnTpClick.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	toggleColor(btnTpClick, tpEnabled, "Double Tap TP: ВКЛ", "Double Tap TP: ВЫКЛ")
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
	toggleColor(btnInfJump, infJumpEnabled, "Inf Jump: ВКЛ", "Inf Jump: ВЫКЛ")
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Noclip V2
btnNoclip.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	toggleColor(btnNoclip, noclipEnabled, "Noclip V2: ВКЛ", "Noclip V2: ВЫКЛ")
end)

RunService.RenderStepped:Connect(function(deltaTime)
	if noclipEnabled and character and hrp and humanoid then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
		
		if humanoid.MoveDirection.Magnitude > 0 then
			local speedToUse = humanoid.WalkSpeed
			hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * speedToUse * deltaTime)
		end
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
	toggleColor(btnWH, whEnabled, "WallHack: ВКЛ", "WallHack: ВЫКЛ")
	if not whEnabled then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
		end
	end
end)

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
