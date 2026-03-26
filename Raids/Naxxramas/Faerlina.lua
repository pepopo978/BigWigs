
local module, L = BigWigs:ModuleDeclaration("Grand Widow Faerlina", "Naxxramas")

module.revision = 30090
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "sounds", "bigicon", "raidSilence", "poison", "silence", "enrage", "rain", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Faerlina",

	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for silence",

	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon MC and Enrage Alert",
	bigicon_desc = "BigIcon alerts when priest must MC and when the boss goes Enraged",

	sounds_cmd = "sounds",
	sounds_name = "Sound MC and Enrage Alert",
	sounds_desc = "Sound alert when priest must MC and when the boss goes Enraged",
	
	mc_cmd = "mc",
	mc_name = "MC timer bars",
	mc_desc = "Timer bars for Worshipper MindControls",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	rain_cmd = "rain",
	rain_name = "Rain of Fire Alert",
	rain_desc = "Warn when you are standing in Rain of Fire",
	
	raidSilence_cmd = "raidSilence",
	raidSilence_name = "Raid members Silenced Alert",
	raidSilence_desc = "Warn when raid members are silenced",

	poison_cmd = "poison",
	poison_name = "Poison Volley Alert",
	poison_desc = "Warns shamans on Poison Volley",
	
	trigger_start1 = "Kneel before me, worm!",
	trigger_start2 = "Slay them in the master's name!",
	trigger_start3 = "You cannot hide from me!",
	trigger_start4 = "Run while you still can!",

	trigger_rain = "You suffer (.+) Fire damage from Grand Widow Faerlina's Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE --string find cause could be a partial absorb
	trigger_rain2 = "You absorb Grand Widow Faerlina's Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	
	trigger_poison = "is afflicted by Poison Bolt Volley",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	
	trigger_raidSilence = "afflicted by Silence.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_raidSilence = "Raid member Silenced",
	
	trigger_mcGain = "(.+) gains Mind Control.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS // CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS
	trigger_mcGainYou = "You gain Mind Control.",--CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS
	--trigger_mcGain = "Naxxramas Worshipper is afflicted by Mind Control",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	mc_bar = " MC",
	
	trigger_worshipperDies = "Naxxramas Worshipper dies.",--CHAT_MSG_COMBAT_FRIENDLY_DEATH

	trigger_mcFade = "Mind Control fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
	--trigger_mcFade = "Naxxramas Worshipper begins to perform Widow's Embrace",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
	--trigger_mcSuccess = "Widow's Embrace fades from Naxxramas Worshipper.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	--trigger_embrace = "Grand Widow Faerlina gains Widow's Embrace.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_silencedHalf = "Silenced before enrage! next in 30 seconds",
	msg_silenceZero = "Silenced WAY early! No delay on Enrage",
	bar_silence = "Boss Silenced",
	
	trigger_enrage = "Grand Widow Faerlina gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrageGain = "Enrage!",
	bar_enrageGain = "Boss is ENRAGED!",
	
	trigger_enrageFade = "Enrage fades from Grand Widow Faerlina.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_silencedEnrageFull = "Enrage silenced! next in 61 seconds",
	
	msg_enrageSoon = "Enrage in 10 seconds",
	
	bar_enrageCD = "Enrage CD",
	
	trigger_dispel = "(.+) casts Dispel Magic on Naxxramas Worshipper.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
	msg_dispelCast = " Dispelled a Worshipper! Don't Dispel MC!",
} end )

