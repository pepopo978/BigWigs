
local module, L = BigWigs:ModuleDeclaration("Patchwerk", "Naxxramas")

module.revision = 30077
module.enabletrigger = module.translatedName
module.toggleoptions = {"enrage", "bosskill"}

module.defaultDB = {
	enrage = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Patchwerk",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	trigger_start1 = "Patchwerk want to play!",
	trigger_start2 = "Kel'Thuzad make Patchwerk his Avatar of War!",
	
	trigger_enrage = "%s becomes enraged!",--CHAT_MSG_MONSTER_EMOTE
	
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 60 seconds",
	msg_enrage10 = "Enrage in 10 seconds",
	msg_enrage = "Enrage!",
} end )


L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Patchwerk",

    enrage_cmd = "enrage",
    enrage_name = "激怒警报",
    enrage_desc = "激怒时进行警告",
	
	trigger_start1 = "帕奇维克想玩！",
	trigger_start2 = "克尔苏加德让帕奇维克成为他的战争化身！",
	
	trigger_enrage = "陷入狂暴状态！",--CHAT_MSG_MONSTER_EMOTE
	
    bar_enrage = "激怒",
    msg_enrage60 = "60秒后激怒",
    msg_enrage10 = "10秒后激怒",
    msg_enrage = "激怒！",
} end )
local timer = {
	enrage = 420,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
}
local syncName = {
	enrage = "PatchwerkEnrage"..module.revision,
}

module:RegisterYellEngage(L["trigger_start1"])
module:RegisterYellEngage(L["trigger_start2"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--enrage
	--self:RegisterEvent("CHAT_MSG_EMOTE", "Event")--test
	
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	self.started = false
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, "White")
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Urgent")
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:Message(L["msg_enrage"], "Important", nil, "Beware")
	self:WarningSign(icon.enrage, 0.7)
end
