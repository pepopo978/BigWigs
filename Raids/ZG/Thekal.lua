
local module, L = BigWigs:ModuleDeclaration("High Priest Thekal", "Zul'Gurub")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = {"bloodlust", "silence", "cleave", "heal", "disarm", -1, "phase", "punch", "tigers", "frenzy", "enraged", "bosskill"}
module.wipemobs = {"Zealot Zath", "Zealot Lor'Khan"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Thekal",
	
	heal_cmd = "heal",
	heal_name = "Heal alert",
	heal_desc = "Warn for Lor'Khan's heals.",

	bloodlust_cmd = "bloodlust",
	bloodlust_name = "Bloodlust alert",
	bloodlust_desc = "Announces which boss gets Bloodlust, for easy dispel announce.",

	silence_cmd = "silence",
	silence_name = "Silence",
	silence_desc = "Shows you who gets silenced.",

	disarm_cmd = "disarm",
	disarm_name = "Disarm",
	disarm_desc = "Warn for Zealot Lor'Khan's disarm.",

	cleave_cmd = "cleave",
	cleave_name = "Mortal Cleave notifications",
	cleave_desc = "Shows who has Mortal Strike-type debuff.",

	punch_cmd = "punch",
	punch_name = "Force Punch alert",
	punch_desc = "JUMP!",

	tigers_cmd = "tigers",
	tigers_name = "Tiger spawns",
	tigers_desc = "Warn for incoming tigers.",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy announce",
	frenzy_desc = "Warn when High Priest Thekal goes into a frenzy.",

	enraged_cmd = "enraged",
	enraged_name = "Enrage alert",
	enraged_desc = "Lets you know when the boss is enraged.",

	phase_cmd = "phase",
	phase_name = "Phase notification",
	phase_desc = "Announces the boss' phase transitions.",
	
	
	trigger_phase2 = "fill me with your RAGE!",

	msg_phase2 = "Tiger Phase",
	bar_phase2 = "Tiger Phase",
	
	trigger_tigers = "High Priest Thekal performs Summon Zulian Guardians.",
	msg_tigers = "Incoming Tigers!",
	
	trigger_forcePunch = "High Priest Thekal begins to perform Force Punch.",
	bar_forcePunch = "Force Punch",
	
	heal_trigger = "Zealot Lor'Khan begins to cast Great Heal.",
	heal_message = "Zealot Lor'Khan is Healing! Interrupt it!",
	heal_bar = "Great Heal",
	
	enrage_trigger = "High Priest Thekal gains Enrage\.",
	enrage_message = "Boss is enraged! Spam heals!",
	
	disarmself_trigger = "You are afflicted by Disarm.",
	disarmother_trigger = "(.+) is afflicted by Disarm.",
	disarm_bar = "Disarm: %s",
	
	mortalcleaveself_trigger = "You are afflicted by Mortal Cleave.",
	mortalcleaveother_trigger = "(.+) is afflicted by Mortal Cleave.",
	mortalcleave_bar = "Mortal Cleave: %s",
	
	silenceself_trigger = "You are afflicted by Silence.",
	silenceother_trigger = "(.+) is afflicted by Silence.",
	silenceselfend_trigger = "Silence fades from you.",
	silenceotherend_trigger = "Silence fades from (.+).",
	silence_announce = "Silence on %s! Dispel it!",
	silence_bar = "Silence: %s",
	
	bloodlustgain = "(.+) gains Bloodlust.",
	bloodlustend = "Bloodlust fades from (.+).",
	bloodlust_bar = "Bloodlust: %s",
	bloodlustannounce = "Dispel Bloodlust from %s!",
	
	frenzybegin_trigger = "High Priest Thekal gains Frenzy.",
	frenzyend_trigger = "Frenzy fades from High Priest Thekal.",
	frenzyann = "Frenzy! Tranq now!",
	frenzy_bar = "Frenzy",
	
	death_trigger = "dies.",
	zath_trigger = "Zealot Zath",
	lorkhan_trigger = "Zealot Lor'Khan",
	thekal_trigger = "High Priest Thekal",
	
	thekalrescast_trigger = "High Priest Thekal begins to cast Resurrection.",
	zathrescast_trigger = "Zealot Zath begins to cast Resurrection.",
	lorkhanrescast_trigger = "Zealot Lor'Khan begins to cast Resurrection.",

	["You have slain %s!"] = true,
	["Knockback"] = true,
	["New Adds"] = true,
	["Next Bloodlust"] = true,
} end )

