
local module, L = BigWigs:ModuleDeclaration("Shazzrah", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"curse", "deaden", "blink", "counterspell", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Shazzrah",

	counterspell_cmd = "counterspell",
	counterspell_name = "Counterspell Alert",
	counterspell_desc = "Warn for Counterspell",

	curse_cmd = "curse",
	curse_name = "Shazzrah's Curse Alert",
	curse_desc = "Warn for Shazzrah's Curse",

	deaden_cmd = "deaden",
	deaden_name = "Deaden Magic Alert",
	deaden_desc = "Warn for Deaden Magic",

	blink_cmd = "blink",
	blink_name = "Blink Alert",
	blink_desc = "Warn for Blink",
	
	
	trigger_blink = "casts Gate of Shazzrah",
	msg_blink = "Blink - Aggro Drop!",
	bar_blink = "Blink CD",
	
	trigger_deaden = "Shazzrah gains Deaden Magic.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_deadenFade = "Deaden Magic fades from Shazzrah.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_deaden = "Deaden Magic CD",
	msg_deaden = "Deaden Magic - Dispel it!",
	
	trigger_curse = "afflicted by Shazzrah's Curse.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_curse2 = "Shazzrah's Curse was resisted", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	curse_warn = "Shazzrah's Curse - Decurse!",
	curse_bar = "Shazzrah's Curse",
	
	trigger_counterspell = "Shazzrah's Counterspell", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	trigger_counterspell2 = "Shazzrah interrupts", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_counterspell = "Possible Counterspell",
	msg_counterspellSoon = "3 seconds until Counterspell!",
	msg_counterspell = "Counterspell!",	
} end)

local timer = {
	cs = 16,
	firstCS = 15,
	
	curse =  20,
	firstCurse = 10,
	
	blink = 25,
	firstBlink = 25,
	
	earliestDeaden = 7,
	latestDeaden = 14,
	firstDeaden = 5,
}
local icon = {
	cs = "Spell_Frost_IceShock",
	curse = "Spell_Shadow_AntiShadow",
	blink = "Spell_Arcane_Blink",
	deaden = "Spell_Holy_SealOfSalvation",
}
local color = {

}
local syncName = {
	cs = "ShazzrahCounterspell"..module.revision,
	curse = "ShazzrahCurse"..module.revision,
	blink = "ShazzrahBlink"..module.revision,
	deaden = "ShazzrahDeadenMagicOn"..module.revision,
	deadenOver = "ShazzrahDeadenMagicOff"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS", "Event")


	self:ThrottleSync(10, syncName.blink)
	self:ThrottleSync(10, syncName.curse)
	self:ThrottleSync(5, syncName.deaden)
	self:ThrottleSync(5, syncName.deadenOver)
	self:ThrottleSync(0.5, syncName.cs)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.db.profile.counterspell then
		self:Bar(L["bar_counterspell"], timer.firstCS, icon.cs, true, "red")
	end
	self:DelayedSync(timer.firstCS, syncName.cs)

	if self.db.profile.blink then
		self:Bar(L["bar_blink"], timer.firstBlink, icon.blink, true, "white")
	end
	self:DelayedSync(timer.firstBlink, syncName.blink)

	if self.db.profile.curse then
		self:Bar(L["curse_bar"], timer.firstCurse, icon.curse, true, "blue") -- seems to be completly random
	end
	if self.db.profile.deaden then
		self:Bar(L["bar_deaden"], timer.firstDeaden, icon.deaden, true, "black")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if (string.find(msg, L["trigger_deaden"])) then
		self:Sync(syncName.deaden)
	elseif (string.find(msg, L["trigger_deadenFade"])) then
		self:Sync(syncName.deadenOver)
	elseif (string.find(msg, L["trigger_blink"])) then
		self:Sync(syncName.blink)
	elseif (string.find(msg, L["trigger_counterspell"]) or string.find(msg, L["trigger_counterspell2"])) then
		self:Sync(syncName.cs)
	elseif (string.find(msg, L["trigger_curse"]) or string.find(msg, L["trigger_curse2"])) then
		self:Sync(syncName.curse)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.blink then
		self:Blink()
	elseif sync == syncName.deaden  then
		self:DeadenMagic()
	elseif sync == syncName.deadenOver then
		self:DeadenMagicOver()
	elseif sync == syncName.curse then
		self:Curse()
	elseif sync == syncName.cs and self.db.profile.counterspell then
		self:Counterspell()
	end
end


function module:Counterspell()
	if self.db.profile.counterspell then
		self:Bar(L["bar_counterspell"], timer.cs, icon.cs, true, "red")
		self:Message("Go!", nil, false, nil, false)
		if UnitClass("Player") ~= "Warrior" and UnitClass("Player") ~= "Rogue" and UnitClass("Player") ~= "Hunter" then
			self:WarningSign(icon.cs, 0.7)
		end
	end
	self:DelayedSync(timer.cs, syncName.cs)
end

function module:Curse()
	self:Message(L["curse_warn"], "Attention", "Alarm")
	self:Bar(L["curse_bar"], timer.curse, icon.curse, true, "blue") -- seems to be completly random
end

function module:Blink()
	firstblink = false

	if self.db.profile.blink then
		self:Message(L["msg_blink"], "Important")
		self:Bar(L["bar_blink"], timer.blink, icon.blink, true, "white")

	end

	self:DelayedSync(timer.blink, syncName.blink)
end

function module:DeadenMagic()
	if self.db.profile.deaden then
		self:RemoveBar(L["bar_deaden"])
		self:Message(L["msg_deaden"], "Important")
		self:IntervalBar(L["bar_deaden"], timer.earliestDeaden, timer.latestDeaden, icon.deaden, true, "black")
		if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Priest" then
			self:WarningSign(icon.deaden, timer.earliestDeaden)
		end
	end
end

function module:DeadenMagicOver()
	if self.db.profile.deaden then
		if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Priest" then
			self:RemoveWarningSign(icon.deaden)
		end
	end
end
