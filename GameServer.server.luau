-- Rally Rush V1: a simple, server-built checkpoint race.
-- All course parts, race state, leaderstats, and the HUD message event are
-- created by this script. No Toolbox assets are used.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local COURSE_NAME = "RallyRushCourse"
local EVENT_NAME = "RallyRushUpdate"
local CHECKPOINT_COUNT = 4
local BOOST_SPEED = 28
local BOOST_SECONDS = 3

local oldCourse = workspace:FindFirstChild(COURSE_NAME)
if oldCourse then
	oldCourse:Destroy()
end

local course = Instance.new("Folder")
course.Name = COURSE_NAME
course.Parent = workspace

local event = ReplicatedStorage:FindFirstChild(EVENT_NAME)
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = EVENT_NAME
	event.Parent = ReplicatedStorage
end

local function makePart(name, size, position, color, material, anchored, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = anchored ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent or course
	return part
end

local ground = makePart("Raceway", Vector3.new(42, 1, 190), Vector3.new(0, 0, 65), Color3.fromRGB(75, 170, 105), Enum.Material.Grass)
ground:SetAttribute("RallyRushGenerated", true)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "RallyRushSpawn"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 2, -24)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(65, 190, 255)
spawn.Material = Enum.Material.SmoothPlastic
spawn.Parent = course

