
local module, L = BigWigs:ModuleDeclaration("Ancient Core Hound", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"bars"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Corehound",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",
	
	
	trigger_debuff = "afflicted by (.+) ", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_debuffFail = "Ancient Core Hound's (.+) fails.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_debuffResist = "Ancient Core Hound's (.+) was resisted by", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_debuff = "Debuff",
	
	msg_ancientDread = "Ancient Dread - Dispel!",
	
	bar_ancientDespair = "Disorient",
	
	bar_groundStomp = "Ground Stomp",
	
	msg_cauterizingFlames = "Cauterizing Flames - Dispel!",
	
	msg_witheringHeat = "Withering Heat - Dispel!",
	
	msg_ancientHysteria = "Ancient Hysteria - Decurse!",

	s_ancientdread = "Ancient Dread",
	s_ancientdespair = "Ancient Despair",
	s_groundstomp = "Ground Stomp",
	s_cauterizingflames = "Cauterizing Flames",
	s_witheringheat = "Withering Heat",
	s_ancienthysteria = "Ancient Hysteria",
} end )
L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Corehound",

    bars_cmd = "bars",
    bars_name = "切换计时条",
    bars_desc = "切换显示计时条的状态。",


	trigger_debuff = "你受到了(.+)效果的影响。", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_debuffFail = ".*的(.+)施放失败。", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_debuffResist = ".*的(.+)被.*抵抗了。", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_debuff = "Debuff",

    msg_ancientDread = "上古恐慌 - 驱散！",

    bar_ancientDespair = "迷惑",

    bar_groundStomp = "大地践踏",

    msg_cauterizingFlames = "灼烧之焰 - 驱散！",

    msg_witheringHeat = "枯萎热浪 - 驱散！",

    msg_ancientHysteria = "上古狂乱 - 解除诅咒！",

    s_ancientdread = "上古恐慌",
    s_ancientdespair = "上古绝望",
    s_groundstomp = "大地践踏",
    s_cauterizingflames = "灼烧之焰",
    s_witheringheat = "枯萎热浪",
    s_ancienthysteria = "上古狂乱",
} end )

local timer = {
	debuffFirst = 12,
	debuff = 14,

	ancientDespair = 5,
	groundStomp = 5,
}
local icon = {
	debuff = "Spell_Shadow_UnholyFrenzy",

	ancientDread = "spell_shadow_curseoftounges",
	ancientDespair = "spell_shadow_mindsteal",
	groundStomp = "ability_warstomp",
	cauterizingFlames = "spell_fire_volcano",
	witheringHeat = "spell_fire_fire",
	ancientHysteria = "spell_shadow_unholyfrenzy",
}
local color = {
	debuff = "White",
	ancientDespair = "Red",
	groundStomp = "Orange",
}
local syncName = {
	debuff = "CoreHoundDebuff2"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_debuff
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_debuff
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_debuff

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_debuffFail
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_debuffFail, trigger_debuffResist
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_debuffFail, trigger_debuffResist


	self:ThrottleSync(2, syncName.debuff)
end

function module:OnSetup()
	self.started = false
end

function module:OnEngage()
	if self.db.profile.bars then
		self:Bar(L["bar_debuff"], timer.debuffFirst, icon.debuff, true, color.debuff)
	end
end

function module:OnDisengage()

end

local function IsTrackedDebuff(name)
	return name == L["s_ancientdread"]
		or name == L["s_ancientdespair"]
		or name == L["s_groundstomp"]
		or name == L["s_cauterizingflames"]
		or name == L["s_witheringheat"]
		or name == L["s_ancienthysteria"]
end

function module:Event(msg)
	if string.find(msg, L["trigger_debuff"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuff"])
		if IsTrackedDebuff(debuff) then
			self:Sync(syncName.debuff .. " " .. debuff)
		end

	elseif string.find(msg, L["trigger_debuffFail"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuffFail"])
		if IsTrackedDebuff(debuff) then
			self:Sync(syncName.debuff .. " " .. debuff)
		end

	elseif string.find(msg, L["trigger_debuffResist"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuffResist"])
		if IsTrackedDebuff(debuff) then
			self:Sync(syncName.debuff .. " " .. debuff)
		end
	end
end


function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.debuff and rest and self.db.profile.bars then
		self:Debuff(rest)
	end
end


function module:Debuff(rest)
	self:RemoveBar(L["bar_debuff"])

	if rest == L["s_ancientdread"] then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_ancientDread"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.ancientDread, 1)
		end

	elseif rest == L["s_ancientdespair"] then
		self:Bar(L["bar_ancientDespair"], timer.ancientDespair, icon.ancientDespair, true, color.ancientDespair)
		self:WarningSign(icon.ancientDespair, 1)
		self:DelayedBar(timer.ancientDespair, L["bar_debuff"], timer.debuff - timer.ancientDespair, icon.debuff, true, color.debuff)

	elseif rest == L["s_groundstomp"] then
		self:Bar(L["bar_groundStomp"], timer.groundStomp, icon.groundStomp, true, color.groundStomp)
		self:WarningSign(icon.groundStomp, 1)
		self:DelayedBar(timer.groundStomp, L["bar_debuff"], timer.debuff - timer.groundStomp, icon.debuff, true, color.debuff)

	elseif rest == L["s_cauterizingflames"] then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_cauterizingFlames"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.cauterizingFlames, 1)
		end

	elseif rest == L["s_witheringheat"] then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_witheringHeat"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.witheringHeat, 1)
		end

	elseif rest == L["s_ancienthysteria"] then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
			self:Message(L["msg_ancientHysteria"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.ancientHysteria, 1)
		end
	end
end
