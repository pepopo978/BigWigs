local module, L = BigWigs:ModuleDeclaration("Anomalus", "Karazhan")

-- module variables
module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = { "arcaneoverload", "arcaneprison", "manaboundstrike", "manaboundframe", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}

-- module defaults
module.defaultDB = {
	arcaneoverload = true,
	arcaneprison = true,
	manaboundstrike = true,
	manaboundframe = true,
	manaboundframeposx = 100,
	manaboundframeposy = 300,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "Anomalus",

		arcaneoverload_cmd = "arcaneoverload",
		arcaneoverload_name = "Arcane Overload Alert",
		arcaneoverload_desc = "Warns when players get affected by Arcane Overload",

		arcaneprison_cmd = "arcaneprison",
		arcaneprison_name = "Arcane Prison Alert",
		arcaneprison_desc = "Warns when players get affected by Arcane Prison",

		manaboundstrike_cmd = "manaboundstrike",
		manaboundstrike_name = "Manabound Strike Alert",
		manaboundstrike_desc = "Warns when players get affected by Manabound Strike stacks",

		manaboundframe_cmd = "manaboundframe",
		manaboundframe_name = "Manabound Strikes Frame",
		manaboundframe_desc = "Shows a frame with player stacks and timers for Manabound Strikes",

		trigger_arcaneOverloadYou = "You are afflicted by Arcane Overload",
		trigger_arcaneOverloadOther = "(.+) is afflicted by Arcane Overload",
		msg_arcaneOverloadYou = "BOMB ON YOU - MOVE AWAY!",
		msg_arcaneOverloadOther = "BOMB on %s!",
		bar_arcaneOverload = "Next Bomb",
		bar_arcaneOverloadExplosion = "BOMB ON YOU Explosion",

		trigger_arcanePrison = "(.+) is afflicted by Arcane Prison",
		msg_arcanePrison = "Arcane Prison on %s!",

		trigger_manaboundStrike = "(.+) is afflicted by Manabound Strikes %((%d+)%)",
		trigger_manaboundFade = "Manabound Strikes fades from (.+)",

		bar_manaboundExpire = "Manabound stacks expire",
	}
end)

-- timer and icon variables
local timer = {
	firstArcaneOverload = 7,
	manaboundDuration = 60,
	arcaneOverloadExplosion = 15,
}

local icon = {
	arcaneOverload = "INV_Misc_Bomb_04",
	arcanePrison = "Spell_Frost_Glacier",
	manaboundStrike = "Spell_Arcane_FocusedPower",
	manaboundExpire = "Spell_Holy_FlashHeal",
}

local syncName = {
	arcaneOverload = "AnomalusArcaneOverload" .. module.revision,
	arcanePrison = "AnomalusArcanePrison" .. module.revision,
	manaboundStrike = "AnomalusManaboundStrike" .. module.revision,
	manaboundStrikeFade = "AnomalusManaboundStrikeFade" .. module.revision,
}

local maxManaboundPlayers = 10
local arcaneOverloadCount = 0
local manaboundStrikesPlayers = {}

