local name = "Common Auras"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local BS = AceLibrary("Babble-Spell-2.3")

local spellStatus = nil

local whZone = nil
local whColor = nil
local whText = nil

local portalColor = nil
local portalText = nil

-- Use for detecting instant cast target (Fear Ward)
local spellTarget = nil
local spellCasting = nil

local timeToShutdown = nil
local shutdownBigWarning = nil

L:RegisterTranslations("enUS", function()
	return {
		iconPrefix = "Interface\\Icons\\",

		msg_fearward = " FearWard on ",
		bar_fearward = " FearWard CD",

		msg_shieldwall = " Shield Wall",
		bar_shieldwall = " Shield Wall",

		msg_laststand = " Last Stand",
		bar_laststand = " Last Stand",

		msg_lifegivingGem = " Lifegiving Gem",
		bar_lifegivingGem = " Lifegiving Gem",

		msg_challengingShout = " Challenging Shout",
		bar_challengingShout = " Challenging Shout",

		msg_challengingRoar = " Challenging Roar",
		bar_challengingRoar = " Challenging Roar",

		msg_divineIntervention = "Divine Intervention on ",
		bar_divineIntervention = " Divine Intervention",

		portal_regexp = ".*: (.*)",

		trigger_wormhole = "just opened a wormhole.", --CHAT_MSG_MONSTER_EMOTE
		bar_wormhole = " Wormhole",
		msg_wormhole = " Wormhole",

		trigger_orange = "begins to conjure a refreshment table.", --CHAT_MSG_MONSTER_EMOTE
		bar_orange = "Oranges!",
		msg_orange = "Oranges! Get your Vitamin C",

		trigger_soulwell = "begins a Soulwell ritual.", --CHAT_MSG_MONSTER_EMOTE
		bar_soulwell = "Soulwell!",
		msg_soulwell = "Soulwell! Get your Cookie",

		trigger_shutdown = "Shutdown in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restart = "Restart in (.+) (.+)", --CHAT_MSG_SYSTEM
		trigger_restartMinSec = "Shutdown in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		trigger_shutdownMinSec = "Restart in (.+) Minutes (.+) Seconds.", --CHAT_MSG_SYSTEM
		bar_shutDown = "Server Shutdown/Restart",

		bar_aq40insignia = "Loot Insignia",
		bar_aq40artifact = "Loot Artifact",

		aq40insignia = "Qiraji Lord\'s Insignia",
		aq40artifact = "Ancient Qiraji Artifact",

		cenarionFactionName = "Cenarion Circle",
		broodFactionName = "Brood of Nozdormu",

		["Toggle %s display."] = true,
		["Wormhole"] = true,
		["Spells"] = "Important spells",
		["SpellsDesc"] = "Notification bars during important spells",
		["Orange"] = true,
		["Soulwell"] = true,
		["Portal"] = true,
		["Shutdown"] = true,
		["broadcast"] = true,
		["Broadcast"] = true,
		["Toggle broadcasting the messages to the raidwarning channel."] = true,

		["AutoFocus"] = true,
		["AutoFocusDesc"] = "Automatically sets focus target to skull marks",

		["Gives timer bars and raid messages about common buffs and debuffs."] = true,
		["Common Auras"] = true,
		["commonauras"] = true,

		["Invisibility"] = true,
		["Deepwood Pipe"] = true,
		["Lesser Invisibility"] = true,
		["Limited Invulnerability Potion"] = true,
		["Hand of Protection"] = true,
		["Power Infusion"] = true,

		["AQ40 Insignia Reminder"] = true,
		["AQ40 Artifact Reminder"] = true,

		["di_trigger"] = "You gain Divine Intervention",
		["invis_trigger"] = "You gain Invisibility",
		["lesser_invis_trigger"] = "You gain Lesser Invisibility",
		["cloaking_invis_trigger"] = "You gain Cloaking",
		["lip_trigger"] = "You gain Invulnerability",
		["bop_trigger"] = "You gain Hand of Protection",
		["powerinfusion_trigger"] = "You gain Power Infusion",
		["deepwoodpipe_trigger"] = "You gain Smoke Cloud", -- use this as trigger instead of Stealth due to overlap with rogue ability

		["di_fades"] = "Divine Intervention fades",
		["invis_fades"] = "Invisibility fades",
		["lesser_invis_fades"] = "Lesser Invisibility fades",
		["cloaking_invis_fades"] = "Cloaking fades",
		["lip_fades"] = "Invulnerability fades",
		["bop_fades"] = "Hand of Protection fades",
		["powerinfusion_fades"] = "Power Infusion fades",
		["deepwoodpipe_fades"] = "Stealth fades"
	}
end)

