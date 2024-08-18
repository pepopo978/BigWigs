local module, L = BigWigs:ModuleDeclaration("The Four Horsemen", "Naxxramas")
local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]

module.revision = 30096
module.enabletrigger = { thane, mograine, zeliek, blaumeux }
module.toggleoptions = { "mark", "marksounds", "shieldwall", "hpframe", -1,
                         "alwaysshowmeteor", "meteortimer", "voidtimer", "wrathtimer", "voidalert", -1,
                         "bosskill", "proximity", -1,
                         "healeronerotate", "healertworotate", "healerthreerotate" }
-- Proximity Plugin
module.proximityCheck = function(unit)
	return CheckInteractDistance(unit, 2)
end
module.proximitySilent = true
module.defaultDB = {
	healeronerotate = false,
	healertworotate = false,
	healerthreerotate = false,
	bossframeposx = 100,
	bossframeposy = 500,
	alwaysshowmeteor = false,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Horsemen",

		mark_cmd = "mark",
		mark_name = "Mark Alerts",
		mark_desc = "Warn for marks",

		marksounds_cmd = "marksound",
		marksounds_name = "Mark Alert Sounds",
		marksounds_desc = "Text to speech mark alerts",

		shieldwall_cmd = "shieldwall",
		shieldwall_name = "Shieldwall Alerts",
		shieldwall_desc = "Warn for shieldwall",

		hpframe_cmd = "hpframe",
		hpframe_name = "Boss HP Frame",
		hpframe_desc = "Shows a frame with the bosses' HP",

		alwaysshowmeteor_cmd = "alwaysshowmeteor",
		alwaysshowmeteor_name = "Always Show Meteor Timer",
		alwaysshowmeteor_desc = "Show Meteor Timer even if Thane is not target",

		meteortimer_cmd = "meteortimer",
		meteortimer_name = "Meteor Window Timer",
		meteortimer_desc = "Timer till next Meteor (every 12-15 sec).  Requires Thane to be target or targettarget.",

		voidtimer_cmd = "voidtimer",
		voidtimer_name = "Void Zone Timer",
		voidtimer_desc = "Timer till next Void Zone (every 12 sec).  Requires Lady Blaumeux to be target or targettarget.",

		wrathtimer_cmd = "wrath",
		wrathtimer_name = "Holy Wrath Window Timer",
		wrathtimer_desc = "Timer till next holy wrath (every 10-14 sec).  Requires Sir Zeliek to be target or targettarget.",

		voidalert_cmd = "void",
		voidalert_name = "Void Zone Alerts",
		voidalert_desc = "Warn on Lady Blaumeux casting Void Zone.",

		markbar = "Mark %d",
		mark_warn = "Mark %d!",
		mark_warn_5 = "Mark %d in 5 sec",
		marktrigger1 = "afflicted by Mark of Zeliek",
		marktrigger2 = "afflicted by Mark of Korth'azz",
		marktrigger3 = "afflicted by Mark of Blaumeux",
		marktrigger4 = "afflicted by Mark of Mograine",

		healeronerotate = "Healer 1 Rotate",
		healertworotate = "Healer 2 Rotate",
		healerthreerotate = "Healer 3 Rotate",

		healeronerotate_cmd = "healeronerotate",
		healeronerotate_name = "Healer 1 Alerts",
		healeronerotate_desc = "Sound for Healer 1 rotate",

		healertworotate_cmd = "healertworotate",
		healertworotate_name = "Healer 2 Alerts",
		healertworotate_desc = "Sound for Healer 2 rotate",

		healerthreerotate_cmd = "healerthreerotate",
		healerthreerotate_name = "Healer 3 Alerts",
		healerthreerotate_desc = "Sound for Healer 3 rotate",

		voidtrigger = "Your life is mine!",
		voidwarn = "Void Zone Incoming",
		voidbar = "Void Zone",

		meteortrigger = "Thane Korth'azz's Meteor hits ",
		meteortrigger2 = "I like my meat extra crispy!",
		meteorwarn = "Meteor!",
		meteorbar = "Meteor",

		wrathtrigger = "Sir Zeliek's Holy Wrath hits ",
		wrathtrigger2 = "I have no choice but to obey!",
		wrathwarn = "Holy Wrath!",
		wrathbar = "Holy Wrath",

		startwarn = "The Four Horsemen Engaged! Mark in 20 sec",

		shieldwallbar = "%s - Shield Wall",
		shieldwalltrigger = "(.*) gains Shield Wall.",
		shieldwall_warn = "%s - Shield Wall for 20 sec",
		shieldwall_warn_over = "%s - Shield Wall GONE!",

		proximity_cmd = "proximity",
		proximity_name = "Proximity Warning",
		proximity_desc = "Show Proximity Warning Frame",
	}
