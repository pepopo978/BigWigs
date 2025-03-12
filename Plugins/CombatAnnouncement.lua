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
local BS = AceLibrary("Babble-Spell-2.3")

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
		["Hand of Reckoning"] = true,
		["Earthshaker Slam"] = true,
		["Innervate"] = true, -- Add Innervate to localization
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
	["shieldbash"] = BS["Shield Bash"],
	["taunt"] = BS["Taunt"],
	["handofreckoning"] = L["Hand of Reckoning"],
	["earthshakerslam"] = L["Earthshaker Slam"],
	["innervate"] = BS["Innervate"], -- Added Innervate to the spell translations
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
	["hibernate"] = BS["Hibernate"],
	["entanglingroots"] = BS["Entangling Roots"],
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
	shieldbash = true,
	taunt = true,
	disarm = true,
	challengingshout = true,
	intimidatingshout = false,
	concussionblow = true,
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
	hibernate = true,
	entanglingroots = true,
	innervate = true,
	-- Hunter
	wyvernsting = true,
	scattershot = true,
	tranquilshot = false,
	-- Mage
	counterspell = true,
	-- Paladin
	hammerofjustice = true,
	handofreckoning = true,
	-- Priest
	psychicscream = true,
	-- Shaman
	earthshock = false, -- spams too much if shaman tank
	earthshakerslam = true,
	-- Warlock
	deathcoil = true,

	-- General
	broadcastsay = true,
	broadcastparty = false,
	broadcastraid = false,
	broadcastbg = false,
	broadcastwhisper = false, -- Added general option for whisper
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
				name = BS["Pummel"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Pummel"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.pummel
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.pummel = v
				end,
			},
			shieldbash = {
				type = "toggle",
				name = BS["Shield Bash"],
				order = 2,
				desc = string.format(L["Toggle %s display."], BS["Shield Bash"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.shieldbash
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.shieldbash = v
				end,
			},
			taunt = {
				type = "toggle",
				name = BS["Taunt"],
				order = 3,
				desc = string.format(L["Toggle %s display."], BS["Taunt"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.taunt
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.taunt = v
				end,
			},
			disarm = {
				type = "toggle",
				name = BS["Disarm"],
				order = 4,
				desc = string.format(L["Toggle %s display."], BS["Disarm"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.disarm
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.disarm = v
				end,
			},
			challengingshout = {
				type = "toggle",
				name = BS["Challenging Shout"],
				order = 5,
				desc = string.format(L["Toggle %s display."], BS["Challenging Shout"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.challengingshout
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.challengingshout = v
				end,
			},
			intimidatingshout = {
				type = "toggle",
				name = BS["Intimidating Shout"],
				order = 6,
				desc = string.format(L["Toggle %s display."], BS["Intimidating Shout"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.intimidatingshout
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.intimidatingshout = v
				end,
			},
			concussionblow = {
				type = "toggle",
				name = BS["Concussion Blow"],
				order = 7,
				desc = string.format(L["Toggle %s display."], BS["Concussion Blow"]),
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
				name = BS["Kick"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Kick"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.kick
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.kick = v
				end,
			},
			kidneyshot = {
				type = "toggle",
				name = BS["Kidney Shot"],
				order = 2,
				desc = string.format(L["Toggle %s display."], BS["Kidney Shot"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.kidneyshot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.kidneyshot = v
				end,
			},
			cheapshot = {
				type = "toggle",
				name = BS["Cheap Shot"],
				order = 2,
				desc = string.format(L["Toggle %s display."], BS["Cheap Shot"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.cheapshot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.cheapshot = v
				end,
			},
			blind = {
				type = "toggle",
				name = BS["Blind"],
				order = 4,
				desc = string.format(L["Toggle %s display."], BS["Blind"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.blind
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.blind = v
				end,
			},
			gouge = {
				type = "toggle",
				name = BS["Gouge"],
				order = 5,
				desc = string.format(L["Toggle %s display."], BS["Gouge"]),
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
			innervate = {
				type = "toggle",
				name = BS["Innervate"],
				order = 1,
				desc = string.format(L["Toggle %s display."], L["Innervate"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.innervate
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.innervate = v
				end,
			},
			pounce = {
				type = "toggle",
				name = BS["Pounce"],
				order = 2,
				desc = string.format(L["Toggle %s display."], BS["Pounce"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.pounce
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.pounce = v
				end,
			},
			bash = {
				type = "toggle",
				name = BS["Bash"],
				order = 3,
				desc = string.format(L["Toggle %s display."], BS["Bash"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.bash
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.bash = v
				end,
			},
			growl = {
				type = "toggle",
				name = BS["Growl"],
				order = 4,
				desc = string.format(L["Toggle %s display."], BS["Growl"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.growl
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.growl = v
				end,
			},
			hibernate = {
				type = "toggle",
				name = BS["Hibernate"],
				order = 4,
				desc = string.format(L["Toggle %s display."], BS["Hibernate"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.hibernate
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.hibernate = v
				end,
			},
			entanglingroots = {
				type = "toggle",
				name = BS["Entangling Roots"],
				order = 5,
				desc = string.format(L["Toggle %s display."], BS["Entangling Roots"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.entanglingroots
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.entanglingroots = v
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
			broadcastwhisper = {
				type = "toggle",
				name = "Broadcast Whisper",
				order = 101,
				desc = "Toggle broadcasting the messages to the Whisper channel.",
				get = function()
					return BigWigsCombatAnnouncement.db.profile.broadcastwhisper
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.broadcastwhisper = v
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
				name = BS["Wyvern Sting"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Wyvern Sting"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.wyvernsting
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.wyvernsting = v
				end,
			},
			scattershot = {
				type = "toggle",
				name = BS["Scatter Shot"],
				order = 2,
				desc = string.format(L["Toggle %s display."], BS["Scatter Shot"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.scattershot
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.scattershot = v
				end,
			},
			tranquilshot = {
				type = "toggle",
				name = BS["Tranquilizing Shot"],
				order = 3,
				desc = string.format(L["Toggle %s display."], BS["Tranquilizing Shot"]),
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
				name = BS["Counterspell"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Counterspell"]),
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
				name = BS["Hammer of Justice"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Hammer of Justice"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.hammerofjustice
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.hammerofjustice = v
				end,
			},
			handofreckoning = {
				type = "toggle",
				name = L["Hand of Reckoning"],
				order = 2,
				desc = string.format(L["Toggle %s display."], L["Hand of Reckoning"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.handofreckoning
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.handofreckoning = v
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
				name = BS["Psychic Scream"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Psychic Scream"]),
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
				name = BS["Earth Shock"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Earth Shock"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.earthshock
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.earthshock = v
				end,
			},
			earthshakerslam = {
				type = "toggle",
				name = L["Earthshaker Slam"],
				order = 2,
				desc = string.format(L["Toggle %s display."], L["Earthshaker Slam"]),
				get = function()
					return BigWigsCombatAnnouncement.db.profile.earthshakerslam
				end,
				set = function(v)
					BigWigsCombatAnnouncement.db.profile.earthshakerslam = v
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
				name = BS["Death Coil"],
				order = 1,
				desc = string.format(L["Toggle %s display."], BS["Death Coil"]),
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

BigWigsCombatAnnouncement.revision = 20007
BigWigsCombatAnnouncement.external = true

------------------------------
--      Initialization      --
------------------------------

------------------------------
--         Events           --
------------------------------

function BigWigsCombatAnnouncement:CastEvent(id, name, rank, fullname, caststart, caststop, castduration, castdelay, activetarget)
	if not BigWigsCombatAnnouncement:IsBroadcasting() then
		return
	end

	for optionname, translatedname in pairs(SpellTranslation) do
		if self.db.profile[optionname] == true then
			if name == translatedname then
				local CombatAnnouncementString = "Casted " .. name
				if activetarget and activetarget ~= "none" then
					CombatAnnouncementString = CombatAnnouncementString .. " on " .. activetarget
					BigWigsCombatAnnouncement:AnnounceAbility(CombatAnnouncementString, activetarget, name) -- Pass target for whispers
				else
					BigWigsCombatAnnouncement:AnnounceAbility(CombatAnnouncementString) -- regular announcements without target
				end
			end
		end
	end
end

function BigWigsCombatAnnouncement:OnEnable()
	self:RegisterEvent("SpellStatusV2_SpellCastInstant", "CastEvent")

	if class == "DRUID" then
		self:RegisterEvent("SpellStatusV2_SpellCastCastingFinish", "CastEvent")
	end
end

function BigWigsCombatAnnouncement:IsBroadcasting()
	return self.db.profile.broadcastsay or
			self.db.profile.broadcastparty or
			self.db.profile.broadcastraid or
			self.db.profile.broadcastbg or
			self.db.profile.broadcastwhisper
end

------------------------------
--          Util            --
------------------------------

function BigWigsCombatAnnouncement:AnnounceAbility(msg, target, spellName)
	-- Check if the spell is Innervate and the target is hostile
	if spellName == L["Innervate"] and target and not UnitIsFriend("player", "target") then
		return -- Ignore announcements for Innervate on hostile targets
	end

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
	-- Only send whisper if the spell name has a target that is a friendly player
	if self.db.profile.broadcastwhisper and
			target and
			UnitIsFriend("player", "target") and
			not UnitIsUnit("player", "target") and
			UnitIsPlayer("target") then
		SendChatMessage("Casted " .. spellName .. " on you", "WHISPER", nil, target)
	end
end
