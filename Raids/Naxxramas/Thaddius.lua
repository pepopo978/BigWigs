local module, L = BigWigs:ModuleDeclaration("Thaddius", "Naxxramas")
local feugen = AceLibrary("Babble-Boss-2.2")["Feugen"]
local stalagg = AceLibrary("Babble-Boss-2.2")["Stalagg"]

module.revision = 30091
module.enabletrigger = { module.translatedName, feugen, stalagg }
module.toggleoptions = { "power", "magneticPull", "manaburn", "tankthreat", -1, "phase", -1, "enrage", "selfcharge", "polarity", "bosskill" }

module.defaultDB = {
	enrage = false,
	tankframeposx = 100,
	tankframeposy = 500,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Thaddius",

		power_cmd = "power",
		power_name = "Power Surge Alert",
		power_desc = "Warn for Stalagg's Power Surge",

		magneticPull_cmd = "magneticPull",
		magneticPull_name = "Magnetic Pull Alerts",
		magneticPull_desc = "Warn for Magnetic Pull",

		manaburn_cmd = "manaburn",
		manaburn_name = "Mana Burn Alerts",
		manaburn_desc = "Warn for Mana Burn",

		tankthreat_cmd = "tankthreat",
		tankthreat_name = "Tank Threat Status",
		tankthreat_desc = "Displays the threat of both tanks on Feugen and Stalagg so you aren't caught off guard on magnetic pull.",

		phase_cmd = "phase",
		phase_name = "Phase Alerts",
		phase_desc = "Warn for Phase transitions",

		enrage_cmd = "enrage",
		enrage_name = "Enrage Alert",
		enrage_desc = "Warn for Enrage",

		polarity_cmd = "polarity",
		polarity_name = "Polarity Shift Alert",
		polarity_desc = "Warn for polarity shifts",

		selfcharge_cmd = "selfcharge",
		selfcharge_name = "Charge Change Alert",
		selfcharge_desc = "Warn for your Positive/Negative charge changing.",


		trigger_engage = "Stalagg crush you!", --CHAT_MSG_MONSTER_YELL
		trigger_engage1 = "Feed you to master!", --CHAT_MSG_MONSTER_YELL

		trigger_powerSurge = "Stalagg gains Power Surge.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		bar_powerSurge = "Power Surge",
		msg_powerSurge = "Power Surge on Stalagg!",

		bar_magneticPull = "Magnetic Pull",

		trigger_manaBurn = "Feugen's Static Field hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		trigger_manaBurn2 = "You absorb Feugen's Static Field.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		msg_manaBurn = "Feugen Mana Burned You! 30 yards AoE",

		trigger_feugenDeadYell = "No... more... Feugen...", --CHAT_MSG_MONSTER_YELL
		trigger_stalaggDeadYell = "Master save me...", --CHAT_MSG_MONSTER_YELL

		trigger_3sec = "%s overloads!", --CHAT_MSG_RAID_BOSS_EMOTE
		bar_phase2 = "Thaddius Active",
		msg_phase2 = "Phase 2",
		msg_positionReminder = "- - - - -  Thaddius  + + + + +",

		trigger_enrage = "Thaddius gains Berserk", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		bar_enrage = "Enrage",
		msg_enrage = "Enrage!",
		msg_enrage60 = "Enrage in 60 seconds",
		msg_enrage10 = "Enrage in 10 seconds",

		posicontext = "Positive",
		negicontext = "Negative",

		positivetype = "Interface\\Icons\\Spell_ChargePositive",
		poswarn = "You changed to a Positive Charge!",
		negativetype = "Interface\\Icons\\Spell_ChargeNegative",
		negwarn = "You changed to a Negative Charge!",
		polaritytickbar = "Polarity tick",

		stayedpos = "You stayed Positive, don't move!",
		stayedneg = "You stayed Negative, don't move!",

		trigger_polarityShiftCast = "Thaddius begins to cast Polarity Shift.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_polarityShiftCast = "Polarity Shift Cast",
		msg_polarityShift = "Casting Polarity Shift!",

		trigger_polarityShiftAfflic = "Now YOU feel pain!", --CHAT_MSG_MONSTER_YELL
		bar_polarityShiftCd = "Polarity Shift CD",

		msg_noChange = "Your debuff did not change!",
		msg_changeToPositive = "You changed to a Positive Charge!",
		msg_changeToNegative = "You changed to a Negative Charge!",
		bar_polarityTick = "Polarity tick",
	}
end)

