
local module, L = BigWigs:ModuleDeclaration("Anubisath Warder", "Ahn'Qiraj")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = {"fear", "silence", "roots", "dust", "warnings"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Warder",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warns for Fear",

	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warns for Silence",

	roots_cmd = "roots",
	roots_name = "Roots Alert",
	roots_desc = "Warns for Roots",

	dust_cmd = "dust",
	dust_name = "Dust Cloud Alert",
	dust_desc = "Warns for Dust Cloud",

	warnings_cmd = "warnings",
	warnings_name = "Warnings for 2nd Ability",
	warnings_desc = "Warnings for what the 2nd Ability will be.",

	
	trigger_fear = "Anubisath Warder begins to cast Fear.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fearCast = "Fear!",
	bar_fearCd = "Fear CD",

	trigger_silence = "Anubisath Warder begins to cast Silence.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_silenceCast = "Silence!",
	bar_silenceCd = "Silence CD",

	trigger_roots = "Anubisath Warder begins to cast Entangling Roots.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_rootsCast = "Roots!",
	bar_rootsCd = "Roots CD",

	trigger_dust = "Anubisath Warder begins to perform Dust Cloud.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_dustCast = "Dust Cloud!",
	bar_dustCd = "Dust Cloud CD",
	
	msg_foundFear = "Fear - Next ability is Silence or Dust", --can't be Roots
	msg_foundSilence = "Silence - Next ability is Roots or Fear", --can't be Dust
	msg_foundRoots = "Roots - Next ability is Silence or Dust", --can't be Fear
	msg_foundDust = "Dust - Next ability is Roots or Fear", --can't be Silence
} end )


L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Warder",

    fear_cmd = "fear",
    fear_name = "恐惧警报",
    fear_desc = "恐惧出现时进行警告",

    silence_cmd = "silence",
    silence_name = "沉默警报",
    silence_desc = "沉默出现时进行警告",

    roots_cmd = "roots",
    roots_name = "缠绕根须警报",
    roots_desc = "缠绕根须出现时进行警告",

    dust_cmd = "dust",
    dust_name = "尘雾之云警报",
    dust_desc = "尘雾之云出现时进行警告",

    warnings_cmd = "warnings",
    warnings_name = "第二技能警告",
    warnings_desc = "警告第二技能可能为何。",

	
    trigger_fear = "Anubisath Warder begins to cast Fear.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_fearCast = "恐惧！",
    bar_fearCd = "恐惧 CD",

    trigger_silence = "Anubisath Warder begins to cast Silence.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_silenceCast = "沉默！",
    bar_silenceCd = "沉默 CD",

    trigger_roots = "Anubisath Warder begins to cast Entangling Roots.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_rootsCast = "缠绕根须！",
    bar_rootsCd = "缠绕根须 CD",

    trigger_dust = "Anubisath Warder begins to perform Dust Cloud.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_dustCast = "尘雾之云！",
    bar_dustCd = "尘雾之云 CD",
    
    msg_foundFear = "恐惧 - 下一个技能可能是沉默或尘雾之云", --can't be Roots
    msg_foundSilence = "沉默 - 下一个技能可能是缠绕根须或恐惧", --can't be Dust
    msg_foundRoots = "缠绕根须 - 下一个技能可能是沉默或尘雾之云", --can't be Fear
    msg_foundDust = "尘雾之云 - 下一个技能可能是缠绕根须或恐惧", --can't be Silence
} end )
local timer = {
	fearCd = {15,20}, --saw 15.4, 17.2, 20.5
	fearCast = 1.5,
	
	silenceCd = {11.5,27.2}, --saw 11.5, 27.2
	silenceCast = 1.5,
	
	rootsCd = {16,16},--saw 16
	rootsCast = 1.5,
	
	dustCd = {15,19}, --saw 16.8
	dustCast = 1.5,
}
local icon = {
	fear = "Spell_Shadow_Possession",
	silence = "Spell_Holy_Silence",
	roots = "Spell_Nature_StrangleVines",
	dust = "Ability_Hibernation",
}
local color = {
	fear = "Blue",
	silence = "Red",
	roots = "Green",
	dust = "White",
}
local syncName = {
	fear = "WarderFear"..module.revision,
	silence = "WarderSilence"..module.revision,
	roots = "WarderRoots"..module.revision,
	dust = "WarderDust"..module.revision,
}

