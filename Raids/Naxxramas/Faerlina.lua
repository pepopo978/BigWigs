
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
