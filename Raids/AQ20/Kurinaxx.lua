
local module, L = BigWigs:ModuleDeclaration("Kurinnaxx", "Ruins of Ahn'Qiraj")

module.revision = 20042
module.enabletrigger = module.translatedName
module.toggleoptions = {"wound", "enrage", "trap", "taunt", "bigicon", "sounds", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Kurinnaxx",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Trap and stacks big icon alert",
	bigicon_desc = "Shows a big icon when you are hit by a trap or have too many stacks",
	
	trap_cmd = "trap",
	trap_name = "Trap alerts",
	trap_desc = "Timer bars for everyone hit by a trap",
	
	wound_cmd = "wound",
	wound_name = "Wound 5 stacks alerts",
	wound_desc = "Alert for 5 stacks of Wound",
	
	enrage_cmd = "enrage",
	enrage_name = "enrage alerts",
	enrage_desc = "Alert for Enrage",
	
	sounds_cmd = "sounds",
	sounds_name = "Too many stacks sound alert",
	sounds_desc = "Sound effect when you have too many stacks",
	
	taunt_cmd = "taunt",
	taunt_name = "Big icon for taunt alert",
	taunt_desc = "Shows a big icon when you should taunt.",
	
	trap_trigger = "Sand Trap hits (.+) for",
	trap_warn = "Sand Trap",
	trap_bar = " Sand Trap",
	
	wound_trigger = "(.+) (.+) afflicted by Mortal Wound %(5%)",
	
	enrage_trigger = "Kurinnaxx gains Enrage.",
	enrage_warn = "Kurinnaxx is enraged!",
} end )

local timer = {
	trap = 20,
}

local icon = {
	taunt = "spell_nature_reincarnation",
	stacks = "ability_criticalstrike",
	trap = "inv_misc_dust_02",
}

local syncName = {
	enrage = "KurinaxxEnrage"..module.revision,
	trap = "KurinaxxTrap"..module.revision,
	wound = "KurinaxxWound"..module.revision,
}

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	
	self:ThrottleSync(0, syncName.trap)
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.wound)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	enrage = nil
end

function module:OnDisengage()
end

function module:Event(msg)
	local _,_,trapperson = string.find(msg, L["trap_trigger"])
	local _,_,woundperson = string.find(msg, L["wound_trigger"])
	if string.find(msg, L["trap_trigger"]) and trapperson ~= "you" then
		self:Sync(syncName.trap.." "..trapperson)
	end
	if string.find(msg, L["wound_trigger"]) then
		self:Sync(syncName.wound.." "..woundperson)
	end
	if string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.trap and self.db.profile.trap then
		self:Trap(rest)
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.wound and self.db.profile.wound then
		self:Wound(rest)
	end
end


function module:Enrage()
	self:Message(L["enrage_warn"], "Attention")
	if self.db.profile.sounds then
		self:Sound("Alarm")
	end
end

function module:Trap(rest)
	if rest == UnitName("player") then
		self:Bar(UnitName("player")..L["trap_bar"], timer.trap, icon.trap)
		self:Message(L["trap_warn"], "Attention")
		if self.db.profile.bigicon then
			self:WarningSign(icon.trap, 0.7)
		end
	else
		self:Bar(rest..L["trap_bar"], timer.trap, icon.trap)
	end
end

function module:Wound(rest)
	if rest == UnitName("player") then
		if self.db.profile.sounds then
			self:Sound("stacks")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.stacks, 0.7)
		end
	else
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			self:WarningSign(icon.taunt, 0.7)
		end
	end
end
