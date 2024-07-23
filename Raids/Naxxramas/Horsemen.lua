local module, L = BigWigs:ModuleDeclaration("The Four Horsemen", "Naxxramas")
local thane = AceLibrary("Babble-Boss-2.2")["Thane Korth'azz"]
local mograine = AceLibrary("Babble-Boss-2.2")["Highlord Mograine"]
local zeliek = AceLibrary("Babble-Boss-2.2")["Sir Zeliek"]
local blaumeux = AceLibrary("Babble-Boss-2.2")["Lady Blaumeux"]

module.revision = 20006
module.enabletrigger = { thane, mograine, zeliek, blaumeux }
module.toggleoptions = { "mark", "marksounds", "shieldwall", -1,
                         "meteortimer", "voidtimer", "wrathtimer", "voidalert", -1,
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

		meteortimer_cmd = "meteortimer",
		meteortimer_name = "Meteor Window Timer",
		meteortimer_desc = "Timer till next Meteor (every 12-15 sec).",

		voidtimer_cmd = "voidtimer",
		voidtimer_name = "Void Zone Timer",
		voidtimer_desc = "Timer till next Void Zone (every 12 sec).",

		wrathtimer_cmd = "wrath",
		wrathtimer_name = "Holy Wrath Window Timer",
		wrathtimer_desc = "Timer till next holy wrath (every 10-14 sec).",

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
	targetchanged = "HorsemenTargetChanged" .. module.revision,
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

	self:ThrottleSync(3, syncName.shieldwall)
	self:ThrottleSync(8, syncName.mark)
	self:ThrottleSync(8, syncName.healeronerotate)
	self:ThrottleSync(8, syncName.healertworotate)
	self:ThrottleSync(8, syncName.healerthreerotate)
	self:ThrottleSync(5, syncName.voidzonealert)
	self:ThrottleSync(5, syncName.voidzonetimer)
	self:ThrottleSync(5, syncName.wrathtimer)
	self:ThrottleSync(5, syncName.meteortimer)
	self:ThrottleSync(.2, syncName.targetchanged)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

	self.marks = 0
	self.deaths = 0

	globalMarks = 0

	times = {}
end

local fhAlert = CreateFrame("Frame", "fhAlert");

fhAlert:RegisterEvent("CHAT_MSG_ADDON")

fhAlert:SetPoint("CENTER", UIParent, "CENTER", 0, -100);

fhAlert.text = fhAlert:CreateFontString("$parentText", "OVERLAY");
fhAlert.text:Hide()
fhAlert.text:SetWidth(800);
fhAlert.text:SetHeight(108);
fhAlert.text:SetFont(STANDARD_TEXT_FONT, 50, "OUTLINE");
fhAlert.text:SetPoint("CENTER", UIParent, 0, 100);
fhAlert.text:SetJustifyV("MIDDLE");
fhAlert.text:SetJustifyH("CENTER");

local fh_alert = CreateFrame('Frame')
fh_alert:Hide()
function fh_alert_marks(message)
	fhAlert.text:SetText(message);
	fh_alert:Show()
end

fhAlert.healerIndex = 0

fhAlert:SetScript("OnEvent", function()
	if event then
		if event == 'CHAT_MSG_ADDON' and arg1 == "TWABW" then
			local data = string.split(arg2, ' ')
			for _, d in data do
				for healerIndex = 1, 3 do
					if string.find(d, '[' .. healerIndex .. ']' .. UnitName('player'), 1, true) then
						fhAlert.healerIndex = healerIndex
						DEFAULT_CHAT_FRAME:AddMessage("4HM Healer index set to " .. healerIndex)
						break
					end
				end
			end
		end
	end
end)

function module:OnEngage()
	self.marks = 0

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
end

fh_alert:SetScript("OnShow", function()
	this.startTime = GetTime()
	fhAlert.text:Show()
end)
fh_alert:SetScript("OnHide", function()
	fhAlert.text:Hide()
end)
fh_alert:SetScript("OnUpdate", function()
	local plus = 5
	local gt = GetTime() * 1000
	local st = (this.startTime + plus) * 1000
	if gt >= st then
		fh_alert:Hide()
	end
end)

function module:OnDisengage()
	self:RemoveProximity()
end

function module:MarkEvent(msg)
	if string.find(msg, L["marktrigger1"]) or string.find(msg, L["marktrigger2"]) or string.find(msg, L["marktrigger3"]) or string.find(msg, L["marktrigger4"]) then
		self:Sync(syncName.mark)
	end
end

function module:TargetChangedEvent(msg)
	self:Sync(syncName.targetchanged)
end

function module:TargetChanged()
	local target = UnitName("target")
	local targettarget = UnitName("targettarget")
	if self.lastVoidZone and self.db.profile.voidtimer then
		if target == blaumeux or targettarget == blaumeux then
			local elapsed = GetTime() - self.lastVoidZone
			self:IntervalBar(L["voidbar"], timer.void[1] - elapsed, timer.void[2] - elapsed, icon.void, true, "Black")
		end
	end
	if self.lastMeteor and self.db.profile.meteortimer then
		if target == thane or targettarget == thane then
			local elapsed = GetTime() - self.lastMeteor
			self:IntervalBar(L["meteorbar"], timer.meteor[1] - elapsed, timer.meteor[2] - elapsed, icon.meteor, true, "Red")
		end
	end
	if self.lastWrath and self.db.profile.wrathtimer then
		if target == zeliek or targettarget == zeliek then
			local elapsed = GetTime() - self.lastWrath
			self:IntervalBar(L["wrathbar"], timer.wrath[1] - elapsed, timer.wrath[2] - elapsed, icon.wrath, true, "Yellow")
		end
	end

	if target == zeliek or targettarget == zeliek and self.db.profile.proximity then
		self:Proximity()
	else
		self:RemoveProximity()
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
	if msg == string.format(UNITDIESOTHER, thane) or
			msg == string.format(UNITDIESOTHER, zeliek) or
			msg == string.format(UNITDIESOTHER, mograine) or
			msg == string.format(UNITDIESOTHER, blaumeux) then

		self.deaths = self.deaths + 1
		if self.deaths == 4 then
			self:SendBossDeathSync()
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.targetchanged then
		self:TargetChanged()
	elseif sync == syncName.mark then
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

function horsemenIsRL()
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
		if UnitName("target") == thane or UnitName("targettarget") == thane then
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
