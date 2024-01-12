
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Carrion Spinner", "Naxxramas")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "spiderpack",

	poisonspray_cmd = "poisonspray",
	poisonspray_name = "Poison Spray",
	poisonspray_desc = "Poison Spray timers",

	unbalance_cmd = "unbalancing",
	unbalance_name = "Unbalancing Strike Alert",
	unbalance_desc = "Warn for Unbalancing Strike",


	startwarn = "Spider Pack engaged! 7 seconds to poison spray wave!",

	poisonspray_trigger1 = "Poison Spray hits",
	poisonspray_trigger2 = "Poison Spray was resisted",
	poisonspray_warn = "Poison Spray! Next in 7 seconds!",
	poisonspray_bar = "Poison Spray",

	["You have slain %s!"] = true,
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
-- module.wipemobs = {} -- adds which will be considered in CheckForEngage
module.toggleoptions = {"poisonspray"}
module.trashMod = true

module.defaultDB = {
	bosskill = nil,
}

-- locals
local timer = {
	poisonspray = 7,
}
local icon = {
	poisonspray = "Spell_Nature_CorrosiveBreath",
}
local syncName = {
	poisonspray = "SpiderPoisonSpray"..module.revision,
}


------------------------------
--      Initialization      --
------------------------------


-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CheckForPoisonSpray")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "CheckForPoisonSpray")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "CheckForPoisonSpray")

	self:ThrottleSync(4, syncName.poisonspray)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self.started = nil
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.poisonspray then
		self:Message(L["startwarn"], "Attention", nil)
		self:Bar(L["poisonspray_bar"], timer.poisonspray, icon.poisonspray)
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(self:ToString(), UNITDIESOTHER) or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("target") and UnitAffectingCombat("target") then
				local target = UnitName("target")
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


------------------------------
--      Initialization      --
------------------------------

function module:CheckForPoisonSpray(msg)
	if string.find(msg, L["poisonspray_trigger1"]) or string.find(msg, L["poisonspray_trigger2"]) then
		self:Sync(syncName.poisonspray)
	end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.poisonspray then
		self:PoisonSpray()
	end
end

------------------------------
--      Sync Handlers	    --
------------------------------

function module:PoisonSpray()
	if self.db.profile.poisonspray then
		self:Message(L["poisonspray_warn"], "Attention", nil)
		self:Bar(L["poisonspray_bar"], timer.poisonspray, icon.poisonspray)
	end
end
