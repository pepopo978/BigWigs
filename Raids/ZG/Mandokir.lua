
local module, L = BigWigs:ModuleDeclaration("Bloodlord Mandokir", "Zul'Gurub")

module.revision = 30078
module.enabletrigger = module.translatedName
module.wipemobs = {"Ohgan"}
module.toggleoptions = {"gaze", "cancelaction", -1, "whirlwind", "charge", "enrage", "sunder", -1, "levelup", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Mandokir",
	
	gaze_cmd = "gaze",
	gaze_name = "Threatening Gaze Alert",
	gaze_desc = "Warn for Threatening Gaze",
	
	cancelaction_cmd = "cancelaction",
	cancelaction_name = "Auto-Cancel all actions on Gaze",
	cancelaction_desc = "Automatically cancel all actions when you get Threatening Gaze",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind Alert",
	whirlwind_desc = "Warn for Whirlwind",
	
	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn for Charge",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	sunder_cmd = "sunder",
	sunder_name = "Sunder Alert",
	sunder_desc = "Warn for Sunder",
	
	levelup_cmd = "levelup",
	levelup_name = "Level Up Alert",
	levelup_desc = "Warn for Level Up",
	
	
	trigger_engage = "I'll feed your souls to Hakkar himself!", --CHAT_MSG_MONSTER_YELL
	
	trigger_gaze = "(.+)! I'm watching you!", --CHAT_MSG_MONSTER_YELL
	trigger_gazeFade = "Threatening Gaze fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_gazeCd = "Threatening Gaze CD",
	bar_gazeDur = " Gaze!",
	msg_gaze = "Threatening Gaze - Stop all Actions ",
	
	trigger_whirlwind = "Bloodlord Mandokir gains Whirlwind.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_whirlwindCd = "Whirlwind CD",
	bar_whirlwindCast = "Casting Whirlwind!",
	
	trigger_charge = "Bloodlord Mandokir's Charge", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_chargeCd = "Charge CD",
	
	
	trigger_enrage = "Bloodlord Mandokir gains Enrage.", --guessing CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_enrageFade = "Enrage fades from Bloodlord Mandokir.", --guessing CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_enrage = "Enrage",
	msg_enrage = "You killed Ohgan - Mandokir is Enraged!",
	msg_enrageFade = "Mandokir is no longer Enraged!",
	
	trigger_sunderYou = "You are afflicted by Sunder Armor %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_sunderOther = "(.+) is afflicted by Sunder Armor %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_sunder = " Sunders",
	msg_sunderHigh = " Sunder Stacks - Seek Replacement!",
	
	trigger_levelUp = "DING!", --CHAT_MSG_MONSTER_YELL
	msg_levelUp = "Mandokir Leveled Up by killing someone - He is now Level "
} end )

local timer = {
	gazeFirstCd = 33,
	gazeCd = 12,
	gazeDur = 8, --2sec cast + 6sec dur
	
	whirlwindFirstCd = 20,
	whirlwindCast = 2,
	whirlwindCd = 18,
	
	chargeFirstCd = 15.8,
	chargeCd = {30,35},
	
	enrage = 90,
	
	sunder = 20,
}
local icon = {
	gaze = "Spell_Shadow_Charm",
	whirlwind = "Ability_Whirlwind",
	charge = "Ability_Warrior_Charge",
	enrage = "Spell_Shadow_UnholyFrenzy",
	sunder = "ability_warrior_sunder",
}
local color = {
	gazeCd = "Orange",
	gazeDur = "Red",
	
	whirlwindCd = "Cyan",
	whirlwindCast = "Blue",
	
	chargeCd = "White",
	
	enrage = "Green",
	
	sunder = "Black"
}
local syncName = {
	gaze = "MandokirGaze2"..module.revision,
	gazeFade = "MandokirGazeEnd2"..module.revision,
	
	whirlwind = "MandokirWWStart"..module.revision,

	charge = "MandokirCharge"..module.revision,
	
	enrage = "MandokirEnrageStart"..module.revision,
	enrageFade = "MandokirEnrageEnd"..module.revision,
	
	sunder = "MandokirSunder"..module.revision,
}

local fightningMandokir = nil
local bossLevel = 63

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_gaze
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_gazeFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_gazeFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_gazeFade, trigger_enrageFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_whirlwind, trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_sunderYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_sunderOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_sunderOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_charge
	
	
	self:ThrottleSync(5, syncName.gaze)
	self:ThrottleSync(5, syncName.gazeFade)
	
	self:ThrottleSync(5, syncName.whirlwind)
	
	self:ThrottleSync(5, syncName.charge)
	
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.enrageFade)
	
	self:ThrottleSync(1, syncName.sunder)
end

function module:OnSetup()
end

function module:OnEngage()
	fightningMandokir = true
	bossLevel = 63
	
	if self.db.profile.gaze then
		self:Bar(L["bar_gazeCd"], timer.gazeFirstCd, icon.gaze, true, color.gazeCd)
	end
	
	if self.db.profile.whirlwind then
		self:Bar(L["bar_whirlwindCd"], timer.whirlwindFirstCd, icon.whirlwind, true, color.whirlwindCd)
	end
	
	if self.db.profile.charge then
		self:Bar(L["bar_chargeCd"], timer.chargeFirstCd, icon.charge, true, color.chargeCd)
	end
end

