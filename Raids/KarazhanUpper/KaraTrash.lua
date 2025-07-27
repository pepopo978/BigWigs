local module, L = BigWigs:ModuleDeclaration("Kara Trash", "Karazhan")

local has_superwow = SUPERWOW_VERSION or SetAutoloot

module.revision = 30002
module.trashMod = true -- how does this affect things
module.enabletrigger = {
	"Manascale Drake",

	"Unstable Arcane Elemental",
	"Disrupted Arcane Elemental",
	"Arcane Anomaly",
	"Crumbling Protector",
	"Lingering Magus",
	"Lingering Astrologist",
 }
module.toggleoptions = {
	"frigid_mana_breath",
	"draconic_thrash",

	"mana_buildup",
	"unstable_mana",
	"overflowing_arcana",
	"self_destruct",
	"astral_insight", -- added toggle
}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
	"Outland",
	"???"
}

local guid_patterns = {
	manascale_drake = "^0xF13000F1F427",
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "UpperKaraTrash",

		mana_buildup_cmd = "mana_buildup",
		mana_buildup_name = "Mana Buildup Alert",
		mana_buildup_desc = "Warn to get out of raid if you have Mana Buildup bomb.",

		unstable_mana_cmd = "unstable_mana",
		unstable_mana_name = "Unstable Mana Alert",
		unstable_mana_desc = "Warn to get out of raid if you have Unstable Mana bomb.",

		overflowing_arcana_cmd = "overflowing_arcana",
		overflowing_arcana_name = "Overflowing Arcana Alert",
		overflowing_arcana_desc = "Warn when Overflowing Arcana stacks are near the limit.",

		overflowing_arcana_cmd = "overflowing_arcana",
		overflowing_arcana_name = "Overflowing Arcana Alert",
		overflowing_arcana_desc = "Warn when Overflowing Arcana stacks are near the limit.",

		frigid_mana_breath_cmd = "frigid_mana_breath",
		frigid_mana_breath_name = "Manascale Drake Breath",
		frigid_mana_breath_desc = "Warn when Manascale Drake is able to cast Frigid Mana Breath.",

		draconic_thrash_cmd = "draconic_thrash",
		draconic_thrash_name = "Manascale Threat Drop",
		draconic_thrash_desc = "Warn when Manascale Drake is about to wing buffet.",

		astral_insight_cmd = "astral_insight",
		astral_insight_name = "Astral Insight Alert",
		astral_insight_desc = "Warn and stop casting if you are afflicted by Astral Insight.",

		self_destruct_cmd = "self_destruct",
		self_destruct_name = "Self Destruction Protocol Alert",
		self_destruct_desc = "Warn when Self Destruction Protocol is casting.",

		trigger_mana_buildup = "(.+) ...? afflicted by Mana Buildup",
		trigger_unstable_mana = "(.+) ...? afflicted by Unstable Mana",
		trigger_overflowing_arcana = "(.+) ...? afflicted by Overflowing Arcana(.+)",
		trigger_self_destruct = "Crumbling Protector begins to cast Self Destruction Protocol",

		trigger_remove_mana_buildup = "Your Mana Buildup is removed",

		bar_astral_insight = "Astral Insight (stop casting!)",
		msg_astral_insight = "Stop casting!",
		trigger_astral_insight = "(.+) ...? afflicted by Astral Insight",

		-- todo, add this, add tracking for maguses
		-- 4/20 23:07:11.741  Lingering Magus casts Enveloped Flames(58004) on Misandria.

		-- todo, add overseer AE
		bar_frigid_mana_breath = "Drake Breath soon",
		bar_draconic_thrash    = "Wing Buffet soon",

		msg_mana_buildup_remove = "Mana Buildup dispelled.",
		msg_mana_buildup = "You are a bomb, get dispelled or get out of the raid!",
		warn_mana_buildup = "Mana Buildup (bomb) on %s!",
		bar_mana_buildup = "Mana Buildup (bomb)",

		msg_unstable_mana = "You are a bomb, get out of the raid!",
		warn_unstable_mana = "Unstable Mana (bomb) on %s!",
		bar_unstable_mana = "Unstable Mana (bomb)",

		warn_overflowing_arcana = "Flee from Arcane Anomaly!",
		bar_overflowing_arcana = "Overflowing Arcana dot stacks",

		warn_self_destruct = "Flee from Crumbling Protector!",
		bar_self_destruct = "Self Destruction Protocol",
	}