end)

local timer = {
	firstMark = 20,
	mark = 12,
	firstMeteor = 20,
	meteor = { 12, 15 },
	firstWrath = 20,
	wrath = { 10, 14 },
	firstVoid = 15,
	void = { 12, 15 },
	shieldwall = 20,
}
local icon = {
	mark = "Spell_Shadow_CurseOfAchimonde",
	meteor = "Spell_Fire_Fireball02",
	wrath = "Spell_Holy_Excorcism",
	void = "spell_shadow_antishadow",
	shieldwall = "Ability_Warrior_ShieldWall",
}
local syncName = {
	shieldwall = "HorsemenShieldWall" .. module.revision,
	mark = "HorsemenMark" .. module.revision,
	voidzonealert = "HorsemenDelayedVoidZone" .. module.revision,
	voidzonetimer = "HorsemenVoidZoneTimer" .. module.revision,
	wrathtimer = "HorsemenWrath" .. module.revision,
	meteortimer = "HorsemenMeteor" .. module.revision,
	healeronerotate = "HorsemenHealerOneRotate" .. module.revision,
	healertworotate = "HorsemenHealerTwoRotate" .. module.revision,
	healerthreerotate = "HorsemenHealerThreeRotate" .. module.revision,
}

local void_trigger = "Lady Blaumeux casts Void Zone"

local times = nil
local globalMarks = 0
local playerGroup = 0

local MOVE_SAFE_SPOT = "MOVE TO |cf75DE52fSAFE SPOT"
local MOVE_THANE = "MOVE TO |cff7b9a2fTHANE|r - STACK ON TANK"
local MOVE_MOGRAINE = "MOVE TO |cffb2422eMOGRAINE"

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "MarkEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "MarkEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "MarkEvent")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetChangedEvent")

	self.lastVoidZone = nil
	self.lastMeteor = nil
	self.lastWrath = nil

	self.shieldWallTimers = {}

	self.thaneHp = 100
	self.mograineHp = 100
	self.zeliekHp = 100
	self.blaumeuxHp = 100

	self:ThrottleSync(3, syncName.shieldwall)
	self:ThrottleSync(8, syncName.mark)
	self:ThrottleSync(8, syncName.healeronerotate)
	self:ThrottleSync(8, syncName.healertworotate)
	self:ThrottleSync(8, syncName.healerthreerotate)
	self:ThrottleSync(5, syncName.voidzonealert)
	self:ThrottleSync(5, syncName.voidzonetimer)
	self:ThrottleSync(5, syncName.wrathtimer)
	self:ThrottleSync(5, syncName.meteortimer)

	self:UpdateBossStatusFrame()
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self.marks = 0
	self.deaths = 0

	globalMarks = 0

	times = {}
end

function module:OnEngage()
	self.shieldWallTimers = {}
	self.marks = 0
	self.previousTarget = ""

	-- the initial timers are longer so set lastXXX in the future to accommodate for this
	self.lastVoidZone = GetTime() + (timer.firstVoid - timer.void[1])
	self.lastMeteor = GetTime() + (timer.firstMeteor - timer.meteor[1])
	self.lastWrath = GetTime() + (timer.firstWrath - timer.wrath[1])

	globalMarks = 0

	if self.db.profile.mark then
		self:Message(L["startwarn"], "Attention")
		self:Bar(string.format(L["markbar"], self.marks + 1), timer.firstMark, icon.mark, true, "White")
		self:DelayedMessage(timer.firstMark - 5, string.format(L["mark_warn_5"], self.marks + 1), "Urgent")
	end

	if self.db.profile.alwaysshowmeteor then
		self:Bar(L["meteorbar"], timer.firstMeteor, icon.meteor, true, "Red")
	end

	for i = 0, GetNumRaidMembers() do
		if GetRaidRosterInfo(i) then
			local n, _, group = GetRaidRosterInfo(i);
			if n == UnitName('player') then
				playerGroup = group
			end
		end
	end

	if UnitName("target") or UnitName("targettarget") then
		self:TargetChanged()
	end

	self.thaneHp = 100
	self.mograineHp = 100
	self.zeliekHp = 100
	self.blaumeuxHp = 100

	self.thaneDied = false
	self.mograineDied = false
	self.zeliekDied = false
	self.blaumeuxDied = false

	if self.db.profile.proximity then
		self:Proximity()
	end

	if self.db.profile.hpframe then
		self:ScheduleRepeatingEvent("CheckHps", self.CheckHps, 1, self)
	end
