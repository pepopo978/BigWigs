
local module, L = BigWigs:ModuleDeclaration("Azuregos", "Azshara")

module.revision = 30071
module.enabletrigger = module.translatedName
module.toggleoptions = {"chill", "arcanevacuum", "reflection", "selfreflect", "manastorm", "frostbreath", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Azshara"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Azuregos",
	
	chill_cmd = "chill",
	chill_name = "Chill Alert",
	chill_desc = "Warn for Chill",
	
	arcanevacuum_cmd = "arcanevacuum",
	arcanevacuum_name = "Arcane Vacuum Alert",
	arcanevacuum_desc = "Warn for Arcane Vacuum (Teleport)",
	
	reflection_cmd = "reflection",
	reflection_name = "Reflection Alert",
	reflection_desc = "Warn for Reflection",
	
	selfreflect_cmd = "selfreflect",
	selfreflect_name = "Reflection on You Alert",
	selfreflect_desc = "Warn for Spells reflected back to you",
	
	manastorm_cmd = "manastorm",
	manastorm_name = "Mana Storm Alert",
	manastorm_desc = "Warn for Mana Storm",
	
	frostbreath_cmd = "frostbreath",
	frostbreath_name = "Frost Breath Alert",
	frostbreath_desc = "Warn for Frost Breath",
	
	
	--increasing the time between their attacks by 300%, and movement speed by 40%
	trigger_chillYou = "You are afflicted by Chill.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_chillOther = "(.+) is afflicted by Chill.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_chillFade = "Chill fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_chillCd = "Chill CD",
	bar_chillAfflic = " Chilled",
	msg_chill = "Chill - Dispel the Tank first!",
	
	--teleport close players (data reports 30yd, players report 10yd, probably is 30yd from dead center)
	  --and causes aggro wipe for the teleported players only
	trigger_arcaneVacuum = "Come, little ones. Face me!", --CHAT_MSG_MONSTER_YELL
	bar_arcaneVacuumCd = "Arcane Vacuum CD",
	bar_arcaneVacuumReady = "Arcane Vacuum Ready...",
	msg_arcaneVacuum = "Arcane Vacuum - Teleport + Aggro Wipe on close players only!",
	
	--can be dispelled by felhunter, reflects spells
	trigger_reflection = "Azuregos gains Reflection.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_reflectionFade = "Reflection fades from Azuregos.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_reflectionCd = "Reflection CD",
	bar_reflection = "Reflection!",
	msg_reflectionUp = "Reflection - Stop Casting!",
	msg_reflectionFade = "Reflection Faded",
	
	trigger_reflectYou = "Your (.+) is reflected back by Azuregos.", --CHAT_MSG_SPELL_SELF_DAMAGE
	msg_reflectYou = "Spell Reflect - Stop Killing Yourself!",
	
	--Blizzard-like AoE but burns mana
	trigger_manaStormYou = "You are afflicted by Manastorm.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_manaStormYouFade = "Manastorm fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_manaStorm = "Move away from Mana Storm!",
	
	--Frontal Cone, Dmg + slowMove + ManaBurn
	trigger_frostBreathYou = "Azuregos's Frost Breath hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	trigger_frostBreathCast = "Azuregos begins to perform Frost Breath.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_frostBreathCd = "Frost Breath CD",
	bar_frostBreathCast = "Casting Frost Breath!",
	msg_frostBreath = "Frost Breath = Mana Burn... Don't stand in front!",

	["You have slain %s!"] = true,
} end )

