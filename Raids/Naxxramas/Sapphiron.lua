
local module, L = BigWigs:ModuleDeclaration("Sapphiron", "Naxxramas")

module.revision = 30085
module.enabletrigger = module.translatedName
module.toggleoptions = {"frostbreath", "lifedrain", "block", "enrage", "blizzard", "tailsweep", "phase", -1, "proximity", -1, "parry", "bosskill"}

module.defaultDB = {
	enrage = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sapphiron",

	frostbreath_cmd = "frostbreath",
	frostbreath_name = "Deep Breath Alert",
	frostbreath_desc = "Warn when Sapphiron begins to cast Deep Breath.",

	lifedrain_cmd = "lifedrain",
	lifedrain_name = "Life Drain Alert",
	lifedrain_desc = "Warns about the Life Drain curse.",
	
	block_cmd = "block",
	block_name = "Ice Blocks Alert",
	block_desc = "Warns for Ice Blocks.",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage.",

	blizzard_cmd = "blizzard",
	blizzard_name = "Blizzard Alert",
	blizzard_desc = "Warn for Blizzard.",
	
	tailsweep_cmd = "tailsweep",
	tailsweep_name = "Tail Sweep Alert",
	tailsweep_desc = "Warn for Tail Sweep.",
	
	phase_cmd = "phase",
	phase_name = "Phase Alert",
	phase_desc = "Warn for Ground / Air Phases.",
	
	proximity_cmd = "proximity",
	proximity_name = "Proximity Warning",
	proximity_desc = "Show Proximity Warning Frame",
	
	parry_cmd = "parry",
	parry_name = "Parry Alert",
	parry_desc = "Warn for Parries",
	
	
	trigger_frostBreath = "begins to cast Frost Breath.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_frostBreath = "Frost Breath Exploding!",
	msg_frostBreath = "Ice Bomb Incoming - Hide!",
	
	trigger_lifeDrain = "afflicted by Life Drain", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_lifeDrainResist = "Life Drain was resisted by", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	msg_lifeDrain = "Life Drain, Decurse!",
	bar_lifeDrain = "Life Drain",
	
	trigger_iceboltYou = "You are afflicted by Icebolt.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_iceboltOther = "(.+) is afflicted by Icebolt.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	msg_iceBlock = "Ice Block on ",
	
		--unused
	trigger_iceboltFade = "Icebolt fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	
	trigger_iceboltHits = "Icebolt hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	--bar_iceBlock1 = "Ice Block 1",
	bar_iceBlock2 = "Ice Block 2",
	bar_iceBlock3 = "Ice Block 3",
	bar_iceBlock4 = "Ice Block 4",
	bar_iceBlock5 = "Ice Block 5",
	
	trigger_enrage = "Sapphiron gains Enrage", --to be confirmed
	bar_enrage = "Enrage",
	msg_enrage60 = "60sec to Enrage!",
	msg_enrage10 = "10sec to Enrage!",
	
	
	trigger_blizzardYou = "You are afflicted by Chill.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_blizzardYouFade = "Chill fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	
	trigger_tailSweepYou = "Sapphiron's Tail Sweep hits you", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_tailSweep = "Tail Sweep hits behind the boss for 30 yards.",
	
	bar_timeToAirPhase = "Next Air Phase CD",
	--msg_airPhase = "Air Phase - Spread out!",
	msg_airPhaseSoon = "Air Phase Soon - Prepare to Spread Out!",
	bar_timeToGroundPhase = "Next Ground Phase",
	msg_groundPhase = "Ground Phase!",
	
	msg_lowHp = "Sapphiron under 10% - No more air phases!",
	
	trigger_parryYou = "You attack. Sapphiron parries.", --CHAT_MSG_COMBAT_SELF_MISSES
	msg_parryYou = "Sapphiron Parried your attack - Stop killing the tank you idiot!",
} end )

