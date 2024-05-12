local module, L = BigWigs:ModuleDeclaration("Heigan the Unclean", "Naxxramas")

module.revision = 30038
module.enabletrigger = module.translatedName
module.toggleoptions = { "fundance", "disease", "manaBurn", "teleport", "eruption", -1, "bosskill" }
module.defaultDB = {
	fundance = false,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Heigan",

		fundance_cmd = "fundance",
		fundance_name = "Safety Dance",
		fundance_desc = "You can dance if you want to!",

		disease_cmd = "disease",
		disease_name = "Decrepit Fever Alert",
		disease_desc = "Warn for Decrepit Fever",

		manaBurn_cmd = "manaBurn",
		manaBurn_name = "Mana Burn Alert",
		manaBurn_desc = "Warn for Mana Burn",

		teleport_cmd = "teleport",
		teleport_name = "Teleport Alert",
		teleport_desc = "Warn for Teleports.",

		eruption_cmd = "eruption",
		eruption_name = "Eruption Alert",
		eruption_desc = "Warn for Eruption",

		trigger_engage1 = "You are mine now!", --CHAT_MSG_MONSTER_YELL
		trigger_engage2 = "You...are next!", --CHAT_MSG_MONSTER_YELL
		trigger_engage3 = "I see you!", --CHAT_MSG_MONSTER_YELL

		trigger_die = "takes his last breath.", --to be confirmed

		trigger_disease = "afflicted by Decrepit Fever.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_disease = "Decrepit Fever CD",
		msg_disease = "Decrepit Fever",

		trigger_manaBurn = "Heigan the Unclean's Mana Burn", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		bar_manaBurn = "Mana Burn CD",

		trigger_manaBurnYou = "Heigan the Unclean's Mana Burn hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		msg_manaBurnYou = "Mana Burn hit you!",

		trigger_danceStart = "The end is upon you.", --CHAT_MSG_MONSTER_YELL
		msg_danceStart = "Teleport!",
		bar_dancing = "Dancing Ends",
		bar_dancingSoon = "Dancing Soon",



		msg_fightStart = "Fight!",
		bar_fighting = "Dancing Starts",

		bar_eruption = "Eruption",
	}
end)

local timer = {
	firstDiseaseCD = 30,
	firstDiseaseAfterDanceCD = 5,
	diseaseCD = { 20, 25 },

	firstManaBurnCD = 15,
	firstManaBurnAfterDanceCD = 10,
	manaBurnCD = 3,

	fightDuration = 90,
	danceDuration = 45,

	firstEruption = 15,
	firstDanceEruption = 4,
	eruption = 0, -- will be changed during the encounter
	eruptionSlow = 10,
	eruptionFast = 3.1, -- was getting slightly out of sync with it at 3, maybe only on vmangos?
	dancingSoon = 10,
}
local icon = {
	disease = "Ability_Creature_Disease_03",
	manaBurn = "Spell_Shadow_ManaBurn",
	fightDuration = "Spell_Magic_LesserInvisibilty",
	danceDuration = "Spell_Arcane_Blink",
	eruption = "spell_fire_selfdestruct",
	dancing = "INV_Gizmo_RocketBoot_01",
}
local syncName = {
	disease = "HeiganDisease" .. module.revision,
	manaBurn = "HeiganManaBurn" .. module.revision,
	danceStart = "HeiganToPlatform" .. module.revision,
	fightStart = "HeiganToFloor" .. module.revision,
}

local eruption_count = 1
local eruption_dir = 1
bwHeiganTimeFloorStarted = 0
bwHeiganTimePlatformStarted = 0

