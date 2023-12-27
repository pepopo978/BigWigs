
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Buru the Gorger", "Ruins of Ahn'Qiraj")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Buru",

	you_cmd = "you",
	you_name = "You're being watched alert",
	you_desc = "Warn when you're being watched",

	other_cmd = "other",
	other_name = "Others being watched alert",
	other_desc = "Warn when others are being watched",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on watched person (requires promoted or higher)",

	watchtrigger = "sets eyes on (.+)!",
	watchwarn = " is being watched!",
	watchwarnyou = "You are being watched!",
	you = "You",
	
	dismember1_trigger = "(.+) is afflicted by Dismember.",
	dismember_trigger = "(.+) is afflicted by Dismember %((.+)%)",
	dismember_bar = " Dismember",
	p2 = "Phase2, DPS Buru!",
} end )

L:RegisterTranslations("deDE", function() return {
	you_name = "Du wirst beobachtet",
	you_desc = "Warnung, wenn Du beobachtet wirst.",

	other_name = "X wird beobachtet",
	other_desc = "Warnung, wenn andere Spieler beobachtet werden.",

	icon_name = "Symbol",
	icon_desc = "Platziert ein Symbol \195\188ber dem Spieler, der beobachtet wird. (Ben\195\182tigt Anf\195\188hrer oder Bef\195\182rdert Status.)",

	watchtrigger = "beh\195\164lt (.+) im Blickfeld!",
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

	watchtrigger = "sets eyes on (.+)!",
	watchwarn = " está siendo observado!",
	watchwarnyou = "¡Estás siendo observado!",
	you = "Tu",
} end )
---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.toggleoptions = {"you", "other", "icon", "bosskill"}

-- locals
local timer = {
	dismember = 10,
}
local icon = {
	dismember = "ability_backstab",
	follow = "spell_fire_incinerate",
}
local syncName = {
	dismember = "BuruDismember",
	p2 = "BuruP2",
}


------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("UNIT_HEALTH")
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()
	p2 = false
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers	    --
------------------------------

function module:CHAT_MSG_MONSTER_EMOTE( msg )
	local _, _, player = string.find(msg, L["watchtrigger"])
	if player then
		if player == L["you"] and self.db.profile.you then
			player = UnitName("player")
			self:Message(L["watchwarnyou"], "Personal", true, "RunAway")
			self:Message(UnitName("player") .. L["watchwarn"], "Attention", nil, nil, true)
			self:WarningSign(icon.follow, 1)
		elseif self.db.profile.other then
			self:Message(player .. L["watchwarn"], "Attention")
			self:TriggerEvent("BigWigs_SendTell", player, L["watchwarnyou"])
		end

		if self.db.profile.icon then
			self:Icon(player)
		end
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) > 5 and math.ceil(100*health/maxHealth) <= 20 and not p2 then
			self:Sync(syncName.p2)
			p2 = true
		end
	end
end

function module:Event(msg)
	local _,_,one = string.find(msg, L["dismember1_trigger"])
	local _,_,name, amount = string.find(msg, L["dismember_trigger"])
	if name and amount then
		self:Sync(syncName.dismember .. " " .. name .. " " .. amount)
	end
	if one then
		self:Sync(syncName.dismember .. " " .. one .. " 1")
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.dismember then
		if rest == UnitName("player") then
			self:Bar(string.format(UnitName("player") .. L["dismember_bar"]), timer.dismember, icon.dismember)
		else
			self:Bar(string.format(rest .. L["dismember_bar"]), timer.dismember, icon.dismember)
		end
	end
	if sync ==syncName.p2 then
		self:Message(L["p2"], "Attention")
		self:Sound("gogogo")
	end
end