local timer = {
	powerSurge = 10,
	magneticPull = 20.5,

	phase2 = 14,

	enrage = 300,

	firstPolarity = { 11, 14.2 }, --saw 11, 14.2
	polarityShiftCd = 27, --{25,35},
	polarityShiftCast = 3,
	polarityTick = 5,
}
local icon = {
	powerSurge = "Spell_Shadow_UnholyFrenzy",
	magneticPull = "spell_nature_groundingtotem",

	phase2 = "Inv_misc_pocketwatch_01",

	enrage = "Spell_Shadow_UnholyFrenzy",

	polarityShift = "Spell_Nature_Lightning",
	positive = "Spell_ChargePositive",
	negative = "Spell_ChargeNegative",

	manaBurn = "Spell_Shadow_ManaBurn",

	hpBar = "spell_shadow_raisedead",
}
local color = {
	powerSurge = "Red",
	magneticPull = "Blue",

	phase = "Black",

	enrage = "White",

	polarityShiftCd = "Cyan",
	polarityShiftCast = "Green",

	positive = "Blue",
	negative = "Red",

	hpBar = "Magenta"
}
local syncName = {
	powerSurge = "StalaggPower" .. module.revision,

	phase2 = "ThaddiusAddsDead" .. module.revision,

	teslaOverload = "ThaddiusTeslaOverload" .. module.revision,

	enrage = "ThaddiusEnrage" .. module.revision,

	checkAuras = "ThaddiusCheckAuras" .. module.revision,

	feuganTankThreat = "feuganTankThreat" .. module.revision,
	stalaggTankThreat = "stalaggTankThreat" .. module.revision,

	polarityShiftCast = "ThaddiusPolarityShiftCast" .. module.revision,
	polarity = "ThaddiusPolarity" .. module.revision,
}

local phase2started = nil
local stalaggDead = nil
local feugenDead = nil

module:RegisterYellEngage(L["trigger_engage"])
module:RegisterYellEngage(L["trigger_engage1"])

function module:OnEnable()
	self.threatWasListening = BigWigsThreat:IsListening()

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_engage1, trigger_feugenDeadYell, trigger_stalaggDeadYell, trigger_polarityShiftAfflic
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE") --trigger_3sec
	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_polarityShiftCast
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_manaBurn, trigger_manaBurn2

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_powerSurge, trigger_enrage

	self:ThrottleSync(4, syncName.powerSurge)

	self:ThrottleSync(20, syncName.phase2)
	self:ThrottleSync(5, syncName.teslaOverload)

	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(5, syncName.polarityShiftCast)
	self:ThrottleSync(5, syncName.polarity)
	self:ThrottleSync(2, syncName.checkAuras)

	self:ThrottleSync(0.5, syncName.feuganTankThreat)
	self:ThrottleSync(0.5, syncName.stalaggTankThreat)

	self.checkAuras = true

	self:UpdateTankStatusFrame()
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self.started = nil
	self.previousCharge = ""
end

function module:OnEngage()
	if self.db.profile.tankthreat then
		BigWigsThreat:StartListening()
		BigWigsThreat:EnableEventsForTank()
		self:RegisterEvent("BigWigs_ThreatUpdate", "ThreatUpdate")
	end

	phase2started = false

	self.previousCharge = ""

	stalaggDead = false
	feugenDead = false

	self.feugenHP = 100
	self.stalaggHP = 100
	self:TriggerEvent("BigWigs_StartHPBar", self, feugen, 100, "Interface\\Icons\\" .. icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, feugen, 0)
	self:TriggerEvent("BigWigs_StartHPBar", self, stalagg, 100, "Interface\\Icons\\" .. icon.hpBar, true, color.hpBar)
	self:TriggerEvent("BigWigs_SetHPBar", self, stalagg, 0)

	self:ScheduleRepeatingEvent("CheckAddHP", self.CheckAddHP, 0.5, self)

	if self.db.profile.magneticPull then
		self:Bar(L["bar_magneticPull"], timer.magneticPull, icon.magneticPull, true, color.magneticPull)
		self:ScheduleRepeatingEvent("MagneticPull", self.MagneticPull, timer.magneticPull, self)
	end
end

function module:OnDisengage()
	-- stop listening for tank threat updates when combat ends
	if self.threatWasListening == false then
		BigWigsThreat:StopListening()
	end

	if self.tankStatusFrame then
		self.tankStatusFrame:Hide()
	end
end

