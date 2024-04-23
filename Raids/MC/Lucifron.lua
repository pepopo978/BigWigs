
local module, L = BigWigs:ModuleDeclaration("Lucifron", "Molten Core")

module.revision = 30085
module.enabletrigger = module.translatedName
module.toggleoptions = {"curse", "doom", "mc", -1, "shock", -1, "adds", "bosskill"}
module.wipemobs = {"Flamewaker Protector"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Lucifron",
	
	curse_cmd = "curse",
	curse_name = "Lucifron's Curse Alert",
	curse_desc = "Warn for Lucifron's Curse",

	doom_cmd = "doom",
	doom_name = "Impending Doom Alert",
	doom_desc = "Warn for Impending Doom",
	
	mc_cmd = "mc",
	mc_name = "Dominate Mind Alert",
	mc_desc = "Warn for Dominate Mind.",

	shock_cmd = "shock",
	shock_name = "Shadow Shock Alert",
	shock_desc  = "Warn for Shadow Shock",
	
	adds_cmd = "adds",
	adds_name = "Add Dies Alert",
	adds_desc = "Warn for Adds Deaths",


	trigger_curse = "afflicted by Lucifron's Curse.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_curse2 = "Lucifron's Curse was resisted", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_curseCd = "Next Lucifron's Curse",
	msg_curse = "Lucifron's Curse - Decurse!",
	
	trigger_doom = "afflicted by Impending Doom.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_doom2 = "Impending Doom was resisted", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_doomCd = "Next Impending Doom",
	bar_doomDmg = "Impending Doom!",
	msg_doom = "Impending Doom - Dispel!",
	
	trigger_shadowShock = "Lucifron's Shadow Shock", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_shadowShockCd = "Shadow Shock CD",
	
	trigger_mcYou = "You are afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mcOther2 = "(.+) %(.+%) is afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcOther = "(.+) is afflicted by Dominate Mind", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcFade = "Dominate Mind fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mcCd = "MC CD",
	bar_mc = " MC ",
	msg_mc = " MC - Dispel!",
	
	trigger_mcCast = "Flamewaker Protector begins to cast Dominate Mind.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_mcCast = "Casting MC!",
	msg_mcCast = "Casting MC - Interrupt!",
	
	msg_addDead = "/2 Flamewaker Protectors Dead",

	trigger_deadYou = "You die.", --CHAT_MSG_COMBAT_FRIENDLY_DEATH
	trigger_deadOther = "(.+) dies.", --CHAT_MSG_COMBAT_FRIENDLY_DEATH
} end)

local timer = {
	curseFirstCd = 20,
	curseCd = 15,

	impendingDoomCd = 10,
	impendingDoomDur = 10,
	
	mcCd = 8,
	mcCast = 2,
	mc = 15,
	
	shadowShockFirstCd = {5,10}, --6
	shadowShockCd = {10,20}, --12
}
local icon = {
	curse = "Spell_Shadow_BlackPlague",
	impendingDoom = "Spell_Shadow_NightOfTheDead",
	mc = "Spell_Shadow_ShadowWordDominate",
	shadowShock = "spell_shadow_shadowbolt",
}
local color = {
	curse = "Blue",
	
	impendingDoomCd = "White",
	impendingDoomDur = "Black",
	
	mcCd = "Orange",
	mcCast = "Cyan",
	mc = "Red",
	
	shadowShockCd = "Magenta",
}
local syncName = {
	curse = "LucifronCurseRep"..module.revision,
	impendingDoom = "LucifronDoomRep"..module.revision,
	
	mc = "LucifronMc"..module.revision,
	mcCast = "LucifronMcCast"..module.revision,
	mcFade = "LucifronMcFade"..module.revision,
	
	shock = "LucifronShock"..module.revision,
	
	addDead = "LucifronAddDead"..module.revision,
}

local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_curse, trigger_doom, trigger_mcYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_curse, trigger_doom, trigger_mcOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_curse, trigger_doom, trigger_mcOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event") --trigger_mcOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_mcFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_curse2, trigger_doom2, trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_curse2, trigger_doom2, trigger_shadowShock, trigger_mcCast
	
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "Event") --trigger_deadYou, trigger_deadOther
	
	
	self:ThrottleSync(5, syncName.curse)
	self:ThrottleSync(5, syncName.impendingDoom)
	
	self:ThrottleSync(0.1, syncName.mc)
	self:ThrottleSync(1, syncName.mcCast)
	self:ThrottleSync(0.1, syncName.mcFade)
	
	self:ThrottleSync(5, syncName.shock)
	self:ThrottleSync(0.5, syncName.addDead)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --addDead, mcFade
end

