
local module, L = BigWigs:ModuleDeclaration("Gluth", "Naxxramas")

module.revision = 30072
module.enabletrigger = module.translatedName
module.toggleoptions = {"frenzy", "fear", "decimate", "enrage", "zombies", "wound", -1, "bosskill"}

local _, englishClass = UnitClass("player");

module.defaultDB = {
	enrage = false,
	frenzy = englishClass == "HUNTER",
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gluth",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for fear",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for frenzy",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Timer",
	enrage_desc = "Warn for Enrage",

	decimate_cmd = "decimate",
	decimate_name = "Decimate Alert",
	decimate_desc = "Warn for Decimate",
	
	zombies_cmd = "zombies",
	zombies_name = "Zombie Spawn",
	zombies_desc = "Shows timer for zombies",
	
	wound_cmd = "wound",
	wound_name = "Mortal Wounds Alert",
	wound_desc = "Warn for Mortal Wounds",
	
	
	trigger_frenzyGain = "Gluth gains Frenzy.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from Gluth.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_frenzy = "Frenzy - Tranq!",
	bar_frenzyGain = "Frenzy - Tranq!",
	bar_frenzyCD = "Frenzy CD",
	
	trigger_enrage = "Gluth gains Berserk.",--to be confirmed
	msg_enrage60 = "Enrage in 60 seconds",
	msg_enrage10 = "Enrage in 10 seconds",
	msg_enrage = "Enrage!",
	bar_enrage = "Enrage",
		
	trigger_decimate = "Decimate hits",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_decimate = "Decimate!",
	msg_decimate5 = "Decimate in 5",
	bar_decimate = "Decimate",
	
	bar_zombies = "Next Zombie - %d",
		
	trigger_fear = "afflicted by Terrifying Roar",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fearCD = "Fear CD",
	msg_fear = "Fear!",
	
	trigger_woundYou = "You are afflicted by Mortal Wound %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_woundOther = "(.+) is afflicted by Mortal Wound %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_wound = " Wounds",
} end )

local timer = {
	decimate = 105,
	zombie = 6,
	enrage = 330,
	firstfear = 20,
	fear = 20,
	frenzy = 10,
	wound = 15,
}
local icon = {
	zombie = "Ability_Seal",
	enrage = "Spell_Shadow_UnholyFrenzy",
	fear = "Spell_Shadow_PsychicScream",
	decimate = "INV_Shield_01",
	tranquil = "Spell_Nature_Drowsy",
	frenzy = "Ability_Druid_ChallangingRoar",
	wound = "ability_criticalstrike",
}
local color = {
	zombie = "Green",
	enrage = "Cyan",
	fear = "Blue",
	decimate = "Black",
	frenzyGain = "Red",
	frenzyCd = "White",
	wound = "Magenta",
}
local syncName = {
	frenzy = "GluthFrenzyStart"..module.revision,
	frenzyOver = "GluthFrenzyEnd"..module.revision,
	
	enrage = "GluthEnrage"..module.revision,
	decimate = "GluthDecimate"..module.revision,
	fear = "GluthFear"..module.revision,
	wound = "GluthWound"..module.revision,
}

local lastFrenzy = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_frenzyGain
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_frenzyFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_decimate, trigger_fear
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_decimate
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_decimate
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_fear, trigger_woundOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_fear, trigger_woundOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_fear, trigger_woundYou
	
	
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(1, syncName.frenzyOver)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.decimate)
	self:ThrottleSync(5, syncName.fear)
	self:ThrottleSync(3, syncName.wound)
end

function module:OnSetup()
	self.started = nil
	self.zomnum = 1
	lastFrenzy = 0
end

