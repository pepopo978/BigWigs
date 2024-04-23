
local module, L = BigWigs:ModuleDeclaration("Razorgore the Untamed", "Blackwing Lair")
local controller = AceLibrary("Babble-Boss-2.2")["Grethok the Controller"]

module.revision = 30085
module.enabletrigger = {"Razorgore the Untamed", "Grethok the Controller"}
module.toggleoptions = {"polymorph", "dominatemind", "icon", "slow", -1, "phase", "eggs", "orb", "mindexhaustion", -1, "volley", "conflagration", "warstomp", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Razorgore",

	--Phase 1
	polymorph_cmd = "polymorph",
	polymorph_name = "Polymorph Alert",
	polymorph_desc = "Warn for Polymorph",
	
	dominatemind_cmd = "dominatemind",
	dominatemind_name = "Dominate Mind Alert",
	dominatemind_desc = "Warn for Dominate Mind",
	
	icon_cmd = "icon",
	icon_name = "Raid Icon on Dominate Mind",
	icon_desc = "Place a Raid Icon on Dominate Mind",
	
	slow_cmd = "slow",
	slow_name = "Slow Alert",
	slow_desc = "Warn for Slow",

	--Phase 2
	phase_cmd = "phase",
	phase_name = "Phase Change Alert",
	phase_desc = "Warn for Phase Change",
	
	eggs_cmd = "eggs",
	eggs_name = "Eggs Counter",
	eggs_desc = "Counter for Black Dragon Eggs destroyed",

	orb_cmd = "orb",
	orb_name = "Orb Control Alert",
	orb_desc = "Warn for Orb Control",
	
	mindexhaustion_cmd = "mindexhaustion",
	mindexhaustion_name = "Mind Exhaustion Alert",
	mindexhaustion_desc = "Warn for Mind Exhaustion",
	
--Phase 3
	volley_cmd = "volley",
	volley_name = "Fireball Volley Alert",
	volley_desc = "Warn for Fireball Volley",

	conflagration_cmd = "conflagration",
	conflagration_name = "Conflagration Alert",
	conflagration_desc = "Warn for Conflagration",
	
	warstomp_cmd = "warstomp",
	warstomp_name = "War Stomp Alert",
	warstomp_desc = "Warn for War Stomp",
	
	
--Phase 1
	trigger_engage = "Intruders have breached the hatchery!", --CHAT_MSG_MONSTER_YELL
	
	trigger_polyYou = "You are afflicted by Greater Polymorph.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_polyOther = "(.+) is afflicted by Greater Polymorph.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_polyFade = "Greater Polymorph fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY //CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_poly = " Polymorph",
	msg_poly = " Polymorphed - Dispel!",
	
	trigger_mcYou =  "You are afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE --guessing
	trigger_mcOther2 = "(.+) %(.+%) is afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE --guessing
	trigger_mcOther = "(.+) is afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE --guessing
	trigger_mcFade = "Dominate Mind fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY //CHAT_MSG_SPELL_AURA_GONE_OTHER --guessing
	bar_mc = " MC",
	msg_mc = " MC - Dispel!",
	
	trigger_slow = "afflicted by Slow.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_slow = "Slowed",
	msg_slow = "Slow - Dispel!",
	
--Phase 2
		--there is no p2 trigger, orb is controllable from the start
		--timer for mobs spawn starts when?
	bar_mobsSpawn = "Mobs Spawn",
	
	trigger_destroyEggCast = "Razorgore the Untamed begins to cast Destroy Egg.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
	bar_destroyEggCast = "Destroying Egg",
	bar_destroyEggCd = "Destroy Egg CD",
	
		--doesn't happen every time; unreliable
	--trigger_eggDestroyed1 = "You'll pay for forcing me to do this!", --CHAT_MSG_MONSTER_YELL
	--trigger_eggDestroyed2 = "Fools! These eggs are more precious than you know!", --CHAT_MSG_MONSTER_YELL
	--trigger_eggDestroyed3 = "No! Not another one! I'll have your heads for this atrocity!", --CHAT_MSG_MONSTER_YELL
	
		--check for eggCast, if no re-cast or mindExhaustionFade within 3sec -> destroyed
	bar_eggsCounter = "Eggs Left",
	msg_eggCounter = "/30 Eggs Destroyed",
	
	trigger_mindExhaustionYou = "You are afflicted by Mind Exhaustion.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mindExhaustionOther = "(.+) is afflicted by Mind Exhaustion.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_mindExhaustionFade = "Mind Exhaustion fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY //CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mindExhaustion = " Mind Exhaustion",
	
		--there is no orb control trigger, aside from gain mind exhaustion
			--and then, there is no orb control fade trigger at all
				--must go with check raid pet
	--trigger_orbControl = "",
	bar_orb = " Orb Control",
	msg_orb = " is Controlling Razorgore",
	msg_orbFade = "Razorgore is loose!",
	
--Phase 3
	trigger_phase3 = "troops flee as the power of the controlling power of the orb is drained.", --CHAT_MSG_MONSTER_EMOTE
	msg_phase3 = "All Eggs are Destroyed - Phase 3 - Razorgore is free!",
	
	trigger_volleyCast = "Razorgore the Untamed begins to cast Fireball Volley.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_volleyCd = "Fireball Volley CD",
	bar_volleyCast = "Casting Fireball Volley",
	msg_volley = "Fireball Volley - Hide!",
	
	trigger_conflagrationYou = "You are afflicted by Conflagration.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_conflagrationOther = "(.+) is afflicted by Conflagration.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_conflagrationFade = "Conflagration fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY //CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_conflagrationCd = "Conflagration CD",
	bar_conflagrationDur = " Conflagration",
	msg_conflagration = " Conflagration",
	
	trigger_conflagHitYou = "Conflagration hits you for", --CHAT_MSG_SPELL_SELF_DAMAGE
	msg_conflagHitYou = "Move away from Conflag'd person you idiot!!!",
	
	trigger_warStomp = "Razorgore the Untamed's War Stomp", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_warStompDur = "War Stomped",
	bar_warStompCd = "War Stomp CD",
} end)

