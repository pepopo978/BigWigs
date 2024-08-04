
local module, L = BigWigs:ModuleDeclaration("Princess Huhuran", "Ahn'Qiraj")

module.revision = 30033
module.enabletrigger = module.translatedName
module.toggleoptions = {"wyvernsting", "frenzy", "noxiouspoison", "berserk", "enrage", "bosskill"}

module.defaultDB = {
	enrage = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Huhuran",

	wyvernsting_cmd = "wyvernsting",
	wyvernsting_name = "Wyvern Sting Alert",
	wyvernsting_desc = "Warn for Wyvern Sting",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",

	noxiouspoison_cmd = "noxiouspoison",
	noxiouspoison_name = "Noxious Poison Alert",
	noxiouspoison_desc = "Warn for Noxious Poison",
	
	berserk_cmd = "berserk",
	berserk_name = "Low Hp Berserk Alert",
	berserk_desc = "Warn for Low Hp Berserk",
	
	enrage_cmd = "enrage",
	enrage_name = "Timed Enrage Alert",
	enrage_desc = "Warn for Timed Enrage",
	
	
	trigger_wyvernSting = "afflicted by Wyvern Sting",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_wyvernStingYou = "You are afflicted by Wyvern Sting.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_wyvernStingYouFade = "Wyvern Sting fades from you.",--CHAT_MSG_SPELL_AURA_GONE_SELF
	bar_wyvernStingDuration = "Wyvern Stung",
	bar_wyvernStingCd = "Wyvern Sting CD",
	
	trigger_frenzyGain = "Princess Huhuran gains Frenzy.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from Princess Huhuran.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_frenzyDuration = "Frenzy!",
	bar_frenzyCd = "Frenzy CD",
	msg_frenzy = "Frenzy - Tranq Shot!",

	trigger_noxiousPoison = "afflicted by Noxious Poison",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_noxiousPoisonYou = "You are afflicted by Noxious Poison.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_noxiousPoisonYouFade = "Noxious Poison fades from you.",--CHAT_MSG_SPELL_AURA_GONE_SELF
	bar_noxiousPoisonDuration = "People Silenced",
	bar_noxiousPoisonCd = "Noxious Poison CD",
	
	trigger_berserk = "Princess Huhuran gains Berserk.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_berserk = "Berserk! Soak poison!",
	
	trigger_enrage = "Princess Huhuran gains Enrage.",--5min timer, string to be confirmed
	bar_enrage = "Enrage",
	msg_enrage1min = "Enrage in 60 seconds",
	msg_enrage5sec = "Enrage in 5 seconds",
} end )

local timer = {
	wyvernStingCdFirst = {18,28},
	wyvernStingCd = {3,20},--15,32 minus 12sec duration
	wyvernStingDuration = 12,
	
	frenzyCd = {25,35},
	frenzyDuration = 8,
	
	noxiousPoisonCdFirst = {10,14},
	noxiousPoisonCd = {3,7},--11,15 minus 8sec duration
	noxiousPoisonDuration = 8,
	
	enrage = 300,
}
local icon = {
	wyvernSting = "INV_Spear_02",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranq = "Spell_Nature_Drowsy",
	noxiousPoison = "spell_nature_corrosivebreath",
	berserk = "Spell_Shadow_UnholyFrenzy",
	enrage = "Spell_Shadow_UnholyFrenzy",
}
local color = {
	wyvernStingCd = "Yellow",
	wyvernStingDuration = "Blue",
	frenzyCd = "Cyan",
	frenzyDuration = "Red",
	noxiousPoisonCd = "Black",
	noxiousPoisonDuration = "Green",
	enrage = "White",
}
local syncName = {
	wyvernSting = "HuhuranWyvernSting"..module.revision,
	frenzyGain = "HuhuranFrenzyGain"..module.revision,
	frenzyFade = "HuhuranFrenzyFade"..module.revision,
	noxiousPoison = "HuhuranNoxiousCD"..module.revision,
	berserk = "HuhuranBerserk"..module.revision,
	enrage = "HuhuranEnrage"..module.revision,
}

local lastFrenzy = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_wyvernSting, trigger_noxiousPoison,trigger_noxiousPoisonYou , trigger_wyvernStingYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_wyvernSting, trigger_noxiousPoison
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_wyvernSting, trigger_noxiousPoison
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_frenzyGain, trigger_berserk
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_frenzyFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_noxiousPoisonYouFade, trigger_wyvernStingYouFade

	self:ThrottleSync(5, syncName.wyvernSting)
	self:ThrottleSync(5, syncName.frenzyGain)
	self:ThrottleSync(5, syncName.frenzyFade)
	self:ThrottleSync(5, syncName.noxiousPoison)
	self:ThrottleSync(5, syncName.berserk)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.berserk, true, color.enrage)
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage1min"], "Urgent", false, nil, false)
		self:DelayedMessage(timer.enrage - 5, L["msg_enrage5sec"], "Urgent", false, nil, false)
	end
	if self.db.profile.wyvernsting then
		self:IntervalBar(L["bar_wyvernStingCd"], timer.wyvernStingCdFirst[1], timer.wyvernStingCdFirst[2], icon.wyvernSting, true, color.wyvernStingCd)
	end
	if self.db.profile.frenzy then
		self:IntervalBar(L["bar_frenzyCd"], timer.frenzyCd[1], timer.frenzyCd[2], icon.frenzy, true, color.frenzyCd)
	end
	if self.db.profile.noxiouspoison then
		self:IntervalBar(L["bar_noxiousPoisonCd"], timer.noxiousPoisonCdFirst[1], timer.noxiousPoisonCdFirst[2], icon.noxiousPoison, true, color.noxiousPoisonCd)
	end
