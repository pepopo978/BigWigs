
local module, L = BigWigs:ModuleDeclaration("Core Hound", "Molten Core")

module.revision = 30074
module.enabletrigger = module.translatedName
module.toggleoptions = {"respawn","despawn"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Molten Core"],
	AceLibrary("Babble-Zone-2.2")["Molten Core"],
}
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "CoreHound",

	respawn_cmd = "respawn",
	respawn_name = "Respawn Alert",
	respawn_desc = "Warn for Respawn",

	despawn_cmd = "despawn",
	despawn_name = "Despawn Timer",
	despawn_desc = "Countdown for body Despawn",

	trigger_smolder = "collapses and begins to smolder.",
	bar_respawn = "Respawn",
	msg_respawn = "Kill all Core Hounds within 10 seconds",

	bar_despawn = "Despawn",
	msg_despawn = "Corehounds despawned",

	["You have slain %s!"] = true,
} end )

local timer = {
	respawn = 10,
	despawn = 11, -- also 10, but giving wiggle room
}
local icon = {
	respawn = "spell_holy_resurrection",
	despawn = "inv_misc_pocketwatch_01",
}
local color = {
	respawn = "Magenta",
	despawn = "Gray",
}
local syncName = {
	dead = "CoreHoundDead"..module.revision,
	despawn = "CoreHoundDespawn"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	
	self:ThrottleSync(10, syncName.dead)
	self:ThrottleSync(0.5, syncName.despawn)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["trigger_smolder"]) then
		self:Sync(syncName.dead)
		self:Sync(syncName.despawn)
	end
end

function module:Event(msg)
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.dead and self.db.profile.respawn then
		self:StartRespawnTimer()
	elseif sync == syncName.despawn and self.db.profile.despawn then
		self:StartDespawnTimer()
	end
end

function module:StartDespawnTimer()
	self:Message(L["msg_despawn"])
	self:Bar(L["bar_despawn"], timer.despawn, icon.despawn, true, color.despawn)
end

function module:StartRespawnTimer()
	self:Message(L["msg_respawn"])
	self:Bar(L["bar_respawn"], timer.respawn, icon.respawn, true, color.respawn)
end
