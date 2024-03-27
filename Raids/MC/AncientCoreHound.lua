
local module, L = BigWigs:ModuleDeclaration("Ancient Core Hound", "Molten Core")

module.revision = 30073
module.enabletrigger = module.translatedName
module.toggleoptions = {"bars"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Corehound",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",
	
	
	trigger_debuff = "afflicted by (.+).", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_debuffFail = "Ancient Core Hound's (.+) fails.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_debuffResist = "Ancient Core Hound's (.+) was resisted by", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_debuff = "Debuff",
	
	msg_ancientDread = "Ancient Dread - Dispel!",
	
	bar_ancientDespair = "Disorient",
	
	bar_groundStomp = "Ground Stomp",
	
	msg_cauterizingFlames = "Cauterizing Flames - Dispel!",
	
	msg_witheringHeat = "Withering Heat - Dispel!",
	
	msg_ancientHysteria = "Ancient Hysteria - Decurse!",
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

function module:Event(msg)
	if string.find(msg, L["trigger_debuff"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuff"])
		if debuff == "Ancient Dread" or "Ancient Despair" or "Ground Stomp" or "Cauterizing Flames" or "Withering Heat" or "Ancient Hysteria" then
			self:Sync(syncName.debuff .. " " .. debuff)
		end
	
	elseif string.find(msg, L["trigger_debuffFail"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuffFail"])
		if debuff == "Ancient Dread" or "Ancient Despair" or "Ground Stomp" or "Cauterizing Flames" or "Withering Heat" or "Ancient Hysteria" then
			self:Sync(syncName.debuff .. " " .. debuff)
		end
	
	elseif string.find(msg, L["trigger_debuffResist"]) then
		local _,_, debuff, _ = string.find(msg, L["trigger_debuffResist"])
		if debuff == "Ancient Dread" or "Ancient Despair" or "Ground Stomp" or "Cauterizing Flames" or "Withering Heat" or "Ancient Hysteria" then
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
	
	if rest == "Ancient Dread" then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_ancientDread"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.ancientDread, 1)
		end
	
	elseif rest == "Ancient Despair" then
		self:Bar(L["bar_ancientDespair"], timer.ancientDespair, icon.ancientDespair, true, color.ancientDespair)
		self:WarningSign(icon.ancientDespair, 1)
		self:DelayedBar(timer.ancientDespair, L["bar_debuff"], timer.debuff - timer.ancientDespair, icon.debuff, true, color.debuff)
	
	elseif rest == "Ground Stomp" then
		self:Bar(L["bar_groundStomp"], timer.groundStomp, icon.groundStomp, true, color.groundStomp)
		self:WarningSign(icon.groundStomp, 1)
		self:DelayedBar(timer.groundStomp, L["bar_debuff"], timer.debuff - timer.groundStomp, icon.debuff, true, color.debuff)
	
	elseif rest == "Cauterizing Flames" then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_cauterizingFlames"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.cauterizingFlames, 1)
		end
		
	elseif rest == "Withering Heat" then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
			self:Message(L["msg_witheringHeat"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.witheringHeat, 1)
		end
		
	elseif rest == "Ancient Hysteria" then
		self:Bar(L["bar_debuff"], timer.debuff, icon.debuff, true, color.debuff)
		if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
			self:Message(L["msg_ancientHysteria"], "Urgent", false, nil, false)
			self:Sound("Info")
			self:WarningSign(icon.ancientHysteria, 1)
		end
	end
end
