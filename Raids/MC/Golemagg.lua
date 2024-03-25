
local module, L = BigWigs:ModuleDeclaration("Golemagg the Incinerator", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"earthquake", "enraged", "bosskill"}
module.wipemobs = {"Core Rager"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Golemagg",

	enraged_cmd = "enraged",
	enraged_name = "Announce boss Enrage",
	enraged_desc = "Lets you know when boss hits harder",

	earthquake_cmd = "earthquake",
	earthquake_name = "Earthquake announce",
	earthquake_desc = "Announces when it's time for melees to back off",
	
	
	msg_earthquakeSoon = "Earthquake Soon",
	trigger_enrage = "Golemagg the Incinerator gains Enrage.",
	msg_enrage = "Boss is enraged!",
} end)

local timer = {}
local icon = {}
local color = {}
local syncName = {
	earthquake = "GolemaggEarthquake",
	enrage = "trigger_enrage",
}

local earthquake = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("UNIT_HEALTH")

	self:ThrottleSync(10, syncName.earthquake)
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	earthquake = nil
end

function module:OnDisengage()
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(msg, L["trigger_enrage"]) then
		self:Sync(syncName.enrage)
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 15 and healthPct <= 20 and earthquake == nil and self.db.profile.earthquake then
			self:Sync(syncName.earthquake)
		elseif healthPct > 21 and earthquake == true then
			earthquake = nil
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.earthquake and earthquake == nil and self.db.profile.earthquake then
		self:Earthquake()
	elseif sync == syncName.enrage and self.db.profile.enraged then
		self:Enrage()
	end
end

function module:Earthquake()
	earthquake = true
	self:Message(L["msg_earthquakeSoon"], "Attention", "Alarm")
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Attention", true, "Beware")
end
