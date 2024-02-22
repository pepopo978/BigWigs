--Credits to balakethelock

local module, L = BigWigs:ModuleDeclaration("Kel'Thuzad", "Naxxramas")

module.revision = 30050
module.enabletrigger = module.translatedName
module.toggleoptions = {
	"frostbolt",
	"frostboltbar",
	-1,
	"frostblast",
	"proximity",
	"fissure",
	"mc",
	-1,
	"fbvolley",
	-1,
	"detonate",
	"detonateicon",
	"shackles",
	-1,
	"abomwarn",
	"weaverwarn",
	"guardians",
	-1,
	"addcount",
	"phase",
	"bosskill",
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Kelthuzad",

	phase_cmd = "phase",
	phase_name = "Phase Warnings",
	phase_desc = "Warn for phases.",

	mc_cmd = "mindcontrol",
	mc_name = "Mind Control",
	mc_desc = "Alerts when people are mind controlled.",

	fissure_cmd = "fissure",
	fissure_name = "Shadow Fissure",
	fissure_desc = "Alerts about incoming Shadow Fissures.",

	frostblast_cmd = "frostblast",
	frostblast_name = "Frost Blast",
	frostblast_desc = "Alerts when people get Frost Blasted.",

	frostbolt_cmd = "frostbolt",
	frostbolt_name = "Frostbolt Alert",
	frostbolt_desc = "Alerts about incoming Frostbolts",

	frostboltbar_cmd = "frostboltbar",
	frostboltbar_name = "Frostbolt Bar",
	frostboltbar_desc = "Displays a bar for Frostbolt casts",

	detonate_cmd = "detonate",
	detonate_name = "Detonate Mana Warning",
	detonate_desc = "Warns about Detonate Mana soon.",

	detonateicon_cmd = "detonateicon",
	detonateicon_name = "Raid Icon on Detonate",
	detonateicon_desc = "Place a raid icon on people with Detonate Mana.",

	guardians_cmd = "guardians",
	guardians_name = "Guardian Spawns",
	guardians_desc = "Warn for incoming Icecrown Guardians in phase 3.",

	shackles_cmd = "shackles",
	shackles_name = "Shackle announces",
	shackles_desc = "Warn when shackles are applied or broke",

	fbvolley_cmd = "fbvolley",
	fbvolley_name = "Possible volley",
	fbvolley_desc = "Timer for possible Frostbolt volley/multiple",

	addcount_cmd = "addcount",
	addcount_name = "P1 Add counter",
	addcount_desc = "Counts number of killed adds in P1",
	
	abomwarn_cmd = "abomwarn",
	abomwarn_name = "P1 Aboms alert",
	abomwarn_desc = "Play sound when Abom spawns",
	
	abomwarn_text = "Spawned Abomination ",
	
	weaverwarn_cmd = "weaverarn",
	weaverwarn_name = "P1 Weavers alert",
	weaverwarn_desc = "Play sound when Weaver spawns",
	
	proximity_cmd = "proximity",
	proximity_name = "Proximity Warning",
	proximity_desc = "Show Proximity Warning Frame",
	
	
	KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzad Chamber",
	
	
	weaverwarn_text = "Spawned Soulweaver ",
	
	trigger_mcYou = "You are afflicted by Chains of Kel'Thuzad.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mcOther = "(.+) is afflicted by Chains of Kel'Thuzad.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_mcFade = "Chains of Kel'Thuzad fades from (.+)", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	
	mc_trigger1 = "Your soul, is bound to me now!",
	mc_trigger2 = "There will be no escape!",
	mc_warning = "Mind Control!",
	mc_bar = "Possible Mind Control!",

	start_trigger = "Minions, servants, soldiers of the cold dark, obey the call of Kel'Thuzad!",
	start_trigger1 = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!",
	start_warning = "Kel'Thuzad encounter started! ~5min till he is active!",
	start_bar = "Phase 1 Timer",
	
	attack_trigger1 = "Kel'Thuzad attacks",
	attack_trigger2 = "Kel'Thuzad misses",
	attack_trigger3 = "Kel'Thuzad hits",
	attack_trigger4 = "Kel'Thuzad crits",
	kick_trigger1 = "Kick hits Kel'Thuzad",
	kick_trigger2 = "Kick crits Kel'Thuzad",
	kick_trigger3 = "Kick was blocked by Kel'Thuzad",
	pummel_trigger1 = "Pummel hits Kel'Thuzad",
	pummel_trigger2 = "Pummel crits Kel'Thuzad",
	pummel_trigger3 = "Pummel was blocked by Kel'Thuzad",
	shieldbash_trigger1 = "Shield Bash hits Kel'Thuzad",
	shieldbash_trigger2 = "Shield Bash crits Kel'Thuzad",
	shieldbash_trigger3 = "Shield Bash was blocked by Kel'Thuzad",
	earthshock_trigger1 = "Earth Shock hits Kel'Thuzad",
	earthshock_trigger2 = "Earth Shock crits Kel'Thuzad",

	phase1_warn = "Phase 1 ends in 20 seconds!",

	phase2_trigger1 = "Pray for mercy!",
	phase2_trigger2 = "Scream your dying breath!",
	phase2_trigger3 = "The end is upon you!",
	phase2_warning = "Phase 2, Kel'Thuzad incoming!",
	phase2_bar = "Kel'Thuzad Active!",

	phase3_soon_warning = "Phase 3 soon!",
	phase3_trigger = "Master! I require aid!",
	phase3_warning = "Phase 3, Guardians incoming!",

	guardians_bar = "Guardian %d",

	fissure_trigger = "casts Shadow Fissure.",
	fissure_warning = "Shadow Fissure!",

	frostbolt_trigger = "Kel'Thuzad begins to cast Frostbolt.",
	frostbolt_warning = "Frostbolt! Interrupt!",
	frostbolt_bar = "Frostbolt",


	frostbolt_volley = "Possible volley",
	frostbolt_volley_trigger = "afflicted by Frostbolt",

	add_dead_trigger = "(.*) dies",
	add_bar = "%d/14 %s",

	frostblast_bar = "Possible Frost Blast",
	frostblast_trigger1 = "I will freeze the blood in your veins!",
	frostblast_trigger2 = "^([^%s]+) ([^%s]+) afflicted by Frost Blast.",
	frostblast_warning = "Frost Blast!",
	frostblast_soon_message = "Possible Frost Blast in ~5sec!",

	phase2_frostblast_warning = "Possible Frost Blast in ~5sec!",
	phase2_mc_warning = "Possible Mind Control in ~5sec!",
	phase2_detonate_warning = "Detonate Mana in ~5sec!",

	detonate_trigger = "^([^%s]+) ([^%s]+) afflicted by Detonate Mana",
	detonate_bar = "Detonate Mana - %s",
	detonate_possible_bar = "Detonate Mana",
	detonate_warning = "%s has Detonate Mana!",

	shackle_trigger = "Guardian of Icecrown is afflicted by Shackle Undead",
	shacklefade_trigger = "Shackle Undead fades from Guardian of Icecrown",
	shackle_warning = "%s/3",

	you = "You",
	are = "are",

	
} end )

