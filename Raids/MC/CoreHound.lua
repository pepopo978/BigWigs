
local module, L = BigWigs:ModuleDeclaration("Core Hound", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"respawn"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "CoreHound",

	respawn_cmd = "respawn",
	respawn_name = "Respawn Alert",
	respawn_desc = "Warn for Respawn",

	trigger_smolder = "%s collapses and begins to smolder.",
	bar_respawn = "Hounds Respawn",
	msg_respawn = "Kill all Core Hounds within 10 seconds",

	["You have slain %s!"] = true,
} end )

local timer = {
	respawn = 10,
}
local icon = {
	respawn = "inv_misc_pocketwatch_01",
}
local color = {
	respawn = "Magenta",
}
local syncName = {
	dead = "CoreHoundDead"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	
	self:ThrottleSync(10, syncName.dead)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

-- why do this though? it's just a short timer
-- function module:CheckForBossDeath(msg)
-- 	if msg == string.format(UNITDIESOTHER, self:ToString())
-- 		or msg == string.format(L["You have slain %s!"], self.translatedName) then
-- 		local function IsBossInCombat()
-- 			local t = module.enabletrigger
-- 			if not t then return false end
-- 			if type(t) == "string" then t = {t} end

-- 			if UnitExists("Target") and UnitAffectingCombat("Target") then
-- 				local target = UnitName("Target")
-- 				for _, mob in pairs(t) do
-- 					if target == mob then
-- 						return true
-- 					end
-- 				end
-- 			end

-- 			local num = GetNumRaidMembers()
-- 			for i = 1, num do
-- 				local raidUnit = string.format("raid%starget", i)
-- 				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
-- 					local target = UnitName(raidUnit)
-- 					for _, mob in pairs(t) do
-- 						if target == mob then
-- 							return true
-- 						end
-- 					end
-- 				end
-- 			end
-- 			return false
-- 		end

-- 		if not IsBossInCombat() then
-- 			self:SendBossDeathSync()
-- 		end
-- 	end
-- end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L["trigger_smolder"] then
		self:Sync(syncName.dead)
	end
end

function module:Event(msg)
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.dead and self.db.profile.respawn then
		self:StartTimer()
	end
end


function module:StartTimer()
	self:Message(L["msg_respawn"])
	self:Bar(L["bar_respawn"], timer.respawn, icon.respawn, true, color.respawn)
end