end)

module.defaultDB = {
	frigid_mana_breath = true,
	draconic_thrash = false,

	mana_buildup = true,
	unstable_mana = true,
	overflowing_arcana = true,
	self_destruct = false,

	astral_insight = true, -- default enabled
	-- bosskill           = nil,
}

local timer = {
	mana_buildup = 7,
	unstable_mana = 10,
	overflowing_arcana = 8, -- warning icon and application delay
	self_destruct = 4,
	frigid_mana_breath = {14, 19},
	draconic_thrash = {12, 14},
	astral_insight = 7, -- 7 sec timer bar
}

local icon = {
	mana_buildup = "Spell_Nature_Lightning",
	unstable_mana = "Spell_Shadow_Teleport",
	overflowing_arcana = "INV_Enchant_EssenceEternalLarge",
	self_destruct = "Spell_Shadow_LifeDrain",
	frigid_mana_breath = "Spell_Frost_FrostShock",
	draconic_thrash = "INV_Misc_MonsterScales_05",
	astral_insight = "Ability_Creature_Cursed_03",
}

local syncName = {
	mana_buildup = "ManaBuildup" .. module.revision,
	unstable_mana = "UnstableMana" .. module.revision,
	overflowing_arcana = "OverflowingArcana" .. module.revision,
	self_destruct = "SelfDestruct" .. module.revision,
	drake_engage = "DrakeEngage" .. module.revision,
}

local debuffedPlayers = {}
local maguses = {}
local tracked_guids = {}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SelfAfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA", "RemoveEvent")

	if has_superwow then
		self:RegisterEvent("UNIT_CASTEVENT")
		self:RegisterEvent("UNIT_FLAGS")
	else
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "DestructEvent") -- not sure which of these it is
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "DestructEvent")  -- not sure which of these it is
	end

	self:ThrottleSync(1, syncName.mana_buildup)
	self:ThrottleSync(1, syncName.unstable_mana)
	self:ThrottleSync(1, syncName.overflowing_arcana)
	self:ThrottleSync(1, syncName.self_destruct)
	self:ThrottleSync(10, syncName.drake_engage)
end

-- todo: replace this with a proper top level flags detection feature for pull detection
function module:UNIT_FLAGS(unit)
	if not UnitAffectingCombat(unit) then return end
	if not tracked_guids[unit] and string.find(unit, guid_patterns.manascale_drake) then
		tracked_guids[unit] = true
		self:Sync(syncName.drake_engage)
	end
end

function module:CheckDrakeTarget()
	local drakeTarget = nil

	if UnitName("target") == "Manascale Drake" then
		drakeTarget = UnitName("targettarget")
	else
		-- loop through raid to find someone targeting the drake
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid" .. i .. "target") == "Manascale Drake" then
				drakeTarget = UnitName("raid" .. i .. "targettarget")
				break
			end
		end
	end

	if drakeTarget then
		self:Sync(syncName.drake_engage)
	end
end

-- function module:OnSetup()
-- end

function module:OnEngage()
	if not has_superwow and self.db.profile.frigid_mana_breath then
		-- start checking for drake changing targets
		self:ScheduleRepeatingEvent("bwdraketargetcheck", self.CheckDrakeTarget, 0.2, self)
		-- don't run forever if this isn't a drake pack
		self:ScheduleEvent("disable_bwdraketargetcheck", "CancelScheduledEvent", 5, "bwdraketargetcheck")
	end
end

function module:OnDisengage()
	tracked_guids = {}
end

