local module, L = BigWigs:ModuleDeclaration("Alterac Valley", "Alterac Valley")

module.revision = 30094
module.enabletrigger = {}
module.toggleoptions = {"towers", "gy", "mine", "rez", "start", "captain", "korrak", "gameend", "lord", "boss"}

L:RegisterTranslations("enUS", function()
	return {
	cmd = "Alterac",
	
	towers_cmd = "towers",
	towers_name = "Towers Alerts",
	towers_desc = "Warn for Towers.",

	gy_cmd = "gy",
	gy_name = "Graveyards Alerts",
	gy_desc = "Warn for Graveyards.",
	
	mine_cmd = "mine",
	mine_name = "Mine Alerts",
	mine_desc = "Warn for Mines.",
	
	rez_cmd = "rez",
	rez_name = "Resurrection Timer",
	rez_desc = "Timer for Spirit Resurrection.",
	
	start_cmd = "start",
	start_name = "Game Start Timer",
	start_desc = "Timer for the start of the game.",
	
	captain_cmd = "captain",
	captain_name = "Captains Death Alerts",
	captain_desc = "Warn for Captains' Death.",
	
	korrak_cmd = "korrak",
	korrak_name = "Korrak Death Alerts",
	korrak_desc = "Warn for Korrak's Death.",
	
	gameend_cmd = "gameend",
	gameend_name = "Game End (too few players) Alerts",
	gameend_desc = "Timer for Game's End due to too few players.",
	
	lord_cmd = "lord",
	lord_name = "Lords (Ivus and Lokholar) Alerts",
	lord_desc = "Warn for Ivus the Forest Lord and Lokholar the Icelord Summons.",
	
	boss_cmd = "boss",
	boss_name = "Bosses HP Alerts",
	boss_desc = "Warn for Bosses' Health status.",
	
	
	--lord trigger
	
	--rez trigger
		--activate check on death -> scan for not dead, when not dead -> expect this to be the timer
		--getting rez'd / corpse rez / canceling spirit rez / ankh etc
	
	trigger_gyUnderAttack = "(.+) is under attack! If left unchecked, the (.+) will capture it!", --CHAT_MSG_MONSTER_YELL
	trigger_towerUnderAttack = "(.+) is under attack! If left unchecked, the (.+) will destroy it!", --CHAT_MSG_MONSTER_YELL
	trigger_defend = "(.+) was taken by the (.+)!", --CHAT_MSG_MONSTER_YELL
	
	trigger_mine = "The (.+) has taken the (.+)! Its supplies will now be used for reinforcements!", --CHAT_MSG_MONSTER_YELL
	
	msg_DrekHp = "Drek'Thar HP: ",
	msg_VannHp = "Vandarr HP: ",
	
	msg_galvDead = "Captain Galvangar Died",
	msg_balindaDead = "Captain Balinda Stonehearth Died",
	msg_korrakDead = "Korrak the Bloodrager Died",
	
	trigger_gameStart = "(.+) (.+) until the battle for Alterac Valley begins.",
	trigger_gameHasStarted = "The battle for Alterac Valley has begun!",
	bar_gameStart = "Game Start",
	
	--msg to be confirmed once it gets below 2 minutes
	trigger_gameEnd = "Not enough players. This game will close in (.+) (.+).",
	bar_gameEnd = "Game Close",
    }
end)

local timer = {
    towers = 60*5,
    graveyards = 60*5,
	mines = 60*5, -- to be confirmed
}
local icon = {
    alliance = "inv_bannerpvp_02",
    horde = "inv_bannerpvp_01",
	
	gameStart = "inv_misc_pocketwatch_01",
	gameEnd = "inv_misc_pocketwatch_01",
}
local color = {
	alliance = "Blue",
	horde = "Red",
	
	gameStart = "White",
	gameEnd = "White",
}
local syncName = {
    gy = "AV_GraveYards"..module.revision,
    tower = "AV_Towers"..module.revision,
	
	drek50 = "AV_Drek50"..module.revision,
	drek40 = "AV_Drek40"..module.revision,
	drek30 = "AV_Drek30"..module.revision,
	drek20 = "AV_Drek20"..module.revision,
	drek10 = "AV_Drek10"..module.revision,
	
	vann50 = "AV_Vann50"..module.revision,
	vann40 = "AV_Vann40"..module.revision,
	vann30 = "AV_Vann30"..module.revision,
	vann20 = "AV_Vann20"..module.revision,
	vann10 = "AV_Vann10"..module.revision,
	
	galvDead = "AV_GalvDead"..module.revision,
	balindaDead = "AV_BalindaDead"..module.revision,
	korrakDead = "AV_KorrakDead"..module.revision,
	
	gameStart = "AV_GameStart"..module.revision,
	gameStarted = "AV_GameStarted"..module.revision,
	
	gameEnd = "AV_GameEnd"..module.revision,
	countPlayers = "AV_CountPlayers"..module.revision,
}