-- arcane overload timing
local arcaneOverloadTimers = {
	7, 15, 14, 13, 12, 11, 10, 9, 8, 7
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

	self:ThrottleSync(3, syncName.arcaneOverload)
	self:ThrottleSync(3, syncName.arcanePrison)
	self:ThrottleSync(3, syncName.manaboundStrike)
	self:ThrottleSync(3, syncName.manaboundStrikeFade)

	self:UpdateManaboundStatusFrame()
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	arcaneOverloadCount = 0
	manaboundStrikesPlayers = {}

	if self.db.profile.arcaneoverload then
		self:Bar(L["bar_arcaneOverload"], arcaneOverloadTimers[1], icon.arcaneOverload)
	end

	if self.db.profile.manaboundframe then
		self:ScheduleRepeatingEvent("UpdateManaboundStatusFrame", self.UpdateManaboundStatusFrame, 1, self)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("UpdateManaboundStatusFrame")

	if self.manaboundStatusFrame then
		self.manaboundStatusFrame:Hide()
	end
end

function module:AfflictionEvent(msg)
	-- Arcane Overload
	if string.find(msg, L["trigger_arcaneOverloadYou"]) then
		self:Sync(syncName.arcaneOverload .. " " .. UnitName("player"))
	else
		local _, _, player = string.find(msg, L["trigger_arcaneOverloadOther"])
		if player then
			self:Sync(syncName.arcaneOverload .. " " .. player)
		end
	end

	-- Arcane Prison
	local _, _, player = string.find(msg, L["trigger_arcanePrison"])
	if player then
		self:Sync(syncName.arcanePrison .. " " .. player)
	end

	-- Manabound Strikes
	local _, _, player, count = string.find(msg, L["trigger_manaboundStrike"])
	if player and count then
		self:Sync(syncName.manaboundStrike .. " " .. player .. " " .. count)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end

	-- remove bar
	self:RemoveBar(L["bar_manaboundExpire"])
end

function module:CHAT_MSG_SPELL_AURA_GONE_PARTY(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	local _, _, player = string.find(msg, L["trigger_manaboundFade"])
	if player then
		self:Sync(syncName.manaboundStrikeFade .. " " .. player)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.arcaneOverload and rest then
		self:ArcaneOverload(rest)
	elseif sync == syncName.arcanePrison and rest then
		self:ArcanePrison(rest)
	elseif string.find(sync, syncName.manaboundStrike) and rest then
		local _, _, player, count = string.find(rest, "([^%s]+) (%d+)")
		if player and count then
			self:ManaboundStrike(player, count)
		end
	elseif sync == syncName.manaboundStrikeFade and rest then
		self:ManaboundStrikeFade(rest)
	end
end

function module:ArcaneOverload(player)
	arcaneOverloadCount = arcaneOverloadCount + 1

	-- Calculate next timer (minimum 7 seconds)
	local nextTimer = arcaneOverloadTimers[arcaneOverloadCount + 1] or 7

	if self.db.profile.arcaneoverload then
		if player == UnitName("player") then
			self:Message(L["msg_arcaneOverloadYou"], "Important", true, "Alarm")
			self:WarningSign(icon.arcaneOverload, 5, true, "BOMB ON YOU")
			-- Add personal explosion bar with red color
			self:Bar(L["bar_arcaneOverloadExplosion"], timer.arcaneOverloadExplosion, icon.arcaneOverload, true, "red")
		else
			self:Message(string.format(L["msg_arcaneOverloadOther"], player), "Important")

			if IsRaidLeader() or IsRaidOfficer() then
				for i = 1, GetNumRaidMembers() do
					if UnitName("raid" .. i) == player then
						SetRaidTarget("raid" .. i, 8)
					end
				end
			end
		end

		self:RemoveBar(L["bar_arcaneOverload"])
		self:Bar(L["bar_arcaneOverload"], nextTimer, icon.arcaneOverload)
	end
end

function module:ArcanePrison(player)
	if self.db.profile.arcaneprison then
		self:Message(string.format(L["msg_arcanePrison"], player), "Attention")
	end
end

function module:ManaboundStrike(player, count)
	if tonumber(count) then
		-- Update or add player to tracking table
		manaboundStrikesPlayers[player] = {
			count = tonumber(count),
			expires = GetTime() + timer.manaboundDuration
		}

		-- Only show bar for the player's own debuff
		if player == UnitName("player") and self.db.profile.manaboundstrike then
			self:RemoveBar(L["bar_manaboundExpire"])
			self:Bar(L["bar_manaboundExpire"], timer.manaboundDuration, icon.manaboundExpire)
		end

		self:UpdateManaboundStatusFrame()
	end
end

function module:ManaboundStrikeFade(player)
	-- Remove player from tracking table
	if manaboundStrikesPlayers[player] then
		manaboundStrikesPlayers[player] = nil

		-- Only remove the player's own bar
		if player == UnitName("player") then
			self:RemoveBar(L["bar_manaboundExpire"])
		end

		self:UpdateManaboundStatusFrame()
	end
end

function module:UpdateManaboundStatusFrame()
	if not self.db.profile.manaboundframe then
		if self.manaboundStatusFrame then
			self.manaboundStatusFrame:Hide()
		end
		return
	end

	-- Create frame if needed
	if not self.manaboundStatusFrame then
		self.manaboundStatusFrame = CreateFrame("Frame", "AnomalusManaboundFrame", UIParent)
		self.manaboundStatusFrame.module = self
		self.manaboundStatusFrame:SetWidth(200)
		self.manaboundStatusFrame:SetHeight(120)
		self.manaboundStatusFrame:ClearAllPoints()
		local s = self.manaboundStatusFrame:GetEffectiveScale()
		self.manaboundStatusFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
				(self.db.profile.manaboundframeposx or 100) / s,
				(self.db.profile.manaboundframeposy or 300) / s)
		self.manaboundStatusFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})
		self.manaboundStatusFrame:SetBackdropColor(0, 0, 0, 1)

		-- Allow dragging
		self.manaboundStatusFrame:SetMovable(true)
		self.manaboundStatusFrame:EnableMouse(true)
		self.manaboundStatusFrame:RegisterForDrag("LeftButton")
		self.manaboundStatusFrame:SetScript("OnDragStart", function()
			this:StartMoving()
		end)
		self.manaboundStatusFrame:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()
			local scale = this:GetEffectiveScale()
			this.module.db.profile.manaboundframeposx = this:GetLeft() * scale
			this.module.db.profile.manaboundframeposy = this:GetTop() * scale
		end)

		-- Header - Column labels
		self.manaboundStatusFrame.header = self.manaboundStatusFrame:CreateFontString(nil, "ARTWORK")
		self.manaboundStatusFrame.header:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
		self.manaboundStatusFrame.header:SetPoint("TOPLEFT", self.manaboundStatusFrame, "TOPLEFT", 10, -10)
		self.manaboundStatusFrame.header:SetText("Timer | Player name | Stack count")

		-- Create player lines (will be populated dynamically)
		self.manaboundStatusFrame.lines = {}
		for i = 1, maxManaboundPlayers do
			-- Support up to maxManaboundPlayers players
			local line = {}

			-- Timer column
			line.timer = self.manaboundStatusFrame:CreateFontString(nil, "ARTWORK")
			line.timer:SetFont("Fonts\\FRIZQT__.TTF", 9)
			line.timer:SetPoint("TOPLEFT", self.manaboundStatusFrame, "TOPLEFT", 10, -10 - (i * 15))
			line.timer:SetWidth(40)
			line.timer:SetJustifyH("LEFT")

			-- Player name column
			line.player = self.manaboundStatusFrame:CreateFontString(nil, "ARTWORK")
			line.player:SetFont("Fonts\\FRIZQT__.TTF", 9)
			line.player:SetPoint("LEFT", line.timer, "RIGHT", 10, 0)
			line.player:SetWidth(80)
			line.player:SetJustifyH("LEFT")

			-- Stack count column
			line.stacks = self.manaboundStatusFrame:CreateFontString(nil, "ARTWORK")
			line.stacks:SetFont("Fonts\\FRIZQT__.TTF", 9)
			line.stacks:SetPoint("LEFT", line.player, "RIGHT", 10, 0)
			line.stacks:SetWidth(30)
			line.stacks:SetJustifyH("CENTER")

			self.manaboundStatusFrame.lines[i] = line
		end
	end

	self.manaboundStatusFrame:Show()

	-- Update player data in the frame
	local lineIndex = 1
	local now = GetTime()

	for player, data in pairs(manaboundStrikesPlayers) do
		if lineIndex <= maxManaboundPlayers then
			-- Max maxManaboundPlayers players shown
			local line = self.manaboundStatusFrame.lines[lineIndex]

			local timeLeft = math.max(0, data.expires - now)

			-- Set the columns in the new format
			line.timer:SetText(string.format("%.0f", timeLeft))
			line.player:SetText(player)
			line.stacks:SetText(data.count)

			-- Color based on stack count
			if data.count >= 8 then
				line.stacks:SetTextColor(1, 0, 0) -- Red for high stacks
			elseif data.count >= 5 then
				line.stacks:SetTextColor(1, 0.5, 0) -- Orange for medium stacks
			else
				line.stacks:SetTextColor(1, 1, 1) -- White for low stacks
			end

			-- Color timer based on time remaining
			if timeLeft < 5 then
				line.timer:SetTextColor(0, 1, 0) -- Green for about to expire
			else
				line.timer:SetTextColor(1, 1, 1) -- White for normal
			end

			lineIndex = lineIndex + 1
		end
	end

	-- Hide unused lines
	for i = lineIndex, maxManaboundPlayers do
		local line = self.manaboundStatusFrame.lines[i]
		if line then
			line.timer:SetText("")
			line.player:SetText("")
			line.stacks:SetText("")
		end
	end

	-- Adjust frame height based on number of visible entries
	local numEntries = 0
	for _ in pairs(manaboundStrikesPlayers) do
		numEntries = numEntries + 1
	end

	local newHeight = math.max(40, 25 + (numEntries * 17))
	self.manaboundStatusFrame:SetHeight(newHeight)
