
local module, L = BigWigs:ModuleDeclaration("Loktanag the Vile", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"secretion", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Loktanag",

	secretion_cmd = "secretion",
	secretion_name = "Infected Secretion Alert",
	secretion_desc = "Timer for Loktanag the Vile's Infected Secretion",

	trigger_secretion = "Loktanag the Vile casts Infected Secretion",
	bar_secretion = "Infected Secretion",
} end )

local timer = {
	secretion = {12, 14},
}
local icon = {
	secretion = "Spell_Nature_NullifyDisease",
}
local color = {
	secretion = "Green",
}
local syncName = {
	secretion = "LoktanagSecretion"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(5, syncName.secretion)
end

function module:OnSetup()
end

function module:OnEngage()
	-- first Infected Secretion lands ~2.4-4.9s after engage; wait for the
	-- actual cast to start the interval bar
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_secretion"]) then
		self:Sync(syncName.secretion)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.secretion and self.db.profile.secretion then
		self:Secretion()
	end
end

function module:Secretion()
	self:RemoveBar(L["bar_secretion"])
	self:IntervalBar(L["bar_secretion"], timer.secretion[1], timer.secretion[2], icon.secretion, true, color.secretion)
end

-- Spoofs real combat-log strings through Event() so the full parse -> sync
-- -> handler chain is exercised. Requires the player to be in a raid for
-- Sync's local echo to reach BigWigs_RecvSync.
-- Usage: /run local m=BigWigs:GetModule("Loktanag the Vile"); BigWigs:SetupModule("Loktanag the Vile"); m:Test();
function module:Test()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Loktanag the Vile test started", "Positive")

	local castMsg = "Loktanag the Vile casts Infected Secretion(52813) on "..UnitName("player").."."
	for i = 1, 5 do
		self:ScheduleEvent("LoktanagTestSecretion"..i, self.Event, i * 12.5, self, castMsg)
	end

	self:ScheduleEvent("LoktanagTestEnd", function()
		module:RemoveBar(L["bar_secretion"])
		module:Message("Loktanag the Vile test complete", "Positive")
	end, 5 * 12.5 + 3)
	return true
end
