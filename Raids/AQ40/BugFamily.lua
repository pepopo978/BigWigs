
local module, L = BigWigs:ModuleDeclaration("The Bug Family", "Ahn'Qiraj")

local kri = AceLibrary("Babble-Boss-2.2")["Lord Kri"]
local yauj = AceLibrary("Babble-Boss-2.2")["Princess Yauj"]
local vem = AceLibrary("Babble-Boss-2.2")["Vem"]

module.revision = 30077
module.enabletrigger = {kri, yauj, vem}
module.toggleoptions = {"panic", "volley", "heal", "enrage", "vapors", "deathspecials", "bosskill"}

module.defaultDB = {
	enrage = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "BugFamily",
	
	panic_cmd = "panic",
	panic_name = "Fear",
	panic_desc = "Warn for Princess Yauj's Panic.",

	volley_cmd = "volley",
	volley_name = "Toxic Volley",
	volley_desc = "Warn for Lord Kri's Toxic Volley.",

	heal_cmd = "heal",
	heal_name = "Great Heal",
	heal_desc = "Announce Princess Yauj's heals.",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Enrage timers.",
	
	vapors_cmd = "vapors",
	vapors_name = "Vapors Cloud Alert",
	vapors_desc = "Warn if you are standing in the Toxic Vapors Cloud.",
	
	deathspecials_cmd = "deathspecials",
	deathspecials_name = "Death Specials",
	deathspecials_desc = "Lets people know which boss has been killed and what special abilities they do.",


	trigger_panic = "afflicted by Panic",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_panicResist = "Panic was resisted",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE
	trigger_panicImmune = "Panic fails",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_panic = "Panic CD",
	
	trigger_volleyHit = "Toxic Volley hits",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	trigger_volleyAfflicted = "afflicted by Toxic Volley",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_volleyResist = "Toxic Volley was resisted",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE
	trigger_volleyImmune = "Toxic Volley fail",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_volley = "Toxic Volley",
	
	trigger_heal = "Princess Yauj begins to cast Great Heal.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_heal = "Great Heal",
	msg_heal = "Yauj Casting Heal - Interrupt!",
	
	trigger_attack1 = "Princess Yauj attacks", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES
	trigger_attack2 = "Princess Yauj misses", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES
	trigger_attack3 = "Princess Yauj hits", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS
	trigger_attack4 = "Princess Yauj crits", --CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS
	trigger_kick1 = "Kick hits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_kick2 = "Kick crits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_kick3 = "Kick was blocked by Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_pummel1 = "Pummel hits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_pummel2 = "Pummel crits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_pummel3 = "Pummel was blocked by Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_shieldBash1 = "Shield Bash hits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_shieldBash2 = "Shield Bash crits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_shieldBash3 = "Shield Bash was blocked by Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_earthShock1 = "Earth Shock hits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	trigger_earthShock2 = "Earth Shock crits Princess Yauj", --CHAT_MSG_SPELL_SELF_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE
	
	trigger_enrage = "%s goes into a berserker rage!",--CHAT_MSG_MONSTER_EMOTE (not confirmed)
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 60 seconds!",
	msg_enrage10 = "Enrage in 10 seconds!",
	msg_enrage = "Enraged!",

	trigger_toxicVapors = "You are afflicted by Toxic Vapors.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_toxicVaporsFade = "Toxic Vapors fades from you.",--CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_toxicVapors = "Move away from the Poison Cloud!",
	
	msg_kriDead = "Kri is Dead - POISON CLOUD!",
	msg_yaujDead = "Yauj is Dead - KILL THE SPAWNS!",
	msg_vemDead = "Vem is Dead - ENRAGE!",	
} end )

