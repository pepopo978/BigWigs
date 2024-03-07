--[[
This is a plugin to help mages track their fire vulnerability debuff.
--]]

assert(BigWigs, "BigWigs not found!")

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
	ignite = 4,
	igniteFirstTickDelay = 2.0,
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

local syncSpeed = 0.2

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
		["EnableDesc"] = "Enable Mage tools",

		["AnchorTitle"] = "Mage tools anchor frame",
		["ShowAnchor"] = "Show anchor frame",
		["ShowAnchorDesc"] = "Show the anchor frame for controlling where the mage tools appear.",

		["Texture"] = "Texture",
		["TextureDesc"] = "Set the texture for the bars.",

		["BarSpacing"] = "Bar Spacing",
		["BarSpacingDesc"] = "Vertical space between bars.",

		["ResetPosition"] = "Reset Anchor Position",
		["ResetPositionDesc"] = "Reset the anchor position, moving it to the center of your screen.",

		["Test"] = "Test",
		["Close"] = "Close",

		-- scorch settings
		["ScorchOptions"] = "Scorch Options",
		["ScorchEnable"] = "Enable",
		["ScorchEnableTimer"] = "Enable scorch timer",
		["ScorchEnableTimerDesc"] = "Displays a timer for Scorch Fire Vulnerability.",
		["ScorchWarningSound"] = "Warning Sound",
		["ScorchWarningSoundDesc"] = "Says 'Scorch' when there are 5 seconds left before it falls off",
		["ScorchWarningSign"] = "Warning Sign",
		["ScorchWarningSignDesc"] = "Show a warning sign when there are 5 seconds left before it falls off",
		["ScorchBarWidth"] = "Scorch bar width",
		["ScorchBarWidthDesc"] = "Sets the width of the scorch bar",
		["ScorchBarHeight"] = "Scorch bar height",
		["ScorchBarHeightDesc"] = "Sets the height of the scorch bar",

		-- ignite settings
		["IgniteOptions"] = "Ignite Options",
		["IgniteEnable"] = "Enable",
		["IgniteTimerMode"] = "Ignite timer mode",
		["IgniteTimerModeDesc"] = "In timer mode bar size will indicate remaining time in ignite window.  Otherwise bar will grow with ignite stacks.",
		["IgniteThreatThreshold"] = "Ignite threat threshold",
		["IgniteThreatThresholdDesc"] = "Percentage of top threat at which to warn about ignite",
		["IgniteBarWidth"] = "Ignite bar width",
		["IgniteBarWidthDesc"] = "Sets the width of the ignite bar",
		["IgniteBarHeight"] = "Ignite bar height",
		["IgniteBarHeightDesc"] = "Sets the height of the ignite bar",

		["IgnitePlayerWarning"] = "Ignite player warnings",
		["IgnitePlayerWarningDesc"] = "Whether to display + play sounds for manual player warnings",
		["IgnitePlayerWarningTrigger"] = "Trigger ignite warning",
		["IgnitePlayerWarningTriggerDesc"] = "/bw extra magetools ignite ignitewarningtrigger",

		["IgnitePyroRequest"] = "Pyro sync requests",
		["IgnitePyroRequestDesc"] = "Whether to display + play sounds for manual player pryo requests",
		["IgnitePyroRequestTrigger"] = "Trigger pyro request",
		["IgnitePyroRequestTriggerDesc"] = "/bw extra magetools ignite ignitepyrotrigger",

		scorch_afflict_test = "^(.+) is afflicted by Fire Vulnerability(.*)", -- for stacks 2-5 will be "Fire Vulnerability (2)".  Use this to detect resists
		scorch_test = ".+ Scorch (.+)s (.+) for",
		scorch_fades_test = "Fire Vulnerability fades from (.+).",

		ignite_afflict_test = "^(.+) is afflicted by Ignite(.*)", -- for stacks 2-5 will be "Ignite (2)".  Use this to detect resists
		ignite_crit_test = "^.+ (.+) crits (.+) for .+ Fire damage",
		ignite_dmg = "^(.+) suffers (.+) Fire damage from (.+) Ignite",
		ignite_fades_test = "Ignite fades from (.+).",
	}
end)

-----------------------------------------------------------------------
--      Module Declaration
-----------------------------------------------------------------------

local _, englishClass = UnitClass("player");
local isMage = false;
if englishClass == "MAGE" then
	isMage = true
