
local module, L = BigWigs:ModuleDeclaration("Magmadar", "Molten Core")

module.revision = 30073
module.enabletrigger = module.translatedName
module.toggleoptions = {"panic", "frenzy", "conflagration", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Magmadar",

	panic_cmd = "panic",
	panic_name = "Fear Alert",
	panic_desc = "Warn when Magmadar casts Panic",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn when Magmadar goes into a Frenzy",
	
	conflagration_cmd = "conflagration",
	conflagration_name = "Conflagration Alert",
	conflagration_desc = "Warn for Conflagration",
	
	
	trigger_panic = "afflicted by Panic.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_panic2 = "Magmadar's Panic fails.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_panic3 = "Magmadar's Panic was resisted", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_panicCd = "Fear CD",
	bar_panicSoon = "Fear Soon...",
	msg_panic = "Fear - Dispel!",
	
	trigger_frenzy = "Magmadar gains Frenzy.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from Magmadar.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_frenzyCd = "Frenzy CD",
	bar_frenzyDur = "Frenzy!",
	msg_frenzy = "Frenzy - Tranq now!",
	
	trigger_conflagYou = "You are afflicted by Conflagration.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
} end)

local timer = {
	panicFirstCd = 10,
	panicCd = 30,
	panicSoon = 5,
	
	frenzyCd = {15,20},
	frenzyDur = 8,
}
local icon = {
	panic = "Spell_Shadow_DeathScream",
	berserkerRage = "spell_nature_ancestralguardian",
	tremor = "spell_nature_tremortotem",
	
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
	
	fireProtPot = "inv_potion_24",
}
local color = {
	panicCd = "Cyan",
	panicSoon = "Blue",
	
	frenzyCd = "White",
	frenzyDur = "Red",
}
local syncName = {
	panic = "MagmadarPanic"..module.revision,
	frenzy = "MagmadarFrenzyStart"..module.revision,
	frenzyFade = "MagmadarFrenzyStop"..module.revision,
}

local frenzyStartTime = 0
local frenzyEndTime = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_panic, trigger_conflagYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_panic
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_panic
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_panic2
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_panic2, trigger_panic3
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_panic2, trigger_panic3
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_frenzy
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_frenzyFade


	self:ThrottleSync(15, syncName.panic)
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(5, syncName.frenzyFade)
end

function module:OnSetup()
end

function module:OnEngage()
	frenzyStartTime = 0
	frenzyEndTime = 0
	
	if self.db.profile.panic then
		self:Bar(L["bar_panicCd"], timer.panicFirstCd, icon.panic, true, color.panicCd)
		
		if UnitClass("Player") == "Warrior" then
			self:WarningSign(icon.berserkerRage, 0.7)
		elseif UnitClass("Player") == "Shaman" then
			self:DelayedWarningSign(5, icon.tremor, 0.7)
		end
	end
	
	if self.db.profile.frenzy then
		self:IntervalBar(L["bar_frenzyCd"], timer.frenzyCd[1], timer.frenzyCd[2], icon.frenzy, true, color.frenzyCd)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_panic"]) or string.find(msg, L["trigger_panic2"]) or string.find(msg, L["trigger_panic3"]) then
		self:Sync(syncName.panic)
		
	elseif msg == L["trigger_frenzy"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyFade)
		
	elseif msg == L["trigger_conflagYou"] and self.db.profile.conflagration then
		self:Conflagration()
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.panic and self.db.profile.panic then
		self:Panic()
	
	elseif sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyFade and self.db.profile.frenzy then
		self:FrenzyFade()
	end
end


function module:Panic()
	self:RemoveBar(L["bar_panicCd"])
	self:CancelDelayedBar(L["bar_panicSoon"])
	self:RemoveBar(L["bar_panicSoon"])
	self:CancelDelayedWarningSign(icon.berserkerRage)
	self:RemoveWarningSign(icon.berserkerRage)
	self:CancelDelayedWarningSign(icon.tremor)
	self:RemoveWarningSign(icon.tremor)
	
	self:Bar(L["bar_panicCd"], timer.panicCd, icon.panic, true, color.panicCd)
	if UnitClass("Player") == "Priest" or  UnitClass("Player") == "Paladin" then
		self:Message(L["msg_panic"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.panic, 0.7)
	end
	
	self:DelayedBar(timer.panicCd, L["bar_panicSoon"], timer.panicSoon, icon.panic, true, color.panicSoon)
	
	if UnitClass("Player") == "Warrior" then
		self:DelayedWarningSign(timer.panicCd + timer.panicSoon - 10, icon.berserkerRage, 0.7)
	elseif UnitClass("Player") == "Shaman" then
		self:DelayedWarningSign(timer.panicCd, icon.tremor, 0.7)
	end
end

function module:Frenzy()
	self:RemoveBar(L["bar_frenzyCd"])
	
	if UnitClass("Player") == "Hunter" then
		self:Message(L["msg_frenzy"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.tranquil, 1)
	end
	
	self:Bar(L["bar_frenzyDur"], timer.frenzyDur, icon.frenzy, true, color.frenzyDur)
	frenzyStartTime = GetTime()
end

function module:FrenzyFade()
	self:RemoveBar(L["bar_frenzyDur"])
	self:RemoveWarningSign(icon.tranquil)
	
	frenzyEndTime = GetTime()
	
	self:IntervalBar(L["bar_frenzyCd"], timer.frenzyCd[1] - (frenzyEndTime - frenzyStartTime), timer.frenzyCd[2] - (frenzyEndTime - frenzyStartTime), icon.frenzy, true, color.frenzyCd)
end

function module:Conflagration()
	self:WarningSign(icon.fireProtPot, 1)
end
