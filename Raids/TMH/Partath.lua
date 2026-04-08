
local module, L = BigWigs:ModuleDeclaration("Chieftain Partath", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"might", "immune", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Partath",

	might_cmd = "might",
	might_name = "Might of the Chieftain Bar",
	might_desc = "Tracks Chieftain Partath's Might of the Chieftain stacks (caps at 50)",

	immune_cmd = "immune",
	immune_name = "Immune (Shade of the Withermaw) Timer",
	immune_desc = "Shows a 15 second bar when Chieftain Partath gains Shade of the Withermaw",

	trigger_mightStack = "Chieftain Partath gains Might of the Chieftain %((%d+)%)",
	trigger_immuneGain = "Chieftain Partath gains Shade of the Withermaw",
	trigger_immuneFade = "Shade of the Withermaw fades from Chieftain Partath",

	bar_might = "Might of the Chieftain",
	bar_immune = "Immune",
	bar_nextImmune = "Next Immune",

	msg_immune = "Chieftain Partath is immune - bring Illuminators to him!",
	msg_immuneOver = "Immune ended!",
} end )

local candybar = AceLibrary("CandyBar-2.2")

local timer = {
	mightCap = 50,
	immune = 15,
	immuneCycle = 52,
}

local icon = {
	might = "Ability_Druid_Maul",
	immune = "Spell_Shadow_SummonVoidWalker",
	immuneCycle = "spell_cloaked_in_shadows_2",
}

local syncName = {
	mightStack = "PartathMight"..module.revision,
	immuneGain = "PartathImmune"..module.revision,
	immuneFade = "PartathImmuneOff"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:ThrottleSync(0, syncName.mightStack)
	self:ThrottleSync(5, syncName.immuneGain)
	self:ThrottleSync(5, syncName.immuneFade)
end

function module:OnSetup()
	self.mightStacks = 0
end

function module:OnEngage()
	self.mightStacks = 0
	if self.db.profile.immune then
		self:StartNextImmuneBar()
		self:ScheduleRepeatingEvent("PartathNextImmune", self.StartNextImmuneBar, timer.immuneCycle, self)
	end
end

function module:StartNextImmuneBar()
	self:RemoveBar(L["bar_nextImmune"])
	self:Bar(L["bar_nextImmune"], timer.immuneCycle, icon.immuneCycle, true, "Blue")
end

function module:OnDisengage()
	self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_might"])
	self:RemoveBar(L["bar_immune"])
	if self:IsEventScheduled("PartathNextImmune") then
		self:CancelScheduledEvent("PartathNextImmune")
	end
	self:RemoveBar(L["bar_nextImmune"])
end

function module:Event(msg)
	local _, _, stacks = string.find(msg, L["trigger_mightStack"])
	if stacks then
		self:Sync(syncName.mightStack.." "..stacks)
		return
	end
	if string.find(msg, L["trigger_immuneGain"]) then
		self:Sync(syncName.immuneGain)
	elseif string.find(msg, L["trigger_immuneFade"]) then
		self:Sync(syncName.immuneFade)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mightStack and rest and self.db.profile.might then
		local n = tonumber(rest)
		if n then self:UpdateMight(n) end
	elseif sync == syncName.immuneGain and self.db.profile.immune then
		self:ImmuneStart()
	elseif sync == syncName.immuneFade and self.db.profile.immune then
		self:ImmuneEnd()
	end
end

function module:StartMightBar(stacks)
	self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_might"], timer.mightCap, "Interface\\Icons\\"..icon.might, true, "White")
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_might"], timer.mightCap - stacks)
	self:ApplyMightTextColor(stacks)
end

function module:UpdateMight(stacks)
	if stacks <= self.mightStacks then return end
	local prev = self.mightStacks
	self.mightStacks = stacks
	if stacks > timer.mightCap then stacks = timer.mightCap end

	if prev == 0 then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_might"], timer.mightCap, "Interface\\Icons\\"..icon.might, true, "White")
	end
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_might"], timer.mightCap - stacks)
	self:ApplyMightTextColor(stacks)
end

function module:ApplyMightTextColor(stacks)
	local id = "BigWigsBar "..L["bar_might"]
	local c = "White"
	if stacks >= 40 then
		c = "Red"
	elseif stacks >= 30 then
		c = "Yellow"
	end
	candybar:SetColor(id, c, 1)
end

function module:ImmuneStart()
	self:RemoveBar(L["bar_immune"])
	self:Bar(L["bar_immune"], timer.immune, icon.immune, true, "Black")
	self:Message(L["msg_immune"], "Urgent", false, "Alarm")
end

function module:ImmuneEnd()
	self:RemoveBar(L["bar_immune"])
	self:Message(L["msg_immuneOver"], "Positive")
end

-- Spoofs real combat-log strings through Event() so the full parse -> sync
-- -> handler chain is exercised. Requires the player to be in a raid for
-- Sync's local echo to reach BigWigs_RecvSync.
-- Usage: /run local m=BigWigs:GetModule("Chieftain Partath"); BigWigs:SetupModule("Chieftain Partath"); m:Test();
function module:Test()
	timer.immuneCycle = 12
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Chieftain Partath test started", "Positive")

	local stackEvents = {
		{t = 2,  s = 2},
		{t = 4,  s = 5},
		{t = 6,  s = 9},
		{t = 8,  s = 15},
		{t = 10, s = 22},
		{t = 12, s = 30},
		{t = 14, s = 38},
		{t = 16, s = 42},
		{t = 18, s = 50},
	}
	for i, e in ipairs(stackEvents) do
		local t, s = e.t, e.s
		local msg = "Chieftain Partath gains Might of the Chieftain ("..s..")."
		self:ScheduleEvent("PartathTestStack"..i, self.Event, t, self, msg)
	end

	self:ScheduleEvent("PartathTestImmuneOn",  self.Event, 20, self,
		"Chieftain Partath gains Shade of the Withermaw (1).")
	self:ScheduleEvent("PartathTestImmuneOff", self.Event, 27, self,
		"Shade of the Withermaw fades from Chieftain Partath.")
	self:ScheduleEvent("PartathTestRestore", function() timer.immuneCycle = 52 end, 32)
	self:ScheduleEvent("PartathTestEnd", self.OnDisengage, 32, self)
	return true
end
