local module, L = BigWigs:ModuleDeclaration("Time-Lord Epochronos", "The Black Morass")

module.revision = 30035
module.enabletrigger = module.translatedName
module.toggleoptions = { "sandbreath", "banish", "dnd", "devouringplague", "deathcoil", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["The Black Morass"],
	AceLibrary("Babble-Zone-2.2")["The Black Morass"],
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "TimeLordEpochronos",

		sandbreath_cmd = "sandbreath",
		sandbreath_name = "Sand Breath Alert",
		sandbreath_desc = "Warn for Sand Breath",

		banish_cmd = "banish",
		banish_name = "Banish Alert",
		banish_desc = "Warns for Banish",

		dnd_cmd = "dnd",
		dnd_name = "Death & Decay Alert",
		dnd_desc = "Warns for Death & Decay",

		devouringplague_cmd = "devouringplague",
		devouringplague_name = "Devouring Plague Alert",
		devouringplague_desc = "Warns for Devouring Plague",

		deathcoil_cmd = "deathcoil",
		deathcoil_name = "Death Coil Alert",
		deathcoil_desc = "Warns for Death Coil",


		trigger_engage = "Time moves in our favor, your intrusion ends here!", --CHAT_MSG_MONSTER_YELL

		trigger_sandBreath = "Time-Lord Epochronos begins to perform Sand Breath.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_sandBreathCast = "Sand Breath Cast",
		bar_sandBreathCd = "Sand Breath CD",

		trigger_lkSpawn = "Time-Lord Epochronos is afflicted by Banish.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
		trigger_banishFade = "Banish fades from Time-Lord Epochronos.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_banish = "Banish",
		msg_banish = "Kill the Spawned Mini-Boss!",

		trigger_dndCast = "Echo of the Lich King begins to cast Death & Decay.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_dndCast = "Casting Death & Decay",
		msg_dndCast = "Casting Death & Decay, Interrupt!",

		--to be confirmed
		trigger_dndDamage = "You suffer (.+) Shadow damage from Death & Decay.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE

		trigger_devouringPlagueYou = "You are afflicted by Devouring Plague.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_devouringPlagueOther = "(.+) is afflicted by Devouring Plague.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
		trigger_devouringPlagueFade = "Devouring Plague fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_devouringPlague = " Devouring Plague",

		trigger_deathCoilYou = "You are afflicted by Death Coil.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_deathCoilOther = "(.+) is afflicted by Death Coil.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_deathCoilFade = "Death Coil fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_deathCoil = " Death Coil",

		--Lady Vashj -> Thunderstorm Cloud -> CLOG
	}
end)

