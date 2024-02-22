
local module, L = BigWigs:ModuleDeclaration("Grobbulus", "Naxxramas")

module.revision = 30050
module.enabletrigger = module.translatedName
module.toggleoptions = {"slimespray", "inject", "cloud", "icon",  -1, "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grobbulus",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	slimespray_cmd = "slimespray",
	slimespray_name = "Slime Spray",
	slimespray_desc = "Show timer for Slime Spray",
	
	inject_cmd = "inject",
	inject_name = "Mutating Injection Alert",
	inject_desc = "Warn when someone is injected",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on an injected person. (Requires promoted or higher)",

	cloud_cmd = "cloud",
	cloud_name = "Poison Cloud",
	cloud_desc = "Warn for Poison Clouds",
		
	trigger_enrage = "%s becomes enraged!",--to be confirmed
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 1min",
	msg_enrage10 = "Enrage in 10sec",
	msg_enrage = "Enrage!",
	
	trigger_slimeSpray = "Slime Spray",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	bar_slimeSprayCD = "Slime Spray CD",
	
	trigger_inject = "(.+) is afflicted by Mutating Injection.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_injectYou = "You are afflicted by Mutating Injection.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_injectFade = "Mutating Injection fades from (.+),",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_injected = " Injected",
	msg_inject = " Injected",
	
	trigger_cloudCast = "Grobbulus casts Poison Cloud.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_cloudCD = "Poison Cloud CD",
	msg_cloudCast = "Cloud -- Move Grobbulus!",
	trigger_cloudHitsYou = "Grobbulus Cloud's Poison hits you",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
} end )

local timer = {
	enrage = 720,
	firstSlimeSpray = {20, 30},--25
	slimeSprayCD = {30, 35},--confirmed
	injectDuration = 10,
	cloudCD = 16,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	slimeSpray = "INV_Misc_Slime_01",
	inject = "Spell_Shadow_CallofBone",
	cloud = "Ability_Creature_Disease_02",
	cleanse = "spell_holy_renew",
}
local syncName = {
	enrage = "GrobbulusEnrage"..module.revision,
	slimeSpray = "GrobbulusSlimeSpray"..module.revision,
	inject = "GrobbulusInject"..module.revision,
	injectFade = "GrobbulusInjectFade"..module.revision,
	cloud = "GrobbulusCloud"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--inject
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--inject
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--inject
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--slimeSpray, cloudHitsYou
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--slimeSpray
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--slimeSpray
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--cloudCast
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_injectFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_injectFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_injectFade
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.slimeSpray)
	self:ThrottleSync(3, syncName.inject)
	self:ThrottleSync(0, syncName.injectFade)
	self:ThrottleSync(5, syncName.cloud)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, "White")
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important")
	end
	if self.db.profile.slimespray then
		self:IntervalBar(L["bar_slimeSprayCD"], timer.firstSlimeSpray[1], timer.firstSlimeSpray[2], icon.slimeSpray, true, "Green")
	end
	if self.db.profile.cloud then
		self:Bar(L["bar_cloudCD"], timer.cloudCD, icon.cloud, true, "Blue")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_slimeSpray"]) then
		self:Sync(syncName.slimeSpray)
	
	elseif string.find(msg, L["trigger_inject"]) then
		local _,_, injectPerson, _ = string.find(msg, L["trigger_inject"])
		self:Sync(syncName.inject.." "..injectPerson)
	elseif msg == L["trigger_injectYou"] then
		self:Sync(syncName.inject.." "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_injectFade"]) then
		local _,_, injectFadePerson, _ = string.find(msg, L["trigger_injectFade"])
		if injectFadePerson == "you" then injectFadePerson = UnitName("Player") end
		self:Sync(syncName.injectFade.." "..injectFadePerson)

	
	elseif msg == L["trigger_cloudCast"] then
		self:Sync(syncName.cloud)
		
	elseif string.find(msg, L["trigger_cloudHitsYou"]) then
		self:WarningSign(icon.cloud, 0.7)
		self:Sound("Info")
	end
end




function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.slimeSpray and self.db.profile.slimespray then
		self:SlimeSpray()
	elseif sync == syncName.inject and rest and self.db.profile.inject then
		self:Inject(rest)
	elseif sync == syncName.injectFade and rest and self.db.profile.inject then
		self:InjectFade(rest)
	elseif sync == syncName.cloud and self.db.profile.cloud then
		self:Cloud()
	end
end




function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:WarningSign(icon.enrage, 0.7)
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:Sound("RunAway")
end

function module:SlimeSpray()
	self:RemoveBar(L["bar_slimeSprayCD"])
	self:IntervalBar(L["bar_slimeSprayCD"], timer.slimeSprayCD[1], timer.slimeSprayCD[2], icon.slimeSpray, true, "Green")
end

function module:Inject(rest)
	self:Bar(rest..L["bar_injected"], timer.injectDuration, icon.inject, true, "Red")
	self:Message(rest..L["msg_inject"], "Urgent", false, nil, false)
	
	if (IsRaidLeader() or IsRaidOfficer()) and self.db.profile.icon then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 8)
			end
		end
	end
	
	if rest == UnitName("Player") then
		SendChatMessage("Inject on "..UnitName("Player").."!","SAY")
		self:Sound("Beware")
		self:WarningSign(icon.inject, 3)
	end
end

function module:InjectFade(rest)
	self:RemoveBar(rest..L["bar_injected"])
	
	if (IsRaidLeader() or IsRaidOfficer()) and self.db.profile.icon then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 0)
			end
		end
	end
	
	if rest == UnitName("Player") then
		self:WarningSign(icon.cleanse, 1)
		self:Sound("Long")
	end
end

function module:Cloud()
	self:Message(L["msg_cloudCast"], "Important", false, nil, false)
	self:Bar(L["bar_cloudCD"], timer.cloudCD, icon.cloud, true, "Blue")
end
