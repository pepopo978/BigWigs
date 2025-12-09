--[[
MageToolEventsV1.lua - Event handlers for MageTools plugin
This file contains all the event registration and handler logic for tracking scorch and ignite.
--]]

assert(BigWigs, "BigWigs not found!")

local MageToolEventsV1 = {}

-- Reference to parent module (will be set by MageTools)
MageToolEventsV1.parent = nil

-----------------------------------------------------------------------
--      Localization (V1-specific chat message patterns)
-----------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsMageToolsV1")

L:RegisterTranslations("enUS", function()
	return {
		scorch_afflict_test = "^(.+) is afflicted by Fire Vulnerability(.*)", -- for stacks 2-5 will be "Fire Vulnerability (2)".
		scorch_gains_test = "^(.+) gains Fire Vulnerability(.*)", -- for stacks 2-5 will be "Fire Vulnerability (2)".
		scorch_test = ".+ Scorch (.+)s (.+) for",
		fireblast_test = ".+ Fire Blast (.+)s (.+) for",
		scorch_fades_test = "Fire Vulnerability fades from (.+).",
		scorch_resist_test = "(.+) Scorch was resisted by (.+).",
		fireblast_resist_test = "(.+) Fire Blast was resisted by (.+).",
		fire_vuln_resist_test = "(.+) Fire Vulnerability was resisted by (.+).", -- Scorch can hit but fire vulnerability can resist independently

		ignite_afflict_test = "^(.+) is afflicted by Ignite(.*)", -- for stacks 2-5 will be "Ignite (2)".
		ignite_gains_test = "^(.+) gains Ignite(.*)", -- for stacks 2-5 will be "Ignite (2)".
		self_ignite_crit_test = "^(Your) (.+) crits (.+) for .+ Fire damage",
		other_ignite_crit_test = "^(.+)'s (.+) crits (.+) for .+ Fire damage",
		ignite_dmg = "^(.+) suffers (.+) Fire damage from (.+) Ignite",
		ignite_fades_test = "Ignite fades from (.+).",

		slain_test = "(.+) is slain by (.+)",
		self_slain_test = "You have slain (.+)",
		death_test = "(.+) dies.",
	}
end)

-----------------------------------------------------------------------
--      Event Registration
-----------------------------------------------------------------------

function MageToolEventsV1:RegisterEvents()
	local parent = self.parent
	if not parent then return end

	parent:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "DeathEvent")
	parent:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "AuraFadeEvents")

	parent:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "PlayerDamageEvents")
	parent:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", "PlayerDamageEvents")
end

-----------------------------------------------------------------------
--      Helper Functions
-----------------------------------------------------------------------

function MageToolEventsV1:IsMageFireSpell(spellName)
	return spellName == "Fireball" or
			spellName == "Pyroblast" or
			spellName == "Scorch" or
			spellName == "Fire Blast" or
			spellName == "Flamestrike" or
			spellName == "Blast Wave"
end

function MageToolEventsV1:UpdateIgniteOwner(playername, target)
	local parent = self.parent
	if not parent then return end

	local playerName = ""
	-- playername can be "your" or "name 's"
	if string.lower(playername) == "your" then
		playerName = parent.playerName        -- add ignite owner if it's not already set
	else
		--	strip the 's and the space that is currently inserted after the player name
		playerName = string.gsub(playername, "(%s?)'s", "")
	end
	BigWigsThreat:EnableEventsForPlayerName(playerName)
	parent.igniteOwners[target] = playerName
end

function MageToolEventsV1:UpdateScorchTimer(target, time)
	local parent = self.parent
	if not parent then return end

	parent.scorchTimers[target] = time
	parent:Scorch(target)
end

-----------------------------------------------------------------------
--      Event Parsing Functions
-----------------------------------------------------------------------