local timer = {
	sandBreathCast = 2,
	sandBreathCd = 13,
	banish = 30,
	dndCast = 3,
	devouringPlague = 30, --to be confirmed
	deathCoil = 3,
}
local icon = {
	sandBreath = "spell_fire_windsofwoe",
	banish = "spell_shadow_cripple",
	dndCast = "spell_shadow_deathanddecay",
	devouringPlague = "spell_shadow_shadetruesight",
	deathCoil = "spell_shadow_deathcoil",
}
local color = {
	sandBreathCast = "Red",
	sandBreathCd = "White",
	banish = "Black",
	dndCast = "Red",
	devouringPlague = "Blue",
	deathCoil = "Green",
}
local syncName = {
	sandBreath = "TimeLordEpochronosSandBreath" .. module.revision,
	banish = "TimeLordEpochronosBanish" .. module.revision,
	banishFade = "TimeLordEpochronosBanishFade" .. module.revision,
	dndCast = "TimeLordEpochronosDndCast" .. module.revision,
	devouringPlague = "TimeLordEpochronosDevouringPlague" .. module.revision,
	devouringPlagueFade = "TimeLordEpochronosDevouringPlagueFade" .. module.revision,
	deathCoil = "TimeLordEpochronosDeathCoil" .. module.revision,
	deathCoilFade = "TimeLordEpochronosDeathCoilFade" .. module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_dndDamage, trigger_devouringPlagueYou, trigger_deathCoilYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_devouringPlagueOther, trigger_deathCoilOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_devouringPlagueOther, trigger_deathCoilOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_banishFade, trigger_devouringPlagueFade, trigger_deathCoilFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_devouringPlagueFade, trigger_deathCoilFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_devouringPlagueFade, trigger_deathCoilFade

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_sandBreath, trigger_dndCast

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")--trigger_lkSpawn

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage

	self:ThrottleSync(5, syncName.sandBreath)
	self:ThrottleSync(5, syncName.banish)
	self:ThrottleSync(5, syncName.banishFade)
	self:ThrottleSync(5, syncName.dndCast)
	self:ThrottleSync(3, syncName.devouringPlague)
	self:ThrottleSync(3, syncName.devouringPlagueFade)
	self:ThrottleSync(3, syncName.deathCoil)
	self:ThrottleSync(3, syncName.deathCoilFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	end
end

function module:Event(msg)
	if msg == L["trigger_sandBreath"] then
		self:Sync(syncName.sandBreath)

	elseif msg == L["trigger_lkSpawn"] then
		self:Sync(syncName.banish)

	elseif msg == L["trigger_banishFade"] then
		self:Sync(syncName.banishFade)

	elseif msg == L["trigger_dndCast"] then
		self:Sync(syncName.dndCast)

	elseif string.find(msg, L["trigger_dndDamage"]) then
		self:DndDamage()


	elseif msg == L["trigger_devouringPlagueYou"] then
		self:Sync(syncName.devouringPlague .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_devouringPlagueOther"]) then
		local _, _, devouringPlaguePlayer, _ = string.find(msg, L["trigger_devouringPlagueOther"])
		self:Sync(syncName.devouringPlague .. " " .. devouringPlaguePlayer)

	elseif string.find(msg, L["trigger_devouringPlagueFade"]) then
		local _, _, devouringPlagueFadePlayer, _ = string.find(msg, L["trigger_devouringPlagueFade"])
		if devouringPlagueFadePlayer == "you" then
			devouringPlagueFadePlayer = UnitName("Player")
		end
		self:Sync(syncName.devouringPlagueFade .. " " .. devouringPlagueFadePlayer)


	elseif msg == L["trigger_deathCoilYou"] then
		self:Sync(syncName.deathCoil .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_deathCoilOther"]) then
		local _, _, deathCoilPlayer, _ = string.find(msg, L["trigger_deathCoilOther"])
		self:Sync(syncName.deathCoil .. " " .. deathCoilPlayer)

	elseif string.find(msg, L["trigger_deathCoilFade"]) then
		local _, _, deathCoilFadePlayer, _ = string.find(msg, L["trigger_deathCoilFade"])
		if deathCoilFadePlayer == "you" then
			deathCoilFadePlayer = UnitName("Player")
		end
		self:Sync(syncName.deathCoilFade .. " " .. deathCoilFadePlayer)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sandBreath and self.db.profile.sandbreath then
		self:SandBreath()
	elseif sync == syncName.banish and self.db.profile.banish then
		self:Banish()
	elseif sync == syncName.banishFade and self.db.profile.banish then
		self:BanishFade()
	elseif sync == syncName.dndCast and self.db.profile.dnd then
		self:DndCast()
	elseif sync == syncName.devouringPlague and rest and self.db.profile.devouringplague then
		self:DevouringPlague(rest)
	elseif sync == syncName.devouringPlagueFade and rest and self.db.profile.devouringplague then
		self:DevouringPlagueFade(rest)
	elseif sync == syncName.deathCoil and rest and self.db.profile.deathcoil then
		self:DeathCoil(rest)
	elseif sync == syncName.deathCoilFade and rest and self.db.profile.deathcoil then
		self:DeathCoilFade(rest)
	end
end

function module:SandBreath()
	self:RemoveBar(L["bar_sandBreathCd"])
	self:Bar(L["bar_sandBreathCast"], timer.sandBreathCast, icon.sandBreath, true, color.sandBreathCast)
	self:DelayedBar(timer.sandBreathCast, L["bar_sandBreathCd"], timer.sandBreathCd, icon.sandBreath, true, color.sandBreathCd)
end

function module:Banish()
	self:Bar(L["bar_banish"], timer.banish, icon.banish, true, color.banish)
	self:Message(L["msg_banish"], "Positive", false, nil, false)
	self:RemoveBar(L["bar_sandBreathCast"])
	self:RemoveBar(L["bar_sandBreathCd"])
	self:CancelDelayedBar(L["bar_sandBreathCd"])
end

function module:BanishFade()
	self:RemoveBar(L["bar_banish"])
end

function module:DndCast()
	self:Bar(L["bar_dndCast"], timer.dndCast, icon.dndCast, true, color.dndCast)
	self:Message(L["msg_dndCast"], "Urgent", false, nil, false)
	self:Sound("Info")
end

function module:DndDamage()
	self:WarningSign(icon.dndCast, 0.7)
	self:Sound("Info")
end

function module:DevouringPlague(rest)
	self:Bar(rest .. L["bar_devouringPlague"], timer.devouringPlague, icon.devouringPlague, true, color.devouringPlague)
end

function module:DevouringPlagueFade(rest)
	self:RemoveBar(rest .. L["bar_devouringPlague"])
end

function module:DeathCoil(rest)
	self:Bar(rest .. L["bar_deathCoil"], timer.deathCoil, icon.deathCoil, true, color.deathCoil)
end

function module:DeathCoilFade(rest)
	self:RemoveBar(rest .. L["bar_deathCoil"])
end
