
local module, L = BigWigs:ModuleDeclaration("Gargoyle", "Naxxramas")

module.revision = 20004
module.enabletrigger = { "Stoneskin Gargoyle", "Plagued Gargoyle" }

L:RegisterTranslations("enUS", function() return {
	cmd = "Stoneskin",

	stoneskin_cmd = "stoneskin",
	stoneskin_name = "Stoneskin Alert",
	stoneskin_desc = "Warn for Stoneskin",

	stoneskintrigger = "%s emits a strange noise.",
	stoneskinwarn = "Casting Stoneskin!",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Defender",

	stoneskin_cmd = "stoneskin",
	stoneskin_name = "Stoneskin Alert",
	stoneskin_desc = "Warn for Stoneskin",

	stoneskintrigger = "Stoneskin Gargoyle emits a strange noise.",
	stoneskinwarn = "Casting Stoneskin!",
} end )

L:RegisterTranslations("deDE", function() return {
	stoneskin_cmd = "stoneskin",
	stoneskin_name = "Stoneskin Alert",
	stoneskin_desc = "Warn for Stoneskin",

	stoneskintrigger = "Stoneskin Gargoyle emits a strange noise.",
	stoneskinwarn = "Casting Stoneskin!",
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	stoneskin = 6,
}
local icon = {
	stoneskin = "spell_nature_enchantarmor",
}
local syncName = {
	stoneskin = "StoneskinGargoyleStoneskin"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "checkStoneskin")

	self:ThrottleSync(6, syncName.stoneskin)
end

function module:OnSetup()
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.stoneskin then
		self:Message(L["stoneskinwarn"], "Important", nil, "Beware")
		self:Bar(L["stoneskinwarn"], timer.stoneskin, icon.stoneskin)
	end
end

function module:checkStoneskin(msg)
	if msg == L["stoneskintrigger"] then
		self:Sync(syncName.stoneskin)
	end
end
