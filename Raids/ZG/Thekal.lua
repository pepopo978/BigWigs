
local module, L = BigWigs:ModuleDeclaration("High Priest Thekal", "Zul'Gurub")

module.revision = 30083
module.enabletrigger = module.translatedName
module.wipemobs = {"Zealot Zath", "Zealot Lor'Khan"}
module.toggleoptions = {
	"heal",
	"silence",
	"disarm",
	"blind",
	"gouge",
	"mortalcleave",
	"bloodlust",
	-1,
	"punch",
	"charge",
	"frenzy",
	"enrage",
	"adds",
	-1,
	"hpbars",
	"reztimer",
	"bosskill"
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Thekal",
	
	heal_cmd = "heal",
	heal_name = "Great Heal Alert",
	heal_desc = "Warn for Lor'Khan's Great Heals",
	
	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for Silence",
	
	disarm_cmd = "disarm",
	disarm_name = "Disarm Alert",
	disarm_desc = "Warn for Disarm",
	
	blind_cmd = "blind",
	blind_name = "Blind Alert",
	blind_desc = "Warn for Blind",
	
	gouge_cmd = "gouge",
	gouge_name = "Gouge Alert",
	gouge_desc = "Warn for Gouge",
	
	mortalcleave_cmd = "mortalcleave",
	mortalcleave_name = "Mortal Cleave Alert",
	mortalcleave_desc = "Warn for Mortal Cleave",
	
	bloodlust_cmd = "bloodlust",
	bloodlust_name = "Bloodlust Alert",
	bloodlust_desc = "Warn for Bloodlust",

	punch_cmd = "punch",
	punch_name = "Force Punch Alert",
	punch_desc = "Warn for Force Punch",

	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn for Charge",
	
	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	adds_cmd = "adds",
	adds_name = "Tiger Adds Alert",
	adds_desc = "Warn for Tiger Adds",
	
	hpbars_cmd = "hpbars",
	hpbars_name = "HP Bars in Phase 1",
	hpbars_desc = "Display HP Bars for Thekal's, Zath's and Lor'Khan's HP",
	
	reztimer_cmd = "reztimer",
	reztimer_name = "Timer for Resurrect",
	reztimer_desc = "Time after one dies before he resurrects",
	
	
	trigger_heal = "Zealot Lor'Khan begins to cast Great Heal.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_heal = "Zealot Lor'Khan is Healing - Interrupt!",
	bar_heal = "Casting Heal",
	
	trigger_attack1 = "Zealot Lor'Khan attacks", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES
	trigger_attack2 = "Zealot Lor'Khan misses", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES
	trigger_attack3 = "Zealot Lor'Khan hits", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS
	trigger_attack4 = "Zealot Lor'Khan crits", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS
	trigger_kick1 = "Kick hits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_kick2 = "Kick crits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_kick3 = "Kick was blocked by Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_pummel1 = "Pummel hits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_pummel2 = "Pummel crits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_pummel3 = "Pummel was blocked by Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_shieldBash1 = "Shield Bash hits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_shieldBash2 = "Shield Bash crits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_shieldBash3 = "Shield Bash was blocked by Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_earthShock1 = "Earth Shock hits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	trigger_earthShock2 = "Earth Shock crits Zealot Lor'Khan", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
	
	trigger_silenceYou = "You are afflicted by Silence.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_silenceOther = "(.+) is afflicted by Silence.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_silenceFade = "Silence fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_silence = " Silenced",
	msg_silence = " Silenced - Dispel!",
	
	trigger_disarmYou = "You are afflicted by Disarm.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_disarmOther = "(.+) is afflicted by Disarm.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_disarmFade = "Disarm fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_disarm = " Disarmed",
	
	trigger_blindYou = "You are afflicted by Blind.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_blindOther = "(.+) is afflicted by Blind.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_blindFade = "Blind fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_blind = " Blinded",
	
	trigger_gougeYou = "You are afflicted by Gouge.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_gougeOther = "(.+) is afflicted by Gouge.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_gougeFade = "Gouge fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_gouge = " Gouged",
	
	trigger_mortalCleaveYou = "You are afflicted by Mortal Cleave.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mortalCleaveOther = "(.+) is afflicted by Mortal Cleave.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_mortalCleaveFade = "Mortal Cleave fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mortalCleave = " Mortal Cleave",
	
	--to be confirmed
	trigger_bloodlustGain = "(.+) gains Bloodlust.", --guessing CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_bloodlustFade = "Bloodlust fades from (.+).", --guessing CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_bloodlust = " Bloodlust",
	msg_bloodlust = " Bloodlust - Dispel!",
	
		--unuseable due to %s
	--trigger_mobDies = "(.+) dies.", --CHAT_MSG_MONSTER_EMOTE --High Priest Thekal // Zealot Zath // Zealot Lor'Khan
	bar_rezTimer = "Resurrect",
	
	trigger_resurrection = "is resurrected by a nearby ally!", --CHAT_MSG_MONSTER_EMOTE --High Priest Thekal // Zealot Zath // Zealot Lor'Khan
	
	trigger_phase2 = "Shirvallah, fill me with your RAGE!", --CHAT_MSG_MONSTER_YELL
	
	bar_phase2 = "Tiger Phase",
	msg_phase2 = "Phase 2 - Tiger Phase",
	
	trigger_forcePunch = "High Priest Thekal's Force Punch", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_forcePunch = "Force Punch CD",
	bar_forcePunchCast = "Casting Force Punch!",
	
	trigger_charge = "High Priest Thekal's Charge", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_charge = "Charge CD",
	
	--to be confirmed
	trigger_frenzyGain = "High Priest Thekal gains Frenzy.", --guessing CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from High Priest Thekal.", --guessing, CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_frenzy = "Frenzy - Tranq!",
	bar_frenzy = "Frenzy",
	
	trigger_enrage = "High Priest Thekal gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "High Priest Thekal is Enraged!",
	
	--no trigger_tigers
	bar_tigersCd = "Tigers Spawn CD",
	msg_tigers = "Tiger adds Spawned!",
	msg_addDead = "/2 Tiger Adds Dead",
	
	trigger_bossDead = "Hakkar binds me no more! Peace at last!", --CHAT_MSG_MONSTER_YELL
} end )