local timer = {
	phase1 = 320,
	firstFrostboltVolley = 30,
	frostboltVolley = {15,45},
	frostbolt = 2,
	phase2 = 15,
	firstDetonate = 20,
	detonate = 5,
	nextDetonate = {20,30},
	firstFrostblast = 50,
	frostblast = {30,60},
	firstMindcontrol = 60,
	mindcontrol = {60,90},
	mcduration = 20,
	firstGuardians = 5,
	guardians = 7,
}
local icon = {
	abomination = "Spell_Shadow_CallOfBone",
	soulWeaver = "Spell_Shadow_Possession",
	frostboltVolley = "Spell_Frost_FrostWard",
	mindcontrol = "Inv_Belt_18",
	phase = "Spell_Shadow_Raisedead",
	guardians = "Spell_Shadow_Raisedead",
	frostblast = "Spell_Frost_FreezingBreath",
	detonate = "Spell_Nature_WispSplode",
	frostbolt = "Spell_Frost_FrostBolt02",
	shackleundead = "Spell_Nature_Slow",
}
local color = {
	phase = "White",
	soulWeaver = "Blue",
	abomination = "Red",
	
	mindcontrol = "Black",
	detonate = "Green",
	volley = "Cyan",
	frostblast = "Red",
	frostbolt = "Blue",
	
	guardians = "Yellow",
}
local syncName = {
	detonate = "KelDetonate"..module.revision,
	frostblast = "KelFrostBlast"..module.revision,
	frostbolt = "KelFrostbolt"..module.revision,
	frostboltOver = "KelFrostboltStop"..module.revision,
	fissure = "KelFissure"..module.revision,
	mindcontrol = "KelMindControl"..module.revision,
	abomination = "KelAddDiesAbom"..module.revision,
	soulWeaver = "KelAddDiesSoul"..module.revision,
	phase2 = "KelPhase2"..module.revision,
	phase3 = "KelPhase3"..module.revision,
}