function module:UpdateTankStatusFrame()
	if not self.db.profile.tankthreat then
		return
	end

	-- create frame if needed
	if not self.tankStatusFrame then
		self.tankStatusFrame = CreateFrame("Frame", "ThaddiusTankStatusFrame", UIParent)
		self.tankStatusFrame.module = self
		self.tankStatusFrame:SetWidth(250)
		self.tankStatusFrame:SetHeight(50)
		self.tankStatusFrame:ClearAllPoints()
		local s = self.tankStatusFrame:GetEffectiveScale()
		self.tankStatusFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (self.db.profile.tankframeposx or 100) / s, (self.db.profile.tankframeposy or 500) / s)
		self.tankStatusFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})
		self.tankStatusFrame:SetBackdropColor(0, 0, 0, 1)

		-- allow dragging
		self.tankStatusFrame:SetMovable(true)
		self.tankStatusFrame:EnableMouse(true)
		self.tankStatusFrame:RegisterForDrag("LeftButton")
		self.tankStatusFrame:SetScript("OnDragStart", function()
			this:StartMoving()
		end)
		self.tankStatusFrame:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()

			local scale = this:GetEffectiveScale()
			this.module.db.profile.tankframeposx = this:GetLeft() * scale
			this.module.db.profile.tankframeposy = this:GetTop() * scale
		end)

		local font = "Fonts\\FRIZQT__.TTF"
		local fontSize = 9

		self.tankStatusFrame.feugen = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.feugen:SetFontObject(GameFontNormal)
		self.tankStatusFrame.feugen:SetPoint("TOPLEFT", self.tankStatusFrame, "TOPLEFT", 10, -10)
		self.tankStatusFrame.feugen:SetText("Feugan Tank:")
		self.tankStatusFrame.feugen:SetFont(font, fontSize)

		self.tankStatusFrame.feugenTank = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.feugenTank:SetFontObject(GameFontNormal)
		self.tankStatusFrame.feugenTank:SetPoint("TOP", self.tankStatusFrame, "TOP", 0, -10)
		self.tankStatusFrame.feugenTank:SetJustifyH("CENTER")
		self.tankStatusFrame.feugenTank:SetFont(font, fontSize)

		self.tankStatusFrame.feugenTankThreat = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.feugenTankThreat:SetFontObject(GameFontNormal)
		self.tankStatusFrame.feugenTankThreat:SetPoint("TOPRIGHT", self.tankStatusFrame, "TOPRIGHT", -10, -10)
		self.tankStatusFrame.feugenTankThreat:SetJustifyH("RIGHT")
		self.tankStatusFrame.feugenTankThreat:SetFont(font, fontSize)

		self.tankStatusFrame.stalagg = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.stalagg:SetFontObject(GameFontNormal)
		self.tankStatusFrame.stalagg:SetPoint("TOPLEFT", self.tankStatusFrame.feugen, "BOTTOMLEFT", 0, -10)
		self.tankStatusFrame.stalagg:SetText("Stalagg Tank:")
		self.tankStatusFrame.stalagg:SetFont(font, fontSize)

		self.tankStatusFrame.stalaggTank = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.stalaggTank:SetFontObject(GameFontNormal)
		self.tankStatusFrame.stalaggTank:SetPoint("TOP", self.tankStatusFrame.feugenTank, "BOTTOM", 0, -10)
		self.tankStatusFrame.stalaggTank:SetJustifyH("CENTER")
		self.tankStatusFrame.stalaggTank:SetFont(font, fontSize)

		self.tankStatusFrame.stalaggTankThreat = self.tankStatusFrame:CreateFontString(nil, "ARTWORK")
		self.tankStatusFrame.stalaggTankThreat:SetFontObject(GameFontNormal)
		self.tankStatusFrame.stalaggTankThreat:SetPoint("TOPRIGHT", self.tankStatusFrame.feugenTankThreat, "BOTTOMRIGHT", 0, -10)
		self.tankStatusFrame.stalaggTankThreat:SetJustifyH("RIGHT")
		self.tankStatusFrame.stalaggTankThreat:SetFont(font, fontSize)
	end
	self.tankStatusFrame:Show()

	self.tankStatusFrame.feugenTank:SetText(self.feugenTank or "?")

	if self.feugenTankThreat and type(self.feugenTankThreat) == "number" then
		-- divide by 1000 and round to 1 decimal
		self.tankStatusFrame.feugenTankThreat:SetText(string.format("%.1f k", self.feugenTankThreat / 1000))
	else
		self.tankStatusFrame.feugenTankThreat:SetText("?")
	end

	self.tankStatusFrame.stalaggTank:SetText(self.stalaggTank or "?")

	if self.stalaggTankThreat and type(self.stalaggTankThreat) == "number" then
		self.tankStatusFrame.stalaggTankThreat:SetText(string.format("%.1f k", self.stalaggTankThreat / 1000))
	else
		self.tankStatusFrame.stalaggTankThreat:SetText("?")
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Feugen")) then
		feugenDead = true
	elseif (msg == string.format(UNITDIESOTHER, "Stalagg")) then
		stalaggDead = true
	end

	if feugenDead == true and feugenDead == true then
		self:Sync(syncName.phase2)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_feugenDeadYell"] then
		feugenDead = true
		if feugenDead == true and feugenDead == true then
			self:Sync(syncName.phase2)
		end
	elseif msg == L["trigger_stalaggDeadYell"] then
		stalaggDead = true
		if feugenDead == true and feugenDead == true then
			self:Sync(syncName.phase2)
		end
	elseif msg == L["trigger_polarityShiftAfflic"] then
		self:Sync(syncName.polarity)
	end
