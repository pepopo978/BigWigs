local module, L = BigWigs:ModuleDeclaration("Kara Trash", "Karazhan")

module.revision = 30000
module.trashMod = true -- how does this affect things
module.enabletrigger = { "Unstable Arcane Elemental", "Disrupted Arcane Elemental", "Arcane Anomaly", "Crumbling Protector", "Lingering Magus" }
module.toggleoptions = { "mana_buildup", "unstable_mana", "overflowing_arcana", "self_destruct" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
	"Outland",
	"???"
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

		self_destruct_cmd = "self_destruct",
		self_destruct_name = "Self Destruction Protocol Alert",
		self_destruct_desc = "Warn when Self Destruction Protocol is casting.",

		trigger_mana_buildup = "(.+) ...? afflicted by Mana Buildup",
		trigger_unstable_mana = "(.+) ...? afflicted by Unstable Mana",
		trigger_overflowing_arcana = "(.+) ...? afflicted by Overflowing Arcana(.+)",
		trigger_self_destruct = "Crumbling Protector begins to cast Self Destruction Protocol",

		trigger_remove_mana_buildup = "Your Mana Buildup is removed",

		-- todo, add this, add tracking for maguses
		-- 4/20 23:07:11.741  Lingering Magus casts Enveloped Flames(58004) on Misandria.

		msg_mana_buildup_remove = "Mana Buildup dispelled.",
		msg_mana_buildup = "You are a bomb, get dispelled or get out of the raid!",
		warn_mana_buildup = "Mana Buildup (bomb) on %s!",
		bar_mana_buildup = "Mana Buildup, get dispelled or get out!",

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
	mana_buildup = true,
	unstable_mana = true,
	overflowing_arcana = true,
	self_destruct = true,
	-- bosskill           = nil,
}

local timer = {
	mana_buildup = 7,
	unstable_mana = 10,
	overflowing_arcana = 8, -- warning icon and application delay
	self_destruct = 4,
}

local icon = {
	mana_buildup = "Spell_Nature_Lightning",
	unstable_mana = "Spell_Shadow_Teleport",
	overflowing_arcana = "INV_Enchant_EssenceEternalLarge",
	self_destruct = "Spell_Shadow_LifeDrain",
}

local syncName = {
	mana_buildup = "ManaBuildup" .. module.revision,
	unstable_mana = "UnstableMana" .. module.revision,
	overflowing_arcana = "OverflowingArcana" .. module.revision,
	self_destruct = "SelfDestruct" .. module.revision,
}

local debuffedPlayers = {}
local maguses = {}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")

	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA", "RemoveEvent")

	if SUPERWOW_VERSION or SetAutoloot then
		self:RegisterEvent("UNIT_CASTEVENT")
	else
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "DestructEvent") -- not sure which of these it is
		self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "DestructEvent")  -- not sure which of these it is
	end

	self:ThrottleSync(1, syncName.mana_buildup)
	self:ThrottleSync(1, syncName.unstable_mana)
	self:ThrottleSync(1, syncName.overflowing_arcana)
	self:ThrottleSync(1, syncName.self_destruct)
end

-- function module:OnSetup()
-- end

-- function module:OnEngage()
-- end

-- function module:OnDisengage()
-- end

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
			self:Bar(L.self_destruct, timer.self_destruct, icon.self_destruct)
		end
	elseif sync == syncName.shackleShatter and rest then
		self:ShackleShatter(rest)
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
		-- after  1s, simulate the “Crash Landing fades from Living Stone” fade event
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
	}

	for i, t in ipairs(tests) do
		if type(t[2]) == "string" then
			local t1, t2, t3, t4 = t[1], t[2], t[3], t[4]
			self:ScheduleEvent("RupturanTest" .. i, function()
				print(t2)
				self:TriggerEvent(t3, t4)
			end, t1)
		else
			self:ScheduleEvent("RupturanTest" .. i, t[2], t[1])
		end
	end

	self:Message(module.translatedName .. " test started", "Positive")
	return true
end
-- /run BigWigs:GetModule("Kara Trash"):Test()
