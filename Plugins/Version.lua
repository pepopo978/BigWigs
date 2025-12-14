assert(BigWigs, "BigWigs not found!")

local BWL = nil
local BZ = AceLibrary("Babble-Zone-2.2")
local L = AceLibrary("AceLocale-2.2"):new("BigWigsVersionQuery")
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

local COLOR_GREEN = "00ff00"
local COLOR_RED = "ff0000"
local COLOR_WHITE = "ffffff"
local COLOR_GREY = "808080"

local isInitialQuery = true

local fork = GetAddOnMetadata("BigWigs", "X-Fork")
local website = GetAddOnMetadata("BigWigs", "X-Website")

---------------------------------
--      Localization           --
---------------------------------

L:RegisterTranslations("enUS", function()
	return {
		["versionquery"] = true,
		["Version Query"] = true,
		["Commands for querying the raid for Big Wigs versions."] = true,
		["Query already running, please wait 5 seconds before trying again."] = true,
		["Querying versions for "] = true,
		["Big Wigs Version Query"] = true,
		["Close window"] = true, -- I know, it's really a Tablet.
		["Showing version for "] = true,
		["Green versions are newer than yours, red are older, and white are the same."] = true,
		["Player"] = true,
		["Version"] = true,
		["Current zone"] = true,
		["<zone>"] = true,
		["The given zone is invalid."] = true,
		["Version query done."] = true,
		["Runs a version query on your current zone."] = true,
		["Closes the version query window."] = true,
		["current"] = true,
		["Runs a version query on the given zone."] = true,
		["Zone"] = true,
		["zone"] = true,
		["missing module"] = true,
		["offline"] = true,
		["no response"] = true,
		["unknown"] = true,
		["Legacy"] = true,
		["BigWigs"] = true,
		["Runs a version query on the BigWigs core."] = true,
		["Nr Replies"] = true,

		["OutOfDate"] = "Your "..fork.." Big Wigs might be out of date!\nPlease visit "..website.." to get the latest version.",
		["Close"] = true,
		["Cancel"] = true,

		["People with outdated [fork] BigWigs:"] = "People with outdated "..fork.." BigWigs:",
		["Notify old versions"] = true,
		["List people with old versions to raid chat."] = true,
		["Download newest version from [website]"] = "Download newest version from "..website,

		["Show popup"] = true,
		["Show popup warning on out of date version"] = true,
	}
end)

---------------------------------
--      Addon Declaration      --
---------------------------------

BigWigsVersionQuery = BigWigs:NewModule("Version Query")

