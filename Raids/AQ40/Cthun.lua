local module, L = BigWigs:ModuleDeclaration("C'Thun", "Ahn'Qiraj")

module.revision = 30078
module.enabletrigger = { "Eye of C'Thun", "C'Thun" }
module.toggleoptions = {
	"cthuneyebeam",
	"darkglare",
	"smalltentacle",
	"smallclaw",
	-1,
	"gianttimer",
	"gianteyeeyebeam",
	"groundtremor",
	"window",
	"weakened",
	"acid",
	-1,
	"map",
	"stomachhp",
	"proximity",
	"stomachplayers",
	-1,
	"raidicon",
	"bosskill"
}
module.defaultDB = {
	mapX = 600,
	mapY = -400,
	mapAlpha = 1,
	mapScale = 1,
	autotarget = false,
	window = false,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Cthun",

		map_cmd = "map",
		map_name = "Positions Map",
		map_desc = "Show live cthun positions map",

		cthuneyebeam_cmd = "cthuneyebeam",
		cthuneyebeam_name = "C'Thun's Eye Beam Alert",
		cthuneyebeam_desc = "Warn for C'Thun's Eye Beam",

		darkglare_cmd = "darkglare",
		darkglare_name = "Dark Glare Alert",
		darkglare_desc = "Warn for Dark Glare",

		smalltentacle_cmd = "smalltentacle",
		smalltentacle_name = "Small Eye Tentacles Alert",
		smalltentacle_desc = "Warn for Small Eye Tentacles",

		smallclaw_cmd = "smallclaw",
		smallclaw_name = "Small Claw Alert",
		smallclaw_desc = "Warn for Small Claw Tentacle",

		gianttimer_cmd = "gianttimer",
		gianttimer_name = "Giant Claw/Eye Spawn Alert",
		gianttimer_desc = "Warn for Giant Claw and Giant Eye spawns",

		gianteyeeyebeam_cmd = "gianteyeeyebeam",
		gianteyeeyebeam_name = "Giant Eye's Eye Beam Alert",
		gianteyeeyebeam_desc = "Warn for Giant Eye's Eye Beam",

		groundtremor_cmd = "groundtremor",
		groundtremor_name = "Ground Tremor Alert",
		groundtremor_desc = "Warn for Ground Tremor",

		window_cmd = "window",
		window_name = "Window of Opportunity Alert",
		window_desc = "Warn for best time to push weaken",

		weakened_cmd = "weakened",
		weakened_name = "Weakened Alert",
		weakened_desc = "Warn for Weakened State",

		acid_cmd = "acid",
		acid_name = "Digestive Acid Alert",
		acid_desc = "Warn for High Digestive Acid Stacks",

		stomachhp_cmd = "stomachhp",
		stomachhp_name = "Stomach Tentacle HP",
		stomachhp_desc = "Bars and Warnings for Stomach Tentacles' HP",

		proximity_cmd = "proximity",
		proximity_name = "Proximity Warning Frame",
		proximity_desc = "Show Proximity Warning Frame",

		stomachplayers_cmd = "stomachplayers",
		stomachplayers_name = "Players in Stomach Frame",
		stomachplayers_desc = "Show Players in Stomach Frame",

		raidicon_cmd = "raidicon",
		raidicon_name = "Skull on Eye Beams",
		raidicon_desc = "Put a Skull on Eye Beam targets",


		bar_startRandomBeams = "Start of Random Beams!",

		trigger_cthun_eyeBeam = "Eye of C'Thun begins to cast Eye Beam.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_eyeBeam = "Eye Beam on ",

		--no dark glare trigger
		bar_darkGlareCd = "Next Dark Glare",
		bar_darkGlareCasting = "Casting Dark Glare!",
		bar_darkGlareDur = "Dark Glare!",
		msg_darkGlareCasting = "Dark Glare!",
		msg_darkGlareEndsSoon = "Dark Glare ends in 5 sec",

		trigger_smallEyeTentacles = "Eye Tentacle begins to cast Birth.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
		msg_smallEyeTentaclesSoon = "Small Eye Tentacles in 3 sec",
		bar_smallEyeTentacles = "Small Eye Tentacles",
		bar_smallEyesDead = "/8 Eye Tentacles Dead",

		trigger_smallClaw = "Claw Tentacle begins to cast Birth.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
		bar_smallClaw = "Small Claw Spawn",

		msg_phase2 = "The Eye is dead - Body incoming!",

		trigger_giantClaw = "Giant Claw Tentacle begins to cast Birth.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
		bar_giantClaw = "Giant Claw Spawns",

		trigger_giantEye = "Giant Eye Tentacle begins to cast Birth.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
		bar_giantEye = "Giant Eye Spawns",

		trigger_giantEye_eyeBeam = "Giant Eye Tentacle begins to cast Eye Beam.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		--bar_eyeBeam = "Eye Beam on ",

		trigger_groundTremor = "afflicted by Ground Tremor.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
		bar_groundTremorDur = "Ground Tremor Stun",

		bar_windowOfOpportunity = "Window of Opportunity",

		--must be a string.find
		trigger_weakened = "is weakened!", --CHAT_MSG_MONSTER_EMOTE
		bar_weakened = "C'Thun is Weakened!",
		msg_weakened = "C'Thun is Weakened!",
		msg_weakenedFade = "Weaken is Over",

		trigger_digestiveAcid = "You are afflicted by Digestive Acid %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		msg_digestiveAcid = " Acid Stacks - Consider getting out of the Stomach",

		hpBar_firstTentacle = "First Tentacle",
		hpBar_secondTentacle = "Second Tentacle",
		msg_firstTentacleDead = "First Tentacle Dead",

		frameHeader_playersInStomach = "Players in Stomach",
	}
