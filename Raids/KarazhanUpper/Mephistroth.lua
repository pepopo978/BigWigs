local module, L = BigWigs:ModuleDeclaration("Mephistroth", "Karazhan")

module.revision = 30002
module.enabletrigger = module.translatedName
module.toggleoptions = { "shacklescast", "shacklesdebuff", "shackleshatter", "shardscd", "shardschannel", "markdoom", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
	"Outland",
	"???"
}

-- module defaults
module.defaultDB = {
	shacklescast = true,
	shacklesdebuff = true,
	shackleshatter = false,
	shardscd = true,
	shardschannel = true,
	markdoom = true,
}

L:RegisterTranslations("enUS", function()
	return {
		-- options
		cmd = "Mephistroth",

		shacklescast_cmd = "shacklescast",
		shacklescast_name = "Shackles Cast Alert",
		shacklescast_desc = "Warn when Mephistroth begins casting Shackles of the Legion.",

		shacklesdebuff_cmd = "shacklesdebuff",
		shacklesdebuff_name = "Shackles Debuff Alert",
		shacklesdebuff_desc = "Warn and timer when Shackles of the Legion lands.",

		shackleshatter_cmd = "shackleshatter",
		shackleshatter_name = "Shackle Shatter Tattle",
		shackleshatter_desc = "Tell who failed standing still.",

		shardscd_cmd = "shardscd",
		shardscd_name = "Shards of Hellfury Countdown",
		shardscd_desc = "Show countdown to next Shards of Hellfury.",

		shardschannel_cmd = "shardschannel",
		shardschannel_name = "Shards of Hellfury Channel Time",
		shardschannel_desc = "Show time left before Channel enrage.",

		markdoom_cmd = "markdoom",
		markdoom_name = "Mark Doom Target",
		markdoom_desc = "Mark a Doomed player with Triangle.",

		-- triggers
		trigger_engage = "I foresaw your arrival", -- CHAT_MSG_MONSTER_YELL
		trigger_shacklesDebuffYou = "You are afflicted by Shackles of the Legion",
		trigger_shacklesDebuffOther = "(.+) is afflicted by Shackles of the Legion",
		trigger_doomDebuff = "(.+) ...? afflicted by Doom of Outland",
		trigger_doomDebuffFade = "Doom of Outland fades from (.+)%.",

		trigger_shacklesFade = "Shackles of the Legion fades from (.+)%.",

		trigger_shackleShatterYou = "Your Shackle Shatter .-its",
		trigger_shackleShatterOther = "(.+)'s Shackle Shatter .-its",

		-- messages & bars
		msg_shacklesCast = "Shackles of the Legion incoming! >>DO NOT MOVE<<",
		bar_shacklesCast = "Casting Shackles",
		msg_shacklesCastAlert = "Shackles Casting >>STOP MOVING<<",

		bar_shacklesDebuff = "Shackles of the Legion",
		msg_shacklesDebuffYou = "You are shackled! >>DO NOT MOVE<<",
		msg_shacklesDebuffOther = "%s is shackled!",

		msg_shackleShatter = " didn't keep still.",

		bar_shardsChannel = "Shard Enrage",
		bar_shardsCD      = "Next Shards Cast",
		msg_shardsCast    = "Hellfire Shards casting, go kill shards!",
	}
end)

local timer = {
	shacklesInitialCD = { 68, 96 }, -- 60 to 120 ?
	shacklesCD = { 40, 70 },
	shacklesCast = 2.5,
	shacklesDebuff = 6,
	shardsCast = 6,
	shardsCD = 120,
	shardsCD_bar_delay = 25,
	shardsChannel = 25,
}

local icon = {
	shackles = "INV_Belt_18",
	shardsCD = "Spell_Fire_Fire",
	shardsChannel = "Spell_Fire_SoulBurn",
}

local syncName = {
	shacklesCast = "MephistrothShacklesCast" .. module.revision,
	shacklesDebuff = "MephistrothShacklesDebuff" .. module.revision,
	shackleShatter = "MephistrothShackleShatter" .. module.revision,
	shardsCD = "MephistrothShardsOfHellfuryCD" .. module.revision,
	shardsChannel = "MephistrothShardsOfHellfuryChannel" .. module.revision,
	shardsChannelEnd = "MephistrothShardsOfHellfuryChannelEnd" .. module.revision,
	markDoom = "MephistrothMarkDoom" .. module.revision,
}

local fail_shards = 0

module:RegisterYellEngage(L.trigger_engage)

--------------------------------------------------------------------------------
--  Module OnEnable
--------------------------------------------------------------------------------

function module:OnSetup()
	self.started = nil
end

