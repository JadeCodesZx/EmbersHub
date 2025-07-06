local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local autoRebirth = false

-- GUI Creation
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "AutoRebirthGUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 150, 0, 50)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.Text = "AutoRebirth: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

-- Toggle Logic
local function toggleAutoRebirth(state)
	autoRebirth = state
	if state then
		toggleBtn.Text = "AutoRebirth: ON"
		task.spawn(function()
			while autoRebirth do
				local rebirths = LocalPlayer.leaderstats.Rebirths.Value
				local requiredStrength = 10000 + (5000 * rebirths)

				local goldenRebirth = LocalPlayer:FindFirstChild("ultimatesFolder") and LocalPlayer.ultimatesFolder:FindFirstChild("Golden Rebirth")
				if goldenRebirth then
					requiredStrength = math.floor(requiredStrength * (1 - goldenRebirth.Value * 0.1))
				end

				local function unequipAllPets()
					local petFolder = LocalPlayer:FindFirstChild("petsFolder")
					if petFolder then
						for _, h in pairs(petFolder:GetChildren()) do
							if h:IsA("Folder") then
								for _, j in pairs(h:GetChildren()) do
									ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", j)
								end
							end
						end
					end
					task.wait(0.1)
				end

				local function equipPet(name)
					unequipAllPets()
					task.wait(0.01)
					for _, pet in pairs(LocalPlayer.petsFolder.Unique:GetChildren()) do
						if pet.Name == name then
							ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
						end
					end
				end

				local function getMachine(name)
					local machine = workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild(name)
					if not machine then
						for _, folder in pairs(workspace:GetChildren()) do
							if folder:IsA("Folder") and folder.Name:lower():find("machines") then
								machine = folder:FindFirstChild(name)
								if machine then break end
							end
						end
					end
					return machine
				end

				local function interact()
					VirtualInputManager:SendKeyEvent(true, "E", false, game)
					task.wait(0.1)
					VirtualInputManager:SendKeyEvent(false, "E", false, game)
				end

				equipPet("Swift Samurai")
				while LocalPlayer.leaderstats.Strength.Value < requiredStrength do
					for _ = 1, 10 do
						LocalPlayer.muscleEvent:FireServer("rep")
					end
					task.wait()
				end

				equipPet("Tribal Overlord")
				local machine = getMachine("Jungle Bar Lift")
				if machine and machine:FindFirstChild("interactSeat") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = machine.interactSeat.CFrame * CFrame.new(0, 3, 0)
					repeat task.wait(0.1) interact() until LocalPlayer.Character.Humanoid.Sit
				end

				local beforeRebirth = LocalPlayer.leaderstats.Rebirths.Value
				repeat
					ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
					task.wait(0.1)
				until LocalPlayer.leaderstats.Rebirths.Value > beforeRebirth

				task.wait()
			end
		end)
	else
		toggleBtn.Text = "AutoRebirth: OFF"
	end
end

-- Button event
toggleBtn.MouseButton1Click:Connect(function()
	toggleAutoRebirth(not autoRebirth)
end)
