
local module, L = BigWigs:ModuleDeclaration("Ossirian the Unscarred", "Ruins of Ahn'Qiraj")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "warstomp", "cyclone", "sandstorm", "supreme", "weakness", "clickit", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ossirian",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Big icon warnings signs",
	bigicon_desc = "Big warning signs for Sandstorm, Weakness and Shaman's grounding totem",
	
	warstomp_cmd = "warstomp",
	warstomp_name = "Warstomp bars",
	warstomp_desc = "Timers for Ossirian's Warstomp ability",
	
	cyclone_cmd = "cyclone",
	cyclone_name = "Cyclone bars",
	cyclone_desc = "Timers for Ossirian's Cyclone ability",
	
	sandstorm_cmd = "sandstorm",
	sandstorm_name = "Sand tornado damage warning",
	sandstorm_desc = "Warn if you are taking damage from a Sand tornado",
	
	supreme_cmd = "supreme",
	supreme_name = "Supreme Alert",
	supreme_desc = "Warn for Supreme Mode",
	
	weakness_cmd = "weakness",
	weakness_name = "Ossirian's weakness alert",
	weakness_desc = "Warns what Ossirian's new weakness is",
	
	clickit_cmd = "clickit",
	clickit_name = "Click a crystal now",
	clickit_desc = "Timers for if you click after this timer, he will go supreme",

	supreme_trigger = "Ossirian the Unscarred gains Strength of Ossirian.",
	supreme_trigger2 = "Ossirian the Unscarred is afflicted by Strength of Ossirian.",
	supreme_bar = "Supreme",
	supremewarn = "Ossirian Supreme Mode!",
	supremedelaywarn = "Supreme in %d seconds!",

	debuff_trigger = "Ossirian the Unscarred is afflicted by (.+) Weakness.",
	debuff_trigger2 = "Ossirian the Unscarred gains (.+) Weakness.",
	debuffwarn = "Ossirian now weak to ",

	ossiLostSupreme = "Strength of Ossirian fades from Ossirian the Unscarred.",-- CHAT_MSG_SPELL_AURA_GONE_OTHER",

	expose = "Expose",
	
	cyclone_trigger = "Enveloping Winds",
	cyclone_bar = "Cyclone",
	warstomp_trigger = "War Stomp",
	warstomp_bar = "War Stomp",
	
	sandstorm_trigger = "Sand Vortex's Harsh Winds hits you for",
	
	clickit_bar = "Crystal or die",
	
	firstcrystal_bar = "Click 1st crystal at 0",
	firstcrystal_warn = "CLICK IT NOW!!!",
} end )

local timer = {
	weakness = 45,
	supreme = 45,
	warstomp = 30,
	cyclone = 20,
	clickit = 10,
	firstcrystal = 10,
	firstWarstomp = 25,
}

local icon = {
	supreme = "Ability_warrior_innerrage",
	warstomp = "Ability_warstomp",
	cyclone = "Spell_Nature_Cyclone",
	grounding = "spell_nature_groundingtotem",
	sandstorm = "spell_nature_earthbind",
	
	shadow = "spell_shadow_shadowbolt",
	fire = "Spell_Fire_Fire",
	frost = "Spell_Frost_ChillingBlast",
	nature = "spell_nature_healingtouch",
	arcane = "spell_nature_starfall",
	
	clickit = "inv_misc_pocketwatch_01",
}

local syncName = {
	weakness = "OssirianWeakness"..module.revision,
	supreme = "OssirianSupreme"..module.revision,
	warstomp = "OssirianWarstomp"..module.revision,
	cyclone = "OssirianCyclone"..module.revision,
}

local _, playerClass = UnitClass("player")
bwOssiWeaknessTime = GetTime()

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")

	
	self:ThrottleSync(3, syncName.weakness)
	self:ThrottleSync(3, syncName.supreme)
	self:ThrottleSync(3, syncName.cyclone)
	self:ThrottleSync(3, syncName.warstomp)
end

function module:OnSetup()
end

