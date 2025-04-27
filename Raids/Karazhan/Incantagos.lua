local module, L = BigWigs:ModuleDeclaration("Ley-Watcher Incantagos", "Karazhan")

-- module variables
module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = { "leyline", "gaze", "summonseeker", "summonwhelps", "affinity", "proximity", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

-- module defaults
module.defaultDB = {
	leyline = true,
	gaze = true,
	summonseeker = true,
	summonwhelps = true,
	affinity = true,
	proximity = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "Incantagos",

		leyline_cmd = "leyline",
		leyline_name = "Ley-Line Disturbance Alert",
		leyline_desc = "Warns when Ley-Watcher Incantagos casts Ley-Line Disturbance",

		gaze_cmd = "gaze",
		gaze_name = "Gaze Alert",
		gaze_desc = "Warns when Ley-Watcher Incantagos begins to cast Gaze of Incantagos",

		summonseeker_cmd = "summonseeker",
		summonseeker_name = "Summon Ley-Seeker Alert",
		summonseeker_desc = "Warns when Ley-Watcher Incantagos summons Manascale Ley-Seeker",

		summonwhelps_cmd = "summonwhelps",
		summonwhelps_name = "Summon Whelps Alert",
		summonwhelps_desc = "Warns when Ley-Watcher Incantagos summons Manascale Whelps",

		affinity_cmd = "affinity",
		affinity_name = "Affinity Alert",
		affinity_desc = "Warns when players get an affinity that requires action",

		proximity_cmd = "proximity",
		proximity_name = "Proximity Warning",
		proximity_desc = "Show Proximity Warning Frame",

		trigger_gazeCast = "Ley%-Watcher Incantagos begins to cast Gaze of Incantagos",
		bar_gazeCast = "Gaze of Incantagos",
		msg_gaze = "Gaze of Incantagos casting - Fear in 1.5 sec",

		trigger_summonSeekerCast = "Ley%-Watcher Incantagos begins to cast Summon Manascale Ley%-Seeker",
		bar_summonSeekerCast = "Ley-Seeker Summoning",
		msg_summonSeeker = "Manascale Ley-Seeker spawning in 2 sec!",

		trigger_summonWhelpsCast = "Ley%-Watcher Incantagos begins to cast Summon Manascale Whelps",
		bar_summonWhelpsCast = "Whelps Summoning",
		msg_summonWhelps = "Manascale Whelps spawning in 2 sec!",

		trigger_leyLineCast = "Ley%-Watcher Incantagos begins to cast Ley%-Line Disturbance",
		bar_leyLineCast = "Ley-Line Disturbance casting",
		bar_leyLineCD = "Next Possible Ley-Line Disturbance",
		msg_leyLine = "Ley-Line Disturbance casting!",

		trigger_greenAffinity = "gain Green Affinity",
		trigger_blackAffinity = "gain Black Affinity",
		trigger_redAffinity = "gain Red Affinity",
		trigger_blueAffinity = "gain Blue Affinity",
		trigger_manaAffinity = "gain Mana Affinity",
		trigger_crystalAffinity = "gain Crystal Affinity",

		msg_greenAffinity = "GREEN AFFINITY - Shamans and Druids handle this!",
		msg_blackAffinity = "BLACK AFFINITY - Priests and Warlocks handle this!",
		msg_redAffinity = "RED AFFINITY - Mages and Warlocks handle this!",
		msg_blueAffinity = "BLUE AFFINITY - Mages handle this!",
		msg_manaAffinity = "MANA AFFINITY - Mages and Druids handle this!",
		msg_crystalAffinity = "CRYSTAL AFFINITY - Warriors, Rogues, Paladins and Hunters handle this!",
	}
end)

-- timer and icon variables
local timer = {
	firstLeyLine = { 70, 80 }, -- 1:10 to 1:20
	leyLineCD = { 53, 63 },
	leyLineCast = 3,
	gazeCast = 1.5,
	summonSeekerCast = 2,
	summonWhelpsCast = 2,
}

local icon = {
	leyLine = "Spell_Arcane_PortalIronForge",
	greenAffinity = "Spell_Nature_AbolishMagic",
	blackAffinity = "Spell_Shadow_ShadowBolt",
	redAffinity = "Spell_Fire_FlameBolt",
	blueAffinity = "Spell_Frost_FrostBolt02",
	manaAffinity = "Spell_Nature_StarFall",
	crystalAffinity = "INV_Sword_04",
}