function module:OnEngage()
	if self.db.profile.frenzy then
		self:Bar(L["bar_frenzyCD"], timer.frenzy, icon.frenzy, true, color.frenzyCd)
	end
	
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, color.enrage)
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Important", false, nil, false)
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important", false, nil, false)
	end
	
	if self.db.profile.decimate then
		self:Bar(L["bar_decimate"], timer.decimate, icon.decimate, true, color.decimate)
		self:DelayedMessage(timer.decimate - 5, L["msg_decimate5"], "Urgent", false, nil, false)
	end
	
	if self.db.profile.fear then
		self:Bar(L["bar_fearCD"], timer.firstfear, icon.fear, true, color.fear)
	end
	
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, color.zombie)
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_frenzyGain"] then
		self:Sync(syncName.frenzy)
	
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyOver)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_decimate"]) then
		self:Sync(syncName.decimate)
	
	elseif string.find(msg, L["trigger_fear"]) then
		self:Sync(syncName.fear)
		
	elseif string.find(msg, L["trigger_woundYou"]) then
		local _,_,woundQty,_ = string.find(msg, L["trigger_woundYou"])
		local woundPlayer = UnitName("Player")
		local woundPlayerAndWoundQty = woundPlayer .. " " .. woundQty
		self:Sync(syncName.wound.." "..woundPlayerAndWoundQty)
		
	elseif string.find(msg, L["trigger_woundOther"]) then
		local _,_,woundPlayer,woundQty = string.find(msg, L["trigger_woundOther"])
		local woundPlayerAndWoundQty = woundPlayer .. " " .. woundQty
		self:Sync(syncName.wound.." "..woundPlayerAndWoundQty)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:FrenzyOver()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.decimate then
		self:Decimate()
	elseif sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	elseif sync == syncName.wound and rest and self.db.profile.wound then
		self:Wound(rest)
	end
end


function module:Frenzy()
	self:Message(L["msg_frenzy"], "Attention", false, nil, false)
	self:Sound("Alert")
	self:Bar(L["bar_frenzyGain"], timer.frenzy, icon.frenzy, true, color.frenzyGain)
	lastFrenzy = GetTime()
	
	if UnitClass("Player") == "Hunter" then
		self:WarningSign(icon.tranquil, timer.frenzy)
	end
end

function module:FrenzyOver()
	self:RemoveBar(L["bar_frenzyGain"])
	self:RemoveWarningSign(icon.tranquil)
	
	if lastFrenzy ~= 0 then
		local NextTime = (lastFrenzy + timer.frenzy) - GetTime()
		self:Bar(L["bar_frenzyCD"], NextTime, icon.frenzy, true, color.frenzyCd)
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:WarningSign(icon.enrage, 0.7)
	self:Sound("Info")
end

function module:Decimate()
	if self.db.profile.decimate then
		self:RemoveBar(L["bar_decimate"])
		self:Bar(L["bar_decimate"], timer.decimate, icon.decimate, true, color.decimate)
		self:DelayedMessage(timer.decimate - 5, L["msg_decimate5"], "Urgent", false, nil, false)
		self:Sound("Beware")
	end
	
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, color.zombie)
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
end

function module:Fear()
	self:Bar(L["bar_fearCD"], timer.fear, icon.fear, true, color.fear)
end

function module:Zombies()
	self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, color.zombie)

	if self.zomnum <= 10 then
		self.zomnum = self.zomnum + 1
	elseif self.zomnum > 10 then
		self:CancelScheduledEvent("Zombies")
		self:RemoveBar(string.format(L["bar_zombies"], self.zomnum ))
		self.zomnum = 1
	end
end

function module:Zombie()
	self:ScheduleRepeatingEvent("Zombies", self.Zombies, timer.zombie, self)
end

function module:Wound(rest)
	local woundPlayer = strsub(rest,0,strfind(rest," ") - 1)
	local woundQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
	
	self:RemoveBar(woundPlayer.." ".."1"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."2"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."3"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."4"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."5"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."6"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."7"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."8"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."9"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."10"..L["bar_wound"])

	self:Bar(woundPlayer.." "..woundQty..L["bar_wound"], timer.wound, icon.wound, true, color.wound)
end
