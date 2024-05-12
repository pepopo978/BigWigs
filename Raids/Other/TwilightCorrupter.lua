
local module, L = BigWigs:ModuleDeclaration("Twilight Corrupter", "Duskwood")

module.revision = 30087
module.enabletrigger = module.translatedName
module.toggleoptions = {"creatureofnightmare", "soulcorruption", "swellofsouls", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Duskwood"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "TwilightCorrupter",

	creatureofnightmare_cmd = "creatureofnightmare",
	creatureofnightmare_name = "Mind Control Alert",
	creatureofnightmare_desc = "Warn for Mind Control",

	soulcorruption_cmd = "soulcorruption",
	soulcorruption_name = "Soul Corruption Alert",
	soulcorruption_desc = "Warns for Soul Corruption",
	
	swellofsouls_cmd = "swellofsouls",
	swellofsouls_name = "AP Increase per death Alert",
	swellofsouls_desc = "Warns about the current AP Increase per death",
	
	
		--MC, 1 person, 30sec duration, then 8sec CD
	trigger_creatureOfNightmare = "(.+) is afflicted by Creature of Nightmare.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_creatureOfNightmareYou = "You are afflicted by Creature of Nightmare.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_creatureOfNightmareFade = "Creature of Nightmare fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY //CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_creatureOfNightmareAfflic = " MC",
	bar_creatureOfNightmareCd = "MC CD",
	
		--AoE, 40yd, 15sec DoT + knockback, cd is min20 max30sec
	trigger_soulCorruption = "afflicted by Soul Corruption.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_soulCorruptionCd = "Soul Corruption CD",
	bar_soulCorruptionSoon = "Soul Corruption Soon...",
	
	bar_swellOfSouls = " AP Buff",
	
	subStringDead = "(.+) dies.",
} end )

local timer = {
	creatureOfNightmareAfflic = 30,
	creatureOfNightmareCd = 8,
	soulCorruptionCd = 20,
	soulCorruptionSoon = 10,
	swellOfSouls = 600,
}
local icon = {
	creatureOfNightmare = "spell_shadow_shadowworddominate",
	soulCorruption = "spell_shadow_fumble",
	swellOfSouls = "spell_nature_strength",
}
local color = {
	creatureOfNightmareAfflic = "Red",
	creatureOfNightmareCd = "White",
	soulCorruptionCd = "Blue",
	soulCorruptionSoon = "Cyan",
	swellOfSouls = "Black",
}
local syncName = {
	creatureOfNightmare = "TwilightCorrupterCreatureOfNightmare"..module.revision,
	creatureOfNightmareFade = "TwilightCorrupterCreatureOfNightmareFade"..module.revision,
	soulCorruption = "TwilightCorrupterSoulCorruption"..module.revision,
	swellOfSouls = "TwilightCorrupterSwellOfSouls"..module.revision,
}

local deadPlayers = 0
local swellOfSoulsAmount = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_creatureOfNightmareYou, trigger_soulCorruption
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_creatureOfNightmare, trigger_soulCorruption
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_creatureOfNightmare, trigger_soulCorruption
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")--trigger_creatureOfNightmare
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_creatureOfNightmareFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_creatureOfNightmareFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_creatureOfNightmareFade
	
	
	self:ThrottleSync(5, syncName.creatureOfNightmare)
	self:ThrottleSync(5, syncName.creatureOfNightmareFade)
	self:ThrottleSync(5, syncName.soulCorruption)
	self:ThrottleSync(0, syncName.swellOfSouls)
end

function module:OnSetup()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")--swellOfSouls counter
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")--swellOfSouls counter
end

function module:OnEngage()
	deadPlayers = 0
	swellOfSoulsAmount = 0
	
	if self.db.profile.soulcorruption then
		self:Bar(L["bar_soulCorruptionCd"], timer.soulCorruptionCd, icon.soulCorruption, true, color.soulCorruptionCd)
		self:DelayedBar(timer.soulCorruptionCd, L["bar_soulCorruptionSoon"], timer.soulCorruptionSoon, icon.soulCorruption, true, color.soulCorruptionSoon)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	
	if string.find(msg, L["subStringDead"]) then
		--this is for removing MC bar if someone dies
		local _,_, deadPlayer, _ = string.find(msg, L["subStringDead"])
		self:Sync(syncName.creatureOfNightmareFade .. " " .. deadPlayer)
		
		--this is for counting deads for AP buff
		if GetNumRaidMembers() > 0 then
			self:CountDeads()
		end
	end
end

