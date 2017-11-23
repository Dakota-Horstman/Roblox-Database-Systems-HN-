local Create = assert(LoadLibrary("RbxUtility")).Create
local Method = {}
local DataStoreService = game:GetService("DataStoreService")
	local OtherPurchases = DataStoreService:GetDataStore("PlayerDataStores")
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
	local GameObjects = ServerStorage:WaitForChild("GameObjects")
	local GameSettings = ServerStorage:WaitForChild("GameSettings")
	local PlayerValuesFolder = ServerStorage:WaitForChild("PlayerValuesFolder")
local ModuleScript = {}
for i, v in pairs(script.Parent:GetChildren()) do
	ModuleScript[v.Name] = v
end
local PlayerDatabase = require(ModuleScript["PlayerDatabase"]):GetDatabase("Global")
local Server = require(ModuleScript["BotControl"])
	local API = Server("horizon-nation-bot-server.herokuapp.com", "1912", 2697145)

function DecodeTable(Table)
	local ReturnData = {}
	for i in string.gmatch(Table, "[%a%d]+") do
		print(i)
		table.insert(ReturnData, i)
	end
	return ReturnData[2], ReturnData[4], ReturnData[6]
end

function GetRoleInGroup(Player)
	local Role = Player:GetRoleInGroup(2697145)
	if Role == "Guest" or not Role then Role = "Visitor" end
	return Role
end

function Method:UpdateDatabases(Player)
	if GetRoleInGroup(Player) ~= "Visitor" then -- if the player is in HN
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
			local SavedPrimaryData = false
			local SavedSecondaryData = false
			local SavedAuraData = false
			for i, v in pairs(PurchasesSave) do
				if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
					SavedPrimaryData = true
				elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
					SavedSecondaryData = true
				elseif v == ServerLoadoutAura.Value and not SavedAuraData then
					SavedAuraData = true
				elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutAura.Value and SavedAuraData then
					table.remove(PurchasesSave, i)
				end
			end
			if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
			if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
			if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
			OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value, Aura = ServerLoadoutAura.Value }, RankPoints = ServerRankPoints.Value }
			return PlayerDatabase:SetAsync(Player.userId, SaveData)
		end
	elseif PlayerDatabase:GetAsync(Player.userId) then -- If previous data exists
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
			local SavedPrimaryData = false
			local SavedSecondaryData = false
			local SavedAuraData = false
			for i, v in pairs(PurchasesSave) do
				if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
					SavedPrimaryData = true
				elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
					SavedSecondaryData = true
				elseif v == ServerLoadoutAura.Value and not SavedAuraData then
					SavedAuraData = true
				elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutAura.Value and SavedAuraData then
					table.remove(PurchasesSave, i)
				end
			end
			if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
			if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
			if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
			OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value, Aura = ServerLoadoutAura.Value }, RankPoints = ServerRankPoints.Value }
			return PlayerDatabase:SetAsync(Player.userId, SaveData)
		end
	else -- Check for any purchases
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			if ServerLoadoutPrimary.Value ~= "Default" and ServerLoadoutPrimary.Value ~= "" then -- If they've purchased a primary weapon
				local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value }, RankPoints = ServerRankPoints.Value }
				PlayerDatabase:SetAsync(Player.userId, SaveData)
				local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
				local SavedPrimaryData = false
				local SavedSecondaryData = false
				local SavedAuraData = false
				for i, v in pairs(PurchasesSave) do
					if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
						SavedPrimaryData = true
					elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
						SavedSecondaryData = true
					elseif v == ServerLoadoutAura.Value and not SavedAuraData then
						SavedAuraData = true
					elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutAura.Value and SavedAuraData then
						table.remove(PurchasesSave, i)
					end
				end
				if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
				if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
				if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
				OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			elseif ServerLoadoutSecondary.Value ~= "Default" and ServerLoadoutSecondary.Value ~= "" then -- If they've purchased a secondary weapon
				local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value }, RankPoints = ServerRankPoints.Value }
				PlayerDatabase:SetAsync(Player.userId, SaveData)
				local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
				local SavedPrimaryData = false
				local SavedSecondaryData = false
				local SavedAuraData = false
				for i, v in pairs(PurchasesSave) do
					if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
						SavedPrimaryData = true
					elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
						SavedSecondaryData = true
					elseif v == ServerLoadoutAura.Value and not SavedAuraData then
						SavedAuraData = true
					elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutAura.Value and SavedAuraData then
						table.remove(PurchasesSave, i)
					end
				end
				if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
				if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
				if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
				OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			end
		end
		return true
	end
	for i, v in pairs(game:GetService("DataStoreService"):GetDataStore("PlayerDataStores"):GetAsync(game.Players.LocalPlayer.userId)) do
		print(i .." : ".. v)
	end