local timeLastFrostboltVolley = 0    -- saves time of first frostbolt
local numFrostboltVolleyHits = 0	-- counts the number of people hit by frostbolt
local numAbominations = 0	-- counter for Unstoppable Abomination's
local numWeavers = 0 	-- counter for Soul Weaver's
local timePhase1Start = 0    -- time of p1 start, used for tracking add count
local shacklecount = 0 -- Counter for shackles up

module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
module.proximitySilent = true

module:RegisterYellEngage(L["start_trigger"])
module:RegisterYellEngage(L["start_trigger1"])

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Affliction")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Affliction")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Affliction")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "ShackleCheck")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "ShackleCheck")

	self:ThrottleSync(5, syncName.detonate)
	self:ThrottleSync(0, syncName.frostblast)
	self:ThrottleSync(2, syncName.frostbolt)
	self:ThrottleSync(2, syncName.frostboltOver)
	self:ThrottleSync(2, syncName.fissure)
	self:ThrottleSync(2, syncName.abomination)
	self:ThrottleSync(2, syncName.soulWeaver)
	self:ThrottleSync(5, syncName.phase2)
	self:ThrottleSync(5, syncName.phase3)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self.warnedAboutPhase3Soon = nil
	frostbolttime = 0
	self.lastFrostBlast=0
end

