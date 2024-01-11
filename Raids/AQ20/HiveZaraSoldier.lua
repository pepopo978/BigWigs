
local module, L = BigWigs:ModuleDeclaration("Hive'Zara Soldier", "Ruins of Ahn'Qiraj")

module.revision = 30040
module.enabletrigger = module.translatedName
module.toggleoptions = {"retaliationgain" , "retaliationhityou"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "HiveZaraSoldier",

	retaliationgain_cmd = "retaliationgain",
	retaliationgain_name = "Retaliation Gain Alert",
	retaliationgain_desc = "Warn for Retaliation Gain",
	
	retaliationhityou_cmd = "retaliationhityou",
	retaliationhityou_name = "Retaliation Hit You Alert",
	retaliationhityou_desc = "Warn for Retaliation Hit You",
	
	trigger_retaliationGain = "Hive'Zara Soldier gains Retaliation.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_retaliationGain = "Hive'Zara Soldier gains Retaliation!",
	
	trigger_retaliationHitYou = "Hive'Zara Soldier's Retaliation hits you for",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_retaliationHitYou = "STOP KILLING YOURSELF!",
	
	["You have slain %s!"] = true,
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
}
local icon = {
	retaliation = "ability_warrior_challange",
}
local color = {
}
local syncName = {
	retaliationGain = "HiveZaraSoldierRetaliationGain"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_retaliationGain
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_retaliationHitYou
	
	self:ThrottleSync(2, syncName.retaliationGain)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
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

function module:Event(msg)
	if msg == L["trigger_retaliationGain"] then
		self:Sync(syncName.retaliationGain)
	
	elseif string.find(msg, L["trigger_retaliationHitYou"]) and self.db.profile.retaliationhityou then
		self:HitYou()
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.retaliationGain and self.db.profile.retaliationgain then
		self:RetaliationGain()
	end
end


function module:RetaliationGain()
	self:Message(L["msg_retaliationGain"], "Attention", false, nil, false)
end

function module:HitYou()
	self:Message(L["msg_retaliationHitYou"], "Personal", false, nil, false)
	self:WarningSign(icon.retaliation, 0.7)
	self:Sound("Info")
end
