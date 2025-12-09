--[[
MageToolEventsV2.lua - Event handlers for MageTools plugin using structured events
This file contains event registration and handler logic using the new structured event system
with GUIDs, spell IDs, and detailed parameters instead of text parsing.
--]]

assert(BigWigs, "BigWigs not found!")

local MageToolEventsV2 = {}

-- Reference to parent module (will be set by MageTools)
MageToolEventsV2.parent = nil

-- Constants
local SPELL_SCHOOL_FIRE = 2
local HIT_INFO_CRIT = 2
local FIRE_VULNERABILITY_MAX_STACKS = 5
local IGNITE_MAX_STACKS = 5
local IGNITE_DURATION = 4

-- Spell ID lookup tables - All ranks of mage fire spells
-- Format: [spellId] = "Spell Name"

-- Mage fire spells that can cause ignite
local IGNITE_SPELL_IDS = {
	-- Blast Wave (Ranks 1-5)
	[11113] = "Blast Wave",
	[13018] = "Blast Wave",
	[13019] = "Blast Wave",
	[13020] = "Blast Wave",
	[13021] = "Blast Wave",

	-- Fire Blast (Ranks 1-7)
	[2136] = "Fire Blast",
	[2137] = "Fire Blast",
	[2138] = "Fire Blast",
	[8412] = "Fire Blast",
	[8413] = "Fire Blast",
	[10197] = "Fire Blast",
	[10199] = "Fire Blast",

	-- Fireball (Ranks 1-12)
	[133] = "Fireball",
	[143] = "Fireball",
	[145] = "Fireball",
	[3140] = "Fireball",
	[8400] = "Fireball",
	[8401] = "Fireball",
	[8402] = "Fireball",
	[10148] = "Fireball",
	[10149] = "Fireball",
	[10150] = "Fireball",
	[10151] = "Fireball",
	[25306] = "Fireball",

	-- Flamestrike (Ranks 1-6)
	[2120] = "Flamestrike",
	[2121] = "Flamestrike",
	[8422] = "Flamestrike",
	[8423] = "Flamestrike",
	[10215] = "Flamestrike",
	[10216] = "Flamestrike",

	-- Pyroblast (Ranks 1-9)
	[11366] = "Pyroblast",
	[12505] = "Pyroblast",
	[12522] = "Pyroblast",
	[12523] = "Pyroblast",
	[12524] = "Pyroblast",
	[12525] = "Pyroblast",
	[12526] = "Pyroblast",
	[12527] = "Pyroblast",
	[18809] = "Pyroblast",

	-- Scorch (Ranks 1-7)
	[2948] = "Scorch",
	[8444] = "Scorch",
	[8445] = "Scorch",
	[8446] = "Scorch",
	[10205] = "Scorch",
	[10206] = "Scorch",
	[10207] = "Scorch",
}

-- Scorch and Fire Blast spell IDs (for tracking scorch debuff synergy)
local SCORCH_FIREBLAST_SPELL_IDS = {
	-- Scorch (Ranks 1-7)
	[2948] = "Scorch",
	[8444] = "Scorch",
	[8445] = "Scorch",
	[8446] = "Scorch",
	[10205] = "Scorch",
	[10206] = "Scorch",
	[10207] = "Scorch",

	-- Fire Blast (Ranks 1-7)
	[2136] = "Fire Blast",
	[2137] = "Fire Blast",
	[2138] = "Fire Blast",
	[8412] = "Fire Blast",
	[8413] = "Fire Blast",
	[10197] = "Fire Blast",
	[10199] = "Fire Blast",
}

-- Debuff/Buff spell IDs

-- Ignite debuff (Ranks 1-5)
local IGNITE_DEBUFF_IDS = {
	[12654] = "Ignite",
}

-- Fire Vulnerability debuff (Ranks 1-10)
local FIRE_VULNERABILITY_DEBUFF_IDS = {
	[22959] = "Fire Vulnerability",
}

-----------------------------------------------------------------------
--      Event Registration
-----------------------------------------------------------------------