end
function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_noxiousPoisonYou"] then
		self:WarningSign(icon.noxiousPoison, timer.noxiousPoisonDuration)
	elseif msg == L["trigger_noxiousPoisonYouFade"] then
		self:RemoveWarningSign(icon.noxiousPoison)
	end
	
	if msg == L["trigger_wyvernStingYou"] then
		self:WarningSign(icon.wyvernSting, timer.wyvernStingDuration)
	elseif msg == L["trigger_wyvernStingYouFade"] then
		self:RemoveWarningSign(icon.wyvernSting)
	end
	
	
	if string.find(msg, L["trigger_wyvernSting"]) then
		self:Sync(syncName.wyvernSting)
	
	elseif msg == L["trigger_frenzyGain"] then
		self:Sync(syncName.frenzyGain)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyFade)
		
	elseif string.find(msg, L["trigger_noxiousPoison"]) then
		self:Sync(syncName.noxiousPoison)

	elseif msg == L["trigger_berserk"] then
		self:Sync(syncName.berserk)
		
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.wyvernSting and self.db.profile.wyvernsting then
		self:WyvernSting()
	elseif sync == syncName.frenzyGain and self.db.profile.frenzy then
		self:FrenzyGain()
	elseif sync == syncName.frenzyFade and self.db.profile.frenzy then
		self:FrenzyFade()
	elseif sync == syncName.noxiousPoison and self.db.profile.noxiouspoison then
		self:NoxiousPoison()
	elseif sync == syncName.berserk and self.db.profile.berserk then
		self:Berserk()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end

function module:WyvernSting()
	self:RemoveBar(L["bar_wyvernStingCd"])
	
	self:Bar(L["bar_wyvernStingDuration"], timer.wyvernStingDuration, icon.wyvernSting, true, color.wyvernStingDuration)
	self:DelayedIntervalBar(timer.wyvernStingDuration, L["bar_wyvernStingCd"], timer.wyvernStingCd[1], timer.wyvernStingCd[2], icon.wyvernSting, true, color.wyvernStingCd)
end

function module:FrenzyGain()
	self:RemoveBar(L["bar_frenzyCd"])
	
	self:Bar(L["bar_frenzyDuration"], timer.frenzyDuration, icon.frenzy, true, color.frenzyDuration)
	self:Message(L["msg_frenzy"], "Important", false, nil, false)
	
	lastFrenzy = GetTime()
	
	if UnitClass("Player") == "Hunter" then
		self:Sound("Info")
		self:WarningSign(icon.tranq, timer.frenzyDuration)
	end
end

function module:FrenzyFade()
	self:RemoveBar(L["bar_frenzyDuration"])
	self:RemoveWarningSign(icon.tranq)
	
	if lastFrenzy ~= 0 then
		local NextTime = (lastFrenzy + timer.frenzyCd[1]) - GetTime()
		local latestNextTime = (lastFrenzy + timer.frenzyCd[2]) - GetTime()
		self:IntervalBar(L["bar_frenzyCd"], NextTime, latestNextTime, icon.frenzy, true, color.frenzyCd)
	end
end

function module:NoxiousPoison()
	self:RemoveBar(L["bar_noxiousPoisonCd"])
	
	self:Bar(L["bar_noxiousPoisonDuration"], timer.noxiousPoisonDuration, icon.noxiousPoison, true, color.noxiousPoisonDuration)
	self:DelayedIntervalBar(timer.noxiousPoisonDuration, L["bar_noxiousPoisonCd"], timer.noxiousPoisonCd[1], timer.noxiousPoisonCd[2], icon.noxiousPoison, true, color.noxiousPoisonCd)
end

function module:Berserk()
	--no more frenzy when she berserks
	self:RemoveBar(L["bar_frenzyDuration"])
	self:RemoveBar(L["bar_frenzyCd"])
	self:RemoveWarningSign(icon.tranq)

	
	self:Message(L["msg_berserk"], "Urgent", false, nil, false)
	self:Sound("Beware")
	self:WarningSign(icon.berserk, 0.7)
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage1min"])
	self:CancelDelayedMessage(L["msg_enrage5sec"])
	
	self:Sound("Beware")
	self:WarningSign(icon.enrage, 0.7)
end
