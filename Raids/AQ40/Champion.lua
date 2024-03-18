
local module, L = BigWigs:ModuleDeclaration("Qiraji Champion", "Ahn'Qiraj")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"fear"}
module.trashMod = true
module.defaultDB = {
	bosskill = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Champion",

	fear_cmd = "fear",
	fear_name = "Intimidating Shout Alert",
	fear_desc = "Warn for Intimidating Shout",
	
	
	trigger_fear = "afflicted by Intimidating Shout", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_fear2 = "Qiraji Champion's Intimidating Shout was resisted", --to be confirmed
	trigger_fear3 = "Qiraji Champion's Intimidating Shout fail", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	bar_fear = "Intimidating Shout CD",
} end )

local timer = {
	fearCd = {19,40},--saw 19, saw 40
}
local icon = {
	fear = "ability_golemthunderclap",
}
local color = {
	fear = "Blue",
}
local syncName = {
	fear = "QirajiChampionFear"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	
	
	self:ThrottleSync(15, syncName.fear)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_fear"]) or string.find(msg, L["trigger_fear2"]) or string.find(msg, L["trigger_fear3"]) then
		self:Sync(syncName.fear)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	end
end

function module:Fear()
	self:IntervalBar(L["bar_fear"], timer.fearCd[1], timer.fearCd[2], icon.fear, true, color.fear)
end
