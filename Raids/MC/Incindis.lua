local module, L = BigWigs:ModuleDeclaration("Incindis", "Molten Core")

module.revision = 30001
module.enabletrigger = module.translatedName
module.toggleoptions = {"firenova", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Incindis",

	firenova_cmd = "firenova",
	firenova_name = "Fire Nova Alert",
	firenova_desc = "Warn for incoming Fire Nova after Quaking Stomp",

	trigger_quakingStomp = "Incindis's Quaking Stomp hits (.+) for",
	bar_fireNova = "Fire Nova!",
	msg_fireNova = "FIRE NOVA - RUN AWAY!",
} end)

local timer = {
	fireNova = 5.5,
}
local icon = {
	fireNova = "spell_fire_selfdestruct",
}
local color = {
	fireNova = "Red",
}
local syncName = {
	quakingStomp = "IncindisQuakingStomp"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")

	self:ThrottleSync(1, syncName.quakingStomp)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_quakingStomp"]) then
		self:Sync(syncName.quakingStomp)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.quakingStomp and self.db.profile.firenova then
		self:QuakingStomp()
	end
end

function module:QuakingStomp()
	self:RemoveBar(L["bar_fireNova"])

	self:Message(L["msg_fireNova"], "Urgent", false, nil, false)
	self:Bar(L["bar_fireNova"], timer.fireNova, icon.fireNova, true, color.fireNova)
	self:Sound("RunAway")
	self:WarningSign(icon.fireNova, timer.fireNova)
end

function module:Test()
	BigWigs:ToggleActive(true)
	BigWigs:EnableModule(self:ToString())
	self:TriggerEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Incindis's Quaking Stomp hits Pookers for 975.")
end
-- /run BigWigs:GetModule("Incindis"):Test()