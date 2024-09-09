local module, L = BigWigs:ModuleDeclaration("Patchwork Golem", "Naxxramas")

module.revision = 20001
module.enabletrigger = { "Patchwork Golem" }
module.toggleoptions = { "warstomp" }
module.trashMod = true

L:RegisterTranslations("enUS", function()
	return {
		cmd = "ConstructTrash",

		warstomp_cmd = "warstomp",
		warstomp_name = "War Stomp",
		warstomp_desc = "Displays a cooldown and an icon for the initial synchronised warstomp.",

		bar_timeToStomp = "Warstomp",
	}
end)

local timer = {
	warstomp = 6, -- actually 7, but 6 seems to be accurate in game?
}

local icon = {
	warstomp = "ability_bullrush"
}

local color = {
	warstomp = "Red",
}

local deathCount = 0
local stompNumber = 1
local lastStomp = 0

function module:OnEnable()
end

function module:OnSetup()
	-- self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	-- deathCount = 0
	-- stompNumber = 1
	-- lastStomp = 0
end

function module:OnEngage()
	if self.db.profile.warstomp then
		self:Bar(L["bar_timeToStomp"], timer.warstomp, icon.warstomp, true, color.warstomp)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	-- if msg == string.format(UNITDIESOTHER, "Patchwork Golem") then
	-- 	deathCount = deathCount + 1
	-- 	if deathCount == 4 then
	-- 		self:SendBossDeathSync()
	-- 	end
	-- end
end

function module:Event(msg)
end