BigWigsVersionQuery.defaultDB = {
	versionpopup = false,
}
BigWigsVersionQuery.consoleCmd = L["versionquery"]
BigWigsVersionQuery.consoleOptions = {
	type = "group",
	name = L["Version Query"],
	desc = L["Commands for querying the raid for Big Wigs versions."],
	args = {
		[L["BigWigs"]] = {
			type = "execute",
			name = L["BigWigs"],
			order = 1,
			desc = L["Runs a version query on the BigWigs core."],
			func = function()
				BigWigsVersionQuery:QueryVersion("BigWigs")
			end,
		},
		[L["current"]] = {
			type = "execute",
			name = L["Current zone"],
			order = 2,
			desc = L["Runs a version query on your current zone."],
			func = function()
				BigWigsVersionQuery:QueryVersion()
			end,
		},
		[L["zone"]] = {
			type = "text",
			name = L["Zone"],
			order = 3,
			desc = L["Runs a version query on the given zone."],
			usage = L["<zone>"],
			get = false,
			set = function(zone)
				BigWigsVersionQuery:QueryVersion(zone)
			end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 10,
		},
		versionpopup = {
			type = "toggle",
			name = L["Show popup"],
			desc = L["Show popup warning on out of date version"],
			order = 12,
			get = function()
				return BigWigsVersionQuery.db.profile.versionpopup
			end,
			set = function(v)
				BigWigsVersionQuery.db.profile.versionpopup = v
			end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsVersionQuery:Test()
	BigWigsVersionQuery:QueryVersion("BigWigs")
end

function BigWigsVersionQuery:OnEnable()
	self.queryRunning = nil
	self.responseTable = {}
	self.zoneRevisions = nil
	self.currentZone = ""
	self.OutOfDateShown = false
	isInitialQuery = true -- reset after /console reloadui

	BWL = AceLibrary("AceLocale-2.2"):new("BigWigs")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "BWVQ", 0)
	self:TriggerEvent("BigWigs_ThrottleSync", "BWVR", 0)
	self:TriggerEvent("BigWigs_ThrottleSync", "PEPO_BWVR", 0)

	self:ScheduleEvent("versionquerytest", BigWigsVersionQuery.Test, 3, self) -- automatically check version after joining a raid, 3s delay to populate raid information after a relog
end

function BigWigsVersionQuery:PopulateRevisions()
	self.zoneRevisions = {}
	for name, module in self.core:IterateModules() do
		if module:IsBossModule() and module.zonename and type(module.zonename) == "string" then
			-- Make sure to get the enUS zone name.
			local zone = BZ:HasReverseTranslation(module.zonename) and BZ:GetReverseTranslation(module.zonename) or module.zonename
			-- Get the abbreviated name from BW Core.
			local zoneAbbr = BWL:HasTranslation(zone) and BWL:GetTranslation(zone) or nil
			if not self.zoneRevisions[zone] or module.revision > self.zoneRevisions[zone] then
				self.zoneRevisions[zone] = module.revision
			end
			if zoneAbbr and (not self.zoneRevisions[zoneAbbr] or module.revision > self.zoneRevisions[zoneAbbr]) then
				self.zoneRevisions[zoneAbbr] = module.revision
			end
		end
	end
	self.zoneRevisions["BigWigs"] = self.core.revision
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsVersionQuery:UpdateTablet()
	if not tablet:IsRegistered("BigWigs_VersionQuery") then
		tablet:Register("BigWigs_VersionQuery",
				"children", function()
					tablet:SetTitle(L["Big Wigs Version Query"])
					self:OnTooltipUpdate()
				end,
				"clickable", true,
				"showTitleWhenDetached", true,
				"showHintWhenDetached", true,
				"cantAttach", true,
				"menu", function()
					dewdrop:AddLine(
							"text", L["BigWigs"],
							"tooltipTitle", L["BigWigs"],
							"tooltipText", L["Runs a version query on the BigWigs core."],
							"func", function()
								self:QueryVersion("BigWigs")
							end)
					dewdrop:AddLine(
							"text", L["Current zone"],
							"tooltipTitle", L["Current zone"],
							"tooltipText", L["Runs a version query on your current zone."],
							"func", function()
								self:QueryVersion()
							end)
					dewdrop:AddLine(
							"text", L["Notify old versions"],
							"tooltipTitle", L["Notify old versions"],
							"tooltipText", L["List people with old versions to raid chat."],
							"func", function()
								self:NotifyOldVersions()
							end)
					dewdrop:AddLine(
							"text", L["Close window"],
							"tooltipTitle", L["Close window"],
							"tooltipText", L["Closes the version query window."],
							"func", function()
								tablet:Attach("BigWigs_VersionQuery");
								dewdrop:Close()
							end)
				end
		)
	end
	if tablet:IsAttached("BigWigs_VersionQuery") then
		tablet:Detach("BigWigs_VersionQuery")
	else
		tablet:Refresh("BigWigs_VersionQuery")
	end
end

function BigWigsVersionQuery:UpdateVersions()
	for name, entry in pairs(self.responseTable) do
		if not self.zoneRevisions then
			return
		end
		if entry[2] == fork then
			if self.zoneRevisions[self.currentZone] and entry[1] > self.zoneRevisions[self.currentZone] then
				self:IsOutOfDate()
			end
		end
	end

	if not isInitialQuery then
		self:UpdateTablet()
	end
end

function BigWigsVersionQuery:IsOutOfDate()
	if not self.OutOfDateShown then
		self.OutOfDateShown = true
		BigWigs:Print(L["OutOfDate"])

		if self.db.profile.versionpopup then
			local dialog = nil
			StaticPopupDialogs["BigWigsOutOfDateDialog"] = {
				text = L["OutOfDate"],
				button1 = L["Close"],
				button2 = L["Cancel"],
				OnAccept = function()
					StaticPopup_Hide("BigWigsOutOfDateDialog")
				end,
				OnCancel = function()
					StaticPopup_Hide("BigWigsOutOfDateDialog")
				end,
				OnShow = function(self, data)
					local editbox = getglobal(this:GetName() .. "WideEditBox")
					editbox:SetText(website)
					editbox:SetWidth(250)
					editbox:ClearFocus()
					editbox:HighlightText()
					getglobal(this:GetName() .. "Button2"):Hide()
				end,
				hasEditBox = true,
				hasWideEditBox = true,
				maxLetters = 42,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
			}
			local dialog = StaticPopup_Show("BigWigsOutOfDateDialog")
		end
	end
end

function BigWigsVersionQuery:NotifyOldVersions()
	local line = ""
	for name, entry in pairs(self.responseTable) do
		if entry[2] == fork and self.zoneRevisions[self.currentZone] and entry[1] < self.zoneRevisions[self.currentZone] then
			if line == "" then
				line = name
			else
				line = line .. " " .. name
			end
		end
	end
	SendChatMessage(L["People with outdated [fork] BigWigs:"], "RAID")
	SendChatMessage(line, "RAID")
	SendChatMessage(L["Download newest version from [website]"], "RAID")
end

function BigWigsVersionQuery:OnTooltipUpdate()
	local zoneCat = tablet:AddCategory(
			"columns", 1,
			"text", L["Zone"],
			"child_justify1", "LEFT"
	)
	zoneCat:AddLine("text", self.currentZone)
	local playerscat = tablet:AddCategory(
			"columns", 1,
			"text", L["Nr Replies"],
			"child_justify1", "LEFT"
	)
	playerscat:AddLine("text", self.responses)
	local cat = tablet:AddCategory(
			"columns", 2,
			"text", L["Player"],
			"text2", L["Version"],
			"child_justify1", "LEFT",
			"child_justify2", "RIGHT"
	)
	for name, entry in pairs(self.responseTable) do
		if entry[1] == -1 then
			cat:AddLine("text", name, "text2", "|cff" .. COLOR_RED .. entry[2] .. " " ..  L["missing module"] .. "|r")
		else
			local color = COLOR_GREY

			-- if they are using the same fork as us, compare revisions
			if entry[2] == fork then
				color = COLOR_WHITE
				if not self.zoneRevisions then
					self:PopulateRevisions()
				end
				if self.zoneRevisions[self.currentZone] and entry[1] > self.zoneRevisions[self.currentZone] then
					self:IsOutOfDate()
					color = COLOR_GREEN
				elseif self.zoneRevisions[self.currentZone] and entry[1] < self.zoneRevisions[self.currentZone] then
					color = COLOR_RED
				end
			elseif entry[1] == -3 then -- no response
				color = COLOR_RED
			end
			
			cat:AddLine("text", name, "text2", "|cff" .. color .. entry[2] .. " " .. entry[1] .. "|r")
		end
	end

	tablet:SetHint(L["Green versions are newer than yours, red are older, and white are the same."])
end

function BigWigsVersionQuery:QueryVersionAndShowWindow(zone)
	self:QueryVersion(zone)
	self:UpdateVersions()
end
function BigWigsVersionQuery:QueryVersion(zone)
	if self.queryRunning then
		self.core:Print(L["Query already running, please wait 5 seconds before trying again."])
		return
	end
	if not zone or zone == "" or type(zone) ~= "string" then
		zone = GetRealZoneText()
	end
	-- If this is a shorthand zone, convert it to enUS full.
	-- Also, if this is a shorthand, we can't really know if the user is enUS or not.

	if not BWL then
		BWL = AceLibrary("AceLocale-2.2"):new("BigWigs")
	end
	if BWL ~= nil and zone ~= nil and type(zone) == "string" and BWL:HasReverseTranslation(zone) then
		zone = BWL:GetReverseTranslation(zone)
		-- If there is a translation for this to GetLocale(), get it, so we can
		-- print the zone name in the correct locale.
		if BZ:HasTranslation(zone) then
			zone = BZ:GetTranslation(zone)
		end
	end

	if not zone then
		error(L["The given zone is invalid."])
		return
	end

	-- ZZZ |zone| should be translated here.
	if not isInitialQuery then
		self.core:Print(L["Querying versions for "] .. "|cff" .. COLOR_GREEN .. zone .. "|r.")
	end

	-- If this is a non-enUS zone, convert it to enUS.
	if BZ:HasReverseTranslation(zone) then
		zone = BZ:GetReverseTranslation(zone)
	end

	self.currentZone = zone

	self.queryRunning = true
	self:ScheduleEvent(function()
		self.queryRunning = nil
		if not isInitialQuery then
			self.core:Print(L["Version query done."])
		end
		isInitialQuery = false
	end, 5)

	self.responseTable = {}

	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			if GetRaidRosterInfo(i) then
				local n, _, _, _, _, _, z = GetRaidRosterInfo(i);

				if z == 'Offline' then
					self.responseTable[n] = {-2, L["offline"]}
				else
					self.responseTable[n] = {-3, L["no response"]}
				end
			end
		end
	else
		self.responseTable[UnitName("player")] = {}
	end

	if not self.zoneRevisions then
		self:PopulateRevisions()
	end
	if not self.zoneRevisions[zone] then
		self.responseTable[UnitName("player")][1] = -1
	else
		self.responseTable[UnitName("player")][1] = self.zoneRevisions[zone]
	end
	self.responseTable[UnitName("player")][2] = fork
	self.responses = 1
	self:TriggerEvent("BigWigs_SendSync", "BWVQ " .. zone)
end

--[[ Parses new style ("<rev> <nick>") with arbitrary additional payload ]]
function BigWigsVersionQuery:SplitReply(reply) --adapted from TWLC2 by CosminPOP
    local output = {}
    local from = 1
    local delim_from, delim_to = string.find(reply, " ", from)
    while delim_from do
        table.insert(output, string.sub(reply, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(reply, " ", from)
    end
    table.insert(output, string.sub(reply, from))
    return unpack(output)
end

--[[ Parses the old style reply, which was MC:REV BWL:REV, etc. ]]
function BigWigsVersionQuery:ParseReply(reply)
	if not string.find(reply, ":") then
		return -1
	end
	local zone = BWL:HasTranslation(self.currentZone) and BWL:GetTranslation(self.currentZone) or self.currentZone

	local zoneIndex, zoneEnd = string.find(reply, zone)
	if not zoneIndex then
		return -1
	end

	local revision = string.sub(reply, zoneEnd + 2, zoneEnd + 6)
	local convertedRev = tonumber(revision)
	if revision and convertedRev ~= nil then
		return convertedRev
	end

	return -1
end

--[[
-- Version reply syntax history:
--  Old Style:           MC:REV BWL:REV ZG:REV
--  First Working Style: REV
--  New Style:           REV QuereeNick
--  Fork Style:          REV QuereeNick Fork
--]]

function BigWigsVersionQuery:BigWigs_RecvSync(sync, rest, nick)
	if sync == "BWVQ" and nick ~= UnitName("player") and rest then
		if not self.zoneRevisions then
			self:PopulateRevisions()
		end
		if not self.zoneRevisions[rest] then
			self:TriggerEvent("BigWigs_SendSync", "PEPO_BWVR -1 " .. nick)
		else
			self:TriggerEvent("BigWigs_SendSync", "PEPO_BWVR " .. self.zoneRevisions[rest] .. " " .. nick)
		end
	elseif string.find(sync, "BWVR") and self.queryRunning and nick and rest then
		-- Means it's either a old style or new style reply.
		-- The "working style" is just the number, which was the second type of
		-- version reply we had.
		local revision, queryNick, remoteFork = nil, nil, nil

		if string.find(rest, ":") then -- old style
			revision = BigWigsVersionQuery:ParseReply(rest)
			remoteFork = L["Legacy"]
		elseif tonumber(rest) then -- first working style
			revision = tonumber(rest)
			remoteFork = L["Legacy"]
		else -- new style & fork style & future payloads
			revision, queryNick, remoteFork = self:SplitReply(rest)
			if remoteFork == nil then -- backwards compatibility
				if sync == "PEPO_BWVR" then
					remoteFork = "Pepo"
				else
					remoteFork = L["unknown"]
				end				
			end
		end

		if queryNick == nil or queryNick == UnitName("player") then
			self.responseTable[nick][1] = tonumber(revision)
			self.responseTable[nick][2] = remoteFork

			self.responses = self.responses + 1
			self:UpdateVersions()
		end
	end
end

