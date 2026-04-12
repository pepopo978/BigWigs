
local module, L = BigWigs:ModuleDeclaration("Archdruid Kronn", "Timbermaw Hold")

module.revision = 30002
module.enabletrigger = {
	"Archdruid Kronn",
	"Dreamform of Kronn",
}
module.toggleoptions = {"hpframe", "dreamfever", "bodycasts", "bosskill"}
module.zonename = "Timbermaw Hold"

module.defaultDB = {
	hpframe = true,
	dreamfever = true,
	-- hpframeposx / hpframeposy computed in UpdateHpFrame on first frame
	-- creation so GetScreenWidth/Height return real values (they can be
	-- unreliable at file-load time).
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Kronn",

	hpframe_cmd = "hpframe",
	hpframe_name = "HP Frame",
	hpframe_desc = "Shows a frame with the HP of Archdruid Kronn and Dreamform of Kronn",

	kronn_label = "Kronn HP",
	dream_label = "Dream HP",

	kronn_dying = "DYING",
	dream_waking = "WAKING",

	trigger_engage = "You will not awaken him.",

	dreamfever_cmd = "dreamfever",
	dreamfever_name = "Dream Fever Alert",
	dreamfever_desc = "Warn when someone is afflicted by Dream Fever and mark them",

	trigger_feverYou = "You are afflicted by Dream Fever",
	trigger_feverOther = "(.+) is afflicted by Dream Fever",
	trigger_feverFadeYou = "Dream Fever fades from you",
	trigger_feverFadeOther = "Dream Fever fades from (.+)%.",

	msg_feverYou = "DREAM FEVER ON YOU - GET AWAY FROM OTHERS!",
	msg_feverOther = "Dream Fever on %s - get away from them!",

	bodycasts_cmd = "bodycasts",
	bodycasts_name = "Body Cast Bars",
	bodycasts_desc = "Show 10s cast bars for Dreamform's Return to Body and Archdruid Kronn's Reform Body",

	trigger_returnBody = "Dreamform of Kronn begins to cast Return to Body%.",
	trigger_reformBody = "Archdruid Kronn begins to cast Reform Body%.",
	bar_returnBody = "Return to Body",
	bar_reformBody = "Reform Body",
} end )

local realKronn = "Archdruid Kronn"
local dreamKronn = "Dreamform of Kronn"

local icon = {
	fever = "Spell_Nature_NullifyDisease",
	returnBody = "Spell_Nature_Sleep",
	reformBody = "Spell_Shadow_UnholyStrength",
}

local timer = {
	bodyCast = 10,
}

local syncName = {
	kronnHp = "KronnHp"..module.revision,
	dreamHp = "KronnDreamHp"..module.revision,
	feverGain = "KronnFeverGain"..module.revision,
	feverFade = "KronnFeverFade"..module.revision,
	returnBody = "KronnReturnBody"..module.revision,
	reformBody = "KronnReformBody"..module.revision,
}

local feverGainPattern = "^"..syncName.feverGain.."(.+)"
local feverFadePattern = "^"..syncName.feverFade.."(.+)"

function module:OnSetup()
	self.kronnHp = nil
	self.dreamHp = nil
	self.victorySent = nil
	self.kronnDying = nil
	self.dreamWaking = nil
	self.feverTargets = {}
end

function module:OnEnable()
	self:ThrottleSync(1, syncName.kronnHp)
	self:ThrottleSync(1, syncName.dreamHp)
	self:ThrottleSync(5, syncName.returnBody)
	self:ThrottleSync(5, syncName.reformBody)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CastEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "FadeEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "FadeEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FadeEvent")
end

function module:CastEvent(msg)
	if string.find(msg, L["trigger_returnBody"]) then
		self:Sync(syncName.returnBody)
	elseif string.find(msg, L["trigger_reformBody"]) then
		self:Sync(syncName.reformBody)
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["trigger_engage"]) then
		self:SendEngageSync()
	end
end

function module:OnEngage()
	self.kronnHp = nil
	self.dreamHp = nil
	self.victorySent = nil
	self.kronnDying = nil
	self.dreamWaking = nil
	self:CancelScheduledEvent("KronnDyingExpire")
	self:CancelScheduledEvent("KronnDreamWakeExpire")
	self.feverTargets = {}

	if self.db.profile.hpframe then
		self:UpdateHpFrame()
		self.hpFrame:Show()
	end
	self:ScheduleRepeatingEvent("KronnHpPoll", self.PollHp, 1, self)