local timer = {
	earliestFirstPanic = 10,
	latestFirstPanic = 20,
	panic = 20,
	
	earliestFirstVolley = 8,
	latestFirstVolley = 10,
	earliestVolley = 8,
	latestVolley = 14,
	
	heal = 2,
	enrage = 900,
}
local icon = {
	panic = "Spell_Shadow_DeathScream",
	volley = "Spell_Nature_Corrosivebreath",
	heal = "Spell_Holy_Heal",
	enrage = "Spell_Shadow_UnholyFrenzy",
	toxicVapors = "Spell_Nature_AbolishMagic",
}
local color = {
	panic = "White",
	volley = "Green",
	heal = "Yellow",
	enrage = "Black",
}
local syncName = {
	panic = "BugTrioYaujPanic"..module.revision,
	volley = "BugTrioKriVolley"..module.revision,
	heal = "BugTrioYaujHealStart"..module.revision,
	healStop = "BugTrioYaujHealStop"..module.revision,
	enrage = "BugTrioEnraged"..module.revision,
	kriDead = "BugTrioKriDead"..module.revision,
	yaujDead = "BugTrioYaujDead"..module.revision,
	vemDead = "BugTrioVemDead"..module.revision,
	allDead = "BugTrioAllDead"..module.revision,
}

local kriDead = nil
local yaujDead = nil
local vemDead = nil
local castingHeal = false

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--trigger_heal
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")--trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")--trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")--trigger_attack1, trigger_attack2
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")--trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")--trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")--trigger_attack3, trigger_attack4
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")--trigger_kick1,2,3, trigger_pummel1,2,3, trigger_shieldBash1,2,3, trigger_earthShock1,2
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")--trigger_kick1,2,3, trigger_pummel1,2,3, trigger_shieldBash1,2,3, trigger_earthShock1,2
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_kick1,2,3, trigger_pummel1,2,3, trigger_shieldBash1,2,3, trigger_earthShock1,2
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_volleyHit
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_volleyHit, trigger_volleyResist, trigger_volleyImmune, trigger_panicResist, trigger_panicImmune
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_volleyHit, trigger_volleyResist, trigger_volleyImmune, trigger_panicResist, trigger_panicImmune
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_panic, trigger_panicImmune, trigger_volleyImmune, trigger_toxicVapors
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_volleyAfflicted, trigger_panic
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_volleyAfflicted, trigger_panic
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_toxicVaporsFade
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--trigger_enrage
	
	
	self:ThrottleSync(5, syncName.panic)
	self:ThrottleSync(5, syncName.volley)
	self:ThrottleSync(5, syncName.heal)
	self:ThrottleSync(5, syncName.healStop)
	self:ThrottleSync(5, syncName.enrage)
	
	self:ThrottleSync(5, syncName.kriDead)
	self:ThrottleSync(5, syncName.yaujDead)
	self:ThrottleSync(5, syncName.vemDead)
	self:ThrottleSync(5, syncName.allDead)
end

