
local module, L = BigWigs:ModuleDeclaration("Ouro", "Ahn'Qiraj")

module.revision = 30058
module.enabletrigger = module.translatedName
module.toggleoptions = {"popcorn", "sounds", "bigicon", "sweep", "sandblast", -1, "emerge", "submerge", -1, "berserk", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ouro",

	OUROCHAMBERLOCALIZEDLOLHAX = "Ouro's Chamber",

	sweep_cmd = "sweep",
	sweep_name = "Sweep Alert",
	sweep_desc = "Warn for Sweeps",
	
	popcorn_cmd = "popcorn",
	popcorn_name = "Popcorn Alert",
	popcorn_desc = "Warns when you take damage from Popcorn",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon Alerts",
	bigicon_desc = "BigIcon Alert for Sweep, Submerge, Emerge, Popcorn",
	
	sounds_cmd = "sounds",
	sounds_name = "Sound Alerts",
	sounds_desc = "Sound Alert for Sweep, Submerge, Emerge, Popcorn",
	
	sandblast_cmd = "sandblast",
	sandblast_name = "Sandblast Alert",
	sandblast_desc = "Warn for Sandblasts",

	emerge_cmd = "emerge",
	emerge_name = "Emerge Alert",
	emerge_desc = "Warn for Emerge",

	submerge_cmd = "submerge",
	submerge_name = "Submerge Alert",
	submerge_desc = "Warn for Submerge",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warn for when Ouro goes berserk",

	sweeptrigger = "Ouro begins to cast Sweep",
	sweepannounce = "Sweep!",
	sweepwarn = "5 seconds until Sweep!",
	sweepbartext = "Sweep",

	sandblasttrigger = "Ouro begins to perform Sand Blast",
	sandblastannounce = "Incoming Sand Blast!",
	sandblastwarn = "5 seconds until Sand Blast!",
	sandblastbartext = "Possible Sand Blast",

	engage_message = "Ouro engaged! Possible Submerge in 90sec!",
	possible_submerge_bar = "Possible submerge",

	--emergetrigger = "Dirt Mound casts Summon Ouro Scarabs.",
	emergetrigger = "Ground Rupture",

	emergeannounce = "Ouro has emerged!",
	emergewarn = "15 sec to possible submerge!",
	emergebartext = "Ouro submerge",

	--submergetrigger = "Ouro casts Summon Ouro Mounds.",
	submergetrigger = "submerge",
	submergeannounce = "Ouro has submerged!",
	submergewarn = "5 seconds until Ouro Emerges!",
	submergebartext = "Ouro Emerge",

	berserktrigger = "Ouro gains Berserk.",
	berserkannounce = "Berserk - Berserk!",
	berserksoonwarn = "Berserk Soon - Get Ready!",

	popcorn_trigger = "Dirt Mound's Quake hits you for",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Ouro",

	--sweep_cmd = "sweep",
	sweep_name = "Alerta de Barrido",
	sweep_desc = "Avisa para Barrido",

	--sandblast_cmd = "sandblast",
	sandblast_name = "Alerta de Explosión de arena",
	sandblast_desc = "Avisa para Explosión de arena",

	--emerge_cmd = "emerge",
	emerge_name = "Alerta de Emersión",
	emerge_desc = "Alerta para Emersión",

	--submerge_cmd = "submerge",
	submerge_name = "Alerta de Sumersión",
	submerge_desc = "Avisa para Sumersión",

	--berserk_cmd = "berserk",
	berserk_name = "Rabia",
	berserk_desc = "Avisa para Rabia",

	sweeptrigger = "Ouro comienza a lanzar Barrido",
	sweepannounce = "¡Barrido!",
	sweepwarn = "¡5 segundos hasta Barrido!",
	sweepbartext = "Barrido",

	sandblasttrigger = "Ouro comienza a hacer Explosión de arena",
	sandblastannounce = "¡Explosión de arena entrante!",
	sandblastwarn = "¡5 segundos hasta Explosión de arena!",
	sandblastbartext = "Explosión de arena Posible",

	engage_message = "¡Entrando en combate con Ouro! Sumersión Posible en 90 segundos!",
	possible_submerge_bar = "Sumersión Posible",

	--emergetrigger = "Dirt Mound casts Summon Ouro Scarabs.",
	emergetrigger = "Ruptura terrenal",

	emergeannounce = "¡Ouro se ha emergido!",
	emergewarn = "¡15 segundos hasta Sumersión posible!",
	emergebartext = "Ouro Sumersión",

	--submergetrigger = "Ouro casts Summon Ouro Mounds.",
	submergetrigger = "sumerge",
	submergeannounce = "¡Ouro se ha sumergido!",
	submergewarn = "¡5 hasta que Ouro Emerge!",
	submergebartext = "Ouro Emerge",

	berserktrigger = "Ouro gana Rabia.",
	berserkannounce = "¡Rabia!",
	berserksoonwarn = "¡Rabia pronto - Prepárate!",


} end )