-- should sync enables
function module:OnEnable()
	if SUPERWOW_STRING or SetAutoloot then
		self:RegisterEvent("UNIT_CASTEVENT", "MephistrothCastEvent")
	end

	-- Debuff landing
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")

	-- Debuff fading
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "DebuffFade")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "DebuffFade")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "DebuffFade")

	self:ThrottleSync(2, syncName.shacklesCast)
	self:ThrottleSync(2, syncName.shacklesDebuff)
	self:ThrottleSync(2, syncName.shackleShatter)
	self:ThrottleSync(2, syncName.shardsCD)
	self:ThrottleSync(5, syncName.shardsChannel)
	self:ThrottleSync(5, syncName.shardsChannelEnd)
end

function module:OnEngage()
	fail_shards = 0
end

--------------------------------------------------------------------------------
--  Cast Event
--------------------------------------------------------------------------------
function module:MephistrothCastEvent(casterGuid, targetGuid, eventType, spellId, castTime)
	-- if not self.db.profile.shacklescast then return end
	-- todo: I believe shackles is a channel but don't know for sure yet
	if spellId == 51916 and (eventType == "START" or eventType == "CHANNEL") then
		self:Sync(syncName.shacklesCast .. " " .. (castTime / 1000))
	elseif spellId == 51917 then
		-- Shackle Shatter
		self:Sync(syncName.shackleShatter .. " " .. UnitName(casterGuid))
	elseif spellId == 51942 and eventType == "START" then
		fail_shards = 0
		self:Sync(syncName.shardsCD)
	elseif spellId == 51947 then
		if eventType == "CHANNEL" then
			self:Sync(syncName.shardsChannel .. " " .. (castTime / 1000))
		elseif eventType == "FAIL" then
			fail_shards = fail_shards + 1
			if fail_shards == 6 then
				fail_shards = 0
				self:Sync(syncName.shardsChannelEnd)
			end
		end
	elseif spellId == 51948 and eventType == "CAST" then
		-- todo: shard completed, good spot for an enrage indication
	end
end

--------------------------------------------------------------------------------
--  Debuff landing
--------------------------------------------------------------------------------
function module:Event(msg)
	-- if not self.db.profile.shacklesdebuff then return end

	if self.db.profile.shacklesdebuff then
		-- self-detected, trigger a debuff alert
		if string.find(msg, L.trigger_shacklesDebuffYou) then
			self:ShacklesDebuff(UnitName("player"))
			return
		end
		local _, _, player = string.find(msg, L.trigger_shacklesDebuffOther)
		if player then
			self:Sync(syncName.shacklesDebuff .. " " .. player)
			return
		end
	end
	if self.db.profile.shackleshatter then
		if string.find(msg, L.trigger_shackleShatterYou) then
			self:Sync(syncName.shackleShatter .. " " .. UnitName("player"))
			return
		end
		local _, _, player = string.find(msg, L.trigger_shackleShatterOther)
		if player then
			self:Sync(syncName.shackleShatter .. " " .. player)
			return
		end
	end
	if self.db.profile.shackleshatter then
		if string.find(msg, L.trigger_shackleShatterYou) then
			self:Sync(syncName.shackleShatter .. " " .. UnitName("player"))
			return
		end
		local _, _, player = string.find(msg, L.trigger_shackleShatterOther)
		if player then
			self:Sync(syncName.shackleShatter .. " " .. player)
			return
		end
	end
	if self.db.profile.markdoom then
		local _, _, player = string.find(msg, L.trigger_doomDebuff)
		if player then
			player = player == "You" and UnitName("player") or player
			self:SetRaidTargetForPlayer(player, 4) -- tri
			return
		end
		local _, _, player = string.find(msg, L.trigger_doomDebuffFade)
		if player then
			player = player == "you" and UnitName("player") or player
			self:RestorePreviousRaidTargetForPlayer(player)
		end
	end
end

--------------------------------------------------------------------------------
--  Debuff fades
--------------------------------------------------------------------------------
function module:DebuffFade(msg)
	if not self.db.profile.shacklesdebuff then
		return
	end
	local _, _, player = string.find(msg, L.trigger_shacklesFade)
	if player == "you" then
		self:RemoveBar(string.format(L.bar_shacklesDebuff, player))
		self:RemoveWarningSign(icon.shackles)
	end
end

--------------------------------------------------------------------------------
--  Sync handler
--------------------------------------------------------------------------------
function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shacklesCast then
		local castTime = tonumber(rest)
		self:ShacklesCast(castTime)
	elseif sync == syncName.shacklesDebuff and rest then
		self:ShacklesDebuff(rest)
	elseif sync == syncName.shackleShatter and rest then
		self:ShackleShatter(rest)
	elseif sync == syncName.shardsCD then
		self:ShardsCD()
	elseif sync == syncName.shardsChannel and rest then
		local castTime = tonumber(rest)
		self:ShardsChannel(castTime)
	elseif sync == syncName.shardsChannelEnd then
		self:RemoveBar(L.bar_shardsChannel)
	end
