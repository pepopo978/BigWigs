--[[
--
-- BigWigs Strategy Module - Combat Announcement
--
-- announces in chat channel for important instant ability casts
--
--
--]]

------------------------------
--      Are you local?      --
------------------------------

local name = "Combat Announcement"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local BS = AceLibrary("Babble-Spell-2.2")

local spellStatus = AceLibrary("SpellStatusV2-2.0")
local _, class = UnitClass("player")

------------------------------
--      Localization        --
------------------------------

L:RegisterTranslations("enUS", function()
	return {
		["Toggle %s display."] = true,

		["Announces in chat channel on important instant casts."] = true,
		["Combat Announcement"] = true,
		["combatannouncement"] = true,
	}
end)


------------------------------
--      Module              --
------------------------------

BigWigsCombatAnnouncement = BigWigs:NewModule(name, "AceHook-2.1")
BigWigsCombatAnnouncement.synctoken = myname

local RaidMarkerIndexToText = {
	[1] = "(Star)",
	[2] = "(Circle)",
	[3] = "(Diamond)",
	[4] = "(Triangle)",
	[5] = "(Moon)",
	[6] = "(Square)",
	[7] = "(Cross)",
	[8] = "(Skull)",
}

local SpellTranslation = {
	["pummel"] = BS["Pummel"],
	["taunt"] = BS["Taunt"],
	["disarm"] = BS["Disarm"],
	["challengingshout"] = BS["Challenging Shout"],
	["intimidatingshout"] = BS["Intimidating Shout"],
	["concussionblow"] = BS["Concussion Blow"],
	["kick"] = BS["Kick"],
	["kidneyshot"] = BS["Kidney Shot"],
	["cheapshot"] = BS["Cheap Shot"],
	["blind"] = BS["Blind"],
	["gouge"] = BS["Gouge"],
	["pounce"] = BS["Pounce"],
	["bash"] = BS["Bash"],
	["growl"] = BS["Growl"],
	["wyvernsting"] = BS["Wyvern Sting"],
	["scattershot"] = BS["Scatter Shot"],
	["tranquilshot"] = BS["Tranquilizing Shot"],
	["counterspell"] = BS["Counterspell"],
	["hammerofjustice"] = BS["Hammer of Justice"],
	["psychicscream"] = BS["Psychic Scream"],
	["earthshock"] = BS["Earth Shock"],
	["deathcoil"] = BS["Death Coil"],
}

BigWigsCombatAnnouncement.defaultDB = {
	-- Warrior
	pummel = true,
	taunt = true,
	disarm = true,
	challengingshout = true,
	intimidatingshout = false,
	concussionblow = false,
	-- Rogue
	kick = true,
	kidneyshot = true,
	cheapshot = true,
	blind = true,
	gouge = true,
	-- Druid
	pounce = true,
	bash = true,
	growl = true,
	-- Hunter
	wyvernsting = true,
	scattershot = true,
	tranquilshot = false,
	-- Mage
	counterspell = true,
	-- Paladin
	hammerofjustice = true,
	-- Priest
	psychicscream = true,
	-- Shaman
	earthshock = true,
	-- Warlock
	deathcoil = true,

	-- General
	broadcastsay = true,
	broadcastparty = false,
	broadcastraid = false,
	broadcastbg = false,
}

BigWigsCombatAnnouncement.consoleCmd = L["combatannouncement"]