L:RegisterTranslations("deDE", function() return {
	sweep_name = "Feger",
	sweep_desc = "Warnung, wenn Ouro Feger wirkt.",

	sandblast_name = "Sandsto\195\159",
	sandblast_desc = "Warnung, wenn Ouro Sandsto\195\159 wirkt.",

	emerge_name = "Auftauchen",
	emerge_desc = "Warnung, wenn Ouro auftaucht.",

	submerge_name = "Untertauchen",
	submerge_desc = "Warnung, wenn Ouro untertaucht.",

	berserk_name = "Berserk",
	berserk_desc = "Warnung, wenn Ouro Berserkerwut bekommt.",

	sweeptrigger = "Ouro beginnt Feger zu wirken.", -- ?
	sweepannounce = "Feger!",
	sweepwarn = "5 Sekunden bis Feger!",
	sweepbartext = "Feger",

	sandblasttrigger = "Ouro beginnt Sandstoß auszuführen.", -- ?
	sandblastannounce = "Sandsto\195\159 in K\195\188rze!",
	sandblastwarn = "5 Sekunden bis Sandsto\195\159!",
	sandblastbartext = "Möglicher Sandsto\195\159",

	engage_message = "Ouro angegriffen! Mögliches Untertauchen in 90sek!",
	possible_submerge_bar = "Mögliches Untertauchen",

	--emergetrigger = "Dirt Mound casts Summon Ouro Scarabs.",
	emergetrigger = "Erdhaufen stirbt.", -- ?
	emergeannounce = "Ouro ist aufgetaucht!",
	emergewarn = "15 sek bis mögliches Untertauchen!",
	emergebartext = "Untertauchen",

	submergetrigger = "Ouro casts Summon Ouro Mounds.", -- ?
	submergeannounce = "Ouro ist aufgetaucht!",
	submergewarn = "5 Sekunden bis Ouro auftaucht!",
	submergebartext = "Auftauchen",

	berserktrigger = "Ouro bekommt 'Berserker'.",
	berserkannounce = "Berserk - Berserk!",
	berserksoonwarn = "Berserkerwut in K\195\188rze - Bereit machen!",
} end )

local timer = {
	nextSubmerge = 89,
	
	sweep = 1.5,
	earliestFirstSweep = 30,
	latestFirstSweep = 40,
	sweepInterval = 15,
	
	earliestFirstSandblast = 30,
	latestFirstSandblast = 45,
	
	earliestSandblastInterval = 12,
	latestSandblastInterval = 17,
	sandblast = 2,
	
	nextEmerge = 27,
}
local icon = {
	sweep = "Spell_Nature_Thorns",
	sandblast = "Spell_Nature_Cyclone",
	submerge = "Spell_Nature_Earthquake",
	popcorn = "Spell_Nature_Earthquake",
	collapse = "Ability_Marksmanship",
	enrage = "ability_druid_challangingroar",
	ouroTarget = "spell_shadow_charm",
}
local syncName = {
	sweep = "OuroSweep"..module.revision,
	sandblast = "OuroSandblast"..module.revision,
	emerge = "OuroEmerge"..module.revision,
	submerge = "OuroSubmerge"..module.revision,
	berserk = "OuroBerserk"..module.revision,
}

local berserkannounced = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")

	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

	self:ThrottleSync(10, syncName.sweep)
	self:ThrottleSync(10, syncName.sandblast)
	self:ThrottleSync(10, syncName.emerge)
	self:ThrottleSync(10, syncName.submerge)
	self:ThrottleSync(10, syncName.berserk)

	self:ScheduleRepeatingEvent("bwouroengagecheck", self.EngageCheck, 0.5, self)
	
	ouroCurrentTarget = nil
end

function module:OnSetup()
	berserkannounced = nil
	self.started = nil
	self.phase = nil
end