end
BigWigsMageTools = BigWigs:NewModule(name)
BigWigsMageTools.defaultDB = {
	enable = isMage and true or false,
	barspacing = 5,
	texture = "BantoBar",
	posx = nil,
	posy = nil,

	scorchenable = true,
	scorchtimer = true,
	scorchsound = false,
	scorchwarningsign = false,
	scorchwidth = 200,
	scorchheight = 15,

	igniteenable = true,
	ignitetimermode = true,
	ignitethreatthreshold = 85,
	igniteplayerwarning = true,
	ignitepyrorequest = true,
	ignitewidth = 200,
	igniteheight = 20,

	threatwidth = 200,
	threatheight = 20,
}

BigWigsMageTools.consoleCmd = L["MageToolsCmd"]
BigWigsMageTools.consoleOptions = {
	type = "group",
	name = L["MageTools"],
	desc = L["MageToolsDesc"],
	args = {
		enable = {
			type = "toggle",
			name = L["Enable"],
			desc = L["EnableDesc"],
			order = 1,
			get = function()
				return BigWigsMageTools.db.profile.enable
			end,
			set = function(v)
				BigWigsMageTools.db.profile.enable = v
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
				candybar:UpdateBarSpacing(BigWigsMageTools.frames.anchor.candyBarGroupId,
						BigWigsMageTools.db.profile.barspacing)
			end,
		},
		scorch = {
			type = "group",
			name = L["ScorchOptions"],
			desc = L["ScorchOptions"],
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
					max = 30,
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
		ignite = {
			type = "group",
			name = L["IgniteOptions"],
			desc = L["IgniteOptions"],
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
					order = 2,
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
					order = 3,
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
					order = 4,
					min = 10,
					max = 30,
					step = 1,
					get = function()
						return BigWigsMageTools.db.profile.igniteheight
					end,
					set = function(v)
						BigWigsMageTools.db.profile.igniteheight = v
					end,
				},
				spacer = {
					type = "header",
					name = " ",
					order = 5,
				},
				-- TODO readd once I get threat working
				--ignitethreatthreshold = {
				--	type = "range",
				--	name = L["IgniteThreatThreshold"],
				--	desc = L["IgniteThreatThresholdDesc"],
				--	order = 6,
				--	min = 0,
				--	max = 100,
				--	step = 1,
				--	get = function()
				--		return BigWigsMageTools.db.profile.ignitethreatthreshold
				--	end,
				--	set = function(v)
				--		BigWigsMageTools.db.profile.ignitethreatthreshold = v
				--	end,
				--},
				igniteplayerwarning = {
					type = "toggle",
					name = L["IgnitePlayerWarning"],
					desc = L["IgnitePlayerWarningDesc"],
					order = 7,
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
					order = 8,
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
					order = 9,
				},
				ignitewarningtrigger = {
					type = "execute",
					name = L["IgnitePlayerWarningTrigger"],
					desc = L["IgnitePlayerWarningTriggerDesc"],
					order = 10,
					func = function()
						BigWigsMageTools:Sync(syncName.ignitePlayerWarningSpace .. BigWigsMageTools.playerName)
					end,
				},
				ignitepyrotrigger = {
					type = "execute",
					name = L["IgnitePyroRequest"],
					desc = L["IgnitePyroRequestDesc"],
					order = 11,
					func = function()
						BigWigsMageTools:Sync(syncName.ignitePyroRequestSpace .. BigWigsMageTools.playerName)
					end,
				},
			}
		}
	}
}

BigWigsMageTools.revision = 20001
BigWigsMageTools.external = true

BigWigsMageTools.target = nil
BigWigsMageTools.playerName = nil
BigWigsMageTools.scorchTimers = {}
BigWigsMageTools.scorchStacks = {}
BigWigsMageTools.igniteTimers = {}
BigWigsMageTools.igniteStacks = {}
BigWigsMageTools.igniteOwners = {}
BigWigsMageTools.igniteHasScorch = {}
BigWigsMageTools.igniteDamage = {}
-----------------------------------------------------------------------
--      Initialization
-----------------------------------------------------------------------

function BigWigsMageTools:OnRegister()
	self.consoleOptions.args.texture.validate = surface:List()
	self:RegisterEvent("Surface_Registered", function()
		self.consoleOptions.args.texture.validate = surface:List()
	end)
end

