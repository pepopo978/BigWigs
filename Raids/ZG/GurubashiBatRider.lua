
local module, L = BigWigs:ModuleDeclaration("Gurubashi Bat Rider", "Zul'Gurub")

module.revision = 20001
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "bars"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "BatRider",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon warnings",
	bigicon_desc = "Big icon warning on explosion",
	
	explodingTrigger = "Gurubashi Bat Rider gets a crazed look in his eye.",
	explodingTrigger2 = "Gurubashi Bat Rider becomes fully engulfed in flames.",
	explodingBar = "Exploding",
	explodingMsg = "Exploding!",
	
	["You have slain %s!"] = true,
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	exploding = 3,
}

local icon = {
	exploding = "spell_fire_incinerate",
}

local syncName = {
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Emote")
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Emote(msg)
	if msg == L["explodingTrigger"] or msg == L["explodingTrigger2"] then
		self:Bar(L["explodingBar"], timer.exploding, icon.exploding, true, "Red")
		self:Message(L["explodingMsg"], "Important")
		if self.db.profile.bigicon then
			self:WarningSign(icon.exploding, 1)
		end
		
		self:Sound("RunAway")
	end
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
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
