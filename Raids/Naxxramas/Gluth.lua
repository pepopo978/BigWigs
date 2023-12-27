
local module, L = BigWigs:ModuleDeclaration("Gluth", "Naxxramas")

module.revision = 30030
module.enabletrigger = module.translatedName
module.toggleoptions = {"frenzy", "fear", "decimate", "enrage", "zombies", -1, "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gluth",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for fear",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for frenzy",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Timer",
	enrage_desc = "Warn for Enrage",

	decimate_cmd = "decimate",
	decimate_name = "Decimate Alert",
	decimate_desc = "Warn for Decimate",
	
	zombies_cmd = "zombies",
	zombies_name = "Zombie Spawn",
	zombies_desc = "Shows timer for zombies",
	
	trigger_frenzyGain = "%s goes into a frenzy!",--CHAT_MSG_MONSTER_EMOTE
	trigger_frenzyFade = "Frenzy fades from Gluth.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_frenzy = "Frenzy - Tranq!",
	bar_frenzyGain = "Frenzy - Tranq!",
	bar_frenzyCD = "FrenzyCD",
	
	trigger_enrage = "Gluth gains Berserk.",--to be confirmed
	msg_enrage60 = "Enrage in 60 seconds",
	msg_enrage10 = "Enrage in 10 seconds",
	msg_enrage = "Enrage!",
	bar_enrage = "Enrage",
		
	trigger_decimate = "Decimate hits",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_decimate = "Decimate!",
	msg_decimate5 = "Decimate in 5",
	bar_decimate = "Decimate",
	
	bar_zombies = "Next Zombie - %d",
		
	trigger_fear = "Terrifying Roar",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fearCD = "Fear CD",
	msg_fear = "Fear!",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Gluth",

	--fear_cmd = "fear",
	fear_name = "Alerta de Miedo",
	fear_desc = "Avisa para Miedo",

	--frenzy_cmd = "frenzy",
	frenzy_name = "Alerta de Frenesí",
	frenzy_desc = "Avisa para Frenesí",

	--enrage_cmd = "enrage",
	enrage_name = "Temporizador de Enfurecer",
	enrage_desc = "Avisa para Enfurecer",

	--decimate_cmd = "decimate",
	decimate_name = "Alerta de Diezmar",
	decimate_desc = "Avisa para Diezmar",

	frenzy_trigger = "¡%s entra frenesí!",
	berserk_trigger = "gana Rabia",
	fear_trigger = "de Clamor aterrorizador.",
	starttrigger = "¡devora todos los zombis cercanos!",

	frenzy_warn = "¡Alerta de Frenesí!",
	fear_warn_5 = "5 segundos hasta Miedo!",
	fear_warn = "¡Alerta de Miedo - 20 segundos hasta el próximo!",

	enragewarn = "¡ENFURECER!",
	enragebartext = "Enfurecer",
	enrage_warn_90 = "Enfurecer en 90 segundos",
	enrage_warn_30 = "Enfurecer en 30 segundos",
	enrage_warn_10 = "Enfurecer en 10 segundos",

	startwarn = "¡Entrando en combate con Gluth! ~1:45 hasta Diezmar!",
	decimatesoonwarn = "¡Diezmar Pronto!",
	decimatebar = "Diezmar Zombi",

	--zombies_cmd = "zombies",
	zombies_name = "Zombi",
	zombies_desc = "Muestra temporizador para zombis",
	zombiebar = "Próximo Zombi - %d",

	fear_bar = "Miedo",

	testtrigger = "testtrigger";

	frenzygain_trigger = "Gluth gana Frenesí.",
	frenzygain_trigger2 = "Gluth entra frenzy!",
	frenzyend_trigger = "Frenesí desaparece de Gluth.",
	frenzy_message = "¡Frensí! Disparo tranquilizante ahora!",
	frenzy_bar = "Frenesí",
	frenzy_Nextbar = "Próximo Frenesí",
} end )

