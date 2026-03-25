
local module, L = BigWigs:ModuleDeclaration("Grizikil", "Karazhan")

module.revision = 30024
module.enabletrigger = module.translatedName
module.toggleoptions = {"rainoffire", "flamewave", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grizikil",
	
	rainoffire_cmd = "rainoffire",
	rainoffire_name = "Rain of Fire Alert",
	rainoffire_desc = "Warn for Rain of Fire",

	flamewave_cmd = "flamewave",
	flamewave_name = "Flamewave Alert",
	flamewave_desc = "Warn for Flamewave",
	
	
	
	trigger_rainOfFireYou = "You suffer (.+) Fire damage from Grizikil's Grellkin Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_rainOfFireYou = "Get out of Rain of Fire!",
	
	trigger_flamewave = "Grizikil is afflicted by Flamewave.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	trigger_flamewaveFade = "Flamewave fades from Grizikil.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_flamewave = "Flamewave",
	msg_flamewave = "Flamewave, melee run out!",
	
	trigger_yellSmt = "You-you-you no defeat me, I am strong!",--CHAT_MSG_MONSTER_YELL
	
	trigger_engage = "Whats this? You're here for the orb?! ITS MINE, Grellkin, get them!",--CHAT_MSG_MONSTER_YELL
	
	msg_pullAll = "Pull --ALL-- imp packs before engaging Grizikil!",
} end )


L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Grizikil",

    rainoffire_cmd = "rainoffire",
    rainoffire_name = "火焰之雨警报",
    rainoffire_desc = "火焰之雨出现时进行警告",

    flamewave_cmd = "flamewave",
    flamewave_name = "烈焰波警报",
    flamewave_desc = "烈焰波出现时进行警告",
    

    
    trigger_rainOfFireYou = "You suffer (.+) Fire damage from Grizikil's Grellkin Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
    msg_rainOfFireYou = "离开火焰之雨区域！",
    
    trigger_flamewave = "Grizikil is afflicted by Flamewave.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
    trigger_flamewaveFade = "Flamewave fades from Grizikil.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
    bar_flamewave = "烈焰波",
    msg_flamewave = "烈焰波，近战快躲开！",
    
    trigger_yellSmt = "You-you-you no defeat me, I am strong!",--CHAT_MSG_MONSTER_YELL
    
    trigger_engage = "Whats this? You're here for the orb?! ITS MINE, Grellkin, get them!",--CHAT_MSG_MONSTER_YELL
    
    msg_pullAll = "在与格里兹基尔交战前，拉清--所有--小鬼群！",
} end )
local timer = {
	flamewave = 9,
}
local icon = {
	rainOfFire = "spell_shadow_rainoffire",
	flamewave = "spell_fire_incinerate",
}
local color = {
	flamewave = "Red"
}
local syncName = {
	flamewave = "GrizikilFlamewave"..module.revision,
	flamewaveFade = "GrizikilFlamewaveFade"..module.revision,
}

--module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	self:Message(L["msg_pullAll"], "Urgent", false, nil, false)
	
	self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_rainOfFireYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")--trigger_flamewave
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_flamewaveFade
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage
	
	self:ThrottleSync(5, syncName.flamewave)
	self:ThrottleSync(5, syncName.flamewaveFade)
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
	if string.find(msg, L["trigger_rainOfFireYou"]) then
		self:WarningSign(icon.rainOfFire, 0.7)
		self:Message(L["msg_rainOfFireYou"], "Important", false, nil, false)
		self:Sound("Info")
	
	elseif msg == L["trigger_flamewave"] then
		self:Sync(syncName.flamewave)
	
	elseif msg == L["trigger_flamewaveFade"] then
		self:Sync(syncName.flamewaveFade)
	
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.flamewave and self.db.profile.flamewave then
		self:Flamewave()
	elseif sync == syncName.flamewaveFade and self.db.profile.flamewave then
		self:FlamewaveFade()
	end
end

function module:Flamewave()
	self:Bar(L["bar_flamewave"], timer.flamewave, icon.flamewave, true, color.flamewave)
	self:Message(L["msg_flamewave"], "Urgent", false, nil, false)
	self:WarningSign(icon.flamewave, 1)
	self:Sound("Beware")
end

function module:FlamewaveFade()
	self:RemoveBar(L["bar_flamewave"])
end
