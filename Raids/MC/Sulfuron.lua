
local module, L = BigWigs:ModuleDeclaration("Sulfuron Harbinger", "Molten Core")

module.revision = 30078
module.enabletrigger = module.translatedName
module.toggleoptions = {"heal", "knockback", "flamespear", "inspire", "shadowwordpain", "immolate", "adds", "bosskill"}
module.wipemobs = {"Flamewaker Priest"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sulfuron",

	knockback_cmd = "knockback",
	knockback_name = "Hand of Ragnaros Alert",
	knockback_desc = "Warn for Hand of Ragnaros",

	heal_cmd = "heal",
	heal_name = "Dark Mending Alert",
	heal_desc = "Warn for Dark Mending",
	
	flamespear_cmd = "flamespear",
	flamespear_name = "Flame Spear Alert",
	flamespear_desc = "Warn for Flame Spear",
	
	inspire_cmd = "inspire",
	inspire_name = "Inspire Alert",
	inspire_desc = "Warn for Inspire",
	
	shadowwordpain_cmd = "shadowwordpain",
	shadowwordpain_name = "Shadow word: Pain Alert",
	shadowwordpain_desc = "Warn for Shadow word: Pain",
	
	immolate_cmd = "immolate",
	immolate_name = "Immolate Alert",
	immolate_desc = "Warn for Immolate",
	
	adds_cmd = "adds",
	adds_name = "Add Dies Alert",
	adds_desc = "Warn for Adds Deaths",
	
	
	trigger_handOfRagnaros = "afflicted by Hand of Ragnaros.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_handOfRagnarosCd = "Hand of Ragnaros CD",
	bar_handOfRagnarosDur = "Hand of Ragnaros Stun",
	
	trigger_darkMending = "Flamewaker Priest begins to cast Dark Mending.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_darkMending = "Dark Mending",
	msg_darkMending = "Dark Mending - Interrupt!",
	
	trigger_flameSpear = "Sulfuron Harbinger begins to perform Flame Spear.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_flameSpearCd = "Flame Spear CD",
	bar_flameSpearCast = "Flame Spear!",
	
	trigger_inspire = "gains Inspire.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	bar_inspireDur = "Inspire",
	msg_inspire = "Inspire - Attack Speed +100% & Damage +25%",
	
	trigger_shadowWordPain = "(.+) is afflicted by Shadow Word: Pain.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	msg_shadowWordPain = "Shadow Word: Pain - Dispel!",
	
	trigger_immolate = "(.+) is afflicted by Immolate.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	msg_immolate = "Immolate - Dispel!",
	
	msg_addDead = "/4 Flamewaker Protectors Dead",
} end)

local timer = {
	handOfRagnarosFirstCd = 6,
	handOfRagnarosCd = 10, --12 - 2
	handOfRagnarosDur = 2,
	
	darkMendingCast = 2,
	
	flameSpearFirstCd = 2,
	flameSpearCd = {12,16},
	flameSpearCast = 1,
	
	inspireDur = 10,
}
local icon = {
	handOfRagnaros = "Spell_Fire_Fireball",
	darkMending = "Spell_Shadow_ChillTouch",
	flameSpear = "Spell_Fire_FlameBlades",
	inspire = "ability_warrior_battleshout",
	shadowWordPain = "spell_shadow_shadowwordpain",
	immolate = "spell_fire_immolation",
}
local color = {
	handOfRagnarosCd = "Black",
	handOfRagnarosDur = "White",
	
	darkMendingCast = "Green",
	
	flameSpearCd = "Red",
	flameSpearCast = "Orange",
	
	inspire = "Blue",
}
local syncName = {
	handOfRagnaros = "SulfuronKnockback"..module.revision,
	darkMending = "SulfuronAddHeal"..module.revision,
	flameSpear = "SulfuronSpear"..module.revision,
	inspire = "SulfuronInspire"..module.revision,
	shadowWordPain = "SulfuronShadowWordPain"..module.revision,
	immolate = "SulfuronImmolate"..module.revision,
	addDead = "SulfuronAddDead"..module.revision,
}

