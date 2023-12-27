
local module, L = BigWigs:ModuleDeclaration("BOSS EXACT NAME", "Emerald Sanctum")

module.revision = 30020
module.enabletrigger = module.translatedName
module.toggleoptions = {"ability1", "ability2", "ability3", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Bossname",

	ability1_cmd = "ability1",
	ability1_name = "ability1 Alert",
	ability1_desc = "Warn for ability1",

	ability2_cmd = "ability2",
	ability2_name = "ability2 Alert",
	ability2_desc = "Warn for ability2",
	
	ability3_cmd = "ability3",
	ability3_name = "ability3 Alert",
	ability3_desc = "Warns for ability3",
	
	
	
	
	trigger_ability1 = "trigger_ability1",--CHAT_MSG...
	bar_ability1 = "bar_ability1",
	msg_ability1 = "msg_ability1",
	
	trigger_ability2 = "trigger_ability2",--CHAT_MSG...
	bar_ability2 = "bar_ability1",
	msg_ability2 = "msg_ability1",
	
	trigger_ability3 = "trigger_ability3",--CHAT_MSG_
	bar_ability3 = "bar_ability1",
	msg_ability3 = "msg_ability1",
	
	trigger_person1 = "(.+) is afflicted by Living Bomb.",--CHAT_MSG_
	
	trigger_engage = "I kill you!",--CHAT_MSG_MONSTER_YELL
} end )

local timer = {
	ability1 = 10,
	ability2 = {80,120},
	ability3 = 20,
}
local icon = {
	ability1 = "Spell_Nature_InsectSwarm",
	ability2 = "ability_backstab",
	ability3 = "ability_backstab",
}
local color = {
	ability1 = "White",
	ability2 = "Black",
	ability3 = "Red",
}
local syncName = {
	ability1 = "BossNameAbility1"..module.revision,
	ability2 = "BossNameAbility2"..module.revision,
	ability3 = "BossNameAbility3"..module.revision,
}

module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_", "Event")--trigger_ability1
	self:RegisterEvent("CHAT_MSG_", "Event")--trigger_ability2
	self:RegisterEvent("CHAT_MSG_", "Event")--trigger_ability3
	
	self:ThrottleSync(10, syncName.ability1)
	self:ThrottleSync(10, syncName.ability2)
	self:ThrottleSync(10, syncName.ability3)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.ability1 then
		self:Ability1()
	end
	
	if self.db.profile.ability2 then
		self:IntervalBar(L["bar_ability2"], timer.ability2[1], timer.ability2[2], icon.ability2, true, color.ability2)
	end
	
	if self.db.profile.ability3 then
		self:Bar(L["bar_ability3"], timer.ability3, icon.ability3, true, color.ability3)
		self:Message(L["msg_ability3"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.ability3, 0.7)
		self:DelayedMessage(timer.ability1, L["msg_ability3"], "Urgent", nil, nil, true)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_ability1"] then
		self:Sync(syncName.ability1)
	
	elseif string.find(msg, L["trigger_ability2"]) then
		self:Sync(syncName.ability2)
	
	elseif string.find(msg, L["trigger_ability3"]) then
		local _,_, ability3target, _ = string.find(msg, L["trigger_ability3"])
		self:Sync(syncName.trigger_ability3 .. " " .. ability3target)
		
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.ability1 and self.db.profile.ability1 then
		self:Ability1()
	elseif sync == syncName.ability2 and self.db.profile.ability2 then
		self:Ability2()
	elseif sync == syncName.ability3 and rest and self.db.profile.ability3 then
		self:Ability3(rest)
	end
end


function module:Ability1(rest)
	
end

function module:Ability2()
	self:RemoveBar(L["bar_ability2"])
	
	self:DelayedSync(timer.ability1, syncName.ability3)
end

function module:Ability3(rest)
	if IsRaidLeader() or IsRaidOfficer() then
		TargetByName(rest,true)
		SetRaidTarget("target",8)
		TargetLastTarget()
	end
	
	self:Bar(rest..L["bar_ability3"].. " >Click Me<", timer.ability3, icon.ability3, true, color.ability3)
	self:SetCandyBarOnClick("BigWigsBar "..rest..L["bar_ability3"].. " >Click Me<", function(name, button, extra) TargetByName(extra, true) end, rest)
	self:Message(rest..L["msg_ability3"], "Attention")
end