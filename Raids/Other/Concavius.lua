
local module, L = BigWigs:ModuleDeclaration("Concavius", "Desolace")

module.revision = 30094
module.enabletrigger = module.translatedName
module.toggleoptions = {"addhp", -1, "shadowshock", "manaburn", "voidbolt", -1, "veilofshadow", "piercingshadow", -1, "vacuum", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Desolace"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Concavius",

	addhp_cmd = "addhp",
	addhp_name = "Gozzo & Liang HP Bars",
	addhp_desc = "HP Bars for Gozzo and Liang",
	
	shadowshock_cmd = "shadowshock",
	shadowshock_name = "Shadow Shock Alert",
	shadowshock_desc = "Warn for Shadow Shock",
	
	manaburn_cmd = "manaburn",
	manaburn_name = "Mana Burn Alert",
	manaburn_desc = "Warn for Mana Burn",
	
	veilofshadow_cmd = "veilofshadow",
	veilofshadow_name = "Veil of Shadow Alert",
	veilofshadow_desc = "Warn for Veil of Shadow",
	
	voidbolt_cmd = "voidbolt",
	voidbolt_name = "Void Bolt Alert",
	voidbolt_desc = "Warn for Void Bolt",
	
	piercingshadow_cmd = "piercingshadow",
	piercingshadow_name = "Piercing Shadow Alert",
	piercingshadow_desc = "Warn for Piercing",
	
	vacuum_cmd = "vacuum",
	vacuum_name = "Vacuum Alert",
	vacuum_desc = "Warn for Vacuum",
	
	
	
	trigger_engage = "Let the void claim you...", --CHAT_MSG_MONSTER_YELL
	
		--yells "Bask in the power of the infinite void!", happens at 30%, only gains Shadowform (1)?
	trigger_p2 = "Concavius gains Shadowform", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	
	trigger_shadowShock = "Concavius's Shadow Shock", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	bar_shadowShock = "Shadow Shock CD",
	msg_shadowShocking = "Concavius < 30%: No Mana Burn -> Casting Shadow Shocks and More Piercing Shadows",
	
	--Mana Burn / Disorient
	trigger_manaBurnCd = "Perish.", --CHAT_MSG_MONSTER_YELL
	trigger_manaBurnAfflic = "afflicted by Mana Burn", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_manaBurnCd = "Mana Burn CD",
	bar_manaBurnAfflic = "Disorient",
	msg_manaBurn3 = "Mana Burn in 3sec - Hide!",
	
	trigger_veilOfShadow_you = "You are afflicted by Veil of Shadow", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_veilOfShadow_other = "(.+) is afflicted by Veil of Shadow", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_veilOfShadow_fade = "Veil of Shadow fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
	bar_veilOfShadow = "Veil of Shadow",
	msg_veilOfShadow = "Veil of Shadow - Decurse!",
	
		--2.6 - 3.2k dmg, 4.35 - 4.5sec cast, 9-12sec cd
	trigger_voidBolt = "Concavius begins to cast Void Bolt.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_voidBoltCd = "Void Bolt CD",
	bar_voidBoltCast = "Casting Void Bolt",
	
	trigger_piercingShadow_cast = "Concavius begins to cast Piercing Shadow.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_piercingShadow_you = "You are afflicted by Piercing Shadow", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_piercingShadow_other = "(.+) is afflicted by Piercing Shadow", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_piercingShadow_fade = "Piercing Shadow fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
	bar_piercingShadowCd = "Piercing Shadow CD",
	bar_piercingShadowCast = "Casting Piercing Shadow",
	bar_piercingShadowAfflic = "Piercing Shadow",
	msg_piercingShadow = "Piercing Shadow - Decurse!",
	
		--pulls everyone to him, 30sec cd, 20sec from start, can it be avoided?
	trigger_vacuum = "Embrace the void!", --CHAT_MSG_MONSTER_YELL
	bar_vacuum = "Vacuum CD",
	
	
	--unused
			--hits the tank every 3-5 seconds for 150-200 dmg
		trigger_drainLife = "Concavius's Drain Life hits (.+) for", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
			
			--only stacks to (1)? shadow bolt hits for 150 dmg, the DoT does 40dmg per 2 seconds, doesn't stack
		trigger_shadowBoltStack_you = "You are afflicted by Shadow Bolt %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_shadowBoltStack_other = "(.+) is afflicted by Shadow Bolt %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_shadowBoltStack_fade = "Shadow Bolt fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
		
			--does he gain a buff? or just like to nag?
		trigger_someoneDies = "Your struggle is futile.", --CHAT_MSG_MONSTER_YELL
} end )

