
local module, L = BigWigs:ModuleDeclaration("Ormanos the Cracked", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"charge", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Ormanos",

	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warns when Ormanos prepares to charge a player (boulder throw)",

	trigger_charge = "Ormanos is preparing to charge (.+)!",
	trigger_chargeLand = "Rampaging Earth",

	msg_chargeYou = "CHARGE ON YOU - STACK WITH RANGED!",
} end )

local icon = {
	charge = "Ability_Warrior_Charge",
}

local syncName = {
	charge     = "OrmanosCharge"..module.revision,
	chargeLand = "OrmanosChargeLand"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Emote")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "LandEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "LandEvent")
	self:ThrottleSync(3, syncName.charge)
	self:ThrottleSync(1, syncName.chargeLand)
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
	local _, _, target = string.find(msg, L["trigger_charge"])
	if target then
		self:Sync(syncName.charge.." "..target)
	end
end

function module:LandEvent(msg)
	if self.markedTarget and string.find(msg, L["trigger_chargeLand"]) then
		-- broadcast so the raid leader (possibly not the seer of this msg)
		-- is the one that actually calls SetRaidTarget to restore
		self:Sync(syncName.chargeLand.." "..self.markedTarget)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.charge and rest and self.db.profile.charge then
		self:Charge(rest)
	elseif sync == syncName.chargeLand and rest then
		if self.markedTarget == rest then
			self:RestorePreviousRaidTargetForPlayer(rest)
			self.markedTarget = nil
		end
	end
end

function module:Charge(target)
	if target == UnitName("player") then
		self:Message(L["msg_chargeYou"], "Personal", true, "Alarm")
		self:WarningSign(icon.charge, 3, true)
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
-- Usage: /run local m=BigWigs:GetModule("Ormanos the Cracked"); BigWigs:SetupModule("Ormanos the Cracked"); m:Test();
function module:Test()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Ormanos test started", "Positive")

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
	if not other then other = player end -- solo fallback: both charges on player

	-- first charge: on you
	self:ScheduleEvent("OrmanosTestChargeYou", self.Emote, 2, self,
		"Ormanos is preparing to charge "..player.."!")
	self:ScheduleEvent("OrmanosTestLandYou", self.LandEvent, 6, self,
		"Ormanos the Cracked 's Rampaging Earth hits "..player.." for 2500 Nature damage.")

	-- second charge: on another raid member
	self:ScheduleEvent("OrmanosTestChargeOther", self.Emote, 10, self,
		"Ormanos is preparing to charge "..other.."!")
	self:ScheduleEvent("OrmanosTestLandOther", self.LandEvent, 14, self,
		"Ormanos the Cracked 's Rampaging Earth hits "..other.." for 2500 Nature damage.")

	self:ScheduleEvent("OrmanosTestEnd", self.OnDisengage, 16, self)
	return true
end
