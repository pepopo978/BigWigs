
local module, L = BigWigs:ModuleDeclaration("Karrsh the Sentinel", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"roar", "seed", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Karrsh",

	roar_cmd = "roar",
	roar_name = "Furious Roar Alert",
	roar_desc = "Timer for Karrsh's Furious Roar while Spear of Timbermaw is active",

	seed_cmd = "seed",
	seed_name = "Seed of Corruption Alert",
	seed_desc = "Warn when someone is afflicted by Seed of Corruption and mark them",

	trigger_spearGain = "Karrsh the Sentinel gains Spear of Timbermaw",
	trigger_spearFade = "Spear of Timbermaw fades from Karrsh the Sentinel",
	trigger_roarCast = "Karrsh the Sentinel casts Furious Roar",

	trigger_seedYou = "You are afflicted by Seed of Corruption",
	trigger_seedOther = "(.+) is afflicted by Seed of Corruption",
	trigger_seedFadeYou = "Seed of Corruption fades from you",
	trigger_seedFadeOther = "Seed of Corruption fades from (.+)%.",

	bar_roar = "Furious Roar",
	msg_roarSoon = "Threat drop incoming!",

	msg_seedYou = "SEED ON YOU - GET AWAY FROM OTHERS!",
} end )

local timer = {
	roar = 12,
}

local icon = {
	roar = "Ability_Druid_DemoralizingRoar",
	seed = "ability_warlock_shadowflame",
}

local color = {
	roar = "Red",
	seed = "Purple",
}