local timer = {
	frostBreath = 7,
	firstLifeDrain = 12,
	lifeDrain = 24,
	
	iceBlock1 = 7,
	iceBlock2 = 4,
	iceBlock3 = 4,
	iceBlock4 = 3.5,
	iceBlock5 = 3,
	
	enrage = 900,
	blizzard = 10,
	tailSweep = 1,
	
	firstGroundPhase = 40,
	groundPhaseMin = 50,
	groundPhaseMax = 70,
	airPhase = 30,
}
local icon = {
	frostBreath = "spell_frost_frostward",
	lifeDrain = "Spell_Shadow_LifeDrain02",
	iceBlock = "spell_frost_frost",
	enrage = "Spell_Shadow_UnholyFrenzy",
	blizzard = "spell_frost_icestorm",
	tailSweep = "inv_misc_monsterscales_05",
	phase = "inv_misc_pocketwatch_01",
	parry = "ability_parry",
}
local color = {
	frostBreath = "Red",
	lifeDrain = "Green",
	iceBlock = "Blue",
	enrage = "Black",
	phase = "White",
}
local syncName = {
	frostBreath = "SapphironBreath"..module.revision,
	lifeDrain = "SapphironLifeDrain"..module.revision,
	iceBlock = "SapphironIceBlock"..module.revision,
	enrage = "SapphironEnrage"..module.revision,
	groundPhase = "SapphironGroundPhase"..module.revision,
	--airPhase = "SapphironAirPhase"..module.revision,
	iceboltHits = "SapphironIceboltHits"..module.revision,
	lowHp = "SapphironLowHp"..module.revision,
	enableProximity = "SapphironEnableProximity"..module.revision,
}

--local lastLifeDrainTime = nil
--local airPhaseTime = nil
local remainingLifeDrainTimer = nil

local lowHp = nil
local phase = "ground"

module.proximityCheck = function(unit) return CheckInteractDistance(unit, 2) end
module.proximitySilent = false

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_lifeDrain, trigger_iceboltYou, trigger_blizzardYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_lifeDrain, trigger_iceboltOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_lifeDrain, trigger_iceboltOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_lifeDrainResist, trigger_tailSweepYou
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_lifeDrainResist
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_frostBreath, trigger_lifeDrainResist
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_iceboltFade, trigger_blizzardYouFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_iceboltFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_iceboltFade
	
	self:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES", "Event") --trigger_parryYou
	
	
	self:ThrottleSync(3, syncName.frostBreath)
	self:ThrottleSync(3, syncName.lifeDrain)
	self:ThrottleSync(3, syncName.iceBlock)
	self:ThrottleSync(3, syncName.enrage)
	self:ThrottleSync(3, syncName.groundPhase)
	--self:ThrottleSync(3, syncName.airPhase)
	self:ThrottleSync(30, syncName.iceboltHits)
	self:ThrottleSync(10, syncName.lowHp)
	self:ThrottleSync(10, syncName.enableProximity)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	--lastLifeDrainTime = GetTime()
	--airPhaseTime = GetTime()
	remainingLifeDrainTimer = 60
	
	lowHp = nil
	phase = "ground"
	
	if self.db.profile.enrage then
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage, true, color.enrage)
		self:DelayedMessage(timer.enrage - 60, L["msg_enrage60"], "Urgent", false, nil, false)
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Urgent", false, nil, false)
	end
	
	if self.db.profile.lifedrain then
		self:Bar(L["bar_lifeDrain"], timer.firstLifeDrain, icon.lifeDrain, true, color.lifeDrain)
	end
	
	if self.db.profile.phase then
		self:Bar(L["bar_timeToAirPhase"], timer.firstGroundPhase, icon.phase, true, color.phase)
		self:DelayedMessage(timer.firstGroundPhase, L["msg_airPhaseSoon"], "Important", false, nil, false)
	end
	
	self:DelayedSync(timer.firstGroundPhase, syncName.enableProximity)
end

function module:OnDisengage()
	self:CancelDelayedSync(syncName.enableProximity)
	self:CancelDelayedSync(syncName.groundPhase)
	self:RemoveProximity()
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() == "Kel'Thuzad Chamber" and self.core:IsModuleActive(module.translatedName) then
		self.core:DisableModule(module.translatedName)
	
	elseif GetMinimapZoneText() == "Eastern Plaguelands" and self.core:IsModuleActive(module.translatedName) then
		self:TriggerEvent("BigWigs_RebootModule", module.translatedName)
		self:ResetModule()
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7f   [BigWigs]|r - Auto-Rebooting Module: "..module.translatedName)
			
	elseif GetMinimapZoneText() == "Sapphiron's Lair" and not self.core:IsModuleActive(module.translatedName) then
		self.core:EnableModule(module.translatedName)
	end
end