function MageToolEventsV2:RegisterEvents()
	local parent = self.parent
	if not parent then
		return
	end

	-- Spell damage events (for tracking scorch/ignite crits and hits)
	parent:RegisterEvent("SPELL_DAMAGE_EVENT_SELF", function(targetGuidStr, casterGuidStr, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
		MageToolEventsV2:OnSpellDamage(targetGuidStr, casterGuidStr, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
	end)

	parent:RegisterEvent("SPELL_DAMAGE_EVENT_OTHER", function(targetGuidStr, casterGuidStr, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
		MageToolEventsV2:OnSpellDamage(targetGuidStr, casterGuidStr, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
	end)

	-- Debuff tracking (for ignite and fire vulnerability)
	parent:RegisterEvent("BUFF_ADDED_OTHER", function(guid, slot, spellId, stacks, levels)
		MageToolEventsV2:OnAuraAddedOther(guid, slot, spellId, stacks, levels)
	end)

	parent:RegisterEvent("DEBUFF_ADDED_OTHER", function(guid, slot, spellId, stacks, levels)
		MageToolEventsV2:OnAuraAddedOther(guid, slot, spellId, stacks, levels)
	end)

	parent:RegisterEvent("BUFF_REMOVED_OTHER", function(guid, slot, spellId, stacks, levels)
		MageToolEventsV2:OnAuraRemovedOther(guid, slot, spellId, stacks, levels)
	end)

	parent:RegisterEvent("DEBUFF_REMOVED_OTHER", function(guid, slot, spellId, stacks, levels)
		MageToolEventsV2:OnAuraRemovedOther(guid, slot, spellId, stacks, levels)
	end)

	-- Death tracking
	parent:RegisterEvent("UNIT_DIED", function(guid)
		MageToolEventsV2:OnUnitDied(guid)
	end)
end

-----------------------------------------------------------------------
--      Helper Functions
-----------------------------------------------------------------------

function MageToolEventsV2:IsMageFireSpell(spellId)
	return IGNITE_SPELL_IDS[spellId] ~= nil
end

-----------------------------------------------------------------------
--      Spell Damage Event Handlers
-----------------------------------------------------------------------

function MageToolEventsV2:OnSpellDamage(targetGuidStr, casterGuidStr, spellId, amount, mitigationStr, hitInfo, spellSchool, effectAuraStr)
	local parent = self.parent
	if not parent then
		return
	end

	-- Check if this is a fire spell
	if spellSchool ~= SPELL_SCHOOL_FIRE then
		return
	end

	local isCrit = (hitInfo == HIT_INFO_CRIT)
	local targetGuid = targetGuidStr
	local casterGuid = casterGuidStr

	if not targetGuid then
		return
	end

	-- Drop stale ignite data when the last tick/crit is older than the ignite duration
	local lastIgniteTime = parent.igniteTimers[targetGuid]
	if lastIgniteTime and (GetTime() - lastIgniteTime) > IGNITE_DURATION then
		parent.igniteHasScorch[targetGuid] = nil
		parent.igniteTimers[targetGuid] = nil
		parent.igniteStacks[targetGuid] = nil
		parent.igniteOwners[targetGuid] = nil
		parent.igniteDamage[targetGuid] = nil
		parent:StopBar("IgniteBar" .. targetGuid)
		parent:StopBar("ThreatBar" .. targetGuid)
	end

	parent:Debug(string.format("SPELL_DAMAGE_OTHER: spell=%d (%s), casterGuid=%s, targetGuid=%s, amount=%d, crit=%s",
			spellId, IGNITE_SPELL_IDS[spellId] or IGNITE_DEBUFF_IDS[spellId] or "unknown",
			tostring(casterGuid), targetGuid, amount, tostring(isCrit)))

	-- Handle ignite damage ticks
	if IGNITE_DEBUFF_IDS[spellId] then
		parent.igniteDamage[targetGuid] = amount
		if casterGuid then
			parent.igniteOwners[targetGuid] = casterGuid
			-- Enable threat tracking - convert GUID to name for BigWigsThreat
			local casterName = parent:GetOwnerDisplayName(casterGuid)
			if casterName then
				BigWigsThreat:EnableEventsForPlayerName(casterName)
			end
		end
		parent:Ignite(targetGuid)
		return
	end

	-- Handle scorch/fire blast from other players
	if SCORCH_FIREBLAST_SPELL_IDS[spellId] then
		local scorchStacks = parent.scorchStacks[targetGuid] or 0
		if scorchStacks < FIRE_VULNERABILITY_MAX_STACKS then
			scorchStacks = scorchStacks + 1
			parent.scorchStacks[targetGuid] = scorchStacks
		end
		parent.scorchTimers[targetGuid] = GetTime()
		parent:Scorch(targetGuid)

		if isCrit and parent.igniteStacks[targetGuid] and parent.igniteStacks[targetGuid] < IGNITE_MAX_STACKS then
			parent.igniteHasScorch[targetGuid] = true
		end
	end

	-- Handle ignite-causing crits from other players
	if isCrit and IGNITE_SPELL_IDS[spellId] and casterGuid then
		local igniteStacks = parent.igniteStacks[targetGuid] or 0
		if igniteStacks < IGNITE_MAX_STACKS then
			igniteStacks = igniteStacks + 1
			parent.igniteStacks[targetGuid] = igniteStacks
		end
		if not parent.igniteOwners[targetGuid] then
			parent.igniteOwners[targetGuid] = casterGuid
		end
		parent.igniteTimers[targetGuid] = GetTime()
		parent:Ignite(targetGuid)
	end
end

-----------------------------------------------------------------------
--      Debuff Event Handlers
-----------------------------------------------------------------------

function MageToolEventsV2:OnAuraAddedOther(guid, slot, spellId, stacks, levels)
	local parent = self.parent
	if not parent then
		return
	end

	local targetGuid = guid
	if not targetGuid then
		return
	end

	-- Track Fire Vulnerability (Scorch debuff)
	if FIRE_VULNERABILITY_DEBUFF_IDS[spellId] then
		parent:Debug(string.format("DEBUFF_ADDED_OTHER: targetGuid=%s, spell=%d (%s), stacks=%d",
			targetGuid, spellId, FIRE_VULNERABILITY_DEBUFF_IDS[spellId], stacks or 0))

		parent.scorchStacks[targetGuid] = stacks
		parent.scorchTimers[targetGuid] = GetTime()
		parent:Scorch(targetGuid)
	end

	-- Track Ignite debuff
	if IGNITE_DEBUFF_IDS[spellId] then
		parent:Debug(string.format("DEBUFF_ADDED_OTHER: targetGuid=%s, spell=%d (%s), stacks=%d",
			targetGuid, spellId, IGNITE_DEBUFF_IDS[spellId], stacks or 0))

		parent.igniteStacks[targetGuid] = stacks
		parent.igniteTimers[targetGuid] = GetTime()
		parent:Ignite(targetGuid)
	end
end

function MageToolEventsV2:OnAuraRemovedOther(guid, slot, spellId, stacks, levels)
	local parent = self.parent
	if not parent then
		return
	end

	local targetGuid = guid
	if not targetGuid then
		return
	end

	-- Handle Fire Vulnerability fade
	if FIRE_VULNERABILITY_DEBUFF_IDS[spellId] then
		parent:Debug(string.format("DEBUFF_REMOVED_OTHER: targetGuid=%s, spell=%d (%s)",
			targetGuid, spellId, FIRE_VULNERABILITY_DEBUFF_IDS[spellId]))
		parent.scorchTimers[targetGuid] = nil
		parent.scorchStacks[targetGuid] = nil
		parent:StopBar("ScorchTimerBar" .. targetGuid)
	end

	-- Handle Ignite fade
	if IGNITE_DEBUFF_IDS[spellId] then
		parent:Debug(string.format("DEBUFF_REMOVED_OTHER: targetGuid=%s, spell=%d (%s)",
			targetGuid, spellId, IGNITE_DEBUFF_IDS[spellId]))
		parent.igniteHasScorch[targetGuid] = nil
		parent.igniteTimers[targetGuid] = nil
		parent.igniteStacks[targetGuid] = nil
		parent.igniteOwners[targetGuid] = nil
		parent.igniteDamage[targetGuid] = nil
		parent:StopBar("IgniteBar" .. targetGuid)
		parent:StopBar("ThreatBar" .. targetGuid)
	end
end

-----------------------------------------------------------------------
--      Death Event Handler
-----------------------------------------------------------------------

function MageToolEventsV2:OnUnitDied(guid)
	local parent = self.parent
	if not parent then
		return
	end

	local targetGuid = guid
	if not targetGuid then
		return
	end

	parent:Debug(string.format("UNIT_DIED: guid=%s", targetGuid))

	-- Reset everything for that target
	parent.scorchTimers[targetGuid] = nil
	parent.scorchStacks[targetGuid] = nil
	parent:StopBar("ScorchTimerBar" .. targetGuid)

	parent.igniteHasScorch[targetGuid] = nil
	parent.igniteTimers[targetGuid] = nil
	parent.igniteStacks[targetGuid] = nil
	parent.igniteOwners[targetGuid] = nil
	parent.igniteDamage[targetGuid] = nil
	parent:StopBar("IgniteBar" .. targetGuid)
	parent:StopBar("ThreatBar" .. targetGuid)
end

-----------------------------------------------------------------------
--      Initialize
-----------------------------------------------------------------------

function MageToolEventsV2:Initialize(parentModule)
	self.parent = parentModule
end

-- Export
BigWigsMageToolEventsV2 = MageToolEventsV2
