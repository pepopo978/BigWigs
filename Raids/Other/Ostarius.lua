
local module, L = BigWigs:ModuleDeclaration("Ostarius", "Tanaris")

module.revision = 30045
module.enabletrigger = module.translatedName
module.toggleoptions = {"conflagbar", "conflagyou", -1, "blizzard", "rainoffire", "sonicburst", -1, "activation", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Tanaris"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ostarius",

	conflagbar_cmd = "conflagbar",
	conflagbar_name = "Conflagration Timer",
	conflagbar_desc = "Timer for Conflagration",
	
	conflagyou_cmd = "conflagyou",
	conflagyou_name = "Conflagration Damage Alert",
	conflagyou_desc = "Warn for Conflagration Damage",
	
	blizzard_cmd = "blizzard",
	blizzard_name = "Blizzard Alert",
	blizzard_desc = "Warn for Blizzard",
	
	rainoffire_cmd = "rainoffire",
	rainoffire_name = "Rain of Fire Alert",
	rainoffire_desc = "Warn for Rain of Fire",

	sonicburst_cmd = "sonicburst",
	sonicburst_name = "Sonic Burst Alert",
	sonicburst_desc = "Warn for Sonic Burst",
	
	activation_cmd = "activation",
	activation_name = "Activation timer",
	activation_desc = "Timer for boss' activation",
	
		--using self only because affects many people within the same second
	trigger_conflagYou = "You are afflicted by Conflagration.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	say_conflagYou = "CONFLAG ON ME! RUN AWAY!",
	bar_conflag = " Conflag",
	trigger_conflagYouFade = "Conflagration fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	trigger_conflagHitYou = "'s Conflagration hits you for", --CHAT_MSG_SPELL_SELF_DAMAGE
	msg_conflagHitYou = "Move away from Conflagration!",
	
	trigger_blizzardYou = "You are afflicted by Blizzard.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_blizzardYou = "Move away from Blizzard!",
	trigger_blizzardYouFade = "Blizzard fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	trigger_rainOfFireYou = "You are afflicted by Rain of Fire.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_rainOfFireYou = "Move away from Rain of Fire!",
	trigger_rainOfFireYouFade = "Rain of Fire fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	trigger_sonicBurstYou = "You are afflicted by Sonic Burst.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_sonicBurstYou = "Sonic Burst is 20 yards...",
	
	
	bar_activeX = "Ostarius Activates",
	trigger_active33 = "Welcome, honored guests, to the research facility.", --CHAT_MSG_MONSTER_YELL
	msg_active33 = "Ostarius Active in 33 seconds!",
	
	trigger_active27 = "Please wait for the initial scanning...", --CHAT_MSG_MONSTER_YELL
	msg_active27 = "Ostarius Active in 27 seconds!",
	
	trigger_active17 = "WARNING! Curse of the flesh detected!", --CHAT_MSG_MONSTER_YELL
	msg_active17 = "Ostarius Active in 17 seconds!",
	
	trigger_active13 = "Initiating manual gate override... Gate locked successfully.",--CHAT_MSG_MONSTER_YELL
	msg_active13 = "Ostarius Active in 13 seconds!",
	
	trigger_active6 = "Activating defensive system for threat elimination.", --CHAT_MSG_MONSTER_YELL
	msg_active6 = "Ostarius Active in 6 seconds!",
	
	trigger_activeNow = "Guardians, awaken and smite these intruders!", --CHAT_MSG_MONSTER_YELL
	msg_activeNow = "Ostarius Active!",
	
	trigger_engage = "Ostarius gains Defensive Storm.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	
	trigger_aaaaa = "Ostarius reactivates all defenses out of desperation!", --CHAT_MSG_RAID_BOSS_EMOTE
	
		--starts doing earthquake, 1st as he yells, removes Defensive Storm
		--starts doing Chain Lightning too?
	trigger_bbbbb = "Still you persist, servants of the old ones? Very well.", --CHAT_MSG_MONSTER_YELL
	
	--[[
	Frost Breath?
	Stomp?
	Earthquake? starts happenning after a yell. Melee only?
	Harsh Winds?
	Mortality Scan, 11sec, channel, casted by Ostarius or not? Overlaps many. Kickable?
	Chain Lightning, interruptible? Happenned 3x, at 15sec interval
	The yells?
	Gate Construct, there is 8, do they spawn at the same time?
	]]--
} end )