local timer = {
	heal = 4,
	silence = 6,
	disarm = 6,
	blind = 10,
	gouge = 4,
	mortalCleave = 5,
	bloodlust = 30,
	rezTimer = 10, --guessing
	
	phase2 = 15, --15sec from thekal's death, not from all 3 dead
	
	forcePunchFirst = 5,
	forcePunch = {12,18}, --saw 12,18
	charge = {12,18}, --saw 13,15,18
	frenzy = 10, --is 8 or 10 depending on bosses
	addsFirst = 25,
	adds = 20,
}
local icon = {
	heal = "Spell_Holy_Heal",
	silence = "Spell_Holy_Silence",
	disarm = "Ability_Warrior_Disarm",
	blind = "spell_shadow_mindsteal",
	gouge = "ability_gouge",
	mortalCleave = "Ability_Warrior_SavageBlow",
	bloodlust = "Spell_Nature_BloodLust",
	hpBar = "spell_holy_prayerofspirit",
	rezTimer = "spell_holy_resurrection",
	
	phase = "ability_mount_jungletiger",
	
	forcePunch = "ability_smash",
	charge = "ability_warrior_charge",
	frenzy = "Ability_Druid_ChallangingRoar",
	enrage = "Spell_Shadow_UnholyFrenzy",
	adds = "Ability_Hunter_Pet_Cat",
}
local color = {
	heal = "Green",
	silence = "Blue",
	disarm = "Yellow",
	blind = "Black",
	gouge = "Red",
	mortalCleave = "Orange",
	bloodlust = "Cyan",
	hpBar = "Magenta",
	rezTimer = "White",
	
	phase = "White",
	
	forcePunch = "Black",
	charge = "White",
	frenzy = "Red",
	adds = "Blue",
}
local syncName = {
	heal = "ThekalLorkhanHeal"..module.revision,
	healOver = "ThekalLorkhanHealOver"..module.revision,
	
	silence = "ThekalSilence"..module.revision,
	silenceFade = "ThekalSilenceFade"..module.revision,
	
	disarm = "ThekalDisarm"..module.revision,
	disarmFade = "ThekalDisarmFade"..module.revision,
	
	blind = "ThekalBlind"..module.revision,
	blindFade = "ThekalBlindFade"..module.revision,
	
	gouge = "ThekalGouge"..module.revision,
	gougeFade = "ThekalGougeFade"..module.revision,
	
	mortalCleave = "ThekalMortalCleave"..module.revision,
	mortalCleaveFade = "ThekalMortalCleaveFade"..module.revision,
	
	bloodlust = "ThekalBloodlustStart"..module.revision,
	bloodlustFade = "ThekalBloodlustStop"..module.revision,
	
	
	
	phase1End = "ThekalPhase1End"..module.revision,
	phase2 = "ThekalPhaseTwo"..module.revision,
	
	forcePunch = "ThekalForcePunch"..module.revision,
	
	charge = "ThekalCharge"..module.revision,
	
	frenzy = "ThekalFrenzyStart"..module.revision,
	frenzyFade = "ThekalFrenzyStop"..module.revision,
	
	enrage = "ThekalEnrage"..module.revision,
	
	moreAdds = "ThekalMoreAdds"..module.revision,
	addDead = "ThekalAddDead"..module.revision,
}

