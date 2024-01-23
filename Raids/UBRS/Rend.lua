local module, L = BigWigs:ModuleDeclaration("Warchief Rend Blackhand", "Blackrock Spire")

local gyth = AceLibrary("Babble-Boss-2.2")["Gyth"]
local rend = AceLibrary("Babble-Boss-2.2")["Warchief Rend Blackhand"]

module.revision = 30041
module.enabletrigger = {gyth, rend}
module.toggleoptions = {"flamebreath", "freeze", "dismount", "whirlwind", "enrage", -1, "waves", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
}
--module.zonename = {
--	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
--	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
--	AceLibrary("Babble-Zone-2.2")["Upper Blackrock Spire"],
--}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gyth",
	
	flamebreath_cmd = "flamebreath",
	flamebreath_name = "Flamebreath",
	flamebreath_desc = "Warn for Flamebreath.",
	
	freeze_cmd = "freeze",
	freeze_name = "Freeze",
	freeze_desc = "Prompts group to dispel your Freeze.",
	
	dismount_cmd = "dismount",
	dismount_name = "Dismount",
	dismount_desc = "Warn when Rend dismounts Gyth.",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind",
	whirlwind_desc = "Timer for Rend Whirlwind.",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Prompts Enrage.",
	
	waves_cmd = "waves",
	waves_name = "Waves",
	waves_desc = "Warn for Waves.",
	
	
	
	trigger_flamebreath = "Gyth begins to cast Flame Breath.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_flamebreathCd = "Casting Flamebreath CD",
	bar_flamebreathCast = "Flamebreath",
	
	trigger_freezeYou = "You are afflicted by Freeze.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_freezeOther = "(.+) is afflicted by Freeze.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	msg_freeze = "Dispel freeze!",
	
	trigger_dismount = "Gyth casts Summon Rend Blackhand.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_dismount = "Rend has dismounted!",
	
	trigger_whirlwind = "Warchief Rend Blackhand gains Whirlwind.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_whirlwindCd = "Whirlwind CD",
	bar_whirlwindCast = "Whirlwind!",
	
	trigger_enrage = "Warchief Rend Blackhand gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",
	msg_enrage = "Rend Enraged!",
	
	trigger_engage = "Excellent... it would appear as if the meddlesome insects have arrived just in time to feed my legion. Welcome, mortals!",--CHAT_MSG_MONSTER_YELL
	trigger_bossNext = "THIS CANNOT BE!!! Rend, deal with these insects.",--CHAT_MSG_MONSTER_YELL
	
	bar_beforeWave1 = "Waves start",
	bar_beforeWave2 = "Wave 2/7 starts",
	bar_beforeWave3 = "Wave 3/7 starts",
	bar_beforeWave4 = "Wave 4/7 starts",
	bar_beforeWave5 = "Wave 5/7 starts",
	bar_beforeWave6 = "Wave 6/7 starts",
	bar_beforeWave7 = "Wave 7/7 starts",
	bar_beforeWaveBoss = "Gyth",
	
	bar_waves1 = "Wave 1/7",
	bar_waves2 = "Wave 2/7",
	bar_waves3 = "Wave 3/7",
	bar_waves4 = "Wave 4/7",
	bar_waves5 = "Wave 5/7",
	bar_waves6 = "Wave 6/7",
	bar_waves7 = "Wave 7/7 - Boss next!",
} end )

local bwRendWaves = 0

local bwWhelpDead = 0
local bwSpawnDead = 0
local bwHandlerDead = 0

local bwWaveWhelpTotal = 0
local bwWaveSpawnTotal = 0
local bwWaveHandlerTotal = 0

local rendDead = nil
local gythDead = nil
local bwPlayerIsAttacking = nil