end

function module:OnDisengage()
	self:CancelScheduledEvent("KronnHpPoll")
	self:CancelScheduledEvent("KronnDyingExpire")
	self:CancelScheduledEvent("KronnDreamWakeExpire")
	-- Framework auto-restores initialPlayerMarks on disengage (Core.lua:484-488)
	self.feverTargets = {}
	if self.hpFrame then
		self.hpFrame:Hide()
	end
end

function module:AfflictionEvent(msg)
	if string.find(msg, L["trigger_feverYou"]) then
		self:Sync(syncName.feverGain..UnitName("player"))
		return
	end
	local _, _, target = string.find(msg, L["trigger_feverOther"])
	if target then
		self:Sync(syncName.feverGain..target)
	end
end

function module:FadeEvent(msg)
	if string.find(msg, L["trigger_feverFadeYou"]) then
		self:Sync(syncName.feverFade..UnitName("player"))
		return
	end
	local _, _, target = string.find(msg, L["trigger_feverFadeOther"])
	if target then
		self:Sync(syncName.feverFade..target)
	end
end

function module:ZONE_CHANGED_NEW_AREA()
	if GetRealZoneText() ~= "Timbermaw Hold" and self.hpFrame then
		self.hpFrame:Hide()
	end
end

function module:PollHp()
	local foundKronn, foundDream = false, false
	for i = 1, GetNumRaidMembers() do
		local unit = "raid"..i.."target"
		local name = UnitName(unit)
		if name == realKronn then
			foundKronn = true
			-- Archdruid Kronn never actually dies; the fight ends when he
			-- becomes non-hostile.
			if not UnitIsEnemy("player", unit) then
				if self.engaged and not self.victorySent then
					self.victorySent = true
					self:SendBossDeathSync()
				end
			else
				local h, m = UnitHealth(unit), UnitHealthMax(unit)
				if h and m and m > 0 then
					local pct = math.floor((h / m) * 100)
					self.kronnHp = pct
					self:Sync(syncName.kronnHp.." "..pct)
				end
			end
		elseif name == dreamKronn then
			foundDream = true
			local h, m = UnitHealth(unit), UnitHealthMax(unit)
			if h and m and m > 0 then
				local pct = math.floor((h / m) * 100)
				self.dreamHp = pct
				self:Sync(syncName.dreamHp.." "..pct)
			end
		end
		if foundKronn and foundDream then break end
	end
end

