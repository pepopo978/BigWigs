
local module, L = BigWigs:ModuleDeclaration("Archdruid Kronn", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = {
	"Archdruid Kronn",
	"Dreamform of Kronn",
}
module.toggleoptions = {"hpframe", "dreamfever", "bosskill"}
module.zonename = "Timbermaw Hold"

module.defaultDB = {
	hpframe = true,
	-- hpframeposx / hpframeposy computed in UpdateHpFrame on first frame
	-- creation so GetScreenWidth/Height return real values (they can be
	-- unreliable at file-load time).
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Kronn",

	hpframe_cmd = "hpframe",
	hpframe_name = "HP Frame",
	hpframe_desc = "Shows a frame with the HP of Archdruid Kronn and Dreamform of Kronn",

	kronn_name = "Kronn to |cffffff00kill|r",
	dream_name = "Dream to |cff00ff00fill|r",

	kronn_zero = "DEAD",
	dream_zero = "WAKING",

	frame_title = "Kronn HP",

	trigger_victory = "The Nightmare has ended!",

	dreamfever_cmd = "dreamfever",
	dreamfever_name = "Dream Fever Alert",
	dreamfever_desc = "Warn when someone is afflicted by Dream Fever and mark them",

	trigger_feverYou = "You are afflicted by Dream Fever",
	trigger_feverOther = "(.+) is afflicted by Dream Fever",
	trigger_feverFadeYou = "Dream Fever fades from you",
	trigger_feverFadeOther = "Dream Fever fades from (.+)%.",

	msg_feverYou = "DREAM FEVER ON YOU - GET AWAY FROM OTHERS!",
	msg_feverOther = "Dream Fever on %s - get away from them!",
} end )

local realKronn = "Archdruid Kronn"
local dreamKronn = "Dreamform of Kronn"

local icon = {
	fever = "Spell_Nature_NullifyDisease",
}

local syncName = {
	kronnHp = "KronnHp"..module.revision,
	dreamHp = "KronnDreamHp"..module.revision,
	feverGain = "KronnFeverGain"..module.revision,
	feverFade = "KronnFeverFade"..module.revision,
}

function module:OnSetup()
	self.kronnHp = 100
	self.dreamHp = 0 -- raw HP percent; display is 100 - dreamHp to show "distance to full"
	self.feverTargets = {}
end

function module:OnEnable()
	-- Core.lua fires OnEnable *before* OnSetup, so initialize HP values here
	-- to avoid nil concat in UpdateHpFrame below.
	self.kronnHp = 100
	self.dreamHp = 0
	self.feverTargets = {}

	self:ThrottleSync(2, syncName.kronnHp)
	self:ThrottleSync(2, syncName.dreamHp)
	-- per-target payloads; dedupe is handled by self.feverTargets so any
	-- throttle here would drop syncs for different players sharing the key
	self:ThrottleSync(0, syncName.feverGain)
	self:ThrottleSync(0, syncName.feverFade)
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "AfflictionEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "FadeEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "FadeEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FadeEvent")
	if self.db.profile.hpframe then
		self:UpdateHpFrame()
		self.hpFrame:Show() -- allow positioning before pull
	end
end

function module:OnEngage()
	self.kronnHp = 100
	self.dreamHp = 0
	self.victorySent = nil
	self.feverTargets = {}

	if self.db.profile.hpframe then
		self:UpdateHpFrame()
		self.hpFrame:Show()
	end
end

function module:OnDisengage()
	-- Framework auto-restores initialPlayerMarks on disengage (Core.lua:484-488)
	self.feverTargets = {}
	if self.hpFrame then
		self.hpFrame:Hide()
	end
end

function module:AfflictionEvent(msg)
	if string.find(msg, L["trigger_feverYou"]) then
		self:Sync(syncName.feverGain.." "..UnitName("player"))
		return
	end
	local _, _, target = string.find(msg, L["trigger_feverOther"])
	if target then
		self:Sync(syncName.feverGain.." "..target)
	end
end

function module:FadeEvent(msg)
	if string.find(msg, L["trigger_feverFadeYou"]) then
		self:Sync(syncName.feverFade.." "..UnitName("player"))
		return
	end
	local _, _, target = string.find(msg, L["trigger_feverFadeOther"])
	if target then
		self:Sync(syncName.feverFade.." "..target)
	end
end

function module:UNIT_HEALTH(unit)
	self:ScanUnit(unit)
end

function module:UPDATE_MOUSEOVER_UNIT()
	self:ScanUnit("mouseover")
end