local mustRebootModule = nil

function module:OnRegister()
	--self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	--self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
    --self:RegisterEvent("CHAT_MSG_SAY") --debug
	
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
	
	--self:RegisterEvent("CHAT_MSG_BATTLEGROUND")
	--self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
	--self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
	
	
	self:RegisterEvent("UNIT_HEALTH")
	
    self:ThrottleSync(8, syncName.gy)
    self:ThrottleSync(8, syncName.tower)
	
	self:ThrottleSync(8, syncName.drek50)
	self:ThrottleSync(8, syncName.drek40)
	self:ThrottleSync(8, syncName.drek30)
	self:ThrottleSync(8, syncName.drek20)
	self:ThrottleSync(8, syncName.drek10)
	
	self:ThrottleSync(8, syncName.vann50)
	self:ThrottleSync(8, syncName.vann40)
	self:ThrottleSync(8, syncName.vann30)
	self:ThrottleSync(8, syncName.vann20)
	self:ThrottleSync(8, syncName.vann10)
	
	self:ThrottleSync(8, syncName.galvDead)
	self:ThrottleSync(8, syncName.balindaDead)
	self:ThrottleSync(8, syncName.korrakDead)
	
	self:ThrottleSync(8, syncName.gameStart)
	self:ThrottleSync(8, syncName.gameStarted)
	
	self:ThrottleSync(8, syncName.gameEnd)
	self:ThrottleSync(4, syncName.countPlayers)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CheckForWipe(event)
end

function module:CHAT_MSG_MONSTER_YELL(msg)
    if string.find(msg, L["trigger_gyUnderAttack"]) then
		local _, _, gy, faction = string.find(msg, L["trigger_gyUnderAttack"])
		if gy and faction then
			
			self:RemoveBar(gy)
			
			if faction == "Alliance" then
				self:Bar(gy, timer.graveyards, icon.alliance, true, color.alliance)
			elseif faction == "Horde" then
				self:Bar(gy, timer.graveyards, icon.horde, true, color.horde)
			end
		end
	
	elseif string.find(msg, L["trigger_towerUnderAttack"]) then
		local _, _, tower, faction = string.find(msg, L["trigger_towerUnderAttack"])
		if tower and faction then
			
			self:RemoveBar(tower)
			
			if faction == "Alliance" then
				self:Bar(tower, timer.towers, icon.alliance, true, color.alliance)
			elseif faction == "Horde" then
				self:Bar(tower, timer.towers, icon.horde, true, color.horde)
			end
		end
	
	elseif string.find(msg, L["trigger_defend"]) then
		local _, _, obj, faction = string.find(msg, L["trigger_defend"])
		if obj then 
			self:RemoveBar(obj)
		end
		
	elseif string.find(msg, L["trigger_mine"]) then
		local _, _, faction, mine = string.find(msg, L["trigger_mine"])
		if mine and faction then
			
			self:RemoveBar(mine)
			
			if faction == "Alliance" then
				self:Bar(mine, timer.mines, icon.alliance, true, color.alliance)
			elseif faction == "Horde" then
				self:Bar(mine, timer.mines, icon.horde, true, color.horde)
			end
		end
	end
end

function module:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
	if string.find(msg, L["trigger_gameStart"]) then
		local _, _, startTime, minSec = string.find(msg, L["trigger_gameStart"])
		if minSec == "minute" then
			startTime = (tonumber(startTime) * 60)
		elseif minSec == "seconds" then
			startTime = tonumber(startTime)
		end
		self:Sync(syncName.gameStart .. " " .. startTime)
	
	elseif msg == L["trigger_gameHasStarted"] then
		self:Sync(syncName.gameStarted)
	end
end