end)

local timer = {
	p1_startRandomBeams = 8,
	eyeBeamCast = 2,

	darkGlareFirstCd = 45,
	darkGlareCd = 87,
	darkGlareCasting = 3,
	darkGlareDur = 39,

	p1_smallEyeTentaclesFirstCd = 45,
	p1_smallEyeTentaclesCd = 45,

	smallClaw = 8,


	p2_smallEyeTentaclesFirstCd = 42,
	p2_smallEyeTentaclesCd = 30,
	p2_smallEyeTentaclesAfterWeakenCd = 38,

	giantClawFirstCd = 12,
	giantClawCd = 30,
	giantClawAfterWeakenCd = 8,

	giantEyeCd = 30,

	p2_timeBetweenGiantSpawn = 30,

	groundTremor = 2,

	weakenedDur = 45,
}
local icon = {
	eyeBeam = "spell_shadow_lifedrain02",
	darkGlare = "Inv_misc_ahnqirajtrinket_04",
	smallEyeTentacles = "spell_shadow_siphonmana",
	smallClaw = "spell_nature_thorns",

	giantClaw = "spell_nature_thorns",
	giantEye = "inv_misc_eye_01",

	groundTremor = "spell_nature_earthquake",

	window = "inv_misc_pocketwatch_01",
	weakened = "spell_shadow_deadofnight",

	digestiveAcid = "ability_creature_disease_02",

	stomachTentacle = "inv_misc_ahnqirajtrinket_05",
}
local color = {
	startRandomBeams = "Cyan",
	eyeBeam = "Green",

	darkGlareCd = "Orange",
	darkGlareCast = "Red",
	darkGlareDur = "Red",

	smallEyeTentacles = "Blue",
	smallEyesDead = "Yellow",
	smallClaw = "Black",

	giantClaw = "Black",
	giantEye = "Cyan",

	groundTremor = "Yellow",

	window = "White",
	weakened = "White",

	stomachTentacle = "Magenta",
}
local syncName = {
	eyeBeam = "CThunEyeBeam" .. module.revision,

	smallEyeTentacles = "CThunSmallEyeTentaclesSpawn" .. module.revision,
	allSmallEyeTentaclesDead = "CThunAllSmallEyeTentaclesDead" .. module.revision,

	smallClaw = "CThunSmallClawTentacleSpawn" .. module.revision,

	phase2 = "CThunP2Start" .. module.revision,

	giantClaw = "CThunGiantClaw" .. module.revision,
	giantEye = "CThunGiantEye" .. module.revision,

	groundTremor = "CThunGroundTremor" .. module.revision,

	window = "CThunWindow" .. module.revision,

	weakened = "CThunWeakened" .. module.revision,
	weakenedOver = "CThunWeakenedOver2" .. module.revision,

	firstStomachTentacleDead = "CThunFleshTentacleDead2" .. module.revision,
}

module.proximityCheck = function(unit)
	return CheckInteractDistance(unit, 2)
end
module.proximitySilent = false

local doCheckForWipe = false
local cthunStarted = nil
local phase = "phase1"
local eyeTarget = nil

local firstStomachTentacleDead = nil
local secondTentacleLowWarn = nil
local firstTentacleHP = 100
local secondTentacleHP = 100

local smallEyeDead = 0
local smallEyeDeadCounter = 8

