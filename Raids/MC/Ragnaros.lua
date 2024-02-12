
local module, L = BigWigs:ModuleDeclaration("Ragnaros", "Molten Core")

module.revision = 30044
module.enabletrigger = module.translatedName
module.toggleoptions = {"start", "aoeknock", "submerge", "emerge", "adds", "bosskill"}
module.wipemobs = {"Son of Flame"}
module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ragnaros",

	start_cmd = "start",
	start_name = "Start",
	start_desc = "Starts a bar for estimating the beginning of the fight.",

	emerge_cmd = "emerge",
	emerge_name = "Emerge alert",
	emerge_desc = "Warn for Ragnaros Emerge",

	adds_cmd = "adds",
	adds_name = "Son of Flame dies",
	adds_desc = "Warn when a son dies",

	submerge_cmd = "submerge",
	submerge_name = "Submerge alert",
	submerge_desc = "Warn for Ragnaros Submerge",

	aoeknock_cmd = "aoeknock",
	aoeknock_name = "Knockback alert",
	aoeknock_desc = "Warn for Wrath of Ragnaros knockback",
	
	
	trigger_knockback = "^TASTE",
	bar_knockback = "AoE knockback",
	msg_knockback = "Knockback!",
	msg_knockbackSoon = "Knockback soon!",
	
	trigger_submerge = "^COME FORTH,",
	trigger_submerge2 = "^YOU CANNOT DEFEAT THE LIVING FLAME,",
	bar_emerge = "Ragnaros emerge",
	msg_submerge = "Ragnaros submerged. Incoming Sons of Flame!",
	
	trigger_engage = "^NOW FOR YOU",
	trigger_engageSoon1 = "Imprudent whelps!",
	trigger_engageSoon2 = "TOO SOON! YOU HAVE AWAKENED ME TOO SOON",
	trigger_engageSoon3 = "YOU ALLOWED THESE INSECTS",
	
	trigger_hammer = "^BY FIRE BE PURGED!",

	msg_emergeSoon = "10sec until Ragnaros emerges!",
	msg_emerge = "Ragnaros emerged, 3 minutes until submerge!",
	bar_submerge = "Ragnaros submerge",
	msg_submerge10 = "10 sec to submerge!",

	sonOfFlame = "Son of Flame",
	msg_sonsDead = "%d/8 Sons of Flame dead!",

	["Combat"] = true,
} end)

L:RegisterTranslations("esES", function() return {
	trigger_knockback = "^PROBAR LAS LLAMAS DE SULFURON", -- /script PlaySoundFile("Sound\\Creature\\Ragnaros\\RagnarosSpecialAttack02.wav")
	trigger_submerge = "^VENID INSECTOS,", -- /script PlaySoundFile("Sound\\Creature\\Ragnaros\\RagnarosSpecialAttack03.wav")
	trigger_submerge2 = "^YOU CANNOT DEFEAT THE LIVING FLAME,",
	trigger_engage = "^NOW FOR YOU",
	trigger_engageSoon1 = "Imprudent whelps!",
	trigger_engageSoon2 = "TOO SOON! YOU HAVE AWAKENED ME TOO SOON",
	trigger_engageSoon3 = "YOU ALLOWED THESE INSECTS",
	trigger_hammer = "^EL FUEGO TE PURIFIQUE!", -- /script PlaySoundFile("Sound\\Creature\\Ragnaros\\RagnarosSpecialAttack01.wav")

	msg_knockback = "¡Rechazar!",
	msg_knockbackSoon = "¡Rechazar pronto!",
	msg_submerge = "¡Ragnaros se sumerge. Hijos de la llama entrantes!",
	msg_emergeSoon = "¡10 segundos hasta que se yerga Ragnaros!",
	msg_emerge = "¡Ragnaros se yerge, 3 minutos hasta que se sumerja!",
	msg_submerge10 = "¡10 segundos hasta que se sumerja Ragnaros!",

	bar_knockback = "Cólera de Ragnaros",
	bar_emerge = "Ragnaros se yerge",
	bar_submerge = "Ragnaros se sumerja",

	sonOfFlame = "Hijos de la llama",
	msg_sonsDead = "¡%d/8 Hijos de la llama muertos!",

	cmd = "Ragnaros",

	--start_cmd = "start",
	start_name = "Empezar",
	start_desc = "Empieza una barra para estimar el comienzo de la pelea.",

	--emerge_cmd = "emerge",
	emerge_name = "Alerta de Emersión",
	emerge_desc = "Avisa para Emersión de Ragnaros",

	--adds_cmd = "adds",
	adds_name = "Hijo de la llama muerto",
	adds_desc = "Avisa cuando muera un hijo de la llama",

	--submerge_cmd = "submerge",
	submerge_name = "Alerta de Sumersión",
	submerge_desc = "Avisa cuando se sumerja Ragnaros",

	--aoeknock_cmd = "aoeknock",
	aoeknock_name = "Alerta de Cólera de Ragnaros",
	aoeknock_desc = "Avisa para el rechazo de Cólera de Ragnaros",

	["Combat"] = "Combate",
} end)