BigWigsCommonAuras = BigWigs:NewModule(name, "AceHook-2.1")
BigWigsCommonAuras.synctoken = myname
BigWigsCommonAuras.defaultDB = {
	fearward = true,
	shieldwall = true,
	laststand = true,
	lifegivinggem = true,
	challengingshout = true,
	challengingroar = true,
	di = true,
	portal = true,
	wormhole = true,
	orange = true,
	soulwell = true,
	shutdown = true,
	invis = true,
	deepwood = true,
	lip = true,
	bop = true,
	powerinfusion = true,
	broadcast = false,
	aq40artifact = true,
	aq40insignia = true,
	autofocus = false
}
BigWigsCommonAuras.consoleCmd = L["commonauras"]
BigWigsCommonAuras.revision = 30064
BigWigsCommonAuras.external = true
BigWigsCommonAuras.consoleOptions = {
	type = "group",
	name = L["Common Auras"],
	desc = L["Gives timer bars and raid messages about common buffs and debuffs."],
	args = {
		["aq40insignia"] = {
			type = "toggle",
			name = L["AQ40 Insignia Reminder"],
			desc = string.format(L["Toggle %s display."], L["AQ40 Insignia Reminder"]),
			get = function()
				return BigWigsCommonAuras.db.profile.aq40insignia
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.aq40insignia = v
			end,
		},
		["aq40artifact"] = {
			type = "toggle",
			name = L["AQ40 Artifact Reminder"],
			desc = string.format(L["Toggle %s display."], L["AQ40 Artifact Reminder"]),
			get = function()
				return BigWigsCommonAuras.db.profile.aq40artifact
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.aq40artifact = v
			end,
		},
		["broadcast"] = {
			type = "toggle",
			name = L["Broadcast"],
			desc = L["Toggle broadcasting the messages to the raidwarning channel."],
			get = function()
				return BigWigsCommonAuras.db.profile.broadcast
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.broadcast = v
			end,
		},
		["autofocus"] = {
			type = "toggle",
			name = L["AutoFocus"],
			desc = L["AutoFocusDesc"],
			get = function()
				return BigWigsCommonAuras.db.profile.autofocus
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.autofocus = v
			end,
		},
		["portal"] = {
			type = "toggle",
			name = L["Portal"],
			desc = string.format(L["Toggle %s display."], L["Portal"]),
			get = function()
				return BigWigsCommonAuras.db.profile.portal
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.portal = v
			end,
		},
		["orange"] = {
			type = "toggle",
			name = L["Orange"],
			desc = string.format(L["Toggle %s display."], L["Orange"]),
			get = function()
				return BigWigsCommonAuras.db.profile.orange
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.orange = v
			end,
		},
		["soulwell"] = {
			type = "toggle",
			name = L["Soulwell"],
			desc = string.format(L["Toggle %s display."], L["Soulwell"]),
			get = function()
				return BigWigsCommonAuras.db.profile.soulwell
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.soulwell = v
			end,
		},
		["shutdown"] = {
			type = "toggle",
			name = L["Shutdown"],
			desc = string.format(L["Toggle %s display."], L["Shutdown"]),
			get = function()
				return BigWigsCommonAuras.db.profile.shutdown
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.shutdown = v
			end,
		},
		["wormhole"] = {
			type = "toggle",
			name = L["Wormhole"],
			desc = string.format(L["Toggle %s display."], L["Wormhole"]),
			get = function()
				return BigWigsCommonAuras.db.profile.wormhole
			end,
			set = function(v)
				BigWigsCommonAuras.db.profile.wormhole = v
			end,
		},
		["spells"] = {
			type = "group",
			name = L["Spells"],
			desc = L["SpellsDesc"],
			order = 6,
			args = {
				["bop"] = {
					type = "toggle",
					name = L["Hand of Protection"],
					desc = string.format(L["Toggle %s display."], L["Hand of Protection"]),
					get = function()
						return BigWigsCommonAuras.db.profile.bop
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.bop = v
					end,
				},
				["challengingshout"] = {
					type = "toggle",
					name = BS["Challenging Shout"],
					desc = string.format(L["Toggle %s display."], BS["Challenging Shout"]),
					get = function()
						return BigWigsCommonAuras.db.profile.challengingshout
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.challengingshout = v
					end,
				},
				["challengingroar"] = {
					type = "toggle",
					name = BS["Challenging Roar"],
					desc = string.format(L["Toggle %s display."], BS["Challenging Roar"]),
					get = function()
						return BigWigsCommonAuras.db.profile.challengingroar
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.challengingroar = v
					end,
				},
				["di"] = {
					type = "toggle",
					name = BS["Divine Intervention"],
					desc = string.format(L["Toggle %s display."], BS["Divine Intervention"]),
					get = function()
						return BigWigsCommonAuras.db.profile.di
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.di = v
					end,
				},
				["deepwood"] = {
					type = "toggle",
					name = L["Deepwood Pipe"],
					desc = string.format(L["Toggle %s display."], L["Deepwood Pipe"]),
					get = function()
						return BigWigsCommonAuras.db.profile.deepwood
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.deepwood = v
					end,
				},
				["fearward"] = {
					type = "toggle",
					name = BS["Fear Ward"],
					desc = string.format(L["Toggle %s display."], BS["Fear Ward"]),
					get = function()
						return BigWigsCommonAuras.db.profile.fearward
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.fearward = v
					end,
				},
				["invisibility"] = {
					type = "toggle",
					name = L["Invisibility"],
					desc = string.format(L["Toggle %s display."], L["Invisibility"]),
					get = function()
						return BigWigsCommonAuras.db.profile.invis
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.invis = v
					end,
				},
				["laststand"] = {
					type = "toggle",
					name = BS["Last Stand"],
					desc = string.format(L["Toggle %s display."], BS["Last Stand"]),
					get = function()
						return BigWigsCommonAuras.db.profile.laststand
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.laststand = v
					end,
				},
				["lip"] = {
					type = "toggle",
					name = L["Limited Invulnerability Potion"],
					desc = string.format(L["Toggle %s display."], L["Limited Invulnerability Potion"]),
					get = function()
						return BigWigsCommonAuras.db.profile.lip
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.lip = v
					end,
				},
				["lifegivinggem"] = {
					type = "toggle",
					name = BS["Lifegiving Gem"],
					desc = string.format(L["Toggle %s display."], BS["Lifegiving Gem"]),
					get = function()
						return BigWigsCommonAuras.db.profile.lifegivinggem
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.lifegivinggem = v
					end,
				},
				["powerinfusion"] = {
					type = "toggle",
					name = L["Power Infusion"],
					desc = string.format(L["Toggle %s display."], L["Power Infusion"]),
					get = function()
						return BigWigsCommonAuras.db.profile.powerinfusion
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.powerinfusion = v
					end,
				},
				["shieldwall"] = {
					type = "toggle",
					name = BS["Shield Wall"],
					desc = string.format(L["Toggle %s display."], BS["Shield Wall"]),
					get = function()
						return BigWigsCommonAuras.db.profile.shieldwall
					end,
					set = function(v)
						BigWigsCommonAuras.db.profile.shieldwall = v
					end,
				},
			}
		}
	}
}

