
local module, L = BigWigs:ModuleDeclaration("Ursol", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"transition", "roarofterror", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Ursol",

	transition_cmd = "transition",
	transition_name = "Phase Transition Timers",
	transition_desc = "Timers for the Ursol/Ursoc transition phases",

	roarofterror_cmd = "roarofterror",
	roarofterror_name = "Roar of Terror",
	roarofterror_desc = "Timer for Roar of Terror cast",

	trigger_transition = "Miserable insects like",
	trigger_bearGod = "You gain Blessing of the Bear God",
	trigger_presenceFadeUrsol = "Presence of the Wild God fades from Ursol",
	trigger_roarOfTerrorCast = "Ursol begins to cast Roar of Terror",

	bar_presenceOfWildGod = "RP - Immune",
	bar_blessingOfBearGod = "Add Phase",
	bar_roarOfTerror = "Roar of Terror",
	msg_roarOfTerror = "Roar of Terror - Touch a Pool!",
} end )

local timer = {
	presenceOfWildGod = 30,
	blessingOfBearGod = 92,
	roarOfTerror      = 5,
}

local color = {
	presenceOfWildGod = "White",
	blessingOfBearGod = "Green",
	roarOfTerror      = "Orange",
}

local icon = {
	presenceOfWildGod = "Spell_Shadow_Cripple",
	blessingOfBearGod = "Spell_Holy_PowerInfusion",
	roarOfTerror      = "Ability_Druid_ChallangingRoar",
	tremorTotem       = "Spell_Nature_TremorTotem",
}

local syncName = {
	transition        = "UrsolTransition"..module.revision,
	blessingOfBearGod = "UrsolBlessingOfBearGod"..module.revision,
	presenceFadeUrsol = "UrsolPresenceFadeUrsol"..module.revision,
	roarOfTerror      = "UrsolRoarOfTerror"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CastEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "BuffEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FadeEvent")
	self:ThrottleSync(5, syncName.transition)
	self:ThrottleSync(120, syncName.blessingOfBearGod)
	self:ThrottleSync(5, syncName.presenceFadeUrsol)
	self:ThrottleSync(5, syncName.roarOfTerror)
end

function module:OnSetup()
end
function module:OnEngage() end
function module:OnDisengage() end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["trigger_transition"]) then
		self:Sync(syncName.transition)
	end
end

function module:CastEvent(msg)
	if string.find(msg, L["trigger_roarOfTerrorCast"]) then
		self:Sync(syncName.roarOfTerror)
	end
end

function module:BuffEvent(msg)
	if string.find(msg, L["trigger_bearGod"]) then
		self:Sync(syncName.blessingOfBearGod)
	end
end

function module:FadeEvent(msg)
	if string.find(msg, L["trigger_presenceFadeUrsol"]) then
		self:Sync(syncName.presenceFadeUrsol)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.transition and self.db.profile.transition then
		self:Bar(L["bar_presenceOfWildGod"], timer.presenceOfWildGod, icon.presenceOfWildGod, color.presenceOfWildGod)
	elseif sync == syncName.blessingOfBearGod and self.db.profile.transition then
		self:Bar(L["bar_blessingOfBearGod"], timer.blessingOfBearGod, icon.blessingOfBearGod, color.blessingOfBearGod)
	elseif sync == syncName.roarOfTerror and self.db.profile.roarofterror then
		self:Message(L["msg_roarOfTerror"], "Urgent")
		self:Bar(L["bar_roarOfTerror"], timer.roarOfTerror, icon.roarOfTerror, color.roarOfTerror)
		if UnitClass("Player") == "Shaman" then
			self:WarningSign(icon.tremorTotem, 2)
		end
	elseif sync == syncName.presenceFadeUrsol and self.db.profile.transition then
		self:RemoveBar(L["bar_blessingOfBearGod"])
	end
end

