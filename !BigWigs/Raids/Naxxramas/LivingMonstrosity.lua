
-- Credit to Relar/MadScripts

----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Living Monstrosity", "Naxxramas")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Monstrosity",

	lightningtotem_cmd = "lightningtotem",
	lightningtotem_name = "Lightning Totem Alert",
	lightningtotem_desc = "Warn for Lightning Totem summon",

	autotarget_cmd = "autotarget",
	autotarget_name = "Auto-Target Lightning Totem",
	autotarget_desc = "Targets the totem automatically upon summon",

	trigger_totemUp = "Living Monstrosity casts Lightning Totem.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_totemUp = "Lightning Totem!",
	
	trigger_totemDead = "Lightning Totem dies.",--CHAT_MSG_COMBAT_HOSTILE_DEATH

} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.toggleoptions = {"lightningtotem", "autotarget"}
module.trashMod = true

module.defaultDB = {
	lightningtotem = true,
	autotarget = false,
	bosskill = nil,
}

-- locals
local timer = {
    lightningcast = 3.5, --Maybe??
}
local icon = {
	lightningTotem = "Spell_Nature_Lightning"
}
local syncName = {
	lightningtotem = "lightningtotem"..module.revision,
}


------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "CheckTotem")

	self:ThrottleSync(6, syncName.lightningtotem)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers      --
------------------------------

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.lightningtotem and self.db.profile.lightningtotem then
		self:Message(L["msg_totemUp"], "Important", nil, "Beware")
		self:WarningSign(icon.lightningTotem, 3, true, "TOTEM!")
		if self.db.profile.autotarget then TargetByName("Lightning Totem",true) end
	end
end

function module:CheckTotem(msg)
	if string.find(msg, L["trigger_totemUp"]) then
		self:Sync(syncName.lightningtotem)
	end
end
