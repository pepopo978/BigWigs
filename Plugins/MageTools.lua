--[[
This is a plugin to help mages track their fire vulnerability and ignite debuffs.
--]]

assert(BigWigs, "BigWigs not found!")

local _, englishClass = UnitClass("player");
local isMage = false;
if englishClass == "MAGE" then
	isMage = true
else
	return
end

-----------------------------------------------------------------------
--      Are you local?
-----------------------------------------------------------------------
local name = "MageTools"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs" .. name)
local paint = AceLibrary("PaintChips-2.0")
local candybar = AceLibrary("CandyBar-2.2")
local surface = AceLibrary("Surface-1.0")

local timer = {
	scorch = 30,
	ignite = 6,
}
local syncName = {
	scorch = "ScorchHit",
	scorchSpace = "ScorchHit ",
	ignite = "IgniteHit",
	igniteSpace = "IgniteHit ",

	ignitePlayerWarning = "IgnitePlayerWarning",
	ignitePlayerWarningSpace = "IgnitePlayerWarning ",

	ignitePyroRequest = "IgnitePyroRequest",
	ignitePyroRequestSpace = "IgnitePyroRequest ",

	fetishStart = "FetishStart",
	fetishFade = "FetishFade",
	eyeOfDimStart = "eyeOfDimStart",
	eyeOfDimFade = "eyeOfDimFade",
}

local scorchIcon = "Interface\\Icons\\Spell_Fire_SoulBurn"
local igniteIcon = "Interface\\Icons\\Spell_Fire_Incinerate"
local threatIcon = "Interface\\Icons\\inv_misc_bone_orcskull_01"

local scorchBarPrefix = "ScorchTimerBar"
local igniteBarPrefix = "IgniteBar"
local threatBarPrefix = "ThreatBar"

local warningSoundEvent = "warningSoundEvent"
local warningSignEvent = "warningSignEvent"
local targetChangeEvent = "targetChangeEvent"
local scorchTimerUpdateEvent = "scorchTimerUpdateEvent"

local warningSyncSpeed = 5

local ticksForWarning = 4     -- if another player own's ignite
local ticksForSelfWarning = 5 -- if current player owns the ignite
-----------------------------------------------------------------------
--      Localization
-----------------------------------------------------------------------

L:RegisterTranslations("enUS", function()
	return {
		-- general settings
		["MageToolsCmd"] = "magetools",
		["MageTools"] = "Mage Tools",
		["MageToolsDesc"] = "Scorch/Ignite tools for mages",
		["Enable"] = "Enable",
		["EnableDesc"] = "Whether to check talents to see if tools should activate",
		["Active"] = "Active",
		["ActiveDesc"] = "Activate Mage tools (only works if you are a fire mage)",
		["Debug"] = "Debug",

		["AnchorTitle"] = "Extras -> Mage Tools",
		["ShowAnchor"] = "Show anchor frame",
		["ShowAnchorDesc"] = "Show the anchor frame for controlling where the mage tools appear.",

		["Texture"] = "Texture",
		["TextureDesc"] = "Set the texture for the bars.",

		["BarSpacing"] = "Bar Spacing",
		["BarSpacingDesc"] = "Vertical space between bars.",

		["ResetPosition"] = "Reset Anchor Position",
		["ResetPositionDesc"] = "Reset the anchor position, moving it to the center of your screen.",

		["Test"] = "Start Test",
		["Close"] = "Close",

		-- scorch settings
		["ScorchBarOptions"] = "Scorch Bar Options",
		["ScorchEnable"] = "Enable",
		["ScorchEnableTimer"] = "Enable scorch timer",
		["ScorchEnableTimerDesc"] = "Displays a timer for Scorch Fire Vulnerability.",
		["ScorchWarningSound"] = "Warning Sound",
		["ScorchWarningSoundDesc"] = "Says 'Scorch' when there are 5 seconds left before it falls off",
		["ScorchResistSound"] = "Resist Sound",
		["ScorchResistSoundDesc"] = "Says 'Scorch Resist' if any Scorch or Fire Vulnerability gets resisted",
		["ScorchWarningSign"] = "Warning Sign",
		["ScorchWarningSignDesc"] = "Show a warning sign when there are 5 seconds left before it falls off",
		["ScorchBarWidth"] = "Scorch bar width",
		["ScorchBarWidthDesc"] = "Sets the width of the scorch bar",
		["ScorchBarHeight"] = "Scorch bar height",
		["ScorchBarHeightDesc"] = "Sets the height of the scorch bar",

		-- ignite settings
		["IgniteBarOptions"] = "Ignite Bar Options",
		["IgniteEnable"] = "Enable",
		["IgniteTimerMode"] = "Ignite timer mode",
		["IgniteTimerModeDesc"] = "In timer mode bar size will indicate remaining time in ignite window.  Otherwise bar will grow with ignite stacks.",
		["IgniteBarWidth"] = "Ignite bar width",
		["IgniteBarWidthDesc"] = "Sets the width of the ignite bar at 5 stacks",
		["IgniteBarHeight"] = "Ignite bar height",
		["IgniteBarHeightDesc"] = "Sets the height of the ignite bar",

		["IgniteThreatBarOptions"] = "Ignite Threat Bar Options",
		["IgniteThreatEnable"] = "Show ignite threat bar",
		["IgniteThreatEnableDesc"] = "Show the ignite owner's percent threat",
		["IgniteThreatThreshold"] = "Ignite threat threshold",
		["IgniteThreatThresholdDesc"] = "Percentage of top threat at which to turn red",
		["IgniteThreatBarWidth"] = "Ignite threat bar width",
		["IgniteThreatBarWidthDesc"] = "Sets the width of the ignite threat bar at 100% threat",
		["IgniteThreatBarHeight"] = "Ignite threat bar height",
		["IgniteThreatBarHeightDesc"] = "Sets the height of the ignite threat bar",

		["IgniteAutoWarning"] = "Automated ignite warning",
		["IgniteAutoWarningDesc"] = "Warning message when small number of ignite ticks will pull aggro for the ignite owner",

		["ThreatTrinketAlerts"] = "Threat Trinket Alerts",
		["ThreatTrinketAlertsDesc"] = "Notify when other mages use Fetish or Eye of Diminution",

		["IgnitePlayerWarning"] = "Ignite player warnings",
		["IgnitePlayerWarningDesc"] = "Whether to display + play sounds for manual player warnings",
		["IgnitePlayerWarningTrigger"] = "Trigger ignite warning",
		["IgnitePlayerWarningTriggerDesc"] = "/bw extra magetools ignitewarningtrigger",

		["IgnitePyroRequest"] = "Pyro sync requests",
		["IgnitePyroRequestDesc"] = "Whether to display + play sounds for manual player pryo requests",
		["IgnitePyroRequestTrigger"] = "Trigger pyro request",
		["IgnitePyroRequestTriggerDesc"] = "/bw extra magetools ignitepyrotrigger",

		scorch_afflict_test = "^(.+) is afflicted by Fire Vulnerability(.*)", -- for stacks 2-5 will be "Fire Vulnerability (2)".
		scorch_gains_test = "^(.+) gains Fire Vulnerability(.*)", -- for stacks 2-5 will be "Fire Vulnerability (2)".
		scorch_test = ".+ Scorch (.+)s (.+) for",
		scorch_fades_test = "Fire Vulnerability fades from (.+).",
		scorch_resist_test = "(.+) Scorch was resisted by (.+).",
		fire_vuln_resist_test = "(.+) Fire Vulnerability was resisted by (.+).", -- Scorch can hit but fire vulnerability can resist independently

		ignite_afflict_test = "^(.+) is afflicted by Ignite(.*)", -- for stacks 2-5 will be "Ignite (2)".
		ignite_gains_test = "^(.+) gains Ignite(.*)", -- for stacks 2-5 will be "Ignite (2)".
		self_ignite_crit_test = "^(Your) (.+) crits (.+) for .+ Fire damage",
		other_ignite_crit_test = "^(.+)'s (.+) crits (.+) for .+ Fire damage",
		ignite_dmg = "^(.+) suffers (.+) Fire damage from (.+) Ignite",
		ignite_fades_test = "Ignite fades from (.+).",

		arcane_shroud_test = "You gain Arcane Shroud", -- Fetish of the sand reaver
		arcane_shroud_fades_test = "Arcane Shroud fades from you",
		eye_of_diminution_test = "You gain The Eye of Diminution", -- Eye of Diminution
		eye_of_diminution_fades_test = "The Eye of Diminution fades from you",

		slain_test = "(.+) is slain by (.+)",
		self_slain_test = "You have slain (.+)",
		death_test = "(.+) dies.",
	}
end)