local timer = {
	beforeWave1 = 13.5,
	beforeWave2 = 40,
	beforeWave3 = 42,
	beforeWave4 = 38,
	beforeWave5 = 38,
	beforeWave6 = 39,
	beforeWave7 = 35,
	beforeWaveBoss = 36.5,
	
	waves = 600,--need data
	
	firstFlamebreath = 8,
	flamebreathCd = {8,18},--minus 2 for flamebreathCast delay, saw 12, 14
	flamebreathCast = 2,
	whirlwindCast = 1.9,
	whirlwindCd = 9.6,--from Kronos, need data
}
local icon = {
	waves = "Inv_Misc_Pocketwatch_01",
	flamebreath = "Spell_fire_fire",
	freeze = "spell_frost_glacier",
	whirlwind = "ability_whirlwind",
	enrage = "spell_shadow_unholyfrenzy",
}
local color = {
	waves = "White",
	flameBreathCd = "Black",
	flameBreathCast = "Red",
	whirlwindCd = "White",
	whirlwindCast = "Blue",
}
local syncName = {
	flamebreath = "rendFlamebreath"..module.revision,
	freeze = "rendFreeze"..module.revision,
	dismount = "rendDismount"..module.revision,
	whirlwind = "rendWhirlwind"..module.revision,
	enrage = "rendEnrage"..module.revision,
	
	rendDead = "rendRendDead"..module.revision,
	gythDead = "rendGythDead"..module.revision,
	allDead = "rendAllDead"..module.revision,
	
	waves = "rendWaves"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--debug
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_flamebreath
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_freezeYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_freezeOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_freezeOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_dismount
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_whirlwind, trigger_enrage

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage, trigger_bossNext

	self:ThrottleSync(2, syncName.flamebreath)
	self:ThrottleSync(2, syncName.freeze)
	self:ThrottleSync(2, syncName.dismount)
	self:ThrottleSync(2, syncName.whirlwind)
	self:ThrottleSync(2, syncName.enrage)
	
	self:ThrottleSync(2, syncName.rendDead)
	self:ThrottleSync(2, syncName.gythDead)
	self:ThrottleSync(2, syncName.allDead)
	
	self:ThrottleSync(2, syncName.waves)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	rendDead = nil
	gythDead = nil
end

function module:OnEngage()
	bwRendWaves = 0

	bwWhelpDead = 0
	bwSpawnDead = 0
	bwHandlerDead = 0

	bwWaveWhelpTotal = 0
	bwWaveSpawnTotal = 0
	bwWaveHandlerTotal = 0

	rendDead = nil
	gythDead = nil
	bwPlayerIsAttacking = nil

	if self.db.profile.waves then
		self:Sync(syncName.waves)
	end
end

function module:OnDisengage()
end

function module:CheckForWipe()
end

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= "Blackrock Stadium" or self.core:IsModuleActive(module.translatedName) then
		return
	end

	self.core:EnableModule(module.translatedName)
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
		
	elseif msg == L["trigger_bossNext"] then
		bwRendWaves = 8
		self:Sync(syncName.waves)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if msg == string.format(UNITDIESOTHER, gyth) then
		self:Sync(syncName.gythDead)
	elseif msg == string.format(UNITDIESOTHER, rend) then
		self:Sync(syncName.rendDead)
		
	elseif msg == string.format(UNITDIESOTHER, "Chromatic Whelp") then
		if self.db.profile.waves then
			bwWhelpDead = bwWhelpDead + 1
			if bwWhelpDead == bwWaveWhelpTotal and bwSpawnDead == bwWaveSpawnTotal and bwHandlerDead == bwWaveHandlerTotal then
				self:Sync(syncName.waves)
			end
		end
	elseif msg == string.format(UNITDIESOTHER, "Chromatic Dragonspawn") then
		if self.db.profile.waves then
			bwSpawnDead = bwSpawnDead + 1
			if bwWhelpDead == bwWaveWhelpTotal and bwSpawnDead == bwWaveSpawnTotal and bwHandlerDead == bwWaveHandlerTotal then
				self:Sync(syncName.waves)
			end
		end
	elseif msg == string.format(UNITDIESOTHER, "Blackhand Dragon Handler") then
		if self.db.profile.waves then
			bwHandlerDead = bwHandlerDead + 1
			if bwWhelpDead == bwWaveWhelpTotal and bwSpawnDead == bwWaveSpawnTotal and bwHandlerDead == bwWaveHandlerTotal then
				self:Sync(syncName.waves)
			end
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_flamebreath"] then
		self:Sync(syncName.flamebreath)
		
	elseif string.find(msg, L["trigger_freezeYou"]) or string.find(msg, L["trigger_freezeOther"]) then
		self:Sync(syncName.freeze)
	
	elseif msg == L["trigger_dismount"] then
		self:Sync(syncName.dismount)
		
	elseif msg == L["trigger_whirlwind"] then
		self:Sync(syncName.whirlwind)
		
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.flamebreath and self.db.profile.flamebreath then
		self:Flamebreath()
		
	elseif sync == syncName.freeze and self.db.profile.freeze then
		self:Freeze()
		
	elseif sync == syncName.dismount and self.db.profile.dismount then
		self:Dismount()
		
	elseif sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
		
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
		
	elseif sync == syncName.gythDead then
		self:GythDead()
	elseif sync == syncName.rendDead then
		self:RendDead()
	elseif sync == syncName.allDead then
		self:AllDead()
		
	elseif sync == syncName.waves and self.db.profile.waves then
		self:Waves()
	end
end

function module:Flamebreath()
	self:RemoveBar(L["bar_flamebreathCd"])
	self:Bar(L["bar_flamebreathCast"], timer.flamebreathCast, icon.flamebreath, true, color.flameBreathCast)
	self:DelayedIntervalBar(timer.flamebreathCast, L["bar_flamebreathCd"], timer.flamebreathCd[1], timer.flamebreathCd[2], icon.flamebreath, true, color.flameBreathCd)
end

function module:Freeze()
	self:Message(L["msg_freeze"], "Urgent", false, nil, false)
	
	if UnitClass("Player") == "Priest" then
		self:WarningSign(icon.freeze, 1)
		self:Sound("Info")
	elseif UnitClass("Player") == "Paladin" then
		self:WarningSign(icon.freeze, 1)
		self:Sound("Info")
	end
end

function module:Dismount()
	self:Message(L["msg_dismount"], "Important", false, nil, false)
	self:Sound("Beware")
	
	bwPlayerIsAttacking = nil
	if IsRaidLeader() or IsRaidOfficer() then
		if UnitClass("Player") ~= "Rogue" and UnitClass("Player") ~= "Druid" then
			if PlayerFrame.inCombat then
				bwPlayerIsAttacking = true
			end
			
			TargetByName("Warchief Rend Blackhand",true)
			SetRaidTarget("target",6)
			TargetLastTarget()
			if bwPlayerIsAttacking == true then
				AttackTarget()
			end
		end
	end
end

function module:Whirlwind()
	self:RemoveBar(L["bar_whirlwindCd"])
	self:Bar(L["bar_whirlwindCast"], timer.whirlwindCast, icon.whirlwind, true, color.whirlwindCast)
	self:DelayedBar(timer.whirlwindCast, L["bar_whirlwindCd"], timer.whirlwindCd, icon.whirlwind, true, color.whirlwindCd)
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:WarningSign(icon.enrage, 0.7)
end

function module:GythDead()
	self:RemoveBar(L["bar_flamebreathCd"])
	gythDead = true
	if gythDead and rendDead then
		self:Sync(syncName.allDead)
	end
end

function module:RendDead()
	rendDead = true
	if gythDead and rendDead then
		self:Sync(syncName.allDead)
	end
end

function module:AllDead()
	self:SendBossDeathSync()
end

function module:Waves()
	bwWhelpDead = 0
	bwSpawnDead = 0
	bwHandlerDead = 0
	
	if bwRendWaves == 0 then
		self:Bar(L["bar_beforeWave1"], timer.beforeWave1, icon.waves, true, color.waves)
			bwRendWaves = 1
			self:DelayedSync(timer.beforeWave1, syncName.waves)
		return
		
	elseif bwRendWaves == 1 then
		self:RemoveBar(L["bar_beforeWave1"])
		self:Bar(L["bar_waves1"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 3
			bwWaveSpawnTotal = 1
			bwWaveHandlerTotal = 0
			bwRendWaves = 2
		return
		
	elseif bwRendWaves == 2 then
		self:RemoveBar(L["bar_waves1"])
		self:Bar(L["bar_beforeWave2"], timer.beforeWave2, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave2,L["bar_waves2"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 3
			bwWaveSpawnTotal = 1
			bwWaveHandlerTotal = 0
			bwRendWaves = 3
		return
		
	elseif bwRendWaves == 3 then
		self:RemoveBar(L["bar_waves2"])
		self:Bar(L["bar_beforeWave3"], timer.beforeWave3, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave3,L["bar_waves3"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 2
			bwWaveSpawnTotal = 1
			bwWaveHandlerTotal = 1
			bwRendWaves = 4
		return
		
	elseif bwRendWaves == 4 then
		self:RemoveBar(L["bar_waves3"])
		self:Bar(L["bar_beforeWave4"], timer.beforeWave4, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave4,L["bar_waves4"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 2
			bwWaveSpawnTotal = 1
			bwWaveHandlerTotal = 1
			bwRendWaves = 5
		return
		
	elseif bwRendWaves == 5 then
		self:RemoveBar(L["bar_waves4"])
		self:Bar(L["bar_beforeWave5"], timer.beforeWave5, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave5,L["bar_waves5"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 3
			bwWaveSpawnTotal = 1
			bwWaveHandlerTotal = 1
			bwRendWaves = 6
		return
		
	elseif bwRendWaves == 6 then
		self:RemoveBar(L["bar_waves5"])
		self:Bar(L["bar_beforeWave6"], timer.beforeWave6, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave6,L["bar_waves6"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 2
			bwWaveSpawnTotal = 2
			bwWaveHandlerTotal = 1
			bwRendWaves = 7
		return
		
	elseif bwRendWaves == 7 then
		self:RemoveBar(L["bar_waves6"])
		self:Bar(L["bar_beforeWave7"], timer.beforeWave7, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWave7,L["bar_waves7"], timer.waves, icon.waves, true, color.waves)
			bwWaveWhelpTotal = 0--2
			bwWaveSpawnTotal = 0--2
			bwWaveHandlerTotal = 0--1
			bwRendWaves = 9--8
		return
		
	elseif bwRendWaves == 8 then
		self:RemoveBar(L["bar_waves7"])
		self:Bar(L["bar_beforeWaveBoss"], timer.beforeWaveBoss, icon.waves, true, color.waves)
		self:DelayedBar(timer.beforeWaveBoss, L["bar_flamebreathCd"], timer.firstFlamebreath, icon.flamebreath, true, color.flamebreathCd)
		return
	end
end
