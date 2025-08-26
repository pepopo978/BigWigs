local module, L = BigWigs:ModuleDeclaration("Sorcerer-Thane Thaurissan", "Molten Core")

module.revision = 30001
module.enabletrigger = module.translatedName
module.toggleoptions = {"runeofdetonation", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Thaurissan",
	
	runeofdetonation_cmd = "runeofdetonation",
	runeofdetonation_name = "Rune of Detonation Alert",
	runeofdetonation_desc = "Personal alert when you have both Rune of Detonation and Rune of Power",
	
	trigger_runeOfDetonationYou = "You are afflicted by Rune of Detonation",
	trigger_runeOfDetonationStackYou = "You are afflicted by Rune of Detonation %((.+)%)",
	trigger_runeOfDetonationFade = "Rune of Detonation fades from you",
	
	trigger_runeOfPowerYou = "You are afflicted by Rune of Power",
	trigger_runeOfPowerFade = "Rune of Power fades from you",
	
	msg_runeCombo = "Rune of Detonation MOVE!",
} end)

local hasRuneOfDetonation = false
local hasRuneOfPower = false

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
end

function module:OnSetup()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
end

function module:OnEngage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
end

function module:OnDisengage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
end

function module:Event(msg)
	if string.find(msg, L["trigger_runeOfDetonationYou"]) then
		hasRuneOfDetonation = true
		self:CheckRuneCombination()
	
	elseif msg == L["trigger_runeOfDetonationFade"] then
		hasRuneOfDetonation = false
		
	elseif string.find(msg, L["trigger_runeOfPowerYou"]) then
		hasRuneOfPower = true
		self:CheckRuneCombination()
	
	elseif msg == L["trigger_runeOfPowerFade"] then
		hasRuneOfPower = false
	end
end

function module:CheckRuneCombination()
	if hasRuneOfDetonation and hasRuneOfPower and self.db.profile.runeofdetonation then
		self:Message(L["msg_runeCombo"], "Personal", false, nil, false)
		self:Sound("RunAway")
		self:WarningSign("inv_enchant_essenceastralsmall", 3)
	end
end