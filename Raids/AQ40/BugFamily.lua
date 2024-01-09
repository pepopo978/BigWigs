
local module, L = BigWigs:ModuleDeclaration("The Bug Family", "Ahn'Qiraj")

local kri = AceLibrary("Babble-Boss-2.2")["Lord Kri"]
local yauj = AceLibrary("Babble-Boss-2.2")["Princess Yauj"]
local vem = AceLibrary("Babble-Boss-2.2")["Vem"]

module.revision = 30039
module.enabletrigger = {kri, yauj, vem}
module.toggleoptions = {"panic", "toxicvolley", "heal", "announce", "deathspecials", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "BugFamily",
	
	panic_cmd = "panic",
	panic_name = "Fear",
	panic_desc = "Warn for Princess Yauj's Panic.",

	toxicvolley_cmd = "toxicvolley",
	toxicvolley_name = "Toxic Volley",
	toxicvolley_desc = "Warn for Lord Kri's Toxic Volley.",

	heal_cmd = "heal",
	heal_name = "Great Heal",
	heal_desc = "Announce Princess Yauj's heals.",

	announce_cmd = "announce",
	announce_name = "Poison Cloud",
	announce_desc = "Whispers players that stand in the Poison Cloud.\n\n(Requires assistant or higher)",

	deathspecials_cmd = "deathspecials",
	deathspecials_name = "Death Specials",
	deathspecials_desc = "Lets people know which boss has been killed and what special abilities they do.",

	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Enrage timers.",
	
	trigger_heal = "Princess Yauj begins to cast Great Heal.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_heal = "Great Heal",
	msg_heal = "Casting heal!",
	
	trigger_attack1 = "Princess Yauj attacks",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES
	trigger_attack2 = "Princess Yauj misses",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES
	trigger_attack3 = "Princess Yauj hits",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS
	trigger_attack4 = "Princess Yauj crits",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS
	
	trigger_toxicVolleyHit = "Toxic Volley hits",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	trigger_toxicVolleyAfflicted = "afflicted by Toxic Volley",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_toxicVolleyResist = "Toxic Volley was resisted",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE
	trigger_toxicVolleyImmune = "Toxic Volley fail",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_toxicVolley = "Toxic Volley",

	trigger_panic = "afflicted by Panic",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_panicResist = "Panic was resisted",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE
	trigger_panicImmune = "Panic fails",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_panic = "Panic",

	trigger_toxicVapors = "You suffer (.*) Nature damage from Ruklar the Trapper's Toxic Vapors.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_toxicVapors = "Move away from the Poison Cloud!",
	
	trigger_enrage = "%s goes into a berserker rage!",--CHAT_MSG_MONSTER_EMOTE (not confirmed)
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 60 seconds!",
	msg_enrage10 = "Enrage in 10 seconds!",
	msg_enrage = "Enraged!",
	
	msg_kriDead = "Kri is dead, POISON CLOUD!",
	msg_yaujDead = "Yauj is dead, KILL THE SPAWNS!",
	msg_vemDead = "Vem is dead, ENRAGE!",	
} end )

local timer = {
	earliestFirstPanic = 10,
	latestFirstPanic = 20,
	panic = 20,
	earliestFirstVolley = 8,
	latestFirstVolley = 10,
	earliestVolley = 8,
	latestVolley = 14,
	enrage = 900,
	heal = 2,
}
local icon = {
	panic = "Spell_Shadow_DeathScream",
	volley = "Spell_Nature_Corrosivebreath",
	enrage = "Spell_Shadow_UnholyFrenzy",
	heal = "Spell_Holy_Heal",
	toxicVapors = "Spell_Nature_AbolishMagic",
}
local syncName = {
	volley = "BugTrioKriVolley"..module.revision,
	heal = "BugTrioYaujHealStart"..module.revision,
	healStop = "BugTrioYaujHealStop"..module.revision,
	panic = "BugTrioYaujPanic"..module.revision,
	enrage = "BugTrioEnraged"..module.revision,
	kriDead = "BugTrioKriDead"..module.revision,
	yaujDead = "BugTrioYaujDead"..module.revision,
	vemDead = "BugTrioVemDead"..module.revision,
	allDead = "BugTrioAllDead"..module.revision,
}

