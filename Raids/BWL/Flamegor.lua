
local module, L = BigWigs:ModuleDeclaration("Flamegor", "Blackwing Lair")

module.revision = 30085
module.enabletrigger = module.translatedName
module.toggleoptions = {"wingbuffet", "shadowflame", "frenzy", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Flamegor",

	wingbuffet_cmd = "wingbuffet",
	wingbuffet_name = "Wing Buffet Alert",
	wingbuffet_desc = "Warn for Wing Buffet",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame Alert",
	shadowflame_desc = "Warn for Shadow Flame",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",
	
	
	trigger_wingBuffet = "Flamegor begins to cast Wing Buffet.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_wingBuffetCast = "Casting Wing Buffet!",
	bar_wingBuffetCd = "Wing Buffet CD",
	msg_wingBuffetCast = "Casting Wing Buffet!",
	msg_wingBuffetSoon = "Wing Buffet in 2 seconds - Taunt now!",
	
	trigger_shadowFlame = "Flamegor begins to cast Shadow Flame.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_shadowFlameCast = "Casting Shadow Flame!",
	bar_shadowFlameCd = "Shadow Flame CD",
	msg_shadowFlameCast = "Casting Shadow Flame!",
	
	trigger_frenzy = "Flamegor gains Frenzy.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from Flamegor.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_frenzyCd = "Frenzy CD",
	bar_frenzyDur = "Frenzy!",
	msg_frenzy = "Frenzy - Tranq now!",
} end)

local timer = {
	wingBuffetFirstCd = 30,
	wingBuffetCd = 29, --30sec - 1sec cast
	wingBuffetCast = 1,
	
	shadowFlameFirstCd = 16,
	shadowFlameCd = 14, --16 - 2sec cast
	shadowFlameCast = 2,
	
	frenzyCd = 10,
	frenzyDur = 10,
}
local icon = {
	wingBuffet = "INV_Misc_MonsterScales_14",
	shadowFlame = "Spell_Fire_Incinerate",
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",
}
local color = {
	wingBuffetCd = "Cyan",
	wingBuffetCast = "Blue",
	
	shadowFlameCd = "Orange",
	shadowFlameCast = "Red",
	
	frenzyCd = "Black",
	frenzyDur = "Magenta",
}
local syncName = {
	wingBuffet = "FlamegorWingBuffet"..module.revision,
	shadowFlame = "FlamegorShadowflame"..module.revision,
	frenzy = "FlamegorFrenzyStart"..module.revision,
	frenzyFade = "FlamegorFrenzyEnd"..module.revision,
}

local frenzyStartTime = 0
local frenzyEndTime = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_frenzy
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_frenzyFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_wingBuffet, trigger_shadowFlame
	
	
	self:ThrottleSync(3, syncName.wingBuffet)
	self:ThrottleSync(3, syncName.shadowFlame)
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(1, syncName.frenzyFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	frenzyStartTime = 0
	frenzyEndTime = 0
	
	if self.db.profile.wingbuffet then
		self:Bar(L["bar_wingBuffetCd"], timer.wingBuffetFirstCd, icon.wingBuffet, true, color.wingBuffetCd)
		self:DelayedMessage(timer.wingBuffetFirstCd - 2, L["msg_wingBuffetSoon"], "Attention", false, nil, false)
	end
	
	if self.db.profile.shadowflame then
		self:Bar(L["bar_shadowFlameCd"], timer.shadowFlameFirstCd, icon.shadowFlame, true, color.shadowFlameCd)
	end
	
	if self.db.profile.frenzy then
		self:Bar(L["bar_frenzyCd"], timer.frenzyCd, icon.frenzy, true, color.frenzyCd)
	end
end

function module:OnDisengage()
end


function module:Event(msg)
	if msg == L["trigger_wingBuffet"] then
		self:Sync(syncName.wingBuffet)
	
	elseif msg == L["trigger_shadowFlame"] then
		self:Sync(syncName.shadowFlame)
	
	elseif msg == L["trigger_frenzy"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyFade)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.wingBuffet and self.db.profile.wingbuffet then
		self:WingBuffet()
	elseif sync == syncName.shadowFlame and self.db.profile.shadowflame then
		self:ShadowFlame()
	elseif sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyFade and self.db.profile.frenzy then
		self:FrenzyFade()
	end
end


function module:WingBuffet()
	self:CancelDelayedMessage(L["msg_wingBuffetSoon"])
	self:RemoveBar(L["bar_wingBuffetCd"])
	
	self:Bar(L["bar_wingBuffetCast"], timer.wingBuffetCast, icon.wingBuffet, true, color.wingBuffetCast)
	
	self:DelayedBar(timer.wingBuffetCast, L["bar_wingBuffetCd"], timer.wingBuffetCd, icon.wingBuffet, true, color.wingBuffetCd)
	self:DelayedMessage(timer.wingBuffetCast + timer.wingBuffetCd - 2, L["msg_wingBuffetSoon"], "Attention", false, nil, false)
end

function module:ShadowFlame()
	self:RemoveBar(L["bar_shadowFlameCd"])
	
	self:Bar(L["bar_shadowFlameCast"], timer.shadowFlameCast, icon.shadowFlame, true, color.shadowFlameCast)
	self:Message(L["msg_shadowFlameCast"], "Urgent", false, nil, false)
	
	self:DelayedBar(timer.shadowFlameCast, L["bar_shadowFlameCd"], timer.shadowFlameCd, icon.shadowFlame, true, color.shadowFlameCd)
end

function module:Frenzy()
	self:RemoveBar(L["bar_frenzyCd"])
	
	if UnitClass("Player") == "Hunter" then
		self:Message(L["msg_frenzy"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.tranquil, 1)
	end
	
	self:Bar(L["bar_frenzyDur"], timer.frenzyDur, icon.frenzy, true, color.frenzyDur)
	frenzyStartTime = GetTime()
end

function module:FrenzyFade()
	self:RemoveBar(L["bar_frenzyDur"])
	self:RemoveWarningSign(icon.tranquil)
	
	frenzyEndTime = GetTime()
	
	self:Bar(L["bar_frenzyCd"], timer.frenzyCd - (frenzyEndTime - frenzyStartTime), icon.frenzy, true, color.frenzyCd)
end
