
local module, L = BigWigs:ModuleDeclaration("Deathknight Captain", "Naxxramas")

module.revision = 30071
module.enabletrigger = module.translatedName
module.toggleoptions = {"whirlwind"}
module.trashMod = true
module.defaultDB = {
	bosskill = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "deathknightCaptain",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind Alert",
	whirlwind_desc = "Warn for Whirlwind",
	
	
	trigger_whirlwind = "Deathknight Captain gains Whirlwind.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_whirlwindFade = "Whirlwind fades from Deathknight Captain.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_whirlwind1 = "Whirlwind 1",
	bar_whirlwind2 = "Whirlwind 2",
	bar_whirlwindCd1 = "Whirlwind CD 1",
	bar_whirlwindCd2 = "Whirlwind CD 2",

	["You have slain %s!"] = true,
} end )

local timer = {
	whirlwindDur = 6,
	whirlwindCd = 9,
}
local icon = {
	whirlwind = "ability_whirlwind"
}
local color = {
	whirlwindDur = "Red",
	whirlwindCd = "White",
}
local syncName = {
	whirlwind = "DkCapWW"..module.revision,
	whirlwindEnd = "DkCapWWEnd"..module.revision,
}

local wwStartTime = 0
local wwEndTime = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_whirlwind
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_whirlwindFade
	
	
	self:ThrottleSync(1, syncName.whirlwind)
	self:ThrottleSync(1, syncName.whirlwindEnd)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	wwStartTime = 0
	wwEndTime = 0
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("Target") and UnitAffectingCombat("Target") then
				local target = UnitName("Target")
				for _, mob in pairs(t) do
					if target == mob then
						return true
					end
				end
			end

			local num = GetNumRaidMembers()
			for i = 1, num do
				local raidUnit = string.format("raid%starget", i)
				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
					local target = UnitName(raidUnit)
					for _, mob in pairs(t) do
						if target == mob then
							return true
						end
					end
				end
			end
			return false
		end

		if not IsBossInCombat() then
			self:SendBossDeathSync()
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_whirlwind"] then
		self:Sync(syncName.whirlwind)
	elseif msg == L["trigger_whirlwindFade"] then
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
	if (GetTime() - wwStartTime) > 8 then
		self:Bar(L["bar_whirlwind1"], timer.whirlwindDur, icon.whirlwind, true, color.whirlwindDur)
	else
		self:Bar(L["bar_whirlwind2"], timer.whirlwindDur, icon.whirlwind, true, color.whirlwindDur)
	end
	
	if UnitName("Target") == "Deathknight Captain" and (UnitClass("Player") == "Warrior" or UnitClass("Player") == "Rogue" or UnitClass("Player") == "Druid" or UnitClass("Player") == "Paladin") then
		self:WarningSign(icon.whirlwind, 0.7)
	end
	
	wwStartTime = GetTime()
end

function module:WhirlwindEnd()
	if (GetTime() - wwEndTime) > 8 then
		self:Bar(L["bar_whirlwindCd1"], timer.whirlwindCd, icon.whirlwind, true, color.whirlwindCd)
	else
		self:Bar(L["bar_whirlwindCd2"], timer.whirlwindCd, icon.whirlwind, true, color.whirlwindCd)
	end
	wwEndTime = GetTime()
end