local timer = {
	active33 = 33,
	active27 = 27,
	active17 = 17,
	active13 = 13,
	active6 = 6,
	
	conflag = 10,
	
	frostBreath = 99,
	stomp = 99,
	earthquake = 99,
	harshWinds = 99,
	mortalityScan = 11,
	chainLightning = 99,
}
local icon = {
	activeX = "inv_misc_pocketwatch_01",
	conflag = "spell_fire_incinerate",
	blizzard = "spell_frost_icestorm",
	rainOfFire = "spell_shadow_rainoffire",
	sonicBurst = "spell_shadow_teleport",
	
	frostBreath = "spell_frost_frostnova",
	stomp = "ability_warstomp",
	earthquake = "spell_nature_earthquake",
	harshWinds = "spell_nature_earthbind",
	mortalityScan = "ability_thunderbolt",
	chainLightning = "spell_nature_chainlightning",
}
local color = {
	activeX = "White",
	conflag = "Red",
	
	frostBreath = "Blue",
	stomp = "Yellow",
	earthquake = "Cyan",
	harshWinds = "Green",
	mortalityScan = "Black",
	chainLightning = "Orange",
}
local syncName = {
	active33 = "OstariusActive33"..module.revision,
	active27 = "OstariusActive27"..module.revision,
	active17 = "OstariusActive17"..module.revision,
	active13 = "OstariusActive13"..module.revision,
	active6 = "OstariusActive6"..module.revision,
	activeNow = "OstariusActiveNow"..module.revision,
	
	conflag = "OstariusConflag"..module.revision,
	conflagFade = "OstariusConflagFade"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_active6, trigger_bbbbb
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE") --trigger_aaaaa
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_engage
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_conflagYou, trigger_blizzardYou, trigger_rainOfFireYou, trigger_sonicBurstYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_conflagHitYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_conflagYouFade, trigger_blizzardYouFade, trigger_rainOfFireYouFade
		
	
	self:ThrottleSync(3, syncName.active33)
	self:ThrottleSync(3, syncName.active27)
	self:ThrottleSync(3, syncName.active17)
	self:ThrottleSync(3, syncName.active13)
	self:ThrottleSync(3, syncName.active6)
	self:ThrottleSync(3, syncName.activeNow)
	
	self:ThrottleSync(0, syncName.conflag)
	self:ThrottleSync(0, syncName.conflagFade)
	
	self:ThrottleSync(3, syncName.aaaaa)
	self:ThrottleSync(3, syncName.bbbbb)
	
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	self:RemoveBar(L["bar_activeX"])
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if msg == L["trigger_active33"] then
		self:Sync(syncName.active33)
	elseif msg == L["trigger_active27"] then
		self:Sync(syncName.active27)
	elseif msg == L["trigger_active17"] then
		self:Sync(syncName.active17)
	elseif msg == L["trigger_active13"] then
		self:Sync(syncName.active13)
	elseif msg == L["trigger_active6"] then
		self:Sync(syncName.active6)
	elseif msg == L["trigger_activeNow"] then
		self:Sync(syncName.activeNow)
	elseif msg == L["trigger_bbbbb"] then
		self:Sync(syncName.bbbbb)
	end
end

function module:CHAT_MSG_RAID_BOSS_EMOTE(msg, sender)
end

function module:Event(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	
	elseif msg == L["trigger_conflagYou"] then
		self:Sync(syncName.conflag .. " " .. UnitName("Player"))
		if self.db.profile.conflagyou then
			SendChatMessage(L["say_conflagYou"],"SAY")
		end
	
	elseif msg == L["trigger_conflagYouFade"] then
		self:Sync(syncName.conflagFade .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_conflagHitYou"]) and self.db.profile.conflagyou then
		self:Message(L["msg_conflagHitYou"], "Urgent", false, nil, false)
		self:WarningSign(icon.conflag, 0.7)
		self:Sound("Info")
		
		
	elseif msg == L["trigger_blizzardYou"] and self.db.profile.blizzard then
		self:Message(L["msg_blizzardYou"], "Urgent", false, nil, false)
		self:WarningSign(icon.blizzard, 10)
		self:Sound("RunAway")
		
	elseif msg == L["trigger_blizzardYouFade"] and self.db.profile.blizzard then
		self:RemoveWarningSign(icon.blizzard)
		
		
	elseif msg == L["trigger_rainOfFireYou"] and self.db.profile.rainoffire then
		self:Message(L["msg_rainOfFireYou"], "Urgent", false, nil, false)
		self:WarningSign(icon.rainOfFire, 10)
		self:Sound("RunAway")
		
	elseif msg == L["trigger_rainOfFireYouFade"] and self.db.profile.rainoffire then
		self:RemoveWarningSign(icon.rainOfFire)
		
		
	elseif msg == L["trigger_sonicBurstYou"] and self.db.profile.sonicburst then
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" or UnitClass("Player") == "Hunter" then
			self:Message(L["msg_sonicBurstYou"], "Urgent", false, nil, false)
			self:WarningSign(icon.sonicBurst, 1)
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.active33 and self.db.profile.activation then
		self:Active33()
	elseif sync == syncName.active27 and self.db.profile.activation then
		self:Active27()
	elseif sync == syncName.active17 and self.db.profile.activation then
		self:Active17()
	elseif sync == syncName.active13 and self.db.profile.activation then
		self:Active13()
	elseif sync == syncName.active6 and self.db.profile.activation then
		self:Active6()
	elseif sync == syncName.activeNow and self.db.profile.activation then
		self:ActiveNow()
	
	elseif sync == syncName.conflag and rest and self.db.profile.conflagbar then
		self:Conflag(rest)
	elseif sync == syncName.conflagFade and rest and self.db.profile.conflagbar then
		self:ConflagFade(rest)
	end
end


function module:Active33()
	self:RemoveBar(L["bar_activeX"])
	self:Bar(L["bar_activeX"], timer.active33, icon.activeX, true, color.activeX)
	self:Message(L["msg_active33"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:Active27()
	self:RemoveBar(L["bar_activeX"])
	self:Bar(L["bar_activeX"], timer.active27, icon.activeX, true, color.activeX)
	self:Message(L["msg_active27"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:Active17()
	self:RemoveBar(L["bar_activeX"])
	self:Bar(L["bar_activeX"], timer.active17, icon.activeX, true, color.activeX)
	self:Message(L["msg_active17"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:Active13()
	self:RemoveBar(L["bar_activeX"])
	self:Bar(L["bar_activeX"], timer.active13, icon.activeX, true, color.activeX)
	self:Message(L["msg_active13"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:Active6()
	self:RemoveBar(L["bar_activeX"])
	self:Bar(L["bar_activeX"], timer.active6, icon.activeX, true, color.activeX)
	self:Message(L["msg_active6"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:ActiveNow()
	self:RemoveBar(L["bar_activeX"])
	self:Message(L["msg_activeNow"], "Attention", false, nil, false)
	self:Sound("Alarm")
end

function module:Conflag(rest)
	self:Bar(rest..L["bar_conflag"], timer.conflag, icon.conflag, true, color.conflag)
end

function module:ConflagFade(rest)
	self:RemoveBar(rest..L["bar_conflag"])
end