function module:OnEngage()
	bwOssiSupreme = true
	bwOssiFirstWarstop = true
	bwOssiWeaknessTime = GetTime()
	
	self:Sync(syncName.warstomp)
	self:Sync(syncName.cyclone)
	self:Sync(syncName.supreme)
	
	if self.db.profile.clickit then
		self:Bar(L["firstcrystal_bar"], timer.firstcrystal, icon.clickit, true, "blue")
		self:DelayedMessage(timer.firstcrystal, L["firstcrystal_warn"], "Urgent")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["ossiLostSupreme"] then
		bwOssiSupreme = false
	end
	
	if ((bwOssiWeaknessTime + 46) < GetTime()) and bwOssiSupreme == false then
		self:Bar("UNKNOWN Supreme timer", 30, icon.supreme, true, "red")
		self:Message("WARNING! Supreme timer unknown!", "Attention", nil, "Beware")
		bwOssiSupreme = nil
	end
	
	local _, _, debuffName = string.find(msg, L["debuff_trigger"])
	if string.find(msg, L["debuff_trigger"]) and debuffName ~= L["expose"] then
		self:Sync(syncName.weakness .. " " .. debuffName)
	end
	
	local _, _, debuffName = string.find(msg, L["debuff_trigger2"])
	if string.find(msg, L["debuff_trigger2"]) and debuffName ~= L["expose"] then
		self:Sync(syncName.weakness .. " " .. debuffName)
	end
	
	if string.find(msg, L["cyclone_trigger"]) then
		self:Sync(syncName.cyclone)
	end
	if string.find(msg, L["warstomp_trigger"]) then
		self:Sync(syncName.warstomp)
	end
	if string.find(msg, L["supreme_trigger"]) or string.find(msg, L["supreme_trigger2"]) then
		self:Sync(syncName.supreme)
	end
	if string.find(msg, L["sandstorm_trigger"]) and self.db.profile.sandstorm then
		if self.db.profile.bigicon then
			self:WarningSign(icon.sandstorm, 1)
		end
		self:Sound("RunAway")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.weakness and rest and self.db.profile.weakness then
		self:Weakness(rest)
	elseif sync == syncName.supreme and self.db.profile.supreme then
		self:Supreme()
	elseif sync == syncName.cyclone and self.db.profile.cyclone then
		self:Cyclone()
	elseif sync == syncName.warstomp and self.db.profile.warstomp then
		self:WarStomp()
	end
end

function module:Weakness(rest)
	if self.db.profile.clickit then
		self:ClickIt()
	end
	
	self:RemoveBar("UNKNOWN Supreme timer")
	bwOssiWeaknessTime = GetTime()
	bwOssiSupreme = false
	element = tostring(rest)
	
	if element == "Shadow" and self.db.profile.weakness then
		self:RemoveBar("Shadow weakness!")
		self:Message(string.format(L["debuffwarn"].."Shadow!"), "Important")
		self:Bar("Shadow weakness!", timer.weakness, icon.shadow, true, "green")
		if self.db.profile.bigicon then
			self:WarningSign(icon.shadow, 0.7)
		end
	end
	if element == "Fire" and self.db.profile.weakness then
		self:RemoveBar("Fire weakness!")
		self:Message(string.format(L["debuffwarn"].."Fire!"), "Important")
		self:Bar("Fire weakness!", timer.weakness, icon.fire, true, "green")
		if self.db.profile.bigicon then
			self:WarningSign(icon.fire, 0.7)
		end
	end
	if element == "Frost" and self.db.profile.weakness then
		self:RemoveBar("Frost weakness!")
		self:Message(string.format(L["debuffwarn"].."Frost!"), "Important")
		self:Bar("Frost weakness!", timer.weakness, icon.frost, true, "green")
		if self.db.profile.bigicon then
			self:WarningSign(icon.frost, 0.7)
		end
	end
	if element == "Nature" and self.db.profile.weakness then
		self:RemoveBar("Nature weakness!")
		self:Message(string.format(L["debuffwarn"].."Nature!"), "Important")
		self:Bar("Nature weakness!", timer.weakness, icon.nature, true, "green")
		if self.db.profile.bigicon then
			self:WarningSign(icon.nature, 0.7)
		end
	end
	if element == "Arcane" and self.db.profile.weakness then
		self:RemoveBar("Arcane weakness!")
		self:Message(string.format(L["debuffwarn"].."Arcane!"), "Important")
		self:Bar("Arcane weakness!", timer.weakness, icon.arcane, true, "green")
		if self.db.profile.bigicon then
			self:WarningSign(icon.arcane, 0.7)
		end
	end	
	if self.db.profile.supreme then
		self:CancelDelayedMessage(string.format(L["supremedelaywarn"], 5))
		self:RemoveBar(L["supreme_bar"])
		self:DelayedMessage(timer.supreme-5, string.format(L["supremedelaywarn"], 5), "Important")
		self:Bar(L["supreme_bar"], timer.supreme, icon.supreme, true, "red")
	end
end

function module:Supreme()
	bwOssiSupreme = true
	self:Message(L["supremewarn"], "Attention", nil, "Beware")
	self:RemoveBar("UNKNOWN Supreme timer")
end

function module:Cyclone()
	self:RemoveBar(L["cyclone_bar"])
	self:Bar(L["cyclone_bar"], timer.cyclone, icon.cyclone, true, "white")
	
	if playerClass == "SHAMAN" and self.db.profile.bigicon then
		self:DelayedWarningSign(timer.cyclone - 5, icon.grounding, 1)
	end
end

function module:WarStomp()
	if bwOssiFirstWarstop == false then
		self:RemoveBar(L["warstomp_bar"])
	
		self:Bar(L["warstomp_bar"], timer.warstomp, icon.warstomp, true, "yellow")
		self:DelayedWarningSign(timer.warstomp - 5, icon.warstomp, 1)
	else
		self:Bar(L["warstomp_bar"], timer.firstWarstomp, icon.warstomp, true, "yellow")
		bwOssiFirstWarstop = false
	end
end

function module:ClickIt()
	self:RemoveBar(L["clickit_bar"])
	self:DelayedBar(timer.weakness-16.2, L["clickit_bar"], timer.clickit, icon.clickit, true, "blue")
end
