
local module, L = BigWigs:ModuleDeclaration("Shadowclaw Rager", "Karazhan")

module.revision = 30020
module.enabletrigger = module.translatedName
module.toggleoptions = {"enrage"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "ShadowclawRager",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",
	
	trigger_enrage = "Shadowclaw Rager gains Shadowclaw Enrage (1).", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_enrageFade = "Shadowclaw Enrage fades from Shadowclaw Rager.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_enrage = "Enrage - Tranq now!",
	
} end )

module.defaultDB = {
	enrage = true,
}

local timer = {}

local icon = {
	enrage = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
}

local color = {}

local syncName = {
	enrage = "ShadowclawRagerEnrageStart"..module.revision,
	enrageFade = "ShadowclawRagerEnrageStop"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --enrage
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --enrage fades
	
	self:ThrottleSync(3, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end


function module:Event(msg)
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_enrageFade"]) then
		self:Sync(syncName.enrageFade)		
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.enrageFade and self.db.profile.enrage then
		self:EnrageFade()
	end
end


function module:Enrage()
	if UnitClass("Player") == "Hunter" then
		self:Message(L["msg_enrage"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.tranquil, 1)
	end
	
end

function module:EnrageFade()
	self:RemoveWarningSign(icon.tranquil)
end
