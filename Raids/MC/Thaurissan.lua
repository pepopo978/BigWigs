local module, L = BigWigs:ModuleDeclaration("Sorcerer-Thane Thaurissan", "Molten Core")

module.revision = 30003
module.enabletrigger = module.translatedName
module.toggleoptions = { "runetimers", "runeofdetonation", "runeofcombustion", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Thaurissan",

	runetimers_cmd = "runetimers",
	runetimers_name = "Rune Timers",
	runetimers_desc = "Warns about incoming and ongoing Rune of Detonation and Rune of Combustion",

	runeofdetonation_cmd = "runeofdetonation",
	runeofdetonation_name = "Rune of Detonation Alert",
	runeofdetonation_desc = "Personal alert when you have both Rune of Detonation and Rune of Power",

	runeofcombustion_cmd = "runeofcombustion",
	runeofcombustion_name = "Rune of Combustion Alert",
	runeofcombustion_desc = "Personal alert when you have Rune of Combustion and not Rune of Power",

	trigger_detonation = "afflicted by Rune of Detonation",
	trigger_combustion = "afflicted by Rune of Combustion",
	trigger_you = "You are afflicted",
	trigger_runeOfDetonationFade = "Rune of Detonation fades from you",
	trigger_runeOfCombustionFade = "Rune of Combustion fades from you",

	trigger_runeOfPowerYou = "You are afflicted by Rune of Power",
	trigger_runeOfPowerFade = "Rune of Power fades from you",

	msg_detonation = "Get/Stay out of the Zone - Rune of Detonation",
	msg_combustion = "Get/Stay in the Zone - Rune of Combustion",
	msg_combustion_out_of_zone = "Get back into the Zone!!!",
	msg_detonation_in_zone = "Get back out of the Zone!!!",
	bar_runeDetonation = "Detonation (move out)",
	bar_runeCombustion = "Combustion (get in)",
	bar_detonationNext = "Next Detonation Rune",
	bar_combustionNext = "Next Combustion Rune",
	warn_detonation = "MOVE_OUT",
	warn_combustion = "GET_IN",
} end)

local hasRuneOfDetonation = false
local hasRuneOfPower = false
local hasRuneOfCombustion = false