local timer = {
	fearward = 30,
	laststand = 20,
	lifegivingGem = 20,
	challenging = 6,
	di = 60,
	portal = 60,
	wormhole = 8,
	orange = 60,
	soulwell = 60,
	aq40artifact = 5,
	aq40insignia = 5,
}
local icon = {
	fearward = L["iconPrefix"] .. "spell_holy_excorcism",
	shieldwall = L["iconPrefix"] .. "ability_warrior_shieldwall",
	laststand = L["iconPrefix"] .. "spell_holy_ashestoashes",
	lifegivingGem = L["iconPrefix"] .. "inv_misc_gem_pearl_05",
	challengingShout = L["iconPrefix"] .. "ability_bullrush",
	challengingRoar = L["iconPrefix"] .. "ability_druid_challangingroar",
	di = L["iconPrefix"] .. "spell_nature_timestop",
	wormhole = L["iconPrefix"] .. "Inv_Misc_EngGizmos_12",
	orange = L["iconPrefix"] .. "inv_misc_food_41",
	soulwell = L["iconPrefix"] .. "inv_stone_04",
	shutdown = L["iconPrefix"] .. "trade_engineering",
	aq40insignia = L["iconPrefix"] .. "inv_zulgurubtrinket",
	aq40artifact = L["iconPrefix"] .. "inv_misc_idol_03",
}
local color = {
	fearward = "Cyan",
	shieldwall = "Red",
	laststand = "Red",
	lifegivingGem = "Red",
	challengingShout = "Red",
	challengingRoar = "Red",
	di = "Blue",
	wormhole = "Cyan",
	orange = "Green",
	soulwell = "Green",
	shutdown = "White",
	aq40insignia = "Yellow",
	aq40artifact = "Yellow",
}