function MageToolEventsV1:ScorchEvent(msg)
	local parent = self.parent
	if not parent then return end

	if not parent.db.profile.scorchenable then
		return
	end

	local scorchTimerUpdateEvent = "UpdateScorchTimer"

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["scorch_afflict_test"])
	if not afflictedTarget then
		-- check for gains messages (shouldn't happen but just to be safe)
		_, _, afflictedTarget, stackInfo = string.find(msg, L["scorch_gains_test"])
	end

	if afflictedTarget then
		parent:Debug(msg)
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			parent.scorchStacks[afflictedTarget] = tonumber(stacks)
		else
			parent.scorchStacks[afflictedTarget] = 1
		end

		parent.scorchTimers[afflictedTarget] = GetTime()
		parent:Scorch(afflictedTarget)

		return true, false, afflictedTarget  -- handled, crit, target
	end

	-- otherwise check for scorch hits
	local _, _, hitType, scorchTarget = string.find(msg, L["scorch_test"])
	if not scorchTarget then
		_, _, hitType, scorchTarget = string.find(msg, L["fireblast_test"])
	end
	-- only need to update bars if at 5 stacks, otherwise afflicted by message will handle it
	if scorchTarget then
		parent:Debug(msg)

		-- update scorch timer after a half second to give time to check if fire vulnerability was resisted
		parent:ScheduleEvent(scorchTimerUpdateEvent .. scorchTarget, self.UpdateScorchTimer, 0.2, self, scorchTarget, GetTime())

		local igniteStacks = parent.igniteStacks[scorchTarget] or 1

		--check if scorch crit got into the ignite
		if hitType == "crit" and igniteStacks < 5 then
			parent.igniteHasScorch[scorchTarget] = true
		end

		return true, hitType == "crit", scorchTarget  -- handled, crit, target
	end

	-- otherwise check for scorch resists
	local _, _, caster, resistTarget = string.find(msg, L["scorch_resist_test"])
	if not resistTarget then
		_, _, caster, resistTarget = string.find(msg, L["fireblast_resist_test"])
	end
	if not resistTarget then
		_, _, caster, resistTarget = string.find(msg, L["fire_vuln_resist_test"])
	end
	if resistTarget then
		parent:Debug(msg)
		-- cancel timer update
		if parent:IsEventScheduled(scorchTimerUpdateEvent .. resistTarget) then
			parent:CancelScheduledEvent(scorchTimerUpdateEvent .. resistTarget)
		end
		parent:Message(resistTarget .. " resisted " .. caster .. " scorch", "Attention", false)
		if parent.db.profile.scorchresistsound then
			parent:Sound("ScorchResist")
		end
		return true, false, resistTarget  -- handled, crit, target
	end

	return false, false, nil
end

function MageToolEventsV1:IgniteEvent(msg)
	local parent = self.parent
	if not parent then return end

	if not parent.db.profile.igniteenable then
		return
	end

	-- check for afflicted by messages first
	local _, _, afflictedTarget, stackInfo = string.find(msg, L["ignite_afflict_test"])
	if not afflictedTarget then
		-- check for gains messages (seems to happen for ignite)
		_, _, afflictedTarget, stackInfo = string.find(msg, L["ignite_gains_test"])
	end

	if afflictedTarget then
		parent:Debug(msg)
		local _, _, stacks = string.find(stackInfo, "(%d+)")
		if stacks then
			parent.igniteStacks[afflictedTarget] = tonumber(stacks)
		else
			parent.igniteStacks[afflictedTarget] = 1
		end
		parent.igniteTimers[afflictedTarget] = GetTime()
		parent:Ignite(afflictedTarget)
		return true, false, afflictedTarget  -- handled, crit, target
	else
		-- check for ignite crits
		local _, _, playerName, spellName, critTarget = string.find(msg, L["self_ignite_crit_test"])
		if not critTarget then
			_, _, playerName, spellName, critTarget = string.find(msg, L["other_ignite_crit_test"])
		end
		if critTarget and self:IsMageFireSpell(spellName) then
			parent:Debug(msg)
			-- if no owner is set, set it.  Ignite tick will correct it if wrong
			if not parent.igniteOwners[critTarget] then
				self:UpdateIgniteOwner(playerName, critTarget)
			end

			parent.igniteTimers[critTarget] = GetTime()
			parent:Ignite(critTarget)
			return true, true, critTarget  -- handled, crit, target
		end
	end

	-- check for ignite tick damage
	local _, _, igniteTickTarget, igniteDmg, igniteOwner = string.find(msg, L["ignite_dmg"])
	if igniteTickTarget then
		parent:Debug(msg)
		parent.igniteDamage[igniteTickTarget] = tonumber(igniteDmg)
		if igniteOwner then
			self:UpdateIgniteOwner(igniteOwner, igniteTickTarget)
		end
		parent:Ignite(igniteTickTarget)
		return true, false, igniteTickTarget  -- handled, crit, target
	end
end

-----------------------------------------------------------------------
--      Event Handlers
-----------------------------------------------------------------------

function MageToolEventsV1:PlayerDamageEvents(msg)
	local parent = self.parent
	if not parent then return end

	local eventHandled, crit, _ = self:ScorchEvent(msg)
	if not eventHandled or crit then
		self:IgniteEvent(msg)
	end
end

function MageToolEventsV1:DeathEvent(msg)
	local parent = self.parent
	if not parent then return end

	parent:Debug(msg)
	local _, _, deadTarget, _ = string.find(msg, L["slain_test"])
	if not deadTarget then
		_, _, deadTarget = string.find(msg, L["self_slain_test"])
	end
	if not deadTarget then
		_, _, deadTarget = string.find(msg, L["death_test"])
	end
	if deadTarget then
		-- reset everything for that target
		parent.scorchTimers[deadTarget] = nil
		parent.scorchStacks[deadTarget] = nil
		parent:StopBar("ScorchTimerBar" .. deadTarget)

		parent.igniteHasScorch[deadTarget] = nil
		parent.igniteTimers[deadTarget] = nil
		parent.igniteStacks[deadTarget] = nil
		parent.igniteOwners[deadTarget] = nil
		parent.igniteDamage[deadTarget] = nil
		parent:StopBar("IgniteBar" .. deadTarget)
		parent:StopBar("ThreatBar" .. deadTarget)
	end
end

function MageToolEventsV1:AuraFadeEvents(msg)
	local parent = self.parent
	if not parent then return end
	local _, _, scorchTarget = string.find(msg, L["scorch_fades_test"])
	if scorchTarget then
		parent:Debug(msg)
		parent.scorchTimers[scorchTarget] = nil
		parent.scorchStacks[scorchTarget] = nil
		parent:StopBar("ScorchTimerBar" .. scorchTarget)
		return
	end

	local _, _, igniteTarget = string.find(msg, L["ignite_fades_test"])
	if igniteTarget then
		parent:Debug(msg)
		parent.igniteHasScorch[igniteTarget] = nil
		parent.igniteTimers[igniteTarget] = nil
		parent.igniteStacks[igniteTarget] = nil
		parent.igniteOwners[igniteTarget] = nil
		parent.igniteDamage[igniteTarget] = nil
		parent:StopBar("IgniteBar" .. igniteTarget)
		parent:StopBar("ThreatBar" .. igniteTarget)
	end
end

-----------------------------------------------------------------------
--      Initialize
-----------------------------------------------------------------------

function MageToolEventsV1:Initialize(parentModule)
	self.parent = parentModule

	-- Hook event handlers to parent module
	parentModule.PlayerDamageEvents = function(self, msg)
		MageToolEventsV1:PlayerDamageEvents(msg)
	end

	parentModule.DeathEvent = function(self, msg)
		MageToolEventsV1:DeathEvent(msg)
	end

	parentModule.AuraFadeEvents = function(self, msg)
		MageToolEventsV1:AuraFadeEvents(msg)
	end

	-- Hook event parsing functions to parent module
	parentModule.ScorchEvent = function(self, msg)
		return MageToolEventsV1:ScorchEvent(msg)
	end

	parentModule.IgniteEvent = function(self, msg)
		return MageToolEventsV1:IgniteEvent(msg)
	end

	-- Hook helper functions to parent module
	parentModule.UpdateScorchTimer = function(self, target, time)
		MageToolEventsV1:UpdateScorchTimer(target, time)
	end

	parentModule.IsMageFireSpell = function(self, spellName)
		return MageToolEventsV1:IsMageFireSpell(spellName)
	end

	parentModule.UpdateIgniteOwner = function(self, playername, target)
		MageToolEventsV1:UpdateIgniteOwner(playername, target)
	end
end

-- Export
BigWigsMageToolEventsV1 = MageToolEventsV1