-----------------------------------------------------------------------
--      Module Declaration
-----------------------------------------------------------------------

BigWigsMageTools = BigWigs:NewModule(name)
BigWigsMageTools.defaultDB = {
	enable = isMage,
	debug = false,
	barspacing = 5,
	texture = "BantoBar",
	posx = nil,
	posy = nil,

	scorchenable = true,
	scorchtimer = true,
	scorchsound = false,
	scorchwarningsign = false,
	scorchresistsound = false,
	scorchwidth = 200,
	scorchheight = 15,

	igniteenable = true,
	ignitetimermode = false,
	ignitewidth = 200,
	igniteheight = 20,

	ignitethreatenable = true,
	ignitethreatthreshold = 80,
	ignitethreatwidth = 180,
	ignitethreatheight = 30,
	igniteautowarning = true,
	igniteplayerwarning = true,
	ignitepyrorequest = true,
	threattrinketalerts = true,
}

BigWigsMageTools.consoleCmd = L["MageToolsCmd"]
BigWigsMageTools.consoleOptions = {
	type = "group",
	name = L["MageTools"],
	desc = L["MageToolsDesc"],
	args = {
		active = {
			type = "toggle",
			name = L["Active"],
			desc = L["ActiveDesc"],
			order = 1,
			get = function()
				return BigWigsMageTools.active
			end,
			set = function(v)
				if v then
					BigWigsMageTools:Activate()
				else
					BigWigsMageTools:Deactivate()
				end
			end,
		},
		debug = {
			type = "toggle",
			name = L["Debug"],
			desc = L["Debug"],
			order = 1,
			get = function()
				return BigWigsMageTools.db.profile.debug
			end,
			set = function(v)
				BigWigsMageTools.db.profile.debug = v
			end,
		},
		anchor = {
			type = "execute",
			name = L["ShowAnchor"],
			desc = L["ShowAnchorDesc"],
			order = 2,
			func = function()
				BigWigsMageTools:ShowAnchors()
			end,
		},
		reset = {
			type = "execute",
			name = L["ResetPosition"],
			desc = L["ResetPositionDesc"],
			order = 3,
			func = function()
				BigWigsMageTools:ResetAnchor()
			end,
		},
		texture = {
			type = "text",
			name = L["Texture"],
			desc = L["TextureDesc"],
			order = 4,
			get = function()
				return BigWigsMageTools.db.profile.texture
			end,
			set = function(v)
				BigWigsMageTools.db.profile.texture = v
			end,
			validate = surface:List(),
		},
		barspacing = {
			type = "range",
			name = L["BarSpacing"],
			desc = L["BarSpacingDesc"],
			order = 5,
			min = 0,
			max = 30,
			step = 1,
			get = function()
				return BigWigsMageTools.db.profile.barspacing
			end,
			set = function(v)
				BigWigsMageTools.db.profile.barspacing = v
				if BigWigsMageTools.frames and BigWigsMageTools.frames.anchor then
					candybar:UpdateBarSpacing(BigWigsMageTools.frames.anchor.candyBarGroupId,
							BigWigsMageTools.db.profile.barspacing)
				end
			end,
		},
		scorchbar = {
			type = "group",
			name = L["ScorchBarOptions"],
			desc = L["ScorchBarOptions"],
			order = 6,
			args = {
				scorchenable = {
					type = "toggle",
					name = L["ScorchEnable"],
					desc = L["ScorchEnable"],
					order = 1,
					get = function()
						return BigWigsMageTools.db.profile.scorchenable
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchenable = v
					end,
				},
				scorchtimer = {
					type = "toggle",
					name = L["ScorchEnableTimer"],
					desc = L["ScorchEnableTimerDesc"],
					order = 2,
					get = function()
						return BigWigsMageTools.db.profile.scorchtimer
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchtimer = v
					end,
				},
				scorchsound = {
					type = "toggle",
					name = L["ScorchWarningSound"],
					desc = L["ScorchWarningSoundDesc"],
					order = 3,
					get = function()
						return BigWigsMageTools.db.profile.scorchsound
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchsound = v
					end,
				},
				scorchwarningsign = {
					type = "toggle",
					name = L["ScorchWarningSign"],
					desc = L["ScorchWarningSignDesc"],
					order = 4,
					get = function()
						return BigWigsMageTools.db.profile.scorchwarningsign
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchwarningsign = v
					end,
				},
				scorchresistsound = {
					type = "toggle",
					name = L["ScorchResistSound"],
					desc = L["ScorchResistSoundDesc"],
					order = 4,
					get = function()
						return BigWigsMageTools.db.profile.scorchresistsound
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchresistsound = v
					end,
				},
				scorchbarwidth = {
					type = "range",
					name = L["ScorchBarWidth"],
					desc = L["ScorchBarWidthDesc"],
					order = 5,
					min = 100,
					max = 300,
					step = 5,
					get = function()
						return BigWigsMageTools.db.profile.scorchwidth
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchwidth = v
					end,
				},
				scorchbarheight = {
					type = "range",
					name = L["ScorchBarHeight"],
					desc = L["ScorchBarHeightDesc"],
					order = 6,
					min = 10,
					max = 40,
					step = 1,
					get = function()
						return BigWigsMageTools.db.profile.scorchheight
					end,
					set = function(v)
						BigWigsMageTools.db.profile.scorchheight = v
					end,
				},
			}
		},
		ignitebar = {
			type = "group",
			name = L["IgniteBarOptions"],
			desc = L["IgniteBarOptions"],
			order = 7,
			args = {
				igniteenable = {
					type = "toggle",
					name = L["IgniteEnable"],
					desc = L["IgniteEnable"],
					order = 1,
					get = function()
						return BigWigsMageTools.db.profile.igniteenable
					end,
					set = function(v)
						BigWigsMageTools.db.profile.igniteenable = v
					end,
				},
				ignitetimermode = {
					type = "toggle",
					name = L["IgniteTimerMode"],
					desc = L["IgniteTimerModeDesc"],
					order = 3,
					get = function()
						return BigWigsMageTools.db.profile.ignitetimermode
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitetimermode = v
					end,
				},
				ignitewidth = {
					type = "range",
					name = L["IgniteBarWidth"],
					desc = L["IgniteBarWidthDesc"],
					order = 5,
					min = 100,
					max = 300,
					step = 5,
					get = function()
						return BigWigsMageTools.db.profile.ignitewidth
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitewidth = v
					end,
				},
				igniteheight = {
					type = "range",
					name = L["IgniteBarHeight"],
					desc = L["IgniteBarHeightDesc"],
					order = 7,
					min = 10,
					max = 40,
					step = 1,
					get = function()
						return BigWigsMageTools.db.profile.igniteheight
					end,
					set = function(v)
						BigWigsMageTools.db.profile.igniteheight = v
					end,
				}
			}
		},
		ignitethreatbar = {
			type = "group",
			name = L["IgniteThreatBarOptions"],
			desc = L["IgniteThreatBarOptions"],
			order = 9,
			args = {
				ignitethreatenable = {
					type = "toggle",
					name = L["IgniteThreatEnable"],
					desc = L["IgniteThreatEnableDesc"],
					order = 1,
					get = function()
						return BigWigsMageTools.db.profile.ignitethreatenable
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitethreatenable = v
					end,
				},
				ignitethreatthreshold = {
					type = "range",
					name = L["IgniteThreatThreshold"],
					desc = L["IgniteThreatThresholdDesc"],
					order = 2,
					min = 0,
					max = 100,
					step = 1,
					get = function()
						return BigWigsMageTools.db.profile.ignitethreatthreshold
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitethreatthreshold = v
					end,
				},
				ignitethreatwidth = {
					type = "range",
					name = L["IgniteThreatBarWidth"],
					desc = L["IgniteThreatBarWidthDesc"],
					order = 3,
					min = 100,
					max = 300,
					step = 5,
					get = function()
						return BigWigsMageTools.db.profile.ignitethreatwidth
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitethreatwidth = v
					end,
				},
				ignitethreatheight = {
					type = "range",
					name = L["IgniteThreatBarHeight"],
					desc = L["IgniteThreatBarHeightDesc"],
					order = 5,
					min = 10,
					max = 40,
					step = 1,
					get = function()
						return BigWigsMageTools.db.profile.ignitethreatheight
					end,
					set = function(v)
						BigWigsMageTools.db.profile.ignitethreatheight = v
					end,
				}
			}
		},
		spacer = {
			type = "header",
			name = " ",
			order = 11,
		},
		threattrinketalerts = {
			type = "toggle",
			name = L["ThreatTrinketAlerts"],
			desc = L["ThreatTrinketAlertsDesc"],
			order = 12,
			get = function()
				return BigWigsMageTools.db.profile.threattrinketalerts
			end,
			set = function(v)
				BigWigsMageTools.db.profile.threattrinketalerts = v
			end,
		},
		igniteautowarning = {
			type = "toggle",
			name = L["IgniteAutoWarning"],
			desc = L["IgniteAutoWarningDesc"],
			order = 13,
			get = function()
				return BigWigsMageTools.db.profile.igniteautowarning
			end,
			set = function(v)
				BigWigsMageTools.db.profile.igniteautowarning = v
			end,
		},
		igniteplayerwarning = {
			type = "toggle",
			name = L["IgnitePlayerWarning"],
			desc = L["IgnitePlayerWarningDesc"],
			order = 14,
			get = function()
				return BigWigsMageTools.db.profile.igniteplayerwarning
			end,
			set = function(v)
				BigWigsMageTools.db.profile.igniteplayerwarning = v
			end,
		},
		ignitepyrorequest = {
			type = "toggle",
			name = L["IgnitePyroRequest"],
			desc = L["IgnitePyroRequestDesc"],
			order = 15,
			get = function()
				return BigWigsMageTools.db.profile.ignitepyrorequest
			end,
			set = function(v)
				BigWigsMageTools.db.profile.ignitepyrorequest = v
			end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 17,
		},
		ignitewarningtrigger = {
			type = "execute",
			name = L["IgnitePlayerWarningTrigger"],
			desc = L["IgnitePlayerWarningTriggerDesc"],
			order = 19,
			func = function()
				BigWigsMageTools:Sync(syncName.ignitePlayerWarningSpace .. BigWigsMageTools.playerName)
			end,
		},
		ignitepyrotrigger = {
			type = "execute",
			name = L["IgnitePyroRequestTrigger"],
			desc = L["IgnitePyroRequestTriggerDesc"],
			order = 21,
			func = function()
				BigWigsMageTools:Sync(syncName.ignitePyroRequestSpace .. BigWigsMageTools.playerName)
			end,
		},
	}
}

