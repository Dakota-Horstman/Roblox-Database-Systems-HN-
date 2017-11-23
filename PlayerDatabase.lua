local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Method = {}
local Server = require(script.Parent:WaitForChild("BotControl"))
	local API = Server("horizon-nation-bot-server.herokuapp.com", "1912", 2697145)
local ScriptId = "AKfycbw5shfdSHN5DR3ubUJIXZA8ZYWITBWDFk9ofTLeQbbKL622hFw"
local Url = "https://script.google.com/macros/s/" ..ScriptId.."/exec"

function DecodeMessage(Message, UserId)
	local MessagePart1 = string.sub(Message, 1, 29)
	local PlayerName = Players:GetNameFromUserIdAsync(UserId)
	local MessagePart2 = string.sub(Message, 35 + string.len(UserId), 35 + string.len(UserId) + 27)
	local GroupName = "Horizon Nation"
	return MessagePart1 ..PlayerName.. MessagePart2 ..GroupName
end

function GetRankID(RankPoints)
	if not RankPoints then
		RankPoints = 0
	end
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
	local LastRankIterated = Rank
	for i, TableData in pairs(RanksByPointsWithIDs) do
		if RankPoints and TableData.Points > RankPoints then
			Rank = LastRankIterated
			break
		end
		LastRankIterated = TableData[1]
	end
	if RankPoints > 7000 then Rank = "High Rank" end
	return Rank
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
	local LastRankIterated = Rank
	for i, TableData in pairs(RanksByPointsWithIDs) do
		if TableData.Points > RankPoints then
			Rank = LastRankIterated
			break
		end
		LastRankIterated = TableData[2]
	end
	if RankPoints > 7000 then Rank = "High Rank" end
	return Rank
end

function JSONEncode(Data)
	local ReturnData = Data
	local Success, Error = pcall(function()
		ReturnData = HttpService:JSONEncode(Data)
	end)
	if Error then warn(Error) end
	return ReturnData
end

function JSONDecode(Data)
	local ReturnData = Data
	local Success, Error = pcall(function()
		ReturnData = HttpService:JSONDecode(Data)
	end)
	if Error then warn(Error) end
	return ReturnData
end

function GetData(PlayerUserId, Sheet)
	local UserId = PlayerUserId
	print(UserId)
	if type(UserId) == "string" then
		local Success, Error = pcall(function()
			UserId = game:GetService("Players"):GetUserIdFromNameAsync(UserId)
		end)
		if Error then warn(Error) return Error end
	end
	local ReturnJSON = HttpService:GetAsync(Url.. "?Sheet=" ..Sheet.. "&userId=" ..UserId)
	ReturnJSON = JSONDecode(ReturnJSON)
	if ReturnJSON.Result == "Success"then
		return ReturnJSON.Data
	elseif ReturnJSON.Result == "Failure" then
		warn("Database error: ", ReturnJSON.Status)
		return ReturnJSON.Status
	end
end

function PostData(PlayerUserId, Sheet, Data)
	local Name = PlayerUserId
	if tonumber(Name) then
		local Success, Error = pcall(function()
			Name = game:GetService("Players"):GetNameFromUserIdAsync(Name)
		end)
		if Error then return Error end
	end
	local Loadout = Data.Loadout
	Loadout = HttpService:UrlEncode(JSONEncode(Loadout))
	local Points = Data.Points
	Points = HttpService:UrlEncode(JSONEncode(Points))
	local RankPoints = Data.RankPoints
	RankPoints = HttpService:UrlEncode(JSONEncode(RankPoints))
	local Rank = DetermineRankByPoints(Data.RankPoints)
	Rank = HttpService:UrlEncode(JSONEncode(Rank))
	local CurrentRankPoints = tonumber(GetData(PlayerUserId, Sheet).RankPoints)
	local Message = "Your rank has not been changed"
	if CurrentRankPoints and RankPoints and CurrentRankPoints <= 7000 and tonumber(RankPoints) <= 7000 and CurrentRankPoints ~= tonumber(RankPoints) and Name ~= "Julian_Orteil" then
		Message = API.setRank(PlayerUserId, GetRankID(tonumber(RankPoints))).message
		Message = DecodeMessage(Message, PlayerUserId)
	end
	local ReturnJSON = HttpService:PostAsync(Url, "Sheet=" ..Sheet.. "&userId=" ..PlayerUserId..  "&Name=" ..Name.. "&Points=" ..Points.. "&Loadout=" ..Loadout.. "&RankPoints=" ..RankPoints.. "&Rank=" ..Rank, 2)
	ReturnJSON = JSONDecode(ReturnJSON)
	if ReturnJSON.Result == "Success" then
		return true, Message
	elseif ReturnJSON.Result == "Failure" then
		warn("Database error: ", ReturnJSON.Status)
		return ReturnJSON.Status
	end
end

function Method:GetDatabase(Sheet)
	local Database = {}
	function Database:GetAsync(PlayerUserId)
		return GetData(PlayerUserId, Sheet)
	end
	function Database:SetAsync(PlayerUserId, Data)
		return PostData(PlayerUserId, Sheet, Data)
	end
	return Database
end

return Method
