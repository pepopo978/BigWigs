local module, L = BigWigs:ModuleDeclaration("Heigan the Unclean", "Naxxramas")

module.revision = 30058
module.enabletrigger = module.translatedName
module.toggleoptions = { "map","fundance", "disease", "manaBurn", "teleport", "eruption", -1, "bosskill" }
module.defaultDB = {
	fundance = false,
	mapX = 600,
	mapY = -400,
	mapAlpha = 1,
	mapScale = 1,
	autotarget = false,
	window = false,
}


L:RegisterTranslations("enUS", function()
	return {
		cmd = "Heigan",

		map_cmd = "map",
		map_name = "Positions Map",
		map_desc = "Show live heighan positions map",

		fundance_cmd = "fundance",
		fundance_name = "Safety Dance",
		fundance_desc = "You can dance if you want to!",

		disease_cmd = "disease",
		disease_name = "Decrepit Fever Alert",
		disease_desc = "Warn for Decrepit Fever",

		manaBurn_cmd = "manaBurn",
		manaBurn_name = "Mana Burn Alert",
		manaBurn_desc = "Warn for Mana Burn",

		teleport_cmd = "teleport",
		teleport_name = "Teleport Alert",
		teleport_desc = "Warn for Teleports.",

		eruption_cmd = "eruption",
		eruption_name = "Eruption Alert",
		eruption_desc = "Warn for Eruption",

		trigger_engage1 = "You are mine now!", --CHAT_MSG_MONSTER_YELL
		trigger_engage2 = "You...are next!", --CHAT_MSG_MONSTER_YELL
		trigger_engage3 = "I see you!", --CHAT_MSG_MONSTER_YELL

		trigger_die = "takes his last breath.", --to be confirmed

		trigger_disease = "afflicted by Decrepit Fever.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_disease = "Decrepit Fever CD",
		msg_disease = "Decrepit Fever",

		trigger_manaBurn = "Heigan the Unclean's Mana Burn", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		bar_manaBurn = "Mana Burn CD",

		trigger_manaBurnYou = "Heigan the Unclean's Mana Burn hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		msg_manaBurnYou = "Mana Burn hit you!",

		trigger_danceStart = "The end is upon you.", --CHAT_MSG_MONSTER_YELL
		msg_danceStart = "Teleport!",
		bar_dancing = "Dancing Ends",
		bar_dancingSoon = "Dancing Soon",



		msg_fightStart = "Fight!",
		bar_fighting = "Dancing Starts",

		bar_eruption = "Eruption",
	}
end)

local timer = {
	firstDiseaseCD = 30,
	firstDiseaseAfterDanceCD = 5,
	diseaseCD = { 20, 25 },

	firstManaBurnCD = 15,
	firstManaBurnAfterDanceCD = 10,
	manaBurnCD = 3,

	fightDuration = 90,
	danceDuration = 45,

	firstEruption = 15,
	firstDanceEruption = 4,
	eruption = 0, -- will be changed during the encounter
	eruptionSlow = 10,
	eruptionFast = 3.1, -- was getting slightly out of sync with it at 3, maybe only on vmangos?
	dancingSoon = 10,
}
local icon = {
	disease = "Ability_Creature_Disease_03",
	manaBurn = "Spell_Shadow_ManaBurn",
	fightDuration = "Spell_Magic_LesserInvisibilty",
	danceDuration = "Spell_Arcane_Blink",
	eruption = "spell_fire_selfdestruct",
	dancing = "INV_Gizmo_RocketBoot_01",
}
local syncName = {
	disease = "HeiganDisease" .. module.revision,
	manaBurn = "HeiganManaBurn" .. module.revision,
	danceStart = "HeiganToPlatform" .. module.revision,
	fightStart = "HeiganToFloor" .. module.revision,
}

local eruption_count = 1
local eruption_dir = 1
bwHeiganTimeFloorStarted = 0
bwHeiganTimePlatformStarted = 0