BigWigsMageTools.revision = 30066
BigWigsMageTools.external = true

BigWigsMageTools.active = false
BigWigsMageTools.frames = {}

BigWigsMageTools.target = nil
BigWigsMageTools.playerName = nil
BigWigsMageTools.scorchTimers = {}
BigWigsMageTools.scorchStacks = {}
BigWigsMageTools.igniteTimers = {}
BigWigsMageTools.igniteStacks = {}
BigWigsMageTools.igniteOwners = {}
BigWigsMageTools.igniteHasScorch = {}
BigWigsMageTools.igniteDamage = {}
BigWigsMageTools.previousThreat = {}
BigWigsMageTools.previousThreatPercent = {}

-----------------------------------------------------------------------
--      Initialization
-----------------------------------------------------------------------

function BigWigsMageTools:CheckTalents()
	if isMage then
		self.hasScorchTalent = false
		self.hasIgniteTalent = false

		local nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2, 3);
		if nameTalent == "Ignite" and currRank > 0 then
			self.hasIgniteTalent = true
		end

		nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2, 10);
		if nameTalent == "Improved Scorch" and currRank > 0 then
			self.hasScorchTalent = true
		end

		if self.hasScorchTalent or self.hasIgniteTalent then
			if not self.active then
				DEFAULT_CHAT_FRAME:AddMessage("Enabling Magetools due having scorch/ignite talent(s)")
				self:Activate()
			end
		else
			if self.active then
				DEFAULT_CHAT_FRAME:AddMessage("Disabling Magetools due to not having scorch/ignite talent(s)")
				self:Deactivate()
			end
		end
	end
end

function BigWigsMageTools:CheckTalentEvent()
	self:ScheduleEvent("checktalents", self.CheckTalents, 1, self)
end

function BigWigsMageTools:OnEnable()
	self:ScheduleEvent("checktalents", self.CheckTalents, 1, self)

	if not self:IsEventRegistered("CHARACTER_POINTS_CHANGED") then
		self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckTalentEvent")
	end

	if not self:IsEventRegistered("LEARNED_SPELL_IN_TAB") then
		self:RegisterEvent("LEARNED_SPELL_IN_TAB", "CheckTalentEvent")
	end
end

function BigWigsMageTools:OnDisable()
	self:Deactivate()
end

function BigWigsMageTools:Activate()
	if not self.active then
		self.playerName = UnitName("player")
		if not self.db.profile.texture then
			self.db.profile.texture = "BantoBar"
		end
		self:SetupFrames()
		self:RegisterEvent("BigWigs_RecvSync")
		-- start listening to threat events
		BigWigsThreat:StartListening()
		self:RegisterEvent("BigWigs_ThreatUpdate", "ThreatUpdate")

		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

		self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "AuraFadeEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "TrinketEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "TrinketEvents")

		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", "PlayerDamageEvents")

		if not self:IsEventRegistered("CHARACTER_POINTS_CHANGED") then
			self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckTalentEvent")
		end

		if not self:IsEventRegistered("LEARNED_SPELL_IN_TAB") then
			self:RegisterEvent("LEARNED_SPELL_IN_TAB", "CheckTalentEvent")
		end

		if not self:IsEventRegistered("Surface_Registered") then
			self:RegisterEvent("Surface_Registered", function()
				self.consoleOptions.args[L["Texture"]].validate = surface:List()
			end)
		end

		self.target = UnitName("target")
		self:ThrottleSync(warningSyncSpeed, syncName.ignitePlayerWarning)
		self:ThrottleSync(warningSyncSpeed, syncName.ignitePyroRequest)
		self:ThrottleSync(1, syncName.eyeOfDimStart)
		self:ThrottleSync(1, syncName.eyeOfDimFade)
		self:ThrottleSync(1, syncName.fetishStart)
		self:ThrottleSync(1, syncName.fetishFade)

		self.active = true
	end