local timer = {
	shadowShock = {8,16}, --saw 8.5, 9, 15.8
	
	manaBurnCd = 30,
	manaBurnAfflic = 8,
	
	veilOfShadow = 10, --TBC
	
	voidBoltCd = {4.5,7.5}, --9 to 12sec minus 4.5sec cast time
	voidBoltCast = 4.5,
	
	piercingShadowCd_p1 = 58, --60 - 2sec cast
	piercingShadowCd_p2 = 10, --12 - 2sec cast
	piercingShadowCast = 2,
	piercingShadowAfflic = 1800,
	
	vacuum_first = 20,
	vacuum = 30,
}
local icon = {
	shadowShock = "spell_holy_prayerofshadowprotection",
	
	manaBurnCd = "spell_shadow_manaburn",
	manaBurnAfflic = "spell_shadow_manaburn",
	
	veilOfShadow = "spell_shadow_gathershadows",
	
	voidBoltCd = "spell_shadow_shadowbolt",
	voidBoltCast = "spell_shadow_shadowbolt",
	
	piercingShadow = "spell_shadow_chilltouch",
	
	vacuum = "spell_arcane_portalironforge",
	
	hpBar = "spell_holy_prayerofspirit",
}
local color = {
	shadowShock = "White",
	
	manaBurnCd = "Orange",
	manaBurnAfflic = "Red",
	
	veilOfShadow = "Black",
	
	voidBoltCd = "Cyan",
	voidBoltCast = "Blue",
	
	piercingShadowCast = "Orange",
	piercingShadowCd = "Yellow",
	piercingShadowAfflic = "Red",
	
	vacuum = "Green",
	
	hpBar = "Magenta",
}
local syncName = {
	gozzoAlive = "ConcaviusGozzoAlive"..module.revision,
	liangAlive = "ConcaviusLiangAlive"..module.revision,
	gozzoDead = "ConcaviusGozzoDead"..module.revision,
	liangDead = "ConcaviusLiangDead"..module.revision,
	
	shadowShock = "ConcaviusShadowShock"..module.revision,
	
	manaBurnCd = "ConcaviusManaBurnCd"..module.revision,
	manaBurnAfflic = "ConcaviusManaBurnAfflic"..module.revision,
	
	veilOfShadow = "ConcaviusVeilOfShadow"..module.revision,
	veilOfShadowFade = "ConcaviusVeilOfShadowFade"..module.revision,
	
	voidBolt = "ConcaviusVoidBolt"..module.revision,
	
	piercingShadowCast = "ConcaviusPiercingShadowCast"..module.revision,
	piercingShadowAfflic = "ConcaviusPiercingShadowAfflic"..module.revision,
	piercingShadowFade = "ConcaviusPiercingShadowFade"..module.revision,
	
	vacuum = "ConcaviusVacuum"..module.revision,
}

