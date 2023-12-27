
local module, L = BigWigs:ModuleDeclaration("Grobbulus", "Naxxramas")

module.revision = 30027
module.enabletrigger = module.translatedName
module.toggleoptions = {"slimespray", "inject", "cloud", "icon",  -1, "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grobbulus",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	slimespray_cmd = "slimespray",
	slimespray_name = "Slime Spray",
	slimespray_desc = "Show timer for Slime Spray",
	
	inject_cmd = "inject",
	inject_name = "Mutating Injection Alert",
	inject_desc = "Warn when someone is injected",

	icon_cmd = "icon",
	icon_name = "Place Icon",
	icon_desc = "Place a skull icon on an injected person. (Requires promoted or higher)",

	cloud_cmd = "cloud",
	cloud_name = "Poison Cloud",
	cloud_desc = "Warn for Poison Clouds",
		
	trigger_enrage = "%s becomes enraged!",--to be confirmed
	bar_enrage = "Enrage",
	msg_enrage60 = "Enrage in 1min",
	msg_enrage10 = "Enrage in 10sec",
	msg_enrage = "Enrage!",
	
	trigger_slimeSpray = "Slime Spray",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	bar_slimeSprayCD = "Slime Spray CD",
	
	trigger_inject = "(.*) is afflicted by Mutating Injection.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_injectYou = "You are afflicted by Mutating Injection.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_injected = " Injected",
	msg_injectYou = "You are injected!",
	msg_inject = " Injected",
	
	trigger_injectDispel = "(.*)'s Mutating Injection is removed.",--CHAT_MSG_SPELL_BREAK_AURA,"
	trigger_injectDispelYou = "Your Mutating Injection is removed.",--to be confirmed
	
	trigger_cloudCast = "Grobbulus casts Poison Cloud.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_cloudCD = "Poison Cloud CD",
	msg_cloudCast = "Cloud -- Move Grobbulus!",
	trigger_cloudHitsYou = "Grobbulus Cloud's Poison hits you",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	--trigger_cloudHitsOther = "Grobbulus Cloud's Poison hits (.+) for", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Grobbulus",

	--enrage_cmd = "enrage",
	enrage_name = "Alerta de Enfurecer",
	enrage_desc = "Avisa para Enfurecer",

	--youinjected_cmd = "youinjected",
	youinjected_name = "Alerta Personal de Inyección",
	youinjected_desc = "Avisa cuando estés inyectado",

	--otherinjected_cmd = "otherinjected",
	otherinjected_name = "Alerta de Inyección",
	otherinjected_desc = "Avisa cuando otros jugadores están inyectados",

	--icon_cmd = "icon",
	icon_name = "Marcar para Inyección",
	icon_desc = "Marca con un icono el jugador inyectado. (Require asistente o líder)",

	--cloud_cmd = "cloud",
	cloud_name = "Nube de veneno",
	cloud_desc = "Avisa para Nube de veneno",

	inject_trigger = "^([^%s]+) ([^%s]+) sufre de Inyección mutante",

	you = "Tu",
	are = "estás",

	startwarn = "¡Entrando en combate con Grobbulus, 12 minutos hasta Enfurecer!",
	enragebar = "Enfurecer",
	enrage10min = "Enfurecer en 10 minutos",
	enrage5min = "Enfurecer en 5 minutos",
	enrage1min = "Enfurecer en 1 minuto",
	enrage30sec = "Enfurecer en 30 segundos",
	enrage10sec = "Enfurecer en 10 segundos",
	bomb_message_you = "¡Estás inyectado!",
	bomb_message_other = "¡%s está inyectado!",
	bomb_bar = "%s inyectado",

	cloud_trigger = "Grobbulus lanza Nube de veneno.",
	cloud_warn = "¡Próximo Nube de veneno en ~15 segundos!",
	cloud_bar = "Nube de veneno",

} end )