local firstAbilityFound = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(3, syncName.fear)
	self:ThrottleSync(3, syncName.silence)
	self:ThrottleSync(3, syncName.roots)
	self:ThrottleSync(3, syncName.dust)
end

function module:OnSetup()
end

function module:OnEngage()
	 firstAbilityFound = nil
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_fear"] then
		self:Sync(syncName.fear)
	
	elseif msg == L["trigger_silence"] then
		self:Sync(syncName.silence)
	
	elseif msg == L["trigger_roots"] then
		self:Sync(syncName.roots)
	
	elseif msg == L["trigger_dust"] then
		self:Sync(syncName.dust)
	end
end


function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	elseif sync == syncName.silence and self.db.profile.silence then
		self:Silence()
	elseif sync == syncName.roots and self.db.profile.roots then
		self:Roots()
	elseif sync == syncName.dust and self.db.profile.dust then
		self:Dust()
	end
end


function module:Fear()
	self:RemoveBar(L["bar_fearCd"])
	
	self:Bar(L["bar_fearCast"], timer.fearCast, icon.fear, true, color.fear)
	self:DelayedIntervalBar(timer.fearCast, L["bar_fearCd"], timer.fearCd[1] - timer.fearCast, timer.fearCd[2] - timer.fearCast, icon.fear, true, color.fear)
	
	if firstAbilityFound == nil and self.db.profile.warnings then
		self:AbilityWarn("Fear")
	end
end

function module:Silence()
	self:RemoveBar(L["bar_silenceCd"])
	
	self:Bar(L["bar_silenceCast"], timer.silenceCast, icon.silence, true, color.silence)
	self:DelayedIntervalBar(timer.silenceCast, L["bar_silenceCd"], timer.silenceCd[1] - timer.silenceCast, timer.silenceCd[2] - timer.silenceCast, icon.silence, true, color.silence)
	
	if firstAbilityFound == nil and self.db.profile.warnings then
		self:AbilityWarn("Silence")
	end
end

function module:Roots()
	self:RemoveBar(L["bar_rootsCd"])
	
	self:Bar(L["bar_rootsCast"], timer.rootsCast, icon.roots, true, color.roots)
	self:DelayedIntervalBar(timer.rootsCast, L["bar_rootsCd"], timer.rootsCd[1] - timer.rootsCast, timer.rootsCd[2] - timer.rootsCast, icon.roots, true, color.roots)
	
	if firstAbilityFound == nil and self.db.profile.warnings then
		self:AbilityWarn("Roots")
	end
end

function module:Dust()
	self:RemoveBar(L["bar_dustCd"])
	
	self:Bar(L["bar_dustCast"], timer.dustCast, icon.dust, true, color.dust)
	self:DelayedIntervalBar(timer.dustCast, L["bar_dustCd"], timer.dustCd[1] - timer.dustCast, timer.dustCd[2] - timer.dustCast, icon.dust, true, color.dust)
	
	if firstAbilityFound == nil and self.db.profile.warnings then
		self:AbilityWarn("Dust")
	end
end


function module:AbilityWarn(ability)
	firstAbilityFound = true
	if ability == "Fear" then
		self:Message(L["msg_foundFear"], Important, false, nil, false)
	elseif ability == "Silence" then
		self:Message(L["msg_foundSilence"], Important, false, nil, false)
	elseif ability == "Roots" then
		self:Message(L["msg_foundRoots"], Important, false, nil, false)
	elseif ability == "Dust" then
		self:Message(L["msg_foundDust"], Important, false, nil, false)
	end
end