L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Faerlina",

    silence_cmd = "silence",
    silence_name = "沉默警报",
    silence_desc = "沉默出现时进行警告",

    bigicon_cmd = "bigicon",
    bigicon_name = "心灵控制和激怒大图标警报",
    bigicon_desc = "当牧师必须进行心灵控制和Boss进入激怒时显示大图标警报",

    sounds_cmd = "sounds",
    sounds_name = "心灵控制和激怒声音警报",
    sounds_desc = "当牧师必须进行心灵控制和Boss进入激怒时发出声音警报",
    
    mc_cmd = "mc",
    mc_name = "心灵控制计时条",
    mc_desc = "信徒心灵控制的计时条",
    
    enrage_cmd = "enrage",
    enrage_name = "激怒警报",
    enrage_desc = "激怒出现时进行警告",

    rain_cmd = "rain",
    rain_name = "火焰之雨警报",
    rain_desc = "当你站在火焰之雨中时进行警告",
    
    raidSilence_cmd = "raidSilence",
    raidSilence_name = "团队成员沉默警报",
    raidSilence_desc = "当团队成员被沉默时进行警告",

    poison_cmd = "poison",
    poison_name = "毒箭之雨警报",
    poison_desc = "对萨满进行毒箭之雨的警告",
    
	trigger_start1 = "跪下求饶吧，懦夫！",
	trigger_start2 = "以主人之名杀掉他们！",
	trigger_start3 = "休想从我面前逃掉！",
	trigger_start4 = "逃啊！有本事就逃啊！",

    trigger_rain = "你受到了火焰之雨效果的影响。",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE --string find cause could be a partial absorb
    
    trigger_poison = "受到了毒箭之雨效果的影响。",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
    
    trigger_raidSilence = "受到了沉默效果的影响。",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
    bar_raidSilence = "团队成员沉默",
    
    trigger_mcGain = "(.+)受到了精神控制效果的影响。",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS // CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS
    trigger_mcGainYou = "你获得了精神控制的效果。",--CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS
    --trigger_mcGain = "Naxxramas Worshipper is afflicted by Mind Control",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
    mc_bar = "精神控制",
    
    trigger_worshipperDies = "纳克萨玛斯信奉者死亡了。",--CHAT_MSG_COMBAT_FRIENDLY_DEATH

    trigger_mcFade = "精神控制效果从(.+)身上消失了。",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
    --trigger_mcFade = "Naxxramas Worshipper begins to perform Widow's Embrace",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
    --trigger_mcSuccess = "Widow's Embrace fades from Naxxramas Worshipper.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
    --trigger_embrace = "Grand Widow Faerlina gains Widow's Embrace.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
    msg_silencedHalf = "在激怒前沉默！下一个沉默在30秒后",
    msg_silenceZero = "过早沉默！激怒无延迟",
    bar_silence = "Boss沉默",
    
    trigger_enrage = "黑女巫法琳娜获得了激怒的效果。",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
    msg_enrageGain = "激怒！",
    bar_enrageGain = "Boss激怒！",
    
    trigger_enrageFade = "激怒效果从黑女巫法琳娜身上消失了。",--CHAT_MSG_SPELL_AURA_GONE_OTHER
    msg_silencedEnrageFull = "激怒被沉默！下一个激怒在61秒后",
    
    msg_enrageSoon = "激怒将在10秒后到来",
    
    bar_enrageCD = "激怒冷却",
    
    trigger_dispel = "(.+) casts Dispel Magic on Naxxramas Worshipper.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
    msg_dispelCast = "驱散了一个信徒！请勿驱散心灵控制！",
    you = "你",
} end )
local timer = {
	silencedEnrage = 61,
	silencedWithoutEnrage = 30,
	
	silence = 30,
	raidSilence = 8,
	mc = 60,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	silence = "Spell_Holy_Silence",
	rain = "Spell_Shadow_RainOfFire",
	poison = "spell_nature_poisoncleansingtotem",
	mc = "spell_shadow_shadowworddominate",
}
local syncName = {
	enrage = "FaerlinaEnrage"..module.revision,
	enrageFade = "FaerlinaEnrageFade"..module.revision,
	raidSilence = "FaerlinaRaidSilence"..module.revision,
	poison = "FaerlinaPoison"..module.revision,
	mc = "FaerlinaMc"..module.revision,
	mcEnd = "FaerlinaMcEnd"..module.revision,
	worshipperDies = "FaerlinaWorshipperDies"..module.revision,
	dispel = "FaerlinaDispel"..module.revision,
}