function BigWigsCommonAuras:OnEnable()
	--if UnitName("Player") == "Relar" then self:RegisterEvent("CHAT_MSG_SAY") end --Debug
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")--trigger_wormhole, trigger_orange, trigger_soulwell
	self:RegisterEvent("CHAT_MSG_SYSTEM")--trigger_shutdown, trigger_restart
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	self:RegisterEvent("LOOT_OPENED")

	if UnitClass("player") == "Warrior" or UnitClass("player") == "Druid" or UnitClass("player") == "Priest" then
		self:RegisterEvent("SpellStatusV2_SpellCastInstant")
	elseif UnitClass("player") == "Mage" then
		if not spellStatus then
			spellStatus = AceLibrary("SpellStatusV2-2.0")
		end
		self:RegisterEvent("SpellStatusV2_SpellCastCastingFinish")
		self:RegisterEvent("SpellStatusV2_SpellCastFailure")
	end

	self:RegisterEvent("BigWigs_RecvSync")
	-- XXX Lets have a low throttle because you'll get 2 syncs from yourself, so
	-- it results in 2 messages.
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAFW", .4) -- Fear Ward
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCASW", .4) -- Shield Wall
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCALS", .4) -- Last Stand
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCALG", .4) -- Last Stand
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCACS", .4) -- Challenging Shout
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCACR", .4) -- Challenging Roar
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAP", .4) -- Portal
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAWH", .4) -- Wormhole
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAOR", .4) -- Orange
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAWL", .4) -- Soulwell
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAAF", .4) -- AutoFocus

	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAAQ40INSIGNIA", 60) -- AQ40 boss insignia
	self:TriggerEvent("BigWigs_ThrottleSync", "BWCAAQ40ARTIFACT", 60) -- Artifact
end