module:RegisterYellEngage(L["trigger_engage1"])
module:RegisterYellEngage(L["trigger_engage2"])
module:RegisterYellEngage(L["trigger_engage3"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--heiganDies
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--decrepitFever
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--manaBurn
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")--DanceStart(Teleport)

	self:ThrottleSync(5, syncName.disease)
	self:ThrottleSync(1, syncName.manaBurn)
	self:ThrottleSync(1, syncName.danceStart)
	self:ThrottleSync(10, syncName.fightStart)

	self:SetupMap()
	--heiganmap:Show()
end

function module:OnSetup()
	self:SetupMap()
end

function module:OnEngage()

	if self.db.profile.map then
		heiganmap:Show()
	end

	bwHeiganTimeFloorStarted = GetTime()

	if self.db.profile.disease then
		self:Bar(L["bar_disease"], timer.firstDiseaseCD, icon.disease, true, "Green")
	end
	if self.db.profile.manaBurn then
		self:Bar(L["bar_manaBurn"], timer.firstManaBurnCD, icon.manaBurn, true, "Blue")
	end
	if self.db.profile.teleport then
		self:Bar(L["bar_fighting"], timer.fightDuration, icon.fightDuration, true, "White")
		self:DelayedBar(timer.fightDuration - 10, L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Cyan")
	end

	eruption_count = 1
	eruption_dir = 1
	timer.eruption = timer.eruptionSlow
	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.firstEruption, self)
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.firstEruption, icon.eruption, true, "Red")
	end
end

function module:OnDisengage()
	--heiganmap:Hide()
end

function module:Event(msg)
	if string.find(msg, L["trigger_manaBurnYou"]) then
		if self.db.profile.manaBurn then
			if UnitClass("Player") ~= "Rogue" and UnitClass("Player") ~= "Warrior" then
				self:Message(L["msg_manaBurnYou"], "Important", nil, "Info")
				self:WarningSign(icon.manaBurn, 0.7)
			end
		end
	end
	if string.find(msg, L["trigger_die"]) then
		self:SendBossDeathSync()
	elseif string.find(msg, L["trigger_disease"]) then
		self:Sync(syncName.disease)
	elseif string.find(msg, L["trigger_manaBurn"]) then
		self:Sync(syncName.manaBurn)
	elseif string.find(msg, L["trigger_danceStart"]) then
		self:Sync(syncName.danceStart)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.disease and self.db.profile.disease then
		self:Disease()
	elseif sync == syncName.manaBurn and self.db.profile.manaBurn then
		self:ManaBurn()
	elseif sync == syncName.danceStart then
		self:DanceStart()
	elseif sync == syncName.fightStart then
		self:FightStart()
	end
end

function module:Disease()
	--start a bar only if enough time left before dancing
	if timer.diseaseCD[1] < (timer.fightDuration - (GetTime() - bwHeiganTimeFloorStarted)) then
		self:IntervalBar(L["bar_disease"], timer.diseaseCD[1], timer.diseaseCD[2], icon.disease, true, "Green")
	end
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Priest" then
		self:Message(L["msg_disease"], "Important", nil, "Info")
		self:WarningSign(icon.disease, 0.7)
	end
end

function module:ManaBurn()
	--start a bar only if enough time left before dancing
	if timer.manaBurnCD < (timer.fightDuration - (GetTime() - bwHeiganTimeFloorStarted)) then
		self:Bar(L["bar_manaBurn"], timer.manaBurnCD, icon.manaBurn, true, "Blue")
	end
end

function module:DanceStart()
	self:CancelScheduledEvent("HeiganEruption")
	self:RemoveBar(L["bar_disease"])
	self:RemoveBar(L["bar_manaBurn"])
	self:RemoveBar(L["bar_fighting"])
	self:RemoveBar(L["bar_dancingSoon"])

	eruption_count = 1
	timer.eruption = timer.eruptionFast

	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.firstDanceEruption, self)
	self:ScheduleEvent("bwHeiganToFloor", self.FightStart, timer.danceDuration, self)

	if self.db.profile.teleport then
		self:Message(string.format(L["msg_danceStart"], timer.danceDuration), "Attention")
		self:Bar(L["bar_dancing"], timer.danceDuration, icon.danceDuration, true, "White")
		if self.db.profile.fundance then
			BigWigsSound:BigWigs_Sound("FunDance")
		else
			BigWigsSound:BigWigs_Sound("Dance")
		end
	end
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.firstDanceEruption, icon.eruption, true, "Red")
	end
end

function module:FightStart()
	self:CancelScheduledEvent("bwHeiganToFloor")
	self:CancelScheduledEvent("HeiganEruption")

	eruption_count = 1
	timer.eruption = timer.eruptionSlow
	self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)

	if self.db.profile.teleport then
		self:Message(L["msg_fightStart"], "Attention")
		self:Bar(L["bar_fighting"], timer.fightDuration, icon.fightDuration, true, "White")
		self:DelayedBar(timer.fightDuration - 10, L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Cyan")
	end
	if self.db.profile.disease then
		self:Bar(L["bar_disease"], timer.firstDiseaseAfterDanceCD, icon.disease, true, "Green")
	end
	if self.db.profile.manaBurn then
		self:Bar(L["bar_manaBurn"], timer.firstManaBurnAfterDanceCD, icon.manaBurn, true, "Blue")
	end
	if self.db.profile.eruption then
		self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
	end
end

function module:Eruption()
	eruption_count = eruption_count + 1 * eruption_dir
	if eruption_count == 4 then
		eruption_dir = -1
	end
	if eruption_count == 1 then
		eruption_dir = 1
	end

	local registered, time, elapsed = self:BarStatus(L["bar_fighting"])
	if registered and timer and elapsed then
		local remaining = time - elapsed
		if timer.eruption + 1 < remaining then
			if self.db.profile.eruption then
				self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
			end
			self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)
		else
			if self.db.profile.teleport then
				self:Sound("Beware")
				self:Bar(L["bar_dancingSoon"], timer.dancingSoon, icon.dancing, true, "Blue")
			end
		end
	else
		if self.db.profile.eruption then
			self:Bar(L["bar_eruption"] .. eruption_help(eruption_count), timer.eruption, icon.eruption, true, "Red")
		end
		self:ScheduleEvent("HeiganEruption", self.Eruption, timer.eruption, self)
	end
