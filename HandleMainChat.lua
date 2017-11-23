local Method = {}
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
local ServerScriptService = game:GetService("ServerScriptService")
	local PlayerManager = ServerScriptService:WaitForChild("MainServerScript"):WaitForChild("PlayerManager")
	local MapControls = ServerScriptService:WaitForChild("MainServerScript"):WaitForChild("MapControls")
local ServerStorage = game:GetService("ServerStorage")
	local GameSettings = ServerStorage:WaitForChild("GameSettings")
	local PlayerValuesFolder = ServerStorage:WaitForChild("PlayerValuesFolder")
local ModuleScript = {}
for i, v in pairs(script.Parent:GetChildren()) do
	if v ~= script then
		ModuleScript[v.Name] = v
	end
end
local PlayerDatabase = require(ModuleScript["PlayerDatabase"]):GetDatabase("Global")
local BaseRank = 0

function GetDataFromTable(PlayerData)
	local MessageParts = {}
	for MessagePart in string.gmatch(PlayerData.Loadout, "[%a]+") do
		table.insert(MessageParts, MessagePart)
	end
	return MessageParts[2], MessageParts[4], MessageParts[6] -- Primary, Secondary, Aura
end

function DetermineRankByPoints(RankPoints)
	local function SortTableByID(Num1, Num2)
		return Num1[1] <= Num2[1]
	end
	local Rank = "I | Prospect"
	local RanksByPointsWithIDs = {
		{1, "I | Prospect", Points = 0},
		{2, "II | Occisor", Points = 200},
		{3, "III | Mesorix", Points = 400},
		{4, "IV | Diceptle", Points = 1000},
		{5, "V | Incremn", Points = 1600},
		{6, "M-I | Therist", Points = 2500},
		{7, "M-II | Zeltac", Points = 3600},
		{8, "M-III | Nedole", Points = 4700},
		{9, "M-IV | Hocidem", Points = 5500},
		{10, "M-V | Donari", Points = 7000}
	}
	table.sort(RanksByPointsWithIDs, SortTableByID)
	local LastRankIterated = "I | Prospect"
	for i, TableData in pairs(RanksByPointsWithIDs) do
		if TableData.Points > RankPoints then
			Rank = LastRankIterated
			break
		end
		LastRankIterated = TableData[2]
	end
	return Rank
end

