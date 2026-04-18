
local module, L = BigWigs:ModuleDeclaration("Broodlord Lashlayer", "Blackwing Lair")
local bbbroodlordlashlayer = AceLibrary("Babble-Boss-2.2")["Broodlord Lashlayer"]

module.revision = 30085
module.enabletrigger = module.translatedName
module.toggleoptions = {"ms", "bw", "knock", -1, "targeticon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Broodlord",
	
	ms_cmd = "ms",
	ms_name = "Mortal Strike Alert",
	ms_desc = "Warn for Mortal Strike",

	bw_cmd = "bw",
	bw_name = "Blast Wave Alert",
	bw_desc = "Warn for Blast Wave",
	
	knock_cmd = "knock",
	knock_name = "Knock Away Alert",
	knock_desc = "Warn for Knock Away",
	
	targeticon_cmd = "targeticon",
	targeticon_name = "Skull Icon on Bloodlord's Target",
	targeticon_desc = "Put a Skull Raid Icon on Bloodlord's Target",
	
	
	trigger_engage = "None of your kind should be here! You've doomed only yourselves!",
	
	trigger_msEvade = "Broodlord Lashlayer's Mortal Strike was", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_msEvade = "Mortal Strike was Dodged!",
	
	trigger_msYou = "You are afflicted by Mortal Strike.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_msOther = "(.+) is afflicted by Mortal Strike.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_msFade = "Mortal Strike fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_msCd = "Mortal Strike CD",
	bar_msSoon = "Mortal Strike Soon...",
	bar_msDur = " Mortal Strike",
	msg_ms = " Mortal Strike",
	
	trigger_bw = "Broodlord Lashlayer's Blast Wave", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_bwCd = "Blast Wave CD",
	bar_bwSoon = "Blast Wave Soon...",
	
	trigger_knock = "Broodlord Lashlayer's Knock Away", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_knockCd = "Knock Away CD",
	bar_knockSoon = "Knock Away Soon...",
	you = "you",
	} end )
L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
	cmd = "Broodlord",
	
	ms_cmd = "ms",
	ms_name = "致死打击警报",
	ms_desc = "致死打击出现时进行警告",

	bw_cmd = "bw",
	bw_name = "冲击波警报",
	bw_desc = "冲击波出现时进行警告",

	knock_cmd = "knock",
	knock_name = "击飞警报",
	knock_desc = "击飞出现时进行警告",

	targeticon_cmd = "targeticon",
	targeticon_name = "在BOSS的目标上标记骷髅",
	targeticon_desc = "在BOSS的目标上标记骷髅团队图标",


	trigger_engage = "你们这种人都不应该出现在这里！",
	
	trigger_msEvade = "勒什雷尔的致死打击被", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_msEvade = "致死打击被闪避了！",

	trigger_msYou = "你受到了致死打击效果的影响。", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_msOther = "^(.+)(.+)致死打击效果的影响。", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_msFade = "致死打击效果从(.+)身上消失了。", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_msCd = "致死打击冷却",
	bar_msSoon = "即将致死打击...",
	bar_msDur = " 致死打击",
	msg_ms = " 致死打击",

	trigger_bw = "^(.+)(.+)冲击波效果的影响。", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_bwCd = "冲击波冷却",
	bar_bwSoon = "即将冲击波...",

	trigger_knock = "勒什雷尔的击退击中", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_knockCd = "击飞冷却",
	bar_knockSoon = "即将击飞...",
	you = "你",
} end )

local timer = {
	msFirstCd = 48,--first supposed to be 25, saw 48!?
	msCd = 20,--cd supposed to be {20,30}, saw 26, 27
	msSoon = 10,
	msDur = 5,
	
	bwCd = 20,--first is 20, next are 20 minimum
	bwSoon = 15,--20+15=35, saw 29, 25, 31, supposed to be {20,35}
	
	knockFirstCd = 20,
	knockFirstSoon = 5,
	knockCd = 12,--first is 20-25, next are 12,25
	knockSoon = 13,
}
local icon = {
	ms = "Ability_Warrior_SavageBlow",
	bw = "Spell_Holy_Excorcism_02",
	knock = "INV_Gauntlets_05",
}
local color = {
	msCd = "Black",
	msSoon = "Black",
	msDur = "Magenta",
	
	bwCd = "Orange",
	bwSoon = "Red",
	
	knockCd = "Cyan",
	knockSoon = "Blue",
}
local syncName = {
	ms = "BroodlordMs"..module.revision,
	msFade = "BroodlordMsFade"..module.revision,
	bw = "BroodlordBlastWave"..module.revision,
	knock = "BroodlordKnockAway"..module.revision,
}

