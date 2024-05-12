local module, L = BigWigs:ModuleDeclaration("The Prophet Skeram", "Ahn'Qiraj")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "bosskill"}

L:RegisterTranslations("enUS", function()
	return {
	cmd = "Skeram",

	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",

	split_cmd = "split",
	split_name = "Split Alert",
	split_desc = "Warn before Splitting",
	
	
		trigger_mcYou = "You are afflicted by True Fulfillment", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE (unconfirmed)
		trigger_mcOther2 = "(.+) %(.+%) is afflicted by True Fulfillment", --CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE new client pet message format
		trigger_mcOther = "(.+) is afflicted by True Fulfillment", --CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcFade = "True Fulfillment fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_mc = " is MC",
	bar_mc = " MC",
	
	trigger_kill = "You only delay... the inevetable.",--CHAT_MSG_MONSTER_YELL

	split_message = "Split!",
	kill_trigger = "You only delay",
	
	["You have slain %s!"] = true,
	}
end)

local timer = {
	mc = 20,
}
local icon = {
	mc = "Spell_Shadow_Charm",
}
local color = {
	mc = "White",
}
local syncName = {
	mc = "SkeramMC"..module.revision,
	mcFade = "SkeramMcFade"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_kill
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--mcYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")--mcOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_mcFade
	
	self:ThrottleSync(1, syncName.mc)
	self:ThrottleSync(1, syncName.mcFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.core:IsModuleActive("Anubisath Sentinel", "Ahn'Qiraj") then
		self.core:DisableModule("Anubisath Sentinel", "Ahn'Qiraj")
	end
	
	self:ScheduleRepeatingEvent("CheckTrueSkeram", self.CheckTrueSkeram, 0.5, self)
end

function module:OnDisengage()
	self:CancelScheduledEvent("CheckTrueSkeram")
end

function module:CheckForWipe()
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

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["kill_trigger"]) then
		self:SendBossDeathSync()
	end
end

function module:CheckTrueSkeram()
	if UnitName("Target") == "The Prophet Skeram" and (IsRaidLeader() or IsRaidOfficer()) then
		--hp scaling is supposed to be linear, based on raid members, from 20 to 40 members
			--doesn't scale below 20
			--hp at 40 is 454k and max clone hp is 233k, looking for maxhp > 400k giving a leeway of 54k for adjustments
		if GetNumRaidMembers() >= 20 and GetNumRaidMembers() <= 40 and (UnitHealthMax("Target") > (GetNumRaidMembers() * 10000)) or
		GetNumRaidMembers() < 20 and UnitHealthMax("Target") > 200000 then
			SetRaidTarget("target",6)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_mcYou"]) then
		self:Sync(syncName.mc .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_mcOther2"]) then
		local _, _, mcPerson = string.find(msg, L["trigger_mcOther2"])
		self:Sync(syncName.mc .. " " .. mcPerson)
	elseif string.find(msg, L["trigger_mcOther"]) then
		local _, _, mcPerson = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPerson)
	elseif string.find(msg, L["trigger_mcFade"]) then
		local _, _, mcFadePerson = string.find(msg, L["trigger_mcFade"])
		if mcFadePerson == "you" then
			mcFadePerson = UnitName("Player")
		end
		self:Sync(syncName.mcFade .. " " .. mcFadePerson)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mc and rest and self.db.profile.mc then
		self:MC(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.mc then
		self:McFade(rest)
	end
end

function module:MC(rest)
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 4)
			end
		end
	end
		
	self:Bar(rest..L["bar_mc"].. " >Click Me<", timer.mc, icon.mc, true, color.mc)
	self:SetCandyBarOnClick("BigWigsBar " .. rest .. L["bar_mc"] .. " >Click Me<", function(name, button, extra)
		TargetByName(extra, true)
	end, rest)
	self:Message(rest..L["msg_mc"], "Attention", false, nil, false)
end

function module:McFade(rest)
	self:RemoveBar(rest..L["bar_mc"].. " >Click Me<")
	
	if IsRaidLeader() or IsRaidOfficer() then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTargetIcon("raid"..i, 0)
			end
		end
	end
end
