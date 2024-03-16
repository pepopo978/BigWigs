
local module, L = BigWigs:ModuleDeclaration("Hazza'rah", "Zul'Gurub")

module.revision = 30063
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "sleep", "chainburn", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Hazzarah",
	
	adds_cmd = "adds",
	adds_name = "Nightmare Illusions Adds Alert",
	adds_desc = "Warns for Nightmare Illusions Adds.",
	
	sleep_cmd = "sleep",
	sleep_name = "Sleep Alert",
	sleep_desc = "Warns for Sleep.",
	
	chainburn_cmd = "chainburn",
	chainburn_name = "Chain Burn Alert",
	chainburn_desc = "Warns for Chain Burn.",
	
	
	trigger_addsSpawn = "Hazza'rah casts Summon Nightmare Illusions.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_adds = "Adds Spawn",
	bar_addsCounter = "Adds Dead",
	msg_addsSpawn = "3 Nightmare Illusions - Ranged, Kill the Adds! ",
	
	trigger_sleep = "afflicted by Sleep", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_sleepCd = "Sleep CD",
	bar_sleepAfflic = "Sleeping!",
	msg_sleep = "Sleep - Tremor Totem!",
	
		--did not see, wild guessing
	trigger_chainBurn = "Chain Burn hit", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_chainBurn = "AoE Mana Burn CD",
	msg_chainBurn = "AoE Mana Burn - Drain his Mana!",
} end )

local timer = {
	firstAdds = 21,
	adds = 24,
	
	firstSleepCd = 10,
	sleepCd = 18, --24 - 6sec afflic
	sleepAfflic = 6,
	
	chainBurn = 60,
}
local icon = {
	adds = "spell_magic_lesserinvisibilty",
	sleep = "spell_nature_sleep",
	chainBurn = "spell_shadow_manaburn",
	
	viperSting = "ability_hunter_aimedshot",
	manaDrain = "spell_shadow_siphonmana",
	manaBurn = "spell_shadow_manaburn",
	
	tremor = "spell_nature_tremortotem",
}
local color = {
	adds = "Black",
	addsCounter = "Cyan",
	sleep = "Blue",
	chainBurn = "Red",
}
local syncName = {
	addsSpawn = "HazzarahAddsSpawn"..module.revision,
	addsDead = "HazzarahAddsDead"..module.revision,
	sleep = "HazzarahSleep"..module.revision,
	chainBurn = "HazzarahChainBurn"..module.revision,
}

local addDeadCount = 0
local addDeadCounter = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_addsSpawn
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_sleep
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_sleep
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_sleep

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_chainBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_chainBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_chainBurn


	self:ThrottleSync(5, syncName.addsSpawn)
	self:ThrottleSync(5, syncName.addsDead)
	self:ThrottleSync(5, syncName.sleep)
	self:ThrottleSync(5, syncName.chainBurn)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --addsDead 
	
	self.started = nil
end

function module:OnEngage()
	addDeadCount = 0
	addDeadCounter = 0
	
	if self.db.profile.sleep then
		self:Bar(L["bar_sleepCd"], timer.firstSleepCd, icon.sleep, true, color.sleep)
	end
	
	if self.db.profile.adds then
		self:Bar(L["bar_adds"], timer.firstAdds, icon.adds, true, color.adds)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	
	if (msg == string.format(UNITDIESOTHER, "Nightmare Illusion")) and self.db.profile.adds then
		self:OneAddDead()
	end
end

function module:Event(msg)
	if msg == L["trigger_addsSpawn"] then
		self:Sync(syncName.addsSpawn)
	
	elseif string.find(msg, L["trigger_sleep"]) then
		self:Sync(syncName.sleep)
	
	elseif string.find(msg, L["trigger_chainBurn"]) then
		self:Sync(syncName.chainBurn)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.addsSpawn and self.db.profile.adds then
		self:AddsSpawn()
	elseif sync == syncName.addsDead and self.db.profile.adds then
		self:AddsDead()
	elseif sync == syncName.sleep and self.db.profile.sleep then
		self:Sleep()
	elseif sync == syncName.chainBurn and self.db.profile.chainburn then
		self:ChainBurn()
	end
end

function module:AddsSpawn()
	self:RemoveBar(L["bar_adds"])
	
	self:Bar(L["bar_adds"], timer.adds, icon.adds, true, color.adds)
	self:Message(L["msg_addsSpawn"], "Urgent", false, nil, false)
	
	self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_addsCounter"], 3, "Interface\\Icons\\"..icon.adds, true, color.addsCounter)
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_addsCounter"], (3 - 0.1))
end

function module:OneAddDead()
	addDeadCount = addDeadCount + 1
	if addDeadCount >= 3 then
		self:Sync(syncName.addsDead)
	else
		addDeadCounter = 3 - addDeadCount
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_addsCounter"], addDeadCounter)
	end
end

function module:AddsDead()
	addDeadCount = 0
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_addsCounter"], 3)
end

function module:Sleep()
	self:RemoveBar(L["bar_sleepCd"])
	
	self:Bar(L["bar_sleepAfflic"], timer.sleepAfflic, icon.sleep, true, color.sleep)
	self:Message(L["msg_sleep"], "Attention", false, nil, false)
	
	if UnitClass("Player") == "Shaman" then
		self:WarningSign(icon.tremor, 1)
	end
	
	self:DelayedBar(timer.sleepAfflic, L["bar_sleepCd"], timer.sleepCd, icon.sleep, true, color.sleep)
end

function module:ChainBurn()
	self:Bar(L["bar_chainBurn"], timer.chainBurn, icon.chainBurn, true, color.chainBurn)
	self:Message(L["msg_chainBurn"], "Attention", false, nil, false)
	
	if UnitClass("Player") == "Hunter" then
		self:WarningSign(icon.viperSting, 1)
	elseif UnitClass("Player") == "Warlock" then
		self:WarningSign(icon.manaDrain, 1)
	elseif UnitClass("Player") == "Priest" then
		self:WarningSign(icon.manaBurn, 1)
	end
end
