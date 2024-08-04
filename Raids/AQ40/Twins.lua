local module, L = BigWigs:ModuleDeclaration("The Twin Emperors", "Ahn'Qiraj")

module.revision = 30075
local veklor = AceLibrary("Babble-Boss-2.2")["Emperor Vek'lor"]
local veknilash = AceLibrary("Babble-Boss-2.2")["Emperor Vek'nilash"]
local boss = AceLibrary("Babble-Boss-2.2")["The Twin Emperors"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. boss)
module.enabletrigger = {veklor, veknilash}
module.toggleoptions = {"teleport", "enrage", "blizzard", "bug", "heal", "targeticon", "bosskill"}

module.defaultDB = {
	enrage = false,
}

L:RegisterTranslations("enUS", function()
	return {
	cmd = "Twins",
	
	teleport_cmd = "teleport",
	teleport_name = "Teleport Alert",
	teleport_desc = "Warn for Teleport",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	blizzard_cmd = "blizzard",
	blizzard_name = "Blizzard Alert",
	blizzard_desc = "Warn for Blizzard",
	
	bug_cmd = "bug",
	bug_name = "Exploding Bug Alert",
	bug_desc = "Warn for exploding bugs",

	heal_cmd = "heal",
	heal_name = "Heal Alert",
	heal_desc = "Warn for Twins Healing",
	
	targeticon_cmd = "targeticon",
	targeticon_name = "Twins' targets raid icon",
	targeticon_desc = "Puts a star on the caster twin's target and a skull on the melee twin's target",
	
	
	trigger_tp = "gains Twin Teleport.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_tpCd = "Teleport CD",
	bar_tpOffCd = "Teleport Ready...",
	msg_tpOffCd = "Teleport within 10sec!",
	
	trigger_enrage = "Emperor Vek'nilash becomes enraged.",--??
	trigger_enrage2 = "Emperor Vek'lor becomes enraged.",--??
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 60 seconds",
	msg_enrage10 = "Enrage in 10 seconds",
	msg_enrage = "Twins are enraged",
	
	trigger_blizzard = "You are afflicted by Blizzard.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_blizzardFade = "Blizzard fades from you.",--CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_blizzard = "Run from Blizzard!",
	
	trigger_explode = "is afflicted by Explode Bug.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	msg_explode = "Bug exploding nearby!",
	
	trigger_heal = "Heal Brother heals",--??
	msg_heal = "Twins are healing, separate them!",

	pull_trigger1 = "Ah, lambs to the slaughter.",
	pull_trigger2 = "Prepare to embrace oblivion!",
	pull_trigger3 = "Join me brother, there is blood to be shed.",
	pull_trigger4 = "To decorate our halls.",
	pull_trigger5 = "Let none survive!",
	pull_trigger6 = "It's too late to turn away.",
	pull_trigger7 = "Look brother, fresh blood.",
	pull_trigger8 = "Like a fly in a web.",
	pull_trigger9 = "Shall be your undoing!",
	pull_trigger10 = "Your brash arrogance",

	kill_trigger = "My brother...NO!",
	}
end)

local timer = {
	tpInterval = {30,40},
	tpReady = 10,
	enrage = 900,
	blizzard = 10,
}
local icon = {
	tp = "Spell_Arcane_Blink",
	enrage = "Spell_Shadow_UnholyFrenzy",
	blizzard = "Spell_Frost_IceStorm",
	explode = "spell_fire_fire",
	heal = "spell_nature_healingwavegreater",
}
local color = {
	tpCd = "White",
	tpReady = "Cyan",
	enrage = "Black",
}
local syncName = {
	tp = "TwinsTeleport"..module.revision,
	enrage = "TwinsEnrage"..module.revision,
	heal = "TwinsHeal"..module.revision,
}