function module:CHAT_MSG_COMBAT_FRIENDLY_DEATH(msg)
	if string.find(msg, L["subStringDead"]) then
		--this is for removing MC bar if someone dies
		local _,_, deadPlayer, _ = string.find(msg, L["subStringDead"])
		self:Sync(syncName.creatureOfNightmareFade .. " " .. deadPlayer)
		
		--this is for counting deads for AP buff
		if GetNumRaidMembers() > 0 then
			self:CountDeads()
		end
	end
end

function module:CountDeads()
	local newDeadCount = 0
	
	for i=1, GetNumRaidMembers() do
		if UnitIsDeadOrGhost("raid"..i) then
			newDeadCount = newDeadCount + 1
		end
	end
	
	if newDeadCount > deadPlayers then
		self:Sync(syncName.swellOfSouls .. " " .. newDeadCount)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_creatureOfNightmare"]) then
		local _,_, targetMc, _ = string.find(msg, L["trigger_creatureOfNightmare"])
		self:Sync(syncName.creatureOfNightmare .. " " .. targetMc)
		
	elseif string.find(msg, L["trigger_creatureOfNightmareYou"]) then
		self:Sync(syncName.creatureOfNightmare .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_creatureOfNightmareFade"]) then
		local _,_, targetMcFade, _ = string.find(msg, L["trigger_creatureOfNightmareFade"])
		if targetMcFade == "you" then targetMcFade = UnitName("Player") end
		self:Sync(syncName.creatureOfNightmareFade .. " " .. targetMcFade)
		
		
	elseif string.find(msg, L["trigger_soulCorruption"]) then
		self:Sync(syncName.soulCorruption)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.creatureOfNightmare and rest and self.db.profile.creatureofnightmare then
		self:CreatureOfNightmare(rest)
	elseif sync == syncName.creatureOfNightmareFade and rest and self.db.profile.creatureofnightmare then
		self:CreatureOfNightmareFade(rest)
	elseif sync == syncName.soulCorruption and self.db.profile.soulcorruption then
		self:SoulCorruption()
	elseif sync == syncName.swellOfSouls and rest and self.db.profile.swellofsouls then
		self:SwellOfSouls(rest)
	end
end


function module:CreatureOfNightmare(rest)
	self:RemoveBar(L["bar_creatureOfNightmareAfflic"])
	self:RemoveBar(L["bar_creatureOfNightmareCd"])
	
	self:Bar(rest.." "..L["bar_creatureOfNightmareAfflic"].." >Click Me!<", timer.creatureOfNightmareAfflic, icon.creatureOfNightmare, true, color.creatureOfNightmareAfflic)
	self:SetCandyBarOnClick("BigWigsBar "..rest.." "..L["bar_creatureOfNightmareAfflic"].." >Click Me!<", function(name, button, extra) TargetByName(extra, true) end, rest)
	
	self:DelayedBar(timer.creatureOfNightmareAfflic, L["bar_creatureOfNightmareCd"], timer.creatureOfNightmareCd, icon.creatureOfNightmare, true, color.creatureOfNightmareCd)
	
	if rest == UnitName("Player") then
		SendChatMessage(UnitName("player").." will eat you alive!","SAY")
	end
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 4)
			end
		end
	end
end

function module:CreatureOfNightmareFade(rest)
	self:RemoveBar(rest.." "..L["bar_creatureOfNightmareAfflic"].." >Click Me!<")
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 0)
			end
		end
	end
end

function module:SoulCorruption()
	self:CancelDelayedBar(L["bar_soulCorruptionSoon"])
	self:RemoveBar(L["bar_soulCorruptionCd"])
	self:RemoveBar(L["bar_soulCorruptionSoon"])
	
	self:Bar(L["bar_soulCorruptionCd"], timer.soulCorruptionCd, icon.soulCorruption, true, color.soulCorruptionCd)
	self:DelayedBar(timer.soulCorruptionCd, L["bar_soulCorruptionSoon"], timer.soulCorruptionSoon, icon.soulCorruption, true, color.soulCorruptionSoon)
	
	self:WarningSign(icon.soulCorruption, 0.7)
	self:Sound("Info")
end

function module:SwellOfSouls(rest)
	if tonumber(rest) > deadPlayers then
		self:RemoveBar(swellOfSoulsAmount..L["bar_swellOfSouls"])
		
		deadPlayers = tonumber(rest)
		swellOfSoulsAmount = deadPlayers * 75
	
		self:Bar(swellOfSoulsAmount..L["bar_swellOfSouls"], timer.swellOfSouls, icon.swellOfSouls, true, color.swellOfSouls)
	end
end
