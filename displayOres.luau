if _G.SCRIPTLOADED then
	_G.SCRIPTLOADED:Destroy()
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local rareOreSpawn = game:GetService("ReplicatedStorage").SFX.Rare_Ore_Spawn
local oresSpawned = {}
local ores = workspace.Ores
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = HttpService:GenerateGUID(false)
gui.Parent = CoreGui

local labelModel = Instance.new("TextLabel")
labelModel.TextScaled = true
labelModel.Font = Enum.Font.SourceSans
labelModel.TextColor3 = Color3.new(1, 1, 1)
labelModel.TextStrokeTransparency = 0
labelModel.TextStrokeColor3 = Color3.new(0, 0, 0)
labelModel.BackgroundTransparency = 1
labelModel.Size = UDim2.fromScale(1, 0.02)
labelModel.TextXAlignment = Enum.TextXAlignment.Right

local function updateLabels()
	for ore, amount in oresSpawned do
		if amount <= 0 then
			gui:FindFirstChild(ore):Destroy()
			continue
		end

		local newLabel = gui:FindFirstChild(ore)
		
		if not newLabel then
			newLabel = labelModel:Clone()
			newLabel.Name = ore
			newLabel.Parent = gui
		end

		newLabel.Text = `{ore} x{amount}`

		if tonumber(ore) ~= nil then
			local sfx = rareOreSpawn:Clone()
			newLabel.TextColor3 = Color3.new(1, 1, 0)
			sfx.Parent = player
			sfx:Play()
			task.delay(1, function()
				sfx:Destroy()
			end)
		end
	end
end

for _, ore in ores:GetChildren() do
	if not oresSpawned[ore.Name] then
		oresSpawned[ore.Name] = 0
	end

	oresSpawned[ore.Name] += 1
end

local addConnection = ores.ChildAdded:Connect(function(ore)
	oresSpawned[ore.Name] += 1
	updateLabels()
end)

local removeConnection = ores.ChildRemoved:Connect(function(ore)
	oresSpawned[ore.Name] -= 1
	updateLabels()
end)

updateLabels()

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.Name
layout.Parent = gui

_G.SCRIPTLOADED = {}

function _G.SCRIPTLOADED:Destroy()
	addConnection:Disconnect()
	removeConnection:Disconnect()
	gui:Destroy()
end	