function module:UNIT_CASTEVENT(caster, target, action, spell_id, cast_time)
	if caster and spell_id == 57659 then
		-- 5/2 20:47:37.998  Astrov casts Arcana Explode(57659) on Astrov.
	end
	if caster and spell_id == 57652 and action == "START" then
		self:Sync(syncName.self_destruct)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, "Arcane Anomaly") then
		self:TriggerEvent("BigWigs_StopCounterBar", self, L.bar_overflowing_arcana)
	end
end

function module:DestructEvent(msg)
	if string.find(msg, L.trigger_self_destruct) then
		self:Sync(syncName.self_destruct)
	end
end

function module:AfflictionEvent(msg)
	-- Check for Mana Buildup
	local _, _, playerMB = string.find(msg, L.trigger_mana_buildup)
	if playerMB then
		if playerMB == "You" then
			playerMB = UnitName("player")
		end
		self:Sync(syncName.mana_buildup .. " " .. playerMB)
		return
	end
	local _, _, playerUM = string.find(msg, L.trigger_unstable_mana)
	if playerUM then
		if playerUM == "You" then
			playerUM = UnitName("player")
		end
		self:Sync(syncName.unstable_mana .. " " .. playerUM)
		return
	end
	local _, _, playerOA, rest = string.find(msg, L.trigger_overflowing_arcana)
	if playerOA then
		if playerOA == "You" then
			playerOA = UnitName("player")
		end
		local _, _, n = string.find(rest, "(%d+)")
		n = tonumber(n)
		self:Sync(syncName.overflowing_arcana .. " " .. playerOA .. (n or 1))
		return
	end
end

function module:SelfAfflictionEvent(msg)
	if self.db.profile.astral_insight then
		-- Astral Insight handling using trigger
		local _, _, playerAI = string.find(msg, L.trigger_astral_insight)
		if playerAI then
			self:WarningSign(icon.astral_insight, timer.astral_insight, true, L.msg_astral_insight)
			self:Bar(L.bar_astral_insight, timer.astral_insight, icon.astral_insight)
			return
		end
	end
	-- Fallback to original AfflictionEvent logic for self
	module.AfflictionEvent(self, msg)
end

function module:RemoveEvent(msg)
	-- Check for Mana Buildup removal
	if string.find(msg, L.trigger_remove_mana_buildup) then
		self:RemoveBar(L.bar_mana_buildup)
		self:Message(L.msg_mana_buildup_remove, "Green", nil)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mana_buildup then
		if self.db.profile.mana_buildup and rest == UnitName("player") then
			self:Sound("Beware")
			self:Bar(L.bar_mana_buildup, timer.mana_buildup, icon.mana_buildup)
			self:Message(string.format(L.warn_mana_buildup, rest), "Attention", nil, "Info")
		elseif self.db.profile.mana_buildup then
			self:Message(string.format(L.warn_mana_buildup, rest), "Attention", nil, "Info")
		end
	elseif sync == syncName.unstable_mana then
		if self.db.profile.unstable_mana and rest == UnitName("player") then
			self:Sound("Beware")
			self:Message(string.format(L.warn_unstable_mana, rest), "Attention", nil, "Info")
			self:Bar(L.bar_unstable_mana, timer.unstable_mana, icon.unstable_mana)
		elseif self.db.profile.unstable_mana then
			self:Message(string.format(L.warn_unstable_mana, rest), "Attention", nil, "Info")
		end
	elseif sync == syncName.overflowing_arcana then
		if self.db.profile.overflowing_arcana then
			local _, _, player, n = string.find(rest, "(.-)(%d+)")
			n = tonumber(n)
			if n and player and player == UnitName("player") then
				if n == 1 then
					-- no icon, it's buggy and could confuse people
					self:TriggerEvent("BigWigs_StartCounterBar", self, L.bar_overflowing_arcana, 5, nil, true, "red", "green")
				end
				self:TriggerEvent("BigWigs_SetCounterBar", self, L.bar_overflowing_arcana, 5 - n)
				if n == 4 then
					self:Sound("RunAway")
					self:WarningSign(icon.overflowing_arcana, 8, true, L.warn_overflowing_arcana)
					self:Bar(L.warn_overflowing_arcana, timer.overflowing_arcana, icon.overflowing_arcana)
				end
			end
		end
	elseif sync == syncName.self_destruct then
		if self.db.profile.self_destruct then
			self:Sound("RunAway")
			self:Bar(L.bar_self_destruct, timer.self_destruct, icon.self_destruct)
		end
	elseif sync == syncName.drake_engage then
		if self.db.profile.frigid_mana_breath then
			self:IntervalBar(L.bar_frigid_mana_breath, timer.frigid_mana_breath[1], timer.frigid_mana_breath[2], icon.frigid_mana_breath)
		end
		if self.db.profile.draconic_thrash then
			self:IntervalBar(L.bar_draconic_thrash, timer.draconic_thrash[1], timer.draconic_thrash[2], icon.draconic_thrash)
		end
	end
