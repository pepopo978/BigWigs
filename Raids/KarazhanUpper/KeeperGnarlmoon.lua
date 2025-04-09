local module, L = BigWigs:ModuleDeclaration("Keeper Gnarlmoon", "Karazhan")

-- module variables
module.revision = 30000 -- To be updated
module.enabletrigger = module.translatedName
module.toggleoptions = { "lunarshift", "ravens", "owlphase", "owlenrage", "moondebuff", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
}
-- module defaults
module.defaultDB = {
	lunarshift = true,
	ravens = true,
	owlphase = true,
	owlenrage = true,
	moondebuff = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "Gnarlmoon",

		lunarshift_cmd = "lunarshift",
		lunarshift_name = "Lunar Shift Alert",
		lunarshift_desc = "Warns when Keeper Gnarlmoon begins to cast Lunar Shift",

		owlphase_cmd = "owlphase",
		owlphase_name = "Owl Phase Alert",
		owlphase_desc = "Warns when Keeper Gnarlmoon enters and exits the Owl Dimension phase",

		owlenrage_cmd = "owlenrage",
		owlenrage_name = "Owl Enrage Alert",
		owlenrage_desc = "Warns when the Owls are about to enrage",

		moondebuff_cmd = "moondebuff",
		moondebuff_name = "Moon Debuff Alert",
		moondebuff_desc = "Warns when you get affected by Red Moon or Blue Moon",

		trigger_lunarShiftCast = "Keeper Gnarlmoon begins to cast Lunar Shift",
		bar_lunarShiftCast = "Lunar Shift Casting!",
		bar_lunarShiftCD = "Next Lunar Shift",
		msg_lunarShift = "Lunar Shift casting!",

		ravens_cmd = "ravens",
		ravens_name = "Raven alert",
		ravens_desc = "Timer for when 12 Blood Ravens will appear",
		msg_ravensSoon = "12 ravens incoming",

		msg_midHp = "Keeper Gnarlmoon < 71% - Owls Soon (@ 66%)!",
		msg_lowHp = "Keeper Gnarlmoon < 38% - Owls Soon (@ 33%)!",

		trigger_owlPhaseStart = "Keeper Gnarlmoon gains Worgen Dimension",
		trigger_owlPhaseEnd = "Worgen Dimension fades from Keeper Gnarlmoon",
		msg_owlPhaseStart = "Owl Phase begins - kill the owls at the same time within 1 min!",
		msg_owlPhaseEnd = "Owl Phase ended!",

		bar_owlEnrage = "Owls Enrage",
		msg_owlEnrage = "Owls will enrage in 10 seconds!",
		msg_owlsEnraged = "Owls Enraged!",

		trigger_redMoon = "afflicted by Red Moon",
		trigger_blueMoon = "afflicted by Blue Moon",
		msg_redMoon = "You have RED MOON!",
		msg_blueMoon = "You have BLUE MOON!",
	}
end)

-- timer and icon variables
local timer = {
	lunarShiftCast = 5,
	lunarShiftCD = 30,
	owlPhase = 67, -- approximately based on logs
	owlEnrage = 60,
	ravenSummon = { 15, 40 },
}

local icon = {
	lunarShift = "Spell_Nature_StarFall",
	owlPhase = "Ability_EyeOfTheOwl",
	owlEnrage = "Spell_Shadow_UnholyFrenzy",
	redMoon = "inv_misc_orb_05",
	blueMoon = "inv_ore_arcanite_02",
}

local color = {
	lunarShift = "Blue",
	owlPhase = "Green",
	owlEnrage = "Red",
}

local syncName = {
	lunarShift = "GnarlmoonLunarShift" .. module.revision,
	owlPhaseStart = "GnarlmoonOwlStart" .. module.revision,
	owlPhaseEnd = "GnarlmoonOwlEnd" .. module.revision,
}

-- module functions
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")

	self:ThrottleSync(3, syncName.lunarShift)
	self:ThrottleSync(5, syncName.owlPhaseStart)
	self:ThrottleSync(5, syncName.owlPhaseEnd)
end

function module:OnSetup()
	self.started = nil
	self.phase = nil
	self.owlPhaseCount = 0

	-- Used to monitor when owl phase will begin
	self.lowHp = nil
	self.midHp = nil
	self.gnarlHealth = 100

	-- used to separate timer for first raven summon from remainer
	self.firstRaven = true
end

