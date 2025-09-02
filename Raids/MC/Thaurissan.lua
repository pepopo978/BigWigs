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
	bar_runeDetonation = "Rune of Detonation",
} end)

local hasRuneOfDetonation = false
local hasRuneOfPower = false

local timer = {
	runeDetonation = 6,
}
local icon = {
	runeDetonation = "inv_enchant_essenceastralsmall",
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
	if hasRuneOfDetonation and hasRuneOfPower and self.db.profile.runeofdetonation then
		self:Message(L["msg_runeCombo"], "Personal", false, nil, false)
		self:Sound("RunAway")
		self:WarningSign(icon.runeDetonation, 3)
	end
end

function module:ClearRuneAlerts()
	self:RemoveWarningSign(icon.runeDetonation)
end

function module:Test()
	BigWigs:ToggleActive(true)
	BigWigs:EnableModule(self:ToString())

	print("Testing Thaurissan Rune combinations...")
	
	-- Schedule the sequence of events
	self:ScheduleEvent("ThaurissanTest1", function()
		print("Test 1: Gaining Rune of Power (no alert expected)")
		self:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Rune of Power.")
	end, 0)

	self:ScheduleEvent("ThaurissanTest2", function()
		print("Test 2: Gaining Rune of Detonation while having Rune of Power (ALERT EXPECTED)")
		self:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Rune of Detonation.")
	end, 1)

	self:ScheduleEvent("ThaurissanTest3", function()
		print("Test 3: Losing Rune of Power while keeping Rune of Detonation (alert icon should clear)")
		self:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Rune of Power fades from you.")
	end, 3)

	self:ScheduleEvent("ThaurissanTest4", function()
		print("Test 4: Regaining Rune of Power while having Rune of Detonation (ALERT EXPECTED)")
		self:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Rune of Power.")
	end, 5)

	self:ScheduleEvent("ThaurissanTest5", function()
		print("Test 5: Losing Rune of Detonation (alert icon should clear)")
		self:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Rune of Detonation fades from you.")
	end, 7)
	
	self:ScheduleEvent("ThaurissanTestComplete", function()
		print("Thaurissan test sequence complete!")
	end, 8)
end
-- /run BigWigs:GetModule("Sorcerer-Thane Thaurissan"):Test()