function module:OnEngage()
	addDead = 0
	
	if self.db.profile.curse then
		self:Bar(L["bar_curseCd"], timer.curseFirstCd, icon.curse, true, color.curse)
	end
	
	if self.db.profile.doom then
		self:Bar(L["bar_doomCd"], timer.impendingDoomCd, icon.impendingDoom, true, color.impendingDoomCd)
	end
	
	if self.db.profile.mc then
		self:Bar(L["bar_mcCd"], timer.mcCd, icon.mc, true, color.mcCd)
	end
	
	if self.db.profile.shock then
		self:IntervalBar(L["bar_shadowShockCd"], timer.shadowShockFirstCd[1], timer.shadowShockFirstCd[2], icon.shadowShock, true, color.shadowShockCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Flamewaker Protector")) then
		addDead = addDead + 1
		if addDead <= 2 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	
	elseif string.find(msg, L["trigger_deadOther"]) then
		local _,_, deadPerson, _ = string.find(msg, L["trigger_deadOther"])
		if deadPerson ~= "Flamewaker Protector" and deadPerson ~= "Lucifron" then
			self:Sync(syncName.mcFade .. " " .. deadPerson)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_curse"]) or string.find(msg, L["trigger_curse2"]) then
		self:Sync(syncName.curse)
	
	elseif string.find(msg, L["trigger_doom"]) or string.find(msg, L["trigger_doom2"]) then
		self:Sync(syncName.impendingDoom)
	
	
	elseif msg == L["trigger_mcCast"] then
		self:Sync(syncName.mcCast)
	
	elseif msg == L["trigger_mcYou"] then
		self:Sync(syncName.mc .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_mcOther2"]) then
		local _,_, mcPerson, _ = string.find(msg, L["trigger_mcOther2"])
		self:Sync(syncName.mc .. " " .. mcPerson)

	elseif string.find(msg, L["trigger_mcOther"]) then
		local _,_, mcPerson, _ = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPerson)
	
	elseif string.find(msg, L["trigger_mcFade"]) then
		local _,_, mcFadePerson, _ = string.find(msg, L["trigger_mcFade"])
		if mcFadePerson == "you" then mcFadePerson = UnitName("Player") end
		self:Sync(syncName.mcFade .. " " .. mcFadePerson)

	elseif msg == L["trigger_deadYou"] then
		self:Sync(syncName.mcFade .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_deadOther"]) then
		local _,_, mcFadePerson, _ = string.find(msg, L["trigger_deadOther"])
		self:Sync(syncName.mcFade .. " " .. mcFadePerson)
		
		
	elseif string.find(msg, L["trigger_shadowShock"]) then
		self:Sync(syncName.shock)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:Curse()
	
	elseif sync == syncName.impendingDoom and self.db.profile.doom then
		self:ImpendingDoom()
	
	elseif sync == syncName.mcCast and self.db.profile.mc then
		self:McCast()
	elseif sync == syncName.mc and rest and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.mc then
		self:McFade(rest)
	
	elseif sync == syncName.shock and self.db.profile.shock then
		self:ShadowShock()
		
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
	end
end


function module:Curse()
	self:Bar(L["bar_curseCd"], timer.curseCd, icon.curse, true, color.curse)
	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(L["msg_curse"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.curse, 1)
	end
end

function module:ImpendingDoom()
	self:RemoveBar(L["bar_doomCd"])
	
	self:Bar(L["bar_doomDmg"], timer.impendingDoomDur, icon.impendingDoom, true, color.impendingDoomDur)
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(L["msg_doom"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.impendingDoom, 1)
	end
	
	self:DelayedBar(timer.impendingDoomDur, L["bar_doomCd"], timer.impendingDoomCd, icon.impendingDoom, true, color.impendingDoomCd)
end

function module:McCast()
	self:RemoveBar(L["bar_mcCd"])
	
	self:Bar(L["bar_mcCast"], timer.mcCast, icon.mc, true, color.mcCast)
	if UnitClass("Player") == "Warrior" or UnitClass("Player") == "Rogue" or UnitClass("Player") == "Mage" then
		self:Message(L["msg_mcCast"], "Important", false, nil, false)
		self:WarningSign(icon.mc, 0.7)
	end
end

function module:Mc(rest)
	self:RemoveBar(L["bar_mcCast"])
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 4)
			end
		end
	end
		
	self:Bar(rest..L["bar_mc"].. ">Click Me<", timer.mc, icon.mc, true, color.mc)
	self:SetCandyBarOnClick("BigWigsBar "..rest..L["bar_mc"].. ">Click Me<", function(name, button, extra) TargetByName(extra, true) end, rest)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(rest..L["msg_mc"], "Attention", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.mc, 0.7)
	end
end



function module:McFade(rest)
	self:RemoveBar(rest..L["bar_mc"].. ">Click Me<")
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTargetIcon("raid"..i, 0)
			end
		end
	end
end

function module:ShadowShock()
	self:IntervalBar(L["bar_shadowShockCd"], timer.shadowShockCd[1], timer.shadowShockCd[2], icon.shadowShock, true, color.shadowShockCd)
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
end