end

function BigWigsMageTools:Deactivate()
	self:HideAnchors()
	self:UnregisterAllEvents()
	self:CancelAllScheduledEvents()

	self.active = false

	-- still listen to check talents if a mage
	if isMage then
		self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckTalentEvent")
		self:RegisterEvent("LEARNED_SPELL_IN_TAB", "CheckTalentEvent")
	end
end

-----------------------------------------------------------------------
--      Event Handlers
-----------------------------------------------------------------------
function BigWigsMageTools:PlayerDamageEvents(msg)
	local eventHandled, crit, _ = self:ScorchEvent(msg)
	if not eventHandled or crit then
		self:IgniteEvent(msg)
	end
end

function BigWigsMageTools:Debug(msg)
	if self.db.profile.debug then
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end

function BigWigsMageTools:ScorchEvent(msg)
	if not self.db.profile.scorchenable then
		return
	end

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["scorch_afflict_test"])
	if not afflictedTarget then
		-- check for gains messages (shouldn't happen but just to be safe)
		_, _, afflictedTarget, stackInfo = string.find(msg, L["scorch_gains_test"])
	end

	if afflictedTarget then
		self:Debug(msg)
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			self.scorchStacks[afflictedTarget] = tonumber(stacks)
		else
			self.scorchStacks[afflictedTarget] = 1
		end

		self.scorchTimers[afflictedTarget] = GetTime()
		self:Scorch(afflictedTarget)

		return true, false, afflictedTarget  -- handled, crit, target
	end

	-- otherwise check for scorch hits
	local _, _, hitType, scorchTarget = string.find(msg, L["scorch_test"])
	-- only need to update bars if at 5 stacks, otherwise afflicted by message will handle it
	if scorchTarget then
		self:Debug(msg)
		if not self.scorchStacks[scorchTarget] then
			-- may have missed afflicted msg, resync stacks
			self:ResyncStacks()
		end

		-- update scorch timer after a half second to give time to check if fire vulnerability was resisted
		self:ScheduleEvent(scorchTimerUpdateEvent .. scorchTarget, self.UpdateScorchTimer, 0.2, self, scorchTarget, GetTime())

		local igniteStacks = self.igniteStacks[scorchTarget] or 1

		--check if scorch crit got into the ignite
		if hitType == "crit" and igniteStacks < 5 then
			self.igniteHasScorch[scorchTarget] = true
		end

		return true, hitType == "crit", scorchTarget  -- handled, crit, target
	end

	-- otherwise check for scorch resists
	local _, _, caster, resistTarget = string.find(msg, L["scorch_resist_test"])
	if not resistTarget then
		_, _, caster, resistTarget = string.find(msg, L["fire_vuln_resist_test"])
	end
	if resistTarget then
		self:Debug(msg)
		-- cancel timer update
		if self:IsEventScheduled(scorchTimerUpdateEvent .. resistTarget) then
			self:CancelScheduledEvent(scorchTimerUpdateEvent .. resistTarget)
		end
		self:Message(resistTarget .. " resisted " .. caster .. " scorch", "Attention", false)
		if self.db.profile.scorchresistsound then
			self:Sound("ScorchResist")
		end
		return true, false, resistTarget  -- handled, crit, target
	end

	return false, false, nil
end

function BigWigsMageTools:UpdateScorchTimer(target, time)
	self.scorchTimers[target] = time
	self:Scorch(target)
end

function BigWigsMageTools:IsMageFireSpell(spellName)
	return spellName == "Fireball" or
			spellName == "Pyroblast" or
			spellName == "Scorch" or
			spellName == "Fire Blast" or
			spellName == "Flamestrike" or
			spellName == "Blast Wave"

end

function BigWigsMageTools:UpdateIgniteOwner(playername, target)
	local playerName = ""
	-- playername can be "your" or "name 's"
	if string.lower(playername) == "your" then
		playerName = self.playerName        -- add ignite owner if it's not already set
	else
		--	strip the 's and the space that is currently inserted after the player name
		playerName = string.gsub(playername, "(%s?)'s", "")
	end
	BigWigsThreat:EnableEventsForPlayerName(playerName)
	self.igniteOwners[target] = playerName
end

function BigWigsMageTools:IgniteEvent(msg)
	if not self.db.profile.igniteenable then
		return
	end

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["ignite_afflict_test"])
	if not afflictedTarget then
		-- check for gains messages (seems to happen for ignite)
		_, _, afflictedTarget, stackInfo = string.find(msg, L["ignite_gains_test"])
	end

	if afflictedTarget then
		self:Debug(msg)
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			self.igniteStacks[afflictedTarget] = tonumber(stacks)
		else
			self.igniteStacks[afflictedTarget] = 1
		end
		self.igniteTimers[afflictedTarget] = GetTime()
		self:Ignite(afflictedTarget)
		return true, false, afflictedTarget  -- handled, crit, target
	else
		-- check for ignite crits
		local _, _, playerName, spellName, critTarget = string.find(msg, L["self_ignite_crit_test"])
		if not critTarget then
			_, _, playerName, spellName, critTarget = string.find(msg, L["other_ignite_crit_test"])
		end
		if critTarget and self:IsMageFireSpell(spellName) then
			self:Debug(msg)
			if not self.igniteStacks[critTarget] then
				-- may have missed msg, resync stacks
				self:ResyncStacks()
			end
			-- if no owner is set, set it.  Ignite tick will correct it if wrong
			if not self.igniteOwners[critTarget] then
				self:UpdateIgniteOwner(playerName, critTarget)
			end

			self.igniteTimers[critTarget] = GetTime()
			self:Ignite(critTarget)
			return true, true, critTarget  -- handled, crit, target
		end
	end

	-- check for ignite tick damage
	local _, _, igniteTickTarget, igniteDmg, igniteOwner = string.find(msg, L["ignite_dmg"])
	if igniteTickTarget then
		self:Debug(msg)
		self.igniteDamage[igniteTickTarget] = tonumber(igniteDmg)
		if igniteOwner then
			self:UpdateIgniteOwner(igniteOwner, igniteTickTarget)
		end
		self:ResyncStacks()
		self:Ignite(igniteTickTarget)
		return true, false, igniteTickTarget  -- handled, crit, target
	end
end

-- reset data if your target dies
function BigWigsMageTools:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	self:Debug(msg)
	local _, _, deadTarget, _ = string.find(msg, L["slain_test"])
	if not deadTarget then
		_, _, deadTarget = string.find(msg, L["self_slain_test"])
	end
	if not deadTarget then
		_, _, deadTarget = string.find(msg, L["death_test"])
	end
	if deadTarget then
		-- reset everything for that target
		self.scorchTimers[deadTarget] = nil
		self.scorchStacks[deadTarget] = nil
		self:StopBar(scorchBarPrefix .. deadTarget)

		self.igniteHasScorch[deadTarget] = nil
		self.igniteTimers[deadTarget] = nil
		self.igniteStacks[deadTarget] = nil
		self.igniteOwners[deadTarget] = nil
		self.igniteDamage[deadTarget] = nil
		self:StopBar(igniteBarPrefix .. deadTarget)
		self:StopBar(threatBarPrefix .. deadTarget)
	end
end

