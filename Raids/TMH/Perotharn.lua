
local module, L = BigWigs:ModuleDeclaration("Peroth'arn", "Timbermaw Hold")

module.revision = 30000
module.enabletrigger = module.translatedName
module.toggleoptions = {"nightmarishAbsorption", "bosskill"}
module.zonename = "Timbermaw Hold"

L:RegisterTranslations("enUS", function() return {
	cmd = "Perotharn",

	nightmarishAbsorption_cmd = "nightmarishAbsorption",
	nightmarishAbsorption_name = "Nightmarish Absorption Shield",
	nightmarishAbsorption_desc = "Show a bar tracking damage absorbed by Nightmarish Absorption",

	trigger_shieldGain = "Peroth'arn gains Nightmarish Absorption",
	trigger_shieldFade = "Nightmarish Absorption fades from Peroth'arn",

	bar_shield = "Absorption",
} end )

local shieldMax = 300000

local color = {
	nightmarishAbsorption = "Red",
}

local icon = {
	nightmarishAbsorption = "Spell_Shadow_AntiShadow",
}

local shieldSyncStep = shieldMax * 0.05 -- sync every 5% of shield

local syncName = {
	shieldGain    = "PerothShieldGain"..module.revision,
	shieldFade    = "PerothShieldFade"..module.revision,
	shieldAbsorbed = "PerothShieldAbs"..module.revision,
}

local absorbPatternHit = "Peroth'arn for %d+%.?%s?.*%((%d+) absorbed%)"
local absorbPatternSelf = "You %a+ Peroth'arn for %d+%.?%s?.*%((%d+) absorbed%)"
local absorbPatternDot = "Peroth'arn suffers %d+%s?.*%((%d+) absorbed%)"

local absorbEvents = {
	-- Melee hits
	"CHAT_MSG_COMBAT_SELF_HITS",
	"CHAT_MSG_COMBAT_PARTY_HITS",
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS",
	"CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS",
	"CHAT_MSG_COMBAT_PET_HITS",
	-- Spell hits
	"CHAT_MSG_SPELL_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_PET_DAMAGE",
	-- Damage shields (thorns, ret aura, etc.)
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
	-- DoT/periodic ticks
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
}

function module:RegisterAbsorbEvents()
	for _, event in ipairs(absorbEvents) do
		self:RegisterEvent(event, "AbsorbEvent")
	end
end

function module:UnregisterAbsorbEvents()
	for _, event in ipairs(absorbEvents) do
		if self:IsEventRegistered(event) then
			self:UnregisterEvent(event)
		end
	end
end

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "BuffEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "FadeEvent")

	self:ThrottleSync(5, syncName.shieldGain)
	self:ThrottleSync(5, syncName.shieldFade)
end

function module:OnSetup()
	self.shieldAbsorbed = 0
	self.shieldActive = false
	self.lastSyncThreshold = 0
end
function module:OnEngage() end
function module:OnDisengage()
	self:UnregisterAbsorbEvents()
	self.shieldAbsorbed = 0
	self.shieldActive = false
	self.lastSyncThreshold = 0
end

function module:BuffEvent(msg)
	if string.find(msg, L["trigger_shieldGain"]) then
		self:Sync(syncName.shieldGain)
	end
end

function module:FadeEvent(msg)
	if string.find(msg, L["trigger_shieldFade"]) then
		self:Sync(syncName.shieldFade)
	end
end

function module:UpdateShieldBar()
	self:TriggerEvent("BigWigs_SetHPBar", self, L["bar_shield"], self.shieldAbsorbed)
	local remaining = shieldMax - self.shieldAbsorbed
	local barId = "BigWigsBar "..L["bar_shield"]
	self:SetCandyBarText(barId,
		string.format("%s - %dk / %dk", L["bar_shield"], math.floor(remaining / 1000), shieldMax / 1000))
end

