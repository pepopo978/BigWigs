local module, L = BigWigs:ModuleDeclaration("Rupturan the Broken", "Karazhan")

module.revision = 30001
module.enabletrigger = module.translatedName
module.toggleoptions = { "livingstone", "dirtmound", "flamestrike", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
	"Outland",
	"???",
}

module.defaultDB = {
	livingstone = true,
	dirtmound   = true,
	flamestrike = true,
}

-------------------------------------------------------------------------------
--  Localization
-------------------------------------------------------------------------------
L:RegisterTranslations("enUS", function() return {
	-- Options
	cmd = "Rupturan",
	livingstone_cmd      = "livingstone",
	livingstone_name     = "Living Stone Stomp",
	livingstone_desc     = "Show time left until a Living Stone stomp after Crash Landing fades.",

	dirtmound_cmd        = "dirtmound",
	dirtmound_name       = "Dirt Mound Indicators",
	dirtmound_desc       = "Warn when Dirt Mound Quake hits you and when one is spawned.",

	flamestrike_cmd        = "flamestrike",
	flamestrike_name       = "Flamestrike Indicators",
	flamestrike_desc       = "Warn when Flamestrike (Ignite Rock) is casting.",

	-- Bars / Messages
	bar_ignite_rock      = "Flamestrike",
	bar_ignite_rock_soon = "Flamestrike soon",
	bar_ls_earthstomp    = "Living Stone STOMP",
	msg_dm_quake         = "Dirt Mound Quake!  MOVE AWAY!",
	msg_dm_target_near   = "Get away from diamond!",
	msg_dm_target_you    = "Dirt Mound chasing you!",

	-- Triggers
	trigger_start        = "All shall crumble",
	trigger_phase2       = "Let the cracks of this world destroy you",
	trigger_boss_dead    = "Perished... To dust",

	trigger_ls_fades     = "Crash Landing fades from Living Stone",
	trigger_dm_quake     = "Dirt Mound's Quake .?.its (.+) for",
	trigger_dm_spawn     = "Rupturan commands the earth to crush (.+)!",
	trigger_dm_die       = "Dirt Mound dies",
} end)

local timer = {
	earthstomp = 5,
	igniteRockCD = {20,53},
	igniteRock = 3,
}

local icon = {
	earthstomp = "Ability_ThunderClap",
	quake      = "Spell_Nature_Earthquake",
	igniteRock = "Spell_Fire_SelfDestruct",
}

local syncName = {
	earthstomp   = "RupturanEarthStomp"..module.revision,
	igniteRock   = "RupturanIgniteRock"..module.revision,
	dm_spawn     = "RupturanDirtMoundSpawn"..module.revision,
	phase2       = "RupturanPhaseTwo"..module.revision,
}

-- keep track of which player currently has popcorn
local mound_chasing = nil

-------------------------------------------------------------------------------
--  Initialization
-------------------------------------------------------------------------------

module:RegisterYellEngage(L.trigger_start)

function module:OnEnable()
	-- Living Stone stomp countdown
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	-- Quake damage landed on you
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")

	-- Dirt Mound spawn target announcement (emote)
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")

	-- phase2
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")

	if SUPERWOW_VERSION or SetAutoloot then
		self:RegisterEvent("UNIT_CASTEVENT")
	end

	self:ThrottleSync(2, syncName.earthstomp)
	self:ThrottleSync(2, syncName.dm_spawn)
	self:ThrottleSync(2, syncName.phase2)
end

-- function module:OnSetup()
-- end

function module:OnEngage()
	mound_chasing = nil
end

function module:OnDisengage()
	-- clean up bars
	self:RemoveBar(L.bar_ls_earthstomp)
	self:RestorePreviousRaidTargetForPlayer(mound_chasing)
end

-------------------------------------------------------------------------------
--  Event Handler
--------------------------------------------------------------------------------

function module:Event(msg)
	-- Living Stone fade → start stomp timer
	if self.db.profile.livingstone and string.find(msg, L.trigger_ls_fades) then
		self:Sync(syncName.earthstomp)
		return
	end
	if self.db.profile.dirtmound then
		-- Quake hit on you
		if string.find(msg, L.trigger_dm_quake) then
			self:DirtMoundQuake() -- personal damage, no syncing
			return
		end
		-- Dirt Mound spawn emote: capture player name
		local _,_,player = string.find(msg, L.trigger_dm_spawn)
		if player then
			self:Sync(syncName.dm_spawn .. " " .. player)
			return
		end
	end
	if string.find(msg, L.trigger_phase2) then
		self:Sync(syncName.phase2)
		return
	end
	if string.find(msg, L.trigger_boss_dead) then
		self:SendBossDeathSync()
	end
end