local timer = {
	polymorph = 20,
	mc = 15,
	slow = 10,
	
	mobSpawn = 46, --from engage
	
	orb = 90,
	mindExhaustion = 60,
	
	eggCast = 3,
	eggCd = 10,
	
	volleyFirstCd = 10,
	volleyCd = {14,16.5}, -- {16,18.5} - 2sec cast, saw 17.632 and 18.271
	volleyCast = 2,
	
	conflagrationCd = {5,9}, --{15,19} - 10sec dur, saw 15.496, 18.771
	conflagrationDur = 10,
	
	warStompFirstCd = 9, --saw 9.615
	warStompCd = 25, --30 - 5sec dur, saw 30.628
	warStompDur = 5,
}
local icon = {
	polymorph = "spell_nature_polymorph",
	mc = "spell_shadow_shadowworddominate",
	slow = "spell_nature_slow",
	
	mobSpawn = "spell_holy_prayerofspirit",
	
	orb = "INV_Misc_Gem_Pearl_03",
	mindExhaustion = "spell_shadow_teleport",
	
	egg = "inv_egg_03",
	
	volley = "Spell_Fire_FlameBolt",
	
	conflagration = "spell_fire_incinerate",
	
	warStomp = "ability_warstomp",
}
local color = {
	polymorph = "Blue",
	mc = "Black",
	slow = "Yellow",
	
	mobSpawn = "White",
	
	orb = "Cyan",
	mindExhaustion = "Black",
	
	eggCast = "Green",
	eggCd = "Yellow",
	eggBar = "Magenta",
	
	volleyCd = "Cyan",
	volleyCast = "Blue",
	
	conflagrationCd = "Orange",
	conflagrationDur = "Red",
	
	warStompCd = "Magenta",
	warStompDur = "Black",
}
local syncName = {
--Phase 1
	polymorph = "RazorgorePolymorph"..module.revision,
	polymorphFade = "RazorgorePolymorphFade"..module.revision,
	
	mc = "RazorgoreMc"..module.revision,
	mcFade = "RazorgoreMcFade"..module.revision,
	
	slow = "RazorgoreSlow"..module.revision,
	slowFade = "RazorgoreSlowFade"..module.revision,
	
--Phase 2
	orb = "RazorgoreOrbStart2"..module.revision,
	orbFade = "RazorgoreOrbStop2"..module.revision,
	
	mindExhaustion = "RazorgoreMindExhaustion"..module.revision,
	mindExhaustionFade = "RazorgoreMindExhaustionFade"..module.revision,
	
	destroyEggCast = "RazorgoreEggStart2"..module.revision,
	eggDestroyed = "RazorgoreEgg2"..module.revision,
	
--Phase 3
	phase3 = "RazorgorePhase3"..module.revision,
	volley = "RazorgoreVolleyCast"..module.revision,
	
	conflagration = "RazorgoreConflagration"..module.revision,
	conflagrationFade = "RazorgoreConflagrationFade"..module.revision,
	
	warStomp = "RazorgoreWarStomp"..module.revision,
}