local zathDead = nil
local lorkhanDead = nil
local thekalDead = nil

local zathHp = 100
local lorkhanHp = 100
local thekalHp = 100

local phase = "phase1"
local thekalDeadTime = 0

local doCheckForBossDeath = false

local castingHeal = nil

local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_phase2
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE") --trigger_mobDies, trigger_resurrection
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_heal
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_kick1-2-3, trigger_pummel1-2-3, trigger_shieldBash1-2-3, trigger_earthShock1-2
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event") --trigger_kick1-2-3, trigger_pummel1-2-3, trigger_shieldBash1-2-3, trigger_earthShock1-2
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_kick1-2-3, trigger_pummel1-2-3, trigger_shieldBash1-2-3, trigger_earthShock1-2
		
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event") --trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event") --trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event") --trigger_attack3, trigger_attack4
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event") --trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event") --trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event") --trigger_attack1, trigger_attack2
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_silenceYou, trigger_disarmYou, trigger_blindYou, trigger_gougeYou, trigger_mortalCleaveYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_silenceOther, trigger_disarmOther, trigger_blindOther, trigger_gougeOther, trigger_mortalCleaveOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_silenceOther, trigger_disarmOther, trigger_blindOther, trigger_gougeOther, trigger_mortalCleaveOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_silenceFade, trigger_disarmFade, trigger_blindFade, trigger_gougeFade, trigger_mortalCleaveFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_silenceFade, trigger_disarmFade, trigger_blindFade, trigger_gougeFade, trigger_mortalCleaveFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_silenceFade, trigger_disarmFade, trigger_blindFade, trigger_gougeFade, trigger_mortalCleaveFade, trigger_bloodlustFade, trigger_frenzyFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_bloodlustGain, trigger_frenzyGain, trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_forcePunch, trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_forcePunch, trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_forcePunch, trigger_charge
	
	
	self:ThrottleSync(3, syncName.heal)
	self:ThrottleSync(3, syncName.healOver)
	
	self:ThrottleSync(3, syncName.silence)
	self:ThrottleSync(3, syncName.silenceFade)
	
	self:ThrottleSync(3, syncName.disarm)
	self:ThrottleSync(3, syncName.disarmFade)
	
	self:ThrottleSync(3, syncName.blind)
	self:ThrottleSync(3, syncName.blindFade)
	
	self:ThrottleSync(3, syncName.gouge)
	self:ThrottleSync(3, syncName.gougeFade)
	
	self:ThrottleSync(3, syncName.mortalCleave)
	self:ThrottleSync(3, syncName.mortalCleaveFade)
	
	self:ThrottleSync(3, syncName.bloodlust)
	self:ThrottleSync(3, syncName.bloodlustFade)
	
	
	self:ThrottleSync(10, syncName.phase1End)
	self:ThrottleSync(10, syncName.phase2)
	
	
	self:ThrottleSync(3, syncName.forcePunch)
	self:ThrottleSync(3, syncName.charge)
	
	self:ThrottleSync(3, syncName.frenzy)
	self:ThrottleSync(1, syncName.frenzyFade)
	
	self:ThrottleSync(5, syncName.enrage)
	
	self:ThrottleSync(10, syncName.moreAdds)
	self:ThrottleSync(0.5, syncName.addDead)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --addDead
end