function BigWigsMageTools:AuraFadeEvents(msg)
	local _, _, scorchTarget = string.find(msg, L["scorch_fades_test"])
	if scorchTarget then
		self:Debug(msg)
		self.scorchTimers[scorchTarget] = nil
		self.scorchStacks[scorchTarget] = nil
		self:StopBar(scorchBarPrefix .. scorchTarget)
		return
	end

	local _, _, igniteTarget = string.find(msg, L["ignite_fades_test"])
	if igniteTarget then
		self:Debug(msg)
		self.igniteHasScorch[igniteTarget] = nil
		self.igniteTimers[igniteTarget] = nil
		self.igniteStacks[igniteTarget] = nil
		self.igniteOwners[igniteTarget] = nil
		self.igniteDamage[igniteTarget] = nil
		self:StopBar(igniteBarPrefix .. igniteTarget)
		self:StopBar(threatBarPrefix .. igniteTarget)
	end
end

function BigWigsMageTools:TrinketEvents(msg)
	if string.find(msg, L["arcane_shroud_test"]) then
		self:Sync(syncName.fetishStart .. " " .. self.playerName)
	elseif string.find(msg, L["arcane_shroud_fades_test"]) then
		self:Sync(syncName.fetishFade .. " " .. self.playerName)
	elseif string.find(msg, L["eye_of_diminution_test"]) then
		self:Sync(syncName.eyeOfDimStart .. " " .. self.playerName)
	elseif string.find(msg, L["eye_of_diminution_fades_test"]) then
		self:Sync(syncName.eyeOfDimFade .. " " .. self.playerName)
	end
end

function BigWigsMageTools:PLAYER_REGEN_ENABLED()
	self:StopAllBars()

	self.target = nil
	self.scorchTimers = {}
	self.scorchStacks = {}
	self.igniteHasScorch = {}
	self.igniteTimers = {}
	self.igniteStacks = {}
	self.igniteOwners = {}
	self.igniteDamage = {}

	BigWigsThreat:DisablePlayerEvents()

	--	cancel events
	if self:IsEventScheduled(targetChangeEvent) then
		self:CancelScheduledEvent(targetChangeEvent)
	end
	if self:IsEventScheduled(warningSoundEvent) then
		self:CancelScheduledEvent(warningSoundEvent)
	end
	if self:IsEventScheduled(warningSignEvent) then
		self:CancelScheduledEvent(warningSignEvent)
	end
end

function BigWigsMageTools:ResyncStacks()
	local target = UnitName("target")
	self.target = target

	if target then
		local foundScorch = false
		local foundIgnite = false
		-- check debuffs
		for i = 1, 16 do
			local texture, stacks = UnitDebuff("target", i)
			if (texture and stacks) then
				if texture == scorchIcon then
					self.scorchStacks[target] = tonumber(stacks)
					foundScorch = true
				elseif texture == igniteIcon then
					self.igniteStacks[target] = tonumber(stacks)
					foundIgnite = true
				end
			else
				-- once we start getting nil we can break
				break
			end
		end
		-- if we didn't find it check buffs as well
		if not foundScorch or not foundIgnite then
			for i = 1, 32 do
				local texture, stacks = UnitBuff("target", i)
				if (texture and stacks) then
					if texture == scorchIcon then
						self.scorchStacks[target] = tonumber(stacks)
					elseif texture == igniteIcon then
						self.igniteStacks[target] = tonumber(stacks)
					end
				else
					-- once we start getting nil we can break
					break
				end
			end
		end
	end
end

function BigWigsMageTools:RecheckTargetChange()
	local target = UnitName("target")
	self.target = target

	-- if this target has been scorched, query current stacks
	if target and self.scorchTimers[target] or self.igniteStacks[target] then
		-- resync stacks
		self:ResyncStacks()

		local timeleft = self:GetTargetScorchTimeLeft(target)
		if self.scorchStacks[target] and timeleft then
			self:StartScorchBar(target, timeleft, self.scorchStacks[target])
		end

		timeleft = self:GetTargetIgniteTimeLeft(target)
		if self.igniteStacks[target] and timeleft then
			self:StartIgniteBar(target, self:GetTargetIgniteText(target), timeleft, self.igniteStacks[target], self.igniteHasScorch[target])
		end
	else
		self:StopAllBars()
	end
end

-- reset data if you change your target
function BigWigsMageTools:PLAYER_TARGET_CHANGED(msg)
	if not self:IsEventScheduled(targetChangeEvent) then
		self:ScheduleEvent(targetChangeEvent, self.RecheckTargetChange, 0.1, self)
	end
end

function BigWigsMageTools:Scorch(target)
	if not self.target then
		self.target = UnitName("target")
	end

	if target == self.target then
		local timeleft = self:GetTargetScorchTimeLeft(target)
		self:StartScorchBar(target, timeleft, self.scorchStacks[target])
		self:ScheduleEvent("ScorchYellowUpdate", self.ScorchYellowUpdate, 20, self, target)
		self:ScheduleEvent("ScorchRedUpdate", self.ScorchRedUpdate, 25, self, target)

		if self.db.profile.scorchsound then
			self:ScheduleEvent(warningSoundEvent, self.ScorchSoundWarning, 25, self, target)
		end
		if self.db.profile.scorchwarningsign then
			self:ScheduleEvent(warningSignEvent, self.ScorchSignWarning, 25, self, target)
		end
	end
end

function BigWigsMageTools:Ignite(target)
	if not self.target then
		self.target = UnitName("target")
	end

	if target == self.target then
		local timeleft = self:GetTargetIgniteTimeLeft(target)
		self:StartIgniteBar(target, self:GetTargetIgniteText(target), timeleft, self.igniteStacks[target], self.igniteHasScorch[target])

		--	if there's an ignite owner and we have threat data, start a threat bar as well
		local hadThreatData = false
		if self.igniteOwners[target] then
			local owner = self.igniteOwners[target]
			local threatData = BigWigsThreat:GetPlayerInfo(owner)
			self:Debug("Owner threat data " .. tostring(owner) .. " "
					.. tostring(threatData['threat']) .. " " .. tostring(threatData['perc']))
			if threatData['perc'] then
				hadThreatData = true
				self:StartThreatBar(target, owner, threatData['perc'], threatData['threat'])
			end
		end
		if not hadThreatData then
			self:Debug("No threat data for target " .. tostring(target) .. " owner " .. tostring(self.igniteOwners[target]))
		end
	end
end

function BigWigsMageTools:ThreatUpdate(player, threat, perc, tank, melee)
	if not self.target then
		return
	end

	if self.igniteOwners[self.target] then
		local owner = self.igniteOwners[self.target]
		if player == owner and perc then
			self:Debug("Threat data update " .. tostring(player) .. " "
					.. tostring(threat) .. " " .. tostring(perc))
			self:StartThreatBar(self.target, owner, perc, threat)
		end
	end
end

function BigWigsMageTools:BigWigs_RecvSync(sync, arg1, arg2)
	if sync == syncName.ignitePlayerWarning then
		if self.active and self.db.profile.igniteplayerwarning then
			self:Bar(arg1 .. " says stop casting!!!", 5, "inv_misc_bone_orcskull_01", false, "Red")
			BigWigsSound:BigWigs_Sound("stopcasting")
		end
	elseif sync == syncName.ignitePyroRequest then
		if self.active and self.db.profile.ignitepyrorequest then
			self:Bar(arg1 .. " has requested pyro!!!", 3, "spell_fire_fireball02", false, "Red")
			BigWigsSound:BigWigs_Sound("Pyro")
		end
	elseif sync == syncName.eyeOfDimStart then
		if self.active and self.db.profile.threattrinketalerts then
			self:Bar(arg1 .. " used Eye of Dim", 20, "INV_Trinket_Naxxramas02", false, "Blue")
		end
	elseif sync == syncName.eyeOfDimFade then
		self:RemoveBar(arg1 .. " used Eye of Dim")
	elseif sync == syncName.fetishStart then
		if self.active and self.db.profile.threattrinketalerts then
			self:Bar(arg1 .. " used Fetish", 20, "INV_Misc_AhnQirajTrinket_03", false, "Blue")
		end
	elseif sync == syncName.fetishFade then
		self:RemoveBar(arg1 .. " used Fetish")
	end