local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_handOfRagnaros, trigger_shadowWordPain
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_handOfRagnaros, trigger_shadowWordPain
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_handOfRagnaros, trigger_shadowWordPain
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_darkMending
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_flameSpear
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_inspire
	
	
	self:ThrottleSync(1, syncName.darkMending)
	self:ThrottleSync(5, syncName.handOfRagnaros)
	self:ThrottleSync(5, syncName.flameSpear)
	self:ThrottleSync(3, syncName.inspire)
	self:ThrottleSync(3, syncName.shadowWordPain)
	self:ThrottleSync(3, syncName.immolate)
	self:ThrottleSync(0.5, syncName.addDead)
	
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --addDead
end

function module:OnEngage()
	addDead = 0
	
	if self.db.profile.knockback then
		self:Bar(L["bar_handOfRagnarosCd"], timer.handOfRagnarosFirstCd, icon.handOfRagnaros, true, color.handOfRagnarosCd)
	end
	if self.db.profile.flamespear then
		self:Bar(L["bar_flameSpearCd"], timer.flameSpearFirstCd, icon.flameSpear, true, color.flameSpearCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Flamewaker Priest")) then
		addDead = addDead + 1
		if addDead <= 4 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_handOfRagnaros"]) then
		self:Sync(syncName.handOfRagnaros)
	
	elseif msg == L["trigger_darkMending"] then
		self:Sync(syncName.darkMending)
	
	elseif msg == L["trigger_flameSpear"] then
		self:Sync(syncName.flameSpear)
		
	elseif string.find(msg, L["trigger_inspire"]) then
		self:Sync(syncName.inspire)
		
	elseif string.find(msg, L["trigger_shadowWordPain"]) then
		local _,_, swpPerson, _ = string.find(msg, L["trigger_shadowWordPain"])
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == swpPerson then
				self:Sync(syncName.shadowWordPain)
				break
			end
		end
		
	elseif string.find(msg, L["trigger_immolate"]) then
		local _,_, immolatePerson, _ = string.find(msg, L["trigger_immolate"])
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == immolatePerson then
				self:Sync(syncName.immolate)
				break
			end
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.handOfRagnaros and self.db.profile.knockback then
		self:HandOfRagnaros()
	
	elseif sync == syncName.darkMending and self.db.profile.heal then
		self:DarkMending()
	
	elseif sync == syncName.flameSpear and self.db.profile.flamespear then
		self:FlameSpear()
	
	elseif sync == syncName.inspire and self.db.profile.inspire then
		self:Inspire()
		
	elseif sync == syncName.shadowWordPain and self.db.profile.shadowwordpain then
		self:ShadowWordPain()
		
	elseif sync == syncName.immolate and self.db.profile.immolate then
		self:Immolate()
		
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
	end
end


function module:HandOfRagnaros()
	self:RemoveBar(L["bar_handOfRagnarosCd"])
	
	self:Bar(L["bar_handOfRagnarosDur"], timer.handOfRagnarosDur, icon.handOfRagnaros, true, color.handOfRagnarosDur)
	self:DelayedBar(timer.handOfRagnarosDur, L["bar_handOfRagnarosCd"], timer.handOfRagnarosCd, icon.handOfRagnaros, true, color.handOfRagnarosCd)
end

function module:DarkMending()
	self:Bar(L["bar_darkMending"], timer.darkMendingCast, icon.darkMending, true, color.darkMendingCast)
	
	if UnitClass("Player") == "Rogue" or UnitClass("Player") == "Warrior" or UnitClass("Player") == "Mage" then
		self:Message(L["msg_darkMending"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.darkMending, 0.7)
	end
end

function module:FlameSpear()
	self:RemoveBar(L["bar_flameSpearCd"])
	
	self:Bar(L["bar_flameSpearCast"], timer.flameSpearCast, icon.flameSpear, true, color.flameSpearCast)
	self:DelayedIntervalBar(timer.flameSpearCast, L["bar_flameSpearCd"], timer.flameSpearCd[1], timer.flameSpearCd[2], icon.flameSpear, true, color.flameSpearCd)
end

function module:Inspire()
	self:Bar(L["bar_inspireDur"], timer.inspireDur, icon.inspire, true, color.inspire)
	self:Message(L["msg_inspire"], "Attention", false, nil, false)
end

function module:ShadowWordPain()
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(L["msg_shadowWordPain"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.shadowWordPain, 0.7)
	end
end

function module:Immolate()
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(L["msg_immolate"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.immolate, 0.7)
	end
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
end