local timer = {
	forcePunch = 1,
	phase2 = 9,
	knockback = 4,
	adds = 25,
	bloodlust = 30,
}
local icon = {
	forcePunch = "INV_Gauntlets_31",
	knockback = "Ability_WarStomp",
	adds = "Ability_Hunter_Pet_Cat",
	bloodlust = "Spell_Nature_BloodLust",
	heal = "Spell_Holy_Heal",
	frenzy = "Ability_Druid_ChallangingRoar",
	silence = "Spell_Holy_Silence",
	mortalCleave = "Ability_Warrior_SavageBlow",
	disarm = "Ability_Warrior_Disarm",
	phase2 = "Spell_Holy_PrayerOfHealing",
	
	hpBar = "spell_holy_prayerofspirit",
}
local color = {
	hpBar = "Magenta",
}
local syncName = {
	phase2 = "ThekalPhaseTwo"..module.revision,
	phasechange = "ThekalPhaseChange"..module.revision,
	heal = "ThekalLorkhanHeal"..module.revision,
	frenzy = "ThekalFrenzyStart"..module.revision,
	frenzyOver = "ThekalFrenzyStop"..module.revision,
	bloodlust = "ThekalBloodlustStart"..module.revision,
	bloodlustOver = "ThekalBloodlustStop"..module.revision,
	silence = "ThekalSilenceStart"..module.revision,
	silenceOver = "ThekalSilenceStop"..module.revision,
	mortalcleave = "ThekalMortalCleave"..module.revision,
	disarm = "ThekalDisarm"..module.revision,
	enrage = "ThekalEnrage"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") -- phase transition
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Fades")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Fades")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Fades")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")

	self:ThrottleSync(10, syncName.phase2)
	self:ThrottleSync(10, syncName.phasechange)
	self:ThrottleSync(5, syncName.heal)
	self:ThrottleSync(3, syncName.frenzy)
	self:ThrottleSync(3, syncName.frenzyOver)
	self:ThrottleSync(3, syncName.bloodlust)
	self:ThrottleSync(3, syncName.bloodlustOver)
	self:ThrottleSync(3, syncName.silence)
	self:ThrottleSync(3, syncName.silenceOver)
	self:ThrottleSync(5, syncName.mortalcleave)
	self:ThrottleSync(5, syncName.disarm)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
	zathdead = nil
	lorkhandead = nil
	thekaldead = nil
	
	self.zathHP = 100
	self.lorkhanHP = 100
	self.thekalHP = 100
end

function module:OnEngage()
	self.phase = 1
	self:ScheduleRepeatingEvent("checkphasechange", self.PhaseChangeCheck, 0.5, self)
	
	zathdead = nil
	lorkhandead = nil
	thekaldead = nil
	
	self.zathHP = 100
	self.lorkhanHP = 100
	self.thekalHP = 100
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Zath", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Zath", 0)
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Lor'Khan", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Lor'Khan", 0)
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "High Priest Thekal", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "High Priest Thekal", 0)
	
	self:ScheduleRepeatingEvent("thekalHpCheck", self.CheckHP, 0.5, self)
end

function module:OnDisengage()
end

