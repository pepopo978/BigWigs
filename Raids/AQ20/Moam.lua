
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