function module:ResetModule()
	--lastLifeDrainTime = GetTime()
	--airPhaseTime = GetTime()
	remainingLifeDrainTimer = 60
	
	lowHp = nil
	phase = "ground"
	
	self:CancelDelayedSync(syncName.enableProximity)
	self:CancelDelayedSync(syncName.groundPhase)
	self:RemoveProximity()
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct >= 10 and lowHp ~= nil then
			lowHp = nil
		elseif healthPct < 10 and lowHp == nil then
			self:Sync(syncName.lowHp)
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_frostBreath"]) then
		self:Sync(syncName.frostBreath)
	
	
	elseif string.find(msg, L["trigger_lifeDrain"]) or string.find(msg, L["trigger_lifeDrainResist"]) then
		self:Sync(syncName.lifeDrain)
		
	elseif string.find(msg, L["trigger_iceboltHits"]) then
		self:Sync(syncName.iceboltHits)
	
	elseif msg == L["trigger_iceboltYou"] then
		self:Sync(syncName.iceBlock.." "..UnitName("Player"))
	
	elseif string.find(msg, L["trigger_iceboltOther"]) then
		local _,_, iceBlockPerson, _ = string.find(msg, L["trigger_iceboltOther"])
		self:Sync(syncName.iceBlock.." "..iceBlockPerson)
		
	elseif msg == L["trigger_blizzardYou"] and self.db.profile.blizzard then
		self:Blizzard()
	elseif msg == L["trigger_blizzardYouFade"] and self.db.profile.blizzard then
		self:BlizzardFade()
		
	elseif string.find(msg, L["trigger_tailSweepYou"]) and self.db.profile.tailsweep then
		self:TailSweep()
		
	elseif string.find(msg, L["trigger_parryYou"]) and self.db.profile.parry then
		if UnitName("Target") ~= nil and UnitName("TargetTarget") ~= nil then
			if UnitName("Target") == "Sapphiron" and UnitName("TargetTarget") ~= UnitName("Player") then
				self:ParryYou()
			end
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frostBreath and self.db.profile.frostbreath then
		self:FrostBreath()
	elseif sync == syncName.lifeDrain and self.db.profile.lifedrain then
		self:LifeDrain()
	elseif sync == syncName.iceboltHits then
		self:IceboltHits()
	elseif sync == syncName.iceBlock and rest then
		self:IceBlock(rest)
	elseif sync == syncName.groundPhase then
		self:GroundPhase()
	--elseif sync == syncName.airPhase then
	--	self:AirPhase()
	elseif sync == syncName.lowHp and lowHp == nil then
		self:LowHp()
	elseif sync == syncName.enableProximity and self.db.profile.proximity then
		self:EnableProximity()
	end
end


function module:FrostBreath()
	self:RemoveBar(L["bar_timeToGroundPhase"])
	
	--self:RemoveBar(L["bar_iceBlock1"])
	self:RemoveBar(L["bar_iceBlock2"])
	self:RemoveBar(L["bar_iceBlock3"])
	self:RemoveBar(L["bar_iceBlock4"])
	self:RemoveBar(L["bar_iceBlock5"])
	
	self:CancelDelayedBar(L["bar_iceBlock3"])
	self:CancelDelayedBar(L["bar_iceBlock4"])
	self:CancelDelayedBar(L["bar_iceBlock5"])
	
	if self.db.profile.frostbreath then
		self:Bar(L["bar_frostBreath"], timer.frostBreath, icon.frostBreath, true, color.frostBreath)
		self:Message(L["msg_frostBreath"], "Urgent", false, nil, false)
		self:WarningSign(icon.frostBreath, 1)
		self:Sound("Beware")
	end
	
	if self.db.profile.phase then
		self:Bar(L["bar_timeToGroundPhase"], timer.frostBreath + 1, icon.phase, true, color.phase)
	end
	
	if self.db.profile.proximity then
		self:RemoveProximity()
	end
	
	self:DelayedSync(timer.frostBreath + 1, syncName.groundPhase)
end

function module:LifeDrain()
	--lastLifeDrainTime = GetTime()
	self:Bar(L["bar_lifeDrain"], timer.lifeDrain, icon.lifeDrain, true, color.lifeDrain)
	
	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(L["msg_lifeDrain"], "Personal", false, nil, false)
		self:WarningSign(icon.lifeDrain, 0.7)
		self:Sound("Long")
	end
