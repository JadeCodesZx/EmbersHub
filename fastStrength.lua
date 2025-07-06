local player = game.Players.LocalPlayer
local run = false

-- GUI
local screengui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screengui.Name = "AutoRepGui"

local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 160, 0, 60)
frame.Position = UDim2.new(0.5, -80, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, 0, 1, 0)
btn.Text = "Start Auto Rep"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.SourceSans
btn.TextSize = 20

-- Toggle Logic
btn.MouseButton1Click:Connect(function()
	run = not run
	btn.Text = run and "Stop Auto Rep" or "Start Auto Rep"
	if run then
		task.spawn(function()
			while run do
				task.wait(0.01)
				player.muscleEvent:FireServer("rep")
				for _,v in pairs(player.Backpack:GetChildren()) do
					if v.Name == "Weight" then
						v.Parent = player.Character
					end
				end
			end
		end)
	end
end)
