--[[
by Dorann
Reduces farclip (terrain distance) to a minimum in naxxramas to avoid screen freezes
--]]


assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------
local L = AceLibrary("AceLocale-2.2"):new("BigWigsFarclip")
----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
	return {
		["Farclip"] = true,
		["farclip"] = true,
		["notify"] = "Notify when raising/lowering farclip",
		["NaxxFarclip"] = "Whether to lower farclip in Naxx.",
		["KaraFarclip"] = "Whether to lower farclip in Kara.",
		["Farclip value outside Raids"] = true,
		["Raid farclip value"] = "Value to set farclip to in Naxx/Kara",
		["lowering_farclip"] = "Lowering farclip for %s to %d and saving your current farclip of %d.  You can configure this in the Farclip plugin in BigWigs.",
		["restoring_farclip"] = "Restoring lowered farclip to your saved value of %d.",
		["low_spell_effects"] = "WARNING: Spell Effect Level is set to %d. Certain boss effects like void/pink zones may be hard or impossible to see. Click the bar to raise it, or type: /script SetCVar(\"spellEffectLevel\", \"2\")",
	}
end)

--[[L:RegisterTranslations("deDE", function() return {

} end)
]]
----------------------------------
--      Module Declaration      --
----------------------------------

local function isInNaxx()
	return AceLibrary("Babble-Zone-2.2")["Naxxramas"] == GetRealZoneText()
end

local function isInKara()
	return AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"] == GetRealZoneText() or
			GetRealZoneText() == "Outland" or
			GetRealZoneText() == "The Rock of Desolation"
end

BigWigsFarclip = BigWigs:NewModule(L["Farclip"])
BigWigsFarclip.revision = 20012
BigWigsFarclip.defaultDB = {
	notify = true,
	defaultFarclip = 777,
	lowFarClip = 250, -- using 177 will cause invisible mobs and portals to not load
	naxx = true,
	kara = true,
}
BigWigsFarclip.consoleCmd = L["farclip"]

BigWigsFarclip.consoleOptions = {
	type = "group",
	name = L["Farclip"],
	desc = L["Farclip"],
	args = {
		naxx = {
			type = "toggle",
			name = L["NaxxFarclip"],
			desc = L["NaxxFarclip"],
			order = 1,
			get = function()
				return BigWigsFarclip.db.profile.naxx
			end,
			set = function(v)
				BigWigsFarclip.db.profile.naxx = v
			end,
			--passValue = "reverse",
		},
		kara = {
			type = "toggle",
			name = L["KaraFarclip"],
			desc = L["KaraFarclip"],
			order = 2,
			get = function()
				return BigWigsFarclip.db.profile.kara
			end,
			set = function(v)
				BigWigsFarclip.db.profile.kara = v
			end,
		},
		notify = {
			type = "toggle",
			name = L["notify"],
			desc = L["notify"],
			order = 5,
			get = function()
				return BigWigsFarclip.db.profile.notify
			end,
			set = function(v)
				BigWigsFarclip.db.profile.notify = v
			end,
		},
		defaultfarclip = {
			type = "range",
			name = L["Farclip value outside Raids"],
			desc = L["Farclip value outside Raids"],
			order = 10,
			min = 177,
			max = 777,
			step = 1,
			get = function()
				return BigWigsFarclip.db.profile.defaultFarclip
			end,
			set = function(v)
				BigWigsFarclip.db.profile.defaultFarclip = v

				if not isInNaxx() and not isInKara() then
					SetCVar("farclip", v)
				end
			end,
		},
		raidfarclip = {
			type = "range",
			name = L["Raid farclip value"],
			desc = L["Raid farclip value"],
			order = 15,
			min = 177,
			max = 777,
			step = 1,
			get = function()
				return BigWigsFarclip.db.profile.lowFarClip
			end,
			set = function(v)
				BigWigsFarclip.db.profile.lowFarClip = v
			end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsFarclip:OnEnable()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function BigWigsFarclip:ZONE_CHANGED_NEW_AREA()
		local farclip = GetCVar("farclip")
		local isAtLowFarclip = tonumber(farclip) == tonumber(self.db.profile.lowFarClip)

	if self.db.profile.naxx and isInNaxx() then
			if not isAtLowFarclip then
				if self.db.profile.notify then
					local msg = string.format(L["lowering_farclip"], "Naxx", tonumber(self.db.profile.lowFarClip), tonumber(farclip))
					self:Message(msg, "Cyan", false, nil, false)
				end

				self.db.profile.defaultFarclip = GetCVar("farclip")
				SetCVar("farclip", self.db.profile.lowFarClip) -- http://wowwiki.wikia.com/wiki/CVar_farclip
			end
			local spellEffectLevel = tonumber(GetCVar("spellEffectLevel")) or 2
			if spellEffectLevel < 2 then
				local spellEffectMsg = string.format(L["low_spell_effects"], spellEffectLevel)
				self:Message(spellEffectMsg, "Red", false, nil, false)
				DEFAULT_CHAT_FRAME:AddMessage("BIGWIGS: " .. spellEffectMsg, 1, 1, 0)
				self:Bar(">CLICK ME< Set spellEffectLevel=2", 10, "Spell_Magic_LesserInvisibilty", true, "Red")
				self:SetCandyBarOnClick("BigWigsBar >CLICK ME< Set spellEffectLevel=2", function()
					SetCVar("spellEffectLevel", 2)
					DEFAULT_CHAT_FRAME:AddMessage("BigWigs: spellEffectLevel set to " .. GetCVar("spellEffectLevel"), 0, 1, 0)
					self:RemoveBar(">CLICK ME< Set spellEffectLevel=2")
				end)
			end
	elseif self.db.profile.kara and isInKara() then
		if not isAtLowFarclip then
			if self.db.profile.notify then
				local msg = string.format(L["lowering_farclip"], "Kara", tonumber(self.db.profile.lowFarClip), tonumber(farclip))
				self:Message(msg, "Cyan", false, nil, false)
			end

			self.db.profile.defaultFarclip = GetCVar("farclip")
			SetCVar("farclip", self.db.profile.lowFarClip) -- http://wowwiki.wikia.com/wiki/CVar_farclip
		end
		local spellEffectLevel = tonumber(GetCVar("spellEffectLevel")) or 2
		if spellEffectLevel < 2 then
			local spellEffectMsg = string.format(L["low_spell_effects"], spellEffectLevel)
			self:Message(spellEffectMsg, "Red", false, nil, false)
			DEFAULT_CHAT_FRAME:AddMessage("BIGWIGS: " .. spellEffectMsg, 1, 1, 0)
			self:Bar(">CLICK ME< Set spellEffectLevel=2", 10, "Spell_Magic_LesserInvisibilty", true, "Red")
			self:SetCandyBarOnClick("BigWigsBar >CLICK ME< Set spellEffectLevel=2", function()
				SetCVar("spellEffectLevel", 2)
				DEFAULT_CHAT_FRAME:AddMessage("BigWigs: spellEffectLevel set to " .. GetCVar("spellEffectLevel"), 0, 1, 0)
				self:RemoveBar(">CLICK ME< Set spellEffectLevel=2")
			end)
		end
	else
		if isAtLowFarclip then
			if self.db.profile.notify then
				local msg = string.format(L["restoring_farclip"], tonumber(self.db.profile.defaultFarclip))
				self:Message(msg, "Cyan", false, nil, false)
			end

			SetCVar("farclip", self.db.profile.defaultFarclip)
		end
	end
end
