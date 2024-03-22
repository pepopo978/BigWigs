
local module, L = BigWigs:ModuleDeclaration("Renataki", "Zul'Gurub")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"vanish", "enrage", "gouge", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Renataki",
	
	vanish_cmd = "vanish",
	vanish_name = "Vanish / Return Alert",
	vanish_desc = "Warn for Vanish and Return.",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage.",
	
	gouge_cmd = "gouge",
	gouge_name = "Gouge Alert",
	gouge_desc = "Warn for Gouge.",
	
	
	--no trigger for vanish
	msg_vanish = "Renataki has Vanished!",
	bar_nextReturn = "Return",
	
	trigger_vanishFade = "Unknown's Ambush", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_vanishFade = "Renataki Appears!",
	bar_nextVanish = "Vanish",
	
	trigger_enrage = "Renataki gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Enrage!",
	
	trigger_gouge = "Renataki's Gouge", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_gouge = "Gouge CD",	
} end )

local timer = {
	nextVanish = 28,
	nextReturn = 20,
	
	gouge = 9, --saw 8.979 and 10.755
}
local icon = {
	nextVanish = "ability_vanish",
	nextReturn = "ability_rogue_ambush",
	
	enrage = "spell_shadow_unholyfrenzy",
	
	gouge = "ability_gouge",
}
local color = {
	vanish = "White",	
	gouge = "Red",
}
local syncName = {
	vanish = "RenatakiVanish"..module.revision,
	vanishFade = "RenatakiUnvanish"..module.revision,
	enrage = "RenatakiEnrage"..module.revision,
	gouge = "RenatakiGouge"..module.revision,
}

local gougeTime = 0
local vanishTime = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
		
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_vanishFade, trigger_gouge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_vanishFade, trigger_gouge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_vanishFade, trigger_gouge
	
	self:ThrottleSync(5, syncName.vanish)
	self:ThrottleSync(5, syncName.vanishFade)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.gouge)
end

function module:OnSetup()
end

function module:OnEngage()
	gougeTime = 0
	vanishTime = 0
	
	if self.db.profile.vanish then
		self:Bar(L["bar_nextVanish"], timer.nextVanish, icon.nextVanish, true, color.vanish)
	end
	
	if self.db.profile.gouge then
		self:Bar(L["bar_gouge"], timer.gouge, icon.gouge, true, color.gouge)
	end
	
	self:ScheduleRepeatingEvent("CheckIfVanish", self.CheckIfVanish, 0.5, self)
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_vanishFade"]) then
		self:Sync(syncName.vanishFade)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_gouge"]) then
		self:Sync(syncName.gouge)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.vanish then
		self:Vanish()
	elseif sync == syncName.vanishFade then
		self:VanishFade()
	
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
		
	elseif sync == syncName.gouge and self.db.profile.gouge then
		self:Gouge()
	end
end


function module:Vanish()
	self:CancelScheduledEvent("CheckIfVanish")
	
	if self.db.profile.vanish then
		self:RemoveBar(L["bar_nextVanish"])
		
		self:Bar(L["bar_nextReturn"], timer.nextReturn, icon.nextReturn, true, color.vanish)
		self:Message(L["msg_vanish"], "Attention", false, nil, false)
	end
	
	self:ScheduleRepeatingEvent("CheckIfVanishFade", self.CheckIfVanishFade, 0.5, self)
	
	if self.db.profile.gouge then
		self:RemoveBar(L["bar_gouge"])
		vanishTime = GetTime()
	end
end

function module:VanishFade()
	self:CancelScheduledEvent("CheckIfVanishFade")
	
	if self.db.profile.vanish then
		self:RemoveBar(L["bar_nextReturn"])
		
		self:Bar(L["bar_nextVanish"], timer.nextVanish, icon.nextVanish, true, color.vanish)
		self:Message(L["msg_vanishFade"], "Attention", false, nil, false)
	end
	
	self:ScheduleRepeatingEvent("CheckIfVanish", self.CheckIfVanish, 0.5, self)
	
	if self.db.profile.gouge then
		self:Bar(L["bar_gouge"], timer.gouge - (vanishTime - gougeTime), icon.gouge, true, color.gouge)
	end
end

function module:Enrage()
	self:WarningSign(icon.enrage, 1)
	self:Sound("Beware")
	self:Message(L["msg_enrage"], "Urgent", false, nil, false)
end

function module:Gouge()
	self:Sound("Info")
	self:Bar(L["bar_gouge"], timer.gouge, icon.gouge, true, color.gouge)
	gougeTime = GetTime()
end


--vanish / visible check
function module:CheckIfVanish()
	if not module:IsRenatakiVisible() then
		self:Sync(syncName.vanish)
	end
end

function module:CheckIfVanishFade()
	if module:IsRenatakiVisible() then
		self:Sync(syncName.vanishFade)
	end
end

function module:IsRenatakiVisible()
	if UnitName("Target") == self.translatedName then
		return true
	else
		for i=1,GetNumRaidMembers() do
			if UnitName("Raid"..i.."Target") == self.translatedName then
				return true
			end
		end
	end

	return false
end