function module:OnSetup()
	self.started = nil
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	kriDead = nil
	vemDead = nil
	yaujDead = nil
	castingHeal = false
	
	if self.db.profile.panic then
		self:IntervalBar(L["bar_panic"], timer.earliestFirstPanic, timer.latestFirstPanic, icon.panic, true, color.panic)
	end
	
	if self.db.profile.volley then
		self:IntervalBar(L["bar_volley"], timer.earliestFirstVolley, timer.latestFirstVolley, icon.volley, true, color.volley)
	end
	
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, color.enrage)
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Attention", false, nil, false)
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Attention", false, nil, false)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if msg == string.format(UNITDIESOTHER, kri) then
		self:Sync(syncName.kriDead)
	elseif msg == string.format(UNITDIESOTHER, yauj) then
		self:Sync(syncName.yaujDead)
	elseif msg == string.format(UNITDIESOTHER, vem) then
		self:Sync(syncName.vemDead)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_panic"]) or string.find(msg, L["trigger_panicResist"]) or string.find(msg, L["trigger_panicImmune"]) then
		self:Sync(syncName.panic)
	
	elseif string.find(msg, L["trigger_volleyHit"]) or string.find(msg, L["trigger_volleyAfflicted"]) or string.find(msg, L["trigger_volleyImmune"]) or string.find(msg, L["trigger_volleyResist"]) then
		self:Sync(syncName.volley)
	
	
	elseif msg == L["trigger_heal"] then
		self:Sync(syncName.heal)
	
	elseif castingHeal == true and (string.find(msg, L["trigger_attack1"]) or string.find(msg, L["trigger_attack2"]) or string.find(msg, L["trigger_attack3"]) or string.find(msg, L["trigger_attack4"])
		or string.find(msg, L["trigger_kick1"]) or string.find(msg, L["trigger_kick2"]) or string.find(msg, L["trigger_kick3"]) -- kicked
		or string.find(msg, L["trigger_pummel1"]) or string.find(msg, L["trigger_pummel2"]) or string.find(msg, L["trigger_pummel3"]) -- pummeled
		or string.find(msg, L["trigger_shieldBash1"]) or string.find(msg, L["trigger_shieldBash2"]) or string.find(msg, L["trigger_shieldBash3"]) -- shield bashed
		or string.find(msg, L["trigger_earthShock1"]) or string.find(msg, L["trigger_earthShock2"])) then -- earth shocked
		self:Sync(syncName.healStop)
	
	
	elseif string.find(msg, L["trigger_toxicVapors"]) and self.db.profile.vapors then
		self:ToxicVapors()
	elseif string.find(msg, L["trigger_toxicVaporsFade"]) and self.db.profile.vapors then
		self:ToxicVaporsFade()
	
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.panic and self.db.profile.panic then
		self:Panic()
	
	elseif sync == syncName.volley and self.db.profile.volley then
		self:Volley()
	
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	elseif sync == syncName.healStop and self.db.profile.heal then
		self:HealStop()
	
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.kriDead then
		self:KriDead()
	elseif sync == syncName.yaujDead then
		self:YaujDead()
	elseif sync == syncName.vemDead then
		self:VemDead()
	elseif sync == syncName.allDead then
		self:SendBossDeathSync()
	end
end

function module:Volley()
	self:IntervalBar(L["bar_volley"], timer.earliestVolley, timer.latestVolley, icon.volley, true, color.volley)
end

function module:Heal()
	castingHeal = true
	
	self:Bar(L["bar_heal"], timer.heal, icon.heal, true, color.heal)
	self:Message(L["msg_heal"], "Attention", false, nil, false)
	
	if UnitClass("Player") == "Rogue" or UnitClass("Player") == "Warrior" or UnitClass("Player") == "Mage" then
		if UnitName("Target") == "Princess Yauj" then
			self:WarningSign(icon.heal, timer.heal)
			self:Sound("Beware")
		else
			self:Sound("Alert")
		end
	end
end

function module:HealStop()
	castingHeal = false
	
	self:RemoveBar(L["bar_heal"])
	self:RemoveWarningSign(icon.heal)
end

function module:Panic()
	self:RemoveBar(L["bar_panic"])
	self:Bar(L["bar_panic"], timer.panic, icon.panic, true, color.panic)
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:Message(L["msg_enrage"], "Important", false, nil, false)
end

function module:KriDead()
	kriDead = true
	if vemDead and yaujDead then
		self:Sync(syncName.allDead)
	else
		if self.db.profile.volley then
			self:RemoveBar(L["bar_volley"])
		end
		if self.db.profile.deathspecials then
			self:Message(L["msg_kriDead"], "Positive", false, nil, false)
		end
	end
end

function module:YaujDead()
	yaujDead = true
	if vemDead and kriDead then
		self:Sync(syncName.allDead)
	else
		if self.db.profile.heal then
			self:RemoveBar(L["bar_heal"])
		end
		if self.db.profile.panic then
			self:RemoveBar(L["bar_panic"])
		end
		if self.db.profile.deathspecials then
			self:Message(L["msg_yaujDead"], "Positive", false, nil, false)
		end
	end	
end

function module:VemDead()
	vemDead = true
	if yaujDead and kriDead then
		self:Sync(syncName.allDead)
	else
		if self.db.profile.deathspecials then
			self:Message(L["msg_vemDead"], "Positive", false, nil, false)
		end
	end	
end

function module:ToxicVapors()
	self:WarningSign(icon.toxicVapors, 10)
	self:Sound("RunAway")
	self:Message(L["msg_toxicVapors"], "Urgent", false, nil, false)
end

function module:ToxicVaporsFade()
	self:RemoveWarningSign(icon.toxicVapors)
end