end

-------------------------------------------------------------------------------
--  Testing
-------------------------------------------------------------------------------

function module:Test()
	local print = function(s)
		DEFAULT_CHAT_FRAME:AddMessage(s)
	end
	BigWigs:EnableModule(self:ToString())

	local player = UnitName("player")
	local tests = {
		-- {0,
		-- "Engage:",
		-- "CHAT_MSG_MONSTER_YELL",
		-- "All shall crumble... To dust."},
		{ 3,
			"Mana Buildup bar, you:",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Mana Buildup (1)." },
		-- after  2s, simulate the quake damage event
		{ 11,
			"Mana Buildup bar, other:",
			"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
			player .. " is afflicted by Mana Buildup (1)." },
		{ 14,
			"Mana Buildup bar, dispell:",
			"CHAT_MSG_SPELL_BREAK_AURA",
			"Your Mana Buildup is removed." },
		{ 15,
			"Unstable Mana",
			"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE",
			UnitName("raid2") .. " is afflicted by Unstable Mana (1)." },
		-- Astral Insight unit test
		{ 20,
			"Astral Insight affliction (self):",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Astral Insight." },
		{ 26,
			"Overflowing Arcana",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana." },
		{ 28,
			"Overflowing Arcana (1)",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana (1)." },
		{ 30,
			"Overflowing Arcana (2)",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana (2)." },
		{ 30,
			"Overflowing Arcana (2) sync",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			player .. "is afflicted by Overflowing Arcana (2)." },
		{ 32,
			"Overflowing Arcana (3)",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana (3)." },
		{ 34,
			"Overflowing Arcana (4)",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana (4)." },
		{ 34,
			"Overflowing Arcana (4) sync",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			player .. "is afflicted by Overflowing Arcana (4)." },
		{ 36,
			"Overflowing Arcana (5)",
			"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
			"You are afflicted by Overflowing Arcana (5)." },
		{ 38,
			"Anomaly Dies:",
			"CHAT_MSG_COMBAT_HOSTILE_DEATH",
			"Arcane Anomaly dies." },
		{ 42,
			"Drake engaged (vanilla):",
			"BigWigs_SendSync",
			syncName.drake_engage},
		{ 62,
			"Drake engaged (superwow):", -- commentout the unitcombat check in unit_flags to test this
			"UNIT_FLAGS",
			"0xF13000F1F4276B71" },
	}

	for i, t in ipairs(tests) do
		local t1,t2,t3,t4 = t[1],t[2],t[3],t[4]
		if type(t2) == "string" then
			self:ScheduleEvent(module.translatedName.."Test"..i, function()
				print(t2)
				if type(t4) == "table" then
					self:TriggerEvent(t3, unpack(t4))
				else
					self:TriggerEvent(t3, t4)
				end
			end, t1)
		else
			self:ScheduleEvent(module.translatedName.."Test"..i, t2, t1)
		end
	end

	self:Message(module.translatedName .. " test started", "Positive")
	return true
end
-- /run BigWigs:GetModule("Kara Trash"):Test()