end

function BigWigsMageTools:ScorchYellowUpdate(arg1)
	if arg1 == self.target then
		local id = scorchBarPrefix .. arg1
		candybar:SetCandyBarColor(id, "yellow", 1)
	end
end

function BigWigsMageTools:ScorchRedUpdate(arg1)
	if arg1 == self.target then
		local id = scorchBarPrefix .. arg1
		candybar:SetCandyBarColor(id, "red", 1)
	end
end

function BigWigsMageTools:ScorchSoundWarning(arg1)
	if arg1 == self.target then
		self:Sound("Scorch")
	end
end

function BigWigsMageTools:ScorchSignWarning(arg1)
	if arg1 == self.target then
		self:WarningSign("Spell_Fire_SoulBurn", 2, true, "Scorch")
	end
end

-----------------------------------------------------------------------
--      Util
-----------------------------------------------------------------------
function BigWigsMageTools:GetTargetScorchTimeLeft(target)
	if self.scorchTimers[target] then
		local timeleft = timer.scorch - (GetTime() - self.scorchTimers[target])
		if timeleft > 0 then
			return timeleft
		end
	end
	return 0
end

function BigWigsMageTools:GetTargetIgniteTimeLeft(target)
	if self.igniteTimers[target] then
		local timeleft = timer.ignite - (GetTime() - self.igniteTimers[target])
		if timeleft > 0 then
			return timeleft
		end
	end
	return 0
end

function BigWigsMageTools:GetTargetIgniteText(target)
	local igniteText = "Ignite"
	if self.igniteDamage[target] then
		igniteText = self.igniteDamage[target]
	end
	if self.igniteOwners[target] then
		igniteText = igniteText .. " - " .. self.igniteOwners[target]
	end
	return igniteText
end

function BigWigsMageTools:Test()
	self:StopAllBars()

	self:StartThreatBar("Ragnaros", "Pepopo", 55, 3500)
	self:StartIgniteBar("Ragnaros", "2222 Pepopo", timer.ignite, 5, true)
	self:StartScorchBar("Thaddius", timer.scorch, 5)

	--	 schedule cancel in 20 sec
	self:ScheduleEvent("TestStop", self.StopAllBars, 20, self)
end

------------------------------
--      Slash Handlers      --
------------------------------


------------------------------
--    Create the Frame     --
------------------------------

function BigWigsMageTools:SetupFrames()
	if self.frames.anchor then
		return
	end

	local f, t

	f, _, _ = GameFontNormal:GetFont()

	local frame = CreateFrame("Frame", "ScorchTimerBarAnchor", UIParent)

	frame.owner = self
	frame:Hide()

	frame:SetWidth(170)
	frame:SetHeight(75)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropBorderColor(.5, .5, .5)
	frame:SetBackdropColor(0, 0, 0)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetScript("OnDragStart", function()
		this:StartMoving()
	end)
	frame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
		this.owner:SavePosition()
	end)

	local cheader = frame:CreateFontString(nil, "OVERLAY")
	cheader:SetFont(f, 14)
	cheader:SetWidth(150)
	cheader:SetText(L["AnchorTitle"])
	cheader:SetTextColor(1, .8, 0)
	cheader:ClearAllPoints()
	cheader:SetPoint("TOP", frame, "TOP", 0, -10)

	frame.cheader = cheader

	local leftbutton = CreateFrame("Button", nil, frame)
	leftbutton.owner = self
	leftbutton:SetWidth(40)
	leftbutton:SetHeight(25)
	leftbutton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
	leftbutton:SetScript("OnClick", function()
		self:Test()
	end)

	t = leftbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", leftbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	leftbutton:SetNormalTexture(t)

	t = leftbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(leftbutton)
	leftbutton:SetPushedTexture(t)

	t = leftbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(leftbutton)
	t:SetBlendMode("ADD")
	leftbutton:SetHighlightTexture(t)
	leftbuttontext = leftbutton:CreateFontString(nil, "OVERLAY")
	leftbuttontext:SetFontObject(GameFontHighlight)
	leftbuttontext:SetText(L["Test"])
	leftbuttontext:SetAllPoints(leftbutton)

	frame.leftbutton = leftbutton

	local middlebutton = CreateFrame("Button", nil, frame)
	middlebutton.owner = self
	middlebutton:SetWidth(40)
	middlebutton:SetHeight(25)
	middlebutton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 65, 10)
	middlebutton:SetScript("OnClick", function()
		BigWigsOptions:OpenMenu(middlebutton)
	end)

	t = middlebutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", middlebutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	middlebutton:SetNormalTexture(t)

	t = middlebutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(middlebutton)
	middlebutton:SetPushedTexture(t)

	t = middlebutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(middlebutton)
	t:SetBlendMode("ADD")
	middlebutton:SetHighlightTexture(t)
	middlebuttontext = middlebutton:CreateFontString(nil, "OVERLAY")
	middlebuttontext:SetFontObject(GameFontHighlight)
	middlebuttontext:SetText("Edit")
	middlebuttontext:SetAllPoints(middlebutton)
	frame.middlebutton = middlebutton

	local rightbutton = CreateFrame("Button", nil, frame)
	rightbutton.owner = self
	rightbutton:SetWidth(40)
	rightbutton:SetHeight(25)
	rightbutton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 120, 10)
	rightbutton:SetScript("OnClick", function()
		BigWigsMageTools:HideAnchors()
	end)

	t = rightbutton:CreateTexture()
	t:SetWidth(50)
	t:SetHeight(32)
	t:SetPoint("CENTER", rightbutton, "CENTER")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	rightbutton:SetNormalTexture(t)

	t = rightbutton:CreateTexture(nil, "BACKGROUND")
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(rightbutton)
	rightbutton:SetPushedTexture(t)

	t = rightbutton:CreateTexture()
	t:SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	t:SetTexCoord(0, 0.625, 0, 0.6875)
	t:SetAllPoints(rightbutton)
	t:SetBlendMode("ADD")
	rightbutton:SetHighlightTexture(t)
	rightbuttontext = rightbutton:CreateFontString(nil, "OVERLAY")
	rightbuttontext:SetFontObject(GameFontHighlight)
	rightbuttontext:SetText(L["Close"])
	rightbuttontext:SetAllPoints(rightbutton)

	frame.rightbutton = rightbutton

	self.frames.anchor = frame

	local x = self.db.profile.posx
	local y = self.db.profile.posy
	if x and y then
		local s = self.frames.anchor:GetEffectiveScale()
		self.frames.anchor:ClearAllPoints()
		self.frames.anchor:SetPoint("TOP", UIParent, "TOP", 0, 0)--self.frames.anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
	else
		self:ResetAnchor("normal")
	end

	self.frames.anchor.candyBarGroupId = "MageToolGroup"
	candybar:RegisterCandyBarGroup(self.frames.anchor.candyBarGroupId, self.db.profile.barspacing, false)
	candybar:SetCandyBarGroupPoint(self.frames.anchor.candyBarGroupId, "BOTTOMLEFT", self.frames.anchor, "TOPLEFT", 0, 0)
	candybar:SetCandyBarGroupGrowth(self.frames.anchor.candyBarGroupId, true)
	self:RestorePosition()
end

function BigWigsMageTools:ResetAnchor(specific)
	if not specific or specific == "reset" or specific == "normal" then
		if not self.frames.anchor then
			self:SetupFrames()
		end
		self.frames.anchor:ClearAllPoints()
		self.frames.anchor:SetPoint("CENTER", UIParent, "CENTER")
		self.db.profile.posx = nil
		self.db.profile.posy = nil
	end
