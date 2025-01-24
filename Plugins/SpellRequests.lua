local name = "Spell Requests"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local BS = AceLibrary("Babble-Spell-2.3")

local hasSuperWow = nil;
if CombatLogAdd then
	hasSuperWow = true;
end

local modulePrefix = "BWSR"
local spellRequestCommand = "SPREQ"
local spellReceivedCommand = "SPRECV"
local cooldownRequestCommand = "CDREQ"
local cooldownResponseCommand = "CDRESP"

local syncFormat = modulePrefix .. "(.+)" --modulePrefix + command
local dataFormat = "(.-);(.+)" -- spellShortName;spellArgs

local Spells = {
	bop = {
		spellName = "Hand of Protection",
		spellIcon = "Spell_Holy_SealOfProtection",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
		allowRequests = true,
	},
	ivate = {
		spellName = "Innervate",
		spellIcon = "Spell_Nature_Lightning",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
		allowRequests = true,
	},
	fearward = {
		spellName = "Fear Ward",
		spellIcon = "Spell_Holy_Excorcism",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
		allowRequests = true,
	},
	sunwell = {
		spellName = "Grace of the Sunwell",
		spellIcon = "Spell_Holy_Mindvision",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
		allowRequests = true,
	},
	spiritlink = {
		spellName = "Spirit Link",
		spellIcon = "Spell_Shaman_SpiritLink",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = true,
		allowRequests = true,
	},
	tranquility = {
		spellName = "Tranquility",
		spellIcon = "Spell_Nature_Tranquility",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = false,
		allowRequests = true,
	},
	-- check cooldowns only
	cshout = {
		spellName = "Challenging Shout",
		spellIcon = "Ability_BullRush",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = false,
		allowRequests = false,
	},
	brez = {
		spellName = "Rebirth",
		spellIcon = "Spell_Nature_Reincarnation",
		spellSlot = nil,
		hasSpell = nil,
		targetRequester = false,
		allowRequests = false,
	},
}

