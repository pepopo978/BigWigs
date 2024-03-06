
local module, L = BigWigs:ModuleDeclaration("Gurubashi Berserker", "Zul'Gurub")

module.revision = 30041
module.enabletrigger = module.translatedName
module.toggleoptions = {"fear", "knock", "thunderclap"}
module.trashMod = true
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Berserker",
	
	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for Fear",
	
	knock_cmd = "knock",
	knock_name = "Knock Away Alert",
	knock_desc = "Warn for Knock Away",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	
	
	trigger_fear1 = "afflicted by Intimidating Roar",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_fear2 = "Intimidating Roar fail(.+) immune.",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_fear3 = "Intimidating Roar was resisted",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fear = "Fear CD",
	
	trigger_knockAway = "Gurubashi Berserker's Knock Away",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_knockAway = "KnockAway CD",
	
	trigger_thunderclap = "Gurubashi Berserker's Thunderclap",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_thunderclap = "Thunderclap CD",
} end )



local timer = {
	firstFear = 15,--ok
	fear = 25,--ok
	
	firstKnock = 10,--ok
	knockAway = 10,--ok
	
	firstThunderclap = 5,--ok
	thunderclap = 15,--ok
}
local icon = {
	fear = "Ability_GolemThunderClap",
	knockAway = "INV_Gauntlets_05",
	thunderclap = "Ability_ThunderClap",
}
local color = {
	fear = "White",
	knockAway = "Red",
	thunderclap = "Blue",
}
local syncName = {
	fear = "BerserkerDebuff"..module.revision,
	knockAway = "BerserkerKnockBack"..module.revision,
	thunderclap = "BerserkerThunderclap"..module.revision,
}


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_fear1
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_fear1
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_fear1
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_fear2, 3, trigger_knockAway, trigger_thunderclap
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_fear2, 3, trigger_knockAway, trigger_thunderclap
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_fear2, 3, trigger_knockAway, trigger_thunderclap


	self:ThrottleSync(2, syncName.fear)
	self:ThrottleSync(2, syncName.knockAway)
	self:ThrottleSync(2, syncName.thunderclap)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.fear then
		self:Bar(L["bar_fear"], timer.firstFear, icon.fear, true, color.fear)
	end
	if self.db.profile.knock then
		self:Bar(L["bar_knockAway"], timer.firstKnock, icon.knockAway, true, color.knockAway)
	end
	if self.db.profile.thunderclap then
		self:Bar(L["bar_thunderclap"], timer.firstThunderclap, icon.thunderclap, true, color.thunderclap)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_fear1"]) or string.find(msg, L["trigger_fear2"]) or string.find(msg, L["trigger_fear3"]) then
		self:Sync(syncName.fear)
	elseif string.find(msg, L["trigger_knockAway"]) then
		self:Sync(syncName.knockAway)
	elseif string.find(msg, L["trigger_thunderclap"]) then
		self:Sync(syncName.thunderclap)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	elseif sync == syncName.knockAway and self.db.profile.knock then
		self:KnockAway()
	elseif sync == syncName.thunderclap and self.db.profile.thunderclap then
		self:Thunderclap()
	end
end

function module:Fear()
	self:Bar(L["bar_fear"], timer.fear, icon.fear, true, color.fear)
end

function module:KnockAway()
	self:Bar(L["bar_knockAway"], timer.knockAway, icon.knockAway, true, color.knockAway)
end

function module:Thunderclap()
	self:Bar(L["bar_thunderclap"], timer.thunderclap, icon.thunderclap, true, color.thunderclap)
end
