
local module, L = BigWigs:ModuleDeclaration("Instructor Razuvious", "Naxxramas")
local understudy = AceLibrary("Babble-Boss-2.2")["Deathknight Understudy"]

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "shout", "unbalance", "shieldwall", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Razuvious",

	shout_cmd = "shout",
	shout_name = "Shout Alert",
	shout_desc = "Warn for disrupting shout",
	
	mc_cmd = "mc",
	mc_name = "MC timer bars",
	mc_desc = "Shows Mind Control timer bars",
	
	unbalance_cmd = "unbalancing",
	unbalance_name = "Unbalancing Strike Alert",
	unbalance_desc = "Warn for Unbalancing Strike",

	shieldwall_cmd = "shieldwall",
	shieldwall_name = "Shield Wall Timer",
	shieldwall_desc = "Show timer for Shield Wall",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Show me what you've got!",
	starttrigger3 = "Hah hah, I'm just getting warmed up!",

	trigger_shout = "%s lets loose a triumphant shout.",--CHAT_MSG_RAID_BOSS_EMOTE
	bar_shout = "Disrupting Shout",
	msg_shout = "Disrupting Shout! Next in 25secs",
	--noshoutwarn = "No shout! Next in 20secs",
	
	trigger_unbalance = "afflicted by Unbalancing Strike",--to be confirmed
	trigger_unbalance2 = "Instructor Razuvious's Unbalancing Strike",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	bar_unbalance = "Unbalancing Strike",
	
	trigger_shieldWall = "Deathknight Understudy gains Shield Wall.",--to be confirmed
	bar_shieldWall = "Shield Wall",
	
	mc_trigger = "You gain Mind Control.", --CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS
	mcEnd_trigger = "Mind Control fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	mc_bar = " MC",
	mcLocked_bar = "Can't MC ",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Razuvious",

	--shout_cmd = "shout",
	shout_name = "Alerta de Grito perturbador",
	shout_desc = "Avisa para Grito perturbador",

	--unbalance_cmd = "unbalancing",
	unbalance_name = "Alerta de Golpe desequilibrante",
	unbalance_desc = "Avisa para Golpe desequilibrante",

	--shieldwall_cmd = "shieldwall",
	shieldwall_name = "Temporizador de Muro de escudo",
	shieldwall_desc = "Muestra un temporizador para Muro de escudo",

	startwarn = "¡Entrando en combate con Instructor Razuvious! 15 segundos hasta Grito, 30 segundos hasta Golpe desequilibrante!",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Show me what you've got!",
	starttrigger3 = "Hah hah, I'm just getting warmed up!",
	--starttrigger4 = "Stand and fight!",

	shouttrigger = "Grito perturbador",
	shout7secwarn = "7 segundos hasta Grito perturbador",
	shout3secwarn = "¡3 segundos hasta Grito perturbador!",
	shoutwarn = "¡Grito perturbador! El próximo en 25 segundos",
	noshoutwarn = "¡No hay grito! El próximo en 20 segundos",
	shoutbar = "Grito perturbado",

	unbalance_trigger = "sufre de Golpe desequilibrante",
	unbalancesoonwarn = "¡Golpe desequilibrante pronto!",
	unbalancewarn = "¡Golpe desequilibrante! El próximo en ~30 segundos",
	unbalancebar = "Golpe desequilibrante",

	shieldwalltrigger   = "Caballero de la Muerte suplente gana Muro de escudo.",
	shieldwallbar       = "Muro de escudo",
} end )