function module:OnEngage()

	self.phase = "emerged"
	self:ScheduleEvent("bwourosubmergecheck", self.DoSubmergeCheck, 5, self)

	if self.db.profile.emerge then
		self:Message(L["engage_message"], "Attention")
		self:PossibleSubmerge()
	end
	if self.db.profile.sandblast then
		self:DelayedMessage(timer.earliestFirstSandblast - 5, L["sandblastwarn"], "Important", nil, nil, true)
		self:IntervalBar(L["sandblastbartext"], timer.earliestFirstSandblast, timer.latestFirstSandblast, icon.sandblast, true, "Red")
	end
	if self.db.profile.sweep then
		self:DelayedMessage(timer.earliestFirstSweep - 5, L["sweepwarn"], "Important", nil, nil, true)
		self:IntervalBar(L["sweepbartext"], timer.earliestFirstSweep, timer.latestFirstSweep, icon.sweep, true, "Blue")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.earliestFirstSweep - 5, icon.sweep, 0.7)
		end
	end
	
	ouroCurrentTarget = nil
	self:ScheduleRepeatingEvent("ouroTargetCheck", self.OuroTarget, 0.5, self)
end

function module:OnDisengage()
end

function module:OuroTarget()
	if UnitName("target") ~= nil and UnitName("targettarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("target") == "Ouro" then
			SetRaidTarget("targettarget",8)
		end
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local health = UnitHealth(msg)
		if health > 20 and health <= 23 and not berserkannounced then
			if self.db.profile.berserk then
				self:Message(L["berserksoonwarn"], "Important", false, nil, false)
			end
			berserkannounced = true
		elseif health > 30 and berserkannounced then
			berserkannounced = nil
		end
	end
end

-- there is no emote ...
function module:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["berserktrigger"] then
		self:Sync(syncName.berserk)
	end
end

function module:Event(msg)
	if msg == L["berserktrigger"] then
		self:Sync(syncName.berserk)
	end
	if string.find(msg, L["emergetrigger"]) then
		self:Sync(syncName.emerge)
		self:DebugMessage("OuroEmerge")
	end
	if string.find(msg, L["sweeptrigger"]) then
		self:DebugMessage("sweep dmg")
		self:Sync(syncName.sweep)
	end
	if string.find(msg, L["sandblasttrigger"]) then
		self:Sync(syncName.sandblast)
	end
	if string.find(msg, L["popcorn_trigger"]) and self.db.profile.popcorn then
		self:Popcorn()
	end
end


function module:Popcorn()
	if self.db.profile.bigicon then
		self:WarningSign(icon.popcorn, 0.7)
	end
	if self.db.profile.sounds then
		self:Sound("Info")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sweep and self.db.profile.sweep then
		self:Sweep()
	elseif sync == syncName.sandblast and self.db.profile.sandblast then
		self:Sandblast()
	elseif sync == syncName.emerge then
		self:Emerge()
	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.berserk then
		self:Berserk()
	end
end

function module:Sweep()
	if self.db.profile.sweep then
		self:RemoveBar(L["sweepbartext"]) -- remove timer bar
		self:Bar(L["sweepannounce"], timer.sweep, icon.sweep, true, "Blue") -- show cast bar
		self:Message(L["sweepannounce"], "Important", true, "Alarm")
		self:DelayedMessage(timer.sweepInterval - 5, L["sweepwarn"], "Important", nil, nil, true)
		self:DelayedBar(timer.sweep, L["sweepbartext"], timer.sweepInterval-timer.sweep, icon.sweep, true, "Blue") -- delayed timer bar
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.sweepInterval - 5, icon.sweep, 0.7)
		end
	end
end

function module:Sandblast()
	if self.db.profile.sandblast then
		self:RemoveBar(L["sandblastbartext"]) -- remove timer bar
		self:Bar(L["sandblastannounce"], timer.sandblast, icon.sandblast, true, "Red") -- show cast bar
		self:Message(L["sandblastannounce"], "Important", true, "Alert")
		self:DelayedMessage(timer.earliestSandblastInterval - 5, L["sandblastwarn"], "Important", nil, nil, true)
		self:DelayedIntervalBar(timer.sandblast, L["sandblastbartext"], timer.earliestSandblastInterval-timer.sandblast, timer.latestSandblastInterval-timer.sandblast, icon.sandblast, true, "Red") -- delayed timer bar
	end
end