local timer = {
	decimate = 105,
	zombie = 6,
	enrage = 330,
	firstfear = 20,
	fear = 15,
	frenzy = 10,
}
local icon = {
	zombie = "Ability_Seal",
	enrage = "Spell_Shadow_UnholyFrenzy",
	fear = "Spell_Shadow_PsychicScream",
	decimate = "INV_Shield_01",
	tranquil = "Spell_Nature_Drowsy",
	frenzy = "Ability_Druid_ChallangingRoar",
}
local syncName = {
	frenzy = "GluthFrenzyStart"..module.revision,
	frenzyOver = "GluthFrenzyEnd"..module.revision,
	
	enrage = "GluthEnrage"..module.revision,
	decimate = "GluthDecimate"..module.revision,
	fear = "GluthFear"..module.revision,
}

local lastFrenzy = 0
local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--frenzyGain, maybe enrage too
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--frenzyFade
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--Decimate, Fear
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--Decimate
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--Decimate
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--Fear
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--Fear
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--Fear
	
	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(1, syncName.frenzyOver)
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.decimate)
	self:ThrottleSync(5, syncName.fear)
end

function module:OnSetup()
	self.started = nil
	self.prior = nil
	self.zomnum = 1
	lastFrenzy = 0
end

function module:OnEngage()
	if self.db.profile.frenzy then
		self:Bar(L["bar_frenzyCD"], timer.frenzy, icon.frenzy, true, "white")
	end
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, "Cyan")
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Attention")
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Attention")
	end
	if self.db.profile.decimate then
		self:Bar(L["bar_decimate"], timer.decimate, icon.decimate, true, "Black")
		self:DelayedMessage(timer.decimate - 5, L["msg_decimate5"], "Urgent")
	end
	if self.db.profile.fear then
		self:Bar(L["bar_fearCD"], timer.firstfear, icon.fear, true, "Blue")
	end
	
	
	
	
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, "Green")
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_frenzyGain"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyOver)
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	elseif string.find(msg, L["trigger_decimate"]) then
		self:Sync(syncName.decimate)
	elseif string.find(msg, L["trigger_fear"]) then
		self:Sync(syncName.fear)
	end
end



function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:FrenzyOver()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.decimate then
		self:Decimate()
	elseif sync == syncName.fear and self.db.profile.fear then
		self:Fear()
	end
end




function module:Frenzy()
	self:Message(L["msg_frenzy"], "Important", nil, true, "Alert")
	self:Bar(L["bar_frenzyGain"], timer.frenzy, icon.frenzy, true, "red")
	lastFrenzy = GetTime()
	
	if playerClass == "HUNTER" then
		self:WarningSign(icon.tranquil, timer.frenzy, true)
	end
end

function module:FrenzyOver()
	self:RemoveBar(L["bar_frenzyGain"])
	self:RemoveWarningSign(icon.tranquil, true)
	
	if lastFrenzy ~= 0 then
		local NextTime = (lastFrenzy + timer.frenzy) - GetTime()
		self:Bar(L["bar_frenzyCD"], NextTime, icon.frenzy, true, "white")
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:Message(L["msg_enrage"], "Important", nil, "Beware")
	self:WarningSign(icon.enrage, 0.7)
	self:Sound("Info")
end

function module:Decimate()
	if self.db.profile.decimate then
		self:RemoveBar(L["bar_decimate"])
		self:Bar(L["bar_decimate"], timer.decimate, icon.decimate, true, "Black")
		self:DelayedMessage(timer.decimate - 5, L["msg_decimate5"], "Urgent")
		self:Sound("Beware")
	end
	
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, "Green")
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
end

function module:Fear()
	self:Bar(L["bar_fearCD"], timer.fear, icon.fear, true, "Blue")
end

function module:Zombies()
	self:Bar(string.format(L["bar_zombies"],self.zomnum), timer.zombie, icon.zombie, true, "Green")

	if self.zomnum <= 10 then
		self.zomnum = self.zomnum + 1
	elseif self.zomnum > 10 then
		self:CancelScheduledEvent("bwgluthzbrepop")
		self:RemoveBar(string.format(L["bar_zombies"], self.zomnum ))
		self.zomnum = 1
	end
end

function module:Zombie()
	self:ScheduleRepeatingEvent("bwgluthzbrepop", self.Zombies, timer.zombie, self)
end
