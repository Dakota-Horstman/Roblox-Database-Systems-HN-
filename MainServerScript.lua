local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEventsFolder")
		local Event = {}
		for i, v in pairs(RemoteEventsFolder:GetChildren()) do
			Event[v.Name] = v
		end
	local RemoteFunctionsFolder = ReplicatedStorage:WaitForChild("RemoteFunctionsFolder")
		local Function = {}
		for i, v in pairs(RemoteFunctionsFolder:GetChildren()) do
			Function[v.Name] = v
		end
local ServerStorage = game:GetService("ServerStorage")
	local GameSettings = ServerStorage:WaitForChild("GameSettings")
local ModuleScript = {}
for i, v in pairs(script:GetChildren()) do
	ModuleScript[v.Name] = v
end

GameSettings["LeaderboardEnabled"].Changed:Connect(function()
	for i, Player in pairs(Players:GetPlayers()) do
		require(ModuleScript["MapControls"]):CheckSettings(Player)
	end
end)
Event["AlertPlayer"].OnServerEvent:Connect(function(Player, Map, MapDescription)
	require(ModuleScript["MapControls"]):LoadMap(Player, Map, MapDescription)
end)
Event["CharacterReady"].OnServerEvent:Connect(function(Player)
	require(ModuleScript["MapControls"]):CheckSettings(Player)
end)
Event["PlayerDied"].OnServerEvent:Connect(function(Player)
	require(ModuleScript["PlayerManager"]):UpdateLeaderboard(Player)
end)
Event["HandleHostInteraction"].OnServerEvent:Connect(function(Player, Setting)
	require(ModuleScript["MapControls"]):HostInteraction(Setting)
end)
Function["SetServerSetting"].OnServerInvoke = function(Player, Setting, Value)
	return require(ModuleScript["MapControls"]):SetSetting(Setting, Value)
end
Function["HandleServerData"].OnServerInvoke = function(Player, Identification)
	local Setting = GameSettings:FindFirstChild(Identification)
	if Setting then return Setting.Value end
end
game:GetService("Players").PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(Message)
		require(ModuleScript["HandleMainChat"]):Chatted(Player, Message)
	end)
	require(ModuleScript["PlayerManager"]):Setup(Player)
end)
game:GetService("Players").PlayerRemoving:Connect(function(Player)
	require(ModuleScript["PlayerManager"]):Remove(Player)
end)
workspace:WaitForChild("ChosenMap").ChildAdded:Connect(function()
	print("Child added")
	GameSettings["LeaderboardEnabled"].Value = true
end)
workspace:WaitForChild("ChosenMap").ChildRemoved:Connect(function()
	GameSettings["LeaderboardEnabled"].Value = false
end)