function module:ScanUnit(unit)
	local name = UnitName(unit)
	if not name then return end
	if name == realKronn or name == dreamKronn then
		-- Archdruid Kronn never actually dies; the fight ends when he becomes
		-- non-hostile. Dreamform is always friendly, so only check real Kronn.
		if name == realKronn and UnitExists(unit) and not UnitIsEnemy("player", unit) then
			if self.engaged and not self.victorySent then
				self.victorySent = true
				self:SendBossDeathSync()
			end
			return
		end

		local h, m = UnitHealth(unit), UnitHealthMax(unit)
		if h and m and m > 0 then
			local pct = math.floor((h / m) * 100)
			if name == realKronn then
				self.kronnHp = pct
				self:Sync(syncName.kronnHp.." "..pct)
			else
				self.dreamHp = pct
				self:Sync(syncName.dreamHp.." "..pct)
			end
		end
	end
end

function module:UpdateHpFrame()
	if not self.db.profile.hpframe then return end

	if not self.hpFrame then
		local f = CreateFrame("Frame", "BigWigsKronnHpFrame", UIParent)
		f.module = self
		local frameW, frameH = 180, 80
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

		f.title = f:CreateFontString(nil, "ARTWORK")
		f.title:SetFontObject(GameFontNormal)
		f.title:SetPoint("TOP", f, "TOP", 0, -10)
		f.title:SetText(L["frame_title"])
		f.title:SetFont(font, fs)

		f.kronnLabel = f:CreateFontString(nil, "ARTWORK")
		f.kronnLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -30)
		f.kronnLabel:SetFont(font, fs)
		f.kronnLabel:SetText(L["kronn_name"])
		f.kronnLabel:SetTextColor(0.3, 1, 0.3)

		f.kronnHpText = f:CreateFontString(nil, "ARTWORK")
		f.kronnHpText:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -30)
		f.kronnHpText:SetFont(font, fs)

		f.dreamLabel = f:CreateFontString(nil, "ARTWORK")
		f.dreamLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -50)
		f.dreamLabel:SetFont(font, fs)
		f.dreamLabel:SetText(L["dream_name"])
		f.dreamLabel:SetTextColor(0.5, 0.5, 1)

		f.dreamHpText = f:CreateFontString(nil, "ARTWORK")
		f.dreamHpText:SetPoint("TOPRIGHT", f, "TOPRIGHT", -15, -50)
		f.dreamHpText:SetFont(font, fs)

		self.hpFrame = f
	end

	self:SetHpText(self.hpFrame.kronnHpText, self.kronnHp, L["kronn_zero"])
	self:SetHpText(self.hpFrame.dreamHpText, 100 - self.dreamHp, L["dream_zero"])
end

function module:SetHpText(fontString, pct, zeroLabel)
	if not fontString then return end
	local text = pct .. "%"
	local r, g, b = 1, 1, 1
	if pct <= 0 then
		text = zeroLabel or "DEAD"
		r, g, b = 0.5, 0.5, 0.5
	elseif pct < 15 then
		r, g, b = 1, 0, 0
	elseif pct < 35 then
		r, g, b = 1, 1, 0
	end
	fontString:SetText(text)
	fontString:SetTextColor(r, g, b)
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if not rest then return end
	if sync == syncName.kronnHp then
		local n = tonumber(rest)
		if n then
			self.kronnHp = n
			if self.db.profile.hpframe then
				self:UpdateHpFrame()
			end
		end
	elseif sync == syncName.dreamHp then
		local n = tonumber(rest)
		if n then
			self.dreamHp = n
			if self.db.profile.hpframe then
				self:UpdateHpFrame()
			end
		end
	elseif sync == syncName.feverGain and self.db.profile.dreamfever then
		self:FeverGain(rest)
	elseif sync == syncName.feverFade and self.db.profile.dreamfever then
		self:FeverFade(rest)
	end
end

function module:FeverGain(target)
	if self.feverTargets[target] then return end
	self.feverTargets[target] = true

	if target == UnitName("player") then
		self:Message(L["msg_feverYou"], "Personal", true, "Alarm")
		self:WarningSign(icon.fever, 3, true)
	else
		self:Message(string.format(L["msg_feverOther"], target), "Urgent", false, "Alert")
	end

	local mark = self:GetAvailableRaidMark()
	if mark then
		self:SetRaidTargetForPlayer(target, mark)
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

	-- k = Kronn current HP (counting down toward 0)
	-- d = Dream current HP (counting up toward 100)
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
		{t = 19, k = 0,  d = 98 },
		{t = 21, k = 0,  d = 100},
	}
	for i, e in ipairs(steps) do
		local k, d = e.k, e.d
		self:ScheduleEvent("KronnTestHp"..i, function()
			module.kronnHp = k
			module.dreamHp = d
			module:UpdateHpFrame()
		end, e.t)
	end

	self:ScheduleEvent("KronnTestEnd", function()
		module.kronnHp = 100
		module.dreamHp = 0
		module:UpdateHpFrame()
		module:Message("Archdruid Kronn test complete", "Positive")
	end, 24)
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
