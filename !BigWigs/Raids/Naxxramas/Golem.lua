
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Patchwork Golem", "Naxxramas")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "patchworkgolem",

	warstomp_cmd = "patch",
	warstomp_name = "War Stomp",
	warstomp_desc = "War Stomp timers",


	startwarn = "Aboms Pack engaged! 7 seconds to War Stomp!",

	warstomp_trigger1 = "War Stomp hits",
	warstomp_trigger2 = "War Stomp fails",
	warstomp_warn = "War Stomp! Next in 10 seconds!",
	warstomp_bar = "War Stomp",

	["You have slain %s!"] = true,
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
-- module.wipemobs = {} -- adds which will be considered in CheckForEngage
module.toggleoptions = {"warstomp"}
module.trashMod = true

module.defaultDB = {
	bosskill = nil,
}

-- locals
local timer = {
	warstomp = 7,
	warstompRepeat = 10,
}
local icon = {
	warstomp = "Ability_BullRush",
}
local syncName = {
	warstomp = "GolemWarStomp"..module.revision,
}


------------------------------
--      Initialization      --
------------------------------


-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CheckForWarStomp")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "CheckForWarStomp")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "CheckForWarStomp")

	self:ThrottleSync(4, syncName.warstomp)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self.started = nil
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.warstomp then
		self:Message(L["startwarn"], "Attention", nil, "Urgent")
		self:Bar(L["warstomp_bar"], timer.warstomp, icon.warstomp)
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

function module:CheckForWarStomp(msg)
	if string.find(msg, L["warstomp_trigger1"]) or string.find(msg, L["warstomp_trigger2"]) then
		self:Sync(syncName.warstomp)
	end
end

------------------------------
--      Synchronization	    --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.warstomp then
		self:WarStomp()
	end
end

------------------------------
--      Sync Handlers	    --
------------------------------

function module:WarStomp()
	if self.db.profile.warstomp then
		self:Message(L["warstomp_warn"], "Attention", nil)
		self:Bar(L["warstomp_bar"], timer.warstompRepeat, icon.warstomp)
	end
end
