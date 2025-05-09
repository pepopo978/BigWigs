local module, L = BigWigs:ModuleDeclaration("King", "Karazhan")

-- module variables
module.revision = 30003
module.enabletrigger = module.translatedName
module.toggleoptions = { "subservience", "kingsfury", "charmingpresence", "decursebow", "marksubservience", "markmindcontrol", "throttlebow", "bishoptonguesalert", "voidzone", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}
module.wipemobs = { "Knight", "Bishop", "Rook" }

local _, playerClass = UnitClass("player")

-- module defaults
module.defaultDB = {
	subservience = true,
	kingsfury = true,
	charmingpresence = playerClass == "SHAMAN",
	decursebow = playerClass == "MAGE" or playerClass == "DRUID",
	marksubservience = true,
	markmindcontrol = true,
	throttlebow = true,
	bishoptonguesalert = true,
    voidzone = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "ChessEvent",

		subservience_cmd = "subservience",
		subservience_name = "Dark Subservience Alert",
		subservience_desc = "Warns when you are afflicted by Dark Subservience",

		kingsfury_cmd = "kingsfury",
		kingsfury_name = "King's Fury Alert",
		kingsfury_desc = "Warns when the King begins to cast King's Fury",

		charmingpresence_cmd = "charmingpresence",
		charmingpresence_name = "Charming Presence Timer",
		charmingpresence_desc = "Shows a timer for when the Queen will cast Charming Presence",

		decursebow_cmd = "decursebow",
		decursebow_name = "Decurse Reminder for Bowing Players",
		decursebow_desc = "Shows a notification with decurse button for players who need to bow",

		marksubservience_cmd = "marksubservience",
		marksubservience_name = "Mark Subservience Target",
		marksubservience_desc = "Marks players affected by Dark Subservience with Skull raid icon (requires assistant or leader)",

		throttlebow_cmd = "throttlebow",
		throttlebow_name = "Throttle /bow",
		throttlebow_desc = "Throttle the Visual Display of other people's /bow",

		markmindcontrol_cmd = "markmindcontrol",
		markmindcontrol_name = "Mark Mind Controlled Target",
		markmindcontrol_desc = "Marks players affected by King's Curse with X raid icon (requires assistant or leader)",

		bishoptonguesalert_cmd = "bishoptonguesalert",
		bishoptonguesalert_name = "Bishop Curse of Tongues Alert",
		bishoptonguesalert_desc = "Alerts when the Bishop needs Curse of Tongues applied",

        voidzone_cmd = "voidzone",
        voidzone_name = "Void Zone Alert",
        voidzone_desc = "Warns when King casts Blunder (Void Zone)",
        trigger_voidzone = "King casts Blunder.",
        msg_voidzone = "Void Zone MOVE!",

		trigger_subservienceYou = "You are afflicted by Dark Subservience",
		trigger_subservienceOther = "(.+) is afflicted by Dark Subservience",
		trigger_subservienceFade = "Dark Subservience fades from (.+)",
		trigger_subservienceFailed = "Dark Subservience fails. Grounding Totem",

		trigger_kingscurseYou = "You are afflicted by King's Curse",
		trigger_kingscurseOther = "(.+) is afflicted by King's Curse",
		trigger_kingscurseFade = "King's Curse fades from (.+)",

		trigger_charmingPresenceYou = "You are afflicted by Charming Presence",
		trigger_charmingPresenceOther = "(.+) is afflicted by Charming Presence",
		trigger_charmingPresenceFade = "Charming Presence fades from (.+)",

		trigger_kingCastFury = "King begins to cast King(.+)Fury", -- they used special character apostrophe for this and queen's Fury

		msg_subservienceYou = "YOU need to go Bow to the Queen!",
		msg_subservienceOther = "%s needs to go Bow!",
		msg_queenCastingSubservience = "Queen began casting on %s!",
		msg_queenSubservienceTotem = "Totem ate cast instead of %s!",
		msg_kingCastFury = "King begins to cast King's Fury!",

		warning_bow = "BOW TO THE QUEEN!",

		bar_subservience = "Go right in front of Queen and Bow! >Click Me<",
		bar_kingsfury = "King's Fury - Hide!",
		bar_charmingpresence = "Next Charming Presence",
		bar_decursebow = "Decurse %s >Click Me<",

		bishop_name = "Bishop",
	}