function module:OnEngage()
	self.phase = 1
	self.owlPhaseCount = 0

	-- Used to monitor when owl phase will begin
	self.lowHp = nil
	self.midHp = nil
	self.gnarlHealth = 100

	-- used to separate timer for first raven summon from remainer
	self.firstRaven = true

	if self.db.profile.lunarshift then
		self:Bar(L["bar_lunarShiftCD"], timer.lunarShiftCD, icon.lunarShift, true, color.lunarShift)
	end

	if self.db.profile.ravens then
		self:DelayedMessage(timer.ravenSummon[1] - 5, L["msg_ravensSoon"], "Important", false, nil, false)
		self:ScheduleEvent("FirstRavens", self.FirstRavens, timer.ravenSummon[1], self)
	end

	if self.db.profile.owlphase then
		self:ScheduleRepeatingEvent("CheckHps", self.CheckHps, 1, self)
	end

end

function module:OnDisengage()
	if self:IsEventScheduled("FirstRavens") then
		self:CancelScheduledEvent("FirstRavens")
	end

	if self:IsEventScheduled("CheckHps") then
		self:CancelScheduledEvent("CheckHps")
	end

	if self:IsEventScheduled("RemainingRavens") then
		self:CancelScheduledEvent("RemainingRavens")
	end
end

function module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["trigger_lunarShiftCast"]) then
		self:Sync(syncName.lunarShift)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if string.find(msg, L["trigger_owlPhaseStart"]) then
		self:Sync(syncName.owlPhaseStart)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	if string.find(msg, L["trigger_owlPhaseEnd"]) then
		self:Sync(syncName.owlPhaseEnd)
	end
end

function module:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE(msg)
	if self.db.profile.moondebuff then
		if string.find(msg, L["trigger_redMoon"]) then
			self:Message(L["msg_redMoon"], "Important", true, "Alarm")
			self:WarningSign(icon.redMoon, 5, true, "RED")
		elseif string.find(msg, L["trigger_blueMoon"]) then
			self:Message(L["msg_blueMoon"], "Important", true, "Alert")
			self:WarningSign(icon.blueMoon, 5, "BLUE")
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.lunarShift then
		self:LunarShift()
	elseif sync == syncName.owlPhaseStart then
		self:OwlPhaseStart()
	elseif sync == syncName.owlPhaseEnd then
		self:OwlPhaseEnd()
	end
end

function module:LunarShift()
	if self.db.profile.lunarshift then
		self:Message(L["msg_lunarShift"], "Important")
		self:RemoveBar(L["bar_lunarShiftCD"])
		self:Bar(L["bar_lunarShiftCast"], timer.lunarShiftCast, icon.lunarShift, true, color.lunarShift)
		self:DelayedBar(timer.lunarShiftCast, L["bar_lunarShiftCD"], timer.lunarShiftCD - timer.lunarShiftCast, icon.lunarShift, true, color.lunarShift)
	end
end

function module:FirstRavens()
	-- first summon is after 15 seconds, remainder are every 40 seconds
	self:DelayedMessage(timer.ravenSummon[2] - 5, L["msg_ravensSoon"], "Important", false, nil, false)
	self:ScheduleRepeatingEvent("RemainingRavens", self.RemainingRavens, timer.ravenSummon[2], self)
end

function module:RemainingRavens()
	self:DelayedMessage(timer.ravenSummon[2] - 5, L["msg_ravensSoon"], "Important", false, nil, false)
end

function module:OwlPhaseStart()
	-- TODO add owl hp display
	if self.db.profile.owlphase then
		self.owlPhaseCount = self.owlPhaseCount + 1
		self:Message(L["msg_owlPhaseStart"], "Attention")
		self:Sound("Alarm")

		if self.db.profile.owlenrage then
			self:Bar(L["bar_owlEnrage"], timer.owlEnrage, icon.owlEnrage, true, color.owlEnrage)
		end

		-- Cancel Lunar Shift bars during owl phase
		self:RemoveBar(L["bar_lunarShiftCast"])
		self:RemoveBar(L["bar_lunarShiftCD"])
	end
end

function module:OwlPhaseEnd()
	if self.db.profile.owlphase then
		self:Message(L["msg_owlPhaseEnd"], "Positive")
		self:RemoveBar(L["bar_owlEnrage"])
	end
end