end

function module:Test()
	-- Initialize module state
	self:OnSetup()
	self:OnEngage()

	local events = {
		-- Arcane Overload events
		{ time = 5, func = function()
			print("Test: Player gets Arcane Overload")
			module:AfflictionEvent("Player1 is afflicted by Arcane Overload")
		end },
		{ time = 15, func = function()
			print("Test: You get Arcane Overload")
			module:AfflictionEvent("You are afflicted by Arcane Overload")
		end },

		-- Arcane Prison event
		{ time = 10, func = function()
			print("Test: Player gets Arcane Prison")
			module:AfflictionEvent("Player3 is afflicted by Arcane Prison")
		end },

		-- Manabound Strikes events
		{ time = 3, func = function()
			print("Test: Player1 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 8, func = function()
			print("Test: Player2 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 13, func = function()
			print("Test: Player1 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 18, func = function()
			print("Test: Player3 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 20, func = function()
			print("Test: Player2 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 25, func = function()
			print("Test: Player3 gets Manabound Strikes (2)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (2)")
		end },
		{ time = 30, func = function()
			print("Test: Player1 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 35, func = function()
			print("Test: Player2 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player2 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 40, func = function()
			print("Test: Player3 gets Manabound Strikes (3)")
			module:AfflictionEvent("Player3 is afflicted by Manabound Strikes (3)")
		end },
		{ time = 45, func = function()
			print("Test: Player4 gets Manabound Strikes (1)")
			module:AfflictionEvent("Player4 is afflicted by Manabound Strikes (1)")
		end },
		{ time = 50, func = function()
			print("Test: Player1 gets Manabound Strikes (4)")
			module:AfflictionEvent("Player1 is afflicted by Manabound Strikes (4)")
		end },
		{ time = 53, func = function()
			print("Test: You get Manabound Strikes (7)")
			local playerName = UnitName("player")
			module:AfflictionEvent(playerName .. " is afflicted by Manabound Strikes (7)")
		end },
		{ time = 70, func = function()
			print("Test: Manabound Strikes fades from Player2")
			module:CHAT_MSG_SPELL_AURA_GONE_PARTY("Manabound Strikes fades from Player2")
		end },
		{ time = 75, func = function()
			print("Test: Manabound Strikes fades from Pepopo")
			module:CHAT_MSG_SPELL_AURA_GONE_PARTY("Manabound Strikes fades from Pepopo")
		end },
		{ time = 80, func = function()
			print("Test: Disengage")
			module:OnDisengage()
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("AnomalusTest" .. i, event.func, event.time)
	end

	self:Message("Anomalus test started", "Positive")
	return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("Anomalus"); BigWigs:SetupModule("Anomalus");m:Test();