function BigWigsMageTools:OnEnable()
	self.playerName = UnitName("player")
	if not self.db.profile.texture then
		self.db.profile.texture = "BantoBar"
	end
	self.frames = {}
	self:SetupFrames()
	self:RegisterEvent("BigWigs_RecvSync")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	if isMage then
		self:RegisterEvent("CHARACTER_POINTS_CHANGED")
		self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "AuraFadeEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
		self:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", "PlayerDamageEvents")
	end

	if not self:IsEventRegistered("Surface_Registered") then
		self:RegisterEvent("Surface_Registered", function()
			self.consoleOptions.args[L["Texture"]].validate = surface:List()
		end)
	end

	self.target = UnitName("target")
	self:ThrottleSync(syncSpeed, syncName.scorch)
	self:ThrottleSync(syncSpeed, syncName.ignite)
	self:ThrottleSync(5, syncName.ignitePlayerWarning)
	self:ThrottleSync(5, syncName.ignitePyroRequest)
end

function BigWigsMageTools:OnDisable()
	self:HideAnchors()
end

-----------------------------------------------------------------------
--      Event Handlers
-----------------------------------------------------------------------
function BigWigsMageTools:PlayerDamageEvents(msg)
	-- check for scorch being enabled
	local eventHandled, crit, _ = self:ScorchEvent(msg)
	if not eventHandled or crit then
		self:IgniteEvent(msg)
	end
end

function BigWigsMageTools:ScorchEvent(msg)
	if not self.db.profile.scorchenable then
		return
	end

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["scorch_afflict_test"])
	if afflictedTarget then
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			self.scorchStacks[afflictedTarget] = tonumber(stacks)
		else
			self.scorchStacks[afflictedTarget] = 1
		end

		self.scorchTimers[afflictedTarget] = GetTime()
		self:Sync(syncName.scorchSpace .. afflictedTarget)

		return true, false, afflictedTarget  -- handled, crit, target
	else
		-- otherwise check for scorch hits
		local _, _, hitType, scorchTarget = string.find(msg, L["scorch_test"])
		-- only need to update bars if at 5 stacks, otherwise afflicted by message will handle it
		if scorchTarget then
			if self.scorchStacks[scorchTarget] == 5 then
				self.scorchTimers[scorchTarget] = GetTime()
				self:Sync(syncName.scorchSpace .. scorchTarget)
			end
			--check if scorch crit got into the ignite
			if hitType == "crit" and self.igniteStacks[scorchTarget] or 5 < 5 then
				self.igniteHasScorch[scorchTarget] = true
			end

			return true, hitType == "crit", scorchTarget  -- handled, crit, target
		end
	end
	return false, false, nil
end

function BigWigsMageTools:IsMageFireSpell(spellName)
	return spellName == "Fireball" or
			spellName == "Pyroblast" or
			spellName == "Scorch" or
			spellName == "Fire Blast" or
			spellName == "Flamestrike" or
			spellName == "Blast Wave"

end

function BigWigsMageTools:IgniteEvent(msg)
	if not self.db.profile.igniteenable then
		return
	end

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["ignite_afflict_test"])
	if afflictedTarget then
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			self.igniteStacks[afflictedTarget] = tonumber(stacks)
			self.igniteTimers[afflictedTarget] = GetTime()
		else
			self.igniteStacks[afflictedTarget] = 1
			self.igniteTimers[afflictedTarget] = GetTime() + timer.igniteFirstTickDelay
		end
		self:Sync(syncName.igniteSpace .. afflictedTarget)
		return true, false, afflictedTarget  -- handled, crit, target
	else
		-- check for ignite crits
		local _, _, spellName, critTarget = string.find(msg, L["ignite_crit_test"])
		if critTarget and self.IsMageFireSpell(spellName) then
			if self.igniteStacks[critTarget] and self.igniteStacks[critTarget] == 5 then
				-- refresh timer
				local timeLeft = self:GetTargetIgniteTimeLeft(critTarget)
				-- if more than 4 seconds, this won't change the timer
				if timeLeft < 4 then
					-- otherwise add 4 seconds to the timer
					if timeLeft > 2 then
						self.igniteTimers[afflictedTarget] = GetTime() + (timeLeft - 2) + 4
						self:Sync(syncName.igniteSpace .. critTarget)
					else
						self.igniteTimers[afflictedTarget] = GetTime() + timeLeft + 4
						self:Sync(syncName.igniteSpace .. critTarget)
					end
				end
			end
			return true, true, critTarget  -- handled, crit, target
		end
	end

	-- check for ignite tick damage
	local _, _, igniteTickTarget, igniteDmg, igniteOwner = string.find(msg, L["ignite_dmg"])
	if igniteTickTarget then
		self.igniteDamage[igniteTickTarget] = tonumber(igniteDmg)
		if igniteOwner then
			if igniteOwner == "your" then
				self.igniteOwners[igniteTickTarget] = self.playerName        -- add ignite owner if it's not already set
			else
				--	strip the 's
				self.igniteOwners[igniteTickTarget] = string.gsub(igniteOwner, "'s", "")
			end
		end
		self:Sync(syncName.igniteSpace .. igniteTickTarget)
		return true, false, igniteTickTarget  -- handled, crit, target
	end