function module:OnEngage()
	self.lastFrostBlast=0
	self:Message(L["start_warning"], "Attention", false, nil, false)
	self:Bar(L["start_bar"], timer.phase1, icon.phase, true, color.phase)
	self:DelayedMessage(timer.phase1 - 20, L["phase1_warn"], "Important", false, nil, false)

	if self.db.profile.addcount then
		timePhase1Start = GetTime() 	-- start of p1, used for tracking add counts
		numAbominations = 0
		numWeavers = 0
		self:Bar(string.format(L["add_bar"], numAbominations, "Unstoppable Abomination"), timer.phase1, icon.abomination, true, color.abomination)
		self:Bar(string.format(L["add_bar"], numWeavers, "Soul Weaver"), timer.phase1, icon.soulWeaver, true, color.soulWeaver)
	end

	self:ScheduleEvent("abom1", self.AbominationSpawns, 44, self, "1")
	self:ScheduleEvent("abom2", self.AbominationSpawns, 72, self, "2")
	self:ScheduleEvent("abom3", self.AbominationSpawns, 100, self, "3")
	self:ScheduleEvent("abom4", self.AbominationSpawns, 130, self, "4")
	self:ScheduleEvent("abom5", self.AbominationSpawns, 153, self, "5")
	self:ScheduleEvent("abom6", self.AbominationSpawns, 176, self, "6")
	self:ScheduleEvent("abom7", self.AbominationSpawns, 193, self, "7")
	self:ScheduleEvent("abom8", self.AbominationSpawns, 212, self, "8")
	self:ScheduleEvent("abom9", self.AbominationSpawns, 232, self, "9")
	self:ScheduleEvent("abom10", self.AbominationSpawns, 252, self, "10")
	self:ScheduleEvent("abom11", self.AbominationSpawns, 268, self, "11")
	self:ScheduleEvent("abom12", self.AbominationSpawns, 285, self, "12")
	self:ScheduleEvent("abom13", self.AbominationSpawns, 300, self, "13")
	self:ScheduleEvent("abom14", self.AbominationSpawns, 318, self, "14")
	
	self:ScheduleEvent("weaver1", self.WeaverSpawns, 44, self, "1")
	self:ScheduleEvent("weaver2", self.WeaverSpawns, 68, self, "2")
	self:ScheduleEvent("weaver3", self.WeaverSpawns, 97, self, "3")
	self:ScheduleEvent("weaver4", self.WeaverSpawns, 130, self, "4")
	self:ScheduleEvent("weaver5", self.WeaverSpawns, 155, self, "5")
	self:ScheduleEvent("weaver6", self.WeaverSpawns, 170, self, "6")
	self:ScheduleEvent("weaver7", self.WeaverSpawns, 190, self, "7")
	self:ScheduleEvent("weaver8", self.WeaverSpawns, 213, self, "8")
	self:ScheduleEvent("weaver9", self.WeaverSpawns, 235, self, "9")
	self:ScheduleEvent("weaver10", self.WeaverSpawns, 256, self, "10")
	self:ScheduleEvent("weaver11", self.WeaverSpawns, 271, self, "11")
	self:ScheduleEvent("weaver12", self.WeaverSpawns, 285, self, "12")
	self:ScheduleEvent("weaver13", self.WeaverSpawns, 294, self, "13")
	self:ScheduleEvent("weaver14", self.WeaverSpawns, 300, self, "14")

	-- Set combat range to max to make sure players don't miss any events.
	SetCVar("CombatDeathLogRange", 200)
	SetCVar("CombatLogRangeParty", 200)
	SetCVar("CombatLogRangePartyPet", 200)
	SetCVar("CombatLogRangeFriendlyPlayers", 200)
	SetCVar("CombatLogRangeFriendlyPlayersPets", 200)
	SetCVar("CombatLogRangeHostilePlayers", 200)
	SetCVar("CombatLogRangeHostilePlayersPets", 200)
	SetCVar("CombatLogRangeCreature", 200)
end

function module:OnDisengage()
	self:RemoveProximity()
	BigWigsFrostBlast:FBClose()
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= L["KELTHUZADCHAMBERLOCALIZEDLOLHAX"] or self.core:IsModuleActive(module.translatedName) then
		return
	end

	self.core:EnableModule(module.translatedName)
end

-- check for phase 3
function module:UNIT_HEALTH(msg)
	if self.db.profile.phase then
		if UnitName(msg) == self.translatedName then
			local health = UnitHealth(msg)
			if health > 35 and health <= 40 and not self.warnedAboutPhase3Soon then
				self:Message(L["phase3_soon_warning"], "Attention", false, nil, false)
				self.warnedAboutPhase3Soon = true
			elseif health > 40 and self.warnedAboutPhase3Soon then
				self.warnedAboutPhase3Soon = nil
			end
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["phase2_trigger1"] or msg == L["phase2_trigger2"] or msg == L["phase2_trigger3"] then
		self:Sync(syncName.phase2)
	elseif string.find(msg, L["phase3_trigger"]) then
		self:Sync(syncName.phase3)
	elseif msg == L["mc_trigger1"] or msg == L["mc_trigger2"] then
		self:Sync(syncName.mindcontrol)
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE( msg )
	if string.find(msg, L["frostbolt_trigger"]) then
		self:Sync(syncName.frostbolt)
	end
	if string.find(msg, L["fissure_trigger"]) then
		self:Sync(syncName.fissure)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	local _,_, mob = string.find(msg, L["add_dead_trigger"])
	if self.db.profile.addcount and (mob == "Unstoppable Abomination") then
		self:Sync(syncName.abomination .. " " .. mob)
	elseif self.db.profile.addcount and (mob == "Soul Weaver") then
		self:Sync(syncName.soulWeaver .. " " .. mob)
	elseif self.db.profile.bosskill and (mob == "Kel'Thuzad") then
		self:SendBossDeathSync()
	end
end