end

function module:OnDisengage()
	self.thaneHp = 100
	self.mograineHp = 100
	self.zeliekHp = 100
	self.blaumeuxHp = 100

	self.thaneDied = false
	self.mograineDied = false
	self.zeliekDied = false
	self.blaumeuxDied = false

	self.shieldWallTimers = {}

	self:RemoveProximity()

	self:CancelScheduledEvent("CheckHps")

	if self.bossStatusFrame then
		self.bossStatusFrame:Hide()
	end
end

function module:UpdateBossStatusFrame()
	if not self.db.profile.hpframe then
		return
	end

	-- create frame if needed
	if not self.bossStatusFrame then
		self.bossStatusFrame = CreateFrame("Frame", "HorsemenBossStatusFrame", UIParent)
		self.bossStatusFrame.module = self
		self.bossStatusFrame:SetWidth(150)
		self.bossStatusFrame:SetHeight(70)
		self.bossStatusFrame:ClearAllPoints()
		local s = self.bossStatusFrame:GetEffectiveScale()
		self.bossStatusFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (self.db.profile.bossframeposx or 100) / s, (self.db.profile.bossframeposy or 500) / s)
		self.bossStatusFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		})
		self.bossStatusFrame:SetBackdropColor(0, 0, 0, 1)

		-- allow dragging
		self.bossStatusFrame:SetMovable(true)
		self.bossStatusFrame:EnableMouse(true)
		self.bossStatusFrame:RegisterForDrag("LeftButton")
		self.bossStatusFrame:SetScript("OnDragStart", function()
			this:StartMoving()
		end)
		self.bossStatusFrame:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()

			local scale = this:GetEffectiveScale()
			this.module.db.profile.bossframeposx = this:GetLeft() * scale
			this.module.db.profile.bossframeposy = this:GetTop() * scale
		end)

		local font = "Fonts\\FRIZQT__.TTF"
		local fontSize = 9

		self.bossStatusFrame.thane = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.thane:SetFontObject(GameFontNormal)
		self.bossStatusFrame.thane:SetPoint("TOPLEFT", self.bossStatusFrame, "TOPLEFT", 10, -10)
		self.bossStatusFrame.thane:SetText("Thane:")
		self.bossStatusFrame.thane:SetFont(font, fontSize)

		self.bossStatusFrame.thaneHp = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.thaneHp:SetFontObject(GameFontNormal)
		self.bossStatusFrame.thaneHp:SetPoint("TOP", self.bossStatusFrame, "TOP", 0, -10)
		self.bossStatusFrame.thaneHp:SetJustifyH("CENTER")
		self.bossStatusFrame.thaneHp:SetFont(font, fontSize)

		self.bossStatusFrame.thaneShieldWall = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.thaneShieldWall:SetFontObject(GameFontNormal)
		self.bossStatusFrame.thaneShieldWall:SetPoint("TOPLEFT", self.bossStatusFrame.thaneHp, "TOPRIGHT", 5, 0)
		self.bossStatusFrame.thaneShieldWall:SetJustifyH("RIGHT")
		self.bossStatusFrame.thaneShieldWall:SetTextColor(1, 0, 0)
		self.bossStatusFrame.thaneShieldWall:SetFont(font, fontSize)

		self.bossStatusFrame.mograine = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.mograine:SetFontObject(GameFontNormal)
		self.bossStatusFrame.mograine:SetPoint("TOPLEFT", self.bossStatusFrame.thane, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.mograine:SetText("Mograine:")
		self.bossStatusFrame.mograine:SetFont(font, fontSize)

		self.bossStatusFrame.mograineHp = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.mograineHp:SetFontObject(GameFontNormal)
		self.bossStatusFrame.mograineHp:SetPoint("TOPLEFT", self.bossStatusFrame.thaneHp, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.mograineHp:SetJustifyH("CENTER")
		self.bossStatusFrame.mograineHp:SetFont(font, fontSize)

		self.bossStatusFrame.mograineShieldWall = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.mograineShieldWall:SetFontObject(GameFontNormal)
		self.bossStatusFrame.mograineShieldWall:SetPoint("TOPLEFT", self.bossStatusFrame.mograineHp, "TOPRIGHT", 5, 0)
		self.bossStatusFrame.mograineShieldWall:SetJustifyH("RIGHT")
		self.bossStatusFrame.mograineShieldWall:SetTextColor(1, 0, 0)
		self.bossStatusFrame.mograineShieldWall:SetFont(font, fontSize)

		self.bossStatusFrame.blaumeux = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.blaumeux:SetFontObject(GameFontNormal)
		self.bossStatusFrame.blaumeux:SetPoint("TOPLEFT", self.bossStatusFrame.mograine, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.blaumeux:SetText("Blaumeux:")
		self.bossStatusFrame.blaumeux:SetFont(font, fontSize)

		self.bossStatusFrame.blaumeuxHp = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.blaumeuxHp:SetFontObject(GameFontNormal)
		self.bossStatusFrame.blaumeuxHp:SetPoint("TOPLEFT", self.bossStatusFrame.mograineHp, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.blaumeuxHp:SetJustifyH("CENTER")
		self.bossStatusFrame.blaumeuxHp:SetFont(font, fontSize)

		self.bossStatusFrame.blaumeuxShieldWall = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.blaumeuxShieldWall:SetFontObject(GameFontNormal)
		self.bossStatusFrame.blaumeuxShieldWall:SetPoint("TOPLEFT", self.bossStatusFrame.blaumeuxHp, "TOPRIGHT", 5, 0)
		self.bossStatusFrame.blaumeuxShieldWall:SetJustifyH("RIGHT")
		self.bossStatusFrame.blaumeuxShieldWall:SetTextColor(1, 0, 0)
		self.bossStatusFrame.blaumeuxShieldWall:SetFont(font, fontSize)

		self.bossStatusFrame.zeliek = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.zeliek:SetFontObject(GameFontNormal)
		self.bossStatusFrame.zeliek:SetPoint("TOPLEFT", self.bossStatusFrame.blaumeux, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.zeliek:SetText("Zeliek:")
		self.bossStatusFrame.zeliek:SetFont(font, fontSize)

		self.bossStatusFrame.zeliekHp = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.zeliekHp:SetFontObject(GameFontNormal)
		self.bossStatusFrame.zeliekHp:SetPoint("TOPLEFT", self.bossStatusFrame.blaumeuxHp, "BOTTOMLEFT", 0, -5)
		self.bossStatusFrame.zeliekHp:SetJustifyH("CENTER")
		self.bossStatusFrame.zeliekHp:SetFont(font, fontSize)

		self.bossStatusFrame.zeliekShieldWall = self.bossStatusFrame:CreateFontString(nil, "ARTWORK")
		self.bossStatusFrame.zeliekShieldWall:SetFontObject(GameFontNormal)
		self.bossStatusFrame.zeliekShieldWall:SetPoint("TOPLEFT", self.bossStatusFrame.zeliekHp, "TOPRIGHT", 5, 0)
		self.bossStatusFrame.zeliekShieldWall:SetJustifyH("RIGHT")
		self.bossStatusFrame.zeliekShieldWall:SetTextColor(1, 0, 0)
		self.bossStatusFrame.zeliekShieldWall:SetFont(font, fontSize)
	end
	self.bossStatusFrame:Show()

	self.bossStatusFrame.thaneHp:SetText(string.format("%d%%", self.thaneHp))
	self.bossStatusFrame.mograineHp:SetText(string.format("%d%%", self.mograineHp))
	self.bossStatusFrame.blaumeuxHp:SetText(string.format("%d%%", self.blaumeuxHp))
	self.bossStatusFrame.zeliekHp:SetText(string.format("%d%%", self.zeliekHp))

	self.bossStatusFrame.zeliekShieldWall:SetText("")
	self.bossStatusFrame.blaumeuxShieldWall:SetText("")
	self.bossStatusFrame.mograineShieldWall:SetText("")
	self.bossStatusFrame.thaneShieldWall:SetText("")

	-- check for shield walls
	local now = GetTime()
	for mob, time in pairs(self.shieldWallTimers) do
		if mob == thane then
			if now < time + timer.shieldwall then
				self.bossStatusFrame.thaneShieldWall:SetText(string.format("SWall: %.0fs", time + timer.shieldwall - now))
			end
		elseif mob == mograine then
			if now < time + timer.shieldwall then
				self.bossStatusFrame.mograineShieldWall:SetText(string.format("SWall: %.0fs", time + timer.shieldwall - now))
			end
		elseif mob == blaumeux then
			if now < time + timer.shieldwall then
				self.bossStatusFrame.blaumeuxShieldWall:SetText(string.format("SWall: %.0fs", time + timer.shieldwall - now))
			end
		elseif mob == zeliek then
			if now < time + timer.shieldwall then
				self.bossStatusFrame.zeliekShieldWall:SetText(string.format("SWall: %.0fs", time + timer.shieldwall - now))
			end
		end
	end
end

function module:CheckHps()
	local thaneHp, mograineHp, zeliekHp, blaumeuxHp

	-- check if dead
	if self.thaneDied then
		thaneHp = 0
	end
	if self.mograineDied then
		mograineHp = 0
	end
	if self.zeliekDied then
		zeliekHp = 0
	end
	if self.blaumeuxDied then
		blaumeuxHp = 0
	end

	for i = 1, GetNumRaidMembers() do
		local targetString = "Raid" .. i .. "Target"
		local targetName = UnitName(targetString)
		if targetName == thane and not thaneHp then
			thaneHp = math.ceil((UnitHealth(targetString) / UnitHealthMax(targetString)) * 100)
		elseif targetName == mograine and not mograineHp then
			mograineHp = math.ceil((UnitHealth(targetString) / UnitHealthMax(targetString)) * 100)
		elseif targetName == zeliek and not zeliekHp then
			zeliekHp = math.ceil((UnitHealth(targetString) / UnitHealthMax(targetString)) * 100)
		elseif targetName == blaumeux and not blaumeuxHp then
			blaumeuxHp = math.ceil((UnitHealth(targetString) / UnitHealthMax(targetString)) * 100)
		end

		if thaneHp and mograineHp and zeliekHp and blaumeuxHp then
			break
		end
	end

	if thaneHp then
		self.thaneHp = thaneHp
	end

	if mograineHp then
		self.mograineHp = mograineHp
	end

	if zeliekHp then
		self.zeliekHp = zeliekHp
	end

	if blaumeuxHp then
		self.blaumeuxHp = blaumeuxHp
	end

	self:UpdateBossStatusFrame()
end

function module:MarkEvent(msg)
	if string.find(msg, L["marktrigger1"]) or string.find(msg, L["marktrigger2"]) or string.find(msg, L["marktrigger3"]) or string.find(msg, L["marktrigger4"]) then
		self:Sync(syncName.mark)
	end
end

function module:TargetChangedEvent(msg)
	if not self:IsEventScheduled("HorsemenTargetChanged") then
		self:ScheduleEvent("HorsemenTargetChanged", self.TargetChanged, 0.1, self)
	end
end

function module:TargetChanged()
	local target = UnitName("target")
	local targettarget = UnitName("targettarget")
	if self.lastVoidZone and self.db.profile.voidtimer and self.previousTarget ~= blaumeux then
		if target == blaumeux or targettarget == blaumeux then
			local elapsed = GetTime() - self.lastVoidZone
			self:IntervalBar(L["voidbar"], timer.void[1] - elapsed, timer.void[2] - elapsed, icon.void, true, "Black")
			self.previousTarget = blaumeux
			return
		end
	end

	if self.db.profile.alwaysshowmeteor ~= true then
		if self.lastMeteor and self.db.profile.meteortimer and self.previousTarget ~= thane then
			if target == thane or targettarget == thane then
				local elapsed = GetTime() - self.lastMeteor
				self:IntervalBar(L["meteorbar"], timer.meteor[1] - elapsed, timer.meteor[2] - elapsed, icon.meteor, true, "Red")
				self.previousTarget = thane
				return
			end
		end
	end

	if self.lastWrath and self.db.profile.wrathtimer and self.previousTarget ~= zeliek then
		if target == zeliek or targettarget == zeliek then
			local elapsed = GetTime() - self.lastWrath
			self:IntervalBar(L["wrathbar"], timer.wrath[1] - elapsed, timer.wrath[2] - elapsed, icon.wrath, true, "Yellow")
			self.previousTarget = zeliek
			return
		end
	end
end

function module:VoidZoneEvent()
	if self.db.profile.voidalert then
		self:ScheduleEvent("DelayedVoidZoneEvent", self.DelayedVoidZoneEvent, 0.2, self)
		self:WarningSign(icon.void, 3)
	end
	if self.db.profile.voidtimer then
		if UnitName("target") == blaumeux or UnitName("targettarget") == blaumeux then
			self:IntervalBar(L["voidbar"], timer.void[1], timer.void[2], icon.void, true, "Black")
		end
	end
end

function module:DelayedVoidZoneEvent()
	local target = self:CheckTarget()

	if target then
		self:Icon(target, 3)
		if target == UnitName("player") then
			self:Message("Void Zone on YOU !!!", "Important")
			self:TriggerEvent("BigWigs_Sound", "VoidZoneMove")
			SendChatMessage("Void Zone On Me !", "SAY")
		else
			self:Message("Void Zone on " .. target .. " !!!", "Important")
		end
	end
end

function module:CheckTarget()
	if UnitName("target") == blaumeux then
		return UnitName("targettarget")
	else
		for i = 1, GetNumRaidMembers() do
			if UnitName("Raid" .. i .. "target") == blaumeux then
				return UnitName("Raid" .. i .. "targettarget")
			end
		end
	end
	return nil
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	local _, _, mob = string.find(msg, L["shieldwalltrigger"])
	if mob then
		self.shieldWallTimers[mob] = GetTime()
		self:Sync(syncName.shieldwall .. " " .. mob)
	end
end

function module:CHAT_MSG_MONSTER_SAY(msg)
	if string.find(msg, L["voidtrigger"]) then
		self.lastVoidZone = GetTime()
		self:Sync(syncName.voidzonealert)
	elseif string.find(msg, L["meteortrigger2"]) then
		self.lastMeteor = GetTime()
		self:Sync(syncName.meteortimer)
	elseif string.find(msg, L["wrathtrigger2"]) then
		self.lastWrath = GetTime()
		self:Sync(syncName.wrathtimer)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	local thaneDied = string.find(msg, string.format(UNITDIESOTHER, thane))
	local mograineDied = string.find(msg, string.format(UNITDIESOTHER, mograine))
	local zeliekDied = string.find(msg, string.format(UNITDIESOTHER, zeliek))
	local blaumeuxDied = string.find(msg, string.format(UNITDIESOTHER, blaumeux))

	if thaneDied then
		self.thaneDied = true
	end

	if mograineDied then
		self.mograineDied = true
	end

	if zeliekDied then
		self.zeliekDied = true
	end

	if blaumeuxDied then
		self.blaumeuxDied = true
	end

	if thaneDied or mograineDied or zeliekDied or blaumeuxDied then
		self.deaths = self.deaths + 1
		if self.deaths == 4 then
			self:SendBossDeathSync()
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mark then
		self:Mark()
	elseif sync == syncName.meteortimer then
		self:Meteor()
	elseif sync == syncName.wrathtimer then
		self:Wrath()
	elseif sync == syncName.voidzonealert or sync == syncName.voidzonetimer then
		self:VoidZoneEvent()
	elseif sync == syncName.shieldwall and rest then
		self:Shieldwall(rest)
	elseif sync == syncName.healeronerotate then
		self:HealerOne()
	elseif sync == syncName.healertworotate then
		self:HealerTwo()
	elseif sync == syncName.healerthreerotate then
		self:HealerThree()
	end
end

local function horsemenIsRL()
	if not UnitInRaid('player') then
		return false
	end
	for i = 0, GetNumRaidMembers() do
		if GetRaidRosterInfo(i) then
			local n, r = GetRaidRosterInfo(i);
			if n == UnitName('player') and r == 2 then
				return true
			end
		end
	end
	return false
end

function module:Mark()
	self:RemoveBar(string.format(L["markbar"], self.marks))
	self.marks = self.marks + 1

	globalMarks = globalMarks + 1

	-- loop back around after 12 marks
	if globalMarks >= 13 then
		globalMarks = 1
		self.marks = 1
	end

	local healerIndex = 0
	if globalMarks == 1 or globalMarks == 4 or globalMarks == 7 or globalMarks == 10 then
		healerIndex = 1
	elseif globalMarks == 2 or globalMarks == 5 or globalMarks == 8 or globalMarks == 11 then
		healerIndex = 2
	elseif globalMarks == 3 or globalMarks == 6 or globalMarks == 9 or globalMarks == 12 then
		healerIndex = 3
	end

	if horsemenIsRL() then
		SendChatMessage("HEALER [" .. healerIndex .. "] ROTATE", "RAID", DEFAULT_CHAT_FRAME.editBox.languageID);
	end

	if healerIndex == 1 then
		self:DelayedSync(1, syncName.healeronerotate) -- let mark sound play first
	elseif healerIndex == 2 then
		self:DelayedSync(1, syncName.healertworotate)
	elseif healerIndex == 3 then
		self:DelayedSync(1, syncName.healerthreerotate)
	end

	if self.db.profile.mark then
		self:Message(string.format(L["mark_warn"], self.marks), "Important")
		local nextMark = self.marks + 1

		if nextMark >= 13 then
			nextMark = 1
		end

		self:Bar(string.format(L["markbar"], nextMark), timer.mark, icon.mark)
		self:DelayedMessage(timer.mark - 5, string.format(L["mark_warn_5"], nextMark), "Urgent", nil, false)
	end

	if self.db.profile.marksounds then
		local markSound = "" -- For some reason naming sounds Mark1, Mark2, Mark3 and concatenating doesn't work
		if self.marks == 1 then
			markSound = "MarkOne"
		elseif self.marks == 2 then
			markSound = "MarkTwo"
		elseif self.marks == 3 then
			markSound = "MarkThree"
		elseif self.marks == 4 then
			markSound = "MarkFour"
		elseif self.marks == 5 then
			markSound = "MarkFive"
		elseif self.marks == 6 then
			markSound = "MarkSix"
		elseif self.marks == 7 then
			markSound = "MarkSeven"
		elseif self.marks == 8 then
			markSound = "MarkEight"
		elseif self.marks == 9 then
			markSound = "MarkNine"
		elseif self.marks == 10 then
			markSound = "MarkTen"
		elseif self.marks == 11 then
			markSound = "MarkEleven"
		elseif self.marks == 12 then
			markSound = "MarkTwelve"
		end
		self:TriggerEvent("BigWigs_Sound", markSound)
	end
end

function module:HealerOne()
	if self.db.profile.healeronerotate then
		self:Message(L["healeronerotate"], "Personal", nil, "HealerOneRotate")
	end
end

function module:HealerTwo()
	if self.db.profile.healertworotate then
		self:Message(L["healertworotate"], "Personal", nil, "HealerTwoRotate")
	end
end

function module:HealerThree()
	if self.db.profile.healerthreerotate then
		self:Message(L["healerthreerotate"], "Personal", nil, "HealerThreeRotate")
	end
end

function module:Meteor()
	if self.db.profile.meteortimer then
		-- show meteor timer only if Thane is target or targettarget
		if self.db.profile.alwaysshowmeteor or UnitName("target") == thane or UnitName("targettarget") == thane then
			self:IntervalBar(L["meteorbar"], timer.meteor[1], timer.meteor[2], icon.meteor, true, "Red")
		end
	end
end

function module:Wrath()
	if self.db.profile.wrathtimer then
		-- show holy wrath timer only if Thane is target or targettarget
		if UnitName("target") == zeliek or UnitName("targettarget") == zeliek then
			self:IntervalBar(L["wrathbar"], timer.wrath[1], timer.wrath[2], icon.wrath, true, "Yellow")
		end
	end
end

function module:Shieldwall(mob)
	if mob and self.db.profile.shieldwall then
		self:Message(string.format(L["shieldwall_warn"], mob), "Attention")
		self:Bar(string.format(L["shieldwallbar"], mob), timer.shieldwall, icon.shieldwall, true, "Blue")
		self:DelayedMessage(timer.shieldwall, string.format(L["shieldwall_warn_over"], mob), "Positive")
	end
end

function string:split(delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(self, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(self, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub(self, from))
	return result
end