end
	
function Method:Setup(Player)
	Event["MessagePlayer"]:FireClient(Player, "{System}: Initializing..", Color3.new(0, 170/255, 1))
	Event["MessagePlayer"]:FireClient(Player, "{System}: Please wait until the system has initialized", Color3.new(0, 170/255, 1))
	local PlayerData = PlayerDatabase:GetAsync(Player.userId)
	local Primary, Secondary, Aura = "Default", "Default", "None"
	if PlayerData.RankPoints then
		Secondary, Aura, Primary = DecodeTable(PlayerData.Loadout)
		print(Primary, Secondary, Aura)
	else
		PlayerData = { Points = 0, Loadout = { Primary = "Default", Secondary = "Default", Aura = "None" }, RankPoints = 0 }
		if GetRoleInGroup(Player) ~= "Guest" then
			PlayerDatabase:SetAsync(Player.userId, PlayerData)
		end
	end
	local PlayerFolder = Create("Folder") { Parent = PlayerValuesFolder, Name = tostring(Player.Name .."Folder") }
		local ServerKills = Create("IntValue") { Parent = PlayerFolder, Name = "Kills", Value = 0 }
		local ServerDeaths = Create("IntValue") { Parent = PlayerFolder, Name = "Deaths", Value = 0 }
		local ServerPoints = Create("IntValue") { Parent = PlayerFolder, Name = "Points", Value = PlayerData.Points }
		local ServerRankPoints = Create("IntValue") { Parent = PlayerFolder, Name = "RankPoints", Value = PlayerData.RankPoints }
		local ServerLoadoutPrimary = Create("StringValue") { Parent = PlayerFolder, Name = "LoadoutPrimary", Value = Primary }
		local ServerLoadoutSecondary = Create("StringValue") { Parent = PlayerFolder, Name = "LoadoutSecondary", Value = Secondary }
		local ServerLoadoutAura = Create("StringValue") { Parent = PlayerFolder, Name = "LoadoutAura", Value = Aura }
	local leaderstats = Create("IntValue") { Parent = Player, Name = "leaderstats", Value = 0 }
	local Rank = leaderstats:FindFirstChild("Rank") or Create("StringValue") { Parent = leaderstats, Name = "Rank", Value = GetRoleInGroup(Player) }
	require(script.Parent:WaitForChild("MapControls")):CheckSettings(Player)
	local Success, Message = Method:UpdateDatabases(Player)
	if Success then
		Event["MessagePlayer"]:FireClient(Player, Message, Color3.new(0, 1, 0))
	end
	print("Getting players..")
	local PlayersInHN = API.getPlayers()
	print("Players got..")
	for Player, Other in pairs(PlayersInHN.data.players) do
		print(Player, " : ", Player[2])
		GameSettings["Players"].Value = GameSettings["Players"].Value ..Player.. " "
	end
	Event["MessagePlayer"]:FireClient(Player, "{System}: System ready", Color3.new(0, 1, 0))
	return true
end

