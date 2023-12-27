
local module, L = BigWigs:ModuleDeclaration("Maexxna", "Naxxramas")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = { "cocoon", "webspray", "poison", "enrage", "spiderlings", "bosskill" }

L:RegisterTranslations("enUS", function() return {
        cmd = "Maexxna",
		
		cocoon_cmd = "cocoon",
        cocoon_name = "Cocoon Alert",
        cocoon_desc = "Warn for Cocooned Players",
		
        webspray_cmd = "spray",
        webspray_name = "Web Spray Alert",
        webspray_desc = "Warn for Web Spray",
		
		poison_cmd = "Poison",
        poison_name = "Necrotic Poison Alert",
        poison_desc = "Warn for Necrotic Poison",
		
        enrage_cmd = "enrage",
        enrage_name = "Enrage Alert",
        enrage_desc = "Warn for Enrage",

        spiderlings_cmd = "spiderlings",
        spiderlings_name = "Spiderlings Alert",
        spiderlings_desc = "Warn for Spiderlings",

		trigger_cocoonGain = "(.*) is afflicted by Web Wrap.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_cocoonGainYou = "You are afflicted by Web Wrap.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_cocoonFade = "Web Wrap fades from (.*).",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
		bar_cocoonGain = "Cocoon ",
		bar_cocoonCD = "Cocoon CD",

		trigger_webSprayGain = "afflicted by Web Spray.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_webSprayGain = "Web Spray",
		bar_webSprayCD = "Web Spray CD",
		
		trigger_webSprayFade = "Web Spray fades from",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF

		trigger_poisonGain = "afflicted by Necrotic Poison.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_poisonGain = "Necrotic on tank!",
		bar_poisonCD = "Necrotic Poison CD",
		
		trigger_poisonFade = "Necrotic Poison fades",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
		
		trigger_enrageGain = "Maexxna gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		msg_enrageGain = "Maexxna is Enraged!",
		
		bar_spiderlings = "Spiderlings",--Maexxna Spiderling dies. CHAT_MSG_COMBAT_HOSTILE_DEATH
		
		--spray every 40sec
			--last for 8sec
		--cocoon after 20sec
		--lings after 35sec
} end )

L:RegisterTranslations("esES", function() return {
        --cmd = "Maexxna",

        --spray_cmd = "spray",
        spray_name = "Alerta de Pulverizador de tela de araña",
        spray_desc = "Avisa para Pulverizador de tela de araña",

        --enrage_cmd = "enrage",
        --enrage_name = "Alerta de Enfurecer",
        --enrage_desc = "Avisa para Enfurecer",

        --cocoon_cmd = "cocoon",
        cocoon_name = "Alerta de Capullo",
        cocoon_desc = "Avisa para jugadores en Capullo",

        --poison_cmd = "Poison",
        poison_name = "Alerta de Veneno necrótico",
        poison_desc = "Avisa para Veneno necrótico",

        cocoontrigger = "(.*) (.*) sufre de Trampa arácnida.",
        webspraytrigger = "sufre de Pulverizador de tela de araña",
        poisontrigger = "sufre de Veneno necrótico.",
        etrigger1 = "gana Enfurecer",

        cocoonwarn = "¡%s en Capullo!",
        poisonwarn = "¡Veneno necrótico!",
        --enragetrigger = "%s becomes enraged.",

        --enragewarn = "¡Enfurecer!",
        --enragesoonwarn = "¡Enfurecer pronto!",

        webspraybar = "Pulverizador de tela de araña",
        cocoonbar = "Capullos",
        spiderbar = "Arañás",
        poisonbar = "Veneno necrótico",

        you = "Tu",
        are = "estás",
} end )