function module:DoSubmergeCheck()
	if self:IsOuroVisible() then
		self:ScheduleRepeatingEvent("bwourosubmergecheck", self.SubmergeCheck, 0.5, self)
	end
end

function module:Emerge()
	if self.phase ~= "berserk" then
		self.phase = "emerged"
		self:DebugMessage("emerged module")
		self:CancelScheduledEvent("bwourosubmergecheck")
		self:ScheduleEvent("bwourosubmergecheck", self.DoSubmergeCheck, 5, self)

		self:CancelScheduledEvent("bwsubmergewarn")
		self:RemoveBar(L["submergebartext"])

		if self.db.profile.emerge then
			self:Message(L["emergeannounce"], "Important", false, "Beware")
			self:PossibleSubmerge()
		end

		if self.db.profile.sweep then
			self:DelayedMessage(timer.sweepInterval - 5, L["sweepwarn"], "Important", nil, nil, true)
			self:Bar(L["sweepbartext"], timer.sweepInterval, icon.sweep, true, "Blue")
			if self.db.profile.bigicon then
				self:DelayedWarningSign(timer.sweepInterval - 5, icon.sweep, 0.7)
			end
		end

		if self.db.profile.sandblast then
			self:DelayedMessage(timer.earliestSandblastInterval - 5, L["sandblastwarn"], "Important", nil, nil, true)
			self:IntervalBar(L["sandblastbartext"], timer.earliestSandblastInterval, timer.latestSandblastInterval, icon.sandblast, true, "Red")
		end
	end
end

function module:Submerge()
	self:CancelDelayedWarningSign(icon.sweep)
	
	self:CancelDelayedMessage(L["sweepwarn"])
	self:CancelDelayedMessage(L["sandblastwarn"])
	self:CancelDelayedMessage(L["emergewarn"])

	self:RemoveBar(L["sweepbartext"])
	self:RemoveBar(L["sandblastbartext"])
	self:RemoveBar(L["emergebartext"])
	self:RemoveBar(L["possible_submerge_bar"])

	self.phase = "submerged"

	if self.db.profile.submerge then
		self:Message(L["submergeannounce"], "Important")
		self:ScheduleEvent("bwsubmergewarn", "BigWigs_Message", timer.nextEmerge - 5, L["submergewarn"], "Important" )
		self:Bar(L["submergebartext"], timer.nextEmerge, icon.submerge, true, "White")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.nextEmerge-10, icon.collapse, 0.7)
		end
	end
end

function module:Berserk()
	self.phase = "berserk"

	self:CancelDelayedMessage(L["emergewarn"])
	self:RemoveBar(L["emergebartext"])
	self:RemoveBar(L["possible_submerge_bar"])
	self:CancelDelayedWarningSign(icon.submerge)
	self:CancelDelayedSound("RunAway")
	
	if self.db.profile.berserk then
		self:Message(L["berserkannounce"], "Important", true, "Beware")
		if self.db.profile.bigicon then
			self:WarningSign(icon.enrage, 0.7)
		end
	end
end

function module:PossibleSubmerge()
	if self.db.profile.emerge then
		self:DelayedMessage(timer.nextSubmerge -15, L["emergewarn"], "Important", nil, nil, true)
		self:Bar(L["possible_submerge_bar"], timer.nextSubmerge, icon.submerge, true, "White")
		if self.db.profile.bigicon then
			self:DelayedWarningSign(timer.nextSubmerge-8, icon.submerge, 0.7)
		end
		if self.db.profile.sounds then
			self:DelayedSound(timer.nextSubmerge-8, "RunAway")
		end
	end
end

function module:SubmergeCheck()
	if self.phase == "emerged" then
		if not UnitIsDeadOrGhost("player") and not self:IsOuroVisible() then
			self:DebugMessage("OuroSubmerge")
			self:Sync(syncName.submerge)
		end
	end
end

function module:EngageCheck()
	if not self.engaged then
		if self:IsOuroVisible() then
			module:CancelScheduledEvent("bwouroengagecheck")

			module:SendEngageSync()
		end
	else
		module:CancelScheduledEvent("bwouroengagecheck")
	end
end

function module:IsOuroVisible()
	if UnitName("playertarget") == self.translatedName then
		return true
	else
		for i = 1, GetNumRaidMembers(), 1 do
			if UnitName("Raid"..i.."target") == self.translatedName then
				return true
			end
		end
	end

	return false
end