function module:AbsorbEvent(msg)
	if not self.shieldActive then return end
	local _, _, absorbed = string.find(msg, absorbPatternHit)
	if not absorbed then
		_, _, absorbed = string.find(msg, absorbPatternSelf)
	end
	if not absorbed then
		_, _, absorbed = string.find(msg, absorbPatternDot)
	end
	if absorbed then
		self.shieldAbsorbed = self.shieldAbsorbed + tonumber(absorbed)
		if self.shieldAbsorbed > shieldMax then
			self.shieldAbsorbed = shieldMax
		end
		self:UpdateShieldBar()

		local threshold = math.floor(self.shieldAbsorbed / shieldSyncStep)
		if threshold > self.lastSyncThreshold then
			self.lastSyncThreshold = threshold
			self:Sync(syncName.shieldAbsorbed .. " " .. self.shieldAbsorbed)
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shieldGain and self.db.profile.nightmarishAbsorption then
		self.shieldAbsorbed = 0
		self.shieldActive = true
		self.lastSyncThreshold = 0
		self:RegisterAbsorbEvents()
		self:TriggerEvent("BigWigs_StartHPBar", self, L["bar_shield"], shieldMax,
			"Interface\\Icons\\"..icon.nightmarishAbsorption, true, color.nightmarishAbsorption)
		-- Hide the timer text (too narrow for 6-digit numbers) and show value in the label
		self:PauseCandyBar("BigWigsBar "..L["bar_shield"], true)
		self:UpdateShieldBar()
	elseif sync == syncName.shieldFade and self.db.profile.nightmarishAbsorption then
		self:UnregisterAbsorbEvents()
		self.shieldActive = false
		self:TriggerEvent("BigWigs_StopHPBar", self, L["bar_shield"])
	elseif sync == syncName.shieldAbsorbed and rest and self.shieldActive then
		local val = tonumber(rest)
		if val and val > self.shieldAbsorbed then
			self.shieldAbsorbed = val
			self.lastSyncThreshold = math.floor(val / shieldSyncStep)
			self:UpdateShieldBar()
		end
	end
end