end)

-- timer and icon variables
local timer = {
	subservience = 8, -- duration of subservience debuff
	kingsfury = 5, -- duration of king's fury cast
	charmingpresence = 12, -- queen casts every 12 seconds
	throttlebow = 1.5, -- bow throttle rate
	bishopScan = 5, -- check bishop debuffs every 5 seconds
    voidzone = 2, -- duration for void zone warning sign
}

local icon = {
	subservience = "Spell_BrokenHeart", -- icon for subservience
	kingsfury = "Spell_Holy_HolyNova", -- icon for king's fury
	charmingpresence = "Spell_Shadow_ShadowWordDominate", -- icon for charming presence
	kingscurse = "Spell_Shadow_GrimWard", -- icon for King's curse
    voidzone = "spell_shadow_antishadow", -- icon for void zone
}

local kingsCurseTexture = "Interface\\Icons\\Spell_Shadow_GrimWard"

local syncName = {
	subservience = "ChessSubservience" .. module.revision,
	queenCastingSubservience = "ChessQueenCastingSubservience" .. module.revision,
	kingCastFury = "ChessKingCastFury" .. module.revision,
	subservienceFailed = "ChessSubservienceFailed" .. module.revision,
	charmingPresence = "ChessCharmingPresence" .. module.revision,
	bishopNoCurse = "ChessBishopNoCurse" .. module.revision,
}

local spellIds = {
	subservience = 41647, -- Dark Subservience
	charmingpresence = 41644,
	kingscurse = 41635,
}

-- Track players afflicted with King's Curse
local bowed = {}