end

function module:IceBlock(rest)
	if self.db.profile.block then
		self:Message(L["msg_iceBlock"]..rest, "Important", false, nil, false)
	end
	
	if rest == UnitName("Player") then
		SendChatMessage("Ice Block on "..UnitName("Player").."!","YELL")
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrage"])
	self:WarningSign(icon.enrage, 1)
	self:Sound("Beware")
end

function module:IceboltHits()
	if phase == "ground" then
		phase = "air"
		--airPhaseTime = GetTime() - 7
	end
	
	self:RemoveBar(L["bar_timeToGroundPhase"])
	self:RemoveBar(L["bar_lifeDrain"])
	self:RemoveBar(L["bar_timeToAirPhase"])
	
	if self.db.profile.proximity then
		self:TriggerEvent("BigWigs_ShowProximity")
	end
	
	if self.db.profile.phase then
		self:Bar(L["bar_timeToGroundPhase"], timer.airPhase - timer.iceBlock1, icon.phase, true, color.phase)
	end
	
	if self.db.profile.block then
		self:Bar(L["bar_iceBlock2"], timer.iceBlock2, icon.iceBlock, true, color.iceBlock)
		self:DelayedBar(timer.iceBlock2, L["bar_iceBlock3"], timer.iceBlock3, icon.iceBlock, true, color.iceBlock)
		self:DelayedBar(timer.iceBlock2 + timer.iceBlock3, L["bar_iceBlock4"], timer.iceBlock4, icon.iceBlock, true, color.iceBlock)
		self:DelayedBar(timer.iceBlock2 + timer.iceBlock3 + timer.iceBlock4, L["bar_iceBlock5"], timer.iceBlock5, icon.iceBlock, true, color.iceBlock)
	end
end

function module:Blizzard()
	self:WarningSign(icon.blizzard, timer.blizzard)
	self:Sound("Info")
end

function module:BlizzardFade()
	self:RemoveWarningSign(icon.blizzard)
end

function module:TailSweep()
	self:Message(L["msg_tailSweep"], "Personal", false, nil, false)
	self:WarningSign(icon.tailSweep, timer.tailSweep)
end

function module:GroundPhase()
	phase = "ground"
	
	self:RemoveBar(L["bar_timeToGroundPhase"])
	
	--self:RemoveBar(L["bar_iceBlock1"])
	self:RemoveBar(L["bar_iceBlock2"])
	self:RemoveBar(L["bar_iceBlock3"])
	self:RemoveBar(L["bar_iceBlock4"])
	self:RemoveBar(L["bar_iceBlock5"])
	
	self:CancelDelayedBar(L["bar_iceBlock2"])
	self:CancelDelayedBar(L["bar_iceBlock3"])
	self:CancelDelayedBar(L["bar_iceBlock4"])
	self:CancelDelayedBar(L["bar_iceBlock5"])
	
	self:RemoveBar(L["bar_frostBreath"])
	
	if self.db.profile.proximity then
		self:RemoveProximity()
		self:DelayedSync(timer.groundPhaseMin, syncName.enableProximity)
	end
	
	self:CancelDelayedSync(syncName.groundPhase)
	
	if self.db.profile.lifedrain then
		--remainingLifeDrainTimer = timer.lifeDrain - (airPhaseTime - lastLifeDrainTime)
		self:Bar(L["bar_lifeDrain"], 6, icon.lifeDrain, true, color.lifeDrain)
	end
	
	if lowHp == nil then
		if self.db.profile.phase then
			self:IntervalBar(L["bar_timeToAirPhase"], timer.groundPhaseMin, timer.groundPhaseMax, icon.phase, true, color.phase)
			self:Message(L["msg_groundPhase"], "Important", false, nil, false)
		end
	end
end

function module:EnableProximity()
	self:TriggerEvent("BigWigs_ShowProximity")
end

function module:RemoveProximity()
	self:TriggerEvent("BigWigs_HideProximity")
end

function module:LowHp()
	lowHp = true
	
	if phase == "ground" then
		self:RemoveBar(L["bar_timeToAirPhase"])
	end
	
	self:Message(L["msg_lowHp"], "Important", false, nil, false)
end

function module:ParryYou()
	self:WarningSign(icon.parry, 0.7)
	self:Message(L["msg_parryYou"], "Personal", false, nil, false)
	self:Sound("Info")
end
