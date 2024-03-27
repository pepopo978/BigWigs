local module, L = BigWigs:ModuleDeclaration("Majordomo Executus", "Molten Core")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = { "magicreflect", "physicalreflect", "adds", "firepit", "bosskill" }
module.wipemobs = { "Flamewaker Elite", "Flamewaker Healer" }

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Majordomo",

		magicreflect_cmd = "magicreflect",
		magicreflect_name = "Magic Reflection Alert",
		magicreflect_desc = "Warn for Magic Reflection",

		physicalreflect_cmd = "physicalreflect",
		physicalreflect_name = "Physical Reflection Alert",
		physicalreflect_desc = "Warn for Physical Reflection",

		adds_cmd = "adds",
		adds_name = "Add Dies Alert",
		adds_desc = "Warn for Adds Deaths",

		firepit_cmd = "firepit",
		firepit_name = "Fire Damage from Fire Pit Alert",
		firepit_desc = "Warn for Fire Damage from Fire Pit",


		trigger_engage = "Reckless mortals, none may challenge the sons of the living flame!", --CHAT_MSG_MONSTER_YELL

		--is MUCH longer than that
		trigger_bossDeath = "Impossible! Stay your attack, mortals... I submit! I submit!", --CHAT_MSG_MONSTER_YELL

		bar_reflectCd = "Reflection CD",

		trigger_magicReflect = "gains Magic Reflection.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS"
		trigger_magicReflectFade = "Magic Reflection fades", --CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_magicReflect = "Magic Reflection",
		msg_magicReflect = "Magic Reflection - Stop Casting!",

		trigger_physicalReflect = "gains Damage Shield.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		trigger_physicalReflectFade = "Damage Shield fades", --CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_physicalReflect = "Physical Reflection",
		msg_physicalReflect = "Physical Reflection - Stop Attacking!",

		msg_eliteDead = "/4 Flamewaker Elite Dead",
		msg_healerDead = "/4 Flamewaker Healer Dead",

		trigger_firePitYou = "You suffer (.+) points of fire damage.", --CHAT_MSG_COMBAT_SELF_HITS
	}
end)

local timer = {
	reflectFirstCd = 30, --saw 29.816
	reflectCd = 20, --saw 20
	reflectDur = 10, --saw 10
}
local icon = {
	noReflect = "Spell_Shadow_DetectLesserInvisibility",
	magicReflect = "Spell_Frost_FrostShock",
	physicalReflect = "Spell_Shadow_AntiShadow",
	firePit = "spell_fire_lavaspawn"
}
local color = {
	noReflect = "Black",
	magicReflect = "Blue",
	physicalReflect = "Red",
}
local syncName = {
	physicalReflect = "DomoAuraDamage" .. module.revision,
	physicalReflectFade = "DomoAuraDamageFade" .. module.revision,

	magicReflect = "DomoAuraMagic" .. module.revision,
	magicReflectFade = "DomoAuraMagicFade" .. module.revision,

	eliteDead = "DomoEliteDead" .. module.revision,
	healerDead = "DomoHealerDead" .. module.revision,
}

local eliteDead = 0
local healerDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_bossDeath

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_magicReflect, trigger_physicalReflect

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_magicReflectFade, trigger_physicalReflectFade

	self:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS", "Event") --trigger_firePitYou


	self:ThrottleSync(2, syncName.physicalReflect)
	self:ThrottleSync(2, syncName.physicalReflectFade)

	self:ThrottleSync(2, syncName.magicReflect)
	self:ThrottleSync(2, syncName.magicReflectFade)

	self:ThrottleSync(0.5, syncName.eliteDead)
	self:ThrottleSync(0.5, syncName.healerDead)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --eliteDead, healerDead
end

function module:OnEngage()
	eliteDead = 0
	healerDead = 0

	if self.db.profile.magicreflect or self.db.profile.physicalreflect then
		self:Bar(L["bar_reflectCd"], timer.reflectFirstCd, icon.noReflect, true, color.noReflect)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Flamewaker Elite")) then
		eliteDead = eliteDead + 1
		if eliteDead <= 4 then
			self:Sync(syncName.eliteDead .. " " .. eliteDead)
		end

	elseif (msg == string.format(UNITDIESOTHER, "Flamewaker Healer")) then
		healerDead = healerDead + 1
		if healerDead <= 4 then
			self:Sync(syncName.healerDead .. " " .. healerDead)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	elseif string.find(msg, L["trigger_bossDeath"]) then
		self:SendBossDeathSync()
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_magicReflect"]) then
		self:Sync(syncName.magicReflect)
	elseif string.find(msg, L["trigger_magicReflectFade"]) then
		self:Sync(syncName.magicReflectFade)

	elseif string.find(msg, L["trigger_physicalReflect"]) then
		self:Sync(syncName.physicalReflect)
	elseif string.find(msg, L["trigger_physicalReflectFade"]) then
		self:Sync(syncName.physicalReflectFade)

	elseif string.find(msg, L["trigger_firePitYou"]) and self.db.profile.firepit then
		self:FirePit()
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.magicReflect and self.db.profile.magicreflect then
		self:MagicReflect()
	elseif sync == syncName.magicReflectFade and (self.db.profile.magicreflect or self.db.profile.physicalreflect) then
		self:MagicReflectFade()

	elseif sync == syncName.physicalReflect and self.db.profile.physicalreflect then
		self:PhysicalReflect()
	elseif sync == syncName.physicalReflectFade and (self.db.profile.magicreflect or self.db.profile.physicalreflect) then
		self:PhysicalReflectFade()

	elseif sync == syncName.eliteDead and rest and self.db.profile.adds then
		self:EliteDead(rest)
	elseif sync == syncName.healerDead and rest and self.db.profile.adds then
		self:HealerDead(rest)
	end
end

function module:MagicReflect()
	self:RemoveBar(L["bar_reflectCd"])

	self:Bar(L["bar_magicReflect"], timer.reflectDur, icon.magicReflect, true, color.magicReflect)

	if not (UnitClass("Player") == "Warrior" or UnitClass("Player") == "Rogue" or UnitClass("Player") == "Hunter") then
		self:Message(L["msg_magicReflect"], "Attention", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.magicReflect, 1)
	end
end

function module:MagicReflectFade()
	self:RemoveBar(L["bar_magicReflect"])
	self:Bar(L["bar_reflectCd"], timer.reflectCd, icon.noReflect, true, color.noReflect)
end

function module:PhysicalReflect()
	self:RemoveBar(L["bar_reflectCd"])

	self:Bar(L["bar_physicalReflect"], timer.reflectDur, icon.physicalReflect, true, color.physicalReflect)

	if not (UnitClass("Player") == "Priest" or UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock") then
		self:Message(L["msg_physicalReflect"], "Attention", false, nil, false)
		self:Sound("Beware")
		self:WarningSign(icon.physicalReflect, 1)
	end
end

function module:PhysicalReflectFade()
	self:RemoveBar(L["bar_physicalReflect"])
	self:Bar(L["bar_reflectCd"], timer.reflectCd, icon.noReflect, true, color.noReflect)
end

function module:EliteDead(rest)
	self:Message(rest .. L["msg_eliteDead"], "Positive", false, nil, false)
end

function module:HealerDead(rest)
	self:Message(rest .. L["msg_healerDead"], "Positive", false, nil, false)
end

function module:FirePit()
	self:WarningSign(icon.firePit, 0.7)
	self:Sound("Info")
end