local phase = "phase1"
local eggsDestroyed = 0
local orbController = nil
local destroyEggTime = 0
local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE") --trigger_phase3
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_polyYou, trigger_mcYou, trigger_slow, trigger_mindExhaustionYou, trigger_conflagrationYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_polyOther, trigger_mcOther, trigger_slow, trigger_mindExhaustionOther, trigger_conflagrationOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_polyOther, trigger_mcOther, trigger_slow, trigger_mindExhaustionOther, trigger_conflagrationOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_polyFade, trigger_mcFade, trigger_mindExhaustionFade, trigger_conflagrationFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_polyFade, trigger_mcFade, trigger_mindExhaustionFade, trigger_conflagrationFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_polyFade, trigger_mcFade, trigger_mindExhaustionFade, trigger_conflagrationFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "Event") --trigger_destroyEggCast

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_conflagHitYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_warStomp
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_warStomp
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_volleyCast, trigger_warStomp


	self:ThrottleSync(3, syncName.polymorph)
	self:ThrottleSync(3, syncName.polymorphFade)
	self:ThrottleSync(3, syncName.mc)
	self:ThrottleSync(3, syncName.mcFade)
	self:ThrottleSync(3, syncName.slow)
	self:ThrottleSync(3, syncName.slowFade)
	
	self:ThrottleSync(1, syncName.orb)
	self:ThrottleSync(1, syncName.orbFade)
	
	self:ThrottleSync(1, syncName.mindExhaustion)
	self:ThrottleSync(1, syncName.mindExhaustionFade)
	
	self:ThrottleSync(1, syncName.destroyEggCast)
	self:ThrottleSync(3, syncName.eggDestroyed)
	
		self:ThrottleSync(5, syncName.phase3)
	self:ThrottleSync(5, syncName.volley)
	
	self:ThrottleSync(5, syncName.conflagration)
	self:ThrottleSync(3, syncName.conflagrationFade)
	
	self:ThrottleSync(3, syncName.warStomp)
end

function module:OnSetup()
	self.started = nil
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	phase = "phase 1"
	eggsDestroyed = 0
	orbController = nil
	destroyEggTime = 0
	addDead = 0
	
	if self.db.profile.eggs then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_eggsCounter"], 30, "Interface\\Icons\\"..icon.egg, true, color.eggBar)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_eggsCounter"], eggsDestroyed)
	end
	self:ScheduleRepeatingEvent("Razorgore_OrbControlCheck", self.OrbControlCheck, 0.5, self)
	
	if self.db.profile.phase then
		self:Bar(L["bar_mobsSpawn"], timer.mobSpawn, icon.mobSpawn, true, color.mobSpawn)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("Razorgore_OrbControlCheck")
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Grethok the Controller")) then
		addDead = addDead + 1
		if addDead == 3 then
			--self:Sync(syncName.phase2)
		end
	elseif (msg == string.format(UNITDIESOTHER, "Blackwing Guardsman")) then
		addDead = addDead + 1
		if addDead == 3 then
			--self:Sync(syncName.phase2)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["trigger_engage"]) then
		module:SendEngageSync()
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["trigger_phase3"]) then
		self:Sync(syncName.phase3)
	end
end