end

function BigWigsMageTools:SavePosition()
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local s = self.frames.anchor:GetEffectiveScale()
	self.db.profile.posx = self.frames.anchor:GetLeft() * s
	self.db.profile.posy = self.frames.anchor:GetTop() * s

end

function BigWigsMageTools:RestorePosition()
	local x = self.db.profile.posx
	local y = self.db.profile.posy

	if not x or not y then
		return
	end

	local f = self.frames.anchor
	local s = f:GetEffectiveScale()

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
end

function BigWigsMageTools:Disable()
	self:StopAllBars()
end

function BigWigsMageTools:ShowAnchors()
	if not self.frames.anchor then
		self:SetupFrames()
	end
	self.frames.anchor:Show()
end

function BigWigsMageTools:HideAnchors()
	if self.frames then
		if not self.frames.anchor then
			return
		end
		self.frames.anchor:Hide()
	end
end

local barCache = {
	-- [i] = {id}
}

function BigWigsMageTools:StartScorchBar(target, timeleft, stacks)
	if not target or not timeleft or not stacks or not self.db.profile.scorchenable then
		return
	end
	if self.db.profile.debug then
		self:Debug("scorch bar " .. tostring(target) .. " " .. tostring(timeleft) .. " " .. tostring(stacks))
	end
	local id = scorchBarPrefix .. target
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local maxTime = timer.scorch
	if timeleft > maxTime then
		maxTime = timeleft
	end

	local groupId = self.frames.anchor.candyBarGroupId
	-- check if bar already exists
	if not candybar:IsRegistered(id) then
		candybar:RegisterCandyBar(id, maxTime, target, scorchIcon)
		candybar:RegisterCandyBarWithGroup(id, groupId, 1)
	else
		candybar:SetText(id, target)
	end

	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))
	candybar:SetIconText(id, stacks or "")

	if type(self.db.profile.scorchwidth) == "number" then
		candybar:SetCandyBarWidth(id, self.db.profile.scorchwidth)
	end
	if type(self.db.profile.scorchheight) == "number" then
		candybar:SetCandyBarHeight(id, self.db.profile.scorchheight)
	end

	candybar:SetCandyBarFade(id, .5)
	if timeleft <= 5 then
		candybar:SetCandyBarColor(id, "red", 1)
	elseif timeleft <= 10 then
		candybar:SetCandyBarColor(id, "yellow", 1)
	else
		candybar:SetCandyBarColor(id, "green", 1)
	end

	-- check if running
	if not candybar:IsRunning(id) then
		candybar:StartCandyBar(id, true)
	end
	candybar:SetTimeLeft(id, timeleft)
	tinsert(barCache, id)
end

function BigWigsMageTools:StartIgniteBar(target, text, timeleft, stacks, igniteHasScorch)
	if not text or not timeleft or not stacks or not self.db.profile.igniteenable then
		return
	end

	if self.db.profile.debug then
		self:Debug("ignite bar " .. tostring(target) .. " " .. tostring(text) .. " " .. tostring(timeleft) .. " " .. tostring(stacks))
	end

	local id = igniteBarPrefix .. target
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local maxTime = timer.ignite
	if timeleft > maxTime then
		maxTime = timeleft
	end

	local groupId = self.frames.anchor.candyBarGroupId
	-- check if bar already exists
	if not candybar:IsRegistered(id) then
		candybar:RegisterCandyBar(id, maxTime, text, igniteIcon)
		candybar:RegisterCandyBarWithGroup(id, groupId, 2)
	else
		candybar:SetText(id, text)
	end

	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))
	candybar:SetIconText(id, stacks or "")

	if type(self.db.profile.ignitewidth) == "number" then
		local width = self.db.profile.ignitewidth

		-- check for timer mode
		if not self.db.profile.ignitetimermode then
			local minwidth = self.db.profile.ignitewidth / 2
			local stackwidth = minwidth / 5
			if stacks and stacks >= 1 then
				width = minwidth + stackwidth * stacks -- don't let bar get too small
			end
		end
		candybar:SetCandyBarWidth(id, width)
	end

	if type(self.db.profile.igniteheight) == "number" then
		candybar:SetCandyBarHeight(id, self.db.profile.igniteheight)
	end

	if igniteHasScorch then
		candybar:SetCandyBarColor(id, "yellow", 1)
	else
		candybar:SetCandyBarColor(id, "orange", 1 / 5 * stacks)
	end

	candybar:SetCandyBarFade(id, .5)

	if not candybar:IsRunning(id) then
		candybar:StartCandyBar(id, true)
	end
	candybar:SetTimeLeft(id, timeleft)
	if not self.db.profile.ignitetimermode then
		candybar:Pause(id, true)
	end

	tinsert(barCache, id)
end

function BigWigsMageTools:CalcIgniteTicksTillAggro(target, percent, threat)
	if not target or not percent or not threat or not self.igniteDamage[target] then
		return nil
	end

	local decimalPercent = percent / 100.0
	local aggroThreat = threat / decimalPercent - threat
	local threatPerTick = self.igniteDamage[target] * 0.7 -- burning soul reduces threat by 30%
	return math.floor(aggroThreat / threatPerTick)
end

function BigWigsMageTools:StartThreatBar(target, owner, percent, threat)
	if not owner or not self.db.profile.ignitethreatenable then
		return
	end
	if self.db.profile.debug then
		self:Debug("threat bar " .. tostring(target) .. " " .. tostring(owner) .. " " .. tostring(percent))
	end

	local id = threatBarPrefix .. target
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local text = owner .. " " .. string.format("%2.f", percent) .. "%"
	local groupId = self.frames.anchor.candyBarGroupId
	-- check if bar already exists
	if not candybar:IsRegistered(id) then
		candybar:RegisterCandyBar(id, 1, text, threatIcon)
		candybar:RegisterCandyBarWithGroup(id, groupId, 3)
	else
		candybar:SetText(id, text)
	end

	local ticksTillAggro = self:CalcIgniteTicksTillAggro(target, percent, threat)
	-- calculate number of ignite ticks to 100% threat
	if ticksTillAggro then
		if ticksTillAggro < 10 then
			candybar:SetIconText(id, ticksTillAggro)
			local warning = ticksForWarning
			if owner == self.playerName then
				warning = ticksForSelfWarning
			end

			if ticksTillAggro <= warning and self.db.profile.igniteautowarning then
				self:WarningSign("Spell_Fire_Incinerate", 2, true, tostring(ticksTillAggro) .. " ticks till aggro")
			end
		else
			candybar:SetIconText(id, ">10")
		end
	else
		candybar:SetIconText(id, "")
	end

	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))

	if type(self.db.profile.ignitethreatwidth) == "number" then
		local minwidth = self.db.profile.ignitethreatwidth / 2
		local width = minwidth + minwidth * percent / 100
		candybar:SetCandyBarWidth(id, width)
	end

	if type(self.db.profile.ignitethreatheight) == "number" then
		candybar:SetCandyBarHeight(id, self.db.profile.ignitethreatheight)
	end

	candybar:SetCandyBarFade(id, .5)
	if percent >= self.db.profile.ignitethreatthreshold then
		candybar:SetCandyBarColor(id, "red", 1)
	elseif percent >= 50 then
		candybar:SetCandyBarColor(id, "yellow", 0.75)
	else
		candybar:SetCandyBarColor(id, "green", 0.5)
	end

	if not candybar:IsRunning(id) then
		candybar:StartCandyBar(id, true)
	end
	candybar:Pause(id, true)

	tinsert(barCache, id)
end