local timer = {
	chillFirstCd = 14,
	chillCd = 24,
	chillDur = 30,
	
	arcaneVacuumFirstCd = 20,
	arcaneVacuumCd = 30,
	arcaneVacuumReady = 20,
	
	reflectionFirstCd = 23,
	reflectionCd = {13,22.5}, --{23,32.5} minus duration
	reflectionDur = 10,
	
	manaStormDur = 10,
	
	frostBreathFirstCd = 11.5,
	frostBreathCd = {14,21},
	frostBreathCast = 2,
}
local icon = {
	chill = "spell_frost_glacier",
	arcaneVacuum = "spell_arcane_portalironforge",
	reflection = "spell_shadow_teleport",
	manaStorm = "spell_frost_icestorm",
	frostBreath = "spell_frost_frostnova",
}
local color = {
	chillCd = "White",
	chillDur = "Orange",
	
	arcaneVacuumCd = "Green",
	arcaneVacuumReady = "Red",
	
	reflectionCd = "Black",
	reflectionDur = "Magenta",
	
	frostBreathCd = "Cyan",
	frostBreathCast = "Blue",
}
local syncName = {
	chill = "AzuregosChill"..module.revision,
	chillFade = "AzuregosChillFade"..module.revision,
	arcaneVacuum = "AzuregosArcaneVacuum"..module.revision,
	reflection = "AzuregosReflection"..module.revision,
	reflectionFade = "AzuregosReflectionFade"..module.revision,
	frostBreath = "AzuregosFrostBreath"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_arcaneVacuum

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_chillYou, trigger_manaStormYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_chillOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_chillOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_chillFade, trigger_manaStormYouFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_chillFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_chillFade, trigger_reflectionFade

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_reflection

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_reflectYou

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_frostBreathYou
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_frostBreathCast
	
	
	self:ThrottleSync(0.1, syncName.chill)
	self:ThrottleSync(0.1, syncName.chillFade)
	self:ThrottleSync(5, syncName.arcaneVacuum)
	self:ThrottleSync(5, syncName.reflection)
	self:ThrottleSync(5, syncName.reflectionFade)
	self:ThrottleSync(5, syncName.frostBreath)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.chill then
		self:Bar(L["bar_chillCd"], timer.chillFirstCd, icon.chill, true, color.chillCd)
	end
	
	if self.db.profile.arcanevacuum then
		self:Bar(L["bar_arcaneVacuumCd"], timer.arcaneVacuumFirstCd, icon.arcaneVacuum, true, color.arcaneVacuumCd)
		self:DelayedBar(timer.arcaneVacuumFirstCd, L["bar_arcaneVacuumReady"], timer.arcaneVacuumReady, icon.arcaneVacuum, true, color.arcaneVacuumReady)
	end
	
	if self.db.profile.reflection then
		self:Bar(L["bar_reflectionCd"], timer.reflectionFirstCd, icon.reflection, true, color.reflectionCd)
	end
	
	if self.db.profile.frostbreath then
		self:Bar(L["bar_frostBreathCd"], timer.frostBreathFirstCd, icon.frostBreath, true, color.frostBreathCd)
	end
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("Target") and UnitAffectingCombat("Target") then
				local target = UnitName("Target")
				for _, mob in pairs(t) do
					if target == mob then
						return true
					end
				end
			end

			local num = GetNumRaidMembers()
			for i = 1, num do
				local raidUnit = string.format("raid%starget", i)
				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
					local target = UnitName(raidUnit)
					for _, mob in pairs(t) do
						if target == mob then
							return true
						end
					end
				end
			end
			return false
		end

		if not IsBossInCombat() then
			self:SendBossDeathSync()
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_arcaneVacuum"] then
		self:Sync(syncName.arcaneVacuum)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_reflectYou"]) and not string.find(msg, "Elemental Vulnerability") and not string.find(msg, "Fire Strike") and self.db.profile.selfreflect then
		self:SelfReflect()
	end
	
	
	if msg == L["trigger_chillYou"] then
		self:Sync(syncName.chill)
		
	elseif string.find(msg, L["trigger_chillOther"]) then
		local _,_, chillPlayer, _ = string.find(msg, L["trigger_chillOther"])
		self:Sync(syncName.chill .. " " .. chillPlayer)
	
	elseif string.find(msg, L["trigger_chillFade"]) then
		local _,_, chillFadePlayer, _ = string.find(msg, L["trigger_chillFade"])
		if chillFadePlayer == "you" then chillFadePlayer = UnitName("Player") end
		self:Sync(syncName.chillFade .. " " .. chillFadePlayer)
	

	elseif string.find(msg, L["trigger_reflection"]) then
		self:Sync(syncName.reflection)
	elseif string.find(msg, L["trigger_reflectionFade"]) then
		self:Sync(syncName.reflectionFade)
	
	elseif string.find(msg, L["trigger_manaStormYou"]) and self.db.profile.manastorm then
		self:ManaStorm()
	elseif string.find(msg, L["trigger_manaStormYouFade"]) and self.db.profile.manastorm then
		self:ManaStormFade()

	elseif string.find(msg, L["trigger_frostBreathYou"]) and self.db.profile.frostbreath then
		self:FrostBreathYou()
	elseif string.find(msg, L["trigger_frostBreathCast"]) and self.db.profile.frostbreath then
		self:Sync(syncName.frostBreath)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.chill and rest and self.db.profile.chill then
		self:Chill(rest)
	elseif sync == syncName.chillFade and rest and self.db.profile.chill then
		self:ChillFade(rest)
	
	elseif sync == syncName.arcaneVacuum and self.db.profile.arcanevacuum then
		self:ArcaneVacuum()
	
	elseif sync == syncName.reflection and self.db.profile.reflection then
		self:Reflection()
	elseif sync == syncName.reflectionFade and self.db.profile.reflection then
		self:ReflectionFade()
		
	elseif sync == syncName.frostBreath and self.db.profile.frostbreath then
		self:FrostBreath()
	end
end


function module:Chill(rest)
	self:Bar(L["bar_chillCd"], timer.chillCd, icon.chill, true, color.chillCd)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(L["msg_chill"], "Attention", false, nil, false)
		self:WarningSign(icon.chill, 1)
		self:Sound("Info")
	end
	
	for i=1,GetNumRaidMembers() do
		if UnitName("raid"..i) == rest then
			if UnitName("raid"..i.."Target") == "Azuregos" and UnitName("raid"..i.."TargetTarget") == rest then
				self:Bar(rest..L["bar_chillAfflic"], timer.chillDur, icon.chill, true, color.chillDur)
			end
		end
	end
end

function module:ChillFade(rest)
	self:RemoveBar(rest..L["bar_chillAfflic"])
end

function module:ArcaneVacuum()
	self:CancelDelayedBar(L["bar_arcaneVacuumReady"])
	self:RemoveBar(L["bar_arcaneVacuumReady"])
	
	self:Bar(L["bar_arcaneVacuumCd"], timer.arcaneVacuumCd, icon.arcaneVacuum, true, color.arcaneVacuumCd)
	self:Message(L["msg_arcaneVacuum"], "Urgent", false, nil, false)
	self:Sound("Beware")
	self:WarningSign(icon.arcaneVacuum, 0.7)
	
	self:DelayedBar(timer.arcaneVacuumCd, L["bar_arcaneVacuumReady"], timer.arcaneVacuumReady, icon.arcaneVacuum, true, color.arcaneVacuumReady)
end

function module:Reflection()
	self:RemoveBar(L["bar_reflectionCd"])
	
	self:Bar(L["bar_reflection"], timer.reflectionDur, icon.reflection, true, color.reflectionDur)
	
	if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Druid" or UnitClass("Player") == "Hunter" then
		self:Message(L["msg_reflectionUp"], "Attention", false, nil, false)
		self:Sound("Long")
		self:WarningSign(icon.reflection, 0.7)
	elseif UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" then
		self:Message(L["msg_reflectionUp"], "Attention", false, nil, false)
		self:Sound("Long")
		self:WarningSign(icon.reflection, timer.reflectionDur)
	end	
end

function module:ReflectionFade()
	self:RemoveBar(L["bar_reflection"])
	
	self:IntervalBar(L["bar_reflectionCd"], timer.reflectionCd[1], timer.reflectionCd[2], icon.reflection, true, color.reflectionCd)
	
	if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Druid" or UnitClass("Player") == "Hunter" then
		self:Message(L["msg_reflectionFade"], "Positive", false, nil, false)
		self:Sound("Alert")
	elseif UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" then
		self:Message(L["msg_reflectionFade"], "Positive", false, nil, false)
		self:RemoveWarningSign(icon.reflection)
		self:Sound("Alert")
	end
end

function module:SelfReflect()
	if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock") then
		self:WarningSign(icon.reflection, 0.7)
	end
	
	self:Message(L["msg_reflectYou"], "Urgent", false, nil, false)
	self:Sound("Info")
end

function module:ManaStorm()
	self:WarningSign(icon.manaStorm, timer.manaStormDur)
	self:Message(L["msg_manaStorm"], "Important", false, nil, false)
	self:Sound("Info")
end

function module:ManaStormFade()
	self:RemoveWarningSign(icon.manaStorm)
end

function module:FrostBreath()
	self:RemoveBar(L["bar_frostBreathCd"])
	
	self:Bar(L["bar_frostBreathCast"], timer.frostBreathCast, icon.frostBreath, true, color.frostBreathCast)
	
	self:DelayedIntervalBar(timer.frostBreathCast, L["bar_frostBreathCd"], timer.frostBreathCd[1], timer.frostBreathCd[2], icon.frostBreath, true, color.frostBreathCd)
end

function module:FrostBreathYou()
	if UnitName("Target") == "Azuregos" and UnitName("TargetTarget") == UnitName("Player") then
		return
	end
	
	self:Message(L["msg_frostBreath"], "Important", false, nil, false)
end