function module:Affliction(msg)
	local _, _, sPlayer, sType = string.find(msg, L["frostblast_trigger2"])
	if ( sPlayer and sType ) then
		if ( sPlayer == "You" and sType == "are" ) then
			self:Sync(syncName.frostblast.." "..UnitName("player"))
		else
			self:Sync(syncName.frostblast.." "..sPlayer)
		end
	end

	if string.find(msg, L["detonate_trigger"]) then
		local _,_, dplayer, dtype = string.find( msg, L["detonate_trigger"])
		if dplayer and dtype then
			if dplayer == L["you"] and dtype == L["are"] then
				dplayer = UnitName("player")
			end
			self:Sync(syncName.detonate .. " ".. dplayer)
		end
	end

	if self.db.profile.fbvolley and string.find(msg, L["frostbolt_volley_trigger"]) then
		local now = GetTime()

		-- only warn if there are more than 4 players hit by frostbolt volley within 4s
		if now - timeLastFrostboltVolley > 4 then
			timeLastFrostboltVolley = now
			numFrostboltVolleyHits = 1
		else
			numFrostboltVolleyHits = numFrostboltVolleyHits + 1
		end

		if numFrostboltVolleyHits == 4 then

			self:IntervalBar(L["frostbolt_volley"], timer.frostboltVolley[1], timer.frostboltVolley[2], icon.frostboltVolley, true, color.volley)

			self:CancelDelayedBar(L["frostbolt_volley"])
			self:DelayedIntervalBar(timer.frostboltVolley[2], L["frostbolt_volley"], timer.frostboltVolley[1], timer.frostboltVolley[2], icon.frostboltVolley, true, color.volley)
		end
	end
end

function module:ShackleCheck(msg)
	if string.find(msg, L["shackle_trigger"]) then
		shacklecount = shacklecount + 1
		--self:WarningSign(icon.shackleundead, 120, true, string.format(L["shackle_warning"], shacklecount))
		if shacklecount < 2 then
			--self:Sound("ShackleOne")
		end
		if shacklecount == 2 then
			--self:Sound("ShackleTwo")
		end
		if shacklecount > 2 then
			--self:Sound("ShackleThree")
		end
	end
	if string.find(msg, L["shacklefade_trigger"]) then
		shacklecount = shacklecount - 1
		if shacklecount < 0 then shacklecount = 0 end
		--self:WarningSign(icon.shackleundead, 120, true, string.format(L["shackle_warning"], shacklecount))
		--self:Sound("ShackleBroke")
	end
end

function module:Event(msg)
	-- shadow fissure
	if string.find(msg, L["fissure_trigger"]) then
		self:Sync(syncName.fissure)
	end

	-- frost bolt
	if GetTime() < frostbolttime + timer.frostbolt then
		if string.find(msg, L["attack_trigger1"]) or string.find(msg, L["attack_trigger2"]) or string.find(msg, L["attack_trigger3"]) or string.find(msg, L["attack_trigger4"]) then
			self:RemoveBar(L["frostbolt_bar"])
			frostbolttime = 0
			self:Sync(syncName.frostboltOver)
		elseif string.find(msg, L["kick_trigger1"]) or string.find(msg, L["kick_trigger2"]) or string.find(msg, L["kick_trigger3"]) -- kicked
			or string.find(msg, L["pummel_trigger1"]) or string.find(msg, L["pummel_trigger2"]) or string.find(msg, L["pummel_trigger3"]) -- pummeled
			or string.find(msg, L["shieldbash_trigger1"]) or string.find(msg, L["shieldbash_trigger2"]) or string.find(msg, L["shieldbash_trigger3"]) -- shield bashed
			or string.find(msg, L["earthshock_trigger1"]) or string.find(msg, L["earthshock_trigger2"]) then -- earth shocked

			self:RemoveBar(L["frostbolt_bar"])
			frostbolttime = 0
			self:Sync(syncName.frostboltOver)
		end
	else
		frostbolttime = 0
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 then
		self:Phase2()
	elseif sync == syncName.phase3 then
		self:Phase3()
	elseif sync == syncName.mindcontrol then
		self:MindControl()
	elseif sync == syncName.frostblast then
		self:FrostBlast(rest)
	elseif sync == syncName.detonate and rest then
		self:Detonate()
	elseif sync == syncName.frostbolt then       -- changed from only frostbolt (thats only alert, if someone still wants to see the bar, it wouldnt work then)
		self:Frostbolt()
	elseif sync == syncName.frostboltOver then
		self:FrostboltOver()
	elseif sync == syncName.fissure then
		self:Fissure()
	elseif sync == syncName.abomination and rest then
		self:AbominationDies(rest)
	elseif sync == syncName.soulWeaver and rest then
		self:WeaverDies(rest)
	end
