--[[
by Dorann
Reduces farclip (terrain distance) to a minimum in naxxramas to avoid screen freezes
--]]


assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------
local L = AceLibrary("AceLocale-2.2"):new("BigWigsThreat")
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
	return {
		["Threat"] = true,
		["ThreatDesc"] = "Parses messages from TWThreat for usage in BigWigs plugins.",
		["Active"] = true,
		["Activate the plugin."] = true,
	}
end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThreat = BigWigs:NewModule(L["Threat"])
BigWigsThreat.revision = 20011
BigWigsThreat.defaultDB = {
	active = false,
}
BigWigsThreat.consoleCmd = "threat"

BigWigsThreat.consoleOptions = {
	type = "group",
	name = L["Threat"],
	desc = L["ThreatDesc"],
	args = {
		active = {
			type = "toggle",
			name = L["Active"],
			desc = L["Activate the plugin."],
			order = 1,
			get = function()
				return BigWigsThreat.db.profile.active
			end,
			set = function(v)
				BigWigsThreat.db.profile.active = v
			end,
			--passValue = "reverse",
		},
	}
}

BigWigsThreat.threatApi = 'TWTv4=';
BigWigsThreat.UDTS = 'TWT_UDTSv4';

BigWigsThreat.prefix = 'TWT'
BigWigsThreat.channel = ''
BigWigsThreat.threats = {}

BigWigsThreat.classesToWatch = {} -- c

------------------------------
--      Initialization      --
------------------------------

function BigWigsThreat:OnEnable()
	BigWigsThreat:StartListening()
end

function BigWigsThreat:OnDisable()
	BigWigsThreat:StopListening()
end

function BigWigsThreat:StartListening()
	if not self:IsEventRegistered("CHAT_MSG_ADDON") then
		self:RegisterEvent("CHAT_MSG_ADDON", "Event")
	end
end

function BigWigsThreat:StopListening()
	if self:IsEventRegistered("CHAT_MSG_ADDON") then
		self:UnregisterEvent("CHAT_MSG_ADDON")
	end
end

function BigWigsThreat:Event()
	if string.find(arg2, self.threatApi, 1, true) then
		local threatData = arg2
		return self:handleThreatPacket(threatData)
	end
end

function BigWigsThreat:wipe(src)
	-- notes: table.insert, table.remove will have undefined behavior
	-- when used on tables emptied this way because Lua removes nil
	-- entries from tables after an indeterminate time.
	-- Instead of table.insert(t,v) use t[table.getn(t)+1]=v as table.getn collapses nil entries.
	-- There are no issues with hash tables, t[k]=v where k is not a number behaves as expected.
	local mt = getmetatable(src) or {}
	if mt.__mode == nil or mt.__mode ~= "kv" then
		mt.__mode = "kv"
		src = setmetatable(src, mt)
	end
	for k in pairs(src) do
		src[k] = nil
	end
	return src
end

function BigWigsThreat:handleThreatPacket(packet)
	local playersString = string.sub(packet, string.find(packet, self.threatApi) + string.len(self.threatApi), string.len(packet))

	self.threats = self:wipe(self.threats)
	self.tankName = ''

	local players = self:explode(playersString, ';')
	for _, tData in players do

		local msgEx = self:explode(tData, ':')

		if msgEx[1] and msgEx[2] and msgEx[3] and msgEx[4] and msgEx[5] then
			local player = string.lower(msgEx[1])
			local tank = msgEx[2] == '1'
			local threat = tonumber(msgEx[3])
			local perc = tonumber(msgEx[4])
			local melee = msgEx[5] == '1'

			self.threats[player] = {
				threat = threat,
				tank = tank,
				perc = perc,
				melee = melee,
			}

			if tank then
				self.tankName = player
			end
		end
	end
end

-- returns {
-- threat = threatValue,
-- tank = boolean,
-- perc = threatPercentage,
-- melee = boolean
function BigWigsThreat:GetPlayerInfo(playerName)
	local lowerPlayerName = string.lower(playerName)
	if not self.threats[lowerPlayerName] then
		return {
			threat = false,
			tank = false,
			perc = false,
			melee = false,
		}
	end
	return self.threats[lowerPlayerName]
end

function BigWigsThreat:explode(str, delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(str, delimiter, from, 1, true)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from, true)
	end
	table.insert(result, string.sub(str, from))
	return result
end