local gozzoDead = nil
local liangDead = nil
local p2 = nil
local lastPiercingShadowCast = 0
local piercingShadowCd = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_manaBurnCd, trigger_someoneDies, trigger_tp, trigger_vacuum
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_p2
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_shadowShock, trigger_voidBolt, trigger_piercingShadow_cast
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_manaBurnAfflic, trigger_shadowBoltStack_you, trigger_veilOfShadow_you, trigger_piercingShadow_you
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_manaBurnAfflic, trigger_shadowBoltStack_other, trigger_veilOfShadow_other, trigger_piercingShadow_other
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_manaBurnAfflic, trigger_shadowBoltStack_other, trigger_veilOfShadow_other, trigger_piercingShadow_other
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_shadowBoltStack_fade, trigger_veilOfShadow_fade, trigger_piercingShadow_fade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_shadowBoltStack_fade, trigger_veilOfShadow_fade, trigger_piercingShadow_fade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_shadowBoltStack_fade, trigger_veilOfShadow_fade, trigger_piercingShadow_fade
	
	
	self:ThrottleSync(30, syncName.gozzoAlive)
	self:ThrottleSync(30, syncName.liangAlive)
	self:ThrottleSync(3, syncName.gozzoDead)
	self:ThrottleSync(3, syncName.liangDead)
	
	self:ThrottleSync(3, syncName.shadowShock)
	
	self:ThrottleSync(10, syncName.manaBurnCd)
	self:ThrottleSync(10, syncName.manaBurnAfflic)
	
	self:ThrottleSync(3, syncName.veilOfShadow)
	self:ThrottleSync(3, syncName.veilOfShadowFade)
	
	self:ThrottleSync(3, syncName.voidBolt)
	
	self:ThrottleSync(10, syncName.piercingShadowCast)
	self:ThrottleSync(10, syncName.piercingShadowAfflic)
	self:ThrottleSync(1, syncName.piercingShadowFade)
	
	self:ThrottleSync(10, syncName.vacuum)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	gozzoDead = nil
	liangDead = nil
	p2 = nil
	lastPiercingShadowCast = 0
	piercingShadowCd = timer.piercingShadowCd_p1
	
	if self.db.profile.manaburn then
		self:Bar(L["bar_manaBurnCd"], timer.manaBurnCd, icon.manaBurnCd, true, color.manaBurnCd)
		
		self:DelayedMessage(timer.manaBurnCd - 3, L["msg_manaBurn3"], "Urgent", false, nil, false)
		self:DelayedSound(timer.manaBurnCd - 3, "RunAway")
	end
	
	if self.db.profile.voidBolt then
		self:IntervalBar(L["bar_voidBoltCd"], timer.voidBoltCast + timer.voidBoltCd[1], timer.voidBoltCast + timer.voidBoltCd[2], icon.voidBolt, true, color.voidBoltCd)
	end
	
	if self.db.profile.piercingShadow then
		self:Bar(L["bar_piercingShadowCd"], piercingShadowCd + timer.piercingShadowCast, icon.piercingShadow, true, color.piercingShadowCd)
	end
	
	if self.db.profile.vacuum then
		self:Bar(L["bar_vacuum"], timer.vacuum_first, icon.vacuum, true, color.vacuum)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("CheckAddHP")
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
		
	elseif msg == L["trigger_manaBurnCd"] then
		self:Sync(syncName.manaBurnCd)
		
	elseif msg == L["trigger_vacuum"] then
		self:Sync(syncName.vacuum)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	
	if (msg == string.format(UNITDIESOTHER, "Gozzo")) then
		self:Sync(syncName.gozzoDead)
	
	elseif (msg == string.format(UNITDIESOTHER, "Liang")) then
		self:Sync(syncName.liangDead)
	
	elseif (msg == string.format(UNITDIESOTHER, "Concavius"))then
		self:SendBossDeathSync()
	end
end

function module:CheckAddHP()
	local liangHealth
	local gozzoHealth
	
	for i=1,GetNumRaidMembers() do
		if UnitName("Raid"..i.."Target") == "Liang" then
			liangHealth = math.ceil((UnitHealth("Raid"..i.."Target") / UnitHealthMax("Raid"..i.."Target")) * 100)
		elseif UnitName("Raid"..i.."Target") == "Gozzo" then
			gozzoHealth = math.ceil((UnitHealth("Raid"..i.."Target") / UnitHealthMax("Raid"..i.."Target")) * 100)
		end
		if liangHealth and gozzoHealth then
			break
		end
	end
	
	if liangHealth then
		self.liangHP = liangHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, "Liang", 100-self.liangHP)
	end
	
	if gozzoHealth then
		self.gozzoHP = gozzoHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, "Gozzo", 100-self.gozzoHP)
	end
end

