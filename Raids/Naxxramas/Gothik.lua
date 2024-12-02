
local module, L = BigWigs:ModuleDeclaration("Gothik the Harvester", "Naxxramas")

module.revision = 30084
module.enabletrigger = module.translatedName
module.toggleoptions = {"room", -1, "add", "adddeath", "bosskill"}
module.wipemobs = {
	"Unrelenting Rider",
	"Unrelenting Deathknight",
	"Unrelenting Trainee",
	"Spectral Rider",
	"Spectral Deathknight",
	"Spectral Trainee",
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gothik",

	room_cmd = "room",
	room_name = "Room Arrival Alert",
	room_desc = "Warn for Gothik Teleporting in the Room",

	add_cmd = "add",
	add_name = "Adds Spawn Alert",
	add_desc = "Warn for Adds Spawns",

	adddeath_cmd = "adddeath",
	adddeath_name = "Adds Death Alert",
	adddeath_desc = "Warn for Adds Deaths",


	trigger_engage = "Brazenly you have disregarded powers beyond your understanding.",
	trigger_bossDead = "I... am... undone.",
	
	name_trainee = "Unrelenting Trainee",
	name_traineeSpectral = "Spectral Trainee",
	bar_trainee = "Trainee - ",
	msg_traineeSoon = "/11 Trainees in 3 seconds",
	
	name_deathKnight = "Unrelenting Deathknight",
	name_deathKnightSpectral = "Spectral Deathknight",
	bar_dk = "Deathknight - ",
	msg_dkSoon = "/7 Deathknight in 3 seconds",
	msg_dkDead = "Death Knight dead!",
	
	name_rider = "Unrelenting Rider",
	name_riderSpectral = "Spectral Rider",
	bar_rider = "Rider - ",
	msg_riderSoon = "/4 Rider in 3 seconds",
	msg_riderDead = "Rider dead!",
	
	trigger_inRoom = "I have waited long enough! Now, you face the harvester of souls!",
	bar_inRoom = "In Room",
	msg_inRoom = "Gothik the Harvester teleports into the Fray!",
	msg_inRoom10 = "Gothik Incoming in 10 seconds",

	teleporttext = "Teleport",

	msg_gateOpen = "The Central gate opens!",
} end )

local timer = {
	inroom = 274, --4:34
	
	firstTrainee = 24,
	trainee = 20,
	
	firstDeathknight = 74, --1:14
	deathknight = 25,
	
	firstRider = 134, --2:14
	rider = 30,
	sideteleport = 15,
}
local icon = {
	inroom = "Spell_Arcane_Blink",
	trainee = "Ability_Seal",
	deathknight = "INV_Boots_Plate_08",
	rider = "Spell_Shadow_DeathPact",
}
local color = {
	inroom = "White",
	trainee = "Green",
	deathknight = "Yellow",
	rider = "Red",
}
local syncName = {
	inRoom = "GothikInRoom"..module.revision,
	gateOpen = "GothikGateOpen"..module.revision,
}

local numTrainees = 1
local numDeathknights = 1
local numRiders = 1
local gateOpen = nil

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:ThrottleSync(10, syncName.inRoom)
	self:ThrottleSync(10, syncName.gateOpen)
end

function module:OnSetup()
	self.started = nil
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.core:IsModuleActive("Deathknight Cavalier", "Naxxramas") then self.core:DisableModule("Deathknight Cavalier", "Naxxramas") end
	
	numTrainees = 1
	numDeathknights = 1
	numRiders = 1
	
	if self.db.profile.room then
		self:Bar(L["bar_inRoom"], timer.inroom, icon.inroom, true, color.inroom)
		
		self:DelayedMessage(timer.inroom - 10, L["msg_inRoom10"], "Important", false, nil, false)
	end

	if self.db.profile.add then
		self:Bar(L["bar_trainee"]..numTrainees, timer.firstTrainee, icon.trainee, true, color.trainee)
		self:Bar(L["bar_dk"]..numDeathknights, timer.firstDeathknight, icon.deathknight, true, color.deathknight)
		self:Bar(L["bar_rider"]..numRiders, timer.firstRider, icon.rider, true, color.rider)
		
		self:DelayedMessage(timer.firstTrainee - 3, numTrainees..L["msg_traineeSoon"], "Attention", false, nil, false)
		self:DelayedMessage(timer.firstDeathknight - 3, numDeathknights..L["msg_dkSoon"], "Urgent", false, nil, false)
		self:DelayedMessage(timer.firstRider - 3, numRiders..L["msg_riderSoon"], "Important", false, nil, false)

		self:ScheduleEvent("GothikTraineeRepop1", self.Trainee, timer.firstTrainee, self)
		self:ScheduleEvent("GothikDkRepop1", self.DeathKnight, timer.firstDeathknight, self)
		self:ScheduleEvent("GothikRiderRepop1", self.Rider, timer.firstRider, self)
	end
