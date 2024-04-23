local module, L = BigWigs:ModuleDeclaration("Qiraji Brainwasher", "Ahn'Qiraj")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = { "mc", "mindflay" }
module.trashMod = true
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "BrainWasher",

		mc_cmd = "mc",
		mc_name = "Mind Control Alert",
		mc_desc = "Warn for Mind Control",

		mindflay_cmd = "mindflay",
		mindflay_name = "Mind Flay Alert",
		mindflay_desc = "Warn for Mind Flay",


		trigger_mcYou = "You are afflicted by Cause Insanity", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_mcOther2 = "(.+) %(.+%) is afflicted by Cause Insanity", --CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE new client pet message format
		trigger_mcOther = "(.+) is afflicted by Cause Insanity", --CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
		trigger_mcFade = "Cause Insanity fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_mc = " MC",

		trigger_mindFlayYou = "You are afflicted by Mind Flay.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_mindFlayOther = "(.+) is afflicted by Mind Flay.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
		trigger_mindFlayFade = "Mind Flay fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
		bar_mindFlay = " Mind Flay",

		["You have slain %s!"] = true,
	}
end)

local timer = {
	mc = 10,
	mindFlay = 8,
}
local icon = {
	mc = "spell_shadow_shadowworddominate",
	mindFlay = "spell_shadow_siphonmana",
}
local color = {
	mc = "Black",
	mindFlay = "Blue",
}
local syncName = {
	mc = "BrainwasherMc" .. module.revision,
	mcFade = "BrainwasherMcFade" .. module.revision,
	mindFlay = "BrainwasherMindFlay" .. module.revision,
	mindFlayFade = "BrainwasherMindFlayFade" .. module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Events")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Events")--trigger_mcOther, trigger_mindFlayOther

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Events")--trigger_mcYou, trigger_mindFlayYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Events")--trigger_mcYou, trigger_mindFlayOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Events")--trigger_mcYou, trigger_mindFlayOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Events")--trigger_mcFade, trigger_mindFlayFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Events")--trigger_mcFade, trigger_mindFlayFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Events")--trigger_mcFade, trigger_mindFlayFade


	self:ThrottleSync(1, syncName.mc)
	self:ThrottleSync(0.2, syncName.mcFade)
	self:ThrottleSync(1, syncName.mindFlay)
	self:ThrottleSync(0.2, syncName.mindFlayFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.core:IsModuleActive("Anubisath Sentinel", "Ahn'Qiraj") then
		self.core:DisableModule("Anubisath Sentinel", "Ahn'Qiraj")
	end
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
			or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then
				return false
			end
			if type(t) == "string" then
				t = { t }
			end

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

	elseif string.find(msg, L["trigger_mcOther2"]) then
		local _, _, mcPerson, _ = string.find(msg, L["trigger_mcOther2"])
		self:Sync(syncName.mc .. " " .. mcPerson)

	elseif string.find(msg, L["trigger_mcOther"]) then
		local _, _, mcPerson, _ = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPerson)

	elseif string.find(msg, L["trigger_mcFade"]) then
		local _, _, mcFadePerson, _ = string.find(msg, L["trigger_mcFade"])
		if mcFadePerson == "you" then
			mcFadePerson = UnitName("Player")
		end
		self:Sync(syncName.mcFade .. " " .. mcFadePerson)


	elseif msg == L["trigger_mindFlayYou"] then
		self:Sync(syncName.mindFlay .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_mindFlayOther"]) then
		local _, _, mindFlayPerson, _ = string.find(msg, L["trigger_mindFlayOther"])
		self:Sync(syncName.mindFlay .. " " .. mindFlayPerson)

	elseif string.find(msg, L["trigger_mindFlayFade"]) then
		local _, _, mindFlayFadePerson, _ = string.find(msg, L["trigger_mindFlayFade"])
		if mindFlayFadePerson == "you" then
			mindFlayFadePerson = UnitName("Player")
		end
		self:Sync(syncName.mindFlayFade .. " " .. mindFlayFadePerson)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mc and rest and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.mc then
		self:McFade(rest)

	elseif sync == syncName.mindFlay and rest and self.db.profile.mindflay then
		self:MindFlay(rest)
	elseif sync == syncName.mindFlayFade and rest and self.db.profile.mindflay then
		self:MindFlayFade(rest)
	end
end

function module:Mc(rest)
	self:Bar(rest .. L["bar_mc"] .. " >Click Me<", timer.mc, icon.mc, true, color.mc)
	self:SetCandyBarOnClick("BigWigsBar " .. rest .. L["bar_mc"] .. " >Click Me<", function(name, button, extra)
		TargetByName(extra, true)
	end, rest)

	if IsRaidLeader() or IsRaidOfficer() then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid" .. i) == rest then
				SetRaidTargetIcon("raid" .. i, 6)
			end
		end
	end
end

function module:McFade(rest)
	self:RemoveBar(rest .. L["bar_mc"] .. " >Click Me<")

	if IsRaidLeader() or IsRaidOfficer() then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid" .. i) == rest then
				SetRaidTargetIcon("raid" .. i, 0)
			end
		end
	end
end

function module:MindFlay(rest)
	self:Bar(rest .. L["bar_mindFlay"], timer.mindFlay, icon.mindFlay, true, color.mindFlay)
end

function module:MindFlayFade(rest)
	self:RemoveBar(rest .. L["bar_mindFlay"])
end
