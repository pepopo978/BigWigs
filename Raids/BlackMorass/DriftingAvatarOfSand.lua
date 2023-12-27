
local module, L = BigWigs:ModuleDeclaration("Drifting Avatar of Sand", "The Black Morass")

module.revision = 30029
module.enabletrigger = module.translatedName
module.toggleoptions = {"blindingsand", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["The Black Morass"],
	AceLibrary("Babble-Zone-2.2")["The Black Morass"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "DriftingAvatarOfSand",

	blindingsand_cmd = "blindingsand",
	blindingsand_name = "Blinding Sand Alert",
	blindingsand_desc = "Warn for Blinding Sand",
	
	trigger_blindingSandYou = "You are afflicted by Blinding Sand.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_blindingSandOther = "(.+) is afflicted by Blinding Sand.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_blindingSandFade = "Blinding Sand fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_blindingSand = " Blinded",
} end )

local timer = {
	blindingSand = 5,
}
local icon = {
	blindingSand = "spell_shadow_mindsteal",
}
local color = {
	blindingSand = "Black",
}
local syncName = {
	blindingSand = "DriftingAvatarOfSandBlindingSand"..module.revision,
	blindingSandFade = "DriftingAvatarOfSandBlindingSandFade"..module.revision,
}


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_blindingSandYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_blindingSandOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_blindingSandOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_blindingSandFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_blindingSandFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_blindingSandFade
		
	self:ThrottleSync(0, syncName.blindingSand)
	self:ThrottleSync(0, syncName.blindingSandFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_blindingSandYou"]) then
		self:Sync(syncName.blindingSand .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_blindingSandOther"]) then
		local _,_, blindingSandPlayer, _ = string.find(msg, L["trigger_blindingSandOther"])
		self:Sync(syncName.blindingSand .. " " .. blindingSandPlayer)
		
	elseif string.find(msg, L["trigger_blindingSandFade"]) then
		local _,_, blindingSandFadePlayer, _ = string.find(msg, L["trigger_blindingSandFade"])
		if blindingSandFadePlayer == "you" then blindingSandFadePlayer = UnitName("Player") end
		self:Sync(syncName.blindingSandFade .. " " .. blindingSandFadePlayer)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.blindingSand and rest and self.db.profile.blindingsand then
		self:BlindingSand(rest)
	elseif sync == syncName.blindingSandFade and rest and self.db.profile.blindingsand then
		self:BlindingSandFade(rest)
	end
end


function module:BlindingSand(rest)
	self:Bar(rest..L["bar_blindingSand"], timer.blindingSand, icon.blindingSand, true, color.blindingSand)
end

function module:BlindingSandFade(rest)
	self:RemoveBar(rest..L["bar_blindingSand"])
end