function module:UpdateHpFrame()
	if not self.db.profile.hpframe then return end

	if not self.hpFrame then
		local f = CreateFrame("Frame", "BigWigsKronnHpFrame", UIParent)
		f.module = self
		local frameW, frameH = 200, 60
		f:SetWidth(frameW)
		f:SetHeight(frameH)
		local s = f:GetEffectiveScale()

		-- Default to screen center if no saved position.
		if not self.db.profile.hpframeposx or not self.db.profile.hpframeposy then
			self.db.profile.hpframeposx = UIParent:GetWidth() / 2
			self.db.profile.hpframeposy = UIParent:GetHeight() / 2
		end

		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
			self.db.profile.hpframeposx / s - frameW / 2,
			self.db.profile.hpframeposy / s + frameH / 2)
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		f:SetBackdropColor(0, 0, 0, 1)

		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", function() this:StartMoving() end)
		f:SetScript("OnDragStop", function()
			this:StopMovingOrSizing()
			local sc = this:GetEffectiveScale()
			this.module.db.profile.hpframeposx = this:GetLeft() * sc
			this.module.db.profile.hpframeposy = this:GetTop() * sc
		end)

		local font = "Fonts\\FRIZQT__.TTF"
		local fs = 12
		local midX = frameW / 2

		-- Left side: Kronn
		f.kronnLabel = f:CreateFontString(nil, "ARTWORK")
		f.kronnLabel:SetPoint("TOP", f, "TOPLEFT", midX / 2, -12)
		f.kronnLabel:SetFont(font, fs)
		f.kronnLabel:SetText(L["kronn_label"])
		f.kronnLabel:SetTextColor(1, 0.8, 0.3)

		f.kronnHpText = f:CreateFontString(nil, "ARTWORK")
		f.kronnHpText:SetPoint("TOP", f.kronnLabel, "BOTTOM", 0, -6)
		f.kronnHpText:SetFont(font, fs + 2)

		-- Right side: Dream
		f.dreamLabel = f:CreateFontString(nil, "ARTWORK")
		f.dreamLabel:SetPoint("TOP", f, "TOPLEFT", midX + midX / 2, -12)
		f.dreamLabel:SetFont(font, fs)
		f.dreamLabel:SetText(L["dream_label"])
		f.dreamLabel:SetTextColor(0.5, 0.5, 1)

		f.dreamHpText = f:CreateFontString(nil, "ARTWORK")
		f.dreamHpText:SetPoint("TOP", f.dreamLabel, "BOTTOM", 0, -6)
		f.dreamHpText:SetFont(font, fs + 2)

		self.hpFrame = f
	end

	-- Kronn: locked to DYING on Reform Body cast, otherwise show HP
	if self.kronnDying then
		self.hpFrame.kronnHpText:SetText(L["kronn_dying"])
		self.hpFrame.kronnHpText:SetTextColor(1, 0, 0)
	elseif self.kronnHp == nil then
		self.hpFrame.kronnHpText:SetText("--")
		self.hpFrame.kronnHpText:SetTextColor(0.7, 0.7, 0.7)
	else
		self.hpFrame.kronnHpText:SetText(self.kronnHp.."%")
		-- Green when low (dying), yellow mid, white high
		if self.kronnHp < 15 then
			self.hpFrame.kronnHpText:SetTextColor(0.3, 1, 0.3)
		elseif self.kronnHp < 35 then
			self.hpFrame.kronnHpText:SetTextColor(1, 1, 0)
		else
			self.hpFrame.kronnHpText:SetTextColor(1, 1, 1)
		end
	end

	-- Dream: locked to WAKING on Return to Body cast, otherwise show HP
	if self.dreamWaking then
		self.hpFrame.dreamHpText:SetText(L["dream_waking"])
		self.hpFrame.dreamHpText:SetTextColor(0.3, 1, 0.3)
	elseif self.dreamHp == nil then
		self.hpFrame.dreamHpText:SetText("--")
		self.hpFrame.dreamHpText:SetTextColor(0.7, 0.7, 0.7)
	else
		self.hpFrame.dreamHpText:SetText(self.dreamHp.."%")
		-- Green when high (filling), yellow mid, white low
		if self.dreamHp > 85 then
			self.hpFrame.dreamHpText:SetTextColor(0.3, 1, 0.3)
		elseif self.dreamHp > 65 then
			self.hpFrame.dreamHpText:SetTextColor(1, 1, 0)
		else
			self.hpFrame.dreamHpText:SetTextColor(1, 1, 1)
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.kronnHp and rest then
		local n = tonumber(rest)
		if n then
			self.kronnHp = n
			if self.db.profile.hpframe then
				self:UpdateHpFrame()
			end
		end
	elseif sync == syncName.dreamHp and rest then
		local n = tonumber(rest)
		if n then
			self.dreamHp = n
			if self.db.profile.hpframe then
				self:UpdateHpFrame()
			end
		end
	elseif sync == syncName.returnBody then
		self.dreamWaking = true
		self:ScheduleEvent("KronnDreamWakeExpire", function()
			module.dreamWaking = nil
			module:UpdateHpFrame()
		end, timer.bodyCast)
		if self.db.profile.hpframe then
			self:UpdateHpFrame()
		end
		if self.db.profile.bodycasts then
			self:RemoveBar(L["bar_returnBody"])
			self:Bar(L["bar_returnBody"], timer.bodyCast, icon.returnBody, true, "Green")
			self:Sound("Info")
		end
	elseif sync == syncName.reformBody then
		self.kronnDying = true
		self:ScheduleEvent("KronnDyingExpire", function()
			module.kronnDying = nil
			module:UpdateHpFrame()
		end, timer.bodyCast)
		if self.db.profile.hpframe then
			self:UpdateHpFrame()
		end
		if self.db.profile.bodycasts then
			self:RemoveBar(L["bar_reformBody"])
			self:Bar(L["bar_reformBody"], timer.bodyCast, icon.reformBody, true, "Red")
			self:Sound("Info")
		end
	elseif self.db.profile.dreamfever then
		local _, _, feverTarget = string.find(sync, feverGainPattern)
		if feverTarget then
			self:FeverGain(feverTarget)
		else
			local _, _, fadeTarget = string.find(sync, feverFadePattern)
			if fadeTarget then
				self:FeverFade(fadeTarget)
			end
		end
	end
end

