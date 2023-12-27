
local module, L = BigWigs:ModuleDeclaration("Qiraji Brainwasher", "Ahn'Qiraj")

module.revision = 30025
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "BrainWasher",
	
	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",
	
	trigger_mcYou = "You are afflicted by Cause Insanity.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE          --To be confirmed
	trigger_mcOther = "(.+) is afflicted by Cause Insanity.",--CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcFade = "Cause Insanity fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mc = " MC",
	
	["You have slain %s!"] = true,
	
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	mc = 10,
}

local icon = {
	mc = "spell_shadow_shadowworddominate",
}

local color = {
	mc = "Black",
}

local syncName = {
	mc = "BrainwasherMc"..module.revision,
	mcFade = "BrainwasherMcFade"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SAY", "Events")--Debug
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Events")--trigger_mcOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Events")--trigger_mcYou
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Events")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Events")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Events")--trigger_mcFade
	
	self:ThrottleSync(1, syncName.mc)
	self:ThrottleSync(1, syncName.mcFade)
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

function module:Events(msg)
	if msg == L["trigger_mcYou"] then
		self:Sync(syncName.mc .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_mcOther"]) then
		local _,_, mcPerson, _ = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPerson)
		
	elseif string.find(msg, L["trigger_mcFade"]) then
		local _,_, mcFadePerson, _ = string.find(msg, L["trigger_mcFade"])
		if mcFadePerson == "you" then mcFadePerson = UnitName("Player") end
		self:Sync(syncName.mcFade .. " " .. mcFadePerson)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mc and rest and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.mc then
		self:McFade(rest)
	end
end


function module:Mc(rest)
	self:Bar(rest..L["bar_mc"], timer.mc, icon.mc, true, color.mc)
	
	for i=1,GetNumRaidMembers() do
		if UnitName("raid"..i) == rest then
			SetRaidTargetIcon("raid"..i, 6)
		end
	end
end

function module:McFade(rest)
	self:RemoveBar(rest..L["bar_mc"])
end
