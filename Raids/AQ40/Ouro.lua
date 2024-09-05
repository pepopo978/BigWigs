
local module, L = BigWigs:ModuleDeclaration("Ouro", "Ahn'Qiraj")

module.revision = 30084
module.enabletrigger = module.translatedName
module.toggleoptions = {"sweep", "sandblast", "popcorn", "emerge", "berserk", -1, "targeticon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ouro",

	sweep_cmd = "sweep",
	sweep_name = "Sweep Alert",
	sweep_desc = "Warn for Sweeps",

	sandblast_cmd = "sandblast",
	sandblast_name = "Sand Blast Alert",
	sandblast_desc = "Warn for Sand Blast",

	popcorn_cmd = "popcorn",
	popcorn_name = "Popcorn Alert",
	popcorn_desc = "Warns when you take damage from Popcorn",

	emerge_cmd = "emerge",
	emerge_name = "Emerge / Submerge Alert",
	emerge_desc = "Warn for Emerge / Submerge",

	berserk_cmd = "berserk",
	berserk_name = "Berserk Alert",
	berserk_desc = "Warn for when Ouro goes Berserk",

	targeticon_cmd = "targeticon",
	targeticon_name = "Skull Icon on Ouro's Target",
	targeticon_desc = "Put a Skull Raid Icon on Ouro's Target",


	trigger_engage = "Ouro begins to cast Birth.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF

	trigger_sweep = "Ouro begins to cast Sweep.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_sweepCd = "Sweep CD",
	bar_sweepCast = "Sweep!",
	msg_sweep = "Casting Sweep!",

	trigger_sandBlast = "Ouro begins to perform Sand Blast.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_sandBlastCd = "Sand Blast CD",
	bar_sandBlastCast = "Sand Blast!",
	msg_sandBlast = "Casting Sand Blast!",

	trigger_emerge = "Ground Rupture", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_submergePossible = "Possible Submerge",
	msg_emerge = "Ouro has Emerged!",

	--there is no trigger_submerge
	bar_submergeDuration = "Ouro Emerge",
	msg_submerge = "Ouro has Submerged!",
	msg_collapse = "Ouro Emerges in 10 seconds - Collapse towards the middle!",

	trigger_berserk = "Ouro gains Berserk.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_berserk = "Ouro is Berserk - No Submerges",
	msg_berserkSoon = "Berserk Soon - Get Ready!",

	bar_berserkPopcorn = "New Popcorn Spawns", --10sec after enrage, should be 1 per 10sec afterwards

	trigger_popcornHitsYou = "Dirt Mound's Quake hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
} end )

local timer = {
	firstSweep = {20.5,25},
	sweepCd = 20.5,
	sweepCast = 1.5,

	firstSandBlast = {20,25},
	sandBlastCd = {20,25},
	sandBlastCast = 2,

	berserkPopcorn = 10,

	nextSubmerge = 89,
	nextEmerge = 27,
}
local icon = {
	sweep = "Spell_Nature_Thorns",
	sandBlast = "Spell_Nature_Cyclone",
	popcorn = "Spell_Nature_Earthquake",

	submerge = "inv_misc_shovel_01",
	collapse = "Ability_Marksmanship",

	enrage = "spell_shadow_unholyfrenzy",
}
local color = {
	sweep = "Blue",
	sandBlast = "Red",
	popcorn = "Cyan",
	submerge = "White"
}
local syncName = {
	sweep = "OuroSweep"..module.revision,
	sandBlast = "OuroSandblast"..module.revision,
	emerge = "OuroEmerge"..module.revision,
	submerge = "OuroSubmerge"..module.revision,
	berserk = "OuroBerserk"..module.revision,
}

local berserkAnnounced = nil
local ouroCurrentTarget = nil
local phase = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_engage

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_sweep, trigger_sandBlast, trigger_emerge
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_berserk
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_popcornHitsYou

	self:RegisterEvent("UNIT_HEALTH") --warn for enrage soon


	self:ThrottleSync(10, syncName.sweep)
	self:ThrottleSync(10, syncName.sandBlast)
	self:ThrottleSync(10, syncName.emerge)
	self:ThrottleSync(10, syncName.submerge)
	self:ThrottleSync(10, syncName.berserk)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	berserkAnnounced = nil
	ouroCurrentTarget = nil
	phase = "emerged"

	if self.db.profile.sweep then
		self:IntervalBar(L["bar_sweepCd"], timer.firstSweep[1], timer.firstSweep[2], icon.sweep, true, color.sweep)
		self:DelayedWarningSign(timer.firstSweep[1] - 3, icon.sweep, 0.7)
	end

	if self.db.profile.sandblast then
		self:IntervalBar(L["bar_sandBlastCd"], timer.firstSandBlast[1], timer.firstSandBlast[2], icon.sandBlast, true, color.sandBlast)
	end

	if self.db.profile.emerge then
		self:PossibleSubmerge()
	end

	self:ScheduleEvent("OuroSubmergeCheck", self.StartSubmergeCheck, 5, self)

	if self.db.profile.targeticon then
		self:ScheduleRepeatingEvent("OuroTargetCheck", self.OuroTarget, 0.5, self)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("OuroSubmergeCheck")
	self:CancelScheduledEvent("OuroTargetCheck")
	self:CancelScheduledEvent("OuroBerserkPopcorn")
end

function module:IsOuroVisible()
	if UnitName("PlayerTarget") == self.translatedName then
		return true
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."Target") == self.translatedName then
				return true
			end
		end
	end

	return false
end

function module:StartSubmergeCheck()
	if self:IsOuroVisible() then
		self:ScheduleRepeatingEvent("OuroSubmergeCheck", self.SubmergeCheck, 0.5, self)
	end
end