L:RegisterTranslations("enUS", function()
	return {
		spellrequests = "spellrequests",
		iconPrefix = "Interface\\Icons\\",

		enable = "Enable",

		title = "Spell Requests",
		desc = "Spell Requests",

		enabledtitle = "Enable",
		enableddesc = "Enables/Disables the spell requests module.",

		fulfillrequest = "Fulfill Request",
		fulfillrequestdesc = "Will fulfill the oldest request you have received.  To use in a macro /bw extra spellrequests fulfillrequest",

		allowedrequests = "Allowed Requests",
		triggerrequests = "Trigger Requests",
		checkcooldowns = "Check Cooldowns",
		requestsuserinterface = "Requests UI",
		cooldownsuserinterface = "Cooldowns UI",
		userinterfaceoptions = "UI Options",

		showrequeststitle = "Show/Hide Requests Frame",
		showrequestsdesc = "Toggles a frame with buttons to request spells.  To use in a macro /bw extra spellrequests userinterface showrequestsframe.",
		showcooldownstitle = "Show/Hide Cooldowns Frame",
		showcooldownsdesc = "Toggles a frame with buttons to check cooldowns.  To use in a macro /bw extra spellrequests userinterface showcooldownsframe.",

		showrequesttitle = "Show %s requests",
		showrequestallowtargetingdesc = "Shows a bar with the name of the player requesting %s that you can click to cast the spell on them.",
		showrequestdesc = "Shows a bar with the name of the player requesting %s.",

		showreqbuttontitle = "Show %s request button",

		showcdbuttontitle = "Show %s cooldown button",

		ignorelisttitle = "Player Ignore List (Enter to save)",
		ignorelistdesc = "Comma separated list of player names to ignore requests from.  Hit enter to save changes.",

		triggerrequesttitle = "Request %s",
		triggerrequestdesc = "Will notify players that can cast %s that you want it.  To use in a macro /bw extra spellrequests triggerrequests request%s.",

		triggercooldownchecktitle = "Check %s cooldowns",
		triggercooldowncheckdesc = "Displays a message with the cooldown of each player that knows the spell.  To use in a macro /bw extra spellrequests checkcooldowns check%scooldowns.",

		display_cooldown_format = "%s %s: %d",
		display_available_format = "%s has %s",

		no_players_responded = "No players responded for %s",

		spell_trigger = "You gain %s",

		friendly_death_playername = "(.+) dies",

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

BigWigsSpellRequests = BigWigs:NewModule(name)
BigWigsSpellRequests.synctoken = myname
BigWigsSpellRequests.defaultDB = {
	enabled = true,
	barDuration = 5,
	shownreqbuttons = {},
	showncdbuttons = {},
	showrequestsframe = false,
	showcooldownsframe = false,
	reqframex = 200,
	reqframey = 200,
	cdframex = 300,
	cdframey = 300,
	buttonwidth = 55,
	buttonheight = 22,
	headerHeight = 18,
	buttonPadding = 5,
	ignorelist = {},
	buttonfont = "Fonts\\FRIZQT__.TTF",
	buttonfontsize = 8,
}
-- add spell keys to defaultDB
for spellKey, _ in pairs(Spells) do
	BigWigsSpellRequests.defaultDB[spellKey] = true
end

BigWigsSpellRequests.playerNameToGuidCache = {}
BigWigsSpellRequests.timeoutEvent = "BigWigsSpellRequestsTimeout"
BigWigsSpellRequests.consoleCmd = L["spellrequests"]
BigWigsSpellRequests.revision = 30065
BigWigsSpellRequests.external = true
BigWigsSpellRequests.playerThrottles = {
	[spellRequestCommand] = {},
	[spellReceivedCommand] = {},
	[cooldownRequestCommand] = {},
	[cooldownResponseCommand] = {},
}
BigWigsSpellRequests.receivedRequests = {}
BigWigsSpellRequests.consoleOptions = {
	type = "group",
	name = L["title"],
	desc = L["desc"],
	args = {
		enable = {
			type = "toggle",
			name = L["enable"],
			desc = L["enable"],
			order = 1,
			get = function()
				return BigWigsSpellRequests.db.profile.enabled
			end,
			set = function(v)
				if v == true then
					BigWigsSpellRequests.db.profile.enabled = true
					BigWigsSpellRequests:OnEnable()
				else
					BigWigsSpellRequests.db.profile.enabled = false
					BigWigsSpellRequests:OnDisable()
				end
			end
		},
		fulfillrequest = {
			type = "execute",
			name = L["fulfillrequest"],
			desc = L["fulfillrequest"],
			order = 5,
			func = function()
				-- loop through received requests and fulfill the first one
				for i = BigWigsSpellRequests:GetTableLength(BigWigsSpellRequests.receivedRequests), 1, -1 do
					local request = BigWigsSpellRequests.receivedRequests[i]
					local spellData = Spells[request.spellShortName]
					if spellData.hasSpell then
						-- check cooldown
						local cd = BigWigsSpellRequests:CheckCooldown(spellData.spellSlot)
						if cd == 0 then
							-- check if time within barDuration
							if GetTime() - request.receivedTime < BigWigsSpellRequests.db.profile.barDuration then
								BigWigsSpellRequests:CastSpellOnPlayer(BS[spellData.spellName], request.requestingPlayerName)
								break
							else
								-- remove the request
								table.remove(BigWigsSpellRequests.receivedRequests, i)
							end
						end
					end
				end
			end
		},
		barduration = {
			type = "range",
			name = "Request Bar Duration",
			desc = "Duration of request bars",
			order = 6,
			min = 1,
			max = 30,
			step = 1,
			get = function()
				return BigWigsSpellRequests.db.profile.barDuration
			end,
			set = function(v)
				BigWigsSpellRequests.db.profile.barDuration = v
			end
		},
		allowedrequests = {
			type = "group",
			name = L["allowedrequests"],
			desc = L["allowedrequests"],
			order = 10,
			args = {
				ignorelist = {
					type = "text",
					name = L["ignorelisttitle"],
					desc = L["ignorelistdesc"],
					order = 1,
					usage = "player1, player2, player3",
					get = function()
						-- convert table to comma separated string
						local ignorelist = ""
						for playerName, _ in pairs(BigWigsSpellRequests.db.profile.ignorelist) do
							if ignorelist == "" then
								ignorelist = playerName
							else
								ignorelist = ignorelist .. ", " .. playerName
							end
						end
						return ignorelist
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.ignorelist = {}

						-- convert comma separated string to table
						local playernames = string.split(v, ",")
						for key, val in pairs(playernames) do
							if val and val ~= "" then
								local trimmedName = string.gsub(val, "%s+", "")
								BigWigsSpellRequests.db.profile.ignorelist[trimmedName] = true
							end
						end
					end
				}
			}
		},
		triggerrequests = {
			type = "group",
			name = L["triggerrequests"],
			desc = L["triggerrequests"],
			order = 20,
			args = {
			}
		},
		checkcooldowns = {
			type = "group",
			name = L["checkcooldowns"],
			desc = L["checkcooldowns"],
			order = 30,
			args = {

			}
		},
		requestsuserinterface = {
			type = "group",
			name = L["requestsuserinterface"],
			desc = L["requestsuserinterface"],
			order = 40,
			args = {
				-- show ui frame toggle
				showrequestsframe = {
					type = "toggle",
					name = L["showrequeststitle"],
					desc = L["showrequestsdesc"],
					order = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.showrequestsframe
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.showrequestsframe = v
						BigWigsSpellRequests:UpdateRequestsFrame()
					end
				},
				spacer = {
					type = "header",
					order = 4,
					name = " ",
				},
			}
		},
		cooldownsuserinterface = {
			type = "group",
			name = L["cooldownsuserinterface"],
			desc = L["cooldownsuserinterface"],
			order = 50,
			args = {
				showcooldownsframe = {
					type = "toggle",
					name = L["showcooldownstitle"],
					desc = L["showcooldownsdesc"],
					order = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.showcooldownsframe
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.showcooldownsframe = v
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
				spacer = {
					type = "header",
					order = 4,
					name = " ",
				},
			}
		},
		userinterfaceoptions = {
			type = "group",
			name = L["userinterfaceoptions"],
			desc = L["userinterfaceoptions"],
			order = 60,
			args = {
				resetrequestsframe = {
					type = "execute",
					name = "Reset Requests Frame",
					desc = "Resets the position of the requests frame",
					order = 1,
					func = function()
						BigWigsSpellRequests.db.profile.reqframex = 200
						BigWigsSpellRequests.db.profile.reqframey = 200
						BigWigsSpellRequests:UpdateRequestsFrame()
					end,
				},
				resetcooldownsframe = {
					type = "execute",
					name = "Reset Cooldowns Frame",
					desc = "Resets the position of the cooldowns frame",
					order = 11,
					func = function()
						BigWigsSpellRequests.db.profile.cdframex = 300
						BigWigsSpellRequests.db.profile.cdframey = 300
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end,
				},
				buttonfontsize = {
					type = "range",
					name = "Button Font Size",
					desc = "Font size of the buttons",
					order = 22,
					min = 5,
					max = 15,
					step = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.buttonfontsize
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.buttonfontsize = v
						BigWigsSpellRequests:UpdateRequestsFrame()
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
				buttonwidth = {
					type = "range",
					name = "Button Width",
					desc = "Width of the buttons",
					order = 33,
					min = 15,
					max = 100,
					step = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.buttonwidth
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.buttonwidth = v
						BigWigsSpellRequests:UpdateRequestsFrame()
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
				buttonheight = {
					type = "range",
					name = "Button Height",
					desc = "Height of the buttons",
					order = 44,
					min = 15,
					max = 50,
					step = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.buttonheight
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.buttonheight = v
						BigWigsSpellRequests:UpdateRequestsFrame()
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
				buttonPadding = {
					type = "range",
					name = "Button Padding",
					desc = "Padding between buttons",
					order = 55,
					min = 0,
					max = 10,
					step = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.buttonPadding
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.buttonPadding = v
						BigWigsSpellRequests:UpdateRequestsFrame()
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
				headerHeight = {
					type = "range",
					name = "Header Height",
					desc = "Height of the header",
					order = 66,
					min = 10,
					max = 50,
					step = 1,
					get = function()
						return BigWigsSpellRequests.db.profile.headerHeight
					end,
					set = function(v)
						BigWigsSpellRequests.db.profile.headerHeight = v
						BigWigsSpellRequests:UpdateRequestsFrame()
						BigWigsSpellRequests:UpdateCooldownsFrame()
					end
				},
			},
		},
	}
}

-- add options for each spell
for spellKey, spellData in pairs(Spells) do
	local spellShortName = spellKey -- need to store this for the closure
	local localizedSpellName = BS[spellData.spellName]
	spellData.localizedSpellName = localizedSpellName

	if spellData.allowRequests then
		BigWigsSpellRequests.consoleOptions.args.allowedrequests.args[spellShortName] = {
			type = "toggle",
			name = string.format(L["showrequesttitle"], localizedSpellName),
			desc = string.format(L["showrequestdesc"], localizedSpellName),
			get = function()
				return BigWigsSpellRequests.db.profile[spellShortName]
			end,
			set = function(v)
				BigWigsSpellRequests.db.profile[spellShortName] = v
			end
		}

		BigWigsSpellRequests.consoleOptions.args.triggerrequests.args["request" .. spellShortName] = {
			type = "execute",
			name = string.format(L["triggerrequesttitle"], localizedSpellName),
			desc = string.format(L["triggerrequestdesc"], localizedSpellName, spellShortName),
			func = function()
				BigWigsSpellRequests:SendRequestSpell(spellShortName, UnitName("player"))
			end
		}

		BigWigsSpellRequests.consoleOptions.args.requestsuserinterface.args[spellShortName .. "reqbutton"] = {
			type = "toggle",
			name = string.format(L["showreqbuttontitle"], localizedSpellName),
			desc = string.format(L["showreqbuttontitle"], localizedSpellName),
			order = 10,
			get = function()
				return BigWigsSpellRequests.db.profile.shownreqbuttons[spellShortName]
			end,
			set = function(v)
				if v == true then
					BigWigsSpellRequests.db.profile.shownreqbuttons[spellShortName] = true
				else
					BigWigsSpellRequests.db.profile.shownreqbuttons[spellShortName] = nil
				end
				BigWigsSpellRequests:UpdateRequestsFrame()
			end
		}
	end

	BigWigsSpellRequests.consoleOptions.args.checkcooldowns.args["check" .. spellShortName .. "cooldowns"] = {
		type = "execute",
		name = string.format(L["triggercooldownchecktitle"], localizedSpellName),
		desc = string.format(L["triggercooldowncheckdesc"], spellShortName),
		func = function()
			BigWigsSpellRequests:SendRequestCooldown(spellShortName, UnitName("player"))
		end
	}

	BigWigsSpellRequests.consoleOptions.args.cooldownsuserinterface.args[spellShortName .. "cdbutton"] = {
		type = "toggle",
		name = string.format(L["showcdbuttontitle"], localizedSpellName),
		desc = string.format(L["showcdbuttontitle"], localizedSpellName),
		order = 30,
		get = function()
			return BigWigsSpellRequests.db.profile.showncdbuttons[spellShortName]
		end,
		set = function(v)
			if v == true then
				BigWigsSpellRequests.db.profile.showncdbuttons[spellShortName] = true
			else
				BigWigsSpellRequests.db.profile.showncdbuttons[spellShortName] = nil
			end
			BigWigsSpellRequests:UpdateCooldownsFrame()
		end
	}
end

function BigWigsSpellRequests:HasForbearance()
	local forbearanceTexture = "Interface\\Icons\\Spell_Holy_RemoveCurse"

	-- check if they have forbearance
	for i = 1, 16 do
		local texture = UnitDebuff("player", i)
		if not texture then
			break
		end
		if texture == forbearanceTexture then
			return true
		end
		i = i + 1
	end

	return nil
end

function BigWigsSpellRequests:GetTableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

-- replace bop function
BigWigsSpellRequests.consoleOptions.args.triggerrequests.args["requestbop"].func = function()
	if BigWigsSpellRequests:HasForbearance() then
		BigWigsSpellRequests:Message(L["forbearance"], "Red", false)
	else
		BigWigsSpellRequests:SendRequestSpell("bop", UnitName("player"))
	end
end

function BigWigsSpellRequests:RemoveDeadPlayerRequests(playerName)
	for i = self:GetTableLength(self.receivedRequests), 1, -1 do
		local request = self.receivedRequests[i]
		if request.requestingPlayerName == playerName then
			table.remove(self.receivedRequests, i)

			local spellData = Spells[request.spellShortName]
			local barTitle = self:GetBarTitle(spellData.localizedSpellName, request.requestingPlayerName)
			self:TriggerEvent("BigWigs_StopBar", self, barTitle)
		end
	end
end

function BigWigsSpellRequests:CastSpellOnPlayer(spellName, playerName)
	if hasSuperWow then
		local exists = nil
		local guid = self.playerNameToGuidCache[playerName]
		if not guid then
			for i = 1, GetNumRaidMembers() do
				local r_name = GetRaidRosterInfo(i)
				if r_name == playerName then
					exists, guid = UnitExists("raid" .. i)
					-- cache the guid
					self.playerNameToGuidCache[playerName] = guid

					-- check if dead
					if UnitIsDeadOrGhost(guid) then
						BigWigsSpellRequests:RemoveDeadPlayerRequests(playerName)
						return
					end

					CastSpellByName(spellName, guid)
					break
				end
			end
		end
		if guid then
			CastSpellByName(spellName, guid)
			return
		end
	end

	-- default to targeting playerName and casting
	TargetByName(playerName, true)
	CastSpellByName(spellName)
end

function BigWigsSpellRequests:SendRequestSpell(spellShortName, requestingPlayerName)
	if self.lastSpellRequest and GetTime() - self.lastSpellRequest < 1 then
		return -- throttle
	end
	self.lastSpellRequest = GetTime()

	self:Sync(string.format("%s%s %s;%s", modulePrefix, spellRequestCommand, spellShortName, requestingPlayerName))
end

function BigWigsSpellRequests:SendReceivedSpell(spellShortName, receivingPlayerName)
	self:Sync(string.format("%s%s %s;%s", modulePrefix, spellReceivedCommand, spellShortName, receivingPlayerName))
end

function BigWigsSpellRequests:SendRequestCooldown(spellShortName, requestingPlayerName)
	if self.lastCDRequest and GetTime() - self.lastCDRequest < 1 then
		return -- throttle
	end
	self.lastCDRequest = GetTime()

	self:Sync(string.format("%s%s %s;%s", modulePrefix, cooldownRequestCommand, spellShortName, requestingPlayerName))
	-- start delayed event in case no one responds
	self:ScheduleEvent(BigWigsSpellRequests.timeoutEvent .. spellShortName, function()
		BigWigsSpellRequests:Message(string.format(L["no_players_responded"], spellShortName), "Yellow", false)
	end, 2)
end

function BigWigsSpellRequests:SendCooldownResponse(spellShortName, requestingPlayerName, cooldownPlayerName, cooldown)
	self:Sync(string.format("%s%s %s;%s;%s;%d", modulePrefix, cooldownResponseCommand, spellShortName, requestingPlayerName, cooldownPlayerName, cooldown))
end

function BigWigsSpellRequests:ParseRequestSpell(data)
	local requestingPlayerName = data
	return requestingPlayerName
end

function BigWigsSpellRequests:ParseReceivedSpell(data)
	local requestingPlayerName = data
	return requestingPlayerName
end

function BigWigsSpellRequests:ParseRequestCooldown(data)
	local requestingPlayerName = data
	return requestingPlayerName
end

function BigWigsSpellRequests:ParseCooldownResponse(data)
	local _, _, requestingPlayerName, cooldownPlayerName, cooldown = string.find(data, "(.-);(.-);(%d+)")
	return requestingPlayerName, cooldownPlayerName, cooldown
end

function BigWigsSpellRequests:UpdateRequestsFrame()
	if self.db.profile.showrequestsframe then
		if not self.requestsFrame then
			self.requestsFrame = CreateFrame("Frame", "BigWigsSpellRequestsFrame", UIParent)
			self.requestsFrame.buttons = {}
		end
		local numButtons = 0
		for k, v in pairs(self.db.profile.shownreqbuttons) do
			if Spells[k] then
				numButtons = numButtons + 1
			else
				-- remove invalid spell
				self.db.profile.shownreqbuttons[k] = nil
			end
		end

		if numButtons == 0 then
			self.requestsFrame:Hide()
			return
		end

		self.requestsFrame:SetWidth(self.db.profile.buttonwidth + self.db.profile.buttonPadding * 2)
		self.requestsFrame:SetHeight(self.db.profile.buttonheight * numButtons + self.db.profile.headerHeight + self.db.profile.buttonPadding)

		-- add header text
		if not self.requestsFrame.header then
			self.requestsFrame.header = self.requestsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		end
		self.requestsFrame.header:SetText("Reqs")
		self.requestsFrame.header:SetPoint("TOP", self.requestsFrame, "TOP", 0, -5)
		self.requestsFrame.header:SetJustifyH("CENTER")
		self.requestsFrame.header:Show()

		local scale = self.requestsFrame:GetEffectiveScale()
		self.requestsFrame:ClearAllPoints()
		self.requestsFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
				self.db.profile.reqframex / scale, self.db.profile.reqframey / scale)

		self.requestsFrame:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		self.requestsFrame:SetBackdropColor(0, 0, 0, 1)
		self.requestsFrame:EnableMouse(true)
		self.requestsFrame:SetMovable(true)
		self.requestsFrame:RegisterForDrag("LeftButton")
		self.requestsFrame:SetScript("OnDragStart", function()
			this:StartMoving()
		end)
		self.requestsFrame:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()

			local effScale = this:GetEffectiveScale()
			BigWigsSpellRequests.db.profile.reqframex = this:GetLeft() * effScale
			BigWigsSpellRequests.db.profile.reqframey = this:GetTop() * effScale
		end)
		self.requestsFrame:Show()

		-- remove previous buttons
		for k, v in pairs(self.requestsFrame.buttons) do
			v:Hide()
			self.requestsFrame.buttons[k] = nil
		end

		-- add buttons, left button for requesting, right button for checking cooldowns
		local i = 1
		for k, v in pairs(self.db.profile.shownreqbuttons) do
			local spellShortName = k
			local requestButton = CreateFrame("Button", "BigWigsSpellRequests" .. spellShortName .. "RequestButton", self.requestsFrame, "UIPanelButtonTemplate")
			self.requestsFrame.buttons[k] = requestButton
			requestButton:SetFont(self.db.profile.buttonfont, self.db.profile.buttonfontsize)
			requestButton:SetWidth(self.db.profile.buttonwidth)
			requestButton:SetHeight(self.db.profile.buttonheight)
			requestButton:SetPoint("TOPLEFT", self.requestsFrame, "TOPLEFT", self.db.profile.buttonPadding, (-1 * self.db.profile.headerHeight) - self.db.profile.buttonheight * (i - 1))
			if spellShortName == "fearward" then
				requestButton:SetText("REQ fearwd") -- fearward is too long but don't want to change the spellShortName
			else
				requestButton:SetText("REQ " .. spellShortName)
			end
			requestButton:SetScript("OnClick", function()
				if spellShortName == "bop" and BigWigsSpellRequests:HasForbearance() then
					BigWigsSpellRequests:Message(L["forbearance"], "Red", false)
				else
					BigWigsSpellRequests:SendRequestSpell(spellShortName, UnitName("player"))
				end
			end)
			requestButton:Show()
			i = i + 1
		end

	else
		if self.requestsFrame then
			self.requestsFrame:Hide()
		end
	end
end

function BigWigsSpellRequests:UpdateCooldownsFrame()
	if self.db.profile.showcooldownsframe then
		if not self.cooldownsFrame then
			self.cooldownsFrame = CreateFrame("Frame", "BigWigsSpellRequestsCooldownsFrame", UIParent)
			self.cooldownsFrame.buttons = {}
		end
		local numButtons = 0
		for k, v in pairs(self.db.profile.showncdbuttons) do
			if Spells[k] then
				numButtons = numButtons + 1
			else
				-- remove invalid spell
				self.db.profile.showncdbuttons[k] = nil
			end
		end

		if numButtons == 0 then
			self.cooldownsFrame:Hide()
			return
		end

		-- add header text
		if not self.cooldownsFrame.header then
			self.cooldownsFrame.header = self.cooldownsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		end
		self.cooldownsFrame.header:SetText("CDs")
		self.cooldownsFrame.header:SetPoint("TOP", self.cooldownsFrame, "TOP", 0, -5)
		self.cooldownsFrame.header:SetJustifyH("CENTER")
		self.cooldownsFrame.header:Show()

		self.cooldownsFrame:SetWidth(self.db.profile.buttonwidth + self.db.profile.buttonPadding * 2)
		self.cooldownsFrame:SetHeight(self.db.profile.buttonheight * numButtons + self.db.profile.headerHeight + self.db.profile.buttonPadding)

		local scale = self.cooldownsFrame:GetEffectiveScale()
		self.cooldownsFrame:ClearAllPoints()
		self.cooldownsFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
				self.db.profile.cdframex / scale, self.db.profile.cdframey / scale)

		self.cooldownsFrame:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		self.cooldownsFrame:SetBackdropColor(0, 0, 0, 1)
		self.cooldownsFrame:EnableMouse(true)
		self.cooldownsFrame:SetMovable(true)
		self.cooldownsFrame:RegisterForDrag("LeftButton")
		self.cooldownsFrame:SetScript("OnDragStart",
				function()
					this:StartMoving()
				end)
		self.cooldownsFrame:SetScript("OnDragStop",
				function()
					this:StopMovingOrSizing()

					local effScale = this:GetEffectiveScale()
					BigWigsSpellRequests.db.profile.cdframex = this:GetLeft() * effScale
					BigWigsSpellRequests.db.profile.cdframey = this:GetTop() * effScale
				end)
		self.cooldownsFrame:Show()

		-- remove previous buttons
		for k, v in pairs(self.cooldownsFrame.buttons) do
			v:Hide()
			self.cooldownsFrame.buttons[k] = nil
		end

		-- add buttons, left button for requesting, right button for checking cooldowns
		local i = 1
		for k, v in pairs(self.db.profile.showncdbuttons) do
			local spellShortName = k
			local cooldownButton = CreateFrame("Button", "BigWigsSpellRequests" .. spellShortName .. "CooldownButton", self.cooldownsFrame, "UIPanelButtonTemplate")
			self.cooldownsFrame.buttons[k] = cooldownButton
			cooldownButton:SetFont(self.db.profile.buttonfont, self.db.profile.buttonfontsize)
			cooldownButton:SetWidth(self.db.profile.buttonwidth)
			cooldownButton:SetHeight(self.db.profile.buttonheight)
			cooldownButton:SetPoint("TOPLEFT", self.cooldownsFrame, "TOPLEFT", self.db.profile.buttonPadding, (-1 * self.db.profile.headerHeight) - self.db.profile.buttonheight * (i - 1))
			if spellShortName == "fearward" then
				cooldownButton:SetText("CD fearwd") -- fearward is too long but don't want to change the spellShortName
			else
				cooldownButton:SetText("CD " .. spellShortName)
			end
			cooldownButton:SetScript("OnClick", function()
				BigWigsSpellRequests:SendRequestCooldown(spellShortName, UnitName("player"))
			end)
			cooldownButton:Show()
			i = i + 1
		end
	else
		if self.cooldownsFrame then
			self.cooldownsFrame:Hide()
		end
	end
end

function BigWigsSpellRequests:ScanForSpells()
	for _, spellData in pairs(Spells) do
		spellData.spellSlot = GetSpellSlot(BS[spellData.spellName])
		if spellData.spellSlot then
			spellData.hasSpell = true
		else
			spellData.hasSpell = false
		end
	end
end

function BigWigsSpellRequests:FriendlyDeath(msg)
	local _, _, playerName = string.find(msg, L["friendly_death_playername"])
	if playerName then
		self:RemoveDeadPlayerRequests(playerName)
	end
end

function BigWigsSpellRequests:OnEnable()
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("LEARNED_SPELL_IN_TAB", "ScanForSpells")
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "FriendlyDeath")

	self.playerName = UnitName("player")

	self:ThrottleSync(0.1, modulePrefix .. spellRequestCommand)
	self:ThrottleSync(0.1, modulePrefix .. spellReceivedCommand)
	self:ThrottleSync(0.1, modulePrefix .. cooldownRequestCommand)
	self:ThrottleSync(0, modulePrefix .. cooldownResponseCommand)

	self:ScanForSpells()

	self:UpdateRequestsFrame()
	self:UpdateCooldownsFrame()
end

function BigWigsSpellRequests:OnDisable()
	self:UnregisterAllEvents()
	self:CancelAllScheduledEvents()
	if self.requestsFrame then
		self.requestsFrame:Hide()
	end
	if self.cooldownsFrame then
		self.cooldownsFrame:Hide()
	end
end

function BigWigsSpellRequests:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS(msg)
	for spellShortName, spellData in pairs(Spells) do
		if string.find(msg, string.format(L["spell_trigger"], spellData.localizedSpellName)) then
			-- player has received the spell, send a sync
			BigWigsSpellRequests:SendReceivedSpell(spellShortName, self.playerName)
		end
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

function BigWigsSpellRequests:CleanupOldRequests()
	local currentTime = GetTime()
	for i = self:GetTableLength(self.receivedRequests), 1, -1 do
		local request = self.receivedRequests[i]
		if currentTime - request.receivedTime > self.db.profile.barDuration then
			table.remove(self.receivedRequests, i)
		end
	end
end

function BigWigsSpellRequests:GetBarTitle(spellName, playerName)
	return playerName .. " wants " .. spellName .. " CLICK HERE"
end

function BigWigsSpellRequests:BigWigs_RecvSync(sync, data)
	local _, _, command = string.find(sync, syncFormat)
	if not command then
		-- ignore events not from this module or without a command
		return
	end

	local _, _, spellShortName, spellArgs = string.find(data, dataFormat)

	local spellData = Spells[spellShortName]
	if not spellData then
		-- ignore events for spells we don't know about
		return
	end

	if self.db.profile[spellShortName] == false then
		-- ignore requests for spells we don't want to see
		return
	end

	-- if this is a request check if we have the spell and haven't disabled requests for it
	if command == spellRequestCommand and spellData.hasSpell then
		local requestingPlayerName = self:ParseRequestSpell(spellArgs)
		-- check ignore list
		if self.db.profile.ignorelist and self.db.profile.ignorelist[requestingPlayerName] then
			return
		end

		-- check cooldown
		local cd = self:CheckCooldown(spellData.spellSlot)
		self:SendCooldownResponse(spellShortName, requestingPlayerName, self.playerName, cd)

		-- don't show the bar if we have the spell and it's on cooldown
		if cd > 0 then
			return
		end

		-- show candybar saying that playername wants spellname
		local barTitle = self:GetBarTitle(spellData.localizedSpellName, requestingPlayerName)

		-- save request
		table.insert(self.receivedRequests, {
			spellShortName = spellShortName,
			requestingPlayerName = requestingPlayerName,
			receivedTime = GetTime(),
		})

		-- trigger event to cleanup old requests
		self:ScheduleEvent("BigWigsSpellRequestsCleanup", self.CleanupOldRequests, self.db.profile.barDuration + 1, self)

		self:TriggerEvent("BigWigs_StartBar", self, barTitle, self.db.profile.barDuration, "Interface\\Icons\\" .. spellData.spellIcon, true, "white")
		if spellData.targetRequester then
			-- enable clicking on the bar to cast on that player
			self:SetCandyBarOnClick("BigWigsBar " .. barTitle, function(_, _, pName, sName)
				BigWigsSpellRequests:CastSpellOnPlayer(sName, pName)
			end, requestingPlayerName, spellData.localizedSpellName)
		end
		-- if this is a cooldown request
	elseif command == cooldownRequestCommand and spellData.hasSpell then
		local requestingPlayerName = self:ParseRequestCooldown(spellArgs)
		-- check ignore list
		if self.db.profile.ignorelist and self.db.profile.ignorelist[requestingPlayerName] then
			return
		end

		local cd = self:CheckCooldown(spellData.spellSlot)
		self:SendCooldownResponse(spellShortName, requestingPlayerName, self.playerName, cd)
	elseif command == spellReceivedCommand and spellData.hasSpell then
		local playerName = self:ParseReceivedSpell(spellArgs)
		-- player has received the spell, hide the bar if visible
		local barTitle = self:GetBarTitle(spellData.localizedSpellName, playerName)
		self:TriggerEvent("BigWigs_StopBar", self, barTitle)
		-- remove from received requests
		for i = self:GetTableLength(self.receivedRequests), 1, -1 do
			local request = self.receivedRequests[i]
			if request.spellShortName == spellShortName and request.requestingPlayerName == playerName then
				table.remove(self.receivedRequests, i)
				break
			end
		end
	elseif command == cooldownResponseCommand then
		local requestingPlayerName, cooldownPlayerName, cooldown = self:ParseCooldownResponse(spellArgs)
		if requestingPlayerName == self.playerName then
			-- cancel timeout event
			self:CancelScheduledEvent(BigWigsSpellRequests.timeoutEvent .. spellShortName)
			-- check cooldownPlayerName throttle
			local lastMsg = self.playerThrottles[cooldownResponseCommand][cooldownPlayerName]
			if lastMsg and GetTime() - lastMsg < 1 then
				return -- throttle
			end
			self.playerThrottles[cooldownResponseCommand][cooldownPlayerName] = GetTime()

			-- show the cooldown of the player that knows the spell
			if cooldown == "0" then
				self:Message(string.format(L["display_available_format"], cooldownPlayerName, spellShortName), "Green", false)
			else
				self:Message(string.format(L["display_cooldown_format"], cooldownPlayerName, spellShortName, cooldown), "Red", false)
			end
		end
	end
end
