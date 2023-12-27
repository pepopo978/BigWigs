local module, L = BigWigs:ModuleDeclaration("Pyroguard Emberseer", "Blackrock Spire")

local adds = AceLibrary("Babble-Boss-2.2")["Blackhand Incarcerator"]
local boss = AceLibrary("Babble-Boss-2.2")["Pyroguard Emberseer"]

module.revision = 30025
module.enabletrigger = {adds, boss}
module.toggleoptions = {"firenova", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Emberseer",

	firenova_cmd = "firenova",
	firenova_name = "Fire Nova Timer",
	firenova_desc = "Indicates time left to next Fire Nova.",

	trigger_engage = "Ha! Ha! Ha! Thank you for freeing me, fools. Now let me repay you by charring the flesh from your bones.",--CHAT_MSG_MONSTER_SAY

	trigger_firenova = "Fire Nova",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_firenova = "Fire Nova",
	
	msg_addDead = "/7 Incarcerator Dead",
	
	trigger_bossDead = "Pyroguard Emberseer dies.",--CHAT_MSG_COMBAT_HOSTILE_DEATH
} end )

local timer = {
	firenova = 6,
}
local icon = {
	firenova = "spell_fire_sealoffire",
}
local syncName = {
	firenova = "emberseerFirenova"..module.revision,
}
local color = {
	firenova = "Red",
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --debug
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_firenova
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_firenova
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_firenova
	
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY") --trigger_engage
	
	self:ThrottleSync(3, syncName.firenova)
end

function module:OnSetup()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	bwIncarceratorDeadCount = 0
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end
function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= "Hall of Binding" or self.core:IsModuleActive(module.translatedName) then
		return
	end

	self.core:EnableModule(module.translatedName)
end

function module:CHAT_MSG_MONSTER_SAY(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == L["trigger_bossDead"] then
		self:SendBossDeathSync()
	elseif msg == string.format(UNITDIESOTHER, "Blackhand Incarcerator") then
		bwIncarceratorDeadCount = bwIncarceratorDeadCount + 1
		self:Message(bwIncarceratorDeadCount..L["msg_addDead"], "Important", false, nil, false)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_firenova"]) then
		self:Sync(syncName.firenova)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.firenova and self.db.profile.firenova then
		self:Firenova()
	end
end

function module:Firenova()
	self:Bar(L["bar_firenova"], timer.firenova, icon.firenova, true, color.firenova)
end
