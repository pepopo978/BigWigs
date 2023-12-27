
local module, L = BigWigs:ModuleDeclaration("Gehennas", "Molten Core")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"adds", "curse", "rain", "bosskill"}

module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gehennas",

	adds_cmd = "adds",
	adds_name = "Dead adds counter",
	adds_desc = "Announces dead Flamewakers",

	curse_cmd = "curse",
	curse_name = "Gehennas' Curse alert",
	curse_desc = "Warn for Gehennas' Curse",

	rain_cmd = "rain",
	rain_name = "Rain of Fire alert",
	rain_desc = "Shows a warning sign for Rain of Fire",
	
	curse_trigger = "afflicted by Gehennas' Curse.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	curse_trigger2 = "Gehennas' Curse was resisted",
	curse_warn_soon = "5 seconds until Gehennas' Curse!",
	curse_bar = "Gehennas' Curse",
	
	rain_run_trigger = "You suffer (.*) Fire damage from Gehennas's Rain of Fire.",--You suffer 958 Fire damage from Gehennas's Rain of Fire. CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	
	dead1 = "Flamewaker dies",
	addmsg = "%d/2 Flamewakers dead!",
	flamewaker_name = "Flamewaker",

	["Rain of Fire"] = true,
} end)

local timer = {
	firstCurse = 8,
	firstRain = 7,
	rainTick = 2,
	rainDuration = 6,
	nextRain = 19, -- 12, 18
	earliestCurse = 22,
	latestCurse = 30,
}
local icon = {
	curse = "Spell_Shadow_BlackPlague",
	rain = "Spell_Shadow_RainOfFire",
}
local syncName = {
	curse = "GehennasCurse"..module.revision,
	add = "GehennasAddDead"
}

local flamewaker = 0

module.wipemobs = { L["flamewaker_name"] }

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--Curse, RainOfFire
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--Curse, RainOfFire
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--Curse, RainOfFire

	self:ThrottleSync(10, syncName.curse)
end

function module:OnSetup()
	self.started = false
	flamewaker = 0

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.db.profile.curse then
		self:DelayedMessage(timer.firstCurse - 5, L["curse_warn_soon"], "Urgent", nil, nil, true)
		self:Bar(L["curse_bar"], timer.firstCurse, icon.curse, true, "Blue")
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["rain_run_trigger"]) and self.db.profile.rain then
		self:WarningSign(icon.rain, 0.7)
	elseif ((string.find(msg, L["curse_trigger"])) or (string.find(msg, L["curse_trigger2"]))) then
		self:Sync(syncName.curse)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if string.find(msg, L["dead1"]) then
		self:Sync(syncName.add .. " " .. tostring(flamewaker + 1))
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.curse and self.db.profile.curse then
		self:Curse()
	elseif sync == syncName.add and rest and rest ~= "" and self.db.profile.adds then
		self:AddsDead(rest)
	end
end

function module:Curse()
	self:DelayedMessage(timer.earliestCurse - 5, L["curse_warn_soon"], "Urgent", nil, nil, true)
	self:IntervalBar(L["curse_bar"], timer.earliestCurse, timer.latestCurse, icon.curse, true, "Blue")
end

function module:AddsDead(rest)
	rest = tonumber(rest)
	if rest <= 2 and flamewaker < rest then
		flamewaker = rest
		self:Message(string.format(L["addmsg"], flamewaker), "Positive")
	end
end