function module:Event(msg)
	if string.find(msg, "Gozzo") and gozzoDead == nil then
		self:Sync(syncName.gozzoAlive)
		
	elseif string.find(msg, "Liang") and liangDead == nil then
		self:Sync(syncName.liangAlive)
	
	elseif string.find(msg, L["trigger_p2"]) then
		self:Sync(syncName.shadowShock)
	elseif string.find(msg, L["trigger_shadowShock"]) then
		self:Sync(syncName.shadowShock)
		
	elseif string.find(msg, L["trigger_manaBurnAfflic"]) then
		self:Sync(syncName.manaBurnAfflic)
	
	
	elseif string.find(msg, L["trigger_veilOfShadow_you"]) then
		self:Sync(syncName.veilOfShadow .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_veilOfShadow_other"]) then
		local _, _, veilPlayer, _ = string.find(msg, L["trigger_veilOfShadow_other"])
		self:Sync(syncName.veilOfShadow .. " " .. veilPlayer)
		
	elseif string.find(msg, L["trigger_veilOfShadow_fade"]) then
		local _, _, veilFadePlayer, _ = string.find(msg, L["trigger_veilOfShadow_fade"])
		if veilFadePlayer == "you" then veilFadePlayer = UnitName("Player") end
		self:Sync(syncName.veilOfShadowFade .. " " .. veilFadePlayer)
	
	
	elseif string.find(msg, L["trigger_voidBolt"]) then
		self:Sync(syncName.voidBolt)
		

	elseif msg == L["trigger_piercingShadow_cast"] then
		self:Sync(syncName.piercingShadowCast)
	
	elseif string.find(msg, L["trigger_piercingShadow_you"]) then
		self:Sync(syncName.piercingShadowAfflic .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_piercingShadow_other"]) then
		local _, _, piercingShadowPlayer, _ = string.find(msg, L["trigger_piercingShadow_other"])
		self:Sync(syncName.piercingShadowAfflic .. " " .. piercingShadowPlayer)
		
	elseif string.find(msg, L["trigger_piercingShadow_fade"]) then
		local _, _, piercingShadowFadePlayer, _ = string.find(msg, L["trigger_piercingShadow_fade"])
		if piercingShadowFadePlayer == "you" then piercingShadowFadePlayer = UnitName("Player") end
		self:Sync(syncName.piercingShadowFade .. " " .. piercingShadowFadePlayer)	
	
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.gozzoAlive and self.db.profile.addhp and gozzoDead == nil then
		self:GozzoAlive()
	elseif sync == syncName.liangAlive and self.db.profile.addhp and liangDead == nil then
		self:LiangAlive()
	elseif sync == syncName.gozzoDead and self.db.profile.addhp and gozzoDead == false then
		self:GozzoDead()
	elseif sync == syncName.liangDead and self.db.profile.addhp and liangDead == false then
		self:LiangDead()
		
	elseif sync == syncName.shadowShock and self.db.profile.shadowshock then
		self:ShadowShock()
		
	elseif sync == syncName.manaBurnCd and self.db.profile.manaburn then
		self:ManaBurnCd()
	elseif sync == syncName.manaBurnAfflic and self.db.profile.manaburn then
		self:ManaBurnAfflic()
	
	elseif sync == syncName.veilOfShadow and rest and self.db.profile.veilofshadow then
		self:VeilOfShadow(rest)
	elseif sync == syncName.veilOfShadowFade and rest and self.db.profile.veilofshadow then
		self:VeilOfShadowFade(rest)
		
	elseif sync == syncName.voidBolt and self.db.profile.voidbolt then
		self:VoidBolt()
		
	elseif sync == syncName.piercingShadowCast and self.db.profile.piercingshadow then
		self:PiercingShadowCast()
	elseif sync == syncName.piercingShadowAfflic and rest and self.db.profile.piercingshadow then
		self:PiercingShadowAfflic(rest)
	elseif sync == syncName.piercingShadowFade and rest and self.db.profile.piercingshadow then
		self:PiercingShadowFade(rest)
		
	elseif sync == syncName.vacuum and self.db.profile.vacuum then
		self:Vacuum()
	end
end


function module:GozzoAlive()
	gozzoDead = false
	
	self.gozzoHP = 100
	self:TriggerEvent("BigWigs_StartHPBar", self, "Gozzo", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Gozzo", 0)
	
	self:ScheduleRepeatingEvent("CheckAddHP", self.CheckAddHP, 0.5, self)
end

function module:LiangAlive()
	liangDead = false
	
	self.liangHP = 100
	self:TriggerEvent("BigWigs_StartHPBar", self, "Liang", 100, "Interface\\Icons\\"..icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, "Liang", 0)
	
	self:ScheduleRepeatingEvent("CheckAddHP", self.CheckAddHP, 0.5, self)
end

function module:GozzoDead()
	gozzoDead = true
	
	self:TriggerEvent("BigWigs_StopHPBar", self, "Gozzo")
	
	if liangDead == true or liangDead == nil then
		self:CancelScheduledEvent("CheckAddHP")
	end
end

function module:LiangDead()
	liangDead = true
	
	self:TriggerEvent("BigWigs_StopHPBar", self, "Liang")
	
	if gozzoDead == true or gozzoDead == nil then
		self:CancelScheduledEvent("CheckAddHP")
	end
end

function module:ShadowShock()
	if p2 == nil then
		
		p2 = true
		
		self:Message(L["msg_shadowShocking"], "Attention", false, nil, false)
		
		self:CancelDelayedMessage(L["msg_manaBurn3"])
		self:CancelDelayedSound("RunAway")
		self:CancelDelayedBar(L["bar_manaBurnCd"])
		self:RemoveBar(L["bar_manaBurnCd"])
		
		if self.db.profile.piercingshadow then
			self:CancelDelayedBar(L["bar_piercingShadowCd"])
			self:RemoveBar(L["bar_piercingShadowCd"])
			
			piercingShadowCd = timer.piercingShadowCd_p2
			
			--piercing shadow happens on 12sec timer now.
				--if less than 1sec since last cast, don't bother
					--if less than 12sec since last, recreate accurate timer -> this is the only case where we do a timer
				--if more than 12sec since last, expect him to re-cast it right now so no timer (TBC)
			if (GetTime() - lastPiercingShadowCast) < 12 and (GetTime() - lastPiercingShadowCast) > 1 then
				self:Bar(L["bar_piercingShadowCd"], 12 - (GetTime() - lastPiercingShadowCast), icon.piercingShadow, true, color.piercingShadowCd)
			end
		end
	end
	
	self:IntervalBar(L["bar_shadowShock"], timer.shadowShock[1], timer.shadowShock[2], icon.shadowShock, true, color.shadowShock)
end

function module:ManaBurnCd()
	self:CancelDelayedMessage(L["msg_manaBurn3"])
	self:CancelDelayedSound("RunAway")
	self:CancelDelayedBar(L["bar_manaBurnCd"])
	
	self:RemoveBar(L["bar_manaBurnCd"])
	
	self:WarningSign(icon.manaBurnCd, 0.7)
	self:DelayedBar(timer.manaBurnAfflic, L["bar_manaBurnCd"], timer.manaBurnCd - timer.manaBurnAfflic, icon.manaBurnCd, true, color.manaBurnCd)
	
	self:DelayedMessage(timer.manaBurnCd - 3, L["msg_manaBurn3"], "Urgent", false, nil, false)
	self:DelayedSound(timer.manaBurnCd - 3, "RunAway")
end

function module:ManaBurnAfflic()
	self:Bar(L["bar_manaBurnAfflic"], timer.manaBurnAfflic, icon.manaBurnAfflic, true, color.manaBurnAfflic)
end

function module:VeilOfShadow(rest)
	self:Bar(L["bar_veilOfShadow"].." "..rest, timer.veilOfShadow, icon.veilOfShadow, true, color.veilOfShadow)
	
	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(L["msg_veilOfShadow"], "Personal", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.veilOfShadow, 3)
	end
end

function module:VeilOfShadowFade(rest)
	self:RemoveBar(L["bar_veilOfShadow"].." "..rest)
	self:RemoveWarningSign(icon.veilOfShadow)
end

function module:VoidBolt()
	self:RemoveBar(L["bar_voidBoltCd"])
	
	self:Bar(L["bar_voidBoltCast"], timer.voidBoltCast, icon.voidBoltCast, true, color.voidBoltCast)
	
	self:DelayedIntervalBar(timer.voidBoltCast, L["bar_voidBoltCd"], timer.voidBoltCd[1], timer.voidBoltCd[2], icon.voidBoltCd, true, color.voidBoltCd)
end

function module:PiercingShadowCast()
	self:RemoveBar(L["bar_piercingShadowCd"])
	
	self:Bar(L["bar_piercingShadowCast"], timer.piercingShadowCast, icon.piercingShadow, true, color.piercingShadowCast)
	lastPiercingShadowCast = GetTime()
	
	--piercingShadowCd varies from p1 to p2
	self:DelayedBar(timer.piercingShadowCast, L["bar_piercingShadowCd"], piercingShadowCd, icon.piercingShadow, true, color.piercingShadowCd)
end

function module:PiercingShadowAfflic(rest)
	self:Bar(L["bar_piercingShadowAfflic"].." "..rest, timer.piercingShadowAfflic, icon.piercingShadow, true, color.piercingShadowAfflic)
	
	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(L["msg_piercingShadow"], "Personal", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.piercingShadow, 3)
	end
end

function module:PiercingShadowFade(rest)
	self:RemoveBar(L["bar_piercingShadowAfflic"].." "..rest)
	self:RemoveWarningSign(icon.piercingShadow)
end

function module:Vacuum()
	self:Bar(L["bar_vacuum"], timer.vacuum, icon.vacuum, true, color.vacuum)
end