function module:OnDisengage()
	fightningMandokir = nil
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	
	elseif string.find(msg, L["trigger_gaze"]) then
		local _,_,gazePlayer,_ = string.find(msg, L["trigger_gaze"])
		self:Sync(syncName.gaze .. " " .. gazePlayer)
		
	elseif msg == L["trigger_levelUp"] and self.db.profile.levelup then
		bossLevel = bossLevel + 1
		self:Message(L["msg_levelUp"]..bossLevel)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_gazeFade"]) then
		local _,_,gazeFadePlayer,_ = string.find(msg, L["trigger_gazeFade"])
		if gazeFadePlayer == "you" then gazeFadePlayer = UnitName("Player") end
		self:Sync(syncName.gazeFade .. " " .. gazeFadePlayer)
	
	elseif msg == L["trigger_whirlwind"] then
		self:Sync(syncName.whirlwind)

	elseif string.find(msg, L["trigger_charge"]) then
		self:Sync(syncName.charge)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	elseif msg == L["trigger_enrageFade"] then
		self:Sync(syncName.enrageFade)

	elseif string.find(msg, L["trigger_sunderYou"]) and fightningMandokir then
		local _,_,sunderQty,_ = string.find(msg, L["trigger_sunderYou"])
		local sunderPlayer = UnitName("Player")
		local sunderPlayerAndSunderQty = sunderPlayer .. " " .. sunderQty
		self:Sync(syncName.sunder.." "..sunderPlayerAndSunderQty)
		
	elseif string.find(msg, L["trigger_sunderOther"]) and fightningMandokir then
		local _,_,sunderPlayer,sunderQty = string.find(msg, L["trigger_sunderOther"])
		if sunderPlayer ~= "Bloodlord Mandokir" and sunderPlayer ~= "Ohgan" then
			local sunderPlayerAndSunderQty = sunderPlayer .. " " .. sunderQty
			self:Sync(syncName.sunder.." "..sunderPlayerAndSunderQty)
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.gaze and rest and self.db.profile.gaze then
		self:Gaze(rest)
	elseif sync == syncName.gazeFade and rest and self.db.profile.gaze then
		self:GazeFade(rest)
	
	elseif sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
	
	elseif sync == syncName.charge and self.db.profile.charge then
		self:Charge()
		
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.enrageFade and self.db.profile.enrage then
		self:EnrageFade()
	
	
	elseif sync == syncName.sunder and rest and self.db.profile.sunder then
		self:Sunder(rest)
	end
end


function module:Gaze(rest)
	self:RemoveBar(L["bar_gazeCd"])
	
	self:Bar(rest..L["bar_gazeDur"], timer.gazeDur, icon.gaze, true, color.gazeDur)
	self:Message(L["msg_gaze"]..rest, "Urgent", false, nil, false)
	
	if rest == UnitName("Player") then
		self:Sound("Beware")
		self:WarningSign(icon.gaze, timer.gazeDur)
		SendChatMessage("Threatening Gaze on "..UnitName("Player").." !", "SAY")
		
		if self.db.profile.cancelaction then
			self:CancelAllAction()
			self:ScheduleRepeatingEvent("MandokirCancelAllAction", self.CancelAllAction, 0.25, self)
			self:ScheduleEvent("MandokirLetMeFree", self.LetMeFree, timer.gazeDur, self)
		end
	end
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTargetIcon("raid"..i, 8)
			end
		end
	end
	
	self:DelayedBar(timer.gazeDur, L["bar_gazeCd"], timer.gazeCd, icon.gaze, true, color.gazeCd)
end
	function module:CancelAllAction()
		if PlayerFrame.inCombat then AttackTarget() end
		SpellStopCasting()
		ClearTarget()
	end
	function module:LetMeFree()
		self:CancelScheduledEvent("MandokirCancelAllAction")
	end

function module:GazeFade(rest)
	self:RemoveBar(rest..L["bar_gazeDur"])
	
	if rest == UnitName("Player") and self.db.profile.cancelaction then
		self:RemoveWarningSign(icon.gaze)
		self:LetMeFree()
	end
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTargetIcon("raid"..i, 0)
			end
		end
	end
end

function module:Whirlwind()
	self:RemoveBar(L["bar_whirlwindCd"])
	
	self:Bar(L["bar_whirlwindCast"], timer.whirlwindCast, icon.whirlwind, true, color.whirlwindCast)
	
	self:DelayedBar(timer.whirlwindCast, L["bar_whirlwindCd"], timer.whirlwindCd, icon.whirlwind, true, color.whirlwindCd)
end

function module:Charge()
	self:RemoveBar(L["bar_chargeCd"])
	self:IntervalBar(L["bar_chargeCd"], timer.chargeCd[1], timer.chargeCd[2], icon.charge, true, color.chargeCd)
end

function module:Enrage()
	self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, color.enrage)
	self:Message(L["msg_enrage"], "Urgent", false, nil, false)
	self:Sound("BikeHorn")
	self:WarningSign(icon.enrage, 0.7)
end

function module:EnrageFade()
	self:RemoveBar(L["bar_enrage"])
	self:Message(L["msg_enrageFade"], "Urgent", false, nil, false)
end

function module:Sunder(rest)
	local sunderPlayer = strsub(rest,0,strfind(rest," ") - 1)
	local sunderQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
	
	self:RemoveBar(sunderPlayer.." ".."1"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."2"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."3"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."4"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."5"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."6"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."7"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."8"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."9"..L["bar_sunder"])
	self:RemoveBar(sunderPlayer.." ".."10"..L["bar_sunder"])

	self:Bar(sunderPlayer.." "..sunderQty..L["bar_sunder"], timer.sunder, icon.sunder, true, color.sunder)
	
	if sunderPlayer == UnitName("Player") and sunderQty >= 5 then
		self:WarningSign(icon.sunder, 0.7)
		self:Message(sunderQty..L["msg_sunderHigh"], "Personal", false, nil, false)
	end
end
