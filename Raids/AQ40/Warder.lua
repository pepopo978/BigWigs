
local module, L = BigWigs:ModuleDeclaration("Anubisath Warder", "Ahn'Qiraj")

module.revision = 20044
module.enabletrigger = module.translatedName
module.toggleoptions = {"fear", "silence", "roots", "dust", "warnings"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Warder",

	fear_cmd = "fear",
	fear_name = "Fear timer",
	fear_desc = "Shows fear cd",

	silence_cmd = "silence",
	silence_name = "Silence timer",
	silence_desc = "Shows Silence cd",

	roots_cmd = "roots",
	roots_name = "Roots timer",
	roots_desc = "Shows Roots cd",

	dust_cmd = "dust",
	dust_name = "Dust Cloud timer",
	dust_desc = "Shows Dust Cloud cd",

	warnings_cmd = "warnings",
	warnings_name = "Warning messages ",
	warnings_desc = "Warning messages showing which 2 abilities current mob has",

	fearTrigger = "Anubisath Warder begins to cast Fear.",
	fearWarn = "Fear",
	fearWarn2 = "(Silence or Dust Cloud)",
	fearBar = "Fear!",
	fearBar_next = "Fear CD",

	silenceTrigger = "Anubisath Warder begins to cast Silence.",
	silenceWarn = "Silence",
	silenceWarn2 = "(Roots or Fear)",
	silenceBar = "Silence!",
	silenceBar_next = "Silence CD",

	rootsTrigger = "Anubisath Warder begins to cast Entangling Roots.",
	rootsWarn = "Roots",
	rootsWarn2 = "(Silence or Dust Cloud)",
	rootsBar = "Roots!",
	rootsBar_next = "Roots CD",

	dustTrigger = "Anubisath Warder begins to perform Dust Cloud.",
	dustWarn = "Dust Cloud",
	dustWarn2 = "(Roots or Fear)",
	dustBar = "Dust Cloud!",
	dustBar_next = "Dust Cloud CD",
} end )

local timer = {
	earliestFear = 14,
	latestFear = 19,
	fearCast = 1.5,
	earliestSilence = 14,
	latestSilence = 19,
	silenceCast = 1.5,
	earliestRoots = 7,
	latestRoots = 14,
	rootsCast = 1.5,
	earliestDust = 14,
	latestDust = 19,
	dustCast = 1.5,
}

local icon = {
	fear = "Spell_Shadow_Possession",
	silence = "Spell_Holy_Silence",
	roots = "Spell_Nature_StrangleVines",
	dust = "Ability_Hibernation",
}

local syncName = {
	fear = "WarderFear"..module.revision,
	silence = "WarderSilence"..module.revision,
	roots = "WarderRoots"..module.revision,
	dust = "WarderDust"..module.revision,
}

local pull = nil

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	if not warnings then
		warnings = {
			["dust"] = {L["dustWarn"], L["dustWarn2"]},
			["roots"] = {L["rootsWarn"], L["rootsWarn2"]},
			["fear"] = {L["fearWarn"], L["fearWarn2"]},
			["silence"] = {L["silenceWarn"], L["silenceWarn2"]},
		}
	end

	self:ThrottleSync(6, syncName.fear)
	self:ThrottleSync(6, syncName.silence)
	self:ThrottleSync(3, syncName.roots)
end

function module:OnSetup()
end

function module:OnEngage()
	self.ability1 = nil
	self.ability2 = nil
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["fearTrigger"]) then
		self:Sync(syncName.fear)
	elseif string.find(msg, L["silenceTrigger"]) then
		self:Sync(syncName.silence)
	elseif string.find(msg, L["rootsTrigger"]) then
		self:Sync(syncName.roots)
	elseif string.find(msg, L["dustTrigger"]) then
		self:Sync(syncName.dust)
	end
end

function module:BigWigs_RecvSync( sync, rest, nick )
	if sync == syncName.fear then
		if self.db.profile.fear then
			self:RemoveBar(L["fearBar_next"])
			self:Bar(L["fearBar"], timer.fearCast, icon.fear, true, "blue")
			self:DelayedIntervalBar(timer.fearCast, L["fearBar_next"], timer.earliestFear-timer.fearCast, timer.latestFear-timer.fearCast, icon.fear, true, "blue")
		end
		self:AbilityWarn("fear")
	elseif sync == syncName.silence then
		if self.db.profile.silence then
			self:RemoveBar(L["silenceBar_next"])
			self:Bar(L["silenceBar"], timer.silenceCast, icon.silence, true, "red")
			self:DelayedIntervalBar(timer.silenceCast, L["silenceBar_next"], timer.earliestSilence-timer.silenceCast, timer.latestSilence-timer.silenceCast, icon.silence, true, "red")
		end
		self:AbilityWarn("silence")
	elseif sync == syncName.roots then
		if self.db.profile.roots then
			self:RemoveBar(L["rootsBar_next"])
			self:Bar(L["rootsBar"], timer.rootsCast, icon.roots, true, "Green")
			self:DelayedIntervalBar(timer.rootsCast, L["rootsBar_next"], timer.earliestRoots-timer.rootsCast, timer.latestRoots-timer.rootsCast, icon.roots, true, "Green")
		end
		self:AbilityWarn("roots")
	elseif sync == syncName.dust then
		if self.db.profile.dust then
			self:RemoveBar(L["dustBar_next"])
			self:Bar(L["dustBar"], timer.dustCast, icon.dust, true, "White")
			self:DelayedIntervalBar(timer.dustCast, L["dustBar_next"], timer.earliestDust-timer.dustCast, timer.latestDust-timer.dustCast, icon.dust, true, "White")
		end
		self:AbilityWarn("dust")
	end
end

function module:AbilityWarn( ability )
	if self.db.profile.warnings then
		if not self.ability1 then
			self.ability1 = ability
			self:Message(string.format("%s + %s",warnings[self.ability1][1], warnings[self.ability1][2]), "Core", nil, "Long")
		elseif not self.ability2 and ability ~= self.ability1 then
			self.ability2 = ability
			self:Message(string.format("%s + %s",warnings[self.ability1][1], warnings[self.ability2][1]), "Core", nil, "Long")
		end
	end
end
