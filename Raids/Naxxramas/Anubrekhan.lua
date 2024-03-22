
local module, L = BigWigs:ModuleDeclaration("Anub'Rekhan", "Naxxramas")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"locust", "impale", -1, "enrage", "web", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Anubrekhan",

	locust_cmd = "locust",
	locust_name = "Locust Swarm Alert",
	locust_desc = "Warn for Locust Swarm.",
	
	impale_cmd = "impale",
	impale_name = "Impale Alert",
	impale_desc = "Warns for Impale.",
	
	enrage_cmd = "enrage",
	enrage_name = "Crypt Guard Enrage Alert",
	enrage_desc = "Warn for Enrage.",
	
	web_cmd = "web",
	web_name = "Crypt Guard Web Alert",
	web_desc = "Warn for Web.",
	
	
	trigger_engage1 = "Just a little taste...",
	trigger_engage2 = "Yes, run! It makes the blood pump faster!",
	trigger_engage3 = "There is no way out.",
	
	trigger_locustSwarmCast = "Anub'Rekhan begins to cast Locust Swarm.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_locustSwarmCasting = "Casting Locust Swarm!",
	bar_locustSwarmCasting = "Casting Locust Swarm!",
	
	trigger_locustSwarmGain = "Anub'Rekhan gains Locust Swarm.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_locustSwarmIsUp = "Locust Swarm!",
	
	trigger_locustSwarmEnds = "Locust Swarm fades from Anub'Rekhan.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_locustSwarmCd = "Locust Swarm CD",
	bar_locustSwarmOffCd = "Locust Swarm Ready...",
	
	trigger_locustSwarmYou = "You are afflicted by Locust Swarm", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_locustYou = "Get  A W A Y  from the boss!",
	trigger_locustSwarmYouFade = "Locust Swarm fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	trigger_impale = "Anub'Rekhan's Impale hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_impale = "Impale CD",
	
	trigger_enrage = "Crypt Guard gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Crypt Guard Enrage - Stun + Traps!",
	
	trigger_web = "afflicted by Web.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_web2 = "Web fails.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_webCd = "Web CD",
	bar_webDur = "Webbed!",
} end )

local timer = {
	firstLocustSwarm = {80,120},--96
	readyFirstLocustSwarm = 40,
	locustSwarmInterval = {70,90},--90,110
	readySwarmInterval = 20,
	locustSwarmDuration = 20,
	locustSwarmCastTime = 3,
	
	locustAfflicted = 6,
	
	impale = {12,18},
	
	webCd = 12,
	webDur = 10,
}
local icon = {
	locust = "Spell_Nature_InsectSwarm",
	impale = "ability_backstab",
	enrage = "spell_shadow_unholyfrenzy",
	web = "ability_ensnare",
}
local color = {
	locustCd = "White",
	locustOffCd = "Cyan",
	locustCasting = "Green",
	
	impale = "Red",
	
	webCd = "Black",
	webDur = "Blue",
}
local syncName = {
	locustCast = "AnubLocustInc"..module.revision,
	locustGain = "AnubLocustSwarm"..module.revision,
	locustEnds = "AnubLocustEnds"..module.revision,
	impale = "AnubImpale"..module.revision,
	
	enrage = "AnubEnrage"..module.revision,
	web = "AnubWeb"..module.revision,
}