local lastspawn = 0

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE") --trigger_weakened

	--self:RegisterEvent("UNIT_HEALTH") --stomach tentacles hp

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_cthun_eyeBeam, trigger_giantEye_eyeBeam

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") --trigger_smallEyeTentacles, trigger_smallClaw, trigger_giantClaw, trigger_giantEye

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_groundTremor, trigger_digestiveAcid
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_groundTremor
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_groundTremor


	self:ThrottleSync(1, syncName.eyeBeam)

	self:ThrottleSync(10, syncName.smallEyeTentacles)
	self:ThrottleSync(10, syncName.allSmallEyeTentaclesDead)

	self:ThrottleSync(5, syncName.smallClaw)

	self:ThrottleSync(10, syncName.phase2)

	self:ThrottleSync(10, syncName.giantClaw)
	self:ThrottleSync(10, syncName.giantEye)

	self:ThrottleSync(3, syncName.groundTremor)

	self:ThrottleSync(3, syncName.window)

	self:ThrottleSync(10, syncName.weakened)
	self:ThrottleSync(10, syncName.weakenedOver)

	self:ThrottleSync(2, syncName.firstStomachTentacleDead)

	self:SetupMap()
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.core:IsModuleActive("Qiraji Mindslayer", "Ahn'Qiraj") then
		self.core:DisableModule("Qiraji Mindslayer", "Ahn'Qiraj")
	end

	doCheckForWipe = false
	cthunStarted = nil
	phase = "phase1"
	eyeTarget = nil

	firstStomachTentacleDead = nil
	secondTentacleLowWarn = nil
	firstTentacleHP = 100
	secondTentacleHP = 100

	smallEyeDead = 0
	smallEyeDeadCounter = 8

	lastspawn = 0

	if self.db.profile.map then
		cthunmap:Show()
	end

	if self.db.profile.cthuneyebeam then
		self:Bar(L["bar_startRandomBeams"], timer.p1_startRandomBeams, icon.giantEye, true, color.startRandomBeams)
	end

	if self.db.profile.darkglare then
		self:Bar(L["bar_darkGlareCd"], timer.darkGlareFirstCd, icon.darkGlare, true, color.darkGlareCd)
		self:ScheduleEvent("CthunDarkGlare", self.DarkGlare, timer.darkGlareFirstCd, self)
	end

	if self.db.profile.smalltentacle then
		self:Bar(L["bar_smallEyeTentacles"], timer.p1_smallEyeTentaclesFirstCd, icon.smallEyeTentacles, true, color.smallEyeTentacles)

		self:DelayedMessage(timer.p1_smallEyeTentaclesFirstCd - 3, L["msg_smallEyeTentaclesSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.p1_smallEyeTentaclesFirstCd - 3, "Alert")
	end

	if self.db.profile.smallclaw then
		self:Bar(L["bar_smallClaw"], timer.smallClaw, icon.smallClaw, true, color.smallClaw)
	end

	if self.db.profile.proximity then
		self:TriggerEvent("BigWigs_ShowProximity")
	end

	self:ScheduleRepeatingEvent("CthunCheckTarget", self.CheckTarget, 0.5, self)
end

function module:OnDisengage()
	cthunmap:Hide()

	self:TriggerEvent("BigWigs_HideProximity")
	self:TriggerEvent("BigWigs_StopDebuffTrack")

	self:CancelScheduledEvent("CthunP1Claw")
	self:CancelScheduledEvent("CthunDarkGlare")
	self:CancelScheduledEvent("CThunDelayedEyeBeamCheck")
	self:CancelScheduledEvent("CthunCheckTarget")
	self:CancelScheduledEvent("CThunCheckTentacleHP")
end

function module:MINIMAP_ZONE_CHANGED(msg)
	--The Scarab Wall when you release, then Gates of Ahn'Qiraj as you run back, then Ahn'Qiraj when you zone in
	if (GetMinimapZoneText() == "The Scarab Wall" or GetMinimapZoneText() == "Gates of Ahn'Qiraj") and self.core:IsModuleActive(module.translatedName) then
		self:TriggerEvent("BigWigs_RebootModule", module.translatedName)
		self:ResetModule()
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7f   [BigWigs]|r - Auto-Rebooting Module: " .. module.translatedName)
	end
end

function module:ResetModule()
	doCheckForWipe = false
	cthunStarted = nil
	phase = "phase1"
	eyeTarget = nil

	firstStomachTentacleDead = nil
	secondTentacleLowWarn = nil
	firstTentacleHP = 100
	secondTentacleHP = 100

	smallEyeDead = 0
	smallEyeDeadCounter = 8

	lastspawn = 0

	self:TriggerEvent("BigWigs_HideProximity")
	self:TriggerEvent("BigWigs_StopDebuffTrack")

	self:CancelScheduledEvent("CthunP1Claw")
	self:CancelScheduledEvent("CthunDarkGlare")
	self:CancelScheduledEvent("CThunDelayedEyeBeamCheck")
	self:CancelScheduledEvent("CthunCheckTarget")
	self:CancelScheduledEvent("CThunCheckTentacleHP")
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Eye of C'Thun")) then
		self:Sync(syncName.phase2)

	elseif (msg == string.format(UNITDIESOTHER, "Giant Claw Tentacle")) then
		self:Sync(syncName.window)

	elseif (msg == string.format(UNITDIESOTHER, "Giant Eye Tentacle")) then
		self:Sync(syncName.window)

	elseif (msg == string.format(UNITDIESOTHER, "Flesh Tentacle")) and not firstStomachTentacleDead then
		self:Sync(syncName.firstStomachTentacleDead)

	elseif (msg == string.format(UNITDIESOTHER, "Eye Tentacle")) then
		smallEyeDead = smallEyeDead + 1
		smallEyeDeadCounter = 8 - smallEyeDead
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_smallEyesDead"], smallEyeDeadCounter)
		if smallEyeDead >= 8 then
			self:Sync(syncName.allSmallEyeTentaclesDead)
		end
	end
end

function module:CheckForWipe(event)
	if doCheckForWipe then
		BigWigs:CheckForWipe(self)
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["trigger_weakened"]) then
		self:Sync(syncName.weakened)
	end
end

--[[
function module:UNIT_HEALTH(msg)
	if UnitName(msg) == "Flesh Tentacle" then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)

		if secondTentacleLowWarn == true and healthPct >= 20 then
			secondTentacleLowWarn = nil
			firstTentacleHP = 1
			secondTentacleHP = 100
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
		end

		if not firstStomachTentacleDead then
			if healthPct < firstTentacleHP then
				firstTentacleHP = healthPct
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
			elseif healthPct > firstTentacleHP and healthPct < secondTentacleHP then
				secondTentacleHP = healthPct
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
			end
		elseif firstStomachTentacleDead then
			firstTentacleHP = 1
			if healthPct < secondTentacleHP then
				secondTentacleHP = healthPct
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
				self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
			end
			if secondTentacleHP <= 20 and not secondTentacleLowWarn then
				self:Message("Second Tentacle at "..secondTentacleHP.."% HP")
				secondTentacleLowWarn = true
			end
		end
	end
end
]]--