function module:OnEngage()
	zathDead = nil
	lorkhanDead = nil
	thekalDead = nil
	
	zathHp = 100
	lorkhanHp = 100
	thekalHp = 100
	
	phase = "phase1"
	thekalDeadTime = 0
	
	doCheckForBossDeath = false
	
	castingHeal = nil
	
	addDead = 0
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Zath", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Zath", 0)
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Lor'Khan", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Lor'Khan", 0)
	
	self:TriggerEvent("BigWigs_StartHPBar", self, "High Priest Thekal", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "High Priest Thekal", 0)
	
	self:ScheduleRepeatingEvent("ThekalCheckHp", self.CheckHp, 0.5, self)
end

function module:OnDisengage()
	self:CancelScheduledEvent("Thekal_PhaseChangeCheck")
	
	self:CancelScheduledEvent("ThekalCheckHp")
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if (msg == string.format(UNITDIESOTHER, "Zulian Tiger")) or (msg == string.format(UNITDIESOTHER, "Zulian Guardian")) then
		addDead = addDead + 1
		if addDead <= 2 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	
	
	
	elseif (msg == string.format(UNITDIESOTHER, "Zealot Zath")) then
		if lorkhanDead == nil and thekalDead == nil and self.db.profile.reztimer then
			self:Bar(L["bar_rezTimer"], timer.rezTimer, icon.rezTimer, true, color.rezTimer)
		end
		
		zathDead = true
		if zathDead and lorkhanDead and thekalDead then
			self:ScheduleRepeatingEvent("Thekal_PhaseChangeCheck", self.PhaseChangeCheck, 1, self)
		end
		
		self:RemoveBar("Zealot Zath"..L["bar_bloodlust"])
		self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Zath")
	
	
	elseif (msg == string.format(UNITDIESOTHER, "Zealot Lor'Khan")) then
		if zathDead == nil and thekalDead == nil and self.db.profile.reztimer then
			self:Bar(L["bar_rezTimer"], timer.rezTimer, icon.rezTimer, true, color.rezTimer)
		end
		
		lorkhanDead = true
		castingHeal = nil
		if zathDead and lorkhanDead and thekalDead then
			self:ScheduleRepeatingEvent("Thekal_PhaseChangeCheck", self.PhaseChangeCheck, 1, self)
		end
		
		self:RemoveBar(L["bar_heal"])
		self:RemoveBar("Zealot Lor'Khan"..L["bar_bloodlust"])
		self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Lor'Khan")
	
	
	elseif (msg == string.format(UNITDIESOTHER, "High Priest Thekal")) then
		if zathDead == nil and lorkhanDead == nil and self.db.profile.reztimer then
			self:Bar(L["bar_rezTimer"], timer.rezTimer, icon.rezTimer, true, color.rezTimer)
		end
		
		thekalDead = true
		if zathDead and lorkhanDead and thekalDead then
			self:ScheduleRepeatingEvent("Thekal_PhaseChangeCheck", self.PhaseChangeCheck, 1, self)
		end
		
		self:RemoveBar("High Priest Thekal"..L["bar_bloodlust"])
		self:TriggerEvent("BigWigs_StopHPBar", self, "High Priest Thekal")
		
		thekalDeadTime = GetTime()
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	--there is no way to know which mob was resurrected as the emote is "%s is resurrected by a nearby ally!"
	--if we're in p1 and that happens, consider all alive and reset all bars
		--the mobs that are still alive will have their bar refreshed on hit
	if string.find(msg, L["trigger_resurrection"]) and phase == "phase1" then
		self:CancelScheduledEvent("Thekal_PhaseChangeCheck")
		
		if zathDead then zathDead = nil end
		zathHp = 100
		self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Zath", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
		self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Zath", 0)
		
		if lorkhanDead then lorkhanDead = nil end
		lorkhanHp = 100
		self:TriggerEvent("BigWigs_StartHPBar", self, "Zealot Lor'Khan", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
		self:TriggerEvent("BigWigs_SetHPBar", self, "Zealot Lor'Khan", 0)
		
		if thekalDead then thekalDead = nil end
		thekalHp = 100
		self:TriggerEvent("BigWigs_StartHPBar", self, "High Priest Thekal", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
		self:TriggerEvent("BigWigs_SetHPBar", self, "High Priest Thekal", 0)
	end
end

function module:PhaseChangeCheck()
	local zathDeadConfirm = true
	local lorkhanDeadConfirm = true
	local thekalDeadConfirm = true
	
	for i=1,GetNumRaidMembers() do
		if UnitName("Raid"..i.."Target") == "Zealot Zath" and not UnitIsDead("Raid"..i.."Target") then
			zathDeadConfirm = nil
		elseif UnitName("Raid"..i.."Target") == "Zealot Lor'Khan" and not UnitIsDead("Raid"..i.."Target") then
			lorkhanDeadConfirm = nil
		elseif UnitName("Raid"..i.."Target") == "High Priest Thekal" and not UnitIsDead("Raid"..i.."Target") then
			thekalDeadConfirm = nil
		end
	end

	if zathDeadConfirm and lorkhanDeadConfirm and thekalDeadConfirm then
		self:Sync(syncName.phase1End)
	end
end

function module:CheckHp()
	local zathHealth
	local lorkhanHealth
	local thekalHealth
	
	if UnitName("PlayerTarget") == "Zealot Zath" then
		zathHealth = math.ceil((UnitHealth("PlayerTarget") / UnitHealthMax("PlayerTarget")) * 100)
	elseif UnitName("PlayerTarget") == "Zealot Lor'Khan" then
		lorkhanHealth = math.ceil((UnitHealth("PlayerTarget") / UnitHealthMax("PlayerTarget")) * 100)
	elseif UnitName("PlayerTarget") == "High Priest Thekal" then
		thekalHealth = math.ceil((UnitHealth("PlayerTarget") / UnitHealthMax("PlayerTarget")) * 100)
	end
	
	for i=1,GetNumRaidMembers() do
		if UnitName("Raid"..i.."Target") == "Zealot Zath" then
			zathHealth = math.ceil((UnitHealth("Raid"..i.."Target") / UnitHealthMax("Raid"..i.."Target")) * 100)
		elseif UnitName("Raid"..i.."Target") == "Zealot Lor'Khan" then
			lorkhanHealth = math.ceil((UnitHealth("Raid"..i.."Target") / UnitHealthMax("Raid"..i.."Target")) * 100)
		elseif UnitName("Raid"..i.."Target") == "High Priest Thekal" then
			thekalHealth = math.ceil((UnitHealth("Raid"..i.."Target") / UnitHealthMax("Raid"..i.."Target")) * 100)
		end
		if zathHealth and lorkhanHealth and thekalHealth then break end
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

function module:CheckForBossDeath(msg)
	if doCheckForBossDeath then
		BigWigs:CheckForBossDeath(msg, self)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_phase2"] then
		self:Sync(syncName.phase2)
	
	elseif msg == L["trigger_bossDead"] then
		self:SendBossDeathSync()
	end
end

function module:Event(msg)
	if msg == L["trigger_heal"] then
		self:Sync(syncName.heal)
	
	elseif castingHeal == true and (string.find(msg, L["trigger_attack1"]) or string.find(msg, L["trigger_attack2"]) or string.find(msg, L["trigger_attack3"]) or string.find(msg, L["trigger_attack4"])
		or string.find(msg, L["trigger_kick1"]) or string.find(msg, L["trigger_kick2"]) or string.find(msg, L["trigger_kick3"]) -- kicked
		or string.find(msg, L["trigger_pummel1"]) or string.find(msg, L["trigger_pummel2"]) or string.find(msg, L["trigger_pummel3"]) -- pummeled
		or string.find(msg, L["trigger_shieldBash1"]) or string.find(msg, L["trigger_shieldBash2"]) or string.find(msg, L["trigger_shieldBash3"]) -- shield bashed
		or string.find(msg, L["trigger_earthShock1"]) or string.find(msg, L["trigger_earthShock2"])) then -- earth shocked
		self:Sync(syncName.healOver)
	
	
	elseif msg == L["trigger_silenceYou"] then
		self:Sync(syncName.silence .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_silenceOther"]) then
		local _,_,silencePerson, _ = string.find(msg, L["trigger_silenceOther"])
		if not (silencePerson == "Zealot Zath" or silencePerson == "Zealot Lor'Khan" or silencePerson == "High Priest Thekal") then
			self:Sync(syncName.silence .. " "..silencePerson)
		end
	
	elseif string.find(msg, L["trigger_silenceFade"]) then
		local _,_,silenceFadePerson, _ = string.find(msg, L["trigger_silenceFade"])
		if silenceFadePerson == "you" then silenceFadePerson = UnitName("Player") end
		if not (silenceFadePerson == "Zealot Zath" or silenceFadePerson == "Zealot Lor'Khan" or silenceFadePerson == "High Priest Thekal") then
			self:Sync(syncName.silenceFade .. " "..silenceFadePerson)
		end
	
	elseif msg == L["trigger_disarmYou"] then
		self:Sync(syncName.disarm .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_disarmOther"]) then
		local _,_,disarmPerson, _ = string.find(msg, L["trigger_disarmOther"])
		if not (disarmPerson == "Zealot Zath" or disarmPerson == "Zealot Lor'Khan" or disarmPerson == "High Priest Thekal") then
			self:Sync(syncName.disarm .. " "..disarmPerson)
		end
	
	elseif string.find(msg, L["trigger_disarmFade"]) then
		local _,_,disarmFadePerson, _ = string.find(msg, L["trigger_disarmFade"])
		if disarmFadePerson == "you" then disarmFadePerson = UnitName("Player") end
		if not (disarmFadePerson == "Zealot Zath" or disarmFadePerson == "Zealot Lor'Khan" or disarmFadePerson == "High Priest Thekal") then
			self:Sync(syncName.disarmFade .. " "..disarmFadePerson)
		end
	
	
	elseif msg == L["trigger_blindYou"] then
		self:Sync(syncName.blind .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_blindOther"]) then
		local _,_,blindPerson, _ = string.find(msg, L["trigger_blindOther"])
		if not (blindPerson == "Zealot Zath" or blindPerson == "Zealot Lor'Khan" or blindPerson == "High Priest Thekal") then
			self:Sync(syncName.blind .. " "..blindPerson)
		end
	
	elseif string.find(msg, L["trigger_blindFade"]) then
		local _,_,blindFadePerson, _ = string.find(msg, L["trigger_blindFade"])
		if blindFadePerson == "you" then blindFadePerson = UnitName("Player") end
		if not (blindFadePerson == "Zealot Zath" or blindFadePerson == "Zealot Lor'Khan" or blindFadePerson == "High Priest Thekal") then
			self:Sync(syncName.blindFade .. " "..blindFadePerson)
		end
		
		
	elseif msg == L["trigger_gougeYou"] then
		self:Sync(syncName.gouge .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_gougeOther"]) then
		local _,_,gougePerson, _ = string.find(msg, L["trigger_gougeOther"])
		if not (gougePerson == "Zealot Zath" or gougePerson == "Zealot Lor'Khan" or gougePerson == "High Priest Thekal") then
			self:Sync(syncName.gouge .. " "..gougePerson)
		end
	
	elseif string.find(msg, L["trigger_gougeFade"]) then
		local _,_,gougeFadePerson, _ = string.find(msg, L["trigger_gougeFade"])
		if gougeFadePerson == "you" then gougeFadePerson = UnitName("Player") end
		if not (gougeFadePerson == "Zealot Zath" or gougeFadePerson == "Zealot Lor'Khan" or gougeFadePerson == "High Priest Thekal") then
			self:Sync(syncName.gougeFade .. " "..gougeFadePerson)
		end
		
	elseif msg == L["trigger_mortalCleaveYou"] then
		self:Sync(syncName.mortalCleave .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_mortalCleaveOther"]) then
		local _,_,mortalCleavePerson, _ = string.find(msg, L["trigger_mortalCleaveOther"])
		self:Sync(syncName.mortalCleave .. " "..mortalCleavePerson)
	
	elseif string.find(msg, L["trigger_mortalCleaveFade"]) then
		local _,_,mortalCleaveFadePerson, _ = string.find(msg, L["trigger_mortalCleaveFade"])
		if mortalCleaveFadePerson == "you" then mortalCleaveFadePerson = UnitName("Player") end
		self:Sync(syncName.mortalCleaveFade .. " "..mortalCleaveFadePerson)
		
		
	elseif string.find(msg, L["trigger_bloodlustGain"]) then
		local _,_,bloodlustPerson, _ = string.find(msg, L["trigger_bloodlustGain"])
		if (bloodlustPerson == "Zealot Zath" or bloodlustPerson == "Zealot Lor'Khan" or bloodlustPerson == "High Priest Thekal") then
			self:Sync(syncName.bloodlust .. " "..bloodlustPerson)
		end
	elseif string.find(msg, L["trigger_bloodlustFade"]) then
		local _,_,bloodlustFadePerson, _ = string.find(msg, L["trigger_bloodlustFade"])
		if (bloodlustFadePerson == "Zealot Zath" or bloodlustFadePerson == "Zealot Lor'Khan" or bloodlustFadePerson == "High Priest Thekal") then
			self:Sync(syncName.bloodlustFade .. " "..bloodlustFadePerson)
		end
		
		
	elseif string.find(msg, L["trigger_forcePunch"]) then
		self:Sync(syncName.forcePunch)
		
	elseif string.find(msg, L["trigger_charge"]) then
		self:Sync(syncName.charge)
		
	elseif msg == L["trigger_frenzyGain"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyFade)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	elseif sync == syncName.healOver and self.db.profile.heal then
		self:HealOver()
	
	elseif sync == syncName.silence and rest and self.db.profile.silence then
		self:Silence(rest)
	elseif sync == syncName.silenceFade and rest and self.db.profile.silence then
		self:SilenceFade(rest)
		
	elseif sync == syncName.disarm and rest and self.db.profile.disarm then
		self:Disarm(rest)
	elseif sync == syncName.disarmFade and rest and self.db.profile.disarm then
		self:DisarmFade(rest)
		
	elseif sync == syncName.blind and rest and self.db.profile.blind then
		self:Blind(rest)
	elseif sync == syncName.blindFade and rest and self.db.profile.blind then
		self:BlindFade(rest)
		
	elseif sync == syncName.gouge and rest and self.db.profile.gouge then
		self:Gouge(rest)
	elseif sync == syncName.gougeFade and rest and self.db.profile.gouge then
		self:GougeFade(rest)
		
	elseif sync == syncName.mortalCleave and rest and self.db.profile.mortalcleave then
		self:MortalCleave(rest)
	elseif sync == syncName.mortalCleaveFade and rest and self.db.profile.mortalcleave then
		self:MortalCleaveFade(rest)
		
	elseif sync == syncName.bloodlust and rest and self.db.profile.bloodlust then
		self:Bloodlust(rest)
	elseif sync == syncName.bloodlustFade and rest and self.db.profile.bloodlust then
		self:BloodlustFade(rest)
		
		
	elseif sync == syncName.phase1End then
		self:Phase1End()
	elseif sync == syncName.phase2 then
		self:Phase2()

	
	elseif sync == syncName.forcePunch and self.db.profile.punch then
		self:ForcePunch()
		
	elseif sync == syncName.charge and self.db.profile.charge then
		self:Charge()
		
	elseif sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyFade and self.db.profile.frenzy then
		self:FrenzyFade()
		
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	
	elseif sync == syncName.moreAdds and self.db.profile.adds then
		self:MoreAdds()
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
	end
end


function module:Heal()
	castingHeal = true
	
	self:Bar(L["bar_heal"], timer.heal, icon.heal, true, color.heal)
	
	if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Warrior" or UnitClass("Player") == "Mage" then
		self:Message(L["msg_heal"], "Urgent", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.heal, timer.heal)
	end
end

function module:HealOver()
	castingHeal = nil
	self:RemoveBar(L["bar_heal"])
	self:RemoveWarningSign(icon.heal)
end

function module:Silence(rest)
	self:Bar(rest..L["bar_silence"], timer.silence, icon.silence, true, color.silence)	
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(rest..L["msg_silence"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.silence, 0.7)
	end
end

function module:SilenceFade(rest)
	self:RemoveBar(rest..L["bar_silence"])
end

function module:Disarm(rest)
	self:Bar(rest..L["bar_disarm"], timer.disarm, icon.disarm, true, color.disarm)	
end

function module:DisarmFade(rest)
	self:RemoveBar(rest..L["bar_disarm"])
end

function module:Blind(rest)
	self:Bar(rest..L["bar_blind"], timer.blind, icon.blind, true, color.blind)	
end

function module:BlindFade(rest)
	self:RemoveBar(rest..L["bar_blind"])
end

function module:Gouge(rest)
	self:Bar(rest..L["bar_gouge"], timer.gouge, icon.gouge, true, color.gouge)	
end

function module:GougeFade(rest)
	self:RemoveBar(rest..L["bar_gouge"])
end

function module:MortalCleave(rest)
	self:Bar(rest..L["bar_mortalCleave"], timer.mortalCleave, icon.mortalCleave, true, color.mortalCleave)	
end

function module:MortalCleaveFade(rest)
	self:RemoveBar(rest..L["bar_mortalCleave"])
end

function module:Bloodlust(rest)
	self:Bar(rest..L["bar_bloodlust"], timer.bloodlust, icon.bloodlust, true, color.bloodlust)	
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" then
		self:Message(rest..L["msg_bloodlust"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.bloodlust, 0.7)
	end
end

function module:BloodlustFade(rest)
	self:RemoveBar(rest..L["bar_bloodlust"])
end


function module:Phase1End()
	phase = "phase2"
	addDead = 0
	
	self:CancelScheduledEvent("Thekal_PhaseChangeCheck")
	
	self:CancelScheduledEvent("ThekalCheckHp")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Zath")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Lor'Khan")
	self:TriggerEvent("BigWigs_StopHPBar", self, "High Priest Thekal")
	
	self:RemoveBar(L["bar_heal"])
	self:RemoveBar(L["bar_rezTimer"])
	self:RemoveBar("Zealot Zath"..L["bar_bloodlust"])
	self:RemoveBar("Zealot Lor'Khan"..L["bar_bloodlust"])
	self:RemoveBar("High Priest Thekal"..L["bar_bloodlust"])
	
	--phase 2 happens 15sec from the moment thekal dies,
		--if the other die 8sec after thekal, only 7sec timer for p2
	self:Bar(L["bar_phase2"], timer.phase2 - (GetTime() - thekalDeadTime), icon.phase, true, color.phase)
	self:Message(L["msg_phase2"], "Attention", false, nil, false)
end

function module:Phase2()
	phase = "phase2"
	addDead = 0
	
	self:CancelScheduledEvent("Thekal_PhaseChangeCheck")
	
	self:CancelScheduledEvent("ThekalCheckHp")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Zath")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Zealot Lor'Khan")
	self:TriggerEvent("BigWigs_StopHPBar", self, "High Priest Thekal")
	
	self:RemoveBar(L["bar_heal"])
	self:RemoveBar(L["bar_rezTimer"])
	self:RemoveBar("Zealot Zath"..L["bar_bloodlust"])
	self:RemoveBar("Zealot Lor'Khan"..L["bar_bloodlust"])
	self:RemoveBar("High Priest Thekal"..L["bar_bloodlust"])
	
	self:RemoveBar(L["bar_phase2"])
	
	doCheckForBossDeath = true
	
	if self.db.profile.punch then
		self:Bar(L["bar_forcePunch"], timer.forcePunchFirst, icon.forcePunch, true, color.forcePunch)
	end
	
	if self.db.profile.charge then
		self:IntervalBar(L["bar_charge"], timer.charge[1], timer.charge[2], icon.charge, true, color.charge)
	end
	
	if self.db.profile.adds then
		self:Bar(L["bar_tigersCd"], timer.addsFirst, icon.adds, true, color.adds)
		self:DelayedSync(timer.addsFirst, syncName.moreAdds)
	end
end


function module:ForcePunch()
	self:RemoveBar(L["bar_forcePunch"])
	self:IntervalBar(L["bar_forcePunch"], timer.forcePunch[1], timer.forcePunch[2], icon.forcePunch, true, color.forcePunch)
end

function module:Charge()
	self:RemoveBar(L["bar_charge"])
	self:IntervalBar(L["bar_charge"], timer.charge[1], timer.charge[2], icon.charge, true, color.charge)
end

function module:Frenzy()
	self:Bar(L["bar_frenzy"], timer.frenzy, icon.frenzy, true, color.frenzy)
	
	if UnitClass("Player") == "Hunter" then
		self:Message(L["msg_frenzy"], "Personal", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.frenzy, 1)
	end
end

function module:FrenzyFade()
	self:RemoveBar(L["bar_frenzy"])
	self:RemoveWarningSign(icon.frenzy)
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Attention", false, nil, false)
	self:Sound("Beware")
	self:WarningSign(icon.enrage, 0.7)
end

function module:MoreAdds()
	addDead = 0
	
	self:Bar(L["bar_tigersCd"], timer.adds, icon.adds, true, color.adds)
	self:Message(L["msg_tigers"], "Important", false, nil, false)
	self:Sound("Alarm")
	self:WarningSign(icon.adds, 1)
	
	self:DelayedSync(timer.adds, syncName.moreAdds)
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
end