function Method:Remove(Player)
	if GetRoleInGroup(Player) ~= "Guest" then -- if the player is in HN
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
			local SavedPrimaryData = false
			local SavedSecondaryData = false
			local SavedAuraData = false
			for i, v in pairs(PurchasesSave) do
				if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
					SavedPrimaryData = true
				elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
					SavedSecondaryData = true
				elseif v == ServerLoadoutAura.Value and not SavedAuraData then
					SavedAuraData = true
				elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutAura.Value and SavedAuraData then
					table.remove(PurchasesSave, i)
				end
			end
			if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
			if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
			if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
			OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value, Aura = ServerLoadoutAura.Value }, RankPoints = ServerRankPoints.Value }
			PlayerFolder:Destroy()
			return PlayerDatabase:SetAsync(Player.userId, SaveData)
		end
	elseif PlayerDatabase:GetAsync(Player.userId) then -- If previous data exists
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
			local SavedPrimaryData = false
			local SavedSecondaryData = false
			local SavedAuraData = false
			for i, v in pairs(PurchasesSave) do
				if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
					SavedPrimaryData = true
				elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
					SavedSecondaryData = true
				elseif v == ServerLoadoutAura.Value and not SavedAuraData then
					SavedAuraData = true
				elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
					table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
				elseif v == ServerLoadoutAura.Value and SavedAuraData then
					table.remove(PurchasesSave, i)
				end
			end
			if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
			if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
			if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
			OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value, Aura = ServerLoadoutAura.Value }, RankPoints = ServerRankPoints.Value }
			PlayerFolder:Destroy()
			return PlayerDatabase:SetAsync(Player.userId, SaveData)
		end
	else -- Check for any purchases
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerPoints = PlayerFolder:FindFirstChild("Points")
			local ServerRankPoints = PlayerFolder:FindFirstChild("RankPoints")
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			local ServerLoadoutAura = PlayerFolder:FindFirstChild("LoadoutAura")
			if ServerLoadoutPrimary.Value ~= "Default" and ServerLoadoutPrimary.Value ~= "" then -- If they've purchased a primary weapon
				local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value }, RankPoints = ServerRankPoints.Value }
				PlayerDatabase:SetAsync(Player.userId, SaveData)
				local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
				local SavedPrimaryData = false
				local SavedSecondaryData = false
				local SavedAuraData = false
				for i, v in pairs(PurchasesSave) do
					if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
						SavedPrimaryData = true
					elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
						SavedSecondaryData = true
					elseif v == ServerLoadoutAura.Value and not SavedAuraData then
						SavedAuraData = true
					elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutAura.Value and SavedAuraData then
						table.remove(PurchasesSave, i)
					end
				end
				if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
				if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
				if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
				OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			elseif ServerLoadoutSecondary.Value ~= "Default" and ServerLoadoutSecondary.Value ~= "" then -- If they've purchased a secondary weapon
				local SaveData = { Points = ServerPoints.Value, Loadout = { Primary = ServerLoadoutPrimary.Value, Secondary = ServerLoadoutSecondary.Value }, RankPoints = ServerRankPoints.Value }
				PlayerDatabase:SetAsync(Player.userId, SaveData)
				local PurchasesSave = OtherPurchases:GetAsync(Player.userId) or {}
				local SavedPrimaryData = false
				local SavedSecondaryData = false
				local SavedAuraData = false
				for i, v in pairs(PurchasesSave) do
					if v == ServerLoadoutPrimary.Value and not SavedPrimaryData then
						SavedPrimaryData = true
					elseif v == ServerLoadoutSecondary.Value and not SavedSecondaryData then
						SavedSecondaryData = true
					elseif v == ServerLoadoutAura.Value and not SavedAuraData then
						SavedAuraData = true
					elseif v == ServerLoadoutPrimary.Value and SavedPrimaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutSecondary.Value and SavedSecondaryData then
						table.remove(PurchasesSave, i) -- Perform self-clean (remove duplicate saves)
					elseif v == ServerLoadoutAura.Value and SavedAuraData then
						table.remove(PurchasesSave, i)
					end
				end
				if not SavedPrimaryData then table.insert(PurchasesSave, ServerLoadoutPrimary.Value) end
				if not SavedSecondaryData then table.insert(PurchasesSave, ServerLoadoutSecondary.Value) end
				if not SavedAuraData then table.insert(PurchasesSave, ServerLoadoutAura.Value) end
				OtherPurchases:SetAsync(Player.userId, PurchasesSave)
			end
			PlayerFolder:Destroy()
		end
		return true
	end
end