local color = {
	leyLine = "Blue",
	gaze = "Red",
	summonSeeker = "Yellow",
	summonWhelps = "Orange",
}

local syncName = {
	gaze = "IncantagosGaze" .. module.revision,
	summonSeeker = "IncantagosSummonSeeker" .. module.revision,
	summonWhelps = "IncantagosSummonWhelps" .. module.revision,
	leyLine = "IncantagosLeyLine" .. module.revision,
	greenAffinity = "IncantagosGreenAffinity" .. module.revision,
	blackAffinity = "IncantagosBlackAffinity" .. module.revision,
	redAffinity = "IncantagosRedAffinity" .. module.revision,
	blueAffinity = "IncantagosBlueAffinity" .. module.revision,
	manaAffinity = "IncantagosManaAffinity" .. module.revision,
	crystalAffinity = "IncantagosCrystalAffinity" .. module.revision,
}

-- Proximity Plugin
module.proximityCheck = function(unit)
	return CheckInteractDistance(unit, 2)
end
module.proximitySilent = true

-- module functions
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFF")

	self:ThrottleSync(3, syncName.gaze)
	self:ThrottleSync(5, syncName.summonSeeker)
	self:ThrottleSync(5, syncName.summonWhelps)
	self:ThrottleSync(5, syncName.leyLine)
	self:ThrottleSync(2, syncName.greenAffinity)
	self:ThrottleSync(2, syncName.blackAffinity)
	self:ThrottleSync(2, syncName.redAffinity)
	self:ThrottleSync(2, syncName.blueAffinity)
	self:ThrottleSync(2, syncName.manaAffinity)
	self:ThrottleSync(2, syncName.crystalAffinity)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.leyline then
		self:IntervalBar(L["bar_leyLineCD"], timer.firstLeyLine[1], timer.firstLeyLine[2], icon.leyLine, true, color.leyLine)
	end

	if self.db.profile.proximity then
		self:Proximity()
	end
end

function module:OnDisengage()
	self:RemoveProximity()
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["trigger_gazeCast"]) then
		self:Sync(syncName.gaze)
	elseif string.find(msg, L["trigger_summonSeekerCast"]) then
		self:Sync(syncName.summonSeeker)
	elseif string.find(msg, L["trigger_summonWhelpsCast"]) then
		self:Sync(syncName.summonWhelps)
	elseif string.find(msg, L["trigger_leyLineCast"]) then
		self:Sync(syncName.leyLine)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF(msg)
	if string.find(msg, L["trigger_greenAffinity"]) then
		self:Sync(syncName.greenAffinity)
	elseif string.find(msg, L["trigger_blackAffinity"]) then
		self:Sync(syncName.blackAffinity)
	elseif string.find(msg, L["trigger_redAffinity"]) then
		self:Sync(syncName.redAffinity)
	elseif string.find(msg, L["trigger_blueAffinity"]) then
		self:Sync(syncName.blueAffinity)
	elseif string.find(msg, L["trigger_manaAffinity"]) then
		self:Sync(syncName.manaAffinity)
	elseif string.find(msg, L["trigger_crystalAffinity"]) then
		self:Sync(syncName.crystalAffinity)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.gaze then
		self:Gaze()
	elseif sync == syncName.summonSeeker then
		self:SummonSeeker()
	elseif sync == syncName.summonWhelps then
		self:SummonWhelps()
	elseif sync == syncName.leyLine then
		self:LeyLine()
	elseif sync == syncName.greenAffinity and self.db.profile.affinity then
		self:GreenAffinity()
	elseif sync == syncName.blackAffinity and self.db.profile.affinity then
		self:BlackAffinity()
	elseif sync == syncName.redAffinity and self.db.profile.affinity then
		self:RedAffinity()
	elseif sync == syncName.blueAffinity and self.db.profile.affinity then
		self:BlueAffinity()
	elseif sync == syncName.manaAffinity and self.db.profile.affinity then
		self:ManaAffinity()
	elseif sync == syncName.crystalAffinity and self.db.profile.affinity then
		self:CrystalAffinity()
	end
end

function module:Gaze()
	if self.db.profile.gaze then
		self:Message(L["msg_gaze"], "Important", true, "Alert")
	end
end

function module:SummonSeeker()
	if self.db.profile.summonseeker then
		self:Message(L["msg_summonSeeker"], "Attention")
	end
end

function module:SummonWhelps()
	if self.db.profile.summonwhelps then
		self:Message(L["msg_summonWhelps"], "Attention")
	end
end

