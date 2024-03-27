
local module, L = BigWigs:ModuleDeclaration("Lava Surger", "Molten Core")

module.revision = 30073
module.enabletrigger = module.translatedName
module.toggleoptions = {"surge"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "LavaSurger",

	surge_cmd = "surge",
	surge_name = "Surge Alert",
	surge_desc = "Warn for Surge",
	
	
	trigger_surge = "Lava Surger's Surge hits (.+) for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_surge = " failed to stack on the Surger",
	msg_surgeYou = "S T A C K on the Surger",
} end )

local timer = {
}
local icon = {
	surge = "ability_warrior_charge",
}
local color = {
}
local syncName = {
	surge = "LavaSurgerSurge"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_surge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_surge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_surge
	
	self:ThrottleSync(3, syncName.surge)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_surge"]) then
		local _,_, surgePerson, _ = string.find(msg, L["trigger_surge"])
		if surgePerson == "you" then surgePerson = UnitName("Player") end
		self:Sync(syncName.surge.. " ".. surgePerson)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.surge and self.db.profile.surge then
		self:Surge(rest)
	end
end


function module:Surge(rest)
	if rest == UnitName("Player") then
		self:Message(L["msg_surgeYou"], "Personal", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.surge, 0.7)
	else
		self:Message(rest..L["msg_surge"], "Important", false, nil, false)
	end
end
