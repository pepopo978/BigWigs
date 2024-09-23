
local module, L = BigWigs:ModuleDeclaration("Flame Imp", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"respawn"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "FlameImp",

	respawn_cmd = "respawn",
	respawn_name = "Respawn Alert",
	respawn_desc = "Warn for Respawn",

	bar_respawn = " Respawn",
	msg_respawn = "Imp Pack will respawn in 7 minutes - Right-click the BigWigs icon to remove the bar",
} end )

local timer = {
	respawn = 420,
}
local icon = {
	respawn = "inv_misc_pocketwatch_01",
}
local color = {
	respawn = "Magenta",
}
local syncName = {
	dead = "FlameImpDead"..module.revision,
}

local packDeadCount = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:ThrottleSync(30, syncName.dead)
end

function module:OnSetup()
	self.started = nil
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
end

function module:OnDisengage()
end

-- noop, over-rides normal 'wipe' bar clearing
function module:CheckForWipe()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if (msg == string.format(UNITDIESOTHER, "Flame Imp")) then
		self:Sync(syncName.dead)
	end
end

function module:Event(msg)
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.dead and self.db.profile.respawn then
		self:StartTimer()
	end
end


function module:StartTimer()
	packDeadCount = packDeadCount + 1
	-- self:Message(L["msg_respawn"])
	self:Bar("Imp Pack "..packDeadCount..L["bar_respawn"], timer.respawn, icon.respawn, true, color.respawn)
end