local bwWorshipperDiesTime = 0
local bwFaerlinaMcEndTime = 0
local bwFaerlinaEnragedFadedTime = 0
local bwFaerlinaIsEnraged = false
local delayedEnrage = nil

module:RegisterYellEngage(L["trigger_start1"])
module:RegisterYellEngage(L["trigger_start2"])
module:RegisterYellEngage(L["trigger_start3"])
module:RegisterYellEngage(L["trigger_start4"])

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_rain, trigger_rain2, trigger_raidSilence
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_poison, trigger_raidSilence
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_poison, trigger_raidSilence
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Event")--trigger_mcGain
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Event")--trigger_mcGain
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Event")--trigger_mcGainYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_mcFade, trigger_enrageFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_enrage
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "Event")--trigger_dispel
	
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.enrageFade)
	self:ThrottleSync(5, syncName.raidSilence)
	self:ThrottleSync(5, syncName.poison)
	self:ThrottleSync(2, syncName.mc)
	self:ThrottleSync(2, syncName.mcEnd)
	self:ThrottleSync(1, syncName.worshipperDies)
	self:ThrottleSync(1, syncName.dispel)
end

function module:OnSetup()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")--trigger_worshipperDies
end

function module:OnEngage()
	bwWorshipperDiesTime = 0
	bwFaerlinaMcEndTime = 0
	bwFaerlinaEnragedFadedTime = GetTime()
	bwFaerlinaIsEnraged = false
	delayedEnrage = nil
	
	if self.db.profile.enrage then
		self:DelayedMessage(timer.silencedEnrage - 11, L["msg_enrageSoon"], "Urgent", nil, nil)
		self:Bar(L["bar_enrageCD"], timer.silencedEnrage - 1, icon.enrage, true, "red")
	end
	
	if UnitClass("player") == "Priest" and self.db.profile.bigicon then
		self:DelayedWarningSign(timer.silencedEnrage - 12, icon.mc, 0.7)
	end
	if UnitClass("player") == "Priest" and self.db.profile.sounds then
		self:DelayedSound(timer.silencedEnrage - 12, "Info")
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_FRIENDLY_DEATH(msg)
	--DEFAULT_CHAT_FRAME:AddMessage("CHAT_MSG_COMBAT_FRIENDLY_DEATH: "..msg)
	BigWigs:CheckForBossDeath(msg, self) -- don't forget this, we are overriding the default functionality

	if msg == L["trigger_worshipperDies"] then
		self:Sync(syncName.worshipperDies)
	end
end

function module:Event(msg)
	if (msg == L["trigger_rain2"] or string.find(msg, L["trigger_rain"])) and self.db.profile.rain then
		self:Sound("Info")
		self:WarningSign(icon.rain, 2, true, "Move!")
	elseif string.find(msg, L["trigger_poison"]) then
		self:Sync(syncName.poison)
	elseif string.find(msg, L["trigger_raidSilence"]) then
		self:Sync(syncName.raidSilence)
	
	elseif msg == L["trigger_mcGainYou"] then
		self:Sync(syncName.mc.." "..UnitName("Player"))
	elseif string.find(msg, L["trigger_mcGain"]) then
		local _,_, mcGainPriest, _ = string.find(msg, L["trigger_mcGain"])
		self:Sync(syncName.mc.." "..mcGainPriest)
	elseif string.find(msg, L["trigger_mcFade"]) then
		local _,_, mcEndPriest, _ = string.find(msg, L["trigger_mcFade"])
		if mcEndPriest == "you" then mcEndPriest = UnitName("Player") end
		self:Sync(syncName.mcEnd.." "..mcEndPriest)
	
	elseif string.find(msg, L["trigger_enrage"]) then
		self:Sync(syncName.enrage)
	elseif msg == L["trigger_enrageFade"] then
		self:Sync(syncName.enrageFade)
	
	elseif string.find(msg, L["trigger_dispel"]) then
		local _,_, dispeller, _ = string.find(msg, L["trigger_dispel"])
		self:Sync(syncName.dispel.." "..dispeller)
	end