function Method:LoadLoadout(Player)
	if Player.TeamColor ~= BrickColor.Gray() and Player.TeamColor ~= BrickColor.Black() and GameSettings["LoadValues"].Value then
		local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
		if PlayerFolder then
			local ServerLoadoutPrimary = PlayerFolder:FindFirstChild("LoadoutPrimary")
			local ServerLoadoutSecondary = PlayerFolder:FindFirstChild("LoadoutSecondary")
			if ServerLoadoutPrimary.Value == "" then
				local Primary, Secondary = DecodeTable(PlayerDatabase:GetAsync(Player.userId).Loadout) or "Default", "Default"
				local PrimaryWeapon
				if Player.TeamColor == BrickColor.Red() or BrickColor.Blue() then
					 PrimaryWeapon = GameObjects["Weapons"]["TDM"]:FindFirstChild(Primary)
				elseif Player.TeamColor == BrickColor.Green() then
					PrimaryWeapon  = GameObjects["Weapons"]["FFA"]:FindFirstChild(Primary)
				end
				if PrimaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					PrimaryWeapon:Clone().Parent = Player.Backpack
				end
				local SecondaryWeapon = GameObjects["Weapons"]:FindFirstChild(Secondary, true)
				if SecondaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					SecondaryWeapon:Clone().Parent = Player.Backpack
					return true
				end
				return false
			elseif ServerLoadoutSecondary.Value == "" then
				local Primary, Secondary = DecodeTable(PlayerDatabase:GetAsync(Player.userId).Loadout) or "Default", "Default"
				local PrimaryWeapon
				if Player.TeamColor == BrickColor.Red() or BrickColor.Blue() then
					 PrimaryWeapon = GameObjects["Weapons"]["TDM"]:FindFirstChild(Primary)
				elseif Player.TeamColor == BrickColor.Green() then
					PrimaryWeapon  = GameObjects["Weapons"]["FFA"]:FindFirstChild(Primary)
				end
				if PrimaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					PrimaryWeapon:Clone().Parent = Player.Backpack
				end
				local SecondaryWeapon = GameObjects["Weapons"]:FindFirstChild(Secondary, true)
				if SecondaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					SecondaryWeapon:Clone().Parent = Player.Backpack
					return true
				end
				return false
			else
				local PrimaryWeapon
				if Player.TeamColor == BrickColor.Red() or BrickColor.Blue() then
					 PrimaryWeapon = GameObjects["Weapons"]["TDM"]:FindFirstChild(ServerLoadoutPrimary.Value)
				elseif Player.TeamColor == BrickColor.Green() then
					PrimaryWeapon  = GameObjects["Weapons"]["FFA"]:FindFirstChild(ServerLoadoutPrimary.Value)
				end
				if PrimaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					PrimaryWeapon:Clone().Parent = Player.Backpack
					return true
				else
					local Primary, Secondary = DecodeTable(PlayerDatabase:GetAsync(Player.userId).Loadout) or "Default", "Default"
					local PrimaryWeapon
					if Player.TeamColor == BrickColor.Red() or BrickColor.Blue() then
						 PrimaryWeapon = GameObjects["Weapons"]["TDM"]:FindFirstChild(Primary)
					elseif Player.TeamColor == BrickColor.Green() then
						PrimaryWeapon  = GameObjects["Weapons"]["FFA"]:FindFirstChild(Primary)
					end
					if PrimaryWeapon then
						repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
						PrimaryWeapon:Clone().Parent = Player.Backpack
					end
					local SecondaryWeapon = GameObjects["Weapons"]:FindFirstChild(Secondary, true)
					if SecondaryWeapon then
						repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
						SecondaryWeapon:Clone().Parent = Player.Backpack
						return true
					end
					return false
				end
				local SecondaryWeapon = GameObjects["Weapons"]:FindFirstChild(ServerLoadoutSecondary.Value, true)
				if SecondaryWeapon then
					repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
					SecondaryWeapon:Clone().Parent = Player.Backpack
				else
					local Primary, Secondary = DecodeTable(PlayerDatabase:GetAsync(Player.userId).Loadout) or "Default", "Default"
					local PrimaryWeapon
					if Player.TeamColor == BrickColor.Red() or BrickColor.Blue() then
						 PrimaryWeapon = GameObjects["Weapons"]["TDM"]:FindFirstChild(Primary)
					elseif Player.TeamColor == BrickColor.Green() then
						PrimaryWeapon  = GameObjects["Weapons"]["FFA"]:FindFirstChild(Primary)
					end
					if PrimaryWeapon then
						repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
						PrimaryWeapon:Clone().Parent = Player.Backpack
					end
					local SecondaryWeapon = GameObjects["Weapons"]:FindFirstChild(Secondary, true)
					if SecondaryWeapon then
						repeat wait() until Player.Character and Player.Character["Humanoid"].Health > 0
						SecondaryWeapon:Clone().Parent = Player.Backpack
						return true
					end
					return false
				end
			end
		end
	elseif (Player.TeamColor ~= BrickColor.Gray() and Player.TeamColor ~= BrickColor.Black()) and not GameSettings["LoadValues"].Value then
		if Player.TeamColor == BrickColor.Red() or Player.TeamColor == BrickColor.Blue() then
			GameObjects["Weapons"]["TDM"]["Default"]:Clone().Parent = Player.Backpack
		elseif Player.TeamColor == BrickColor.Green() then
			GameObjects["Weapons"]["FFA"]["Default"]:Clone().Parent = Player.Backpack
		end
	elseif Player.TeamColor == BrickColor.Gray() or Player.TeamColor == BrickColor.Black() then
		for i, BackpackItem in pairs(Player.Backpack:GetChildren()) do
			BackpackItem:Destroy()
		end
		for i, CharacterItem in pairs(Player.Character:GetChildren()) do
			if CharacterItem:IsA("Tool") then
				CharacterItem:Destroy()
			end
		end
	end
