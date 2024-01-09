
local module, L = BigWigs:ModuleDeclaration("Buru the Gorger", "Ruins of Ahn'Qiraj")
module.revision = 30039
module.enabletrigger = module.translatedName
module.toggleoptions = {"watch", "dismember", "phase", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Buru",

	watch_cmd = "watch",
	watch_name = "Watched Alert",
	watch_desc = "Warns for who is being watched",
	
	dismember_cmd = "dismember",
	dismember_name = "Dismember Alert",
	dismember_desc = "Warns for Dismember",
	
	phase_cmd = "phase",
	phase_name = "Phase Alert",
	phase_desc = "Warns for Phases",
	
	trigger_watch = "sets eyes on (.+)!",--CHAT_MSG_MONSTER_EMOTE
	msg_watch = " is being watched!",
	trigger_watchEnd = "Buru Egg's Explosion hits Buru the Gorger for",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_watchEnd = "Buru stopped following you.",
	
	trigger_dismemberYouOne = "You are afflicted by Dismember.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_dismemberYouMore = "You are afflicted by Dismember %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_dismemberOtherOne = "(.+) is afflicted by Dismember.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
		trigger_dismemberOtherMore = "(.+) is afflicted by Dismember %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_dismember = " Dismember",
	
	msg_phase2 = "Phase2, DPS Buru!",
} end )

L:RegisterTranslations("deDE", function() return {
	you_name = "Du wirst beobachtet",
	you_desc = "Warnung, wenn Du beobachtet wirst.",

	other_name = "X wird beobachtet",
	other_desc = "Warnung, wenn andere Spieler beobachtet werden.",

	icon_name = "Symbol",
	icon_desc = "Platziert ein Symbol \195\188ber dem Spieler, der beobachtet wird. (Ben\195\182tigt Anf\195\188hrer oder Bef\195\182rdert Status.)",

	trigger_watch = "beh\195\164lt (.+) im Blickfeld!",
	watchwarn = " wird beobachtet!",
	watchwarnyou = "Du wirst beobachtet!",
	you = "Euch",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Buru",

	--you_cmd = "you",
	you_name = "Alerta personal de Observar",
	you_desc = "Avisa cuando estés siendo observado",

	--other_cmd = "other",
	other_name = "Alerta de Observar",
	other_desc = "Avisa cuando otros jugadores estén siendo observados",

	--icon_cmd = "icon",
	icon_name = "Marcar para Observar",
	icon_desc = "Marca con un icono el jugador observado (require asistente o líder)",

	trigger_watch = "sets eyes on (.+)!",
	watchwarn = " está siendo observado!",
	watchwarnyou = "¡Estás siendo observado!",
	you = "Tu",
} end )

local timer = {
	dismember = 10,
}
local icon = {
	watch = "ability_cheapshot",
	dismember = "ability_backstab",
}
local color = {
	dismember = "Red",
}
local syncName = {
	watch = "BuruWatch"..module.revision,
	watchEnd = "BuruWatchEnd"..module.revision,
	dismember = "BuruDismember"..module.revision,
	p2 = "BuruP2"..module.revision,
}

local phase2 = nil
local watchedPlayer = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")--trigger_watch
	self:RegisterEvent("UNIT_HEALTH")--p2
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_watchEnd
end

function module:OnSetup()
end

function module:OnEngage()
	phase2 = false
	watchedPlayer = nil
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["trigger_watch"]) then
		local _, _, watchedPlayer = string.find(msg, L["trigger_watch"])
		if watchedPlayer == "you" then watchedPlayer = UnitName("Player") end
		self:Sync(syncName.watch.." "..watchedPlayer)
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) > 5 and math.ceil(100*health/maxHealth) <= 20 and not phase2 then
			self:Sync(syncName.p2)
			phase2 = true
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_dismemberYouOne"] then
		local dismemberPlayerAndDismemberQty = UnitName("Player") .. " " .. "1"
		self:Sync(syncName.dismember.." "..dismemberPlayerAndDismemberQty)
	
	elseif string.find(msg, L["trigger_dismemberYouMore"]) then
		local _,_,dismemberQty,_ = string.find(msg, L["trigger_dismemberYouMore"])
		local dismemberPlayerAndDismemberQty = UnitName("Player") .. " " .. dismemberQty
		self:Sync(syncName.dismember.." "..dismemberPlayerAndDismemberQty)
	
	elseif string.find(msg, L["trigger_dismemberOtherMore"]) then
		local _,_,dismemberPlayer,dismemberQty = string.find(msg, L["trigger_dismemberOtherMore"])
		local dismemberPlayerAndDismemberQty = dismemberPlayer .. " " .. dismemberQty
		self:Sync(syncName.dismember.." "..dismemberPlayerAndDismemberQty)
	
	elseif string.find(msg, L["trigger_dismemberOtherOne"]) then
		local _,_,dismemberPlayer = string.find(msg, L["trigger_dismemberOtherOne"])
		local dismemberPlayerAndDismemberQty = dismemberPlayer .. " " .. "1"
		self:Sync(syncName.dismember .. " " .. dismemberPlayerAndDismemberQty)
	
	
		
	elseif string.find(msg, L["trigger_watchEnd"]) then
		self:Sync(syncName.watchEnd)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.watch and rest then
		self:Watch(rest)
	elseif sync == syncName.watchEnd then
		self:WatchEnd()
	elseif sync == syncName.dismember and rest and self.db.profile.dismember then
		self:Dismember(rest)
	elseif sync ==syncName.p2 then
		self:Phase2()
	end
end

function module:Watch(rest)
	watchedPlayer = rest
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 8)
			end
		end
	end
	
	if self.db.profile.watch then
		self:Message(rest..L["msg_watch"], "Attention", false, nil, false)
		
		if rest == UnitName("Player") then
			SendChatMessage("Buru is chasing me!", "SAY")
			self:WarningSign(icon.watch, 2)
			self:Sound("RunAway")
		end
	end
end

function module:WatchEnd()
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == watchedPlayer then
				SetRaidTarget("raid"..i, 0)
			end
		end
	end
	
	if self.db.profile.watch then
		if watchedPlayer == UnitName("Player") then
			self:Message(L["msg_watchEnd"], "Positive", false, nil, false)
			self:Sound("Alert")
		end
	end
end

function module:Dismember(rest)
	local dismemberPlayer = strsub(rest,0,strfind(rest," ") - 1)
	local dismemberQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
	
	self:RemoveBar(dismemberPlayer.." ".."1"..L["bar_dismember"])
	self:RemoveBar(dismemberPlayer.." ".."2"..L["bar_dismember"])
	self:RemoveBar(dismemberPlayer.." ".."3"..L["bar_dismember"])
	self:RemoveBar(dismemberPlayer.." ".."4"..L["bar_dismember"])
	self:RemoveBar(dismemberPlayer.." ".."5"..L["bar_dismember"])


	self:Bar(dismemberPlayer.." "..dismemberQty..L["bar_dismember"], timer.dismember, icon.dismember, true, color.dismember)
end

function module:Phase2()
	if self.db.profile.phase then
		self:Message(L["msg_phase2"], "Attention", false, nil, false)
		self:Sound("Long")
	end
	self:WatchEnd()
end