local baseChatFrameOnEvent = ChatFrame_OnEvent

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "FadesEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FadesEvent")

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "CastEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CastEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "CastEvent")

	if self.db.profile.bishoptonguesalert then
		self:ScheduleRepeatingEvent("BishopDebuffScan", self.ScanBishopDebuffs, timer.bishopScan, self)
	end

	-- install wrapper exactly once
	if not self.origChatFrameOnEvent and self.db.profile.throttlebow then
		self.origChatFrameOnEvent = ChatFrame_OnEvent

		ChatFrame_OnEvent = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
			local msg, who = arg1, arg2

			if not self.origChatFrameOnEvent then
                -- something went wrong, just call the original function
                baseChatFrameOnEvent(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
                ChatFrame_OnEvent = baseChatFrameOnEvent
                return
            end

			-- only throttle OTHER players’ /bow emote when we’re engaged
			if self.engaged and event == "CHAT_MSG_TEXT_EMOTE" and who ~= UnitName("player") and string.find(msg, "^.- bow") then
				local now = GetTime()
				if not bowed[who] or now - bowed[who] >= timer.throttlebow then
					bowed[who] = now
					self.origChatFrameOnEvent(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
				end
			else
				-- everything else goes through as normal
				self.origChatFrameOnEvent(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
			end
		end
	end

	if SUPERWOW_VERSION then
		self:RegisterCastEventsForUnitName("Queen", "QueenCastEvent")
	end

	self:ThrottleSync(1, syncName.subservience)
	self:ThrottleSync(2, syncName.queenCastingSubservience)
	self:ThrottleSync(2, syncName.kingCastFury)
	self:ThrottleSync(2, syncName.subservienceFailed)
	self:ThrottleSync(2, syncName.charmingPresence)
end

function module:OnSetup()
	self.started = nil
end

function module:OnDisable()
	if self.origChatFrameOnEvent and self.db.profile.throttlebow then
		-- remove the wrapper
		ChatFrame_OnEvent = self.origChatFrameOnEvent
		self.origChatFrameOnEvent = nil
	end
end

function module:OnEngage()
	bowed = {}

	self.queenTarget = ""
end

function module:OnDisengage()
	self:CancelScheduledEvent("BishopDebuffScan")
end

function module:QueenCastEvent(casterGuid, targetGuid, eventType, spellId, castTime)
	if spellId == spellIds.subservience and eventType == "START" then
		self.queenTarget = UnitName(targetGuid) or ""
		self:Sync(syncName.queenCastingSubservience .. " " .. self.queenTarget)
	elseif spellId == spellIds.charmingpresence and eventType == "CAST" then
		self:Sync(syncName.charmingPresence)
	end
end

function module:CastEvent(msg)
	if self.db.profile.subservience and string.find(msg, L["trigger_subservienceFailed"]) and self.queenTarget ~= "" then
		self:Sync(syncName.subservienceFailed .. " " .. self.queenTarget)
	elseif string.find(msg, L["trigger_kingCastFury"]) then
		self:Sync(syncName.kingCastFury)
	end
end

function module:AfflictionEvent(msg)
	-- Dark Subservience
	if string.find(msg, L["trigger_subservienceYou"]) then
		self:Sync(syncName.subservience .. " " .. UnitName("player"))
		return
	else
		local _, _, player = string.find(msg, L["trigger_subservienceOther"])
		if player then
			self:Sync(syncName.subservience .. " " .. player)
			return
		end
	end

	-- Charming Presence
	local _, _, player = string.find(msg, L["trigger_charmingPresenceOther"])
	if player and self.db.profile.markmindcontrol then
		-- Mark the player with X raid target
		self:SetRaidTargetForPlayer(player, 7) -- X
		return
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["trigger_subservienceFade"]) then
		self:RemoveBar(L["bar_subservience"])

		if self.db.profile.marksubservience then
			self:RestorePreviousRaidTargetForPlayer(UnitName("player"))
		end
	elseif string.find(msg, L["trigger_kingscurseFade"]) then
		local player = UnitName("player")
		self:RemoveBar(string.format(L["bar_decursebow"], player))
	end
end

function module:FadesEvent(msg)
	local _, _, player = string.find(msg, L["trigger_kingscurseFade"])
	if player then
		self:RemoveBar(string.format(L["bar_decursebow"], player))
		return
	end

	_, _, player = string.find(msg, L["trigger_subservienceFade"])
	if player then
		if self.db.profile.marksubservience then
			self:RestorePreviousRaidTargetForPlayer(player)
		end
		self:RemoveBar(string.format(L["bar_decursebow"], player))
		return
	end

	_, _, player = string.find(msg, L["trigger_charmingPresenceFade"])
	if player then
		if self.db.profile.markmindcontrol then
			self:RestorePreviousRaidTargetForPlayer(player)
		end
		return
	end
end

function module:OnFriendlyDeath(msg)
	local _, _, player = string.find(msg, "(.+) dies")
	if player then
		-- Remove raid marks for players who die
		if self.db.profile.marksubservience or self.db.profile.markmindcontrol then
			self:RestorePreviousRaidTargetForPlayer(player)
		end

		self:RemoveBar(string.format(L["bar_decursebow"], player))
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.subservience and rest then
		self:Subservience(rest)
	elseif sync == syncName.queenCastingSubservience then
		self:QueenCastingSubservience(rest)
	elseif sync == syncName.kingCastFury then
		self:KingCastFury()
	elseif sync == syncName.subservienceFailed and rest then
		self:SubservienceFailed(rest)
	elseif sync == syncName.charmingPresence then
		if self.db.profile.charmingpresence then
			self:StartCharmingPresenceTimer()
		end
	elseif sync == syncName.bishopNoCurse then
		self:BishopNeedsCurseOfTongues()
	end
end

function module:StartCharmingPresenceTimer()
	if not self.db.profile.charmingpresence then
		return
	end

	self:Bar(L["bar_charmingpresence"], timer.charmingpresence, icon.charmingpresence)
end

function module:QueenCastingSubservience(playerName)
	if not self.db.profile.subservience then
		return
	end
	self.queenTarget = playerName

	self:Message(string.format(L["msg_queenCastingSubservience"], playerName), "Attention", nil, "Info")
end

function module:SubservienceFailed(playerName)
	if not self.db.profile.subservience then
		return
	end

	self:Message(string.format(L["msg_queenSubservienceTotem"], playerName), "Positive")
end

function module:Subservience(player)
	if not self.db.profile.subservience then
		return
	end

	if player == UnitName("player") then
		self:Message(L["msg_subservienceYou"], "Important")
		self:WarningSign(icon.subservience, timer.subservience, true, L["warning_bow"])
		self:Bar(L["bar_subservience"], timer.subservience, icon.subservience)

		-- Set the bar to target Queen and bow when clicked
		self:SetCandyBarOnClick("BigWigsBar " .. L["bar_subservience"], function()
			TargetByName("Queen", true)
			DoEmote("bow")
		end)

		self:Sound("GoBow")
	else
		self:Message(string.format(L["msg_subservienceOther"], player), "Important")

		-- Check for King's Curse directly if decursebow is enabled
		if self.db.profile.decursebow then
			-- Find the player in raid
			local raidTarget = nil
			for i = 1, 40 do
				if UnitExists("raid" .. i) and UnitName("raid" .. i) == player then
					raidTarget = "raid" .. i
					break
				end
			end

			-- If found, check for King's Curse debuff
			if raidTarget then
				for i = 1, 16 do
					local texture = UnitDebuff(raidTarget, i)
					if texture then
						if texture == kingsCurseTexture then
							-- Player has King's Curse, show decurse reminder
							self:DecurseReminder(player, raidTarget)
							break
						end
					else
						break
					end
				end
			end
		end
	end

	if self.db.profile.marksubservience then
		self:SetRaidTargetForPlayer(player, 8) -- Skull
	end
end

function module:DecurseReminder(player, raidTarget)
	if not self.db.profile.decursebow then
		return
	end

	-- Create a bar with decurse functionality
	local barText = string.format(L["bar_decursebow"], player)
	self:Bar(barText, timer.subservience, icon.kingscurse)

	-- Set the bar to target player and cast Remove Curse when clicked
	self:SetCandyBarOnClick("BigWigsBar " .. barText, function(name, button, playerName, target)
		if SUPERWOW_VERSION or SetAutoloot then
			if playerClass == "MAGE" then
				CastSpellByName("Remove Lesser Curse", target)
			elseif playerClass == "DRUID" then
				CastSpellByName("Remove Curse", target)
			end
		else
			TargetByName(playerName, true)
			if playerClass == "MAGE" then
				CastSpellByName("Remove Lesser Curse")
			elseif playerClass == "DRUID" then
				CastSpellByName("Remove Curse")
			end
		end
	end, player, raidTarget)
end

function module:KingCastFury()
	if not self.db.profile.kingsfury then
		return
	end
	self:Message(L["msg_kingCastFury"], "Attention", nil, "Info")
	self:Bar(L["bar_kingsfury"], timer.kingsfury, icon.kingsfury)
end

function module:VoidZoneAlert()
    if not self.db.profile.voidzone then
        return
    end

    self:WarningSign(icon.voidzone, timer.voidzone, true, L["msg_voidzone"])
    self:TriggerEvent("BigWigs_Sound", "VoidZoneMove")
    SendChatMessage("Void Zone On Me!", "SAY")
end

function module:ScanBishopDebuffs()
	-- Check if current target is Bishop
	if UnitName("target") == L["bishop_name"] then
		-- Scan debuffs
		for i = 1, 16 do
			local texture = UnitDebuff("target", i)
			if texture and string.find(texture, "Spell_Shadow_CurseOfTounges") then
				-- Found Curse of Tongues debuff
				return
			elseif not texture then
				break
			end
		end

		-- Scan buffs
		for i = 1, 32 do
			local texture = UnitBuff("target", i)
			if texture and string.find(texture, "Spell_Shadow_CurseOfTounges") then
				-- Found Curse of Tongues as buff
				return
			elseif not texture then
				break
			end
		end

		-- no curse of tongues found, trigger sync
		self:Sync(syncName.bishopNoCurse)
	end
end

function module:BishopNeedsCurseOfTongues()
	if self.db.profile.bishoptonguesalert then
		if IsRaidLeader() or playerClass == "WARLOCK" then
			-- Alert warlocks that the Bishop needs to be cursed
			self:Message("Bishop needs Curse of Tongues!", "Important", nil, "Alert")
		end
	end
end

function module:Test()
	-- Initialize module state
	self:OnSetup()
	self:Engage()

	-- Store original player name
	local originalPlayer = UnitName("player")
	local testPlayerName1 = UnitName("raid1") or "TestPlayer1"
	local testPlayerName2 = UnitName("raid2") or "TestPlayer2"

	local events = {
		-- King's Curse events
		{ time = 1, func = function()
			-- Simulate actual message format
			local msg = originalPlayer .. " is afflicted by King's Curse"
			module:AfflictionEvent(msg)
			print("Test: " .. msg)
		end },

		{ time = 1, func = function()
			-- Simulate actual message format
			local msg = testPlayerName1 .. " is afflicted by King's Curse"
			module:AfflictionEvent(msg)
			print("Test: " .. msg)
		end },

		-- Queen cast with target
		{ time = 2, func = function()
			local targetMsg = "Queen begins to cast Dark Subservience on " .. originalPlayer
			print("Test: " .. targetMsg)
			-- Use the correct sync format
			self:Sync(syncName.queenCastingSubservience .. " " .. originalPlayer)
		end },

		-- Subservience events for self
		{ time = 3, func = function()
			local msg = "You are afflicted by Dark Subservience"
			module:AfflictionEvent(msg)
			print("Test: " .. msg)
		end },

		{ time = 5, func = function()
			print("Test: Scanning Bishop")
			local originalName = L["bishop_name"]
			L["bishop_name"] = UnitName("target")

			-- Run the scan function
			module:ScanBishopDebuffs()

			-- Restore original name
			L["bishop_name"] = originalName
		end },

		{ time = 7, func = function()
			print("Test: Queen begins to cast Charming Presence")
			module:Sync(syncName.charmingPresence)
		end },

		{ time = 9, func = function()
			local msg = "Dark Subservience fades from you"
			module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
			print("Test: " .. msg)
		end },

		-- Subservience events for another player with King's Curse
		{ time = 12, func = function()
			local msg = testPlayerName1 .. " is afflicted by Dark Subservience"
			module:AfflictionEvent(msg)
			module:DecurseReminder(testPlayerName1, "raid1")
			print("Test: " .. msg)
		end },

		{ time = 18, func = function()
			local msg = "Dark Subservience fades from " .. testPlayerName1
			module:FadesEvent(msg)
			print("Test: " .. msg)
		end },

		-- Test King's Curse fading
		{ time = 20, func = function()
			local msg = "King's Curse fades from " .. testPlayerName1
			module:FadesEvent(msg)
			print("Test: " .. msg)
		end },

		-- Test subservience failed (grounding totem)
		{ time = 24, func = function()
			self.queenTarget = testPlayerName1
			print("Test: Queen begins to cast Dark Subservience on " .. testPlayerName1)
			self:Sync(syncName.queenCastingSubservience .. " " .. testPlayerName1)
		end },

		{ time = 25, func = function()
			local msg = "Dark Subservience fails. Grounding Totem"
			module:CastEvent(msg)
			print("Test: " .. msg)
		end },

		-- King's Fury event
		{ time = 28, func = function()
			local msg = "King begins to cast King's Fury"
			module:CastEvent(msg)
			print("Test: " .. msg)
		end },

		-- Test player death with debuffs
		{ time = 30, func = function()
			local msg = testPlayerName2 .. " is afflicted by Dark Subservience"
			module:AfflictionEvent(msg)
			module:DecurseReminder(testPlayerName2, "raid2")
			print("Test: " .. msg)
		end },

		{ time = 31, func = function()
			local msg = testPlayerName2 .. " is afflicted by King's Curse"
			module:AfflictionEvent(msg)
			print("Test: " .. msg)
		end },

		{ time = 32, func = function()
			local msg = testPlayerName2 .. " dies"
			-- Correct event for player death is CHAT_MSG_COMBAT_FRIENDLY_DEATH
			module:OnFriendlyDeath(msg)
			print("Test: " .. msg)
		end },

		-- Add to the events table inside the Test function
		{ time = 33, func = function()
			print("Test: Scanning Bishop")
			local originalName = L["bishop_name"]
			L["bishop_name"] = UnitName("target")

			-- Run the scan function
			module:ScanBishopDebuffs()

			-- Restore original name
			L["bishop_name"] = originalName
		end },

        -- Test case for Void Zone
        { time = 34, func = function()
            print("Test: Simulating Void Zone cast")
            module:CastEvent(L["trigger_voidzone"])
        end },
		-- Test disengage
		{ time = 35, func = function()
			print("Test: Disengage")
			BigWigs:DisableModule("King")
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("ChessEventTest" .. i, event.func, event.time)
	end

	self:Message("Chess Event test started", "Positive")
	return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("King"); BigWigs:SetupModule("King");m:Test();