end

function Method:LoadLeaderboard(Bool)
	if Bool then
		for i, Player in pairs(game:GetService("Players"):GetPlayers()) do
			local leaderstats = Player:FindFirstChild("leaderstats") or Create("IntValue") { Parent = Player, Name = "leaderstats", Value = 0 }
				local Kills = leaderstats:FindFirstChild("Kills") or Create("IntValue") { Parent = leaderstats, Name = "Kills", Value = 0 }
				local Deaths = leaderstats:FindFirstChild("Deaths") or Create("IntValue") { Parent = leaderstats, Name = "Deaths", Value = 0 }
				local Rank = leaderstats:FindFirstChild("Rank") or Create("StringValue") { Parent = leaderstats, Name = "Rank", Value = GetRoleInGroup(Player) }
		end
	else
		for i, Player in pairs(game:GetService("Players"):GetPlayers()) do
			local leaderstats = Player:FindFirstChild("leaderstats")
			if leaderstats then
				for i, Leaderstat in pairs(leaderstats:GetChildren()) do
					if Leaderstat.Name ~= "Rank" then
						Leaderstat:Destroy()
					end
				end
			end
			local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
			if PlayerFolder then
				local ServerKills = PlayerFolder:FindFirstChild("Kills")
				local ServerDeaths = PlayerFolder:FindFirstChild("Deaths")
				if ServerKills then ServerKills.Value = 0 end
				if ServerDeaths then ServerDeaths.Value = 0 end
			end
		end
	end
	return true
end

function Method:UpdateLeaderboard(Killed)
	local function UpdatePlayer(Player, Identifier, Value)
		local leaderstats = Player:FindFirstChild("leaderstats")
		if leaderstats then
			local Leaderstat = leaderstats:FindFirstChild(Identifier)
			if Leaderstat then Leaderstat.Value = Value return true end
			return false
		end
		return false
	end
	local Tag = Killed.Character:FindFirstChild("Humanoid"):FindFirstChild("creator")
	if Tag then
		local Killer = Tag.Value
		if Killer and Killer.Parent then
			local KillerFolder = PlayerValuesFolder:FindFirstChild(tostring(Killer.Name .."Folder"))
			if KillerFolder then
				local ServerKills = KillerFolder:FindFirstChild("Kills")
				if ServerKills then ServerKills.Value = ServerKills.Value + 1 end
				UpdatePlayer(Killer, "Kills", ServerKills.Value)
			end
		end
	end
	local KilledFolder = PlayerValuesFolder:FindFirstChild(tostring(Killed.Name .."Folder"))
	if KilledFolder then
		local ServerDeaths = KilledFolder:FindFirstChild("Deaths")
		if ServerDeaths then ServerDeaths.Value = ServerDeaths.Value + 1 end
		UpdatePlayer(Killed, "Deaths", ServerDeaths.Value)
		return true
	end
	return false
end

function Method:CorrectLeaderboard(Player)
	local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
	if PlayerFolder then
		local ServerDeaths = PlayerFolder:FindFirstChild("Deaths")
		local ServerKills = PlayerFolder:FindFirstChild("Kills")
		local leaderstats = Player:FindFirstChild("leaderstats")
		if leaderstats then
			local PlayerDeaths = leaderstats:FindFirstChild("Deaths")
			local PlayerKills = leaderstats:FindFirstChild("Kills")
			if ServerDeaths then
				if PlayerDeaths then
					PlayerDeaths.Value = ServerDeaths.Value
				end
			end
			if ServerKills then
				if PlayerKills then
					PlayerKills.Value = ServerKills.Value
				end
			end
		end
	end
end

function Method:SetLeaderboard(Player, Identification, Value, Add)
	local PlayerFolder = PlayerValuesFolder:FindFirstChild(tostring(Player.Name .."Folder"))
	if PlayerFolder then
		local ServerDeaths = PlayerFolder:FindFirstChild("Deaths")
		local ServerKills = PlayerFolder:FindFirstChild("Kills")
		if Identification == "Deaths" and ServerDeaths then
			if Add then
				ServerDeaths.Value = ServerDeaths.Value + tonumber(Value)
			else
				ServerDeaths.Value = tonumber(Value)
			end
			Method:CorrectLeaderboard(Player)
		elseif Identification == "Kills" and ServerKills then
			if Add then
				ServerKills.Value = ServerKills.Value + tonumber(Value)
			else
				ServerKills.Value = tonumber(Value)
			end
			Method:CorrectLeaderboard(Player)
		end
	end
end

return Method
