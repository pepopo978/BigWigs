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
		["Active"] = true,
		["Farclip"] = true,
		["farclip"] = true,
		["notify"] = "Notify when raising/lowering farclip",
		["NaxxFarclip"] = "Whether to lower farclip in Naxx.",
		["Farclip value outside Naxx"] = true,
		["Naxx farclip value"] = true,
		["lowering_farclip"] = "Lowering farclip for Naxxramas to %d and saving your current farclip of %d.  You can configure this in the Farclip plugin in BigWigs.",
		["restoring_farclip"] = "Restoring lowered farclip to your saved value of %d.",
		["Reduces the terrain distance to the minimum in Naxxramas to avoid screen freezes."] = true,
	}
end)

--[[L:RegisterTranslations("deDE", function() return {

} end)
]]
----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsFarclip = BigWigs:NewModule(L["Farclip"])
BigWigsFarclip.revision = 20012
BigWigsFarclip.defaultDB = {
	active = false,
	notify = true,
	defaultFarclip = 777,
	lowFarClip = 250, -- using 177 will cause invisible mobs and portals to not load
}
BigWigsFarclip.consoleCmd = L["farclip"]

BigWigsFarclip.consoleOptions = {
	type = "group",
	name = L["Farclip"],
	desc = L["Farclip"],
	args = {
		active = {
			type = "toggle",
			name = L["NaxxFarclip"],
			desc = L["NaxxFarclip"],
			order = 1,
			get = function()
				return BigWigsFarclip.db.profile.active
			end,
			set = function(v)
				BigWigsFarclip.db.profile.active = v
			end,
			--passValue = "reverse",
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
			name = L["Farclip value outside Naxx"],
			desc = L["Farclip value outside Naxx"],
			order = 10,
			min = 177,
			max = 777,
			step = 1,
			get = function()
				return BigWigsFarclip.db.profile.defaultFarclip
			end,
			set = function(v)
				BigWigsFarclip.db.profile.defaultFarclip = v

				if not BigWigsFarclip.db.profile.active or AceLibrary("Babble-Zone-2.2")["Naxxramas"] ~= GetRealZoneText() then
					SetCVar("farclip", v)
				end
			end,
		},
		naxxfarclip = {
			type = "range",
			name = L["Naxx farclip value"],
			desc = L["Naxx farclip value"],
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
	if self.db.profile.active then
		local farclip = GetCVar("farclip")
		local isAtLowFarclip = tonumber(farclip) == tonumber(self.db.profile.lowFarClip)

		if AceLibrary("Babble-Zone-2.2")["Naxxramas"] == GetRealZoneText() then
			if not isAtLowFarclip then
				if self.db.profile.notify then
					local msg = string.format(L["lowering_farclip"], tonumber(self.db.profile.lowFarClip), tonumber(farclip))
					self:Message(msg, "Cyan", false, nil, false)
				end

				self.db.profile.defaultFarclip = GetCVar("farclip")
				SetCVar("farclip", self.db.profile.lowFarClip) -- http://wowwiki.wikia.com/wiki/CVar_farclip
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
end