function BigWigsCommonAuras:SpellStatusV2_SpellCastInstant(sId, sName, sRank, sFullName, sCastTime)
	if sName == BS["Fear Ward"] then
		local targetName = nil
		if spellTarget then
			targetName = spellTarget
			spellCasting = nil
			spellTarget = nil
		else
			if UnitExists("target") and UnitIsPlayer("target") and not UnitIsEnemy("target", "player") then
				targetName = UnitName("target")
			else
				targetName = UnitName("player")
			end
		end
		self:TriggerEvent("BigWigs_SendSync", "BWCAFW " .. targetName)
	elseif sName == BS["Shield Wall"] then
		local shieldWallDuration
		local talentName, _, _, _, currentRank, _, _, _ = GetTalentInfo(3, 13)
		if currentRank == 0 then
			shieldWallDuration = 10
		elseif currentRank == 1 then
			shieldWallDuration = 13
		else
			shieldWallDuration = 15
		end
		self:TriggerEvent("BigWigs_SendSync", "BWCASW " .. tostring(shieldWallDuration))
	elseif sName == BS["Last Stand"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCALS")
	elseif sName == BS["Challenging Shout"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCACS")
	elseif sName == BS["Challenging Roar"] then
		self:TriggerEvent("BigWigs_SendSync", "BWCACR")
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS(msg)
	if string.find(msg, BS["Gift of Life"]) and (UnitClass("Player") == "Warrior" or UnitClass("Player") == "Druid" or UnitClass("Player") == "Paladin") then
		self:TriggerEvent("BigWigs_SendSync", "BWCALG")
	elseif string.find(msg, L["di_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "BWCADI")
	elseif string.find(msg, L["invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["invis_trigger"], 18, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["lesser_invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["lesser_invis_trigger"], 15, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["cloaking_invis_trigger"]) and self.db.profile.invis then
		self:Bar(L["cloaking_invis_trigger"], 10, "Spell_Magic_LesserInvisibilty", true)
	elseif string.find(msg, L["deepwoodpipe_trigger"]) and self.db.profile.deepwood then
		self:Bar(L["deepwoodpipe_trigger"], 30, "ability_stealth", true)
	elseif string.find(msg, L["lip_trigger"]) and self.db.profile.lip then
		self:Bar(L["lip_trigger"], 6, "inv_potion_62", true)
	elseif string.find(msg, L["bop_trigger"]) and self.db.profile.bop then
		self:Bar(L["bop_trigger"], 10, "Spell_Holy_SealOfProtection", true)
	elseif string.find(msg, L["powerinfusion_trigger"]) and self.db.profile.powerinfusion then
		self:Bar(L["powerinfusion_trigger"], 15, "Spell_Holy_PowerInfusion", true)
	end
end

function BigWigsCommonAuras:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
	if string.find(msg, L["di_fades"]) then
		self:RemoveBar(L["di_trigger"])
	elseif string.find(msg, L["invis_fades"]) then
		self:RemoveBar(L["invis_trigger"])
	elseif string.find(msg, L["lesser_invis_fades"]) then
		self:RemoveBar(L["lesser_invis_trigger"])
	elseif string.find(msg, L["cloaking_invis_fades"]) then
		self:RemoveBar(L["cloaking_invis_trigger"])
	elseif string.find(msg, L["deepwoodpipe_fades"]) then
		self:RemoveBar(L["deepwoodpipe_trigger"])
	elseif string.find(msg, L["lip_fades"]) then
		self:RemoveBar(L["lip_trigger"])
	elseif string.find(msg, L["bop_fades"]) then
		self:RemoveBar(L["bop_trigger"])
	elseif string.find(msg, L["powerinfusion_fades"]) then
		self:RemoveBar(L["powerinfusion_trigger"])
	end
end

function BigWigsCommonAuras:SpellStatusV2_SpellCastCastingFinish(sId, sName, sRank, sFullName, sCastTime)
	if not string.find(sName, L["Portal"]) then
		return
	end
	local spellCastName = BS:HasReverseTranslation(sName) and BS:GetReverseTranslation(sName) or sName
	self:ScheduleEvent("bwcaspellcast", self.SpellCast, 0.3, self, spellCastName)
end

function BigWigsCommonAuras:SpellStatusV2_SpellCastFailure(sId, sName, sRank, sFullName, isActiveSpell, UIEM_Message, CMSFLP_SpellName, CMSFLP_Message)
	-- do nothing if we are casting a spell but the error doesn't consern that spell, thanks Iceroth.
	if (spellStatus:IsCastingOrChanneling() and not spellStatus:IsActiveSpell(sId, sName)) then
		return
	end
	if self:IsEventScheduled("bwcaspellcast") then
		self:CancelScheduledEvent("bwcaspellcast")
	end
end

function BigWigsCommonAuras:SpellCast(sName)
	self:TriggerEvent("BigWigs_SendSync", "BWCAP " .. sName)
end

function BigWigsCommonAuras:CHAT_MSG_MONSTER_EMOTE(msg, sender)
	if string.find(msg, L["trigger_wormhole"]) then
		whZone = nil
		if GetNumRaidMembers() > 0 then
			for i = 1, GetNumRaidMembers() do
				if UnitName("raid" .. i) == sender then
					if UnitFactionGroup("raid" .. i) == "Alliance" then
						whZone = "Stormwind"
					elseif UnitFactionGroup("raid" .. i) == "Horde" then
						whZone = "Orgrimmar"
					else
						whZone = sender
					end
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i = 1, GetNumPartyMembers() do
				if UnitName("party" .. i) == sender then
					if UnitFactionGroup("party" .. i) == "Alliance" then
						whZone = "Stormwind"
					elseif UnitFactionGroup("party" .. i) == "Horde" then
						whZone = "Orgrimmar"
					else
						whZone = sender
					end
				end
			end
		else
			whZone = sender
		end

		if whZone ~= nil then
			self:TriggerEvent("BigWigs_SendSync", "BWCAWH " .. whZone)
		end


	elseif string.find(msg, L["trigger_orange"]) then
		local zone = nil -- GetRealZoneText()
		if GetNumRaidMembers() > 0 then
			for i = 1, GetNumRaidMembers() do
				if UnitName("raid" .. i) == sender then
					zone = GetRealZoneText()
					break
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i = 1, GetNumPartyMembers() do
				if UnitName("party" .. i) == sender then
					zone = GetRealZoneText()
					break
				end
			end
		elseif sender == UnitName("player") then
			zone = GetRealZoneText()
		end

		if zone ~= nil then
			self:TriggerEvent("BigWigs_SendSync", "BWCAOR " .. zone)
		end

	elseif string.find(msg, L["trigger_soulwell"]) then
		self:TriggerEvent("BigWigs_SendSync", "BWCAWL")
	end
end

function BigWigsCommonAuras:CHAT_MSG_SYSTEM(msg)
	if string.find(msg, L["trigger_restartMinSec"]) or string.find(msg, L["trigger_shutdownMinSec"]) then
		local _, _, minutes, seconds = string.find(msg, " in (.+) Minutes (.+) Seconds.")
		timeToShutdown = tonumber(minutes) * 60 + tonumber(seconds)

		if self.db.profile.shutdown then
			if timeToShutdown > 9 then
				self:TriggerEvent("BigWigs_StopBar", self, L["bar_shutDown"])
				self:TriggerEvent("BigWigs_StartBar", self, L["bar_shutDown"], timeToShutdown, icon.shutdown, true, color.shutdown)
			end

			if not shutdownBigWarning then
				self:TriggerEvent("BigWigs_Sound", "Beware")
				self:TriggerEvent("BigWigs_ShowWarningSign", icon.shutdown, 2)
				shutdownBigWarning = true
			end
		end


	elseif string.find(msg, L["trigger_restart"]) or string.find(msg, L["trigger_shutdown"]) then
		local _, _, digits, minSec = string.find(msg, " in (.+) (.+)")
		if string.find(minSec, "inute") then
			timeToShutdown = tonumber(digits) * 60
		else
			timeToShutdown = tonumber(digits)
		end

		if self.db.profile.shutdown then
			if timeToShutdown > 9 then
				self:TriggerEvent("BigWigs_StopBar", self, L["bar_shutDown"])
				self:TriggerEvent("BigWigs_StartBar", self, L["bar_shutDown"], timeToShutdown, icon.shutdown, true, color.shutdown)
			end

			if not shutdownBigWarning then
				self:TriggerEvent("BigWigs_Sound", "Beware")
				self:TriggerEvent("BigWigs_ShowWarningSign", icon.shutdown, 2)
				shutdownBigWarning = true
			end
		end
	end
end

function BigWigsCommonAuras:LOOT_OPENED()
	for lootIndex = 1, GetNumLootItems() do
		if (LootSlotIsItem(lootIndex)) then
			local _, lootName = GetLootSlotInfo(lootIndex);
			if lootName == L["aq40insignia"] then
				local unitName = UnitName("target")
				if unitName then
					self:TriggerEvent("BigWigs_SendSync", "BWCAAQ40INSIGNIA " .. unitName)
				else
					self:TriggerEvent("BigWigs_SendSync", "BWCAAQ40INSIGNIA")
				end
			elseif lootName == L["aq40artifact"] then
				local unitName = UnitName("target")
				if unitName then
					self:TriggerEvent("BigWigs_SendSync", "BWCAAQ40ARTIFACT " .. unitName)
				else
					self:TriggerEvent("BigWigs_SendSync", "BWCAAQ40ARTIFACT")
				end
			end
		end
	end
end

--Debug
--function BigWigsCommonAuras:CHAT_MSG_SAY(msg)
--end

function BigWigsCommonAuras:ExaltedForFaction(factionName)
	for factionIndex = 1, GetNumFactions() do
		local fname, description, standingId = GetFactionInfo(factionIndex);
		if fname == factionName then
			if standingId == 8 then
				return true
			end
		end
	end
	return nil
end

function BigWigsCommonAuras:PFUIFocus(guid)
	if not pfUI.uf or not pfUI.uf.focus then
		return
	end

	pfUI.uf.focus.label = nil
	pfUI.uf.focus.guid = guid
	pfUI.uf.focus.unitname = strlower(UnitName(guid))
end

function BigWigsCommonAuras:BigWigs_RecvSync(sync, rest, nick)
	if not nick then
		nick = UnitName("player")
	end
	if self.db.profile.autofocus and sync == "BWCAAF" then
		if pfUI and rest then
			self:PFUIFocus(rest)
		end
	elseif self.db.profile.fearward and sync == "BWCAFW" and rest then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_fearward"] .. rest, "Positive", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_fearward"], timer.fearward, icon.fearward, true, color.fearward)
	elseif self.db.profile.shieldwall and sync == "BWCASW" then
		local swTime = tonumber(rest)
		if not swTime then
			swTime = 10
		end -- If the tank uses an old BWCA, just assume 10 seconds.
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_shieldwall"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_shieldwall"], swTime, icon.shieldwall, true, color.shieldwall)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_shieldwall"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.laststand and sync == "BWCALS" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_laststand"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_laststand"], timer.laststand, icon.laststand, true, color.laststand)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_laststand"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.lifegivinggem and sync == "BWCALG" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_lifegivingGem"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_lifegivingGem"], timer.lifegivingGem, icon.lifegivingGem, true, color.lifegivingGem)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_lifegivingGem"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.challengingshout and sync == "BWCACS" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_challengingShout"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_challengingShout"], timer.challenging, icon.challengingShout, true, color.challengingShout)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_challengingShout"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)


	elseif self.db.profile.challengingroar and sync == "BWCACR" then
		self:TriggerEvent("BigWigs_Message", nick .. L["msg_challengingRoar"], "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_challengingRoar"], timer.challenging, icon.challengingRoar, true, color.challengingRoar)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_challengingRoar"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)

	elseif self.db.profile.di and sync == "BWCADI" then
		self:TriggerEvent("BigWigs_Message", L["msg_divineIntervention"] .. nick, "Urgent", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, nick .. L["bar_divineIntervention"], timer.di, icon.di, true, color.di)
		self:SetCandyBarOnClick("BigWigsBar " .. nick .. L["bar_divineIntervention"], function(name, button, extra)
			TargetByName(extra, true)
		end, nick)

	elseif self.db.profile.portal and sync == "BWCAP" and rest then
		rest = BS:HasTranslation(rest) and BS:GetTranslation(rest) or rest
		local _, _, zone = string.find(rest, L["portal_regexp"])
		if zone then
			if zone == "Orgrimmar" or zone == "Thunder Bluff" or zone == "Undercity" or zone == "Stonard" then
				portalColor = "Red"
				portalText = "--HORDE-- portal to "
			elseif zone == "Stormwind" or zone == "Ironforge" or zone == "Darnassus" or zone == "Theramore" then
				portalColor = "Blue"
				portalText = "--ALLIANCE-- portal to "
			elseif zone == "Karazhan" or zone then
				portalColor = "Green"
				portalText = "--NEUTRAL-- portal to "
			end
			self:TriggerEvent("BigWigs_Message", portalText .. zone, "Attention", false, nil, false)
			if zone == "Stonard" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalStonard", true, portalColor)
			elseif zone == "Theramore" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalTheramore", true, portalColor)
			elseif zone == "Karazhan" then
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, L["iconPrefix"] .. "Spell_Arcane_PortalUndercity", true, portalColor)
			else
				self:TriggerEvent("BigWigs_StartBar", self, rest, timer.portal, BS:GetSpellIcon(rest), true, portalColor)
			end
		end


	elseif self.db.profile.wormhole and sync == "BWCAWH" and rest then
		if rest == "Orgrimmar" then
			whColor = "Red"
			whText = "--HORDE-- wormhole to Orgrimmar"
		elseif rest == "Stormwind" then
			whColor = "Blue"
			whText = "--ALLIANCE-- wormhole to Stormwind"
		end
		self:TriggerEvent("BigWigs_Message", whText, "Attention", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, rest .. L["bar_wormhole"], timer.wormhole, icon.wormhole, true, whColor)
		self:TriggerEvent("BigWigs_Sound", "Info")
		self:TriggerEvent("BigWigs_ShowWarningSign", icon.wormhole, 2)


	elseif self.db.profile.orange and sync == "BWCAOR" then
		local zone = GetRealZoneText()
		if rest and rest == GetRealZoneText() then
			self:TriggerEvent("BigWigs_Message", L["msg_orange"], "Positive", false, nil, false)
			self:TriggerEvent("BigWigs_StartBar", self, L["bar_orange"], timer.orange, icon.orange, true, color.orange)
			self:TriggerEvent("BigWigs_Sound", "Info")
			self:TriggerEvent("BigWigs_ShowWarningSign", icon.orange, 5)
		end

	elseif self.db.profile.orange and sync == "BWCAWL" then
		self:TriggerEvent("BigWigs_Message", L["msg_soulwell"], "Positive", false, nil, false)
		self:TriggerEvent("BigWigs_StartBar", self, L["bar_soulwell"], timer.soulwell, icon.soulwell, true, color.soulwell)
		self:TriggerEvent("BigWigs_Sound", "Info")
		self:TriggerEvent("BigWigs_ShowWarningSign", icon.soulwell, 5)

	elseif self.db.profile.aq40insignia and sync == "BWCAAQ40INSIGNIA" then
		-- check rep
		local exalted = self:ExaltedForFaction(L["broodFactionName"]) and self:ExaltedForFaction(L["cenarionFactionName"])

		if not exalted and self.db.profile.aq40insignia then
			local msg = L["bar_aq40insignia"]
			if rest then
				msg = msg .. " from " .. rest
			end
			self:TriggerEvent("BigWigs_StartBar", self, msg, timer.aq40insignia, icon.aq40insignia, true, color.aq40insignia)
			self:TriggerEvent("BigWigs_Sound", "Info")
		end
	elseif self.db.profile.aq40artifact and sync == "BWCAAQ40ARTIFACT" then
		local exalted = self:ExaltedForFaction(L["broodFactionName"])
		if not exalted and self.db.profile.aq40artifact then
			local msg = L["bar_aq40artifact"]
			if rest then
				msg = msg .. " from " .. rest
			end
			self:TriggerEvent("BigWigs_StartBar", self, msg, timer.aq40artifact, icon.aq40artifact, true, color.aq40artifact)
			self:TriggerEvent("BigWigs_Sound", "Info")
		end
	end
end