L:RegisterTranslations("deDE", function() return {
	trigger_knockback = "DIE FLAMMEN VON SULFURON",
	trigger_submerge = "^Kommt herbei, meine Diener!",
	trigger_engage = "^NUN ZU EUCH,",
	trigger_engageSoon = "ZU FRÜH!",
	trigger_hammer = "^DAS FEUER WIRD EUCH!",

	msg_knockback = "Rücksto\195\159!",
	msg_knockbackSoon = "3 Sekunden bis Rücksto\195\159!",
	msg_submerge = "Ragnaros ist untergetaucht! Söhne der Flamme kommen!",
	msg_emergeSoon = "10 Sekunden bis Ragnaros auftaucht",
	msg_emerge = "Ragnaros ist aufgetaucht, Untertauchen in 3 Minuten!",
	msg_submerge10 = "Auftauchen in 10 Sekunden!",

	bar_knockback = "AoE Rücksto\195\159",
	bar_emerge = "Ragnaros taucht auf",
	bar_submerge = "Ragnaros taucht unter",

	sonOfFlame = "Sohn der Flamme",
	msg_sonsDead = "%d/8 Sohn der Flamme tot!",

	--cmd = "Ragnaros",

	start_cmd = "start",
	start_name = "Start",
	start_desc = "Startet eine Balken f\195\188r die Sch\195\164tzung der Beginn des Kampfes.",

	--emerge_cmd = "emerge",
	emerge_name = "Alarm für Abtauchen",
	emerge_desc = "Warnen, wenn Ragnaros auftaucht",

	--adds_cmd = "adds",
	adds_name = "Zähler für tote Adds",
	adds_desc = "Verkündet Sohn der Flamme Tod",

	--submerge_cmd = "submerge",
	submerge_name = "Alarm für Untertauchen",
	submerge_desc = "Warnen, wenn Ragnaros untertaucht",

	--aoeknock_cmd = "aoeknock",
	aoeknock_name = "Alarm für Rücksto\195\159",
	aoeknock_desc = "Warnen, wenn Zorn des Ragnaros zurückstö\195\159t",

	["Combat"] = "Kampf beginnt",
} end)

local timer = {
	emerge_soon1 = 78,
	emerge_soon2 = 47.5,
	emerge_soon3 = 29,
	hammer_of_ragnaros = 11,
	emerge = 90,
	submerge = 180,
	earliestKnockback = 25,
	latestKnockback = 33,
}
local icon = {
	emerge_soon = "Inv_Hammer_Unique_Sulfuras",
	hammer_of_ragnaros = "Spell_Fire_Incinerate",
	emerge = "Spell_Fire_Volcano",
	submerge = "Spell_Fire_SelfDestruct",
	knockback = "Spell_Fire_SoulBurn",
	knockbackWarn = "Ability_Rogue_Sprint",
}
local color = {
	knockback = "Red",
	submerge = "White",
}
local syncName = {
	knockback = "RagnarosKnockback"..module.revision,
	sons = "RagnarosSonDead"..module.revision,
	submerge = "RagnarosSubmerge"..module.revision,
	emerge = "RagnarosEmerge"..module.revision,
}

local sonsdead = 0
local firstKnockback = true
local lastKnockback = nil
local phase = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:ThrottleSync(5, syncName.knockback)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self.started = nil
	
	self.barstarted = false
	
	sonsdead = 0
	firstKnockback = true
	lastKnockback = nil
end