-- A straight, colorful course with a clear starting platform and finish arch.
makePart("StartPlatform", Vector3.new(28, 1, 16), Vector3.new(0, 1, -20), Color3.fromRGB(65, 190, 255))
makePart("StartLine", Vector3.new(28, 0.3, 2), Vector3.new(0, 1.65, -12), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
makePart("FinishPlatform", Vector3.new(28, 1, 16), Vector3.new(0, 1, 150), Color3.fromRGB(255, 205, 70))
makePart("FinishLine", Vector3.new(28, 0.3, 2), Vector3.new(0, 1.65, 143), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
makePart("FinishLeftPost", Vector3.new(2, 12, 2), Vector3.new(-13, 7, 143), Color3.fromRGB(255, 115, 85))
makePart("FinishRightPost", Vector3.new(2, 12, 2), Vector3.new(13, 7, 143), Color3.fromRGB(255, 115, 85))
makePart("FinishTop", Vector3.new(28, 2, 2), Vector3.new(0, 13, 143), Color3.fromRGB(255, 115, 85))

for side = -1, 1, 2 do
	makePart("CourseRail", Vector3.new(2, 5, 166), Vector3.new(side * 21, 3, 65), Color3.fromRGB(80, 115, 210))
end

local checkpoints = {}
for index = 1, CHECKPOINT_COUNT do
	local z = 15 + (index - 1) * 27
	local gate = makePart("Checkpoint" .. index, Vector3.new(28, 0.5, 2), Vector3.new(0, 1.8, z), Color3.fromRGB(95, 235, 180), Enum.Material.Neon)
	gate.Transparency = 0.2
	gate.CanCollide = false
	gate:SetAttribute("CheckpointNumber", index)
	checkpoints[index] = gate
	-- Small side markers make each checkpoint easy to spot.
	for side = -1, 1, 2 do
		makePart("CheckpointMarker", Vector3.new(1.5, 5, 1.5), Vector3.new(side * 14, 3.5, z), Color3.fromRGB(95, 235, 180), Enum.Material.Neon)
	end
end

local boostPads = {}
for index, z in ipairs({ 28, 82, 123 }) do
	local pad = makePart("BoostPad" .. index, Vector3.new(8, 0.35, 6), Vector3.new(0, 1.7, z), Color3.fromRGB(255, 115, 220), Enum.Material.Neon)
	pad.CanCollide = true
	boostPads[#boostPads + 1] = pad
end

local states = {}
local lastBoost = {}

local function send(player, title, detail, seconds)
	if player and player.Parent == Players then
		event:FireClient(player, title, detail or "", seconds or 0)
	end
end

local function sendAll(title, detail, seconds)
	event:FireAllClients(title, detail or "", seconds or 0)
end

local function getPlayerFromHit(hit)
	local character = hit and hit:FindFirstAncestorOfClass("Model")
	if not character then return nil end
	return Players:GetPlayerFromCharacter(character)
end

local function getStats(player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return nil end
	return stats:FindFirstChild("Wins"), stats:FindFirstChild("BestTime")
end

local function resetRace(player)
	states[player] = nil
	player:SetAttribute("RallyRushCheckpoint", 0)
	player:SetAttribute("RallyRushRacing", false)
end

local function beginRace(player)
	local now = workspace:GetServerTimeNow()
	states[player] = { startedAt = now, nextCheckpoint = 1 }
	player:SetAttribute("RallyRushCheckpoint", 0)
	player:SetAttribute("RallyRushRacing", true)
	send(player, "Race started!", "Run through all 4 green checkpoints, then reach the finish!", 4)
end

local function onCharacterAdded(player, character)
	resetRace(player)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.Died:Connect(function()
			if states[player] then
				resetRace(player)
				send(player, "You're out!", "No worries—try the course again.", 4)
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats

	local bestTime = Instance.new("NumberValue")
	bestTime.Name = "BestTime"
	bestTime.Value = 0
	bestTime.Parent = leaderstats
	bestTime:SetAttribute("DisplayName", "Best Time (s)")

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then onCharacterAdded(player, player.Character) end
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
	lastBoost[player] = nil
end)

local startDebounce = {}
local startTrigger = makePart("StartTrigger", Vector3.new(30, 8, 3), Vector3.new(0, 4, -12), Color3.new(1, 1, 1))
startTrigger.Transparency = 1
startTrigger.CanCollide = false
startTrigger.CanTouch = true
startTrigger.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if not player or states[player] or startDebounce[player] then return end
	startDebounce[player] = true
	task.delay(1, function() startDebounce[player] = nil end)
	beginRace(player)
end)

for index, gate in ipairs(checkpoints) do
	local gateDebounce = {}
	gate.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		local state = player and states[player]
		if not state or state.nextCheckpoint ~= index or gateDebounce[player] then return end
		gateDebounce[player] = true
		task.delay(0.7, function() gateDebounce[player] = nil end)
		state.nextCheckpoint += 1
		player:SetAttribute("RallyRushCheckpoint", index)
		send(player, "Checkpoint " .. index .. " of " .. CHECKPOINT_COUNT, "Keep going!", 2)
	end)
end

local finishDebounce = {}
local finishTrigger = makePart("FinishTrigger", Vector3.new(30, 10, 4), Vector3.new(0, 5, 143), Color3.new(1, 1, 1))
finishTrigger.Transparency = 1
finishTrigger.CanCollide = false
finishTrigger.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	local state = player and states[player]
	if not state or state.nextCheckpoint <= CHECKPOINT_COUNT or finishDebounce[player] then return end
	finishDebounce[player] = true
	local elapsed = math.max(0, workspace:GetServerTimeNow() - state.startedAt)
	local wins, bestTime = getStats(player)
	if wins then wins.Value += 1 end
	if bestTime and (bestTime.Value == 0 or elapsed < bestTime.Value) then
		bestTime.Value = math.floor(elapsed * 100 + 0.5) / 100
	end
	resetRace(player)
	send(player, "You finished!", string.format("Time: %.2f seconds — run again to beat your best!", elapsed), 6)
	task.delay(2, function() finishDebounce[player] = nil end)
end)

for _, pad in ipairs(boostPads) do
	local padDebounce = {}
	pad.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)
		if not player or padDebounce[player] then return end
		padDebounce[player] = true
		task.delay(1, function() padDebounce[player] = nil end)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		local previousSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = math.max(previousSpeed, BOOST_SPEED)
		send(player, "Speed boost!", "Zoom ahead for 3 seconds!", 2)
		task.delay(BOOST_SECONDS, function()
			if humanoid.Parent and humanoid.Health > 0 then
				humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, previousSpeed)
			end
		end)
	end)
end

-- Spawn a friendly sign at the start. Players can walk through it.
local sign = makePart("WelcomeSign", Vector3.new(20, 8, 1), Vector3.new(0, 6, -32), Color3.fromRGB(40, 80, 160))
sign.CanCollide = false
local surface = Instance.new("SurfaceGui")
surface.Face = Enum.NormalId.Front
surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surface.PixelsPerStud = 45
surface.Parent = sign
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "RALLY RUSH!\nTouch the start line, hit every green checkpoint, then race to the finish!"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = surface

sendAll("Welcome to Rally Rush!", "Step onto the blue start platform to begin.", 6)
