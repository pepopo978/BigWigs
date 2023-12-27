
local module, L = BigWigs:ModuleDeclaration("Deathknight Captain", "Naxxramas")

module.revision = 30011
module.enabletrigger = module.translatedName
module.toggleoptions = {"whirlwind"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "deathknightCaptain",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind Alert",
	whirlwind_desc = "Warn for Whirlwind",
	
	whirlwind_trigger = "Deathknight Captain gains Whirlwind.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	whirlwindEnd_trigger = "Whirlwind fades from Deathknight Captain.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	whirlwind_bar1 = "Whirlwind 1",
	whirlwind_bar2 = "Whirlwind 2",
	whirlwindCD_bar1 = "Whirlwind CD 1",
	whirlwindCD_bar2 = "Whirlwind CD 2",
} end )

local timer = {
	whirlwind = 6,
	whirlwindCD = 9,
}

local icon = {
	whirlwind = "ability_whirlwind"
}

local syncName = {
	whirlwind = "DkCapWW"..module.revision,
	whirlwindEnd = "DkCapWWEnd"..module.revision,
}

local deathCount = 0
local _, playerClass = UnitClass("player")
bwDkCapWwTime = 0
bwDkCapWwTimeCd = 0


function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:ThrottleSync(1, syncName.whirlwind)
	self:ThrottleSync(1, syncName.whirlwindEnd)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	deathCount = 0
end

function module:OnEngage()
	bwDkCapWwTime = GetTime() - 8
	bwDkCapWwTimeCd = GetTime() - 8
	
	wwTime = GetTime() - 8
	wwTimeCD = GetTime() - 8
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, module.translatedName) then
		deathCount = deathCount + 1
		if deathCount >= 2 then
			BigWigs:CheckForBossDeath(msg, self)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["whirlwind_trigger"]) then
		self:Sync(syncName.whirlwind)
	end
	if string.find(msg, L["whirlwindEnd_trigger"]) then
		self:Sync(syncName.whirlwindEnd)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.whirlwind and self.db.profile.whirlwind then
		self:Whirlwind()
	elseif sync == syncName.whirlwindEnd and self.db.profile.whirlwind then
		self:WhirlwindEnd()
	end
end

function module:Whirlwind()
	if bwDkCapWwTime == nil then
		bwDkCapWwTime = GetTime()
	end
	if (GetTime() - bwDkCapWwTime) > 8 then
		self:Bar(L["whirlwind_bar1"], timer.whirlwind, icon.whirlwind, true, "red")
	else
		self:Bar(L["whirlwind_bar2"], timer.whirlwind, icon.whirlwind, true, "red")
	end
	if playerClass == "WARRIOR" or playerClass == "ROGUE" then
		if UnitName("target") == "Deathknight Captain" then
			self:WarningSign(icon.whirlwind, 0.7)
		end
	end
	bwDkCapWwTime = GetTime()
end

function module:WhirlwindEnd()
	if bwDkCapWwTimeCd == nil then
		bwDkCapWwTimeCd = GetTime()
	end
	if (GetTime() - bwDkCapWwTimeCd) > 8 then
		self:Bar(L["whirlwindCD_bar1"], timer.whirlwindCD, icon.whirlwind, true, "white")
	else
		self:Bar(L["whirlwindCD_bar2"], timer.whirlwindCD, icon.whirlwind, true, "white")
	end
	bwDkCapWwTimeCd = GetTime()
end