local timer = {
	enrage = 720,
	firstSlimeSpray = {20, 30},--25
	slimeSprayCD = {30, 35},--confirmed
	injectDuration = 10,
	cloudCD = 16,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	slimeSpray = "INV_Misc_Slime_01",
	inject = "Spell_Shadow_CallofBone",
	cloud = "Ability_Creature_Disease_02",
}
local syncName = {
	enrage = "GrobbulusEnrage"..module.revision,
	slimeSpray = "GrobbulusSlimeSpray"..module.revision,
	inject = "GrobbulusInject"..module.revision,
	injectDispel = "GrobbulusInjectDispel"..module.revision,
	cloud = "GrobbulusCloud"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--inject
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--inject
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--inject
	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA", "Event")--injectDispel
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--slimeSpray, cloudHitsYou
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--slimeSpray
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--slimeSpray
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--cloudCast
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.slimeSpray)
	self:ThrottleSync(3, syncName.inject)
	self:ThrottleSync(1, syncName.injectDispel)
	self:ThrottleSync(5, syncName.cloud)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, "White")
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important")
	end
	if self.db.profile.slimespray then
		self:IntervalBar(L["bar_slimeSprayCD"], timer.firstSlimeSpray[1], timer.firstSlimeSpray[2], icon.slimeSpray, true, "Green")
	end
	if self.db.profile.cloud then
		self:Bar(L["bar_cloudCD"], timer.cloudCD, icon.cloud, true, "Blue")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_slimeSpray"]) then
		self:Sync(syncName.slimeSpray)
	
	elseif string.find(msg, L["trigger_inject"]) then
		local _,_, injectPerson, _ = string.find(msg, L["trigger_inject"])
		self:Sync(syncName.inject.." "..injectPerson)
	elseif msg == L["trigger_injectYou"] then
		self:Sync(syncName.inject.." "..UnitName("player"))
	elseif string.find(msg, L["trigger_injectDispel"]) then
		local _,_, injectDispelPerson, _ = string.find(msg, L["trigger_injectDispel"])
		self:Sync(syncName.injectDispel.." "..injectDispelPerson)
	elseif msg == L["trigger_injectDispelYou"] then
		self:Sync(syncName.injectDispel.." "..UnitName("player"))
	
	elseif msg == L["trigger_cloudCast"] then
		self:Sync(syncName.cloud)
	elseif string.find(msg, L["trigger_cloudHitsYou"]) then
		self:WarningSign(icon.cloud, 0.7)
		self:Sound("Info")
	end
end




function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.slimeSpray and self.db.profile.slimespray then
		self:SlimeSpray()
	elseif sync == syncName.inject and self.db.profile.inject and rest then
		self:Inject(rest)
	elseif sync == syncName.injectDispel and self.db.profile.inject and rest then
		self:InjectDispel(rest)
	elseif sync == syncName.cloud and self.db.profile.cloud then
		self:Cloud()
	end
end




function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])
	
	self:Message(L["msg_enrage"], "Important", nil, "RunAway")
	self:WarningSign(icon.enrage, 0.7)
	self:Sound("Info")
end

function module:SlimeSpray()
	self:RemoveBar(L["bar_slimeSprayCD"])
	self:IntervalBar(L["bar_slimeSprayCD"], timer.slimeSprayCD[1], timer.slimeSprayCD[2], icon.slimeSpray, true, "Green")
end

function module:Inject(rest)
	if rest == UnitName("player") then
		SendChatMessage("Inject on "..UnitName("player").."!","SAY")
		self:WarningSign(icon.inject, 0.7)
		self:Message(L["msg_injectYou"], "Personal", true, "Beware")
	else
		self:Message(rest..L["msg_inject"], "Personal")
		--if (IsRaidLeader() or IsRaidOfficer()) then
		--	SendChatMessage("Inject on you!","WHISPER",nil,rest)
		--end
	end
	self:Bar(rest..L["bar_injected"], timer.injectDuration, icon.inject, true, "Red")
	if self.db.profile.icon then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 8)
			end
		end
	end
end

function module:InjectDispel(rest)
	self:RemoveBar(rest..L["bar_injected"])
end

function module:Cloud()
	self:Message(L["msg_cloudCast"], "Urgent")
	self:Bar(L["bar_cloudCD"], timer.cloudCD, icon.cloud, true, "Blue")
end