function module:Event(msg)
--phase 1
	if msg == L["trigger_polyYou"] then
		self:Sync(syncName.polymorph .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_polyOther"]) then
		local _,_,polyPlayer,_ = string.find(msg, L["trigger_polyOther"])
		self:Sync(syncName.polymorph .. " " .. polyPlayer)
		
	elseif string.find(msg, L["trigger_polyFade"]) then
		local _,_,polyFadePlayer,_ = string.find(msg, L["trigger_polyFade"])
		if polyFadePlayer == "you" then polyFadePlayer = UnitName("Player") end
		self:Sync(syncName.polymorphFade .. " " .. polyFadePlayer)
		
		
	elseif msg == L["trigger_mcYou"] then
		self:Sync(syncName.mc .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_mcOther2"]) then
		local _,_,mcPlayer,_ = string.find(msg, L["trigger_mcOther2"])
		self:Sync(syncName.mc .. " " .. mcPlayer)

	elseif string.find(msg, L["trigger_mcOther"]) then
		local _,_,mcPlayer,_ = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPlayer)
		
	elseif string.find(msg, L["trigger_mcFade"]) then
		local _,_,mcFadePlayer,_ = string.find(msg, L["trigger_mcFade"])
		if mcFadePlayer == "you" then mcFadePlayer = UnitName("Player") end
		self:Sync(syncName.mcFade .. " " .. mcFadePlayer)
		
	
	elseif string.find(msg, L["trigger_slow"]) then
		self:Sync(syncName.slow)
		
		
--phase 2
	elseif msg == L["trigger_destroyEggCast"] then
		self:Sync(syncName.destroyEggCast)
		
		self:CancelScheduledEvent("Razorgore_DestroyEgg")
		self:ScheduleEvent("Razorgore_DestroyEgg", self.Razorgore_DestroyEgg, 3, self)
		
	
	
	elseif msg == L["trigger_mindExhaustionYou"] then
		self:Sync(syncName.mindExhaustion .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_mindExhaustionOther"]) then
		local _,_,mindExhaustionPlayer,_ = string.find(msg, L["trigger_mindExhaustionOther"])
		self:Sync(syncName.mindExhaustion .. " " .. mindExhaustionPlayer)
		
	elseif string.find(msg, L["trigger_mindExhaustionFade"]) then
		
		self:CancelScheduledEvent("Razorgore_DestroyEgg")
		
		local _,_,mindExhaustionFadePlayer,_ = string.find(msg, L["trigger_mindExhaustionFade"])
		if mindExhaustionFadePlayer == "you" then mindExhaustionFadePlayer = UnitName("Player") end
		self:Sync(syncName.mindExhaustionFade .. " " .. mindExhaustionFadePlayer)



--phase 3
	elseif msg == L["trigger_volleyCast"] then
		self:Sync(syncName.volley)
		
		
	elseif msg == L["trigger_conflagrationYou"] then
		self:Sync(syncName.conflagration .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_conflagrationOther"]) then
		local _,_,conflagPlayer,_ = string.find(msg, L["trigger_conflagrationOther"])
		self:Sync(syncName.conflagration .. " " .. conflagPlayer)
		
	elseif string.find(msg, L["trigger_conflagrationFade"]) then
		local _,_,conflagFadePlayer,_ = string.find(msg, L["trigger_conflagrationFade"])
		if conflagFadePlayer == "you" then conflagFadePlayer = UnitName("Player") end
		self:Sync(syncName.conflagrationFade .. " " .. conflagFadePlayer)
	
	elseif string.find(msg, L["trigger_conflagHitYou"]) and self.db.profile.conflagration and not string.find(msg, "Your Conflagration hits you for") then
		self:ConflagHitYou()
	
	elseif string.find(msg, L["trigger_warStomp"]) then
		self:Sync(syncName.warStomp)
	end
end

function module:Razorgore_DestroyEgg()
	if (GetTime() - destroyEggTime) >= 9 then
		destroyEggTime = GetTime()
		self:Sync(syncName.eggDestroyed)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.polymorph and rest and self.db.profile.polymorph then
		self:Polymorph(rest)
	elseif sync == syncName.polymorphFade and rest and self.db.profile.polymorph then
		self:PolymorphFade(rest)
		
	elseif sync == syncName.mc and rest and self.db.profile.dominatemind then
		self:Mc(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.dominatemind then
		self:McFade(rest)
		
	elseif sync == syncName.slow and self.db.profile.slow then
		self:Slow()
		
		
--Phase 2
	elseif sync == syncName.orb and rest and self.db.profile.orb then
		self:Orb(rest)
	elseif sync == syncName.orbFade and rest and self.db.profile.orb then
		self:OrbFade(rest)
		
	elseif sync == syncName.mindExhaustion and rest and self.db.profile.mindexhaustion then
		self:MindExhaustion(rest)
	elseif sync == syncName.mindExhaustionFade and rest and self.db.profile.mindexhaustion then
		self:MindExhaustionFade(rest)
		
	elseif sync == syncName.destroyEggCast and self.db.profile.eggs then
		self:DestroyEggCast()
	elseif sync == syncName.eggDestroyed and self.db.profile.eggs then
		self:EggDestroyed()

		
--Phase 3
	elseif sync == syncName.phase3 then
		self:Phase3()
		
	elseif sync == syncName.volley and self.db.profile.volley then
		self:Volley()
		
	elseif sync == syncName.conflagration and rest and self.db.profile.conflagration then
		self:Conflagration(rest)
	elseif sync == syncName.conflagrationFade and rest and self.db.profile.conflagration then
		self:ConflagrationFade(rest)
		
	elseif sync == syncName.warStomp and self.db.profile.warstomp then
		self:WarStomp()
	end
end


--Phase 1
function module:Polymorph(rest)
	self:Bar(rest..L["bar_poly"], timer.polymorph, icon.polymorph, true, color.polymorph)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then 
		self:Message(rest..L["msg_poly"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.polymorph, 1)
	end
end
function module:PolymorphFade(rest)
	self:RemoveBar(rest..L["bar_poly"])
	self:RemoveWarningSign(icon.polymorph)
end

function module:Mc(rest)
	self:Bar(rest..L["bar_mc"], timer.mc, icon.mc, true, color.mc)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then 
		self:Message(rest..L["msg_mc"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.mc, 1)
	end
end
function module:McFade(rest)
	self:RemoveBar(rest..L["bar_mc"])
	self:RemoveWarningSign(icon.mc)
end

function module:Slow()
	self:Bar(L["bar_slow"], timer.slow, icon.slow, true, color.slow)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then 
		self:Message(L["msg_slow"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.slow, 1)
	end
end

function module:OrbControlCheck()
	local orbIsControlled = nil
	
	if orbController == nil then
		for i=1,GetNumRaidMembers() do
			if UnitName("RaidPet"..i) == "Razorgore the Untamed" then
				self:Sync(syncName.orb .. " " .. UnitName("Raid"..i))
				orbController = UnitName("Raid"..i)
				break
			end
		end
		
	elseif orbController ~= nil and GetRealZoneText() == "Blackwing Lair" then
		for i=1,GetNumRaidMembers() do
			if UnitName("RaidPet"..i) == "Razorgore the Untamed" then
				orbIsControlled = true
				break
			end
		end
		if orbIsControlled == nil then
			self:Sync(syncName.orbFade .. " " .. orbController)
		end
	end
end

function module:Orb(rest)
	orbController = rest
	
	self:RemoveWarningSign(icon.orb)
	
	self:Bar(rest..L["bar_orb"], timer.orb, icon.orb, true, color.orb)
	self:Message(rest..L["msg_orb"], "Positive", false, nil, false)
end
function module:OrbFade(rest)
	orbController = nil
	self:RemoveBar(rest..L["bar_orb"])
	
	if phase == "phase 1" or phase == "phase 2" then
		self:Message(L["msg_orbFade"], "Urgent", false, nil, false)
		self:WarningSign(icon.orb, 1)
		self:Sound("Beware")
	end
end

function module:MindExhaustion(rest)
	self:Bar(rest..L["bar_mindExhaustion"], timer.mindExhaustion, icon.mindExhaustion, true, color.mindExhaustion)
	
	--can cast volley in p1, volley stops on orb control
	self:RemoveBar(L["bar_volleyCast"])
	self:RemoveWarningSign(icon.volley)
	self:CancelDelayedBar(L["bar_volleyCd"])
	self:RemoveBar(L["bar_volleyCd"])
	
	--can cast warStomp in p1
	self:RemoveBar(L["bar_warStompDur"])
	self:CancelDelayedBar(L["bar_warStompCd"])
	self:RemoveBar(L["bar_warStompCd"])
	
	--can cast conflag in p1
	self:CancelDelayedBar(L["bar_conflagrationCd"])
	self:RemoveBar(L["bar_conflagrationCd"])
end
function module:MindExhaustionFade(rest)
	self:RemoveBar(rest..L["bar_mindExhaustion"])
end

function module:DestroyEggCast()
	self:CancelDelayedBar(L["bar_destroyEggCd"])
	self:RemoveBar(L["bar_destroyEggCd"])
	
	self:Bar(L["bar_destroyEggCast"], timer.eggCast, icon.egg, true, color.eggCast)
	
	self:DelayedBar(timer.eggCast, L["bar_destroyEggCd"], timer.eggCd, icon.egg, true, color.eggCd)
end

function module:EggDestroyed()
	eggsDestroyed = eggsDestroyed + 1
	self:Message(eggsDestroyed..L["msg_eggCounter"])
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_eggsCounter"], eggsDestroyed)
end


--Phase 3
function module:Phase3()
	phase = "phase3"
	
	self:CancelScheduledEvent("Razorgore_OrbControlCheck")
	
	self:CancelScheduledEvent("Razorgore_DestroyEgg")
	self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_eggsCounter"])
	
	if self.db.profile.phase then
		self:Message(L["msg_phase3"], "Important", false, nil, false)
		self:Sound("Long")
	end
	
	if self.db.profile.volley then
		self:Bar(L["bar_volleyCd"], timer.volleyFirstCd, icon.volley, true, color.volleyCd)
	end
	
	if self.db.profile.conflagration then
		self:Bar(L["bar_conflagrationCd"], timer.conflagrationCd[1], timer.conflagrationCd[2], icon.conflagration, true, color.conflagrationCd)
	end
	
	if self.db.profile.warstomp then
		self:Bar(L["bar_warStompCd"], timer.warStompFirstCd, icon.warStomp, true, color.warStompCd)
	end
end

function module:Volley()
	self:RemoveBar(L["bar_volleyCd"])
	
	self:Bar(L["bar_volleyCast"], timer.volleyCast, icon.volley, true, color.volleyCast)
	self:Message(L["msg_volley"], "Important", false, nil, false)
	self:Sound("Alarm")
	self:WarningSign(icon.volley, timer.volleyCast)
	
	self:DelayedIntervalBar(timer.volleyCast, L["bar_volleyCd"], timer.volleyCd[1], timer.volleyCd[2], icon.volley, true, color.volleyCd)
end

function module:Conflagration(rest)
	self:RemoveBar(L["bar_conflagrationCd"])
	
	self:Bar(rest..L["bar_conflagrationDur"], timer.conflagrationDur, icon.conflagration, true, color.conflagrationDur)
	self:Message(rest..L["msg_conflagration"], "Urgent", false, nil, false)
	
	self:DelayedIntervalBar(timer.conflagrationDur, L["bar_conflagrationCd"], timer.conflagrationCd[1], timer.conflagrationCd[2], icon.conflagration, true, color.conflagrationCd)
end
function module:ConflagrationFade(rest)
	self:RemoveBar(rest..L["bar_conflagrationDur"])
end

function module:ConflagHitYou()
	self:Message(L["msg_conflagHitYou"], "Personal", false, nil, false)
	self:Sound("Info")
	self:WarningSign(icon.conflagration, 0.7)
end

function module:WarStomp()
	self:Bar(L["bar_warStompDur"], timer.warStompDur, icon.warStomp, true, color.warStompDur)
	
	self:DelayedBar(timer.warStompDur, L["bar_warStompCd"], timer.warStompCd, icon.warStomp, true, color.warStompCd)
end
