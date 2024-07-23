local name = "Spell Requests"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local BS = AceLibrary("Babble-Spell-2.2")

local Spells = {
	pi = {
		spellName = "Power Infusion",
		requestSync = "BWREQPI",
		receivedSync = "BWRECVPI",
		cooldownSync = "BWREQCDPI",
		spellIcon = "Spell_Holy_PowerInfusion",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
	},
	bop = {
		spellName = "Blessing of Protection",
		requestSync = "BWREQBOP",
		receivedSync = "BWRECVBOP",
		cooldownSync = "BWREQCDBOP",
		spellIcon = "Spell_Holy_SealOfProtection",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
	},
	bl = {
		spellName = "Bloodlust",
		requestSync = "BWREQBL",
		receivedSync = "BWRECVBL",
		cooldownSync = "BWREQCDBL",
		spellIcon = "Spell_Nature_BloodLust",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
	}
}

L:RegisterTranslations("enUS", function()
	return {
		spellrequests = "spellrequests",
		iconPrefix = "Interface\\Icons\\",

		msg_fearward = " FearWard on ",
		bar_fearward = " FearWard CD",

		title = "Spell Requests",
		desc = "Spell Requests",

		powerinfusion = "PI",
		bop = "BOP",

		boptitle = "BOP Requests",
		bopdesc = "Show bar for BOP requests",
		powerinfusiontitle = "PI Requests",
		powerinfusiondesc = "Show bar for PI requests",
		bloodlusttitle = "BL Requests",
		bloodlustdesc = "Show bar for BL requests",

		requestbop = "Trigger request for BOP",
		requestpi = "Trigger request for PI",
		requestbl = "Trigger request for BL",

		powerinfusion_trigger = "You gain Power Infusion",
		bop_trigger = "You gain Blessing of Protection",
		bl_trigger = "You gain Bloodlust",

		bop_fades = "Blessing of Protection fades",
		powerinfusion_fades = "Power Infusion fades",
		bl_fades = "Bloodlust fades",

		forbearance = "Cannot request BOP while you have Forbearance",
	}
end)

local function GetSpellSlot(targetSpellName)
	local spellSlot = 1;

	while true do
		local spellName, _ = GetSpellName(spellSlot, BOOKTYPE_SPELL);
		if not spellName then
			do
				break
			end
		end

		if spellName == targetSpellName then
			return spellSlot;
		end
		spellSlot = spellSlot + 1;
	end

	return nil;
end

local _, englishClass = UnitClass("player");
local isPriest = false;
local isPaladin = false;
if englishClass == "PRIEST" then
	isPriest = true;
elseif englishClass == "PALADIN" then
	isPaladin = true;
end
local hasSuperWow = nil;
if SetAutoLoot then
	hasSuperWow = true;
end

BigWigsSpellRequests = BigWigs:NewModule(name)
BigWigsSpellRequests.synctoken = myname
BigWigsSpellRequests.defaultDB = {
	powerinfusion = isPriest,
	bop = isPaladin,
}
BigWigsSpellRequests.consoleCmd = L["spellrequests"]
BigWigsSpellRequests.revision = 30064
BigWigsSpellRequests.external = true
BigWigsSpellRequests.consoleOptions = {
	type = "group",
	name = L["title"],
	desc = L["desc"],
	args = {
		bop = {
			type = "toggle",
			name = L["boptitle"],
			desc = L["bopdesc"],
			order = 1,
			get = function()
				return BigWigsSpellRequests.db.profile.bop
			end,
			set = function(v)
				BigWigsSpellRequests.db.profile.bop = v
			end,
		},
		powerinfusion = {
			type = "toggle",
			name = L["powerinfusiontitle"],
			desc = L["powerinfusiondesc"],
			order = 10,
			get = function()
				return BigWigsSpellRequests.db.profile.powerinfusion
			end,
			set = function(v)
				BigWigsSpellRequests.db.profile.powerinfusion = v
			end,
		},
		bloodlust = {
			type = "toggle",
			name = L["bloodlusttitle"],
			desc = L["bloodlustdesc"],
			order = 15,
			get = function()
				return BigWigsSpellRequests.db.profile.bloodlust
			end,
			set = function(v)
				BigWigsSpellRequests.db.profile.bloodlust = v
			end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 20,
		},
		requestpi = {
			type = "execute",
			name = L["requestpi"],
			desc = L["requestpi"],
			order = 30,
			func = function()
				BigWigsSpellRequests:Sync(Spells.pi.requestSync .. " " .. UnitName("player"))
			end,
		},
		requestbl = {
			type = "execute",
			name = L["requestbl"],
			desc = L["requestbl"],
			order = 35,
			func = function()
				BigWigsSpellRequests:Sync(Spells.bl.requestSync .. " " .. UnitName("player"))
			end,
		},
		requestbop = {
			type = "execute",
			name = L["requestbop"],
			desc = L["requestbop"],
			order = 40,
			func = function()
				local forbearanceTexture = "Interface\\Icons\\Spell_Holy_RemoveCurse"
				-- check if they have forbearance
				for i = 1, 16 do
					local texture = UnitDebuff("player", i)
					if not texture then
						break
					end
					if texture == forbearanceTexture then
						BigWigsSpellRequests:Message(L["forbearance"], "Attention", false)
						return
					end
					i = i + 1
				end

				BigWigsSpellRequests:Sync(Spells.bop.requestSync .. " " .. UnitName("player"))
			end,
		},
	}
}