function module:Event(msg)
	if msg == L["trigger_cthun_eyeBeam"] then
		if not cthunStarted then
			module:SendEngageSync()
		end
		self:Sync(syncName.eyeBeam)

	elseif msg == L["trigger_smallEyeTentacles"] then
		self:Sync(syncName.smallEyeTentacles)

	elseif msg == L["trigger_smallClaw"] then
		self:Sync(syncName.smallClaw)

	elseif msg == L["trigger_giantClaw"] then
		self:Sync(syncName.giantClaw)

	elseif msg == L["trigger_giantEye"] then
		self:Sync(syncName.giantEye)


	elseif msg == L["trigger_giantEye_eyeBeam"] then
		self:Sync(syncName.eyeBeam)

	elseif string.find(msg, L["trigger_groundTremor"]) then
		self:Sync(syncName.groundTremor)

	elseif string.find(msg, L["trigger_digestiveAcid"]) and self.db.profile.acid then
		local _, _, acidQty, _ = string.find(msg, L["trigger_digestiveAcid"])
		if tonumber(acidQty) >= 5 then
			self:DigestiveAcid(acidQty)
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.eyeBeam then
		self:EyeBeam()

	elseif sync == syncName.smallEyeTentacles and self.db.profile.smalltentacle then
		self:SmallEyeTentacles()
	elseif sync == syncName.allSmallEyeTentaclesDead and self.db.profile.smalltentacle then
		self:AllSmallEyeTentaclesDead()

	elseif sync == syncName.smallClaw and self.db.profile.smallclaw then
		self:SmallClaw()

	elseif sync == syncName.phase2 then
		self:Phase2()

	elseif sync == syncName.giantClaw then
		self:GiantClaw()

	elseif sync == syncName.giantEye then
		self:GiantEye()

	elseif sync == syncName.groundTremor and self.db.profile.groundtremor then
		self:GroundTremor()

	elseif sync == syncName.window and self.db.profile.window then
		self:Window()

	elseif sync == syncName.weakened then
		self:Weakened()
	elseif sync == syncName.weakenedOver then
		self:WeakenedOver()

	elseif sync == syncName.firstStomachTentacleDead and self.db.profile.stomachhp then
		self:FleshTentacleDead()

	end
end

function module:EyeBeam()
	self:ScheduleEvent("CThunDelayedEyeBeamCheck", self.DelayedEyeBeamCheck, 0.1, self) -- has to be done delayed since the target change is delayed
end
function module:DelayedEyeBeamCheck()
	local name = "Unknown"
	self:CheckTarget()

	if eyeTarget then
		name = eyeTarget

		if self.db.profile.raidicon and (IsRaidLeader() or IsRaidOfficer()) then
			for i = 1, GetNumRaidMembers() do
				if UnitName("raid" .. i) == name then
					SetRaidTarget("raid" .. i, 8)
				end
			end
		end

		if name == UnitName("player") then
			self:WarningSign(icon.eyeBeam, 2 - 0.1)
			SendChatMessage("Eye Beam On Me !", "SAY")
		else
			for i = 1, GetNumRaidMembers(), 1 do
				if name == UnitName('Raid' .. i) and CheckInteractDistance("Raid" .. i, 3) then
					if (phase == "phase1" and self.db.profile.cthuneyebeam) or (phase == "phase2" and self.db.profile.gianteyeeyebeam) then
						self:Message("Eye Beam on " .. name .. " ! Move away !", "Important", false, nil, false)
					end
				end
			end
		end
	end

	if (phase == "phase1" and self.db.profile.cthuneyebeam) or (phase == "phase2" and self.db.profile.gianteyeeyebeam) then
		self:Bar(L["bar_eyeBeam"] .. name, timer.eyeBeamCast - 0.1, icon.giantEye, true, color.eyeBeam)
	end
end
function module:CheckTarget()
	local newtarget = nil
	local enemy = "Eye of C'Thun"

	if phase == "phase2" then
		enemy = "Giant Eye Tentacle"
	end
	if UnitName("Target") == enemy then
		newtarget = UnitName("TargetTarget")
	else
		for i = 1, GetNumRaidMembers() do
			if UnitName("Raid" .. i .. "Target") == enemy then
				newtarget = UnitName("Raid" .. i .. "TargetTarget")
				break
			end
		end
	end
	if newtarget then
		eyeTarget = newtarget
	end
