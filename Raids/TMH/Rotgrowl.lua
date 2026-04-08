
local module, L = BigWigs:ModuleDeclaration("Rotgrowl", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"flamingbolt", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Rotgrowl",

	flamingbolt_cmd = "flamingbolt",
	flamingbolt_name = "Flaming Bolt Alert",
	flamingbolt_desc = "Warns when Rotgrowl aims a flaming bolt at a player (Fire-Soaked Arrow)",

	trigger_flamingBolt = "aims a flaming bolt at (.+)!",
	trigger_boltLand = "Fire%-Soaked Arrow hits",

	msg_boltYou = "FLAMING BOLT ON YOU - STACK IN MELEE!",
} end )

local icon = {
	flamingBolt = "Spell_Fire_Fireball02",
}

local syncName = {
	flamingBolt = "RotgrowlFlamingBolt"..module.revision,
	boltLand    = "RotgrowlFlamingBoltLand"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "LandEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "LandEvent")
	self:ThrottleSync(3, syncName.flamingBolt)
	self:ThrottleSync(1, syncName.boltLand) -- per-target dedup via markedTarget
end

function module:OnSetup()
	self.markedTarget = nil
end
function module:OnEngage() end
function module:OnDisengage()
	-- Framework auto-restores initialPlayerMarks on disengage (Core.lua:484-488)
	self.markedTarget = nil
end

function module:Emote(msg)
	local _, _, target = string.find(msg, L["trigger_flamingBolt"])
	if target then
		self:Sync(syncName.flamingBolt.." "..target)
	end
end

function module:LandEvent(msg)
	if self.markedTarget and string.find(msg, L["trigger_boltLand"]) then
		-- broadcast so the raid leader (possibly not the seer of this msg)
		-- is the one that actually calls SetRaidTarget to restore
		self:Sync(syncName.boltLand.." "..self.markedTarget)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.flamingBolt and rest and self.db.profile.flamingbolt then
		self:FlamingBolt(rest)
	elseif sync == syncName.boltLand and rest then
		if self.markedTarget == rest then
			self:RestorePreviousRaidTargetForPlayer(rest)
			self.markedTarget = nil
		end
	end
end

function module:FlamingBolt(target)
	if target == UnitName("player") then
		self:Message(L["msg_boltYou"], "Personal", true, "Alarm")
		self:WarningSign(icon.flamingBolt, 3, true)
	end

	if self.markedTarget and self.markedTarget ~= target then
		self:RestorePreviousRaidTargetForPlayer(self.markedTarget)
	end
	self.markedTarget = target
	self:SetRaidTargetForPlayer(target, 8) -- Skull
end

-- Spoofs real combat-log strings through Emote() and LandEvent() so the full
-- parse -> sync -> handler chain is exercised. Requires the player to be in a
-- raid for Sync's local echo to reach BigWigs_RecvSync.
-- Usage: /run local m=BigWigs:GetModule("Rotgrowl"); BigWigs:SetupModule("Rotgrowl"); m:Test();
function module:Test()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Rotgrowl test started", "Positive")

	local player = UnitName("player")

	-- pick a second target from the raid (any raid member other than player)
	local other
	for i = 1, GetNumRaidMembers() do
		local name = UnitName("raid"..i)
		if name and name ~= player then
			other = name
			break
		end
	end
	if not other then other = player end -- solo fallback: both bolts on player

	-- first bolt: on you
	self:ScheduleEvent("RotgrowlTestBoltYou", self.Emote, 2, self,
		"Rotgrowl aims a flaming bolt at "..player.."!")
	self:ScheduleEvent("RotgrowlTestLandYou", self.LandEvent, 8, self,
		"Rotgrowl 's Fire-Soaked Arrow hits "..player.." for 857 Fire damage.")

	-- second bolt: on another raid member
	self:ScheduleEvent("RotgrowlTestBoltOther", self.Emote, 12, self,
		"Rotgrowl aims a flaming bolt at "..other.."!")
	self:ScheduleEvent("RotgrowlTestLandOther", self.LandEvent, 18, self,
		"Rotgrowl 's Fire-Soaked Arrow hits "..other.." for 857 Fire damage.")

	self:ScheduleEvent("RotgrowlTestEnd", self.OnDisengage, 20, self)
	return true
end