local timer = {
	cocoonDuration = 600,
    cocoonCD = 20,
	websprayDuration = 10,
	websprayCD = 40,
	poisonDuration = 30,
    firstPoison = 15,--14.89
    spiderlings = 30,
}
local icon = {
	cocoon = "Spell_Nature_Web",
	webspray = "Ability_Ensnare",
	poison = "Ability_Creature_Poison_03",
	enrage = "Spell_shadow_unholyfrenzy",
    spiderlings = "INV_Misc_MonsterSpiderCarapace_01",
}
local syncName = {
	cocoon = "MaexxnaCocoon" .. module.revision,
	cocoonFade = "MaexxnaCocoonFade" .. module.revision,
    webspray = "MaexxnaWebspray" .. module.revision,
	websprayFade = "MaexxnaWebsprayFade" .. module.revision,
    poison = "MaexxnaPoison" .. module.revision,
	poisonFade = "MaexxnaPoisonFade" .. module.revision,
    enrage = "MaexxnaEnrage" .. module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	
	self:ThrottleSync(0, syncName.cocoon)
	self:ThrottleSync(0, syncName.cocoonFade)
    self:ThrottleSync(8, syncName.webspray)
	self:ThrottleSync(8, syncName.websprayFade)
    self:ThrottleSync(2, syncName.poison)
	self:ThrottleSync(2, syncName.poisonFade)
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()

end

function module:OnEngage()
    if self.db.profile.poison then
		self:Bar(L["bar_poisonCD"], timer.firstPoison, icon.poison, true, "Green")
	end
	if self.db.profile.cocoon then
		self:Bar(L["bar_cocoonCD"], timer.cocoonCD, icon.cocoon, true, "blue")--probably fixed
	end
	if self.db.profile.spiderlings then
		self:Bar(L["bar_spiderlings"], timer.spiderlings, icon.spiderlings, true, "red")
	end
    if self.db.profile.webspray then
		self:Bar(L["bar_webSprayCD"], timer.websprayCD, icon.webspray, true, "white")
	end
    
end

function module:OnDisengage()
end

function module:Event(msg)
    if string.find(msg, L["trigger_cocoonGain"]) then--(.*) is afflicted by Web Wrap.
		local _, _, cocoonedPlayer, _ = string.find(msg, L["trigger_cocoonGain"])
		self:Sync(syncName.cocoon .. " " .. cocoonedPlayer)
	elseif msg == L["trigger_cocoonGainYou"] then--You are afflicted by Web Wrap.
		cocoonedPlayer = UnitName("Player")
		self:Sync(syncName.cocoon .. " " .. cocoonedPlayer)
	elseif string.find(msg, L["trigger_cocoonFade"]) then--Web Wrap fades from (.*).
		local _, _, cocoonedPlayerFade, _ = string.find(msg, L["trigger_cocoonFade"])
		self:Sync(syncName.cocoonFade .. " " .. cocoonedPlayerFade)
	
	
	elseif string.find(msg, L["trigger_webSprayGain"]) then--afflicted by Web Spray.
		self:Sync(syncName.webspray)
	elseif string.find(msg, L["trigger_webSprayFade"]) then--Web Spray fades from
		self:Sync(syncName.websprayFade)
	
	elseif string.find(msg, L["trigger_poisonGain"]) then--afflicted by Necrotic Poison.
		self:Sync(syncName.poison)
	elseif string.find(msg, L["trigger_poisonFade"]) then--Necrotic Poison fades
		self:Sync(syncName.poisonFade)
	
	elseif msg == L["trigger_enrageGain"] then--Maexxna gains Enrage.
		self:Sync(syncName.enrage)
	end
end



function module:BigWigs_RecvSync(sync, rest)
    if sync == syncName.cocoon and rest and self.db.profile.cocoon then
        self:Cocoon(rest)
	elseif sync == syncName.cocoonFade and rest and self.db.profile.cocoon then
        self:CocoonFade(rest)
	elseif sync == syncName.webspray and self.db.profile.webspray then
        self:Webspray()
	elseif sync == syncName.websprayFade then
        self:WebsprayFade()
    elseif sync == syncName.poison and self.db.profile.poison then
        self:Poison()
    elseif sync == syncName.poisonFade and self.db.profile.poison then
        self:PoisonFade()
    elseif sync == syncName.enrage and self.db.profile.enrage then
        self:Enrage()
    end
end



function module:Cocoon(rest)
    self:RemoveBar(L["bar_cocoonCD"])
	self:Bar(L["bar_cocoonGain"]..rest, timer.cocoonDuration, icon.cocoon, true, "black")
end

function module:CocoonFade(rest)
	self:RemoveBar(L["bar_cocoonGain"]..rest)
end

function module:Webspray()
	self:RemoveBar(L["bar_webSprayCD"])
	self:RemoveBar(L["bar_spiderlings"])
	self:Bar(L["bar_webSprayGain"], timer.websprayDuration, icon.webspray, true, "white")
end

function module:WebsprayFade()
	self:RemoveBar(L["bar_webSprayGain"])
	
	if self.db.profile.webspray then
		self:Bar(L["bar_webSprayCD"], timer.websprayCD - timer.websprayDuration, icon.webspray, true, "white")
	end
	if self.db.profile.cocoon then
		self:Bar(L["bar_cocoonCD"], timer.cocoonCD - timer.websprayDuration, icon.cocoon, true, "blue")
	end
	if self.db.profile.spiderlings then
		self:Bar(L["bar_spiderlings"], timer.spiderlings - timer.websprayDuration, icon.spiderlings, true, "red")
	end
end

function module:Poison()
	self:RemoveBar(L["bar_poisonCD"])
	self:Bar(L["bar_poisonGain"], timer.poisonDuration, icon.poison, true, "Green")
	if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Paladin" or UnitClass("Player") == "Druid" then
		self:WarningSign(icon.poison, 0.7)
	end
end

function module:PoisonFade()
	self:RemoveBar(L["bar_poisonGain"])
end

function module:Enrage()
	self:Message(L["msg_enrageGain"], "Important", nil, "Beware")
	self:WarningSign(icon.enrage, 0.7)
end
