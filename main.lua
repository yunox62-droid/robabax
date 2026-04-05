local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinalTrueModMenu"
screenGui.ResetOnSpawn = false

local successGui, errGui = pcall(function()
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end)
if not successGui then screenGui.Parent = script.Parent end

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
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
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

local function createModButton(text, yOffset)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 40)
	btn.Position = UDim2.new(0.05, 0, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Parent = mainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn
	return btn
end

local btnWH = createModButton("WallHack: ВЫКЛ", 50)
local btnGod = createModButton("Immortality: ВЫКЛ", 100)
local btnFly = createModButton("Fly: ВЫКЛ", 150)
local btnBoost = createModButton("Boost Up 🚀", 200)
btnBoost.BackgroundColor3 = Color3.fromRGB(50, 150, 250)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
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

local whRadius = 150
local highlights = {}
local bodyGyro, bodyVelocity
local flySpeed = 50

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart", 5)
local humanoid = character:WaitForChild("Humanoid", 5)

local savedCFrame = nil
local flyPart = nil
local godRenderConnection = nil

localPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart", 5)
	humanoid = newChar:WaitForChild("Humanoid", 5)
	
	if flyEnabled then
		flyEnabled = false
		toggleColor(btnFly, false, "Fly: ВКЛ", "Fly: ВЫКЛ")
	end
	if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
	if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	
	if godEnabled then
		godEnabled = false
		toggleColor(btnGod, false, "Immortality: ВКЛ", "Immortality: ВЫКЛ")
	end
	if godRenderConnection then godRenderConnection:Disconnect(); godRenderConnection = nil end
	if flyPart then flyPart:Destroy(); flyPart = nil end
	
	if hrp then hrp.Anchored = false end
	if humanoid then humanoid.PlatformStand = false end
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

Players.PlayerRemoving:Connect(function(player)
	if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
end)

task.spawn(function()
	while true do pcall(updateWH); task.wait(0.5) end
end)

btnGod.MouseButton1Click:Connect(function()
	if not hrp or not humanoid then return end
	godEnabled = not godEnabled
	toggleColor(btnGod, godEnabled, "Immortality: ВКЛ", "Immortality: ВЫКЛ")
	
	if godEnabled then
		savedCFrame = hrp.CFrame
		hrp.Anchored = true
		humanoid.PlatformStand = true 
		
		flyPart = Instance.new("Part")
		flyPart.Size = Vector3.new(2, 2, 1)
		flyPart.CFrame = savedCFrame
		flyPart.Anchored = true
		flyPart.CanCollide = false
		flyPart.Transparency = 1 
		flyPart.Parent = workspace
		
		local cam = workspace.CurrentCamera
		cam.CameraSubject = flyPart
		
		godRenderConnection = RunService.RenderStepped:Connect(function(deltaTime)
			local cam = workspace.CurrentCamera
			local moveDirection = Vector3.new(0, 0, 0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end
			
			if moveDirection.Magnitude > 0 then
				flyPart.CFrame = flyPart.CFrame + (moveDirection.Unit * flySpeed * deltaTime)
			end
		end)
		
	else
		if godRenderConnection then godRenderConnection:Disconnect(); godRenderConnection = nil end
		if flyPart then flyPart:Destroy(); flyPart = nil end
		
		local cam = workspace.CurrentCamera
		cam.CameraSubject = humanoid
		
		humanoid.PlatformStand = false
		hrp.Anchored = false
		hrp.CFrame = savedCFrame
	end
end)

btnFly.MouseButton1Click:Connect(function()
	if not hrp or not humanoid then return end
	flyEnabled = not flyEnabled
	toggleColor(btnFly, flyEnabled, "Fly: ВКЛ", "Fly: ВЫКЛ")
	
	if flyEnabled then
		humanoid.PlatformStand = true
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp
		
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
		bodyVelocity.Parent = hrp
	else
		humanoid.PlatformStand = false
		if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
		if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	end
end)

RunService.RenderStepped:Connect(function()
	if flyEnabled and hrp and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera
		local moveDirection = Vector3.new(0,0,0)
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0,1,0) end
		
		bodyGyro.CFrame = cam.CFrame
		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0,0,0)
		end
	end
end)

btnBoost.MouseButton1Click:Connect(function()
	if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 200, 0) end
end)