end

--------------------------------------------------------------------------------
--  Alerts & Bars
--------------------------------------------------------------------------------
function module:ShacklesCast(castTime)
	if not self.db.profile.shacklescast then
		return
	end
	local dur = castTime or timer.shacklesCast
	self:Sound("Beware")
	self:WarningSign(icon.shackles, dur, true, L.msg_shacklesCastAlert)
	self:Bar(L.bar_shacklesCast, dur, icon.shackles, true, "Red")
end

function module:ShacklesDebuff(player)
	if not self.db.profile.shacklesdebuff then
		return
	end
	-- 0.5 leeway added to encourage people not to move too early
	if player == UnitName("player") then
		self:WarningSign(icon.shackles, timer.shacklesDebuff + 0.5, true, L.msg_shacklesDebuffYou)
		self:Sound("Alarm")
	end
	self:Bar(L.bar_shacklesDebuff, timer.shacklesDebuff + 0.5, icon.shackles)
end

function module:ShackleShatter(player)
	if not self.db.profile.shackleshatter then
		return
	end
	player = player == UnitName("player") and "You" or player
	self:Message(player .. L.msg_shackleShatter, "Important", false, nil, false)
end

function module:ShardsCD()
	if not self.db.profile.shardscd then
		return
	end
	self:RemoveBar(L.bar_shardsCD)
	self:Message(L.msg_shardsCast, "Important", false, nil, false)
	self:DelayedBar(timer.shardsCD_bar_delay, L.bar_shardsCD, timer.shardsCD-timer.shardsCD_bar_delay, icon.shardsCD, true, "Orange")
end

function module:ShardsChannel(castTime)
	if not self.db.profile.shardschannel then
		return
	end
	local dur = castTime or timer.shardsChannel
	self:Sound("Alarm")
	self:Bar(L.bar_shardsChannel, dur, icon.shardsChannel, true, "Red")
end

--------------------------------------------------------------------------------
--  Tests
--------------------------------------------------------------------------------
function module:Test()
	BigWigs:EnableModule("Mephistroth")

	-- simulate engage
	self:Engage()

	-- 1) simulate the cast starting (START event)
	-- self:UNIT_CASTEVENT("player", "player", "START", 51916, 2)
	-- or CHANNEL:
	-- self:MephistrothCastEvent(nil, "player", "CHANNEL", 51916, 2)

	-- after cast finishes, simulate the debuff landing
	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest1", function()
		self:Event("You are afflicted by Shackles of the Legion")
	end, 2.1)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest2", function()
		self:Event("Ehawne is afflicted by Shackles of the Legion.")
	end, 2.1 + 7)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest3", function()
		self:Event("Ehawne is afflicted by Shackles of the Legion (1).")
	end, 2.1 + 15)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest4", function()
		self:Event("Milkpress is afflicted by Shackles of the Legion (1).")
	end, 2.1 + 23)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest5", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "START", 51916, 4000)
	end, 2.1 + 28) -- test this!

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CAST", 51917, 2000)
	end, 2.1 + 35)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CAST", 51917, 2000)
	end, 2.1 + 35)

	self:ScheduleEvent(self:ToString() .. "ShardsCDTest1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "START", 51942, 6000)
	end, 2.1 + 40)

	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CHANNEL", 51947, 25000)
	end, 2.1 + 42)

	-- simulate hellfire shards ending their channel, naturally or by dying
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 47)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_2", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 48)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_3", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 48)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_4", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 49)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_5", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 49)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 51)

	self:ScheduleEvent(self:ToString() .. "DoomTest1", function()
		self:Event(UnitName("player").." is afflicted by Doom of Outland (1).")
	end, 2.1 + 54)
	self:ScheduleEvent(self:ToString() .. "DoomTest2", function()
		self:Event("Doom of Outland fades from you.")
	end, 2.1 + 57)

	self:ScheduleEvent(self:ToString() .. "DoomTest3", function()
		self:Event("You are afflicted by Doom of Outland (1).")
	end, 2.1 + 60)
	self:ScheduleEvent(self:ToString() .. "DoomTest4", function()
		self:Event("Doom of Outland fades from "..UnitName("player")..".")
	end, 2.1 + 63)

	-- after the normal debuff duration, simulate fade
	-- self:ScheduleEvent(self:ToString() .. "ShacklesFadeTest", function()
	--   self:DebuffFade("Shackles of the Legion fades from " .. UnitName("player"))
	-- end, 2.1 + timer.shacklesDebuff + 0.1)

	BigWigs:Print("Mephistroth Shackles self‑test running...")
end
-- /run BigWigs:GetModule("Mephistroth"):Test()