end

function BigWigsMageTools:AuraFadeEvents(msg)
	local _, _, scorchTarget = string.find(msg, L["scorch_fades_test"])
	if scorchTarget then
		self.scorchTimers[scorchTarget] = nil
		self.scorchStacks[scorchTarget] = nil
		self:StopBar(scorchBarPrefix .. scorchTarget)
		return
	end

	local _, _, igniteTarget = string.find(msg, L["ignite_fades_test"])
	if igniteTarget then
		self.igniteHasScorch[igniteTarget] = nil
		self.igniteTimers[igniteTarget] = nil
		self.igniteStacks[igniteTarget] = nil
		self.igniteOwners[igniteTarget] = nil
		self.igniteDamage[igniteTarget] = nil
		self:StopBar(igniteBarPrefix)
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

function BigWigsMageTools:CHARACTER_POINTS_CHANGED()
	self.impScorch = self:CheckTalents()
end

function BigWigsMageTools:RecheckTargetChange()
	local target = UnitName("target")
	self.target = target

	-- if this target has been scorched, query current stacks
	if self.scorchTimers[target] or self.igniteStacks[target] then
		-- loop through debuff slots looking for scorch
		local scorchStacks = nil
		local igniteStacks = nil
		for i = 1, 24 do
			local texture, stacks, _ = UnitDebuff("target", i)
			if (texture and stacks) then
				if texture == scorchIcon then
					scorchStacks = tonumber(stacks)
				elseif texture == igniteIcon then
					igniteStacks = tonumber(stacks)
				end
			end
		end
		self.scorchStacks[target] = scorchStacks
		self.igniteStacks[target] = igniteStacks

		local timeleft = self:GetTargetScorchTimeLeft(target)
		if scorchStacks and timeleft then
			self:StartScorchBar(target, timeleft, self.scorchStacks[target])
		end

		timeleft = self:GetTargetIgniteTimeLeft(target)
		if igniteStacks and timeleft then
			self:StartIgniteBar(self:GetTargetIgniteText(target), timeleft, self.igniteStacks[target], self.igniteHasScorch[target])
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

function BigWigsMageTools:BigWigs_RecvSync(sync, arg1, arg2)
	if sync == syncName.scorch then
		if arg1 == self.target then
			local timeleft = self:GetTargetScorchTimeLeft(arg1)
			self:StartScorchBar(arg1, timeleft, self.scorchStacks[arg1])
			if self.db.profile.scorchsound then
				self:ScheduleEvent(warningSoundEvent, self.ScorchSoundWarning, 25 - syncSpeed, self, arg1)
			end
			if self.db.profile.scorchwarningsign then
				self:ScheduleEvent(warningSignEvent, self.ScorchSignWarning, 25 - syncSpeed, self, arg1)
			end
		end
	elseif sync == syncName.ignite then
		if arg1 == self.target then
			local timeleft = self:GetTargetIgniteTimeLeft(arg1)
			self:StartIgniteBar(self:GetTargetIgniteText(arg1), timeleft, self.igniteStacks[arg1], self.igniteHasScorch[arg1])
		end
	elseif sync == syncName.ignitePlayerWarning then
		if self.db.profile.igniteplayerwarning then
			self:Message(arg1 .. " says stop casting!!!", "Urgent", true, "stopcasting")
		end
	elseif sync == syncName.ignitePyroRequest then
		if self.db.profile.ignitepyrorequest then
			self:Bar(arg1 .. " has requested pyro!!!", 1, "spell_fire_fireball02", false, "Red")
			self:Sound("Pyro")
		end
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

function BigWigsMageTools:CheckTalents()
	nameTalent, icon, tier, column, currRank, maxRank = GetTalentInfo(2, 10);
	if nameTalent == "Improved Scorch" and currRank == maxRank then
		--self:DebugMessage(nameTalent .. " - "..currRank .."/"..maxRank)
		return true
	end
	return false
end