function Method:Chatted(Player, Message)
	wait()
	local MessageParts = {}
	for i in string.gmatch(Message, "[%a%d%p]+") do
		table.insert(MessageParts, i)
	end
	for i = 1, #MessageParts do
		if Player:GetRankInGroup(2697145) >= BaseRank or Player.Name == "Julian_Orteil" then
			if MessageParts[i] == "!Points" then
				if MessageParts[i + 1] == "Retrieve:" then
					if MessageParts[i + 2] == "Me" then
						Event["MessagePlayer"]:FireClient(Player, "{System}: Fetching your data..", Color3.new(0, 170/255, 1))
						local Data = PlayerDatabase:GetAsync(Player.userId)
						if Data.RankPoints then
							Event["MessagePlayer"]:FireClient(Player, "{System}: Your current ranking in HN is: " ..Data.RankPoints.. " [ " ..DetermineRankByPoints(Data.RankPoints).. " ] ", Color3.new(0, 1, 0))
							return true
						else
							Event["MessagePlayer"]:FireClient(Player, "{System}: No data exists", Color3.new(1, 0, 0))
							return false
						end
					end
					local userId
					pcall(function() userId = game:GetService("Players"):GetUserIdFromNameAsync(MessageParts[i + 2]) end)
					if userId then
						Event["MessagePlayer"]:FireClient(Player, "{System}: Fetching data..", Color3.new(0, 170/255, 1))
						local Data = PlayerDatabase:GetAsync(userId)
						PlayerDatabase:SetAsync(userId, Data)
						if Data.RankPoints then
							Event["MessagePlayer"]:FireClient(Player, "{System}: " ..MessageParts[i + 2].. "'s current ranking in HN is: " ..Data.RankPoints.. " [ " ..DetermineRankByPoints(Data.RankPoints).. " ] ", Color3.new(0, 1, 0))
							return true
						else
							Event["MessagePlayer"]:FireClient(Player, "{System}: No data exists", Color3.new(1, 0, 0))
							return false
						end
					else
						Event["MessagePlayer"]:FireClient(Player, "{System}: Please use a valid username", Color3.new(1, 0, 0))
						return false
					end
					Event["MessagePlayer"]:FireClient(Player, "{System}: An unspecified error occured", Color3.new(1, 0, 0))
					return false
				else
					Event["MessagePlayer"]:FireClient(Player, "{System}: Please use this format: !Points Retrieve: [Username/Me]", Color3.new(1, 0, 0))
					return false
				end
			elseif MessageParts[i] == "!Points:" then
				Event["MessagePlayer"]:FireClient(Player, "{System}: Checking " ..MessageParts[i + 1].. "..", Color3.new(0, 170/255, 1))
				if MessageParts[i + 1] then
					if tonumber(MessageParts[i + 2]) then
						local userId
						pcall(function() userId = game:GetService("Players"):GetUserIdFromNameAsync(MessageParts[i + 1]) end)
						if userId then
							if userId ~= Player.userId then
								local PlayerFound = false
								for Player in string.gmatch(GameSettings["Players"].Value, "[%a%d%p]+") do
									print(Player, string.match(string.lower(Player), string.lower(MessageParts[i + 1])))
									if string.match(string.lower(Player), string.lower(MessageParts[i + 1])) then
										PlayerFound = true
										break
									end
								end
								if PlayerFound then
									Event["MessagePlayer"]:FireClient(Player, "{System}: Updating requested player's data..", Color3.new(0, 170/255, 1))
									local vPlayer = game:GetService("Players"):FindFirstChild(MessageParts[i + 1])
									if vPlayer then
										local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(vPlayer.Name .."Folder"))
										if PlayerFolder then
											local Points = PlayerFolder:FindFirstChild("Points")
											local LoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
											local LoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
											local LoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
											local Data = PlayerDatabase:GetAsync(userId)
											if Data.RankPoints then
												local SaveData = { Points = Points.Value, Loadout = { Primary = LoadoutPrimary.Value, Secondary = LoadoutSecondary.Value, Aura = LoadoutAura.Value }, RankPoints = Data.RankPoints + tonumber(MessageParts[i + 2]) }
												if PlayerDatabase:SetAsync(userId, SaveData) == true then
													pcall(function() userId = game:GetService("Players"):GetNameFromUserIdAsync(userId) end)
													Event["MessagePlayer"]:FireClient(Player, "{System}: " ..userId.. "'s data updated successfully!", Color3.new(0, 1, 0))
													return true
												else
													Event["MessagePlayer"]:FireClient(Player, "{System}: System error, please try again")
													return false
												end
											else
												local SaveData = { Points = Points.Value, Loadout = { Primary = LoadoutPrimary.Value, Secondary = LoadoutSecondary.Value, Aura = LoadoutAura.Value }, RankPoints = tonumber(MessageParts[i + 2]) }
												if PlayerDatabase:SetAsync(userId, SaveData) == true then
													pcall(function() userId = game:GetService("Players"):GetNameFromUserIdAsync(userId) end)
													Event["MessagePlayer"]:FireClient(Player, "{System}: " ..userId.. "'s data updated successfully, new entry created!", Color3.new(0, 1, 0))
													return true
												else
													Event["MessagePlayer"]:FireClient(Player, "{System}: System error, please try again")
													return false
												end
											end
										else
											Event["MessagePlayer"]:FireClient(Player, "{System}: Please try again in a few seconds..", Color3.new(0, 170/255, 1))
											return false
										end
									else
										local Data = PlayerDatabase:GetAsync(userId)
										if Data.RankPoints then
											local Primary, Secondary, Aura = GetDataFromTable(Data)
											if type(Data.RankPoints) == "string" then
												if Data.RankPoints == "" then
													Data.RankPoints = 0
												else
													Data.RankPoints = tonumber(Data.RankPoints)
												end
											end
											local SaveData = { Points = Data.Points, Loadout = { Primary = Primary, Secondary = Secondary, Aura = Aura }, RankPoints = Data.RankPoints + tonumber(MessageParts[i + 2]) }
											if PlayerDatabase:SetAsync(userId, SaveData) == true then
												pcall(function() userId = game:GetService("Players"):GetNameFromUserIdAsync(userId) end)
												Event["MessagePlayer"]:FireClient(Player, "{System}: " ..userId.. "'s data updated successfully!", Color3.new(0, 1, 0))
												return true
											else
												Event["MessagePlayer"]:FireClient(Player, "{System}: System error, please try again")
												return false
											end
										else
											local SaveData = { Points = 0, Loadout = { Primary = "Default", Secondary = "Default", Aura = "None" }, RankPoints = tonumber(MessageParts[i + 2]) }
											if PlayerDatabase:SetAsync(userId, SaveData) == true then
												pcall(function() userId = game:GetService("Players"):GetNameFromUserIdAsync(userId) end)
												Event["MessagePlayer"]:FireClient(Player, "{System}: " ..userId.. "'s data updated successfully, new entry created!", Color3.new(0, 1, 0))
												return true
											else
												Event["MessagePlayer"]:FireClient(Player, "{System}: System error, please try again")
												return false
											end
										end
									end
								else
									Event["MessagePlayer"]:FireClient(Player, "{System}: " ..MessageParts[i + 1].. " is not in the group", Color3.new(1, 0, 0))
									return false
								end
							else
								Event["MessagePlayer"]:FireClient(Player, "{System}: You cannot update your own points..", Color3.new(1, 0, 0))
								return false
							end
						elseif MessageParts[i + 1] == "Me" then
							Event["MessagePlayer"]:FireClient(Player, "{System}: You cannot update your own points..", Color3.new(1, 0, 0))
							return false	
						else
							Event["MessagePlayer"]:FireClient(Player, "{System}: Please use a valid username", Color3.new(1, 0, 0))
							return false
						end
					else
						Event["MessagePlayer"]:FireClient(Player, "{System}: Please use this format: !Points: [Username] [Points]", Color3.new(1, 0, 0))
						return false
					end
				end
			elseif MessageParts[i] == "!EndMap" then
				if (#game:GetService("Teams")["Red team"]:GetPlayers() > 0 or #game:GetService("Teams")["Blue team"]:GetPlayers() > 0 or #game:GetService("Teams")["FFA"]:GetPlayers() > 0) and #workspace:WaitForChild("ChosenMap"):GetChildren() >= 1 then
					require(MapControls).ServerMessage(Player.Name .." has ended the current map", 5)
					GameSettings["LeaderboardEnabled"].Value = false
					for i, kPlayer in pairs(Players:GetPlayers()) do
						kPlayer.TeamColor = BrickColor.Gray()
						if kPlayer == Player then
							kPlayer.TeamColor = BrickColor.Black()
						end
						kPlayer:LoadCharacter()
						require(PlayerManager):SetLeaderboard(kPlayer, "Deaths", 0, false)
						require(PlayerManager):SetLeaderboard(kPlayer, "Kills", 0, false)
					end
					for i, Map in pairs(workspace:WaitForChild("ChosenMap"):GetChildren()) do
						Map:Destroy()
					end
				end
			end
		end
		if MessageParts[i] == "!Points" then
			if MessageParts[i + 1] == "Retrieve:" then
				if MessageParts[i + 2] == "Me" or MessageParts[i + 2] == Player.Name then
					wait()
					Event["MessagePlayer"]:FireClient(Player, "{System}: Fetching data..", Color3.new(0, 170/255, 1))
					local Data = PlayerDatabase:GetAsync(Player.userId)
					if Data.RankPoints then
						Event["MessagePlayer"]:FireClient(Player, "{System}: Your current ranking points in HN is: " ..Data.RankPoints.. " [ " ..DetermineRankByPoints(Data.RankPoints).. " ] ", Color3.new(0, 170/255, 1))
						return true
					else
						Event["MessagePlayer"]:FireClient(Player, "{System}: No data exists", Color3.new(0, 170/255, 0))
						return false
					end
				else
					wait()
					Event["MessagePlayer"]:FireClient(Player, [[{System}: Because of your rank in HN, this is your only command: "!Points Retrieve: Me"]], Color3.new(1, 0, 0))
					return false
				end
			else
				Event["MessagePlayer"]:FireClient(Player, "{System}: Please use this format: !Points Retrieve: [Username/Me]", Color3.new(1, 0, 0))
				return false
			end
		elseif MessageParts[i] == "!Points:" then
			Event["MessagePlayer"]:FireClient(Player, [[{System}: Because of your rank in HN, this is your only command: "!Points Retrieve: Me"]], Color3.new(1, 0, 0))
			return false
		end
	end
end

return Method
