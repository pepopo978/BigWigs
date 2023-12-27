
local module, L = BigWigs:ModuleDeclaration("Epidamu", "The Black Morass")

module.revision = 30029
module.enabletrigger = module.translatedName
module.toggleoptions = {"drainmana", "temporalconflux", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["The Black Morass"],
	AceLibrary("Babble-Zone-2.2")["The Black Morass"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Epidamu",

	drainmana_cmd = "drainmana",
	drainmana_name = "Drain Mana Alert",
	drainmana_desc = "Warn for Drain Mana",
	
	temporalconflux_cmd = "temporalconflux",
	temporalconflux_name = "Temporal Conflux Alert",
	temporalconflux_desc = "Warns for Temporal Conflux",

	trigger_drainManaYou = "You are afflicted by Drain Mana.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_drainManaOther = "(.+) is afflicted by Drain Mana.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_drainManaFade = "Drain Mana fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_drainMana = " Drain Mana",
	
	trigger_temporalConfluxYou = "You are afflicted by Temporal Conflux.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_temporalConfluxOther = "(.+) is afflicted by Temporal Conflux.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_temporalConfluxFade = "Temporal Conflux fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_temporalConflux = " Temporal Conflux",
} end )

local timer = {
	drainMana = 5,
	temporalConflux = 15,
}
local icon = {
	drainMana = "spell_shadow_siphonmana",
	temporalConflux = "spell_holy_borrowedtime",
}
local color = {
	drainMana = "Blue",
	temporalConflux = "Red",
}
local syncName = {
	drainMana = "EpidamuDrainMana"..module.revision,
	drainManaFade = "EpidamuDrainManaFade"..module.revision,
	temporalConflux = "EpidamuTemporalConflux"..module.revision,
	temporalConfluxFade = "EpidamuTemporalConfluxFade"..module.revision,
}


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_drainManaYou, trigger_temporalConfluxYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_drainManaOther, trigger_temporalConfluxOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_drainManaOther, trigger_temporalConfluxOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_drainManaFade, trigger_temporalConfluxFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_drainManaFade, trigger_temporalConfluxFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_drainManaFade, trigger_temporalConfluxFade
		
	self:ThrottleSync(1, syncName.drainMana)
	self:ThrottleSync(1, syncName.drainManaFade)
	self:ThrottleSync(1, syncName.temporalConflux)
	self:ThrottleSync(1, syncName.temporalConfluxFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_drainManaYou"]) then
		self:Sync(syncName.drainMana .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_drainManaOther"]) then
		local _,_, drainManaPlayer, _ = string.find(msg, L["trigger_drainManaOther"])
		self:Sync(syncName.drainMana .. " " .. drainManaPlayer)
		
	elseif string.find(msg, L["trigger_drainManaFade"]) then
		local _,_, drainManaFadePlayer, _ = string.find(msg, L["trigger_drainManaFade"])
		if drainManaFadePlayer == "you" then drainManaFadePlayer = UnitName("Player") end
		self:Sync(syncName.drainManaFade .. " " .. drainManaFadePlayer)
		
		
		
	elseif string.find(msg, L["trigger_temporalConfluxYou"]) then
		self:Sync(syncName.temporalConflux .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_temporalConfluxOther"]) then
		local _,_, temporalConfluxPlayer, _ = string.find(msg, L["trigger_temporalConfluxOther"])
		self:Sync(syncName.temporalConflux .. " " .. temporalConfluxPlayer)
	
	elseif string.find(msg, L["trigger_temporalConfluxFade"]) then
		local _,_, temporalConfluxFadePlayer, _ = string.find(msg, L["trigger_temporalConfluxFade"])
		if temporalConfluxFadePlayer == "you" then temporalConfluxFadePlayer = UnitName("Player") end
		self:Sync(syncName.temporalConfluxFade .. " " .. temporalConfluxFadePlayer)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.drainMana and rest and self.db.profile.drainmana then
		self:DrainMana(rest)
	elseif sync == syncName.drainManaFade and rest and self.db.profile.drainmana then
		self:DrainManaFade(rest)
	elseif sync == syncName.temporalConflux and rest and self.db.profile.temporalconflux then
		self:TemporalConflux(rest)
	elseif sync == syncName.temporalConfluxFade and rest and self.db.profile.temporalconflux then
		self:TemporalConfluxFade(rest)
	end
end


function module:DrainMana(rest)
	self:Bar(rest..L["bar_drainMana"], timer.drainMana, icon.drainMana, true, color.drainMana)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") ~= "Paladin" then
		self:WarningSign(icon.drainMana, 0.7)
		self:Sound("Info")
	end
end

function module:DrainManaFade(rest)
	self:RemoveBar(rest..L["bar_drainMana"])
end

function module:TemporalConflux(rest)
	self:Bar(rest..L["bar_temporalConflux"], timer.temporalConflux, icon.temporalConflux, true, color.temporalConflux)
end

function module:TemporalConfluxFade(rest)
	self:RemoveBar(rest..L["bar_temporalConflux"])
end
