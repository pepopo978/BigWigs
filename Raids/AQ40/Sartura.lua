
local module, L = BigWigs:ModuleDeclaration("Battleguard Sartura", "Ahn'Qiraj")

module.revision = 30075
module.enabletrigger = module.translatedName
module.wipemobs = {"Sartura's Royal Guard"}
module.toggleoptions = {"whirlwind", "adds", "enrage", "berserk", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sartura",
		
	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Sartura's Royal Guards.",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind",
	whirlwind_desc = "Timers and bars for Whirlwinds.",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Announces the Enrage when the boss is at 20% HP.",

	berserk_cmd = "berserk",
	berserk_name = "Berserk",
	berserk_desc = "Warns for the Berserk that the boss gains after 10 minutes.",

	
	trigger_engage = "You will be judged for defiling these sacred grounds! The laws of the Ancients will not be challenged! Trespassers will be annihilated!", --CHAT_MSG_MONSTER_YELL
	trigger_bossDead = "I serve to the last!", --CHAT_MSG_MONSTER_YELL
	
	trigger_addDead = "Sartura's Royal Guard dies.", --CHAT_MSG_COMBAT_HOSTILE_DEATH
	msg_addDead = "%d/3 Sartura's Royal Guards dead!",
	
	trigger_whirlwind = "Battleguard Sartura gains Whirlwind.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_whirlwind = "Whirlwind!",
	msg_whirlwind = "Whirlwind!",
	bar_whirlwindCd = "Whirlwind CD",
	
	trigger_whirlwindFade = "Whirlwind fades from Battleguard Sartura.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_whirlwindFade = "Whirlwind ended!",
	
	trigger_enrage = "Battleguard Sartura gains Enrage", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Enrage - Spam heals!",
	
	trigger_berserk = "Battleguard Sartura gains Berserk.", --to be confirmed
	msg_berserk = "Berserk!",
	bar_berserk = "Berserk",
	msg_berserk60 = "Berserk in 60 seconds!",
	msg_berserk10 = "Berserk in 10 seconds!",
} end )

local timer = {
	firstWhirlwind = {8,12},
	whirlwindCd = {5,10},
	whirlwindDur = 15,
	
	berserk = 600,
}
local icon = {
	whirlwind = "Ability_Whirlwind",
	berserk = "Spell_Shadow_UnholyFrenzy",
}
local color = {
	whirlwindCd = "Blue",
	whirlwindDur = "Red",
	berserk = "Black",
}
local syncName = {
	whirlwind = "SarturaWhirlwindStart"..module.revision,
	whirlwindFade = "SarturaWhirlwindEnd"..module.revision,
	enrage = "SarturaEnrage"..module.revision,
	berserk = "SarturaBerserk"..module.revision,
}

local addDeadCount = 0

module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	--self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")


	self:ThrottleSync(3, syncName.whirlwind)
	self:ThrottleSync(3, syncName.whirlwindFade)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.berserk)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	addDeadCount = 0
	
	if self.db.profile.berserk then
		self:Bar(L["bar_berserk"], timer.berserk, icon.berserk, true, color.berserk)
		self:DelayedMessage(timer.berserk - 60, L["msg_berserk60"], "Urgent", false, nil, false)
		self:DelayedMessage(timer.berserk - 10, L["msg_berserk10"], "Important", false, nil, false)
	end
	
	if self.db.profile.whirlwind then
		self:IntervalBar(L["bar_whirlwindCd"], timer.firstWhirlwind[1], timer.firstWhirlwind[2], icon.whirlwind, true, color.whirlwindCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if msg == L["trigger_addDead"] and self.db.profile.adds then
		addDeadCount = addDeadCount + 1
		self:Message(string.format(L["msg_addDead"], addDeadCount), "Positive", false, nil, false)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_bossDead"] then
		self:SendBossDeathSync()
	end
end

function module:Event(msg)
	if msg == L["trigger_whirlwind"] then
		self:Sync(syncName.whirlwind)
	elseif msg == L["trigger_whirlwindFade"] then
		self:Sync(syncName.whirlwindFade)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif msg == L["trigger_berserk"] then
		self:Sync(syncName.berserk)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
	
	elseif sync == syncName.whirlwindFade and self.db.profile.whirlwind then
		self:WhirlwindFade()
	
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
		
	elseif sync == syncName.berserk and self.db.profile.berserk then
		self:Berserk()
	end
end


function module:Whirlwind()
	self:RemoveBar(L["bar_whirlwindCd"])
	
	self:Bar(L["bar_whirlwind"], timer.whirlwindDur, icon.whirlwind, true, color.whirlwindDur)
	self:Message(L["msg_whirlwind"], "Important", false, nil, false)
end

function module:WhirlwindFade()
	self:RemoveBar(L["bar_whirlwind"])
	
	self:IntervalBar(L["bar_whirlwindCd"], timer.whirlwindCd[1], timer.whirlwindCd[2], icon.whirlwind, true, color.whirlwindCd)
	self:Message(L["msg_whirlwindFade"], "Attention", false, nil, false)
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Attention", false, nil, false)
end

function module:Berserk()
	self:RemoveBar(L["bar_berserk"])
	self:CancelDelayedMessage(L["msg_berserk60"])
	self:CancelDelayedMessage(L["msg_berserk10"])
	
	self:Message(L["msg_berserk"], "Attention", false, nil, false)
end
