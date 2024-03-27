
local module, L = BigWigs:ModuleDeclaration("Gehennas", "Molten Core")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = {"curse", "rain", "adds", "bosskill"}
module.wipemobs = {"Flamewaker"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gehennas",

	curse_cmd = "curse",
	curse_name = "Gehennas' Curse Alert",
	curse_desc = "Warn for Gehennas' Curse",

	rain_cmd = "rain",
	rain_name = "Rain of Fire Alert",
	rain_desc = "Warn for Rain of Fire",
	
	adds_cmd = "adds",
	adds_name = "Add Dies Alert",
	adds_desc = "Warn for Adds Deaths",
	
	
	trigger_curse = "afflicted by Gehennas' Curse.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_curse2 = "Gehennas' Curse was resisted", --CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_curseCd = "Gehennas' Curse CD",
	msg_curse = "Gehennas' Curse - Decurse!",
	
	trigger_rainOfFire = "You are afflicted by Rain of Fire.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_rainOfFireFade = "Rain of Fire fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	msg_addDead = "/2 Flamewaker Dead",
} end)

local timer = {
	curseFirstCd = 8,
	curseCd = {22,30},
	
	rainOfFire = 10,
}
local icon = {
	curse = "Spell_Shadow_BlackPlague",
	rainOfFire = "Spell_Shadow_RainOfFire",
}
local color = {
	curseCd = "Blue",
}
local syncName = {
	curse = "GehennasCurse"..module.revision,
	addDead = "GehennasAddDead"..module.revision,
}

local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_curse, trigger_rainOfFire
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_curse
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_curse
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_curse2
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_curse2
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_rainOfFireFade
	

	self:ThrottleSync(10, syncName.curse)
	self:ThrottleSync(0.5, syncName.addDead)
end

function module:OnSetup()
	self.started = false

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.core:IsModuleActive("Flame Imp", "Molten Core") then self:TriggerEvent("BigWigs_RebootModule", "Flame Imp", "Molten Core") end
	
	addDead = 0
	
	if self.db.profile.curse then
		self:Bar(L["bar_curseCd"], timer.curseFirstCd, icon.curse, true, color.curseCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Flamewaker")) then
		addDead = addDead + 1
		if addDead <= 2 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_curse"]) or string.find(msg, L["trigger_curse2"]) then
		self:Sync(syncName.curse)
	
	elseif msg == L["trigger_rainOfFire"] and self.db.profile.rain then
		self:RainOfFire()
	elseif msg == L["trigger_rainOfFireFade"] and self.db.profile.rain then
		self:RainOfFireFade()
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:Curse()
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
	end
end


function module:Curse()
	self:IntervalBar(L["bar_curseCd"], timer.curseCd[1], timer.curseCd[2], icon.curse, true, color.curseCd)
	
	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(L["msg_curse"], "Urgent", false, nil, false)
		self:WarningSign(icon.curse, 0.7)
		self:Sound("Beware")
	end
end

function module:RainOfFire()
	self:WarningSign(icon.rainOfFire, timer.rainOfFire)
	self:Sound("Info")
end

function module:RainOfFireFade()
	self:RemoveWarningSign(icon.rainOfFire)
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
end