function module:SubmergeCheck()
	if phase == "emerged" and not UnitIsDeadOrGhost("Player") and not self:IsOuroVisible() then
		self:Sync(syncName.submerge)
	end
end

function module:OuroTarget()
	if UnitName("Target") ~= nil and UnitName("TargetTarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("Target") == "Ouro" then
			SetRaidTarget("TargetTarget",8)
		end
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 20 and healthPct <= 23 and not berserkAnnounced then
			if self.db.profile.berserk then
				self:Message(L["msg_berserkSoon"], "Important", false, nil, false)
			end
			berserkAnnounced = true
		elseif healthPct > 30 and berserkAnnounced then
			berserkAnnounced = nil
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()

	elseif msg == L["trigger_sweep"] then
		self:Sync(syncName.sweep)

	elseif msg == L["trigger_sandBlast"] then
		self:Sync(syncName.sandBlast)

	elseif string.find(msg, L["trigger_popcornHitsYou"]) and self.db.profile.popcorn then
		self:Popcorn()

	elseif string.find(msg, L["trigger_emerge"]) then
		self:Sync(syncName.emerge)

	elseif msg == L["trigger_berserk"] then
		self:Sync(syncName.berserk)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sweep and self.db.profile.sweep then
		self:Sweep()
	elseif sync == syncName.sandBlast and self.db.profile.sandblast then
		self:SandBlast()
	elseif sync == syncName.emerge and phase ~= "berserk" then
		self:Emerge()
	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.berserk then
		self:Berserk()
	end
end


function module:Sweep()
	self:RemoveBar(L["bar_sweepCd"])

	self:Bar(L["bar_sweepCast"], timer.sweepCast, icon.sweep, true, color.sweep)
	self:Message(L["msg_sweep"], "Important", false, nil, false)
	self:Sound("Alarm")

	self:DelayedBar(timer.sweepCast, L["bar_sweepCd"], timer.sweepCd - timer.sweepCast, icon.sweep, true, color.sweep)
	self:DelayedWarningSign(timer.sweepCast + timer.sweepCd - timer.sweepCast - 3, icon.sweep, 0.7)
end

function module:SandBlast()
	self:RemoveBar(L["bar_sandBlastCd"])

	self:Bar(L["bar_sandBlastCast"], timer.sandBlastCast, icon.sandBlast, true, color.sandBlast)
	self:Message(L["msg_sandBlast"], "Important", false, nil, false)
	self:Sound("Alert")

	self:DelayedIntervalBar(timer.sandBlastCast, L["bar_sandBlastCd"], timer.sandBlastCd[1] - timer.sandBlastCast, timer.sandBlastCd[2] - timer.sandBlastCast, icon.sandBlast, true, color.sandBlast)
end

function module:Popcorn()
	self:WarningSign(icon.popcorn, 0.7)
	self:Sound("Info")
end

function module:Emerge()
	phase = "emerged"

	self:CancelScheduledEvent("OuroSubmergeCheck")
	self:ScheduleEvent("OuroSubmergeCheck", self.StartSubmergeCheck, 5, self)

	self:CancelDelayedMessage("msg_collapse")
	self:RemoveBar(L["bar_submergeDuration"])

	if self.db.profile.sweep then
		self:Bar(L["bar_sweepCd"], timer.sweepCd, icon.sweep, true, color.sweep)
		self:DelayedWarningSign(timer.sweepCd - 3, icon.sweep, 0.7)
	end

	if self.db.profile.sandblast then
		self:IntervalBar(L["bar_sandBlastCd"], timer.sandBlastCd[1], timer.sandBlastCd[2], icon.sandBlast, true, color.sandBlast)
	end

	if self.db.profile.emerge then
		self:Message(L["msg_emerge"], "Important", false, nil, false)
		self:Sound("Beware")
		self:PossibleSubmerge()
	end
end

function module:PossibleSubmerge()
	self:Bar(L["bar_submergePossible"], timer.nextSubmerge, icon.submerge, true, color.submerge)
	self:DelayedWarningSign(timer.nextSubmerge - 3, icon.submerge, 0.7)
	self:DelayedSound(timer.nextSubmerge - 3, "RunAway")
end

function module:Submerge()
	phase = "submerged"

	self:CancelDelayedWarningSign(icon.sweep)

	self:RemoveBar(L["bar_sweepCd"])
	self:RemoveBar(L["bar_sandBlastCd"])
	self:RemoveBar(L["bar_submergePossible"])

	if self.db.profile.emerge then
		self:Bar(L["bar_submergeDuration"], timer.nextEmerge, icon.submerge, true, color.submerge)
		self:Message(L["msg_submerge"], "Important", false, nil, false)
		self:Sound("RunAway")

		self:DelayedWarningSign(timer.nextEmerge - 10, icon.collapse, 0.7)
		self:DelayedMessage(timer.nextEmerge - 10, L["msg_collapse"], "Urgent", false, nil, false)
	end
end

function module:Berserk()
	phase = "berserk"

	self:CancelScheduledEvent("OuroSubmergeCheck")

	self:RemoveBar(L["bar_submergePossible"])
	self:CancelDelayedWarningSign(icon.submerge)
	self:CancelDelayedSound("RunAway")

	if self.db.profile.berserk then
		self:Message(L["msg_berserk"], "Urgent", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.enrage, 0.7)
	end
	if self.db.profile.popcorn then
		self:BerserkPopcorn()
		self:ScheduleRepeatingEvent("OuroBerserkPopcorn", self.BerserkPopcorn, timer.berserkPopcorn, self)
	end
end

function module:BerserkPopcorn()
	self:Bar(L["bar_berserkPopcorn"], timer.berserkPopcorn, icon.popcorn, true, color.popcorn)
end