function module:CheckHP()
	local zathHealth
	local lorkhanHealth
	local thekalHealth
	
	if UnitName("playertarget") == "Zealot Zath" then
		zathHealth = math.ceil((UnitHealth("playertarget") / UnitHealthMax("playertarget")) * 100)
	elseif UnitName("playertarget") == "Zealot Lor'Khan" then
		lorkhanHealth = math.ceil((UnitHealth("playertarget") / UnitHealthMax("playertarget")) * 100)
	elseif UnitName("playertarget") == "High Priest Thekal" then
		thekalHealth = math.ceil((UnitHealth("playertarget") / UnitHealthMax("playertarget")) * 100)
	end
	
	for i = 1, GetNumRaidMembers(), 1 do
		if UnitName("Raid"..i.."target") == "Zealot Zath" then
			zathHealth = math.ceil((UnitHealth("Raid"..i.."target") / UnitHealthMax("Raid"..i.."target")) * 100)
		elseif UnitName("Raid"..i.."target") == "Zealot Lor'Khan" then
			lorkhanHealth = math.ceil((UnitHealth("Raid"..i.."target") / UnitHealthMax("Raid"..i.."target")) * 100)
		elseif UnitName("Raid"..i.."target") == "High Priest Thekal" then
			thekalHealth = math.ceil((UnitHealth("Raid"..i.."target") / UnitHealthMax("Raid"..i.."target")) * 100)
		end
		if zathHealth and lorkhanHealth and thekalHealth then break; end
	end
	
	if zathHealth then
		self.zathHP = zathHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Zath", 100-self.zathHP)
	end
	if lorkhanHealth then
		self.lorkhanHP = lorkhanHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Lor'Khan", 100-self.lorkhanHP)
	end
	if thekalHealth then
		self.thekalHP = thekalHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, "High Priest Thekal", 100-self.thekalHP)
	end
end

-- override: only check for boss death in phase 2
function module:CheckForBossDeath(msg)
	if self.phase then
		self:DebugMessage("thekal death; phase: " .. self.phase .. " msg: " .. msg)
	end
	if self.phase == 2 then
		BigWigs:CheckForBossDeath(msg, self)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["trigger_phase2"]) then
		self:Sync(syncName.phase2)
	end
end

function module:PhaseChangeCheck()
	if self.phase == 1 then
		self:DebugMessage("PhaseChangeCheck")
		thekaldead = true
		zathdead = true
		lorkhandead = true
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == self.translatedName and not UnitIsDead("Raid"..i.."target") then
				thekaldead = nil
			elseif UnitName("Raid"..i.."target") == "Zealot Zath" and not UnitIsDead("Raid"..i.."target") then
				zathdead = nil
			elseif UnitName("Raid"..i.."target") == "Zealot Lor'Khan" and not UnitIsDead("Raid"..i.."target") then
				lorkhandead = nil
			end
		end

		if lorkhandead and zathdead and thekaldead then
			self:Sync(syncName.phasechange)
		end
	end
end