module:RegisterYellEngage(L["trigger_engage1"])
module:RegisterYellEngage(L["trigger_engage2"])
module:RegisterYellEngage(L["trigger_engage3"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--heiganDies
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")--DanceStart(Teleport)

	self:ThrottleSync(5, syncName.disease)
	self:ThrottleSync(1, syncName.manaBurn)
	self:ThrottleSync(1, syncName.danceStart)
	self:ThrottleSync(10, syncName.fightStart)
end

function module:OnSetup()
end

function module:OnEngage()
	bwHeiganTimeFloorStarted = GetTime()

	if self.db.profile.disease then
		self:Bar(L["bar_disease"], timer.firstDiseaseCD, icon.disease, true, "Green")
	end
	if self.db.profile.manaBurn then
		self:Bar(L["bar_manaBurn"], timer.firstManaBurnCD, icon.manaBurn, true, "Blue")
	end
	if self.db.profile.teleport then
		self:Bar(L["bar_fighting"], timer.fightDuration, icon.fightDuration, true, "White")
		self:DelayedBar(timer.fightDuration - 10, L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Cyan")
	end

	eruption_count = 1
	eruption_dir = 1
	timer.eruption = timer.eruptionSlow
	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.firstEruption, self)
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.firstEruption, icon.eruption, true, "Red")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_manaBurnYou"]) then
		if self.db.profile.manaBurn then
			if UnitClass("Player") ~= "Rogue" and UnitClass("Player") ~= "Warrior" then
				self:Message(L["msg_manaBurnYou"], "Important", nil, "Info")
				self:WarningSign(icon.manaBurn, 0.7)
			end
		end
	end
	if string.find(msg, L["trigger_die"]) then
		self:SendBossDeathSync()
	elseif string.find(msg, L["trigger_disease"]) then
		self:Sync(syncName.disease)
	elseif string.find(msg, L["trigger_manaBurn"]) then
		self:Sync(syncName.manaBurn)
	elseif string.find(msg, L["trigger_danceStart"]) then
		self:Sync(syncName.danceStart)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.disease and self.db.profile.disease then
		self:Disease()
	elseif sync == syncName.manaBurn and self.db.profile.manaBurn then
		self:ManaBurn()
	elseif sync == syncName.danceStart then
		self:DanceStart()
	elseif sync == syncName.fightStart then
		self:FightStart()
	end
end

function module:Disease()
	--start a bar only if enough time left before dancing
	if timer.diseaseCD[1] < (timer.fightDuration - (GetTime() - bwHeiganTimeFloorStarted)) then
		self:IntervalBar(L["bar_disease"], timer.diseaseCD[1], timer.diseaseCD[2], icon.disease, true, "Green")
	end
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Priest" then
		self:Message(L["msg_disease"], "Important", nil, "Info")
		self:WarningSign(icon.disease, 0.7)
	end
end

function module:ManaBurn()
	--start a bar only if enough time left before dancing
	if timer.manaBurnCD < (timer.fightDuration - (GetTime() - bwHeiganTimeFloorStarted)) then
		self:Bar(L["bar_manaBurn"], timer.manaBurnCD, icon.manaBurn, true, "Blue")
	end
end

function module:DanceStart()
	self:CancelScheduledEvent("HeiganEruption")
	self:RemoveBar(L["bar_disease"])
	self:RemoveBar(L["bar_manaBurn"])
	self:RemoveBar(L["bar_fighting"])
	self:RemoveBar(L["bar_dancingSoon"])

	eruption_count = 1
	timer.eruption = timer.eruptionFast

	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.firstDanceEruption, self)
	self:ScheduleEvent("bwHeiganToFloor", self.FightStart, timer.danceDuration, self)

	if self.db.profile.teleport then
		self:Message(string.format(L["msg_danceStart"], timer.danceDuration), "Attention")
		self:Bar(L["bar_dancing"], timer.danceDuration, icon.danceDuration, true, "White")
		if self.db.profile.fundance then
			BigWigsSound:BigWigs_Sound("FunDance")
		else
			BigWigsSound:BigWigs_Sound("Dance")
		end
	end
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.firstDanceEruption, icon.eruption, true, "Red")
	end
end

function module:FightStart()
	self:CancelScheduledEvent("bwHeiganToFloor")
	self:CancelScheduledEvent("HeiganEruption")

	eruption_count = 1
	timer.eruption = timer.eruptionSlow
	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)

	if self.db.profile.teleport then
		self:Message(L["msg_fightStart"], "Attention")
		self:Bar(L["bar_fighting"], timer.fightDuration, icon.fightDuration, true, "White")
		self:DelayedBar(timer.fightDuration - 10, L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Cyan")
	end
	if self.db.profile.disease then
		self:Bar(L["bar_disease"], timer.firstDiseaseAfterDanceCD, icon.disease, true, "Green")
	end
	if self.db.profile.manaBurn then
		self:Bar(L["bar_manaBurn"], timer.firstManaBurnAfterDanceCD, icon.manaBurn, true, "Blue")
	end
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
	end
end

function module:Eruption()
	eruption_count = eruption_count + 1 * eruption_dir
	if eruption_count == 4 then
		eruption_dir = -1
	end
	if eruption_count == 1 then
		eruption_dir = 1
	end

	local registered, time, elapsed = self:BarStatus(L["bar_fighting"])
	if registered and timer and elapsed then
		local remaining = time - elapsed
		if timer.eruption + 1 < remaining then
			if self.db.profile.eruption then
				self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
			end
			self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)
		else
			if self.db.profile.teleport then
				self:Sound("Beware")
				self:Bar(L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Blue")
			end
		end
	else
		if self.db.profile.eruption then
			self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
		end
		self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)
	end
end

function eruption_help(inp)
	return ' ' .. inp
end