end

function module:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L["trigger_3sec"] then
		self:Sync(syncName.teslaOverload)
	end
end

function module:CheckAddHP()
	local feugenHealth
	local stalaggHealth

	for i = 1, GetNumRaidMembers() do
		if UnitName("Raid" .. i .. "Target") == feugen then
			feugenHealth = math.ceil((UnitHealth("Raid" .. i .. "Target") / UnitHealthMax("Raid" .. i .. "Target")) * 100)
		elseif UnitName("Raid" .. i .. "Target") == stalagg then
			stalaggHealth = math.ceil((UnitHealth("Raid" .. i .. "Target") / UnitHealthMax("Raid" .. i .. "Target")) * 100)
		end
		if feugenHealth and stalaggHealth then
			break
		end
	end

	if feugenHealth then
		self.feugenHP = feugenHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, feugen, 100 - self.feugenHP)
	end

	if stalaggHealth then
		self.stalaggHP = stalaggHealth
		self:TriggerEvent("BigWigs_SetHPBar", self, stalagg, 100 - self.stalaggHP)
	end
end

function module:ThreatUpdate(player, threat, perc, tank, melee)
	-- ignore other threat updates
	if not tank then
		return
	end

	local currentTarget = UnitName("target")
	if not currentTarget then
		return
	end

	if currentTarget == feugen then
		self:Sync(syncName.feuganTankThreat .. " " .. player .. " " .. threat)
	elseif currentTarget == stalagg then
		self:Sync(syncName.stalaggTankThreat .. " " .. player .. " " .. threat)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_powerSurge"]) then
		self:Sync(syncName.powerSurge)

	elseif string.find(msg, L["trigger_manaBurn"]) or string.find(msg, L["trigger_manaBurn2"]) then
		self:ManaBurn()

	elseif string.find(msg, L["trigger_enrage"]) then
		self:Sync(syncName.enrage)

	elseif msg == L["trigger_polarityShiftCast"] then
		self:Sync(syncName.polarityShiftCast)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.feuganTankThreat and self.db.profile.tankthreat then
		local _, _, tankName, threat = string.find(rest, "(.+) (%d+)")
		if tankName and threat then
			self.feugenTank = tankName
			self.feugenTankThreat = tonumber(threat)
			self:UpdateTankStatusFrame()
		end
	elseif sync == syncName.stalaggTankThreat and self.db.profile.tankthreat then
		local _, _, tankName, threat = string.find(rest, "(.+) (%d+)")
		if tankName and threat then
			self.stalaggTank = tankName
			self.stalaggTankThreat = tonumber(threat)
			self:UpdateTankStatusFrame()
		end
	elseif sync == syncName.powerSurge and self.db.profile.power then
		self:PowerSurge()
	elseif sync == syncName.phase2 and self.db.profile.phase then
		self:Phase2()
	elseif sync == syncName.teslaOverload and self.db.profile.phase then
		self:ThreeSec()

	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()

	elseif sync == syncName.polarity and self.db.profile.polarity then
		self:PolarityShift()
	elseif sync == syncName.polarityShiftCast and self.db.profile.polarity then
		self:PolarityShiftCast()
	elseif sync == syncName.checkAuras then
		self:CheckAuras()
	end
end

function module:PowerSurge()
	self:Message(L["msg_powerSurge"], "Important", false, nil, false)
	self:Bar(L["bar_powerSurge"], timer.powerSurge, icon.powerSurge, true, color.powerSurge)
end

function module:MagneticPull()
	self:WarningSign(icon.magneticPull, 0.7)
	self:Bar(L["bar_magneticPull"], timer.magneticPull, icon.magneticPull, true, color.magneticPull)
end

function module:ManaBurn()
	self:WarningSign(icon.manaBurn, 0.7)
	self:Message(L["msg_manaBurn"], "Urgent", false, nil, false)
	self:Sound("Beware")