function module:CheckHps()
	for i = 1, GetNumRaidMembers() do
		local targetString = "raid" .. i .. "target"
		local targetName = UnitName(targetString)
		local tempH

		if targetName == module.translatedName then
			tempH = UnitHealth(targetString)
			if tempH > 0 then
				self.gnarlHealth = math.ceil((UnitHealth(targetString) / UnitHealthMax(targetString)) * 100)
				break
			end
		end
	end

	if self.gnarlHealth < 71 and self.midHp == nil then
		self.midHp = true
		self:Message(L["msg_midHp"], "Urgent", true, nil, false)
		self:Sound("Info")
	end

	if self.gnarlHealth < 38 and self.lowHp == nil then
		self.lowHp = true
		self:Message(L["msg_lowHp"], "Urgent", true, nil, false)
		self:Sound("Info")
	end
end

-- Update the Test function to include ravens and HP monitoring
function module:Test()
	-- Enable all options for testing
	self.db.profile.lunarshift = true
	self.db.profile.owlphase = true
	self.db.profile.owlenrage = true
	self.db.profile.moondebuff = true
	self.db.profile.ravens = true

	-- Initialize module state
	self:OnSetup()

	self.phase = 1
	self.owlPhaseCount = 0

	local events = {
		-- Initial Lunar Shift
		{ time = 3, text = "Keeper Gnarlmoon begins to cast Lunar Shift." },

		-- HP triggers
		{ time = 6, action = function()
			print("Test: 70% hp");
			module.gnarlHealth = 70;
			module:CheckHps();
		end },

		{ time = 9, text = "Keeper Gnarlmoon begins to cast Lunar Shift." },

		-- First Owl Phase (at 66.66% HP)
		{ time = 15, text = "Keeper Gnarlmoon gains Worgen Dimension (1)." },

		-- Moon debuffs
		{ time = 17, text = "You are afflicted by Red Moon (1)." },
		{ time = 27, text = "You are afflicted by Blue Moon (1)." },

		-- Owl Phase ends
		{ time = 30, text = "Worgen Dimension fades from Keeper Gnarlmoon." },

		-- Second Lunar Shift
		{ time = 40, text = "Keeper Gnarlmoon begins to cast Lunar Shift." },

		-- HP triggers for second owl phase
		{ time = 45, action = function()
			print("Test: 37% hp");
			module.gnarlHealth = 37;
			module:CheckHps();
		end },

		-- Second Owl Phase (at 33.33% HP)
		{ time = 50, text = "Keeper Gnarlmoon gains Worgen Dimension (1)." },

		-- Moon debuffs again
		{ time = 52, text = "You are afflicted by Blue Moon (1)." },
		{ time = 62, text = "You are afflicted by Red Moon (1)." },

		-- Owl Phase ends
		{ time = 65, text = "Worgen Dimension fades from Keeper Gnarlmoon." },

		-- Final Lunar Shift
		{ time = 75, text = "Keeper Gnarlmoon begins to cast Lunar Shift." }
	}

	local handlers = {
		["Keeper Gnarlmoon begins to cast Lunar Shift."] = function()
			print("Test: Keeper Gnarlmoon begins to cast Lunar Shift")
			module:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE("Keeper Gnarlmoon begins to cast Lunar Shift.")
		end,
		["Keeper Gnarlmoon gains Worgen Dimension (1)."] = function()
			print("Test: Keeper Gnarlmoon gains Worgen Dimension")
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS("Keeper Gnarlmoon gains Worgen Dimension")
		end,
		["Worgen Dimension fades from Keeper Gnarlmoon."] = function()
			print("Test: Worgen Dimension fades from Keeper Gnarlmoon")
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER("Worgen Dimension fades from Keeper Gnarlmoon")
		end,
		["You are afflicted by Red Moon (1)."] = function()
			print("Test: You are afflicted by Red Moon")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE("You are afflicted by Red Moon (1).")
		end,
		["You are afflicted by Blue Moon (1)."] = function()
			print("Test: You are afflicted by Blue Moon")
			module:CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE("You are afflicted by Blue Moon (1).")
		end,
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		if event.text then
			self:ScheduleEvent("GnarlmoonTest" .. i, function(eventText)
				if handlers[eventText] then
					handlers[eventText]()
				end
			end, event.time, event.text)
		elseif event.action then
			self:ScheduleEvent("GnarlmoonTest" .. i, event.action, event.time)
		end
	end

	-- Schedule raven test
	self:ScheduleEvent("GnarlmoonTestRavens", function()
		module:FirstRavens()
	end, 12)

	self:Message("Keeper Gnarlmoon test started", "Positive")
	return true
end

--/run local m=BigWigs:GetModule("Keeper Gnarlmoon"); BigWigs:SetupModule("Keeper Gnarlmoon");m:Test();