function module:OnEngage()
	self:ScheduleRepeatingEvent("bwragnarosemergecheck", self.EmergeCheck, 1, self)
	self:EmergeCheck()
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if string.find(msg, L["sonOfFlame"]) then
		self:Sync(syncName.sons .. " " .. tostring(sonsdead + 1))
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["trigger_knockback"]) then
		self:Sync(syncName.knockback)
	elseif string.find(msg, L["trigger_submerge"]) or string.find(msg, L["trigger_submerge2"]) then
		self:Sync(syncName.submerge)
	elseif string.find(msg, L["trigger_engage"]) then
		self:SendEngageSync()
	elseif string.find(msg, L["trigger_engageSoon1"]) and self.db.profile.start then
		self:Bar(L["Combat"], timer.emerge_soon1, icon.emerge_soon, true, color.submerge)
		self.barstarted = true
	elseif string.find(msg, L["trigger_engageSoon2"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["Combat"], timer.emerge_soon2, icon.emerge_soon, true, color.submerge)
		self.barstarted = true
	elseif string.find(msg, L["trigger_engageSoon3"]) and self.db.profile.start and not self.barstarted then
		self:Bar(L["Combat"], timer.emerge_soon3, icon.emerge_soon, true, color.submerge)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sons and rest and rest ~= "" and self.db.profile.adds then
		self:SonsDead(rest)
	elseif sync == syncName.knockback then
		self:Knockback()
	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.emerge then
		self:Emerge()
	end
end


function module:SonsDead(rest)
	rest = tonumber(rest)
	if rest <= 8 and sonsdead < rest then
		sonsdead = rest
		self:Message(string.format(L["msg_sonsDead"], sonsdead), "Positive")
	end
end

function module:Knockback()
	if phase == "submerged" then
		self:Emerge()
	end
	
	if self.db.profile.aoeknock then
		if not firstKnockback then
			self:Message(L["msg_knockback"], "Important", false, nil, false)
		end
		firstKnockback = false
		self:RemoveWarningSign(icon.knockbackWarn, true)
		self:IntervalBar(L["bar_knockback"], timer.earliestKnockback, timer.latestKnockback, icon.knockback, true, color.knockback)
		
		self:DelayedMessage(timer.earliestKnockback - 3, L["msg_knockbackSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.earliestKnockback - 3, "Alarm")
		self:DelayedWarningSign(timer.earliestKnockback - 3, icon.knockbackWarn, 15)
	end
end

function module:Submerge()
	phase = "submerged"
	self:CancelScheduledEvent("bwragnarosaekbwarn")
	
	_, _, lastKnockback = self:BarStatus(L["bar_knockback"])
	self:RemoveBar(L["bar_knockback"])
	self:CancelDelayedMessage(L["msg_knockbackSoon"])
	self:CancelDelayedWarningSign(icon.knockbackWarn)
	self:RemoveWarningSign(icon.knockbackWarn, true)

	if self.db.profile.submerge then
		self:Message(L["msg_submerge"], "Important", false, nil, false)
	end
	if self.db.profile.emerge then
		self:Bar(L["bar_emerge"], timer.emerge, icon.emerge, true, color.submerge)
		self:DelayedMessage(timer.emerge - 10, L["msg_emergeSoon"], "Urgent", false, nil, false)
	end
	
	self:ScheduleRepeatingEvent("bwragnarosemergecheck", self.EmergeCheck, 1, self)
	self:DelayedSync(timer.emerge, syncName.emerge)
end

function module:Emerge()
	phase = "emerged"
	firstKnockback = true
	sonsdead = 0

	self:CancelDelayedSync(syncName.emerge)
	self:CancelScheduledEvent("bwragnarosemergecheck")
	self:CancelDelayedMessage(L["msg_emergeSoon"])
	self:RemoveBar(L["bar_emerge"])

	if self.db.profile.emerge then
		self:Message(L["msg_emerge"], "Attention", false, nil, false)
	end

	if lastKnockback then
		local knocktimer = timer.earliestKnockback-lastKnockback
		local latestKnocktimer = timer.latestKnockback-lastKnockback
		if knocktimer > 0 then
			self:IntervalBar(L["bar_knockback"], knocktimer, latestKnocktimer, icon.knockback, true, color.knockback)
		end
		if knocktimer > 3 then
			self:DelayedMessage(knocktimer - 3, L["msg_knockbackSoon"], "Urgent", false, nil, false)
			self:DelayedSound(knocktimer - 3, "Alarm")
			self:DelayedWarningSign(knocktimer - 3, icon.knockbackWarn, 15)
		else
			self:Message(L["msg_knockbackSoon"], "Urgent", false, nil, false)
			self:Sound("Alarm")
			self:WarningSign(icon.knockbackWarn, 15)
		end
		firstKnockback = false
	else
		self:Knockback()
	end

	if self.db.profile.submerge then
		self:Bar(L["bar_submerge"], timer.submerge, icon.submerge, true, color.submerge)
		
		self:DelayedMessage(timer.submerge - 10, L["msg_submerge10"], "Attention", false, nil, false)
	end
end


function module:EmergeCheck()
	if UnitExists("target") and UnitName("target") == module.translatedName and UnitExists("targettarget") and UnitName("targettarget") ~= "Majordomo Executus" then
		self:Sync(syncName.emerge)
		return
	end

	local num = GetNumRaidMembers()
	for i = 1, num do
		local raidUnit = string.format("raid%starget", i)
		if UnitExists(raidUnit) and UnitName(raidUnit) == module.translatedName and UnitExists(raidUnit .. "target") and UnitName(raidUnit .. "target") ~= "Majordomo Executus" then
			self:Sync(syncName.emerge)
			return
		end
	end
end