-- Full phase transition test: transition yell -> Presence bar, then Bear God
-- gain -> grace bar, then Presence fades from Ursol -> grace bar removed.
-- Timings compressed to ~20s. Also fires a Roar of Terror mid-sequence to
-- verify it coexists with transition bars.
-- Usage: /run local m=BigWigs:GetModule("Ursol"); BigWigs:SetupModule("Ursol"); m:TestTransition();
function module:TestTransition()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ursol transition test started", "Positive")

	-- t=2: Roar of Terror begins (pre-transition, normal combat)
	self:ScheduleEvent("UrsolTestRoar1", self.CastEvent, 2, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")

	-- t=9: transition yell (Presence of the Wild God applied)
	self:ScheduleEvent("UrsolTestTransition", self.CHAT_MSG_MONSTER_YELL, 9, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")

	-- t=12: Bear God buff gained (Presence faded from players)
	self:ScheduleEvent("UrsolTestBearGod", self.BuffEvent, 12, self,
		"You gain Blessing of the Bear God (1).")

	-- t=17: Presence fades from Ursol (grace bar removed early)
	self:ScheduleEvent("UrsolTestPresenceFade", self.FadeEvent, 17, self,
		"Presence of the Wild God fades from Ursol.")

	self:ScheduleEvent("UrsolTestTransitionEnd", function()
		module:Message("Ursol transition test complete", "Positive")
		module:SendBossDeathSync()
	end, 19)
	return true
end

-- Roar of Terror cast bar test with two casts back-to-back to verify the
-- throttle allows a second cast after 5s.
-- Usage: /run local m=BigWigs:GetModule("Ursol"); BigWigs:SetupModule("Ursol"); m:TestRoar();
function module:TestRoar()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ursol Roar of Terror test started", "Positive")

	-- t=2: first cast
	self:ScheduleEvent("UrsolTestRoar1", self.CastEvent, 2, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")

	-- t=9: second cast (7s later, past the 5s throttle)
	self:ScheduleEvent("UrsolTestRoar2", self.CastEvent, 9, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")

	self:ScheduleEvent("UrsolTestRoarEnd", function()
		module:Message("Ursol Roar of Terror test complete", "Positive")
		module:SendBossDeathSync()
	end, 16)
	return true
end

-- Edge case: Bear God buff arrives before the transition yell sync is
-- processed (out-of-order events). Grace bar should still appear. Then
-- fires transition yell after to verify Presence bar still works when late.
-- Usage: /run local m=BigWigs:GetModule("Ursol"); BigWigs:SetupModule("Ursol"); m:TestOutOfOrder();
function module:TestOutOfOrder()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ursol out-of-order test started", "Positive")

	-- t=2: Bear God arrives first (before transition yell)
	self:ScheduleEvent("UrsolTestOOOBearGod", self.BuffEvent, 2, self,
		"You gain Blessing of the Bear God (1).")

	-- t=4: transition yell arrives late
	self:ScheduleEvent("UrsolTestOOOTransition", self.CHAT_MSG_MONSTER_YELL, 4, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")

	-- t=10: Presence fades from Ursol
	self:ScheduleEvent("UrsolTestOOOFade", self.FadeEvent, 10, self,
		"Presence of the Wild God fades from Ursol.")

	self:ScheduleEvent("UrsolTestOOOEnd", function()
		module:Message("Ursol out-of-order test complete", "Positive")
		module:SendBossDeathSync()
	end, 12)
	return true
end

-- Edge case: transition fires but Presence fades from Ursol never arrives
-- (e.g. wipe during add phase). Grace bar should run its full duration
-- without being removed. Also fires a Roar of Terror during the grace
-- phase to verify both bar types coexist.
-- Usage: /run local m=BigWigs:GetModule("Ursol"); BigWigs:SetupModule("Ursol"); m:TestNoFade();
function module:TestNoFade()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ursol no-fade test started (grace bar runs full duration)", "Positive")

	-- t=2: transition yell
	self:ScheduleEvent("UrsolTestNFTransition", self.CHAT_MSG_MONSTER_YELL, 2, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")

	-- t=5: Bear God
	self:ScheduleEvent("UrsolTestNFBearGod", self.BuffEvent, 5, self,
		"You gain Blessing of the Bear God (1).")

	-- t=8: Roar during grace phase
	self:ScheduleEvent("UrsolTestNFRoar", self.CastEvent, 8, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")

	-- No Presence fade — grace bar should expire naturally
	self:ScheduleEvent("UrsolTestNFEnd", function()
		module:Message("Ursol no-fade test complete", "Positive")
		module:SendBossDeathSync()
	end, 15)
	return true
end

-- Duplicate event stress test: fires the same events multiple times rapidly
-- to verify throttling prevents duplicate bars.
-- Usage: /run local m=BigWigs:GetModule("Ursol"); BigWigs:SetupModule("Ursol"); m:TestThrottle();
function module:TestThrottle()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ursol throttle test started", "Positive")

	-- t=2: transition yell fired 3 times in 0.5s (only first should create bar)
	self:ScheduleEvent("UrsolTestThr1", self.CHAT_MSG_MONSTER_YELL, 2, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")
	self:ScheduleEvent("UrsolTestThr2", self.CHAT_MSG_MONSTER_YELL, 2.2, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")
	self:ScheduleEvent("UrsolTestThr3", self.CHAT_MSG_MONSTER_YELL, 2.5, self,
		"No!! Miserable insects like\226\128\166 like you\226\128\166!")

	-- t=5: Bear God fired twice (only first should create bar)
	self:ScheduleEvent("UrsolTestThrBG1", self.BuffEvent, 5, self,
		"You gain Blessing of the Bear God (1).")
	self:ScheduleEvent("UrsolTestThrBG2", self.BuffEvent, 5.3, self,
		"You gain Blessing of the Bear God (1).")

	-- t=8: Roar fired 3 times rapidly
	self:ScheduleEvent("UrsolTestThrR1", self.CastEvent, 8, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")
	self:ScheduleEvent("UrsolTestThrR2", self.CastEvent, 8.1, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")
	self:ScheduleEvent("UrsolTestThrR3", self.CastEvent, 8.3, self,
		"Ursol begins to cast Roar of Terror(37087) on Ursol.")

	-- t=11: Presence fade fired twice (only first should remove bar)
	self:ScheduleEvent("UrsolTestThrPF1", self.FadeEvent, 11, self,
		"Presence of the Wild God fades from Ursol.")
	self:ScheduleEvent("UrsolTestThrPF2", self.FadeEvent, 11.2, self,
		"Presence of the Wild God fades from Ursol.")

	self:ScheduleEvent("UrsolTestThrEnd", function()
		module:Message("Ursol throttle test complete", "Positive")
		module:SendBossDeathSync()
	end, 13)
	return true
end