end



function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.poison and self.db.profile.poison then
		self:Poison()
	elseif sync == syncName.raidSilence and self.db.profile.raidSilence then
		self:RaidSilence()
	elseif sync == syncName.mc and rest and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcEnd and rest and self.db.profile.mc then
		self:McEnd(rest)
	elseif sync == syncName.enrage then
		self:Enrage()
	elseif sync == syncName.enrageFade then
		self:EnrageFade()
	elseif sync == syncName.worshipperDies then
		self:WorshipperDies()
	elseif sync == syncName.dispel then
		self:Dispel(rest)
	end
end


function module:Rain()
	self:WarningSign(icon.rain, 10)
	self:Sound("Info")
end

function module:RainFade()
	self:RemoveWarningSign(icon.rain)
end


function module:Poison()
	if UnitClass("player") == "Shaman" then
		self:WarningSign(icon.poison, 0.7)
	end
end

function module:RaidSilence()
	self:Bar(L["bar_raidSilence"], timer.raidSilence, icon.silence, true, "blue")
end

function module:Mc(rest)
	self:Bar(rest..L["mc_bar"], timer.mc, icon.mc, true, "black")
end

function module:McEnd(rest)
	self:RemoveBar(rest..L["mc_bar"])
	
	bwFaerlinaMcEndTime = GetTime()
	self:CheckForSuccess()
end

function module:WorshipperDies()
	bwWorshipperDiesTime = GetTime()
	self:CheckForSuccess()
end

function module:CheckForSuccess()
	--enraged was removed, so don't go through with the code
	if (bwFaerlinaEnragedFadedTime + 5) > GetTime() then return end
	
	--confirm mcFade and worshipperDies within 1sec of each other -> high chance of it being a successful silence
	if ((abs(bwWorshipperDiesTime - bwFaerlinaMcEndTime)) < 1) and bwFaerlinaIsEnraged == false then
		self:Embrace()
	end
end

