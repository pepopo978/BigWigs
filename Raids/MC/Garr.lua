
local module, L = BigWigs:ModuleDeclaration("Garr", "Molten Core")

module.revision = 30078
module.enabletrigger = module.translatedName
module.toggleoptions = {"pulse", "remove", "adds", "immolate", "bosskill"}
module.wipemobs = {"Firesworn"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Garr",
	
	pulse_cmd = "pulse",
	pulse_name = "Antimagic Pulse Alert",
	pulse_desc = "Warn for Antimagic Pulse",
	
	remove_cmd = "remove",
	remove_name = "Removed Buff Alert",
	remove_desc = "Warn for Removed Buff",
	
	adds_cmd = "adds",
	adds_name = "Add Dies Alert",
	adds_desc = "Warn for Adds Deaths",
	
	immolate_cmd = "immolate",
	immolate_name = "Immolate Alert",
	immolate_desc = "Warn for Immolate",
	
	
	trigger_antimagicPulse = "Garr performs Antimagic Pulse", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_antimagicPulse = "Antimagic Pulse",
	
	trigger_remove = "Your (.+) is removed.", --CHAT_MSG_SPELL_BREAK_AURA
	msg_remove = "Antimagic Pulse Removed your ",
	
	msg_addDead = "/8 Firesworn Dead",
	
	--not tracking the afflicted since many mobs do immolate, may cause conflict
		--instead only showing the message once to remind dispels on Garr
	trigger_immolate = "Fire damage from Firesworn's Immolate.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	msg_immolate = "Immolate - Dispel!",
} end)

local timer = {
	antimagicPulseFirst = 15,
	antimagicPulse = 20,
}
local icon = {
	antimagicPulse = "spell_holy_dispelmagic",
	immolate = "spell_fire_immolation",
}
local color = {
	antimagicPulse = "White",
}
local syncName = {
	antimagicPulse = "GarrAntimagicPulse"..module.revision,
	addDead = "GarrAddDead"..module.revision,
	immolate = "GarrImmolate"..module.revision,
}

local addDead = 0
local fightningGarr = nil


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_antimagicPulse
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_antimagicPulse
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_antimagicPulse
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_immolate
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_immolate
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_immolate
	
	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA", "Event") --trigger_remove
	
	
	self:ThrottleSync(5, syncName.antimagicPulse)
	self:ThrottleSync(0.5, syncName.addDead)
	self:ThrottleSync(60, syncName.immolate)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --addDead
end

function module:OnEngage()
	addDead = 0
	fightningGarr = true
	
	if self.db.profile.pulse then
		self:Bar(L["bar_antimagicPulse"], timer.antimagicPulseFirst, icon.antimagicPulse, true, color.antimagicPulse)
	end
end

function module:OnDisengage()
	fightningGarr = false
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Firesworn")) then
		addDead = addDead + 1
		if addDead <= 8 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	elseif (msg == string.format(UNITDIESOTHER, "Garr")) then
		fightningGarr = false
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_antimagicPulse"]) then
		self:Sync(syncName.antimagicPulse)
	
	elseif string.find(msg, L["trigger_remove"]) and fightningGarr == true and self.db.profile.remove then
		local _,_, removedBuff, _ = string.find(msg, L["trigger_remove"])
		if removedBuff ~= "Immolate" then
			self:Remove(removedBuff)
		end
		
	elseif string.find(msg, L["trigger_immolate"]) then
		self:Sync(syncName.immolate)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.antimagicPulse and self.db.profile.pulse then
		self:AntimagicPulse()
		
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
		
	elseif sync == syncName.immolate and self.db.profile.immolate then
		self:Immolate()
	end
end


function module:AntimagicPulse()
	self:Bar(L["bar_antimagicPulse"], timer.antimagicPulse, icon.antimagicPulse, true, color.antimagicPulse)
end

function module:Remove(rest)
	self:Message(L["msg_remove"]..rest, "Attention", false, nil, false)
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
end

function module:Immolate()
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(L["msg_immolate"], "Urgent", false, nil, false)
		self:WarningSign(icon.immolate, 1)
	end
end