local kridead = nil
local vemdead = nil
local yaujdead = nil
local healtime = 0
local castingheal = false

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--trigger_heal
	
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")--trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")--trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")--trigger_attack1, trigger_attack2
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")--trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")--trigger_attack3, trigger_attack4
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")--trigger_attack3, trigger_attack4
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_toxicVolleyHit, trigger_toxicVolleyResist, trigger_toxicVolleyImmune, trigger_panicResist, trigger_panicImmune
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_toxicVolleyHit, trigger_toxicVolleyResist, trigger_toxicVolleyImmune, trigger_panicResist, trigger_panicImmune
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_toxicVolleyHit
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_toxicVolleyAfflicted, trigger_panic
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_toxicVolleyAfflicted, trigger_panic
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_panic, trigger_panicImmune, trigger_toxicVolleyImmune, trigger_toxicVapors
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--trigger_enrage
	
	self:ThrottleSync(5, syncName.volley)
	self:ThrottleSync(5, syncName.heal)
	self:ThrottleSync(5, syncName.healStop)
	self:ThrottleSync(5, syncName.panic)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.kriDead)
	self:ThrottleSync(5, syncName.yaujDead)
	self:ThrottleSync(5, syncName.vemDead)
	self:ThrottleSync(5, syncName.allDead)
end

function module:OnSetup()
	self.started = nil
	kridead = nil
	vemdead = nil
	yaujdead = nil
	healtime = 0
	castingheal = false

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.db.profile.panic then
		self:IntervalBar(L["bar_panic"], timer.earliestFirstPanic, timer.latestFirstPanic, icon.panic, true, "white")
	end
	if self.db.profile.toxicvolley then
		self:IntervalBar(L["bar_toxicVolley"], timer.earliestFirstVolley, timer.latestFirstVolley, icon.volley, true, "green")
	end
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, "red")
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Attention", nil, nil, true)
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Attention", nil, nil, true)
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
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	elseif string.find(msg, L["trigger_attack1"]) or string.find(msg, L["trigger_attack2"]) or string.find(msg, L["trigger_attack3"]) or string.find(msg, L["trigger_attack4"]) then
		if castingheal then
			if (GetTime() - healtime) < timer.heal then
				self:Sync(syncName.healStop)
			elseif (GetTime() - healtime) >= timer.heal then
				castingheal = false
			end
		end
	elseif string.find(msg, L["trigger_panic"]) or string.find(msg, L["trigger_panicResist"]) or string.find(msg, L["trigger_panicImmune"]) then
		self:Sync(syncName.panic)
	elseif string.find(msg, L["trigger_toxicVolleyHit"]) or string.find(msg, L["trigger_toxicVolleyAfflicted"]) or string.find(msg, L["trigger_toxicVolleyImmune"]) or string.find(msg, L["trigger_toxicVolleyResist"]) then
		self:Sync(syncName.volley)
	elseif string.find(msg, L["trigger_toxicVapors"]) then
		self:WarningSign(icon.toxicVapors, 0.7)
		self:Sound("Info")
		self:Message(L["msg_toxicVapors"], "Urgent")
	elseif msg == L["trigger_heal"] then
		self:Sync(syncName.heal)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.volley and self.db.profile.toxicvolley then
		self:Volley()
	elseif sync == syncName.heal and self.db.profile.heal then
		self:Heal()
	elseif sync == syncName.healStop and self.db.profile.heal then
		self:HealStop()
	elseif sync == syncName.panic and self.db.profile.panic then
		self:Panic()
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
	self:IntervalBar(L["bar_toxicVolley"], timer.earliestVolley, timer.latestVolley, icon.volley, true, "green")
end

function module:Heal()
	healtime = GetTime()
	castingheal = true
	
	self:Bar(L["bar_heal"], timer.heal, icon.heal, true, "yellow")
	self:Message(L["msg_heal"], "Attention", true, "Alert")
	
	if UnitClass("Player") == "Rogue" or UnitClass("Player") == "Warrior" or UnitClass("Player") == "Mage" then
		if UnitName("Target") == "Princess Yauj" then
			self:WarningSign(icon.heal, 1)
			self:Sound("Beware")
		end
	end
end

function module:HealStop()
	castingheal = false
	
	self:RemoveBar(L["bar_heal"])
end

function module:Panic()
	self:RemoveBar(L["bar_panic"])
	self:Bar(L["bar_panic"], timer.panic, icon.panic, true, "white")
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important")
end

function module:KriDead()
	kridead = true
	if self.db.profile.toxicvolley then
		self:RemoveBar(L["bar_toxicVolley"])
	end
	if self.db.profile.deathspecials then
		self:Message(L["msg_kriDead"], "Positive")
	end
	if vemdead and yaujdead then
		self:Sync(syncName.allDead)
	end
end

function module:YaujDead()
	yaujdead = true
	if self.db.profile.heal then
		self:RemoveBar(L["bar_heal"])
	end
	if self.db.profile.panic then
		self:RemoveBar(L["bar_panic"])
	end
	if self.db.profile.deathspecials then
		self:Message(L["msg_yaujDead"], "Positive")
	end
	if vemdead and kridead then
		self:Sync(syncName.allDead)
	end
end

function module:VemDead()
	vemdead = true
	
	if self.db.profile.deathspecials then
		self:Message(L["msg_vemDead"], "Positive")
	end
	if yaujdead and kridead then
		self:Sync(syncName.allDead)
	end
end