function module:CHAT_MSG_SYSTEM(msg)
	if string.find(msg, L["trigger_gameEnd"]) then
		local _, _, endTime, minSec = string.find(msg, L["trigger_gameEnd"])
		if minSec == "mins" then
			endTime = (tonumber(endTime) * 60)
		elseif minSec == "secs" then
			endTime = tonumber(endTime)
		end
		self:Sync(syncName.gameEnd .. " " .. endTime)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == "Drek'Thar" then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		
		if healthPct >= 48 and healthPct <= 52 then
			self:Sync(syncName.drek50)
		elseif healthPct >= 38 and healthPct <= 42 then
			self:Sync(syncName.drek40)
		elseif healthPct >= 28 and healthPct <= 32 then
			self:Sync(syncName.drek30)
		elseif healthPct >= 18 and healthPct <= 22 then
			self:Sync(syncName.drek20)
		elseif healthPct >= 8 and healthPct <= 12 then
			self:Sync(syncName.drek10)
		end
	
	elseif UnitName(msg) == "Vanndar Stormpike" then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		
		if healthPct >= 48 and healthPct <= 52 then
			self:Sync(syncName.vann50)
		elseif healthPct >= 38 and healthPct <= 42 then
			self:Sync(syncName.vann40)
		elseif healthPct >= 28 and healthPct <= 32 then
			self:Sync(syncName.vann30)
		elseif healthPct >= 18 and healthPct <= 22 then
			self:Sync(syncName.vann20)
		elseif healthPct >= 8 and healthPct <= 12 then
			self:Sync(syncName.vann10)
		end
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if (msg == string.format(UNITDIESOTHER, "Captain Galvangar")) then
		self:Sync(syncName.galvDead)
	elseif (msg == string.format(UNITDIESOTHER, "Captain Balinda Stonehearth")) then
		self:Sync(syncName.balindaDead)
	elseif (msg == string.format(UNITDIESOTHER, "Korrak the Bloodrager")) then
		self:Sync(syncName.korrakDead)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.drek50 and self.db.profile.boss then
		self:DrekHp(50)
	elseif sync == syncName.drek40 and self.db.profile.boss then
		self:DrekHp(40)
	elseif sync == syncName.drek30 and self.db.profile.boss then
		self:DrekHp(30)
	elseif sync == syncName.drek20 and self.db.profile.boss then
		self:DrekHp(20)
	elseif sync == syncName.drek10 and self.db.profile.boss then
		self:DrekHp(10)
	
	elseif sync == syncName.vann50 and self.db.profile.boss then
		self:VannHp(50)
	elseif sync == syncName.vann40 and self.db.profile.boss then
		self:VannHp(40)
	elseif sync == syncName.vann30 and self.db.profile.boss then
		self:VannHp(30)
	elseif sync == syncName.vann20 and self.db.profile.boss then
		self:VannHp(20)
	elseif sync == syncName.vann10 and self.db.profile.boss then
		self:VannHp(10)
		
	elseif sync == syncName.galvDead and self.db.profile.captain then
		self:GalvDead()
	elseif sync == syncName.balindaDead and self.db.profile.captain then
		self:BalindaDead()
	elseif sync == syncName.korrakDead and self.db.profile.korrak then
		self:KorrakDead()
		
	elseif sync == syncName.gameStart and rest and self.db.profile.start then
		self:GameStart(rest)
	elseif sync == syncName.gameStarted and rest and self.db.profile.start then
		self:GameStarted()
	
	elseif sync == syncName.gameEnd and rest and self.db.profile.gameend then
		self:GameEnd(rest)
	elseif sync == syncName.countPlayers and self.db.profile.gameend then
		self:CountPlayers()
	end
end

function module:DrekHp(hp)
	self:Message(L["msg_DrekHp"]..hp.."%", "Important", false, nil, false)
end

function module:VannHp(hp)
	self:Message(L["msg_VannHp"]..hp.."%", "Important", false, nil, false)
end

function module:GalvDead()
	self:Message(L["msg_galvDead"], "Important", false, nil, false)
end

function module:BalindaDead()
	self:Message(L["msg_balindaDead"], "Important", false, nil, false)
end

function module:KorrakDead()
	self:Message(L["msg_korrakDead"], "Important", false, nil, false)
end

function module:GameStart(rest)
	local startTime = tonumber(rest)
	self:Bar(L["bar_gameStart"], startTime, icon.gameStart, true, color.gameStart)
end

function module:GameStarted()
	self:RemoveBar(L["bar_gameStart"])
	self:Sound("Info")
end

function module:GameEnd(rest)
	local endTime = tonumber(rest)
	self:Bar(L["bar_gameEnd"], endTime, icon.gameEnd, true, color.gameEnd)
	
	self:CancelDelayedSync(syncName.countPlayers)
	self:DelayedSync(5, syncName.countPlayers)
end

function module:CountPlayers()
	--this updates the data from scoreboard without opening it
	RequestBattlefieldScoreData()
	
	local numScores = GetNumBattlefieldScores()
	local numHorde = 0
	local numAlliance = 0
	for i=1, numScores do
		name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(i);
		if ( faction ) then
			if ( faction == 0 ) then
				numHorde = numHorde + 1
			else
				numAlliance = numAlliance + 1
			end
		end
	end
	
	if numHorde >= 15 and numAlliance >= 15 then
		self:RemoveBar(L["bar_gameEnd"])
	else
		self:DelayedSync(5, syncName.countPlayers)
	end
	--DEFAULT_CHAT_FRAME:AddMessage("Horde Players: "..numHorde.." // Alliance Players: "..numAlliance)
end