module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_msYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_msOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_msOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_msFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_msFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_msFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_bw, trigger_knock, trigger_msEvade
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_bw, trigger_knock, trigger_msEvade
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_bw, trigger_knock, trigger_msEvade
	
	
	self:ThrottleSync(3, syncName.ms)
	self:ThrottleSync(3, syncName.msFade)
	self:ThrottleSync(3, syncName.bw)
	self:ThrottleSync(3, syncName.knock)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.ms then
		self:Bar(L["bar_msCd"], timer.msFirstCd, icon.ms, true, color.msCd)
	end
	
	if self.db.profile.bw then
		self:Bar(L["bar_bwCd"], timer.bwCd, icon.bw, true, color.bwCd)
	end
	
	if self.db.profile.knock then
		self:Bar(L["bar_knockCd"], timer.knockFirstCd, icon.knock, true, color.knockCd)
		self:DelayedBar(timer.knockFirstCd, L["bar_knockSoon"], timer.knockFirstSoon, icon.knock, true, color.knockSoon)
	end
	
	if self.db.profile.targeticon then
		self:ScheduleRepeatingEvent("BroodlordTargetCheck", self.BroodlordTarget, 0.5, self)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("BroodlordTargetCheck")
end

function module:BroodlordTarget()
	if UnitName("Target") ~= nil and UnitName("TargetTarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("Target") == bbbroodlordlashlayer then
			SetRaidTarget("TargetTarget",8)
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_msYou"] then
		self:Sync(syncName.ms .. " "..UnitName("player"))
	
	elseif string.find(msg, L["trigger_msOther"]) then
		local _,_,msPerson, _ = string.find(msg, L["trigger_msOther"])
		self:Sync(syncName.ms .. " "..msPerson)
	
	elseif string.find(msg, L["trigger_msFade"]) then
		local _,_,msFadePerson, _ = string.find(msg, L["trigger_msFade"])
		if msFadePerson == L["you"] then msFadePerson = UnitName("Player") end
		self:Sync(syncName.msFade .. " "..msFadePerson)
		
	elseif string.find(msg, L["trigger_msEvade"]) then
		self:Sync(syncName.ms .. " ".."msEvade")
	

	elseif string.find(msg, L["trigger_bw"]) then
		self:Sync(syncName.bw)
		
	elseif string.find(msg, L["trigger_knock"]) then
		self:Sync(syncName.knock)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.ms and rest and self.db.profile.ms then
		self:Ms(rest)
	elseif sync == syncName.msFade and rest and self.db.profile.ms then
		self:MsFade(rest)
	
	elseif sync == syncName.bw and self.db.profile.bw then
		self:BW()
		
	elseif sync == syncName.knock and self.db.profile.knock then
		self:Knock()
	end
end


function module:Ms(rest)
	self:CancelDelayedBar(L["bar_msSoon"])
	self:RemoveBar(L["bar_msSoon"])
	self:RemoveBar(L["bar_msCd"])
	
	if rest ~= "msEvade" then
		self:Bar(rest..L["bar_msDur"], timer.msDur, icon.ms, true, color.msDur)
		self:Message(rest..L["msg_ms"], "Urgent", false, nil, false)
	
		self:DelayedBar(timer.msDur, L["bar_msCd"], timer.msCd, icon.ms, true, color.msCd)
		self:DelayedBar(timer.msDur + timer.msCd, L["bar_msSoon"], timer.msSoon, icon.ms, true, color.msSoon)
	else
		self:Message(L["msg_msEvade"], "Urgent", false, nil, false)
	
		self:Bar(L["bar_msCd"], timer.msDur + timer.msCd, icon.ms, true, color.msCd)
		self:DelayedBar(timer.msDur + timer.msCd, L["bar_msSoon"], timer.msSoon, icon.ms, true, color.msSoon)
	end
end

function module:MsFade(rest)
	self:RemoveBar(rest..L["bar_msDur"])
end

function module:BW()
	self:CancelDelayedBar(L["bar_bwSoon"])
	self:RemoveBar(L["bar_bwSoon"])
	
	self:Bar(L["bar_bwCd"], timer.bwCd, icon.bw, true, color.bwCd)
	self:DelayedBar(timer.bwCd, L["bar_bwSoon"], timer.bwSoon, icon.bw, true, color.bwSoon)
end

function module:Knock()
	self:CancelDelayedBar(L["bar_knockSoon"])
	self:RemoveBar(L["bar_knockSoon"])
	
	self:Bar(L["bar_knockCd"], timer.knockCd, icon.knock, true, color.knockCd)
	self:DelayedBar(timer.knockCd, L["bar_knockSoon"], timer.knockSoon, icon.knock, true, color.knockSoon)
end
