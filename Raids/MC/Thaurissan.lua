local module, L = BigWigs:ModuleDeclaration("Sorcerer-Thane Thaurissan", "Molten Core")

module.revision = 30002
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
	trigger_runeOfDetonationFade = "Rune of Detonation fades from you",

	trigger_runeOfPowerYou = "You are afflicted by Rune of Power",
	trigger_runeOfPowerFade = "Rune of Power fades from you",

	msg_runeCombo = "Rune of Detonation MOVE!",
	bar_runeDetonation = "Rune of Detonation",
} end)

local hasRuneOfDetonation = false
local hasRuneOfPower = false
local hasAlerted = false

local timer = {
	runeDetonation = 6,
}
local icon = {
	runeDetonation = "Spell_Shadow_Teleport",
}
local color = {
	runeDetonation = "Red",
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
end

function module:OnSetup()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasAlerted = false
end

function module:OnEngage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasAlerted = false
end

function module:OnDisengage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasAlerted = false
end

function module:Event(msg)
	if string.find(msg, L["trigger_runeOfDetonationYou"]) then
		hasRuneOfDetonation = true
		self:Bar(L.bar_runeDetonation, timer.runeDetonation, icon.runeDetonation, true, color.runeDetonation)
		self:CheckRuneCombination()

	elseif msg == L["trigger_runeOfDetonationFade"] then
		hasRuneOfDetonation = false
		self:ClearRuneAlerts()

	elseif string.find(msg, L["trigger_runeOfPowerYou"]) then
		hasRuneOfPower = true
		self:CheckRuneCombination()

	elseif msg == L["trigger_runeOfPowerFade"] then
		hasRuneOfPower = false
		self:ClearRuneAlerts()
	end
end

function module:CheckRuneCombination()
	if not self.db.profile.runeofdetonation then return end

	if hasRuneOfDetonation and hasRuneOfPower then
		-- Only alert when transitioning into having both debuffs
		if not hasAlerted then
			self:Message(L["msg_runeCombo"], "Personal", false, nil, false)
			self:Sound("RunAway")
			self:WarningSign(icon.runeDetonation, 3)
			hasAlerted = true
		end
	else
		self:ClearRuneAlerts()
		hasAlerted = false
	end
end

function module:ClearRuneAlerts()
	self:RemoveWarningSign(icon.runeDetonation)
end