function module:Embrace()
	--Already did a silence before enrage that was ORE THAN 30, LESS THAN 60sec after silence -->> time to enrage is 30sec
	if delayedEnrage == true and GetTime() < (bwFaerlinaEnragedFadedTime + 30) then
		bwFaerlinaEnragedFadedTime = GetTime()
		delayedEnrage = true
		
		self:RemoveBar(L["bar_enrageGain"])
		self:RemoveBar(L["bar_silence"])
		self:RemoveBar(L["bar_enrageCD"])
		self:CancelDelayedMessage(L["msg_enrageSoon"])
		self:CancelDelayedWarningSign(icon.mc)
		self:CancelDelayedSound("Info")
		
		if self.db.profile.silence then
			self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
			self:Message(L["msg_silencedHalf"], "Urgent")
		end
		
		if self.db.profile.enrage then
			self:Bar(L["bar_enrageCD"], timer.silencedWithoutEnrage, icon.enrage, true, "red")
			self:DelayedMessage(timer.silencedWithoutEnrage - 10, L["msg_enrageSoon"], "Urgent", nil, nil)
		end
		if UnitClass("player") == "Priest" and self.db.profile.bigicon then
			self:DelayedWarningSign(timer.silencedWithoutEnrage - 10, icon.mc, 0.7)
		end
		if UnitClass("player") == "Priest" and self.db.profile.sounds then
			self:DelayedSound(timer.silencedWithoutEnrage - 10, "Info")
		end
		
	--WAY Too Soon, LESS THAN 30sec after silence -->> time to enrage is not changed
	elseif (GetTime() < (bwFaerlinaEnragedFadedTime + 30)) then
		self:RemoveBar(L["bar_enrageGain"])
		self:RemoveBar(L["bar_silence"])
		if self.db.profile.silence then
			self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
			self:Message(L["msg_silenceZero"], "Urgent")
		end

	
	--Too Soon but still silences, MORE THAN 30, LESS THAN 60sec after silence -->> time to enrage is 30sec
	elseif (GetTime() < (bwFaerlinaEnragedFadedTime + 60)) then 
		bwFaerlinaEnragedFadedTime = GetTime()
		delayedEnrage = true
		self:RemoveBar(L["bar_enrageGain"])
		self:RemoveBar(L["bar_silence"])
		self:RemoveBar(L["bar_enrageCD"])
		self:CancelDelayedMessage(L["msg_enrageSoon"])
		self:CancelDelayedWarningSign(icon.mc)
		self:CancelDelayedSound("Info")
		
		if self.db.profile.silence then
			self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
			self:Message(L["msg_silencedHalf"], "Urgent")
		end
		
		if self.db.profile.enrage then
			self:Bar(L["bar_enrageCD"], timer.silencedWithoutEnrage, icon.enrage, true, "red")
			self:DelayedMessage(timer.silencedWithoutEnrage - 10, L["msg_enrageSoon"], "Urgent", nil, nil)
		end
		if UnitClass("player") == "Priest" and self.db.profile.bigicon then
			self:DelayedWarningSign(timer.silencedWithoutEnrage - 10, icon.mc, 0.7)
		end
		if UnitClass("player") == "Priest" and self.db.profile.sounds then
			self:DelayedSound(timer.silencedWithoutEnrage - 10, "Info")
		end
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_silence"])
	self:RemoveBar(L["bar_enrageCD"])
	self:CancelDelayedMessage(L["msg_enrageSoon"])
	self:CancelDelayedWarningSign(icon.mc)
	self:CancelDelayedSound("Info")
	
	bwFaerlinaIsEnraged = true
	delayedEnrage = false
	
	if self.db.profile.enrage then
		self:Message(L["msg_enrageGain"], nil, nil, false)
		self:Bar(L["bar_enrageGain"], timer.silencedEnrage, icon.enrage, true, "red")
		
		if (UnitClass("player") == "Warrior" or UnitClass("player") == "Priest") and self.db.profile.bigicon then
			self:WarningSign(icon.enrage, 0.7)
		end
		if (UnitClass("player") == "Warrior" or UnitClass("player") == "Priest") and self.db.profile.sounds then
			self:Sound("Info")
		end
	end
end

function module:EnrageFade()
	bwFaerlinaEnragedFadedTime = GetTime()
	bwFaerlinaIsEnraged = false
	delayedEnrage = false
	
	--Silence DURING an enrage, -->> time to enrage is 60(61)sec
	self:RemoveBar(L["bar_enrageGain"])
	self:RemoveBar(L["bar_enrageCD"])
	
	if self.db.profile.silence then
		self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
		self:Message(L["msg_silencedEnrageFull"], "Urgent")
	end
	
	if self.db.profile.enrage then
		self:Bar(L["bar_enrageCD"], timer.silencedEnrage, icon.enrage, true, "red")
		self:DelayedMessage(timer.silencedEnrage - 10, L["msg_enrageSoon"], "Urgent", nil, nil)
	end
	if UnitClass("player") == "Priest" and self.db.profile.bigicon then
		self:DelayedWarningSign(timer.silencedEnrage - 10, icon.mc, 0.7)
	end
	if UnitClass("player") == "Priest" and self.db.profile.sounds then
		self:DelayedSound(timer.silencedEnrage - 10, "Info")
	end
end

function module:Dispel(rest)
	self:Message(rest..L["msg_dispelCast"], "Urgent")
end