end

function module:DarkGlare()
	self:Bar(L["bar_darkGlareCasting"], timer.darkGlareCasting, icon.darkGlare, true, color.darkGlareCast)
	self:WarningSign(icon.darkGlare, timer.darkGlareCasting)
	self:Message(L["msg_darkGlareCasting"], "Urgent", false, nil, false)
	self:Sound("RunAway")

	self:DelayedBar(timer.darkGlareCasting, L["bar_darkGlareDur"], timer.darkGlareDur, icon.darkGlare, true, color.darkGlareDur)
	self:DelayedMessage(timer.darkGlareCasting + timer.darkGlareDur - 5, L["msg_darkGlareEndsSoon"], "Urgent", false, nil, true)
	self:DelayedBar(timer.darkGlareCasting + timer.darkGlareDur, L["bar_darkGlareCd"], timer.darkGlareCd - timer.darkGlareCasting - timer.darkGlareDur, icon.darkGlare, true, color.darkGlareCd)

	self:ScheduleEvent("CthunDarkGlare", self.DarkGlare, timer.darkGlareCd, self)
end

function module:SmallEyeTentacles()
	self:CancelDelayedMessage(L["msg_smallEyeTentaclesSoon"])
	self:CancelDelayedSound("Alert")

	self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_smallEyesDead"], 8, "Interface\\Icons\\" .. icon.smallEyeTentacles, true, color.smallEyesDead)
	self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_smallEyesDead"], (8 - 0.1))

	smallEyeDead = 0
	smallEyeDeadCounter = 8

	if phase == "phase1" then
		self:Bar(L["bar_smallEyeTentacles"], timer.p1_smallEyeTentaclesCd, icon.smallEyeTentacles, true, color.smallEyeTentacles)

		self:DelayedMessage(timer.p1_smallEyeTentaclesCd - 3, L["msg_smallEyeTentaclesSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.p1_smallEyeTentaclesCd - 3, "Alert")

	elseif phase == "phase2" then
		self:Bar(L["bar_smallEyeTentacles"], timer.p2_smallEyeTentaclesCd, icon.smallEyeTentacles, true, color.smallEyeTentacles)

		self:DelayedMessage(timer.p2_smallEyeTentaclesCd - 3, L["msg_smallEyeTentaclesSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.p2_smallEyeTentaclesCd - 3, "Alert")
	end
end

function module:AllSmallEyeTentaclesDead()
	smallEyeDead = 0
	smallEyeDeadCounter = 8
	self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_smallEyesDead"])
end

function module:SmallClaw()
	self:Bar(L["bar_smallClaw"], timer.smallClaw, icon.smallClaw, true, color.smallClaw)
end

function module:Phase2()
	phase = "phase2"

	doCheckForWipe = false -- disable wipe check since we get out of combat, enable it later again

	self:Message(L["msg_phase2"], "Positive", false, nil, false)

	-- cancel C'thun map
	self:ScheduleEvent("hideCthunMap", function()
		cthunmap:Hide()
	end, 8, self)

	-- cancel dark glare
	self:CancelScheduledEvent("CthunDarkGlare")
	self:CancelDelayedBar(L["bar_darkGlareCd"])
	self:CancelDelayedBar(L["bar_darkGlareDur"])
	self:RemoveBar(L["bar_darkGlareCasting"])
	self:RemoveBar(L["bar_darkGlareCd"])
	self:RemoveBar(L["bar_darkGlareDur"])
	self:CancelDelayedMessage(L["msg_darkGlareEndsSoon"])
	self:RemoveWarningSign(icon.darkGlare)

	-- cancel small eye tentacles
	self:CancelDelayedMessage(L["msg_smallEyeTentaclesSoon"])
	self:CancelDelayedSound("Alert")
	self:RemoveBar(L["bar_smallEyeTentacles"])

	-- cancel small claw tentacle
	self:RemoveBar(L["bar_smallClaw"])

	if self.db.profile.smalltentacle then
		self:DelayedMessage(timer.p2_smallEyeTentaclesFirstCd - 3, L["msg_smallEyeTentaclesSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.p2_smallEyeTentaclesFirstCd - 3, "Alert")
		self:Bar(L["bar_smallEyeTentacles"], timer.p2_smallEyeTentaclesFirstCd, icon.smallEyeTentacles, true, color.smallEyeTentacles)
	end

	if self.db.profile.gianttimer then
		self:Bar(L["bar_giantClaw"], timer.giantClawFirstCd, icon.giantClaw, true, color.giantClaw)
	end

	if self.db.profile.stomachhp then
		firstStomachTentacleDead = nil
		secondTentacleLowWarn = nil
		firstTentacleHP = 100
		secondTentacleHP = 100

		self:TriggerEvent("BigWigs_StartHPBar", self, L["hpBar_firstTentacle"], 100, "Interface\\Icons\\" .. icon.stomachTentacle, true, color.stomachTentacle)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 0)
		self:TriggerEvent("BigWigs_StartHPBar", self, L["hpBar_secondTentacle"], 100, "Interface\\Icons\\" .. icon.stomachTentacle, true, color.stomachTentacle)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 0)

		self:ScheduleRepeatingEvent("CThunCheckTentacleHP", self.CheckTentacleHP, 0.5, self)
	end

	if self.db.profile.stomachplayers then
		self:TriggerEvent("BigWigs_StartDebuffTrack", self:ToString(), "Interface\\Icons\\Ability_Creature_Disease_02", L["frameHeader_playersInStomach"])
	end
end

function module:GiantClaw()
	lastspawn = GetTime()

	doCheckForWipe = true

	if self.db.profile.gianttimer then
		self:Bar(L["bar_giantEye"], timer.giantEyeCd, icon.giantEye, true, color.giantEye)
	end
end

function module:GiantEye()
	lastspawn = GetTime()

	if self.db.profile.gianttimer then
		self:Bar(L["bar_giantClaw"], timer.giantClawCd, icon.giantClaw, true, color.giantClaw)
	end
end

function module:GroundTremor()
	self:Bar(L["bar_groundTremorDur"], timer.groundTremor, icon.groundTremor, true, color.groundTremor)
end

function module:Window()
	local window = (lastspawn + timer.p2_timeBetweenGiantSpawn - 2) - GetTime()
	if window > 0 then
		self:Bar(L["bar_windowOfOpportunity"], window, icon.window, true, color.window)
	end
end

function module:Weakened()
	firstStomachTentacleDead = nil
	secondTentacleLowWarn = nil
	firstTentacleHP = 100
	secondTentacleHP = 100
	self:TriggerEvent("BigWigs_StopHPBar", self, L["hpBar_firstTentacle"])
	self:TriggerEvent("BigWigs_StopHPBar", self, L["hpBar_secondTentacle"])

	self:CancelDelayedMessage(L["msg_smallEyeTentaclesSoon"])
	self:CancelDelayedSound("Alert")
	self:RemoveBar(L["bar_smallEyeTentacles"])

	self:RemoveBar(L["bar_giantEye"])
	self:RemoveBar(L["bar_giantClaw"])

	if self.db.profile.weakened then
		self:Message(L["msg_weakened"], "Positive", false, nil, false)
		self:Sound("Murloc")
		self:Bar(L["bar_weakened"], timer.weakenedDur, icon.weakened, true, color.weakened)
	end

	self:DelayedSync(timer.weakenedDur, syncName.weakenedOver)
end

function module:WeakenedOver()
	self:CancelDelayedSync(syncName.weakenedOver)
	self:RemoveBar(L["bar_weakened"])

	if self.db.profile.weakened then
		self:Message(L["msg_weakenedFade"], "Important", false, nil, false)
	end

	if self.db.profile.smalltentacle then
		self:Bar(L["bar_smallEyeTentacles"], timer.p2_smallEyeTentaclesAfterWeakenCd, icon.smallEyeTentacles, true, color.smallEyeTentacles)
		self:DelayedMessage(timer.p2_smallEyeTentaclesAfterWeakenCd - 3, L["msg_smallEyeTentaclesSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.p2_smallEyeTentaclesAfterWeakenCd - 3, "Alert")
	end

	if self.db.profile.gianttimer then
		self:Bar(L["bar_giantClaw"], timer.giantClawAfterWeakenCd, icon.giantClaw, true, color.giantClaw)
	end

	if self.db.profile.stomachhp then
		firstStomachTentacleDead = nil
		secondTentacleLowWarn = nil
		firstTentacleHP = 100
		secondTentacleHP = 100

		self:TriggerEvent("BigWigs_StartHPBar", self, L["hpBar_firstTentacle"], 100, "Interface\\Icons\\" .. icon.stomachTentacle, true, color.stomachTentacle)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 0)
		self:TriggerEvent("BigWigs_StartHPBar", self, L["hpBar_secondTentacle"], 100, "Interface\\Icons\\" .. icon.stomachTentacle, true, color.stomachTentacle)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 0)
	end
end

function module:DigestiveAcid(rest)
	self:Message(rest .. L["msg_digestiveAcid"], "Personal", false, nil, false)
	self:WarningSign(icon.digestiveAcid, 0.7)
end

function module:FleshTentacleDead()
	if not firstStomachTentacleDead then
		firstStomachTentacleDead = true
		secondTentacleLowWarn = nil

		self:Message(L["msg_firstTentacleDead"], "Important", false, nil, false)

		firstTentacleHP = 1
		secondTentacleHP = 100
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
	end
end

function module:CheckTentacleHP()
	local health
	if UnitName("Target") == "Flesh Tentacle" and not UnitIsDeadOrGhost("Target") then
		health = math.floor(UnitHealth("Target") / UnitHealthMax("Target") * 100)
	else
		for i = 1, GetNumRaidMembers() do
			if UnitName("Raid" .. i .. "Target") == "Flesh Tentacle" and not UnitIsDeadOrGhost("Raid" .. i .. "Target") then
				health = math.floor(UnitHealth("Raid" .. i .. "Target") / UnitHealthMax("Raid" .. i .. "Target") * 100)
				break
			end
		end
	end

	if secondTentacleLowWarn == true and health and health >= 20 then
		secondTentacleLowWarn = nil
		firstTentacleHP = 1
		secondTentacleHP = 100
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
		self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
	end

	if not firstStomachTentacleDead then
		if health and health < firstTentacleHP then
			firstTentacleHP = health
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
		elseif health and health > firstTentacleHP and health < secondTentacleHP then
			secondTentacleHP = health
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
		end
	elseif firstStomachTentacleDead then
		firstTentacleHP = 1
		if health and health < secondTentacleHP then
			secondTentacleHP = health
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_firstTentacle"], 100 - firstTentacleHP)
			self:TriggerEvent("BigWigs_SetHPBar", self, L["hpBar_secondTentacle"], 100 - secondTentacleHP)
		end
		if secondTentacleHP <= 20 and not secondTentacleLowWarn then
			self:Message("Second Tentacle at " .. secondTentacleHP .. "% HP")
			secondTentacleLowWarn = true
		end
	end
end


-----------------------
-- Utility Functions --
-----------------------

function GetCthunCoords(unit)
	local posX, posY = GetPlayerMapPosition(unit)
	posX = (18.25 * posX - 5.55) * cthunmap.map:GetWidth()
	posY = (-12.1666666667 * posY + 5.5) * cthunmap.map:GetHeight()
	return posX, posY
end

function UpdateCthunMap()
	if not cthunmap.map then
		return
	end
	local tooltipText = ""
	local tooltipAnchor
	for i = 1, 40 do
		local coordX, coordY = GetCthunCoords("raid" .. i)
		if coordX == 0 and coordY == 0 then
			cthunmap.map.unit[i]:Hide()
		else
			cthunmap.map.unit[i]:Show()
			cthunmap.map.unit[i]:SetPoint("CENTER", cthunmap.map, "TOPLEFT", coordX, coordY)
			CthunMapUnitIcon(i)
			if MouseIsOver(cthunmap.map.unit[i]) and GetRaidRosterInfo(i) ~= UnitName("player") then
				if GetRaidTargetIndex("raid" .. i) then
					tooltipText = tooltipText .. GetRaidRosterInfo(i) .. SpellstatusV2IndexToIcon[GetRaidTargetIndex("raid" .. i)] .. "\n"
				else
					tooltipText = tooltipText .. GetRaidRosterInfo(i) .. "\n"
				end
				tooltipAnchor = cthunmap.map.unit[i]
			end
		end
	end
	if tooltipText ~= "" then
		cthunmap.tooltip:Show()
		cthunmap.tooltip:SetOwner(tooltipAnchor, "ANCHOR_RIGHT");
		cthunmap.tooltip:SetText(tooltipText)
	else
		cthunmap.tooltip:Hide()
	end
end

function CthunMapUnitIcon(i)
	if GetRaidRosterInfo(i) == UnitName("player") then
		cthunmap.map.unit[i]:SetWidth(32)
		cthunmap.map.unit[i]:SetHeight(32)

		if BigWigsProximity:PlayerCanChain() then
			cthunmap.map.unit[i].texture:SetTexture("Interface\\Addons\\BigWigs\\Textures\\PlayerMapIconRed")
		else
			cthunmap.map.unit[i].texture:SetTexture("Interface\\Addons\\BigWigs\\Textures\\PlayerMapIconGreen")
		end
	else
		cthunmap.map.unit[i]:SetWidth(16)
		cthunmap.map.unit[i]:SetHeight(16)
		cthunmap.map.unit[i].texture:SetTexture("Interface\\WorldMap\\WorldMapPartyIcon")
	end
end

function module:SetupMap()
	if cthunmap then
		return
	end
	cthunmap = CreateFrame("Frame", "BigWigsCThunMap", UIParent)
	cthunmap:SetWidth(200)
	cthunmap:SetHeight(32)

	cthunmap:SetBackdrop({
		-- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Addons\\BigWigs\\Textures\\otravi-semi-full-border", edgeSize = 32,
		--edgeFile = "", edgeSize = 32,
		insets = { left = 1, right = 1, top = 20, bottom = 1 },
	})
	cthunmap:SetBackdropBorderColor(1.0, 1.0, 1.0)
	cthunmap:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
	cthunmap:ClearAllPoints()
	cthunmap:SetPoint("TOPLEFT", nil, "TOPLEFT", self.db.profile.mapX, self.db.profile.mapY)
	cthunmap:EnableMouse(true)
	cthunmap:SetClampedToScreen(true)
	cthunmap:RegisterForDrag("LeftButton")
	cthunmap:SetMovable(true)
	cthunmap:SetFrameStrata("LOW")
	cthunmap:SetAlpha(self.db.profile.mapAlpha or 1.0)
	cthunmap:SetScale(self.db.profile.mapScale or 1.0)
	cthunmap:SetScript("OnDragStart", function()
		cthunmap:StartMoving()
	end)
	cthunmap:SetScript("OnDragStop", function()
		cthunmap:StopMovingOrSizing();
		self.db.profile.mapX = cthunmap:GetLeft();
		self.db.profile.mapY = cthunmap:GetTop()
	end)
	cthunmap:SetScript("OnUpdate", UpdateCthunMap)
	cthunmap:Hide()

	cthunmap.tooltip = CreateFrame("GameTooltip", "CthunMapTooltip", cthunmap, "GameTooltipTemplate")

	cthunmap.cheader = cthunmap:CreateFontString(nil, "OVERLAY")
	cthunmap.cheader:ClearAllPoints()
	cthunmap.cheader:SetWidth(190)
	cthunmap.cheader:SetHeight(15)
	cthunmap.cheader:SetPoint("TOP", cthunmap, "TOP", 0, -14)
	cthunmap.cheader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	cthunmap.cheader:SetJustifyH("LEFT")
	cthunmap.cheader:SetText("C'thun Map")
	cthunmap.cheader:SetShadowOffset(.8, -.8)
	cthunmap.cheader:SetShadowColor(0, 0, 0, 1)

	cthunmap.closebutton = CreateFrame("Button", nil, cthunmap)
	cthunmap.closebutton:SetWidth(20)
	cthunmap.closebutton:SetHeight(14)
	cthunmap.closebutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	cthunmap.closebutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	cthunmap.closebutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	cthunmap.closebutton:SetPoint("TOPRIGHT", cthunmap, "TOPRIGHT", -7, -15)
	cthunmap.closebutton:SetScript("OnClick", function()
		cthunmap:Hide()
	end)

	cthunmap.alphabutton = CreateFrame("Button", nil, cthunmap)
	cthunmap.alphabutton:SetWidth(20)
	cthunmap.alphabutton:SetHeight(14)
	cthunmap.alphabutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	cthunmap.alphabutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	cthunmap.alphabutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	cthunmap.alphabutton:SetPoint("TOPRIGHT", cthunmap, "TOPRIGHT", -27, -15)
	cthunmap.alphabutton:SetScript("OnClick", function()
		if not self.db.profile.mapAlpha or (self.db.profile.mapAlpha < 0.3) then
			self.db.profile.mapAlpha = 1.0
		else
			self.db.profile.mapAlpha = self.db.profile.mapAlpha - 0.2
		end
		cthunmap:SetAlpha(self.db.profile.mapAlpha)
	end)

	cthunmap.scalebutton = CreateFrame("Button", nil, cthunmap)
	cthunmap.scalebutton:SetWidth(20)
	cthunmap.scalebutton:SetHeight(14)
	cthunmap.scalebutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	cthunmap.scalebutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	cthunmap.scalebutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	cthunmap.scalebutton:SetPoint("TOPRIGHT", cthunmap, "TOPRIGHT", -47, -15)
	cthunmap.scalebutton:SetScript("OnClick", function()
		local oldScale = (self.db.profile.mapScale or 1.0)
		if not self.db.profile.mapScale then
			self.db.profile.mapScale = 1.0
		elseif (self.db.profile.mapScale > 2.0) then
			self.db.profile.mapScale = 0.75
		else
			self.db.profile.mapScale = self.db.profile.mapScale + 0.25
		end
		cthunmap:SetScale(self.db.profile.mapScale)
		self.db.profile.mapX = self.db.profile.mapX * oldScale / self.db.profile.mapScale
		self.db.profile.mapY = self.db.profile.mapY * oldScale / self.db.profile.mapScale
		cthunmap:ClearAllPoints()
		cthunmap:SetPoint("TOPLEFT", nil, "TOPLEFT", self.db.profile.mapX, self.db.profile.mapY)
	end)

	cthunmap.map = CreateFrame("Frame", "CthunMapAnchor", cthunmap)
	cthunmap.map:SetPoint("TOPLEFT", cthunmap, "BOTTOMLEFT", 0, 0)
	cthunmap.map:SetWidth(cthunmap:GetWidth())
	cthunmap.map:SetHeight(200)
	cthunmap.map.texture = cthunmap.map:CreateTexture(nil, "BACKGROUND")
	cthunmap.map.texture:SetAllPoints(cthunmap.map)
	cthunmap.map.texture:SetTexture("Interface\\Addons\\BigWigs\\Textures\\cthunmaptexture")

	cthunmap.map.unit = {}
	for i = 1, 40 do
		cthunmap.map.unit[i] = CreateFrame("Frame", "CthunMapUnit" .. i, cthunmap.map)
		--		cthunmap.map.unit[i]:EnableMouse(true)
		--		cthunmap.map.unit[i]: SetPoint("TOPLEFT", cthunmap.map, "TOPLEFT")
		cthunmap.map.unit[i].texture = cthunmap.map.unit[i]:CreateTexture(nil, "OVERLAY")
		cthunmap.map.unit[i].texture:SetAllPoints(cthunmap.map.unit[i])
		--		cthunmap.map.unit[i]:SetScript("OnLeave", function() GameTooltip:Hide(); DEFAULT_CHAT_FRAME:AddMessage("leave hover") end )
		CthunMapUnitIcon(i)
	end
end