local syncName = {
	spearGain = "KarrshSpearGain"..module.revision,
	spearFade = "KarrshSpearFade"..module.revision,
	roar = "KarrshRoar"..module.revision,
	seedGain = "KarrshSeedGain"..module.revision,
	seedFade = "KarrshSeedFade"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")

	self:ThrottleSync(5, syncName.spearGain)
	self:ThrottleSync(5, syncName.spearFade)
	self:ThrottleSync(5, syncName.roar)
	-- per-target payloads; dedupe is handled by self.seedTargets so any
	-- throttle here would drop syncs for different players sharing the key
	self:ThrottleSync(0, syncName.seedGain)
	self:ThrottleSync(0, syncName.seedFade)
end

function module:OnSetup()
	self.seedTargets = {}
end
function module:OnEngage()
	self.seedTargets = {}
end
function module:OnDisengage()
	self:RemoveBar(L["bar_roar"])
	-- Framework auto-restores initialPlayerMarks on disengage (Core.lua:484-488),
	-- so seeds left applied will revert to the raid's original marks automatically.
	self.seedTargets = {}
end

function module:Event(msg)
	if string.find(msg, L["trigger_spearGain"]) then
		self:Sync(syncName.spearGain)
		return
	elseif string.find(msg, L["trigger_spearFade"]) then
		self:Sync(syncName.spearFade)
		return
	elseif string.find(msg, L["trigger_roarCast"]) then
		self:Sync(syncName.roar)
		return
	end

	-- Seed of Corruption gains
	if string.find(msg, L["trigger_seedYou"]) then
		self:Sync(syncName.seedGain.." "..UnitName("player"))
		return
	end
	local _, _, target = string.find(msg, L["trigger_seedOther"])
	if target then
		self:Sync(syncName.seedGain.." "..target)
		return
	end

	-- Seed of Corruption fades
	if string.find(msg, L["trigger_seedFadeYou"]) then
		self:Sync(syncName.seedFade.." "..UnitName("player"))
		return
	end
	local _, _, fadeTarget = string.find(msg, L["trigger_seedFadeOther"])
	if fadeTarget then
		self:Sync(syncName.seedFade.." "..fadeTarget)
		return
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.spearGain and self.db.profile.roar then
		self:StartRoarBar()
	elseif sync == syncName.roar and self.db.profile.roar then
		self:StartRoarBar()
	elseif sync == syncName.spearFade then
		self:RemoveBar(L["bar_roar"])
	elseif sync == syncName.seedGain and rest and self.db.profile.seed then
		self:SeedGain(rest)
	elseif sync == syncName.seedFade and rest and self.db.profile.seed then
		self:SeedFade(rest)
	end
end

function module:StartRoarBar()
	self:RemoveBar(L["bar_roar"])
	self:CancelDelayedMessage(L["msg_roarSoon"])
	-- pass otherc=nil so BigWigsColors drives the time-based gradient
	self:Bar(L["bar_roar"], timer.roar, icon.roar)
	-- fire the warning only in the final 3 seconds
	self:DelayedMessage(timer.roar - 4, L["msg_roarSoon"], "Important", false, "Alert")
end

function module:SeedGain(target)
	if self.seedTargets[target] then return end
	self.seedTargets[target] = true

	if target == UnitName("player") then
		self:Message(L["msg_seedYou"], "Personal", true, "Alarm")
		self:WarningSign(icon.seed, 3, true)
	end

	local mark = self:GetAvailableRaidMark()
	if mark then
		self:SetRaidTargetForPlayer(target, mark)
	end
end

function module:SeedFade(target)
	if not self.seedTargets[target] then return end
	self.seedTargets[target] = nil
	self:RestorePreviousRaidTargetForPlayer(target)
end

-- Spoofs real combat-log strings through Event() so the full parse -> sync
-- -> handler chain is exercised. Requires the player to be in a raid for
-- Sync's local echo to reach BigWigs_RecvSync.
-- Usage: /run local m=BigWigs:GetModule("Karrsh the Sentinel"); BigWigs:SetupModule("Karrsh the Sentinel"); m:Test();
function module:Test()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Karrsh test started", "Positive")

	local spearGainMsg = "Karrsh the Sentinel gains Spear of Timbermaw (1)."
	local roarMsg      = "Karrsh the Sentinel casts Furious Roar(33039) on Karrsh the Sentinel."
	local spearFadeMsg = "Spear of Timbermaw fades from Karrsh the Sentinel."

	self:ScheduleEvent("KarrshTestSpearGain", self.Event, 2,  self, spearGainMsg)
	self:ScheduleEvent("KarrshTestRoar1",     self.Event, 14, self, roarMsg)
	self:ScheduleEvent("KarrshTestRoar2",     self.Event, 26, self, roarMsg)
	self:ScheduleEvent("KarrshTestRoar3",     self.Event, 38, self, roarMsg)

	-- Spoof spear fade 6s into the 4th bar so we can verify the active bar
	-- gets cut off (not just expiring naturally).
	self:ScheduleEvent("KarrshTestSpearFade", self.Event, 44, self, spearFadeMsg)
	self:ScheduleEvent("KarrshTestDone", function()
		module:Message("Karrsh test complete", "Positive")
	end, 46)
	return true
end

-- Simulates Seed of Corruption on multiple targets to exercise the rotating
-- mark allocator. Picks up to 3 random raid members (falls back to the player
-- if solo), fires gains staggered 2s apart, then fades them one by one.
-- Usage: /run local m=BigWigs:GetModule("Karrsh the Sentinel"); BigWigs:SetupModule("Karrsh the Sentinel"); m:TestSeed();
function module:TestSeed()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()

	local pool = {}
	local n = GetNumRaidMembers()
	if n > 0 then
		for i = 1, n do
			local name = UnitName("raid"..i)
			if name then table.insert(pool, name) end
		end
	else
		table.insert(pool, UnitName("player"))
	end

	-- Shuffle-pick up to 3
	local targets = {}
	for _ = 1, 3 do
		if table.getn(pool) == 0 then break end
		local idx = math.random(1, table.getn(pool))
		table.insert(targets, pool[idx])
		table.remove(pool, idx)
	end

	self:Message("Seed test targets: "..table.concat(targets, ", "), "Positive")

	for i, target in ipairs(targets) do
		local gainMsg = target.." is afflicted by Seed of Corruption (1)."
		local fadeMsg = "Seed of Corruption fades from "..target.."."
		self:ScheduleEvent("KarrshTestSeedGain"..i, self.Event, 1 + (i - 1) * 2, self, gainMsg)
		self:ScheduleEvent("KarrshTestSeedFade"..i, self.Event, 10 + (i - 1) * 2, self, fadeMsg)
	end

	self:ScheduleEvent("KarrshTestSeedEnd", function()
		module:Message("Seed test complete", "Positive")
	end, 10 + table.getn(targets) * 2 + 1)
	return true
end