function module:FeverGain(target)
	if self.feverTargets[target] then return end
	self.feverTargets[target] = true

	local mark = self:GetAvailableRaidMark()
	if mark then
		self:SetRaidTargetForPlayer(target, mark)
	end

	if target == UnitName("player") then
		self:Message(L["msg_feverYou"], "Personal", true, "Alarm")
		self:WarningSign(icon.fever, 3, true)
	else
		local nearby = false
		for i = 1, GetNumRaidMembers() do
			local unit = "raid"..i
			if UnitName(unit) == target then
				nearby = UnitIsVisible(unit) and CheckInteractDistance(unit, 2)
				break
			end
		end
		if nearby then
			self:Message(string.format(L["msg_feverOther"], target), "Urgent", false, "Alert")
			self:WarningSign(icon.fever, 3, true)
		end
	end
end

function module:FeverFade(target)
	if not self.feverTargets[target] then return end
	self.feverTargets[target] = nil
	self:RestorePreviousRaidTargetForPlayer(target)
end

-- Usage: /run local m=BigWigs:GetModule("Archdruid Kronn"); BigWigs:SetupModule("Archdruid Kronn"); m:Test();
function module:Test()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()

	if not self.db.profile.hpframe then
		self.db.profile.hpframe = true
	end
	self:UpdateHpFrame()
	self.hpFrame:Show()

	self:Message("Archdruid Kronn test started", "Positive")

	-- k = Kronn HP (counting down), d = Dream HP (counting up)
	-- cast flags trigger through CastEvent at k=0/d=100
	local steps = {
		{t = 1,  k = 95, d = 5  },
		{t = 3,  k = 80, d = 15 },
		{t = 5,  k = 65, d = 30 },
		{t = 7,  k = 50, d = 45 },
		{t = 9,  k = 40, d = 55 },
		{t = 11, k = 32, d = 65 },
		{t = 13, k = 20, d = 75 },
		{t = 15, k = 12, d = 85 },
		{t = 17, k = 5,  d = 92 },
		-- t=19: Kronn hits 0 -> Reform Body cast -> DYING for 10s
		{t = 19, k = 0,  d = 92 },
		-- t=21: HP updates continue while clamped (display stays DYING/WAKING)
		{t = 21, k = 0,  d = 95 },
		{t = 23, k = 0,  d = 98 },
		-- t=25: Dream hits 100 -> Return to Body cast -> WAKING for 10s
		{t = 25, k = 0,  d = 100},
		-- t=27-29: HP fluctuates while clamped — display should stay locked
		{t = 27, k = 3,  d = 97 },
		{t = 29, k = 0,  d = 100},
		-- t=31: 10s after Reform Body (t=19+10=29) — DYING expires, shows HP
		-- t=35: 10s after Return to Body (t=25+10=35) — WAKING expires, shows HP
		{t = 32, k = 5,  d = 90 },
		{t = 36, k = 2,  d = 95 },
	}
	for i, e in ipairs(steps) do
		local k, d = e.k, e.d
		self:ScheduleEvent("KronnTestHp"..i, function()
			module.kronnHp = k
			module.dreamHp = d
			if k <= 0 then
				module:CastEvent("Archdruid Kronn begins to cast Reform Body.")
			end
			if d >= 100 then
				module:CastEvent("Dreamform of Kronn begins to cast Return to Body.")
			end
			module:UpdateHpFrame()
		end, e.t)
	end

	self:ScheduleEvent("KronnTestEnd", function()
		module:Message("Archdruid Kronn test complete", "Positive")
	end, 39)
	return true
end

-- Picks a random raid member (falls back to the player if solo) and spoofs
-- the real Dream Fever combat-log strings through AfflictionEvent / FadeEvent
-- so the full parse -> sync -> handler chain is exercised. Requires the
-- player to be in a raid for Sync's local echo to reach BigWigs_RecvSync.
-- Usage: /run local m=BigWigs:GetModule("Archdruid Kronn"); BigWigs:SetupModule("Archdruid Kronn"); m:TestFever();
function module:TestFever()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()

	local target
	local n = GetNumRaidMembers()
	if n > 0 then
		target = UnitName("raid"..math.random(1, n))
	end
	if not target then target = UnitName("player") end

	self:Message("Dream Fever test target: "..target, "Positive")

	local isSelf = target == UnitName("player")
	local gainMsg = isSelf
		and "You are afflicted by Dream Fever (1)."
		or (target.." is afflicted by Dream Fever (1).")
	local fadeMsg = isSelf
		and "Dream Fever fades from you."
		or ("Dream Fever fades from "..target..".")

	self:ScheduleEvent("KronnTestFeverGain", self.AfflictionEvent, 2,  self, gainMsg)
	self:ScheduleEvent("KronnTestFeverFade", self.FadeEvent,       12, self, fadeMsg)
	self:ScheduleEvent("KronnTestFeverEnd", function()
		module:Message("Dream Fever test complete", "Positive")
	end, 14)
	return true