local timer = {
	firstShout = 14.5,
	shout = 25,
	--noShoutDelay = 5,
	unbalance = 30,
	shieldwall = 20,
	mc = 60,
	mcLocked = 60,
}
local icon = {
	shout = "Ability_Warrior_WarCry",
	unbalance = "Ability_Warrior_DecisiveStrike",
	shieldwall = "Ability_Warrior_ShieldWall",
	mc = "spell_shadow_shadowworddominate",
	taunt = "spell_nature_reincarnation",
	mcLocked = "spell_shadow_sacrificialshield",
}
local syncName = {
	shout = "RazuviousShout"..module.revision,
	unbalance = "RazuviousUnbalance"..module.revision,
	shieldwall = "RazuviousShieldwall"..module.revision,
	mc = "RazuviousMc"..module.revision,
	mcEnd = "RazuviousMcEnd"..module.revision,
	mcLocked = "RazuviousMcLocked"..module.revision,
}

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])
module:RegisterYellEngage(L["starttrigger3"])

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")--shout
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--unbalancing
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--unbalancing
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--unbalancing
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Event")--mc gain
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--mc fade
	
	--to confirm
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--unbalancing to be confirmed
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--unbalancing to be confirmed
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--unbalancing to be confirmed
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")--unbalancing to be confirmed

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Event")--unbalancing to be confirmed
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Event")--unbalancing to be confirmed
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--unbalancing to be confirmed
	
	self:ThrottleSync(5, syncName.shout)
	self:ThrottleSync(5, syncName.unbalance)
	self:ThrottleSync(5, syncName.shieldwall)
	self:ThrottleSync(0, syncName.mc)
	self:ThrottleSync(0, syncName.mcEnd)
	self:ThrottleSync(0, syncName.mcLocked)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.db.profile.shout then
		self:Bar(L["bar_shout"], timer.firstShout, icon.shout, true, "red")
		self:DelayedWarningSign(timer.firstShout - 3, icon.shout, 0.7)
		--self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self)--fix for no first shout
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_shout"] then
		self:Sync(syncName.shout)
	elseif string.find(msg, L["trigger_unbalance"]) or string.find(msg, L["trigger_unbalance2"]) then
		self:Sync(syncName.unbalance)
	elseif string.find(msg, L["trigger_shieldWall"]) then
		self:Sync(syncName.shieldwall)
	end
	
	if string.find(msg, L["mc_trigger"]) then
		mcPerson = UnitName("player")
		if GetRaidTargetIndex("target")== nil then mcIcon = "NoIcon"; end
		if GetRaidTargetIndex("target")==1 then mcIcon = "Star"; end
		if GetRaidTargetIndex("target")==2 then mcIcon = "Circle"; end
		if GetRaidTargetIndex("target")==3 then mcIcon = "Diamond"; end
		if GetRaidTargetIndex("target")==4 then mcIcon = "Triangle"; end
		if GetRaidTargetIndex("target")==5 then mcIcon = "Moon"; end
		if GetRaidTargetIndex("target")==6 then mcIcon = "Square"; end
		if GetRaidTargetIndex("target")==7 then mcIcon = "Cross"; end
		if GetRaidTargetIndex("target")==8 then mcIcon = "Skull"; end
		self:Sync(syncName.mc.." "..mcPerson.." "..mcIcon)
	end
	if string.find(msg, L["mcEnd_trigger"]) then
		mcPerson = UnitName("player")
		self:Sync(syncName.mcEnd.." "..mcPerson.." "..mcIcon)
		self:Sync(syncName.mcLocked.." "..mcIcon)
	end
end

--[[
function module:NoShout()
	self:CancelDelayedWarningSign(icon.shout)
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self)
	if self.db.profile.shout then
		self:Bar(L["shoutbar"], timer.shout - timer.noShoutDelay, icon.shout, true, "red")
		self:DelayedWarningSign(timer.shout - 3, icon.shout, 0.7)
	end
end
]]--

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shout and self.db.profile.shout then
		self:Shout()
	elseif sync == syncName.unbalance and self.db.profile.unbalance then
		self:Unbalance()
	elseif sync == syncName.shieldwall and self.db.profile.shieldwall then
		self:Shieldwall()
	elseif sync == syncName.mc and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcEnd and self.db.profile.mc then
		self:McEnd(rest)
	elseif sync == syncName.mcLocked and self.db.profile.mc then
		self:McLocked(rest)
	end
end

function module:Shout()
	--self:CancelScheduledEvent("bwrazuviousnoshout")
	--self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self)
	
	self:CancelDelayedWarningSign(icon.shout)
	
	self:Message(L["msg_shout"], "Attention", nil, "Alarm")
	self:Bar(L["bar_shout"], timer.shout, icon.shout, true, "red")
	self:DelayedWarningSign(timer.shout - 3, icon.shout, 0.7)
end

function module:Unbalance()
	self:Bar(L["bar_unbalance"], timer.unbalance, icon.unbalance, true, "Blue")
end

function module:Shieldwall()
	self:Bar(L["bar_shieldWall"], timer.shieldwall, icon.shieldwall, true, "green")
	if playerClass == "PRIEST" then
		self:DelayedWarningSign(timer.shieldwall, icon.taunt, 0.7)
	end
end

function module:Mc(rest)
	self:Bar(rest..L["mc_bar"], timer.mc, icon.mc, true, "white")
end

function module:McEnd(rest)
	self:RemoveBar(rest..L["mc_bar"])
	if playerClass == "WARRIOR" then
		self:WarningSign(icon.taunt, 0.7)
		self:Sound("Info")
	end
end

function module:McLocked(rest)
	self:Bar(L["mcLocked_bar"]..rest, timer.mcLocked, icon.mcLocked, true, "black")
end