function module:LeyLine()
	if self.db.profile.leyline then
		self:Message(L["msg_leyLine"], "Important")
		self:RemoveBar(L["bar_leyLineCD"])
		self:Bar(L["bar_leyLineCast"], timer.leyLineCast, icon.leyLine, true, color.leyLine)
		self:IntervalBar(L["bar_leyLineCD"], timer.leyLineCD[1], timer.leyLineCD[2], icon.leyLine, true, color.leyLine)
	end
end

function module:GreenAffinity()
	self:Message(L["msg_greenAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.greenAffinity, 5)
end

function module:BlackAffinity()
	self:Message(L["msg_blackAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.blackAffinity, 5)
end

function module:RedAffinity()
	self:Message(L["msg_redAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.redAffinity, 5)
end

function module:BlueAffinity()
	self:Message(L["msg_blueAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.blueAffinity, 5)
end

function module:ManaAffinity()
	self:Message(L["msg_manaAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.manaAffinity, 5)
end

function module:CrystalAffinity()
	self:Message(L["msg_crystalAffinity"], "Important", true, "Alarm")
	self:WarningSign(icon.crystalAffinity, 5)
end

function module:Test()
	-- Initialize module state
	self:OnSetup()
	self:OnEngage()

	local events = {
		-- First Ley-Line around 1:15
		{ time = 4, text = "Ley-Watcher Incantagos begins to cast Ley-Line Disturbance." },

		-- Gaze
		{ time = 7, text = "Ley-Watcher Incantagos begins to cast Gaze of Incantagos." },

		-- Summon Seeker
		{ time = 7, text = "Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker." },

		-- Summon Whelps
		{ time = 7, text = "Ley-Watcher Incantagos begins to cast Summon Manascale Whelps." },

		-- Affinities
		{ time = 10, text = "You gain Green Affinity (1)." },
		{ time = 17, text = "You gain Black Affinity (1)." },
		{ time = 24, text = "You gain Red Affinity (1)." },
		{ time = 31, text = "You gain Blue Affinity (1)." },
		{ time = 38, text = "You gain Mana Affinity (1)." },
		{ time = 45, text = "You gain Crystal Affinity (1)." },

		-- Second Ley-Line about 55s after first one
		{ time = 55, text = "Ley-Watcher Incantagos begins to cast Ley-Line Disturbance." },
	}

	local handlers = {
		["Ley-Watcher Incantagos begins to cast Ley-Line Disturbance."] = function()
			print("Test: Ley-Watcher Incantagos begins to cast Ley-Line Disturbance")
			module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE("Ley-Watcher Incantagos begins to cast Ley-Line Disturbance.")
		end,
		["Ley-Watcher Incantagos begins to cast Gaze of Incantagos."] = function()
			print("Test: Ley-Watcher Incantagos begins to cast Gaze of Incantagos")
			module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE("Ley-Watcher Incantagos begins to cast Gaze of Incantagos.")
		end,
		["Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker."] = function()
			print("Test: Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker")
			module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE("Ley-Watcher Incantagos begins to cast Summon Manascale Ley-Seeker.")
		end,
		["Ley-Watcher Incantagos begins to cast Summon Manascale Whelps."] = function()
			print("Test: Ley-Watcher Incantagos begins to cast Summon Manascale Whelps")
			module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE("Ley-Watcher Incantagos begins to cast Summon Manascale Whelps.")
		end,
		["You gain Green Affinity (1)."] = function()
			print("Test: You gain Green Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Green Affinity (1).")
		end,
		["You gain Black Affinity (1)."] = function()
			print("Test: You gain Black Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Black Affinity (1).")
		end,
		["You gain Red Affinity (1)."] = function()
			print("Test: You gain Red Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Red Affinity (1).")
		end,
		["You gain Blue Affinity (1)."] = function()
			print("Test: You gain Blue Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Blue Affinity (1).")
		end,
		["You gain Mana Affinity (1)."] = function()
			print("Test: You gain Mana Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Mana Affinity (1).")
		end,
		["You gain Crystal Affinity (1)."] = function()
			print("Test: You gain Crystal Affinity")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_BUFF("You gain Crystal Affinity (1).")
		end,
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("IncantagosTest" .. i, function(eventText)
			if handlers[eventText] then
				handlers[eventText]()
			end
		end, event.time, event.text)
	end

	self:Message("Ley-Watcher Incantagos test started", "Positive")
	return true
end

-- /run local m=BigWigs:GetModule("Ley-Watcher Incantagos"); BigWigs:SetupModule("Ley-Watcher Incantagos");m:Test();