module:RegisterYellEngage(L["trigger_engage1"])
module:RegisterYellEngage(L["trigger_engage2"])
module:RegisterYellEngage(L["trigger_engage3"])

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_locustSwarmCast
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_locustSwarmGain, trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_locustSwarmEnds, trigger_locustSwarmYouFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_locustSwarmEnds
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_impale, trigger_web2
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_impale, trigger_web2
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_impale, trigger_web2
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_web, trigger_locustSwarmYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_web
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_web
	
	
	self:ThrottleSync(10, syncName.locustCast)
	self:ThrottleSync(10, syncName.locustGain)
	self:ThrottleSync(10, syncName.locustEnds)
	self:ThrottleSync(10, syncName.impale)
	self:ThrottleSync(2, syncName.enrage)
	self:ThrottleSync(8, syncName.web)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.locust then
		self:IntervalBar(L["bar_locustSwarmCd"], timer.firstLocustSwarm[1], timer.firstLocustSwarm[2], icon.locust, true, color.locustCd)
		self:DelayedBar(timer.firstLocustSwarm[1], L["bar_locustSwarmOffCd"], timer.readyFirstLocustSwarm, icon.locust, true, color.locustOffCd)
	end
	
	if self.db.profile.impale then
		self:Impale()
	end
	
	if self.db.profile.web then
		self:Bar(L["bar_webCd"], timer.webCd, icon.web, true, color.webCd)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_locustSwarmCast"] then
		self:Sync(syncName.locustCast)
	elseif msg == L["trigger_locustSwarmGain"] then
		self:Sync(syncName.locustGain)
	elseif msg == L["trigger_locustSwarmEnds"] then
		self:Sync(syncName.locustEnds)
	
	elseif string.find(msg, L["trigger_locustSwarmYou"]) and self.db.profile.locust then
		self:LocustYou()
	elseif msg == L["trigger_locustSwarmYouFade"] then
		self:LocustYouFade()
		
	elseif string.find(msg, L["trigger_impale"]) then
		self:Sync(syncName.impale)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_web"]) or string.find(msg, L["trigger_web2"]) then
		self:Sync(syncName.web)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.locustCast and self.db.profile.locust then
		self:LocustCast()
	elseif sync == syncName.locustGain and self.db.profile.locust then
		self:LocustGain()
	elseif sync == syncName.locustEnds and self.db.profile.locust then
		self:LocustEnds()
	
	elseif sync == syncName.impale and self.db.profile.impale then
		self:Impale()
	
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
		
	elseif sync == syncName.web and self.db.profile.web then
		self:Web()
	end
end

function module:LocustCast()
	self:RemoveBar(L["bar_impale"])
	
	self:RemoveBar(L["bar_locustSwarmCd"])
	self:CancelDelayedBar(L["bar_locustSwarmOffCd"])
	self:RemoveBar(L["bar_locustSwarmOffCd"])
	
	self:Bar(L["bar_locustSwarmCasting"], timer.locustSwarmCastTime, icon.locust, true, color.locustCasting)
	self:WarningSign(icon.locust, timer.locustSwarmCastTime)
	self:Message(L["msg_locustSwarmCasting"], "Urgent", false, nil, false)
	self:Sound("Beware")
end

function module:LocustGain()
	self:RemoveBar(L["bar_locustSwarmCasting"])
	self:RemoveWarningSign(icon.locust)
	self:Bar(L["bar_locustSwarmIsUp"], timer.locustSwarmDuration, icon.locust, true, color.locustCasting)
end

function module:LocustEnds()
	self:RemoveBar(L["bar_locustSwarmIsUp"])
	self:IntervalBar(L["bar_locustSwarmCd"], timer.locustSwarmInterval[1], timer.locustSwarmInterval[2], icon.locust, true, color.locustCd)
	self:DelayedBar(timer.locustSwarmInterval[1], L["bar_locustSwarmOffCd"], timer.readySwarmInterval, icon.locust, true, color.locustOffCd)
	
	if self.db.profile.impale then
		self:Impale()
	end
end

function module:LocustYou()
	self:Sound("Info")
	self:WarningSign(icon.locust, timer.locustAfflicted)
	self:Message(L["msg_locustYou"], "Personal", false, nil, false)
end

function module:LocustYouFade()
	self:RemoveWarningSign(icon.locust)
end

function module:Impale()
	self:IntervalBar(L["bar_impale"], timer.impale[1], timer.impale[2], icon.impale, true, color.impale)
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:Sound("Alarm")
	if UnitName("Target") == "Crypt Guard" then
		self:WarningSign(icon.enrage, 0.7)
	end
end

function module:Web()
	self:Bar(L["bar_webDur"], timer.webDur, icon.web, true, color.webDur)
	self:Bar(L["bar_webCd"], timer.webCd, icon.web, true, color.webCd)
end