function BigWigsMageTools:Test()
	self:StopAllBars()

	--self:StartThreatBar("Pepopo 90%", 4)  TODO
	self:StartIgniteBar("2222 Pepopo", 4, 3, true)
	self:StartScorchBar("Thaddius", timer.scorch, 5)

	--	 schedule cancel in 10 sec
	self:ScheduleEvent("TestStop", self.StopAllBars, 10, self)
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

	--self.frames = {}

	local frame = CreateFrame("Frame", "ScorchTimerBarAnchor", UIParent)

	frame.owner = self
	frame:Hide()

	frame:SetWidth(175)
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

	local cfade = frame:CreateTexture(nil, "BORDER")
	cfade:SetWidth(169)
	cfade:SetHeight(25)
	cfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	cfade:SetPoint("TOP", frame, "TOP", 0, -4)
	cfade:SetBlendMode("ADD")
	cfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .25, .25, .25, 1)
	frame.cfade = cfade

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
	leftbutton:SetPoint("RIGHT", frame, "CENTER", -10, -15)
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

	local rightbutton = CreateFrame("Button", nil, frame)
	rightbutton.owner = self
	rightbutton:SetWidth(40)
	rightbutton:SetHeight(25)
	rightbutton:SetPoint("LEFT", frame, "CENTER", 10, -15)
	rightbutton:SetScript("OnClick", function()
		self:HideAnchors()
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
	if not self.frames.anchor then
		return
	end
	self.frames.anchor:Hide()
end

local barCache = {
	-- [i] = {id}
}

function BigWigsMageTools:StartScorchBar(text, time, stacks)
	if not text or not time or not stacks or not self.db.profile.scorchenable then
		return
	end
	local id = scorchBarPrefix .. text
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local groupId = self.frames.anchor.candyBarGroupId
	candybar:RegisterCandyBar(id, time, text, scorchIcon)
	candybar:RegisterCandyBarWithGroup(id, groupId)
	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))
	candybar:SetIconText(id, stacks or "")

	if type(self.db.profile.scorchwidth) == "number" then
		candybar:SetCandyBarWidth(id, self.db.profile.scorchwidth)
	end
	if type(self.db.profile.scorchheight) == "number" then
		candybar:SetCandyBarHeight(id, self.db.profile.scorchheight)
	end

	candybar:SetCandyBarFade(id, .5)
	if time < 5 then
		candybar:SetCandyBarColor(id, "red", 1)
	elseif time < 10 then
		candybar:SetCandyBarColor(id, "yellow", 1)
	else
		candybar:SetCandyBarColor(id, "green", 1)
	end

	candybar:StartCandyBar(id, true)
	tinsert(barCache, id)
end

function BigWigsMageTools:StartIgniteBar(text, time, stacks, igniteHasScorch)
	if not text or not time or not stacks or not self.db.profile.igniteenable then
		return
	end
	local id = igniteBarPrefix
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local groupId = self.frames.anchor.candyBarGroupId
	candybar:RegisterCandyBar(id, time, text, igniteIcon)
	candybar:RegisterCandyBarWithGroup(id, groupId)
	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))
	candybar:SetIconText(id, stacks or "")

	if type(self.db.profile.ignitewidth) == "number" then
		local width = self.db.profile.ignitewidth / 5
		if stacks and stacks > 1 then
			width = width * stacks -- don't let bar get too small
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

	candybar:StartCandyBar(id, true)
	candybar:Pause(id, true)

	tinsert(barCache, id)
end

function BigWigsMageTools:StartThreatBar(text, time)
	if not text or not time or not self.db.profile.threatenable then
		return
	end
	local id = threatBarPrefix .. text
	if not self.frames.anchor then
		self:SetupFrames()
	end

	local groupId = self.frames.anchor.candyBarGroupId
	candybar:RegisterCandyBar(id, time, text, threatIcon)
	candybar:RegisterCandyBarWithGroup(id, groupId)
	candybar:SetCandyBarTexture(id, surface:Fetch(self.db.profile.texture))
	candybar:SetIconText(id, "")

	if type(self.db.profile.threatwidth) == "number" then
		candybar:SetCandyBarWidth(id, self.db.profile.threatwidth)
	end

	if type(self.db.profile.threatheight) == "number" then
		candybar:SetCandyBarHeight(id, self.db.profile.threatheight * 1.5)
	end

	candybar:SetCandyBarFade(id, .5)
	candybar:SetCandyBarColor(id, "red", 1)

	candybar:StartCandyBar(id, true)
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
