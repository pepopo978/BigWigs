local module, L = BigWigs:ModuleDeclaration("The Beast", "Blackrock Spire")

module.revision = 30025
module.enabletrigger = module.translatedName
module.toggleoptions = {"fear","bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Beast",
	
	fear_cmd = "fear",
	fear_name = "Fear",
	fear_desc = "Fear cooldown timer.",
	
	trigger_fear = "afflicted by Terrifying Roar.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_fearDuration = "Fear Duration",
	bar_fearCd = "Fear CD",
} end )

local timer = {
	fearCd = 10,
	fearDuration = 5,
}

local icon = {
	fear = "ability_devour",
}

local syncName = {
	fear = "TheBeastFear"..module.revision,
}

local color = {
	fearCd = "White",
	fearDuration = "Black",
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --debug
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_fear
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_fear
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_fear
	
	self:ThrottleSync(3, syncName.fear)
end

function module:OnSetup()
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_fear"]) then
		self:Sync(syncName.fear)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	end
end

function module:Fear()
	self:Bar(L["bar_fearDuration"], timer.fearDuration, icon.fear, true, color.fearDuration)
	self:DelayedBar(timer.fearDuration, L["bar_fearCd"], timer.fearCd, icon.fear, true, color.fearCd)
end