module:RegisterYellEngage(L["pull_trigger1"])
module:RegisterYellEngage(L["pull_trigger2"])
module:RegisterYellEngage(L["pull_trigger3"])
module:RegisterYellEngage(L["pull_trigger4"])
--module:RegisterYellEngage(L["pull_trigger5"]) Doesn't appear to be used in vmangos and KT says the same text
module:RegisterYellEngage(L["pull_trigger6"])
module:RegisterYellEngage(L["pull_trigger7"])
module:RegisterYellEngage(L["pull_trigger8"])
module:RegisterYellEngage(L["pull_trigger9"])
module:RegisterYellEngage(L["pull_trigger10"])

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --pull trigger, kill trigger
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_blizzard
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_blizzardFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_tp

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --probably enrage


	self:ThrottleSync(28, syncName.tp)
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.heal)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.core:IsModuleActive("Anubisath Defender", "Ahn'Qiraj") then self:TriggerEvent("BigWigs_RebootModule", "Anubisath Defender", "Ahn'Qiraj") end
		
	self:Sync(syncName.tp)

	if self.db.profile.enrage then
		self:DelayedBar(timer.enrage - 60, L["bar_enrage"], 60, icon.enrage, true, color.enrage)
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Urgent", false, nil, false)
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Urgent", false, nil, false)
	end
	
	if self.db.profile.targetIcon then
		self:ScheduleRepeatingEvent("veklorTargetCheck", self.VeklorTarget, 0.5, self)
		self:ScheduleRepeatingEvent("veknilashTargetCheck", self.VeknilashTarget, 0.5, self)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("veklorTargetCheck")
	self:CancelScheduledEvent("veknilashTargetCheck")
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, veklor) or msg == string.format(UNITDIESOTHER, veknilash) then
		self:SendBossDeathSync()
	end
end

function module:VeklorTarget()
	if UnitName("target") ~= nil and UnitName("targettarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("target") == "Emperor Vek'lor" then
			SetRaidTarget("targettarget",1)
		end
	end
end

function module:VeknilashTarget()
	if UnitName("target") ~= nil and UnitName("targettarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("target") == "Emperor Vek'nilash" then
			SetRaidTarget("targettarget",8)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["kill_trigger"]) then
		self:SendBossDeathSync()
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_tp"]) then
		self:Sync(syncName.tp)
		
	elseif string.find(msg, L["trigger_enrage"]) or string.find(msg, L["trigger_enrage2"]) then
		self:Sync(syncName.enrage)
		
	elseif msg == L["trigger_blizzard"] and self.db.profile.blizzard then
		self:Blizzard()
	elseif msg == L["trigger_blizzardFade"] and self.db.profile.blizzard then
		self:BlizzardFade()
	
	elseif string.find(msg, L["trigger_explode"]) and self.db.profile.bug then
		self:Explode()
	
	elseif string.find(msg, L["trigger_heal"]) then
		self:Sync(syncName.heal)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.tp and self.db.profile.teleport then
		self:TP()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	end
end

function module:TP()
	self:CancelDelayedBar(L["bar_tpOffCd"])
	self:CancelDelayedSound("One")
	self:CancelDelayedMessage(L["msg_tpOffCd"])
	self:CancelDelayedBar(L["bar_tpOffCd"])
	self:RemoveBar(L["bar_tpOffCd"])
	
	self:IntervalBar(L["bar_tpCd"], timer.tpInterval[1], timer.tpInterval[2], icon.tp, true, color.tpCd)
	
	self:DelayedSound(timer.tpInterval[1] - 10, "Ten")
	self:DelayedSound(timer.tpInterval[1] - 3, "Three")
	self:DelayedSound(timer.tpInterval[1] - 2, "Two")
	self:DelayedSound(timer.tpInterval[1] - 1, "One")
	self:DelayedMessage(timer.tpInterval[1] - 0.1, L["msg_tpOffCd"], "Attention", false, nil, false)

	self:DelayedBar(timer.tpInterval[1], L["bar_tpOffCd"], timer.tpReady, icon.tp, true, color.tpReady)
end

function module:Enrage()
	self:CancelDelayedBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:WarningSign(icon.enrage, 0.7)
	self:Sound("Beware")
end

function module:Blizzard()
	self:Message(L["msg_blizzard"], "Personal", false, nil, false)
	self:WarningSign(icon.blizzard, timer.blizzard)
	self:Sound("Info")
end

function module:BlizzardFade()
	self:RemoveWarningSign(icon.blizzard)
end

function module:Explode()
	self:Message(L["msg_explode"], "Personal", false, nil, false)
	self:WarningSign(icon.explode, 0.7)
end

function module:Heal()
	self:Message(L["msg_heal"], "Important", false, nil, false)
	self:WarningSign(icon.heal, 2)
end