if class == "WARRIOR" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			pummel = {
				type = "toggle",
				name = "Pummel",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Pummel"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.pummel
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.pummel = v
				end,
			},
			taunt = {
				type = "toggle",
				name = "Taunt",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Taunt"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.taunt
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.taunt = v
				end,
			},
			disarm = {
				type = "toggle",
				name = "Disarm",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Disarm"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.disarm
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.disarm = v
				end,
			},
			challengingshout = {
				type = "toggle",
				name = "Challenging Shout",
				order = 4,
				desc = string.format(L["Toggle %s display."], "Challenging Shout"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.challengingshout
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.challengingshout = v
				end,
			},
			intimidatingshout = {
				type = "toggle",
				name = "Intimidating Shout",
				order = 5,
				desc = string.format(L["Toggle %s display."], "Intimidating Shout"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.intimidatingshout
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.intimidatingshout = v
				end,
			},
			concussionblow = {
				type = "toggle",
				name = "Concussion Blow",
				order = 6,
				desc = string.format(L["Toggle %s display."], "Concussion Blow"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.concussionblow
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.concussionblow = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "ROGUE" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			kick = {
				type = "toggle",
				name = "Kick",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Kick"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.kick
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.kick = v
				end,
			},
			kidneyshot = {
				type = "toggle",
				name = "Kidney Shot",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Kidney Shot"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.kidneyshot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.kidneyshot = v
				end,
			},
			cheapshot = {
				type = "toggle",
				name = "Cheapshot",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Cheapshot"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.cheapshot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.cheapshot = v
				end,
			},
			blind = {
				type = "toggle",
				name = "Blind",
				order = 4,
				desc = string.format(L["Toggle %s display."], "Blind"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.blind
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.blind = v
				end,
			},
			gouge = {
				type = "toggle",
				name = "Gouge",
				order = 5,
				desc = string.format(L["Toggle %s display."], "Gouge"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.gouge
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.gouge = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "DRUID" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			pounce = {
				type = "toggle",
				name = "Pounce",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Pounce"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.pounce
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.pounce = v
				end,
			},
			bash = {
				type = "toggle",
				name = "Bash",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Bash"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.bash
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.bash = v
				end,
			},
			growl = {
				type = "toggle",
				name = "Growl",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Growl"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.growl
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.growl = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "HUNTER" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			wyvernsting = {
				type = "toggle",
				name = "Wyvern Sting",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Wyvern Sting"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.wyvernsting
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.wyvernsting = v
				end,
			},
			scattershot = {
				type = "toggle",
				name = "Scatter Shot",
				order = 2,
				desc = string.format(L["Toggle %s display."], "Scatter Shot"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.scattershot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.scattershot = v
				end,
			},
			tranquilshot = {
				type = "toggle",
				name = "Tranquil Shot",
				order = 3,
				desc = string.format(L["Toggle %s display."], "Tranquil Shot"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.tranquilshot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.tranquilshot = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "MAGE" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			counterspell = {
				type = "toggle",
				name = "Counterspell",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Counterspell"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.counterspell
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.counterspell = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "PALADIN" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			hammerofjustice = {
				type = "toggle",
				name = "Hammer of Justice",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Hammer of Justice"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.hammerofjustice
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.hammerofjustice = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "PRIEST" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			psychicscream = {
				type = "toggle",
				name = "Psychic Scream",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Psychic Scream"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.psychicscream
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.psychicscream = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "SHAMAN" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			earthshock = {
				type = "toggle",
				name = "Earthshock",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Earthshock"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.earthshock
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.earthshock = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

elseif class == "WARLOCK" then
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			deathcoil = {
				type = "toggle",
				name = "Death Coil",
				order = 1,
				desc = string.format(L["Toggle %s display."], "Death Coil"),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.deathcoil
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.deathcoil = v
				end,
			},
			spacer = {
				type = "header",
				name = " ",
				order = 96,
			},
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}

else
	BigWigsCombatAnnouncement.consoleOptions = {
		type = "group",
		name = "Combat Announcement",
		desc = "Announces in chat channel on important instant casts.",
		args = {
			broadcastsay = {
				type = "toggle",
				name = "Broadcast Say",
				order = 97,
				desc = "Toggle broadcasting the messages to the Say channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastsay
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastsay = v
				end,
			},
			broadcastparty = {
				type = "toggle",
				name = "Broadcast Party",
				order = 98,
				desc = "Toggle broadcasting the messages to the Party channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastparty
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastparty = v
				end,
			},
			broadcastraid = {
				type = "toggle",
				name = "Broadcast Raid",
				order = 99,
				desc = "Toggle broadcasting the messages to the Raid channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastraid
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastraid = v
				end,
			},
			broadcastbg = {
				type = "toggle",
				name = "Broadcast BG",
				order = 100,
				desc = "Toggle broadcasting the messages to the Battleground channel (Bloodring).",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastbg
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastbg = v
				end,
			},
		}
	}
end

BigWigsCombatAnnouncement.revision = 20005
BigWigsCombatAnnouncement.external = true

------------------------------
--      Initialization      --
------------------------------

function BigWigsCombatAnnouncement:OnEnable()
	self:RegisterEvent("SpellStatusV2_SpellCastInstant")
end

------------------------------
--          Util            --
------------------------------

function BigWigsCombatAnnouncement:IsBroadcasting()
	if self.db.profile.broadcastsay or self.db.profile.broadcastparty or self.db.profile.broadcastraid or self.db.profile.broadcastbg then
		return true
	end
end

function BigWigsCombatAnnouncement:AnnounceAbility(msg)
	if self.db.profile.broadcastsay and (GetNumPartyMembers("player") > 0 or UnitInRaid("player")) then
		SendChatMessage(msg, "SAY")
	end
	if self.db.profile.broadcastparty and GetNumPartyMembers("player") > 0 then
		SendChatMessage(msg, "PARTY")
	end
	if self.db.profile.broadcastraid and UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	end
	if self.db.profile.broadcastbg and GetZoneText() == "Blood Ring" then
		SendChatMessage(msg, "BATTLEGROUND")
	end
end

------------------------------
--         Events           --
------------------------------

function BigWigsCombatAnnouncement:SpellStatusV2_SpellCastInstant(id, name, rank, fullname, caststart, caststop, castduration, castdelay, activetarget)
	if not BigWigsCombatAnnouncement:IsBroadcasting() then
		return
	end

	for optionname, translatedname in pairs(SpellTranslation) do
		if self.db.profile[optionname] == true then
			if name == translatedname then
				local CombatAnnouncementString = "Casted " .. name
				if activetarget and activetarget ~= "none" then
					CombatAnnouncementString = CombatAnnouncementString .. " on " .. activetarget
				end
				BigWigsCombatAnnouncement:AnnounceAbility(CombatAnnouncementString)
			end
		end
	end
end