function BigWigsSpellRequests:OnEnable()
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")

	self.playerName = UnitName("player")

	for _, spellData in pairs(Spells) do
		spellData.spellSlot = GetSpellSlot(BS[spellData.spellName])
		if spellData.spellSlot then
			spellData.hasSpell = true
		end
		self:ThrottleSync(5, spellData.requestSync)
		self:ThrottleSync(1, spellData.receivedSync)
		self:ThrottleSync(1, spellData.cooldownSync)
	end
end

function BigWigsSpellRequests:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS(msg)
	if string.find(msg, L["bop_trigger"]) and self.db.profile.bop then
		self:TriggerEvent("BigWigs_SendSync", self.sync.receivedBOP .. " " .. self.playerName)
	elseif string.find(msg, L["powerinfusion_trigger"]) and self.db.profile.powerinfusion then
		self:TriggerEvent("BigWigs_SendSync", self.sync.receivedPI .. " " .. self.playerName)
	elseif string.find(msg, L["bl_trigger"]) and self.db.profile.bloodlust then
		self:TriggerEvent("BigWigs_SendSync", self.sync.receivedBL .. " " .. self.playerName)
	end
end

function BigWigsSpellRequests:CheckCooldown(spellSlot)
	local start, duration, enable = GetSpellCooldown(spellSlot, BOOKTYPE_SPELL)
	if start == 0 then
		return 0
	end
	local cd = start + duration - GetTime()
	if cd < 0 then
		return 0
	end
	return cd
end

local function getBarTitle(spellName, playerName)
	return playerName .. " wants " .. spellName .. " CLICK HERE"
end

function BigWigsSpellRequests:BigWigs_RecvSync(sync, data)
	for _, spellData in pairs(Spells) do
		-- if this is a request check if we have the spell
		if sync == spellData.requestSync and spellData.hasSpell then
			local playerName = data
			-- check cooldown
			local cd = self:CheckCooldown(spellData.spellSlot)
			if cd ~= 0 then
				-- send the cooldown to the requester
				-- format: cooldownSync requesterPlayerName cooldownPlayername|spellname|cooldown
				self:TriggerEvent("BigWigs_SendSync",
						string.format("%s %s;%s;%s;%d", spellData.cooldownSync, playerName, self.playerName, spellData.spellName, cd))
			else
				-- show candybar saying that playername wants spellname
				local barTitle = getBarTitle(BS[spellData.spellName], playerName)

				self:TriggerEvent("BigWigs_StartBar", self, barTitle, 5, spellData.spellIcon, true, "white")
				if spellData.targetRequester then
					-- enable clicking on the bar to cast on that player
					self:SetCandyBarOnClick("BigWigsBar " .. barTitle, function(_, _, pName, sName)
						if hasSuperWow then
							local _, guid = UnitExists(pName)
							CastSpellByName(sName, guid)
						else
							TargetByName(pName, true)
							CastSpellByName(sName)
						end
					end, playerName, BS[spellData.spellName])
				end
			end
			-- if this is a cooldown sync being sent back to us
		elseif sync == spellData.cooldownSync then
			local _, _, playerName, cooldownPlayerName, spellName, cooldown = string.find(data, "(.-);(.-);(.-);(%d+)")
			if self.playerName == playerName then
				-- show a message saying that cooldownPlayerName has a cooldown for spellName
				self:Message(string.format("%s CD for %s: %d seconds", cooldownPlayerName, spellName, cooldown),
						"Personal", false)
			end
		elseif sync == spellData.receivedSync then
			local playerName = data

			-- player has received the spell, hide the bar if visible
			local barTitle = getBarTitle(BS[spellData.spellName], playerName)
			self:TriggerEvent("BigWigs_StopBar", self, barTitle)
		end
	end
end