function module:Event(msg)
	local _,_,silenceother_triggerword = string.find(msg, L["silenceother_trigger"])
	local _,_,disarmother_triggerword = string.find(msg, L["disarmother_trigger"])
	local _,_,mortalcleaveother_triggerword = string.find(msg, L["mortalcleaveother_trigger"])
	if msg == L["trigger_tigers"] then
		self:Message(L["msg_tigers"], "Important")
	elseif msg == L["heal_trigger"] then
		self:Sync(syncName.heal)
	elseif msg == L["silenceself_trigger"] then
		self:Sync(syncName.silence .. " "..UnitName("player"))
	elseif silenceother_triggerword then
		self:Sync(syncName.silence .. " "..silenceother_triggerword)
	elseif msg == L["disarmself_trigger"] then
		self:Sync(syncName.disarm .. " "..UnitName("player"))
	elseif disarmother_triggerword then
		self:Sync(syncName.disarm .. " "..disarmother_triggerword)
	elseif msg == L["mortalcleaveself_trigger"] then
		self:Sync(syncName.mortalcleave .. " "..UnitName("player"))
	elseif mortalcleaveother_triggerword then
		self:Sync(syncName.mortalcleave .. " "..mortalcleaveother_triggerword)
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["death_trigger"]) then
		if arg2 == L["zath_trigger"] then
			zathdead = true
			if self.db.profile.bloodlust then
				self:RemoveBar(string.format(L["bloodlust_bar"], L["zath_trigger"]))
			end
		elseif arg2 == L["lorkhan_trigger"] then
			lorkhandead = true
			if self.db.profile.heal then
				self:RemoveBar(L["heal_bar"])
			end
			if self.db.profile.bloodlust then
				self:RemoveBar(string.format(L["bloodlust_bar"], L["lorkhan_trigger"]))
			end
		elseif arg2 == L["thekal_trigger"] then
			thekaldead = true
		end
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if msg == L["trigger_forcePunch"] then
		self:Bar(L["bar_forcePunch"], timer.forcePunch, icon.forcePunch, true, "red")
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	local _,_,bloodlustgainword = string.find(msg, L["bloodlustgain"])
	if msg == L["frenzybegin_trigger"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["enrage_trigger"] then
		self:Sync(syncName.enrage)
	elseif bloodlustgainword then
		self:Sync(syncName.bloodlust .. " " .. bloodlustgainword)
	end
end

function module:Fades(msg)
	local _,_,silenceotherend_triggerword = string.find(msg, L["silenceotherend_trigger"])
	local _,_,bloodlustendword = string.find(msg, L["bloodlustend"])
	if bloodlustendword then
		self:Sync(syncName.bloodlustOver .. " "..bloodlustendword)
	elseif msg == L["silenceselfend_trigger"] then
		self:Sync(syncName.silenceOver .. " "..UnitName("player"))
	elseif silenceotherend_triggerword then
		self:Sync(syncName.silenceOver .. " "..silenceotherend_triggerword)
	elseif msg == L["frenzyend_trigger"] then
		self:Sync(syncName.frenzyOver)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 and self.phase < 2 then
		self.phase = 2
		self:RemoveBar(L["bar_phase2"])
		self:TigerPhase()
	elseif sync == syncName.phasechange then
		self:CancelScheduledEvent("checkphasechange")
		self.phase = 1.5
		self:Bar(L["bar_phase2"], timer.phase2, icon.phase2, true, "White")
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Message(L["heal_message"], "Attention", "Alarm")
		self:Bar(L["heal_bar"], 4, icon.heal, true, "Blue")
	elseif sync == syncName.frenzy and self.db.profile.frenzy then
		self:Message(L["frenzyann"], "Important", true, "Alarm")
		self:Bar(L["frenzy_bar"], 8, icon.frenzy, true, "cyan")
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:RemoveBar(L["frenzy_bar"])
	elseif sync == syncName.bloodlust and self.db.profile.bloodlust then
		self:Message(string.format(L["bloodlustannounce"], rest), "Important")
		self:Bar(string.format(L["bloodlust_bar"], rest), 30, icon.bloodlust, true, "cyan")
	elseif sync == syncName.bloodlustOver and self.db.profile.bloodlust then
		self:RemoveBar(string.format(L["bloodlust_bar"], rest))
	elseif sync == syncName.silence and self.db.profile.silence then
		self:Message(string.format(L["silence_announce"], rest), "Attention")
		self:Bar(string.format(L["silence_bar"], rest), 6, icon.silence, true, "White")
	elseif sync == syncName.silenceOver and self.db.profile.silence then
		self:RemoveBar(string.format(L["silence_bar"], rest))
	elseif sync == syncName.mortalcleave and self.db.profile.cleave then
		self:Bar(string.format(L["mortalcleave_bar"], rest), 5, icon.mortalCleave, true, "black")
	elseif sync == syncName.disarm and self.db.profile.disarm then
		self:Bar(string.format(L["disarm_bar"], rest), 5, icon.disarm, true, "Yellow")
	elseif sync == syncName.enrage and self.db.profile.enraged then
		self:Message(L["enrage_message"], "Urgent")
	end
end

function module:TigerPhase()
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Zath")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Lor'Khan")
	self:TriggerEvent("BigWigs_StopHPBar", self, "High Priest Thekal")
	self:CancelScheduledEvent("thekalHpCheck")
	
	if self.db.profile.heal then
		self:RemoveBar(L["heal_bar"])
	end
	if self.db.profile.bloodlust then
		self:Bar(L["Next Bloodlust"], timer.bloodlust, icon.bloodlust, true, "cyan")
	end
	if self.db.profile.phase then
		self:Message(L["msg_phase2"], "Attention")
	end
	self:Bar(L["New Adds"], timer.adds, icon.adds, true, "blue")
	self:Bar(L["Knockback"], timer.knockback, icon.knockback, true, "red")
end