end

function module:Phase2()
	phase2started = true

	self:TriggerEvent("BigWigs_StopHPBar", self, feugen)
	self:TriggerEvent("BigWigs_StopHPBar", self, stalagg)
	self:CancelScheduledEvent("CheckAddHP")
	self:CancelScheduledEvent("MagneticPull")
	self:RemoveBar(L["bar_magneticPull"])
	self:RemoveBar(L["bar_powerSurge"])
	self:CancelDelayedSound("Info")

	self:Bar(L["bar_phase2"], timer.phase2, icon.phase2, true, color.phase)
	self:Message(L["msg_positionReminder"])
end

function module:ThreeSec()
	if phase2started == true then
		self:RemoveBar(L["bar_phase2"])
		self:Bar(L["bar_phase2"], 3, icon.phase2, true, color.phase)
		self:Message(L["msg_positionReminder"])

		if self.db.profile.enrage then
			self:DelayedBar(3, L["bar_enrage"], timer.enrage, icon.enrage, true, color.enrage)
			self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Urgent", false, nil, false)
			self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important", false, nil, false)
		end

		if self.db.profile.polarity then
			self:DelayedIntervalBar(3, L["bar_polarityShiftCd"], timer.firstPolarity[1], timer.firstPolarity[2], icon.polarityShift, true, color.polarityShiftCd)
			self:Message(L["msg_positionReminder"])
		end
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:CancelDelayedMessage(L["msg_enrage60"])
	self:CancelDelayedMessage(L["msg_enrage10"])

	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:Sound("Beware")
	self:WarningSign(icon.enrage, 0.7)
end

function module:PolarityShiftCast()
	self.checkAuras = true

	self:RemoveBar(L["bar_polarityShiftCd"])
	self:Message(L["msg_polarityShift"], "Important", false, nil, false)
	self:Bar(L["bar_polarityShiftCast"], timer.polarityShiftCast, icon.polarityShift, true, color.polarityShiftCast)
end

function module:PolarityShift()
	self:Bar(L["bar_polarityShiftCd"], timer.polarityShiftCd, icon.polarityShift, true, color.polarityShiftCd)
	self:DelayedSync(1, syncName.checkAuras) -- PLAYER_AURAS_CHANGED doesn't seem to always fire, use this as a backup
end

function module:PLAYER_AURAS_CHANGED(msg)
	self:Sync(syncName.checkAuras)
end

function module:CheckAuras(msg)
	if self.checkAuras == false then
		return
	end

	local chargetype = nil
	local iIterator = 1
	while UnitDebuff("Player", iIterator) do
		local texture, applications = UnitDebuff("Player", iIterator)
		if texture == L["positivetype"] or texture == L["negativetype"] then
			if applications > 1 then
				return
			end
			chargetype = texture
		end
		iIterator = iIterator + 1
	end
	if not chargetype then
		return
	end
	if self.db.profile.selfcharge then
		self:NewPolarity(chargetype)
		self.checkAuras = false
	end
end

function module:NewPolarity(chargeType)
	if self.db.profile.selfcharge then
		if self.previousCharge and self.previousCharge ~= chargeType then
			if chargeType == L["positivetype"] then
				self:WarningSign(icon.positive, 3, false, L["posicontext"])
				self:Message(L["poswarn"], "Positive", true, nil, false)
				self:Sound("PositiveSwitchSides")
			elseif chargeType == L["negativetype"] then
				self:WarningSign(icon.negative, 3, false, L["negicontext"])
				self:Message(L["negwarn"], "Important", true, nil, false)
				self:Sound("NegativeSwitchSides")
			end
		elseif chargeType == L["positivetype"] then
			if self.previousCharge then
				self:Message(L["stayedpos"], "Positive", true, nil, false)
			else
				self:Message(L["poswarn"], "Positive", true, nil, false)
			end
			self:WarningSign(icon.positive, 3, false, L["posicontext"])
			self:Sound("Positive")
		elseif chargeType == L["negativetype"] then
			if self.previousCharge then
				self:Message(L["stayedneg"], "Important", true, nil, false)
			else
				self:Message(L["negwarn"], "Important", true, nil, false)
			end
			self:WarningSign(icon.negative, 3, false, L["negicontext"])
			self:Sound("Negative")
		end

		if chargeType == L["positivetype"] then
			self:Bar(L["polaritytickbar"], timer.polarityTick, icon.positive, true, "blue")
		elseif chargeType == L["negativetype"] then
			self:Bar(L["polaritytickbar"], timer.polarityTick, icon.negative, true, "red")
		end
	end
	self.previousCharge = chargeType
end
