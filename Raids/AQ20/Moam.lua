
local module, L = BigWigs:ModuleDeclaration("Moam", "Ruins of Ahn'Qiraj")
module.revision = 30076
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "paralyze", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Moam",

	adds_cmd = "adds",
	adds_name = "Mana Fiend Alert",
	adds_desc = "Warn for Mana fiends",

	paralyze_cmd = "paralyze",
	paralyze_name = "Paralyze Alert",
	paralyze_desc = "Warn for Paralyze",


	trigger_start = "%s senses your fear.",
	
	trigger_adds = "drains your mana and turns to stone.",
	bar_adds = "Adds",
	msg_incoming = "Mana Fiends incoming in %s seconds!",
	msg_adds = "Mana Fiends spawned! Moam Paralyzed for 90 seconds!",
	
	trigger_energyzeFade = "Energize fades from Moam.",
	trigger_energyzeFade2 = "bristles with energy",
	bar_paralyse = "Paralyze",
	msg_energizeFadeSoon = "Moam unparalyzed in %s seconds!",
	msg_energizeFade = "Moam unparalyzed! 90 seconds until Mana Fiends!",
} end )


L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Moam",

	adds_cmd = "adds",
    adds_name = "法力恶魔警报",
    adds_desc = "法力恶魔出现时进行警告",

	paralyze_cmd = "paralyze",
    paralyze_name = "麻痹警报",
    paralyze_desc = "麻痹出现时进行警告",


	trigger_start = "%s感觉到了你的恐惧。",
	
	trigger_adds = " 耗尽你的法力并变成石头。",
    bar_adds = "小怪",
    msg_incoming = "法力恶魔即将在 %s 秒内到来！",
    msg_adds = "法力恶魔已出现！莫阿姆麻痹 90 秒！",
	
	trigger_energyzeFade = "充能效果从莫阿姆身上消失",
	trigger_energyzeFade2 = "充满了能量！",
    bar_paralyse = "麻痹",
    msg_energizeFadeSoon = "莫阿姆在 %s 秒后解除麻痹！",
    msg_energizeFade = "莫阿姆解除麻痹！90 秒后出现法力恶魔！",
} end )
local timer = {
	paralyze = 90,
	unparalyze = 90,
}
local icon = {
	paralyze = "Spell_Shadow_CurseOfTounges",
	unparalyze = "Spell_Shadow_CurseOfTounges"
}
local color = {

}
local syncName = {
	paralyze = "MoamParalyze"..module.revision,
	unparalyze = "MoamUnparalyze"..module.revision,
}

local firstunparalyze = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:ThrottleSync(10, syncName.paralyze)
	self:ThrottleSync(10, syncName.unparalyze)
end

function module:OnSetup()
	firstunparalyze = true
end

function module:OnEngage()
	self:Unparalyze()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_adds"]) then
		self:Sync(syncName.paralyze)
	
	elseif string.find( msg, L["trigger_energyzeFade"]) then
		self:Sync(syncName.unparalyze)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.paralyze then
		self:Paralyze()
	elseif sync == syncName.unparalyze then
		self:Unparalyze()
	end
end


function module:Paralyze()
	self:RemoveBar(L["bar_paralyse"])
	self:RemoveBar(L["bar_adds"])
	
	if self.db.profile.adds then
		self:Message(L["msg_adds"], "Important")
	end
	
	if self.db.profile.paralyze then
		self:DelayedMessage(timer.paralyze - 60, format(L["msg_energizeFadeSoon"], 60), "Attention", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 30, format(L["msg_energizeFadeSoon"], 30), "Attention", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 15, format(L["msg_energizeFadeSoon"], 15), "Urgent", nil, nil, true)
		self:DelayedMessage(timer.paralyze - 5, format(L["msg_energizeFadeSoon"], 5), "Important", nil, nil, true)
		self:Bar(L["bar_paralyse"], timer.paralyze, icon.paralyze)
	end
end

function module:Unparalyze()
	self:RemoveBar(L["bar_paralyse"])
	self:RemoveBar(L["bar_adds"])
	
	if firstunparalyze then
		firstunparalyze = false
	elseif self.db.profile.paralyze then
		self:Message(L["msg_energizeFade"], "Important")
	end

	if self.db.profile.adds then
		self:DelayedMessage(timer.unparalyze - 60, format(L["msg_incoming"], 60), "Attention", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 30, format(L["msg_incoming"], 30), "Attention", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 15, format(L["msg_incoming"], 15), "Urgent", nil, nil, true)
		self:DelayedMessage(timer.unparalyze - 5, format(L["msg_incoming"], 5), "Important", nil, nil, true)
		self:Bar(L["bar_adds"], timer.unparalyze, icon.unparalyze)
	end
end
