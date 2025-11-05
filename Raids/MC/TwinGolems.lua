local module, L = BigWigs:ModuleDeclaration("Twin Golems", "Molten Core")

-- module variables
module.revision = 30000
module.enabletrigger = { "Smoldaris", "Basalthar" }
module.toggleoptions = { "bulwark", "bosskill" }

-- module defaults
module.defaultDB = {
	bulwark = true,
}

-- localization
L:RegisterTranslations("enUS", function()
	return {
		cmd = "TwinGolems",

		bulwark_cmd = "bulwark",
		bulwark_name = "Molten Bulwark Alert",
		bulwark_desc = "Timer bar and target switch alert for Molten Bulwark (-95% damage taken, fire thorns)",

		trigger_bulwarkGain = "(.+) gains Molten Bulwark",
		trigger_bulwarkFade = "Molten Bulwark fades from (.+)%.",
		msg_switch = "SWITCH to %s",
		bar_bulwark = "%s Bulwark",
	}
end)

-- timer and icon variables
local timer = {
	bulwark = 15,
}

local icon = {
	bulwark = "ability_mage_moltenarmor",
}

local color = {
	bulwark = "Red",
}

local syncName = {
	bulwarkGain = "MCTwinGolemsBulwarkGain" .. module.revision,
	bulwarkFade = "MCTwinGolemsBulwarkFade" .. module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")

	self:ThrottleSync(4, syncName.bulwarkGain)
	self:ThrottleSync(4, syncName.bulwarkFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	-- Bulwark gain
	local _, _, mob = string.find(msg, L["trigger_bulwarkGain"])
	if mob then
		self:Sync(syncName.bulwarkGain .. " " .. mob)
	end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
	-- Bulwark fade
	local _, _, mob = string.find(msg, L["trigger_bulwarkFade"])
	if mob then
		self:Sync(syncName.bulwarkFade .. " " .. mob)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.bulwarkGain and rest then
		self:BulwarkGain(rest)
	elseif sync == syncName.bulwarkFade and rest then
		self:BulwarkFade(rest)
	end
end

function module:BulwarkGain(mob)
	-- display timer bar with mob name
	if self.db.profile.bulwark then
		self:Bar(string.format(L["bar_bulwark"], mob), timer.bulwark, icon.bulwark, true, color.bulwark)
	end
end

function module:BulwarkFade(mob)
	-- remove timer bar in case it's still up
	self:RemoveBar(string.format(L["bar_bulwark"], mob))
	
	-- tell people to switch targets because Bulwark will go on the other golem in 2-4 seconds
	if self.db.profile.bulwark then
		self:Message(string.format(L["msg_switch"], mob), "Attention", true, "Alert")
	end
end

function module:Test()
	-- Initialize module state
	self:Engage()

	local events = {
		-- based on actual log timestamps
		{ time = 0.252, func = function()
			local msg = "Basalthar gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		{ time = 15.259, func = function()
			local msg = "Molten Bulwark fades from Basalthar."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		end },
		{ time = 16.720, func = function()
			local msg = "Smoldaris gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		{ time = 31.649, func = function()
			local msg = "Molten Bulwark fades from Smoldaris."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		end },
		{ time = 35.733, func = function()
			local msg = "Basalthar gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		{ time = 50.587, func = function()
			local msg = "Molten Bulwark fades from Basalthar."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		end },
		{ time = 52.371, func = function()
			local msg = "Smoldaris gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		{ time = 67.290, func = function()
			local msg = "Molten Bulwark fades from Smoldaris."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		end },
		{ time = 71.250, func = function()
			local msg = "Basalthar gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		{ time = 86.199, func = function()
			local msg = "Molten Bulwark fades from Basalthar."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
		end },
		{ time = 87.832, func = function()
			local msg = "Smoldaris gains Molten Bulwark."
			print("Test: " .. msg)
			module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
		end },
		
		-- End of Test
		{ time = 90, func = function()
			print("Test: Disengage")
			module:Disengage()
		end },
	}

	-- Schedule each event at its absolute time
	for i, event in ipairs(events) do
		self:ScheduleEvent("TwinGolemsTest" .. i, event.func, event.time)
	end

	self:Message("Twin Golems test started", "Positive")
	return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("Twin Golems"); BigWigs:SetupModule("Twin Golems");m:Test();
