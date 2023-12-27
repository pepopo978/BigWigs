
local module, L = BigWigs:ModuleDeclaration("Chronar", "The Black Morass")

module.revision = 30029
module.enabletrigger = module.translatedName
module.toggleoptions = {"reflect", "ms", "enrage", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["The Black Morass"],
	AceLibrary("Babble-Zone-2.2")["The Black Morass"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Chronar",

	reflect_cmd = "reflect",
	reflect_name = "Spell Reflect Alert",
	reflect_desc = "Warn for Spell Reflect",
	
	ms_cmd = "ms",
	ms_name = "Mortal Strike Alert",
	ms_desc = "Warns for Mortal Strike",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warns for Enrage",
	
	trigger_engage = "It seems we have visitors. You should not have come here mortals, now I will ensure that you will not leave.",--CHAT_MSG_MONSTER_YELL
	
	trigger_reflect = "Chronar gains Reflection.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_reflectFade = "Reflection fades from Chronar.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_reflect = "Spell Reflect",
	msg_reflect = "Chronar is reflecting Spells!",
	
	trigger_msOther = "(.+) is afflicted by Mortal Strike.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_msYou = "You are afflicted by Mortal Strike.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_msFade = "Mortal Strike fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_ms = " Mortal Strike",
	
	trigger_enrage = "Chronar gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",
	msg_enrage = "Enrage!",
} end )

local timer = {
	reflect = 10,
	ms = 5,
}
local icon = {
	reflect = "Spell_Arcane_Blink",
	ms = "ability_warrior_savageblow",
	enrage = "Spell_Shadow_UnholyFrenzy",
}
local color = {
	reflect = "Blue",
	ms = "Red",
}
local syncName = {
	reflect = "ChronarReflect"..module.revision,
	reflectFade = "ChronarReflectFade"..module.revision,
	ms = "ChronarMs"..module.revision,
	msFade = "ChronarMsFade"..module.revision,
	enrage = "ChronarEnrage"..module.revision,
}


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_msYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_msOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_msOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_msFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_msFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_msFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_reflect, trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage
	
	self:ThrottleSync(1, syncName.reflect)
	self:ThrottleSync(1, syncName.reflectFade)
	self:ThrottleSync(1, syncName.ms)
	self:ThrottleSync(1, syncName.msFade)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	end
end

function module:Event(msg)
	if msg == L["trigger_reflect"] then
		self:Sync(syncName.reflect)
	elseif msg == L["trigger_reflectFade"] then
		self:Sync(syncName.reflectFade)
		
	elseif string.find(msg, L["trigger_msYou"]) then
		self:Sync(syncName.ms .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_msOther"]) then
		local _,_, msPlayer, _ = string.find(msg, L["trigger_msOther"])
		self:Sync(syncName.ms .. " " .. msPlayer)
	
	elseif string.find(msg, L["trigger_msFade"]) then
		local _,_, msFadePlayer, _ = string.find(msg, L["trigger_msFade"])
		if msFadePlayer == "you" then msFadePlayer = UnitName("Player") end
		self:Sync(syncName.msFade .. " " .. msFadePlayer)
		
		
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.reflect and self.db.profile.reflect then
		self:Reflect()
	elseif sync == syncName.reflectFade and self.db.profile.reflect then
		self:ReflectFade()
	elseif sync == syncName.ms and rest and self.db.profile.ms then
		self:Ms(rest)
	elseif sync == syncName.msFade and rest and self.db.profile.ms then
		self:MsFade(rest)
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end


function module:Reflect()
	self:Bar(L["bar_reflect"], timer.reflect, icon.reflect, true, color.reflect)
	
	if UnitClass("Player") ~= "Warrior" and UnitClass("Player") ~= "Rogue" then
		self:WarningSign(icon.reflect, 0.7)
		self:Sound("Info")
		self:Message(L["msg_reflect"], "Urgent", false, nil, false)
	end
end

function module:ReflectFade()
	self:RemoveBar(L["bar_reflect"])
end

function module:Ms(rest)
	self:Bar(rest..L["bar_ms"], timer.ms, icon.ms, true, color.ms)
end

function module:MsFade(rest)
	self:RemoveBar(rest..L["bar_ms"])
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Attention", false, nil, false)
	self:WarningSign(icon.enrage, 0.7)
	self:Sound("Beware")
end