end

-- Rapid-fire multi-target fever test. Picks up to 3 distinct raid members and
-- hits them with fever 0.3s apart (simulating a real AoE application), then
-- duplicates the first target's sync to exercise the feverTargets dedupe guard.
-- Fades are staggered. Verifies: per-player throttle, dedupe, multi-mark, and
-- mark restoration.
-- Usage: /run local m=BigWigs:GetModule("Archdruid Kronn"); BigWigs:SetupModule("Archdruid Kronn"); m:TestFeverMulti();
function module:TestFeverMulti()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()

	-- Gather up to 3 unique targets
	local targets = {}
	local seen = {}
	local n = GetNumRaidMembers()
	for i = 1, n do
		local name = UnitName("raid"..i)
		if name and not seen[name] then
			seen[name] = true
			table.insert(targets, name)
			if table.getn(targets) >= 3 then break end
		end
	end
	if table.getn(targets) == 0 then
		targets[1] = UnitName("player")
	end

	self:Message("Fever multi-test: "..table.concat(targets, ", "), "Positive")

	local delay = 2
	for i, target in ipairs(targets) do
		local isSelf = target == UnitName("player")
		local gainMsg = isSelf
			and "You are afflicted by Dream Fever (1)."
			or (target.." is afflicted by Dream Fever (1).")

		-- Stagger gains 0.3s apart
		self:ScheduleEvent("KronnTestMFGain"..i, self.AfflictionEvent, delay + (i - 1) * 0.3, self, gainMsg)
	end

	-- t=3: duplicate the first target's gain to test dedupe
	local dupeTarget = targets[1]
	local dupeMsg = dupeTarget == UnitName("player")
		and "You are afflicted by Dream Fever (1)."
		or (dupeTarget.." is afflicted by Dream Fever (1).")
	self:ScheduleEvent("KronnTestMFDupe", self.AfflictionEvent, delay + 1, self, dupeMsg)

	-- Stagger fades
	for i, target in ipairs(targets) do
		local isSelf = target == UnitName("player")
		local fadeMsg = isSelf
			and "Dream Fever fades from you."
			or ("Dream Fever fades from "..target..".")

		self:ScheduleEvent("KronnTestMFFade"..i, self.FadeEvent, delay + 10 + (i - 1) * 1, self, fadeMsg)
	end

	self:ScheduleEvent("KronnTestMFEnd", function()
		module:Message("Fever multi-test complete", "Positive")
	end, delay + 14)
	return true
end

-- Spoofs Dreamform's Return to Body and Archdruid Kronn's Reform Body cast
-- begin lines through CastEvent. The first cast is cancelled mid-flight to
-- exercise the early-cancel path; the second runs to completion.
-- Usage: /run local m=BigWigs:GetModule("Archdruid Kronn"); BigWigs:SetupModule("Archdruid Kronn"); m:TestCasts();
function module:TestCasts()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Kronn cast bar test started", "Positive")

	local rtbBegin = "Dreamform of Kronn begins to cast Return to Body."
	local rfbBegin = "Archdruid Kronn begins to cast Reform Body."

	-- t=2: Return to Body begins (10s cast)
	self:ScheduleEvent("KronnTestRtbBegin", self.CastEvent, 2, self, rtbBegin)
	-- t=7: cancel mid-cast (5s in, 5s remaining) to verify early-cancel
	self:ScheduleEvent("KronnTestRtbCancel", function()
		module:RemoveBar(L["bar_returnBody"])
		module:Message("Return to Body cancelled (test)", "Attention")
	end, 7)

	-- t=14: Reform Body begins (10s cast, runs to completion)
	self:ScheduleEvent("KronnTestRfbBegin", self.CastEvent, 14, self, rfbBegin)

	-- t=26: cleanup
	self:ScheduleEvent("KronnTestCastsEnd", function()
		module:RemoveBar(L["bar_returnBody"])
		module:RemoveBar(L["bar_reformBody"])
		module:Message("Kronn cast bar test complete", "Positive")
	end, 26)
	return true
end