end

function eruption_help(inp)
	return ' ' .. inp
end

-----------------------
-- Utility Functions --
-----------------------

function GetHeiganCoords()
	local posX, posY = GetPlayerMapPosition("player")

	posX = posX * 100.
	posY = posY * 100.

	if posX >= 68.3 then
		posX = 0.
	end	

	if posY <= 63.4 or posY >= 70.405 then
		posY = 0.
	end

	posX = ((posX - 63.505) / 4.79870410) * heiganmap.map:GetWidth() * (483.0/512.0)
	posY = ((63.423 - posY) / 7.19656160) * heiganmap.map:GetHeight() * (364.0/512.0)

	if posX < 0 then
		posX = 0.
	end
	
	return posX, posY
end


function UpdateHeiganMap()
	if not heiganmap.map then
		return
	end
	local tooltipText = ""
	local tooltipAnchor
	
	local coordX, coordY = GetHeiganCoords()

	heiganmap.map.unit:Show()
	heiganmap.map.unit:SetPoint("CENTER", heiganmap.map, "TOPLEFT", coordX, coordY)
	HeiganMapUnitIcon()

	if tooltipText ~= "" then
		heiganmap.tooltip:Show()
		heiganmap.tooltip:SetOwner(tooltipAnchor, "ANCHOR_RIGHT");
		heiganmap.tooltip:SetText(tooltipText)
	else
		heiganmap.tooltip:Hide()
	end
end

function HeiganMapUnitIcon()	
	heiganmap.map.unit:SetWidth(32)
	heiganmap.map.unit:SetHeight(32)	
	heiganmap.map.unit.texture:SetTexture("Interface\\Addons\\BigWigs\\Textures\\PlayerMapIconGreen")
end