-- Comprehensive shield test. Fires shield gain, then every format of absorbed
-- damage line we handle (melee self, melee other, spell self, spell other,
-- spell with school+resist, glancing, crit, DoT tick, MC'd player DoT,
-- damage shield, pet melee, pet spell, creature spell). Verifies the bar
-- drains correctly and that non-matching lines are ignored. Fires shield
-- fade at the end.
-- Usage: /run local m=BigWigs:GetModule("Peroth'arn"); BigWigs:SetupModule("Peroth'arn"); m:TestShield();
function module:TestShield()
	self:OnSetup()
	self:OnEnable()
	self:SendEngageSync()
	self:Message("Peroth'arn shield test started", "Positive")

	-- t=1: shield gain
	self:ScheduleEvent("PerothTest01", self.BuffEvent, 1, self,
		"Peroth'arn gains Nightmarish Absorption (1).")

	-- All absorb lines from here. Each fires through AbsorbEvent.
	-- Running total annotated in comments.

	-- t=2: self melee hit (COMBAT_SELF_HITS)
	-- "You hit Target for X. (Y absorbed)"
	self:ScheduleEvent("PerothTest02", self.AbsorbEvent, 2, self,
		"You hit Peroth'arn for 0. (500 absorbed)")
	-- total: 500

	-- t=2.5: self melee crit (COMBAT_SELF_HITS)
	self:ScheduleEvent("PerothTest03", self.AbsorbEvent, 2.5, self,
		"You crit Peroth'arn for 0. (1200 absorbed)")
	-- total: 1700

	-- t=3: self melee glancing (COMBAT_SELF_HITS)
	self:ScheduleEvent("PerothTest04", self.AbsorbEvent, 3, self,
		"You hit Peroth'arn for 1. (glancing) (282 absorbed)")
	-- total: 1982

	-- t=3.5: other melee hit (COMBAT_PARTY/FRIENDLY_HITS)
	-- "Name hits Target for X. (Y absorbed)"
	self:ScheduleEvent("PerothTest05", self.AbsorbEvent, 3.5, self,
		"Rootankman hits Peroth'arn for 0. (650 absorbed)")
	-- total: 2632

	-- t=4: other melee crit (COMBAT_PARTY/FRIENDLY_HITS)
	self:ScheduleEvent("PerothTest06", self.AbsorbEvent, 4, self,
		"Cirah crits Peroth'arn for 0. (1800 absorbed)")
	-- total: 4432

	-- t=4.5: other melee glancing with resist (COMBAT_PARTY/FRIENDLY_HITS)
	self:ScheduleEvent("PerothTest07", self.AbsorbEvent, 4.5, self,
		"Rootankman crits Peroth'arn for 0. (8 resisted) (668 absorbed)")
	-- total: 5100

	-- t=5: self spell hit (SPELL_SELF_DAMAGE)
	-- "Your Spell hits Target for X School damage. (Y absorbed)"
	self:ScheduleEvent("PerothTest08", self.AbsorbEvent, 5, self,
		"Your Starfire hits Peroth'arn for 0 Arcane damage. (619 absorbed)")
	-- total: 5719

	-- t=5.5: self spell crit (SPELL_SELF_DAMAGE)
	self:ScheduleEvent("PerothTest09", self.AbsorbEvent, 5.5, self,
		"Your Earth Shock crits Peroth'arn for 0 Nature damage. (900 absorbed)")
	-- total: 6619

	-- t=6: other spell hit (SPELL_PARTY/FRIENDLY_DAMAGE)
	-- "Name's Spell hits Target for X School damage. (Y absorbed)"
	self:ScheduleEvent("PerothTest10", self.AbsorbEvent, 6, self,
		"Zhafu's Flame Shock hits Peroth'arn for 0 Fire damage. (160 resisted) (481 absorbed)")
	-- total: 7100

	-- t=6.5: other spell crit (SPELL_PARTY/FRIENDLY_DAMAGE)
	self:ScheduleEvent("PerothTest11", self.AbsorbEvent, 6.5, self,
		"Scozmo's Arcane Missiles hits Peroth'arn for 0 Arcane damage. (317 absorbed)")
	-- total: 7417

	-- t=7: other spell hit no school (SPELL_PARTY/FRIENDLY_DAMAGE)
	self:ScheduleEvent("PerothTest12", self.AbsorbEvent, 7, self,
		"Croatus's Lightning Strike hits Peroth'arn for 0. (567 absorbed)")
	-- total: 7984

	-- t=7.5: other spell crit with school (SPELL_PARTY/FRIENDLY_DAMAGE)
	self:ScheduleEvent("PerothTest13", self.AbsorbEvent, 7.5, self,
		"Dehumanizing's Whirlwind crits Peroth'arn for 0. (2515 absorbed)")
	-- total: 10499

	-- t=8: DoT tick (SPELL_PERIODIC_CREATURE_DAMAGE)
	-- "Target suffers X School damage from Name's Spell. (Y absorbed)"
	self:ScheduleEvent("PerothTest14", self.AbsorbEvent, 8, self,
		"Peroth'arn suffers 0 Fire damage from Croatus's Flame Shock. (138 absorbed)")
	-- total: 10637

	-- t=8.5: DoT tick with resist (SPELL_PERIODIC_CREATURE_DAMAGE)
	self:ScheduleEvent("PerothTest15", self.AbsorbEvent, 8.5, self,
		"Peroth'arn suffers 0 Fire damage from Zhafu's Flame Shock. (54 resisted) (163 absorbed)")
	-- total: 10800

	-- t=9: MC'd player DoT (SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE)
	-- "Target suffers X School damage from Name (Peroth'arn)'s Spell. (Y absorbed)"
	self:ScheduleEvent("PerothTest16", self.AbsorbEvent, 9, self,
		"Peroth'arn suffers 0 Fire damage from Employer (Peroth'arn)'s Immolation Trap Effect. (564 absorbed)")
	-- total: 11364

	-- t=9.5: MC'd player DoT - consecration (SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE)
	self:ScheduleEvent("PerothTest17", self.AbsorbEvent, 9.5, self,
		"Peroth'arn suffers 0 Holy damage from Telemannus (Peroth'arn)'s Consecration. (269 absorbed)")
	-- total: 11633

	-- t=10: damage shield - self (SPELL_DAMAGESHIELDS_ON_SELF)
	-- "Your Thorns hits Target for X Nature damage. (Y absorbed)"
	self:ScheduleEvent("PerothTest18", self.AbsorbEvent, 10, self,
		"Your Thorns hits Peroth'arn for 0 Nature damage. (85 absorbed)")
	-- total: 11718

	-- t=10.5: damage shield - other (SPELL_DAMAGESHIELDS_ON_OTHERS)
	self:ScheduleEvent("PerothTest19", self.AbsorbEvent, 10.5, self,
		"Croatus's Lightning Shield hits Peroth'arn for 0 Nature damage. (923 absorbed)")
	-- total: 12641

	-- t=11: pet melee (COMBAT_PET_HITS)
	-- "Name (Owner) hits Target for X. (Y absorbed)"
	self:ScheduleEvent("PerothTest20", self.AbsorbEvent, 11, self,
		"Felguard (Glazbonk) hits Peroth'arn for 0. (651 absorbed)")
	-- total: 13292

	-- t=11.5: pet spell (SPELL_PET_DAMAGE / CREATURE_VS_CREATURE_DAMAGE)
	self:ScheduleEvent("PerothTest21", self.AbsorbEvent, 11.5, self,
		"Doomguard (Dezmar)'s Infernal Blade crits Peroth'arn for 0 Fire damage. (335 absorbed)")
	-- total: 13627

	-- t=12: hostile player melee - MC'd player (COMBAT_HOSTILEPLAYER_HITS)
	self:ScheduleEvent("PerothTest22", self.AbsorbEvent, 12, self,
		"Employer (Peroth'arn) hits Peroth'arn for 0. (400 absorbed)")
	-- total: 14027

	-- t=12.5: hostile player spell - MC'd player (SPELL_HOSTILEPLAYER_DAMAGE)
	self:ScheduleEvent("PerothTest23", self.AbsorbEvent, 12.5, self,
		"Blainam (Peroth'arn)'s Shadow Bolt hits Peroth'arn for 0 Shadow damage. (1500 absorbed)")
	-- total: 15527

	-- t=13: NON-MATCHING lines that should be ignored
	-- Boss hitting player (not damage on Peroth'arn)
	self:ScheduleEvent("PerothTest24", self.AbsorbEvent, 13, self,
		"Peroth'arn's Dirk of the Beast hits you for 57 Shadow damage. (18 resisted)")
	-- total: still 15527

	-- t=13.2: Regular damage on Peroth'arn with no absorb tag
	self:ScheduleEvent("PerothTest25", self.AbsorbEvent, 13.2, self,
		"Dehumanizing's Slam crits Peroth'arn for 2402.")
	-- total: still 15527

	-- t=13.4: Absorbed on wrong target
	self:ScheduleEvent("PerothTest26", self.AbsorbEvent, 13.4, self,
		"Rootankman hits Foulheart Manipulator for 0. (500 absorbed)")
	-- total: still 15527

	-- t=14: verify and report
	self:ScheduleEvent("PerothTestVerify", function()
		local expected = 15527
		local actual = module.shieldAbsorbed
		if actual == expected then
			module:Message("PASS: absorbed "..actual.." (expected "..expected..")", "Positive")
		else
			module:Message("FAIL: absorbed "..actual.." (expected "..expected..")", "Important")
		end
	end, 14)

	-- t=16: shield fades
	self:ScheduleEvent("PerothTest27", self.FadeEvent, 16, self,
		"Nightmarish Absorption fades from Peroth'arn.")

	-- t=17: second shield to test reapplication
	self:ScheduleEvent("PerothTest28", self.BuffEvent, 17, self,
		"Peroth'arn gains Nightmarish Absorption (1).")

	-- t=18: hit on second shield to verify counter reset
	self:ScheduleEvent("PerothTest29", self.AbsorbEvent, 18, self,
		"Rootankman hits Peroth'arn for 0. (1000 absorbed)")

	-- t=19: verify second shield
	self:ScheduleEvent("PerothTestVerify2", function()
		local expected = 1000
		local actual = module.shieldAbsorbed
		if actual == expected then
			module:Message("PASS: second shield absorbed "..actual.." (expected "..expected..")", "Positive")
		else
			module:Message("FAIL: second shield absorbed "..actual.." (expected "..expected..")", "Important")
		end
	end, 19)

	-- t=20: fade second shield
	self:ScheduleEvent("PerothTest30", self.FadeEvent, 20, self,
		"Nightmarish Absorption fades from Peroth'arn.")

	self:ScheduleEvent("PerothTestEnd", function()
		module:Message("Peroth'arn shield test complete", "Positive")
		module:SendBossDeathSync()
	end, 22)
	return true
end
