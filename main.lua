local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrueModMenu_V4"
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
mainFrame.Size = UDim2.new(0, 250, 0, 420)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -210)
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

local btnWH = createModButton("WallHack: ВЫКЛ", 50)
local btnGod = createModButton("Immortality: ВЫКЛ", 90)
local btnFly = createModButton("Fly: ВЫКЛ", 130)
local btnNoclip = createModButton("Noclip: ВЫКЛ", 170)
local btnBoost = createModButton("Boost Up 🚀", 210)
btnBoost.BackgroundColor3 = Color3.fromRGB(50, 150, 250)

local inputSpeed = createTextBox("Введите скорость (По умолчанию 16)", 260)
local inputJump = createTextBox("Введите силу прыжка (По умолчанию 50)", 310)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

local dragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function toggleColor(btn, state, textOn, textOff)
	if state then
		btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		btn.Text = textOn
	else
		btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		btn.Text = textOff
	end
end

local whEnabled = false
local godEnabled = false
local flyEnabled = false
local noclipEnabled = false

local whRadius = 150
local highlights = {}
local flySpeed = 50
local flyUp = false
local flyDown = false

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
	humanoid = newChar:WaitForChild("Humanoid")
	if noclipEnabled then noclipEnabled = false; toggleColor(btnNoclip, false, "Noclip: ВКЛ", "Noclip: ВЫКЛ") end
	if flyEnabled then flyEnabled = false; toggleColor(btnFly, false, "Fly: ВКЛ", "Fly: ВЫКЛ") end
	if godEnabled then godEnabled = false; toggleColor(btnGod, false, "Immortality: ВКЛ", "Immortality: ВЫКЛ") end
end)

local function updateWH()
	if not whEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player == localPlayer then continue end
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") and hrp then
			local dist = (char.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist <= whRadius then
				if not highlights[player] or highlights[player].Parent ~= char then
					pcall(function()
						local hl = Instance.new("Highlight")
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.Parent = char
						highlights[player] = hl
					end)
				end
			else
				if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
			end
		end
	end
end

btnWH.MouseButton1Click:Connect(function()
	whEnabled = not whEnabled
	toggleColor(btnWH, whEnabled, "WallHack: ВКЛ", "WallHack: ВЫКЛ")
	if not whEnabled then
		for p, h in pairs(highlights) do pcall(function() h:Destroy() end) end
		table.clear(highlights)
	end
end)

task.spawn(function()
	while true do 
		pcall(updateWH)
		task.wait(0.5) 
	end
end)

local godConnection = nil
btnGod.MouseButton1Click:Connect(function()
	if not humanoid then return end
	godEnabled = not godEnabled
	toggleColor(btnGod, godEnabled, "Immortality: ВКЛ", "Immortality: ВЫКЛ")
	
	if godEnabled then
		humanoid.Health = humanoid.MaxHealth
		godConnection = humanoid.HealthChanged:Connect(function(health)
			if godEnabled and health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	else
		if godConnection then godConnection:Disconnect(); godConnection = nil end
	end
end)

local upBtn = Instance.new("TextButton")
local downBtn = Instance.new("TextButton")

upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(1, -50, 0.5, -45)
upBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
upBtn.TextColor3 = Color3.fromRGB(255,255,255)
upBtn.Text = "▲"
upBtn.Font = Enum.Font.SourceSansBold
upBtn.TextSize = 20
upBtn.Visible = false
upBtn.Parent = screenGui
local c1 = Instance.new("UICorner") c1.CornerRadius = UDim.new(0, 8) c1.Parent = upBtn

downBtn.Size = UDim2.new(0, 40, 0, 40)
downBtn.Position = UDim2.new(1, -50, 0.5, 5)
downBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
downBtn.TextColor3 = Color3.fromRGB(255,255,255)
downBtn.Text = "▼"
downBtn.Font = Enum.Font.SourceSansBold
downBtn.TextSize = 20
downBtn.Visible = false
downBtn.Parent = screenGui
local c2 = Instance.new("UICorner") c2.CornerRadius = UDim.new(0, 8) c2.Parent = downBtn

upBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then flyUp = true end end)
upBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then flyUp = false end end)
downBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then flyDown = true end end)
downBtn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then flyDown = false end end)

local bv, bg
btnFly.MouseButton1Click:Connect(function()
	if not hrp then return end
	flyEnabled = not flyEnabled
	toggleColor(btnFly, flyEnabled, "Fly: ВКЛ", "Fly: ВЫКЛ")
	
	upBtn.Visible = flyEnabled
	downBtn.Visible = flyEnabled
	
	if flyEnabled then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.Velocity = Vector3.new(0,0,0)
		bv.Parent = hrp
		
		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp
		
		humanoid.PlatformStand = true
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		humanoid.PlatformStand = false
	end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled and hrp and bv and bg then
		local cam = workspace.CurrentCamera
		local moveDirection = humanoid.MoveDirection
		bg.CFrame = cam.CFrame
		
		local velocity = moveDirection * flySpeed
		local verticalSpeed = 0
		if flyUp then verticalSpeed = flySpeed end
		if flyDown then verticalSpeed = -flySpeed end
		
		bv.Velocity = Vector3.new(velocity.X, verticalSpeed, velocity.Z)
	end
end)

btnBoost.MouseButton1Click:Connect(function()
	if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 100, 0) end
end)

btnNoclip.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	toggleColor(btnNoclip, noclipEnabled, "Noclip: ВКЛ", "Noclip: ВЫКЛ")
end)

RunService.RenderStepped:Connect(function()
	if noclipEnabled and character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
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
		if num then
			humanoid.UseJumpPower = true
			humanoid.JumpPower = num
		end
	end
end)