end

function module:OnDisengage()
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() == "Eastern Plaguelands" and self.core:IsModuleActive(module.translatedName) then
		self:TriggerEvent("BigWigs_RebootModule", module.translatedName)
		self:ResetModule()
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7f   [BigWigs]|r - Auto-Rebooting Module: "..module.translatedName)
	end
end

function module:ResetModule()
	numTrainees = 1
	numDeathknights = 1
	numRiders = 1
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct <= 30 and gateOpen == nil then
			self:Sync(syncName.gateOpen)
			gateOpen = true
		elseif healthPct > 30 and gateOpen == true then
			gateOpen = nil
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
		
	elseif msg == L["trigger_inRoom"] then
		self:Sync(syncName.inRoom)
		self:Bar(L["teleporttext"], timer.sideteleport, icon.inroom)
	elseif string.find(msg, L["trigger_bossDead"]) then
		self:SendBossDeathSync()
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if msg == string.format(UNITDIESOTHER, "Unrelenting Rider") and self.db.profile.adddeath then
		self:Message(L["msg_riderDead"], "Important", false, nil, false)
	
	elseif msg == string.format(UNITDIESOTHER, "Unrelenting Deathknight") and self.db.profile.adddeath then
		self:Message(L["msg_dkDead"], "Important", false, nil, false)
	end
end

--[[--debug
function module:Event(msg)
	if msg == "engage" then
		module:SendEngageSync()
	end
	
end
]]

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.inRoom and self.db.profile.room then
		self:InRoom()
	elseif sync == syncName.gateOpen and self.db.profile.room then
		self:GateOpen()
	end
end


function module:InRoom()
	self:RemoveBar(L["bar_inRoom"])
	self:CancelDelayedMessage(L["msg_inRoom10"])
	
	self:ResetModule()
	
	--self:Message(L["msg_inRoom"], "Important", false, nil, false) --useless, there is already an in-game message
end

function module:GateOpen()
	--self:Message(L["msg_gateOpen"], "Important", false, nil, false) --useless, there is already an in-game message
end

function module:Trainee()
	if numTrainees == 1 then
		self:ScheduleRepeatingEvent("GothikTraineeRepop", self.Trainee, timer.trainee, self)
	end
	
	numTrainees = numTrainees + 1
	
	self:Bar(L["bar_trainee"]..numTrainees, timer.trainee, icon.trainee, true, color.trainee)
	self:DelayedMessage(timer.trainee - 3, numTrainees..L["msg_traineeSoon"], "Attention", false, nil, false)
	
	if numTrainees >= 11 then
		self:CancelScheduledEvent("GothikTraineeRepop")
	end
end

function module:DeathKnight()
	if numDeathknights == 1 then
		self:ScheduleRepeatingEvent("GothikDkRepop", self.DeathKnight, timer.deathknight, self)
	end
	
	numDeathknights = numDeathknights + 1
	
	self:Bar(L["bar_dk"]..numDeathknights, timer.deathknight, icon.deathknight, true, color.deathknight)
	self:DelayedMessage(timer.deathknight - 3, numDeathknights..L["msg_dkSoon"], "Urgent", false, nil, false)
	
	if numDeathknights >= 7 then
		self:CancelScheduledEvent("GothikDkRepop")
	end
end

function module:Rider()
	if numRiders == 1 then
		self:ScheduleRepeatingEvent("GothikRiderRepop", self.Rider, timer.rider, self)
	end
	
	numRiders = numRiders + 1
	
	self:Bar(L["bar_rider"]..numRiders, timer.rider, icon.rider, true, color.rider)
	self:DelayedMessage(timer.rider - 3, numRiders..L["msg_riderSoon"], "Important", false, nil, false)
	
	if numRiders >= 4 then
		self:CancelScheduledEvent("GothikRiderRepop")
	end
end