function BigWigsMageTools:StopBar(id)
	if not id and type(id) ~= "string" then
		return
	end
	candybar:UnregisterCandyBar(id)
end

function BigWigsMageTools:StopAllBars()
	for i = 1, table.getn(barCache) do
		BigWigsMageTools:StopBar(barCache[i])
	end
	barCache = {}
end

function BigWigsMageTools:Test1()
	-- /run local m=BigWigs:GetModule("MageTools");m:Test1()
	local function scorch1()
		self:PlayerDamageEvents("Pepopo 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Fire Vulnerability")
		self:PlayerDamageEvents("Tiergwaedd 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Ignite.")
	end
	local function scorch2()
		self:PlayerDamageEvents("Tiergwaedd 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Fire Vulnerability (2)")
		self:PlayerDamageEvents("Scarletrage 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Ignite (2).")
	end
	local function scorch3()
		self:PlayerDamageEvents("Pepopo 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Fire Vulnerability (3)")
		self:PlayerDamageEvents("Scarletrage 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Ignite (3).")

	end
	local function scorch4()
		self:PlayerDamageEvents("Pepopo 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Fire Vulnerability (4)")
		self:PlayerDamageEvents("Pepopo 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Ignite (4).")

	end
	local function scorch5()
		self:PlayerDamageEvents("Scarletrage 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Fire Vulnerability (5)")
		self:PlayerDamageEvents("Pepopo 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")
		self:PlayerDamageEvents("Heroic Training Dummy is afflicted by Ignite (5).")

	end
	local function scorch()
		self:PlayerDamageEvents("Pepopo 's Scorch hits Heroic Training Dummy for 743 Fire damage.")
		self:PlayerDamageEvents("Pepopo 's Fireball crits Heroic Training Dummy for 1743 Fire damage.")

	end

	-- sweep after 5s
	-- loop 10 times
	for i = 1, 22 do
		for j = 1, 22 do
			self:ScheduleEvent(self:ToString() .. "1" .. i .. "it" .. j, scorch1, 1, self)
			self:ScheduleEvent(self:ToString() .. "2" .. i .. "it" .. j, scorch2, 2, self)
			self:ScheduleEvent(self:ToString() .. "3" .. i .. "it" .. j, scorch3, 3, self)
			self:ScheduleEvent(self:ToString() .. "4" .. i .. "it" .. j, scorch4, 4, self)
			self:ScheduleEvent(self:ToString() .. "5" .. i .. "it" .. j, scorch5, 5, self)
			self:ScheduleEvent(self:ToString() .. "6" .. i .. "it" .. j, scorch, 6, self)
			self:ScheduleEvent(self:ToString() .. "7" .. i .. "it" .. j, scorch, 7, self)
			self:ScheduleEvent(self:ToString() .. "8" .. i .. "it" .. j, scorch, 8, self)
			self:ScheduleEvent(self:ToString() .. "10" .. i .. "it" .. j, scorch, 8, self)
			self:ScheduleEvent(self:ToString() .. "12" .. i .. "it" .. j, scorch, 8, self)
			self:ScheduleEvent(self:ToString() .. "15" .. i .. "it" .. j, scorch, 8, self)
			self:ScheduleEvent(self:ToString() .. "17" .. i .. "it" .. j, scorch, 8, self)
			self:ScheduleEvent(self:ToString() .. "19" .. i .. "it" .. j, scorch, 8, self)
		end
	end

end

function BigWigsMageTools:Test2()
	events = {
		"Relkag 's Scorch crits Heroic Training Dummy for 888 Fire damage.",
		"Relkag gains 45 Mana from Relkag 's Master of Elements.",
		"Heroic Training Dummy is afflicted by Ignite (1).",
		"Heroic Training Dummy is afflicted by Fire Vulnerability (1).",
		"Pepopo 's Scorch hits Heroic Training Dummy for 640 Fire damage.",
		"Pepopo 's Fire Vulnerability was resisted by Heroic Training Dummy.",
		"Heroic Training Dummy suffers 187 Fire damage from Relkag 's Ignite.",
		"Pepopo 's Scorch hits Heroic Training Dummy for 667 Fire damage.",
		"Heroic Training Dummy is afflicted by Fire Vulnerability (2).",
		"Rootankman gains 1 Rage from Rootankman 's Bloodrage.",
		"Moeney 's Scorch hits Heroic Training Dummy for 468 Fire damage.",
		"Relkag 's Scorch crits Heroic Training Dummy for 1003 Fire damage.",
		"Heroic Training Dummy is afflicted by Fire Vulnerability (4).",
		"Relkag gains 45 Mana from Relkag 's Master of Elements.",
		"Heroic Training Dummy is afflicted by Ignite (2).",
		"Heroic Training Dummy is afflicted by Fire Vulnerability (5).",
		"Heroic Training Dummy suffers 433 Fire damage from Relkag 's Ignite.",
		"Pepopo 's Scorch was resisted by Heroic Training Dummy.",
		"Moeney 's Scorch crits Heroic Training Dummy for 706 Fire damage.",
		"Heroic Training Dummy is afflicted by Shadow Vulnerability (1).",
		"Heroic Training Dummy is afflicted by Ignite (3).",
		"Moeney begins to cast Scorch.",
		"Heroic Training Dummy suffers 595 Fire damage from Relkag 's Ignite.",
		"Moeney 's Scorch crits Heroic Training Dummy for 750 Fire damage.",
		"Heroic Training Dummy is afflicted by Ignite (4).",
		"Pepopo 's Fireball hits Heroic Training Dummy for 886 Fire damage. (886 resisted)",
		"Luckystrikes gains 1 Rage from Luckystrikes 's Bloodrage.",
		"Heroic Training Dummy is afflicted by Fireball (1).",
		"Relkag 's Fireball crits Heroic Training Dummy for 2680 Fire damage.",
		"Relkag gains 123 Mana from Relkag 's Master of Elements.",
		"Luckystrikes gains 1 Rage from Luckystrikes 's Bloodrage.",
		"Heroic Training Dummy gains Fireball (1).",
		"Heroic Training Dummy is afflicted by Ignite (5).",
		"Heroic Training Dummy suffers 1384 Fire damage from Relkag 's Ignite.",
		"Dewbie 's Bloodthirst hits Heroic Training Dummy for 855.",
		"Dewbie gains Bloodthirst (1).",
		"Bubbelhearth 's Flash of Light heals Luckystrikes for 854.",
		"Heroic Training Dummy suffers 21 Fire damage from Pepopo 's Fireball.",
		"Pepopo 's Fireball hits Heroic Training Dummy for 1705 Fire damage.",
		"Heroic Training Dummy suffers 23 Fire damage from Relkag 's Fireball.",
		"Relkag 's Fireball crits Heroic Training Dummy for 1920 Fire damage. (640 resisted)",
		"Heroic Training Dummy suffers 1384 Fire damage from Relkag 's Ignite.",
		"Heroic Training Dummy suffers 1384 Fire damage from Relkag 's Ignite.",
		"Heroic Training Dummy is afflicted by Fireball (1).",
		"Relkag 's Fireball crits Heroic Training Dummy for 2434 Fire damage.",
		"Pepopo 's Fireball crits Heroic Training Dummy for 2428 Fire damage.",
		"Heroic Training Dummy suffers 1384 Fire damage from Relkag 's Ignite.",
		"Relkag 's Fireball crits Heroic Training Dummy for 2454 Fire damage.",
	}
	local function testEvent(msg)
		BigWigsMageTools:PlayerDamageEvents(msg)
	end
	-- loop through events
	for i, v in ipairs(events) do
		self:ScheduleEvent("logtest" .. i, testEvent, 0.4 * i, v)
	end
end