function module:UNIT_CASTEVENT(caster,target,action,spellId,castTime)
	if spellId == 51298 and action == "START" then
		self:Sync(syncName.igniteRock .. " " .. (castTime / 1000))
	end
end

--------------------------------------------------------------------------------
--  Sync handler
--------------------------------------------------------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.earthstomp then
		self:CrashLandingFades()

	elseif sync == syncName.dm_spawn and rest then
		self:DirtMoundSpawn(rest)

	elseif sync == syncName.phase2 then
		self:Phase2()

	elseif sync == syncName.igniteRock and rest then
		local castTime = tonumber(rest)
		self:IgniteRock(castTime)
	end
end

function module:CrashLandingFades()
	if not self.db.profile.livingstone then return end

	self:Sound("Alarm")
	self:Bar(L.bar_ls_earthstomp, timer.earthstomp, icon.earthstomp)
end

function module:DirtMoundQuake()
	if not self.db.profile.dirtmound then return end

	self:Message(L.msg_dm_quake, "Important", nil, "Alarm")
end

function module:DirtMoundSpawn(player)
	if not player then return end
	if not self.db.profile.dirtmound then return end

	self:RestorePreviousRaidTargetForPlayer(mound_chasing)
	self:SetRaidTargetForPlayer(player,3) -- diamond
	mound_chasing = player

	if player == UnitName("player") then
		-- you're the target: big warning
		self:WarningSign(icon.quake, 5, true, L.msg_dm_target_you)
		self:Sound("RunAway")
		SendChatMessage("Popcorn On Me !", "SAY")
	else
		-- someone else: warn if you’re nearby
		for i=1,GetNumRaidMembers() do
			local unit = "raid"..i
			if UnitName(unit) == player and CheckInteractDistance(unit, 2) then
				self:Message(L.msg_dm_target_near, "Important")
				self:Sound("Alarm")
				break
			end
		end
	end
end

function module:Phase2()
	-- clear popcorn mark
	self:RestorePreviousRaidTargetForPlayer(mound_chasing)
	mound_chasing = nil
end

function module:IgniteRock(castTime)
	if not self.db.profile.flamestrike then return end
	castTime = castTime or timer.igniteRock

	self:Sound("Alarm")
	self:WarningSign(icon.igniteRock, 3, true, L.bar_ignite_rock)
	self:Bar(L.bar_ignite_rock, castTime, icon.igniteRock)
end

-------------------------------------------------------------------------------
--  Testing
-------------------------------------------------------------------------------

function module:Test()
	local print = function (s) DEFAULT_CHAT_FRAME:AddMessage(s) end
	BigWigs:EnableModule(self:ToString())

	local player = UnitName("player")
	local tests = {
		-- after  1s, simulate the “Crash Landing fades from Living Stone” fade event
		{0,
		"Engage:",
		"CHAT_MSG_MONSTER_YELL",
		"All shall crumble... To dust."},
		{3,
		"Crash Land test:",
		"CHAT_MSG_SPELL_AURA_GONE_OTHER",
		"Crash Landing fades from Living Stone."},
		-- after  2s, simulate the quake damage event
		{8,
		"Quake damage test:",
		"CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
		"Dirt Mound's Quake hits you for 717 Nature damage."},
		-- after  3s, simulate the dirt mound spawn on *you*
		{13,
		"Emote player test:",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"Rupturan commands the earth to crush "..player.."!"},
		{16,
		"Emote raid1 test:",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"Rupturan commands the earth to crush "..UnitName("raid1").."!"},
		-- after  4s, simulate the same on “Bob”
		{19,
		"Emote raid2 test:",
		"CHAT_MSG_RAID_BOSS_EMOTE",
		"Rupturan commands the earth to crush "..UnitName("raid2").."!"},
		{22,
		"Phase 2 change:",
		"CHAT_MSG_MONSTER_YELL",
		"Let the cracks of this world destroy you.."},
		{25,
		"Ignite Rock:",
		"UNIT_CASTEVENT",
		{"player", "player", "START", 51298, 3000} },
		{35,
		"Boss kill:",
		"CHAT_MSG_COMBAT_HOSTILE_DEATH",
		"Rupturan the Broken dies."},
	}

	for i, t in ipairs(tests) do
		if type(t[2]) == "string" then
			local t1,t2,t3,t4 = t[1],t[2],t[3],t[4]
			self:ScheduleEvent("RupturanTest"..i, function()
				print(t2)
				if type(t4) == "table" then
					self:TriggerEvent(t3, unpack(t4))
				else
					self:TriggerEvent(t3, t4)
				end
			end, t1)
		else
			self:ScheduleEvent("RupturanTest"..i, t[2], t[1])
		end
	end

	self:Message("Rupturan test started", "Positive")
	return true
end
-- /run BigWigs:GetModule("Rupturan the Broken"):Test()
