-- Rally Rush V1 on-screen messages. Put this complete file in a LocalScript.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("RallyRushUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "RallyRushHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "MessagePanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0.04, 0)
panel.Size = UDim2.new(0.8, 0, 0, 112)
panel.BackgroundColor3 = Color3.fromRGB(38, 69, 140)
panel.BackgroundTransparency = 0.08
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.new(0, 12, 0, 8)
title.Size = UDim2.new(1, -24, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Text = "RALLY RUSH!"
title.Parent = panel

local detail = Instance.new("TextLabel")
detail.Name = "Detail"
detail.Position = UDim2.new(0, 14, 0, 52)
detail.Size = UDim2.new(1, -28, 0, 48)
detail.BackgroundTransparency = 1
detail.Font = Enum.Font.Gotham
detail.TextColor3 = Color3.fromRGB(235, 244, 255)
detail.TextScaled = true
detail.TextWrapped = true
detail.Text = "Step onto the blue start platform to begin."
detail.Parent = panel

local messageNumber = 0
event.OnClientEvent:Connect(function(newTitle, newDetail, seconds)
	messageNumber += 1
	local thisMessage = messageNumber
	title.Text = tostring(newTitle or "Rally Rush")
	detail.Text = tostring(newDetail or "")
	panel.Visible = true
	task.delay(tonumber(seconds) or 4, function()
		if messageNumber == thisMessage then
			panel.Visible = false
		end
	end)
end)