end


function module:Phase2()
	shacklecount = 0
	self:Bar(L["phase2_bar"], timer.phase2, icon.phase, true, color.phase)
	self:DelayedMessage(timer.phase2, L["phase2_warning"], "Important", false, nil, false)
	if self.db.profile.mc then
		self:DelayedBar(timer.phase2, L["mc_bar"], timer.firstMindcontrol, icon.mindcontrol, true, color.mindcontrol)
		self:DelayedMessage(timer.firstMindcontrol  + timer.phase2 - 5, L["phase2_mc_warning"], "Important", false, nil, false)
	end
	if self.db.profile.detonate then
		self:DelayedBar(timer.phase2, L["detonate_possible_bar"], timer.firstDetonate, icon.detonate, true, color.detonate)
		self:DelayedMessage(timer.firstDetonate + timer.phase2 - 5, L["phase2_detonate_warning"], "Important", false, nil, false)
	end
	if self.db.profile.frostblast then
		self:DelayedBar(timer.phase2, L["frostblast_bar"], timer.firstFrostblast, icon.frostblast, true, color.frostblast)
		self:DelayedMessage(timer.firstFrostblast  + timer.phase2 - 5, L["phase2_frostblast_warning"], "Important", false, nil, false)
	end

	if self.db.profile.fbvolley then
		self:DelayedBar(timer.phase2, L["frostbolt_volley"], timer.firstFrostboltVolley, icon.frostboltVolley, true, color.volley)
	end

	-- master target should be automatically set, as soon as a raid assistant targets kel'thuzad

	-- proximity silent
	if self.db.profile.proximity then
		self:ScheduleEvent("bwShowProximity", self.Proximity, timer.phase2, self)
	end
	self:ScheduleEvent("bwShowFBFrame", function() BigWigsFrostBlast:FBShow() end, timer.phase2, self)

	local function removeP1Bars()
		self:RemoveBar(L["start_bar"])
		self:RemoveBar(string.format(L["add_bar"], numWeavers, "Soul Weaver"))
		self:RemoveBar(string.format(L["add_bar"], numAbominations, "Unstoppable Abomination"))
		if self:IsEventScheduled("abom1") then
		self:CancelScheduledEvent("abom1") 
		self:CancelScheduledEvent("abom2") 
		self:CancelScheduledEvent("abom3") 
		self:CancelScheduledEvent("abom4") 
		self:CancelScheduledEvent("abom5") 
		self:CancelScheduledEvent("abom6") 
		self:CancelScheduledEvent("abom7") 
		self:CancelScheduledEvent("abom8") 
		self:CancelScheduledEvent("abom9") 
		self:CancelScheduledEvent("abom10")
		self:CancelScheduledEvent("abom11")
		self:CancelScheduledEvent("abom12")
		self:CancelScheduledEvent("abom13")
		self:CancelScheduledEvent("abom14")
		self:CancelScheduledEvent("weaver1")
		self:CancelScheduledEvent("weaver2")
		self:CancelScheduledEvent("weaver3")
		self:CancelScheduledEvent("weaver4")
		self:CancelScheduledEvent("weaver5")
		self:CancelScheduledEvent("weaver6")
		self:CancelScheduledEvent("weaver7")
		self:CancelScheduledEvent("weaver8")
		self:CancelScheduledEvent("weaver9")
		self:CancelScheduledEvent("weaver10")
		self:CancelScheduledEvent("weaver11")
		self:CancelScheduledEvent("weaver12")
		self:CancelScheduledEvent("weaver13")
		self:CancelScheduledEvent("weaver14")
		end
	end
	self:ScheduleEvent("bwKTremoveP1Bars", removeP1Bars, 1, self)

end