function module:SetupMap()
	if heiganmap then
		return
	end
	heiganmap = CreateFrame("Frame", "BigWigsHeiganMap", UIParent)
	heiganmap:SetWidth(200)
	heiganmap:SetHeight(32)

	heiganmap:SetBackdrop({
		-- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Addons\\BigWigs\\Textures\\otravi-semi-full-border", edgeSize = 32,
		--edgeFile = "", edgeSize = 32,
		insets = { left = 1, right = 1, top = 20, bottom = 1 },
	})
	heiganmap:SetBackdropBorderColor(1.0, 1.0, 1.0)
	heiganmap:SetBackdropColor(24 / 255, 24 / 255, 24 / 255)
	heiganmap:ClearAllPoints()
	heiganmap:SetPoint("TOPLEFT", nil, "TOPLEFT", self.db.profile.mapX, self.db.profile.mapY)
	heiganmap:EnableMouse(true)
	heiganmap:SetClampedToScreen(true)
	heiganmap:RegisterForDrag("LeftButton")
	heiganmap:SetMovable(true)
	heiganmap:SetFrameStrata("LOW")
	heiganmap:SetAlpha(self.db.profile.mapAlpha or 1.0)
	heiganmap:SetScale(self.db.profile.mapScale or 1.0)
	heiganmap:SetScript("OnDragStart", function()
		heiganmap:StartMoving()
	end)
	heiganmap:SetScript("OnDragStop", function()
		heiganmap:StopMovingOrSizing();
		self.db.profile.mapX = heiganmap:GetLeft();
		self.db.profile.mapY = heiganmap:GetTop()
	end)
	heiganmap:SetScript("OnUpdate", UpdateHeiganMap)
	heiganmap:Hide()

	heiganmap.tooltip = CreateFrame("GameTooltip", "HeiganMapTooltip", heiganmap, "GameTooltipTemplate")

	heiganmap.cheader = heiganmap:CreateFontString(nil, "OVERLAY")
	heiganmap.cheader:ClearAllPoints()
	heiganmap.cheader:SetWidth(190)
	heiganmap.cheader:SetHeight(15)
	heiganmap.cheader:SetPoint("TOP", heiganmap, "TOP", 0, -14)
	heiganmap.cheader:SetFont("Fonts\\FRIZQT__.TTF", 12)
	heiganmap.cheader:SetJustifyH("LEFT")
	heiganmap.cheader:SetText("Heigan Map")
	heiganmap.cheader:SetShadowOffset(.8, -.8)
	heiganmap.cheader:SetShadowColor(0, 0, 0, 1)

	heiganmap.closebutton = CreateFrame("Button", nil, heiganmap)
	heiganmap.closebutton:SetWidth(20)
	heiganmap.closebutton:SetHeight(14)
	heiganmap.closebutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	heiganmap.closebutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	heiganmap.closebutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-close")
	heiganmap.closebutton:SetPoint("TOPRIGHT", heiganmap, "TOPRIGHT", -7, -15)
	heiganmap.closebutton:SetScript("OnClick", function()
		heiganmap:Hide()
	end)

	heiganmap.alphabutton = CreateFrame("Button", nil, heiganmap)
	heiganmap.alphabutton:SetWidth(20)
	heiganmap.alphabutton:SetHeight(14)
	heiganmap.alphabutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	heiganmap.alphabutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	heiganmap.alphabutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-alpha")
	heiganmap.alphabutton:SetPoint("TOPRIGHT", heiganmap, "TOPRIGHT", -27, -15)
	heiganmap.alphabutton:SetScript("OnClick", function()
		if not self.db.profile.mapAlpha or (self.db.profile.mapAlpha < 0.3) then
			self.db.profile.mapAlpha = 1.0
		else
			self.db.profile.mapAlpha = self.db.profile.mapAlpha - 0.2
		end
		heiganmap:SetAlpha(self.db.profile.mapAlpha)
	end)

	heiganmap.scalebutton = CreateFrame("Button", nil, heiganmap)
	heiganmap.scalebutton:SetWidth(20)
	heiganmap.scalebutton:SetHeight(14)
	heiganmap.scalebutton:SetHighlightTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	heiganmap.scalebutton:SetNormalTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	heiganmap.scalebutton:SetPushedTexture("Interface\\Addons\\BigWigs\\Textures\\otravi-scale")
	heiganmap.scalebutton:SetPoint("TOPRIGHT", heiganmap, "TOPRIGHT", -47, -15)
	heiganmap.scalebutton:SetScript("OnClick", function()
		local oldScale = (self.db.profile.mapScale or 1.0)
		if not self.db.profile.mapScale then
			self.db.profile.mapScale = 1.0
		elseif (self.db.profile.mapScale > 2.0) then
			self.db.profile.mapScale = 0.75
		else
			self.db.profile.mapScale = self.db.profile.mapScale + 0.25
		end
		heiganmap:SetScale(self.db.profile.mapScale)
		self.db.profile.mapX = self.db.profile.mapX * oldScale / self.db.profile.mapScale
		self.db.profile.mapY = self.db.profile.mapY * oldScale / self.db.profile.mapScale
		heiganmap:ClearAllPoints()
		heiganmap:SetPoint("TOPLEFT", nil, "TOPLEFT", self.db.profile.mapX, self.db.profile.mapY)
	end)

	heiganmap.map = CreateFrame("Frame", "HeiganMapAnchor", heiganmap)
	heiganmap.map:SetPoint("TOPLEFT", heiganmap, "BOTTOMLEFT", 0, 0)
	heiganmap.map:SetWidth(heiganmap:GetWidth())
	heiganmap.map:SetHeight(200)
	heiganmap.map.texture = heiganmap.map:CreateTexture(nil, "BACKGROUND")
	heiganmap.map.texture:SetAllPoints(heiganmap.map)
	heiganmap.map.texture:SetTexture("Interface\\Addons\\BigWigs\\Textures\\heiganmaptexture")

	heiganmap.map.unit = CreateFrame("Frame", "HeiganMapUnit", heiganmap.map)
	--		heiganmap.map.unit[i]:EnableMouse(true)
	--		heiganmap.map.unit[i]: SetPoint("TOPLEFT", heiganmap.map, "TOPLEFT")
	heiganmap.map.unit.texture = heiganmap.map.unit:CreateTexture(nil, "OVERLAY")
	heiganmap.map.unit.texture:SetAllPoints(heiganmap.map.unit)
	--		heiganmap.map.unit[i]:SetScript("OnLeave", function() GameTooltip:Hide(); DEFAULT_CHAT_FRAME:AddMessage("leave hover") end )
	HeiganMapUnitIcon()	
	
	
	heiganmap:Show()
end