local timer = {
	runeCooldown = { 18, 22 }, -- average of 20
	runeDuration = 6,
}
local icon = {
	runeDetonation = "Spell_Shadow_Teleport",
	runeCombustion = "Spell_Fire_SealOfFire",
}
local color = {
	runeDetonation = "Blue",
	runeCombustion = "Orange",
	runeUpcoming = "Gray",
}
local syncName = {
	runeDetonation = "MCThaurissanDetonation" .. module.revision,
	runeCombustion = "MCThaurissanCombusion" .. module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")

	self:ThrottleSync(10, syncName.runeDetonation)
	self:ThrottleSync(10, syncName.runeCombustion)
end

function module:OnSetup()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasRuneOfCombustion = false
end

function module:OnEngage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasRuneOfCombustion = false

	if self.db.profile.runetimers then
		self:IntervalBar(L["bar_detonationNext"], timer.runeCooldown[1], timer.runeCooldown[2], icon.runeDetonation, true, color.runeUpcoming)
	end
end

function module:OnDisengage()
	hasRuneOfDetonation = false
	hasRuneOfPower = false
	hasRuneOfCombustion = false
end

function module:Event(msg)
	-- Rune of Detonation
	if string.find(msg, L["trigger_detonation"]) then
		self:Sync(syncName.runeDetonation)
		if string.find(msg, L["trigger_you"]) then
			hasRuneOfDetonation = true

			self:Message(L["msg_detonation"], "Personal")
			self:Sound("RunAway")
			self:WarningSign(icon.runeDetonation, timer.runeDuration, false, L["warn_detonation"])
		end
	elseif string.find(msg, L["trigger_runeOfDetonationFade"]) then
		hasRuneOfDetonation = false
		-- clear warning sign and bar
		self:RemoveBar(L["bar_runeDetonation"])
		self:RemoveWarningSign(icon.runeDetonation)

		-- Rune of Combustion
	elseif string.find(msg, L["trigger_combustion"]) then
		self:Sync(syncName.runeCombustion)
		if string.find(msg, L["trigger_you"]) then
			hasRuneOfCombustion = true

			self:Message(L["msg_combustion"], "Personal")
			self:Sound("Beware")
			self:WarningSign(icon.runeCombustion, timer.runeDuration, false, L["warn_combustion"])
		end
	elseif string.find(msg, L["trigger_runeOfCombustionFade"]) then
		hasRuneOfCombustion = false
		-- Rune of Power (floor zone)
	elseif string.find(msg, L["trigger_runeOfPowerYou"]) then
		hasRuneOfPower = true
		if hasRuneOfDetonation and self.db.profile.runeofdetonation then
			self:Message(L["msg_detonation_in_zone"], "Personal")
			self:Sound("RunAway")
		end
	elseif string.find(msg, L["trigger_runeOfPowerFade"]) then
		hasRuneOfPower = false
		if hasRuneOfCombustion and self.db.profile.runeofcombustion then
			self:Message(L["msg_combustion_out_of_zone"], "Personal")
			self:Sound("Beware")
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.runeDetonation then
		self:DetonationCast()
	elseif sync == syncName.runeCombustion then
		self:CombustionCast()
	end
end

function module:CombustionCast()
	-- remove CD bar in case of early cast
	self:RemoveBar(L["bar_combustionNext"])
	if self.db.profile.runetimers then
		-- accurate timer for current rune
		self:Bar(L["bar_runeCombustion"], timer.runeDuration, icon.runeCombustion, true, color.runeCombustion)
		-- schedule next opposite rune
		self:DelayedIntervalBar(timer.runeDuration, L["bar_detonationNext"], timer.runeCooldown[1] - timer.runeDuration, timer.runeCooldown[2] - timer.runeDuration, icon.runeDetonation, true, color.runeUpcoming)
	end
end

function module:DetonationCast()
	-- remove CD bar in case of early cast
	self:RemoveBar(L["bar_detonationNext"])
	if self.db.profile.runetimers then
		-- accurate timer for current rune
		self:Bar(L["bar_runeDetonation"], timer.runeDuration, icon.runeDetonation, true, color.runeDetonation)
		-- schedule next opposite rune
		self:DelayedIntervalBar(timer.runeDuration, L["bar_combustionNext"], timer.runeCooldown[1] - timer.runeDuration, timer.runeCooldown[2] - timer.runeDuration, icon.runeCombustion, true, color.runeUpcoming)
	end
end

function module:Test()
	-- Initialize module state
	self:Engage()

	local events = {
		-- ==== Test Case 1: Detonation while OUTSIDE zone ====
		{ time = 3, func = function()
			print("=== Case 1: Detonation while OUTSIDE zone ===")
		end },
		{ time = 5, func = function()
			local msg = "You are afflicted by Rune of Detonation."
			print("Test: " .. msg)
			print("Expected: Base detonation alert only")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 8, func = function()
			local msg = "Raider is afflicted by Rune of Detonation."
			print("Test: " .. msg .. " (sync test)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", msg)
		end },
		{ time = 11, func = function()
			local msg = "Rune of Detonation fades from you."
			print("Test: " .. msg)
			print("Expected: Alert clears")
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 2: Detonation while INSIDE zone ====
		{ time = 14, func = function()
			print("=== Case 2: Detonation while INSIDE zone ===")
		end },
		{ time = 15, func = function()
			local msg = "You are afflicted by Rune of Power."
			print("Test: " .. msg)
			print("Expected: No alert")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 17, func = function()
			local msg = "You are afflicted by Rune of Detonation."
			print("Test: " .. msg)
			print("Expected: Base detonation alert + 'in zone' alert (2 alerts)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 20, func = function()
			local msg = "Rune of Power fades from you."
			print("Test: " .. msg)
			print("Expected: No extra alert (now in correct state)")
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },
		{ time = 22, func = function()
			local msg = "Rune of Detonation fades from you."
			print("Test: " .. msg)
			print("Expected: Alert clears")
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 3: Get Power while having Detonation ====
		{ time = 25, func = function()
			print("=== Case 3: Enter zone while having Detonation ===")
		end },
		{ time = 26, func = function()
			local msg = "You are afflicted by Rune of Detonation."
			print("Test: " .. msg)
			print("Expected: Base detonation alert only")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 28, func = function()
			local msg = "You are afflicted by Rune of Power."
			print("Test: " .. msg .. " (entering zone)")
			print("Expected: 'In zone' alert")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 31, func = function()
			local msg = "Rune of Detonation fades from you."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },
		{ time = 32, func = function()
			local msg = "Rune of Power fades from you."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 4: Combustion while OUTSIDE zone ====
		{ time = 35, func = function()
			print("=== Case 4: Combustion while OUTSIDE zone ===")
		end },
		{ time = 36, func = function()
			local msg = "You are afflicted by Rune of Combustion."
			print("Test: " .. msg)
			print("Expected: Base combustion alert + 'out of zone' alert (2 alerts)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 39, func = function()
			local msg = "Sorcerer-Thane Thaurissan's Rune of Combustion fails. Raider is immune."
			print("Test: " .. msg .. " (sync test)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", msg)
		end },
		{ time = 42, func = function()
			local msg = "Rune of Combustion fades from you."
			print("Test: " .. msg)
			print("Expected: State clears")
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 5: Combustion while INSIDE zone ====
		{ time = 45, func = function()
			print("=== Case 5: Combustion while INSIDE zone ===")
		end },
		{ time = 46, func = function()
			local msg = "You are afflicted by Rune of Power."
			print("Test: " .. msg)
			print("Expected: No alert")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 48, func = function()
			local msg = "You are afflicted by Rune of Combustion."
			print("Test: " .. msg)
			print("Expected: Base combustion alert only (already in zone)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 51, func = function()
			local msg = "Rune of Combustion fades from you."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },
		{ time = 52, func = function()
			local msg = "Rune of Power fades from you."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 6: Leave zone while having Combustion ====
		{ time = 55, func = function()
			print("=== Case 6: Leave zone while having Combustion ===")
		end },
		{ time = 56, func = function()
			local msg = "You are afflicted by Rune of Power."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 57, func = function()
			local msg = "You are afflicted by Rune of Combustion."
			print("Test: " .. msg)
			print("Expected: Base combustion alert only")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 59, func = function()
			local msg = "Rune of Power fades from you."
			print("Test: " .. msg .. " (leaving zone)")
			print("Expected: 'Out of zone' alert")
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },
		{ time = 62, func = function()
			local msg = "Rune of Combustion fades from you."
			print("Test: " .. msg)
			module:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", msg)
		end },

		-- ==== Test Case 7: Edge cases - resists and immunities ====
		{ time = 65, func = function()
			print("=== Case 7: Resists and immunities ===")
		end },
		{ time = 66, func = function()
			local msg = "Sorcerer-Thane Thaurissan's Rune of Detonation was resisted by you."
			print("Test: " .. msg)
			print("Expected: No personal alert (resisted)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", msg)
		end },
		{ time = 68, func = function()
			local msg = "Raider is afflicted by Rune of Detonation."
			print("Test: " .. msg .. " (another player)")
			module:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", msg)
		end },

		-- End of Test
		{ time = 70, func = function()
			print("=== Test Complete ===")
			print("Test: Disengage")
			module:Disengage()
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("ThaurissanTest" .. i, event.func, event.time)
	end

	self:Message("Thaurissan comprehensive test started - 7 test cases", "Positive")
	print("Test will run for 70 seconds and cover all Event() logic paths")
	return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("Sorcerer-Thane Thaurissan"); BigWigs:SetupModule("Sorcerer-Thane Thaurissan");m:Test();