function module:Phase3()
	shacklecount = 0
	if self.db.profile.phase then
		self:Message(L["phase3_warning"], "Attention", false, nil, false)
		self:Sound("Beware")
	end
	if self.db.profile.guardians then
		self:Bar(string.format(L["guardians_bar"],1), timer.firstGuardians, icon.guardians, true, color.guardians)
		for i = 0,3 do
			self:DelayedBar(timer.firstGuardians+timer.guardians*i, string.format(L["guardians_bar"],i+2), timer.guardians, icon.guardians, true, color.guardians)
		end
	end
end

function module:MindControl()
	if self.db.profile.mc then
		self:Message(L["mc_warning"], "Urgent", false, nil, false)
		self:IntervalBar(L["mc_bar"], timer.mindcontrol[1], timer.mindcontrol[2], icon.mindcontrol, true, color.mindcontrol)
		self:Bar(L["mc_warning"], timer.mcduration, icon.mindcontrol, true, color.mindcontrol)
	end
end

function module:FrostBlast(name)
	if self.db.profile.frostblast then
		if GetTime()-self.lastFrostBlast>5 then
			self.lastFrostBlast=GetTime()
			self:Message(L["frostblast_warning"], "Attention", false, nil, false)
			self:DelayedMessage(timer.frostblast[1] - 5, L["frostblast_soon_message"], false, nil, false)
			self:IntervalBar(L["frostblast_bar"], timer.frostblast[1], timer.frostblast[2], icon.frostblast, true, color.frostblast)
		end
	end
	if name and name ~= "" then
		BigWigsFrostBlast:AddFrostBlastTarget(name)
	end
end

function module:Detonate(name)
	if name and self.db.profile.detonate then
		self:Message(string.format(L["detonate_warning"], name), "Attention", false, nil, false)
		if self.db.profile.detonateicon then
			self:Icon(name)
		end
		self:Bar(string.format(L["detonate_bar"], name), timer.detonate, icon.detonate)
		self:IntervalBar(L["detonate_possible_bar"], timer.nextDetonate[1], timer.nextDetonate[2], icon.detonate)
	end
end

function module:Frostbolt()
	if self.db.profile.frostbolt or self.db.profile.frostboltbar then
		frostbolttime = GetTime()
		if self.db.profile.frostbolt then
			self:Message(L["frostbolt_warning"], "Personal", false, nil, false)
		end
		if self.db.profile.frostboltbar then
			self:Bar(L["frostbolt_bar"], timer.frostbolt, icon.frostbolt, true, color.frostbolt)
		end
	end
end

function module:FrostboltOver()
	if self.db.profile.frostbolt then
		self:RemoveBar(L["frostbolt_bar"])
		frostbolttime = 0
	end
end

function module:Fissure()
	if self.db.profile.fissure then
		self:Message(L["fissure_warning"], "Urgent", false, nil, false)
		self:Sound("Beware")
		-- add bar?
	end
end

function module:AbominationDies(name)
	if name and self.db.profile.addcount then
		self:RemoveBar(string.format(L["add_bar"], numAbominations, name))
		numAbominations = numAbominations + 1
		if numAbominations < 14 then
			self:Bar(string.format(L["add_bar"], numAbominations, name), (timePhase1Start + timer.phase1 - GetTime()), icon.abomination, true, color.abomination)
		end
	end
end

function module:WeaverDies(name)
	if name and self.db.profile.addcount then
		self:RemoveBar(string.format(L["add_bar"], numWeavers, name))
		numWeavers = numWeavers + 1
		if numWeavers < 14 then
			self:Bar(string.format(L["add_bar"], numWeavers, name), (timePhase1Start + timer.phase1 - GetTime()), icon.soulWeaver, true, color.soulWeaver)
		end
	end
end

function module:AbominationSpawns(count)
	if count and self.db.profile.abomwarn then
		self:Message(L["abomwarn_text"]..count.."/14", "Personal", false, nil, false)
	end
end

function module:WeaverSpawns(count)
	if count and self.db.profile.weaverwarn then
		self:Message(L["weaverwarn_text"]..count.."/14", "Personal", false, nil, false)
	end
end

