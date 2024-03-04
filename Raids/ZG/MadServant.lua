
local module, L = BigWigs:ModuleDeclaration("Mad Servant", "Zul'Gurub")

module.revision = 30059
module.enabletrigger = {}--module.translatedName
module.toggleoptions = {"portal"}
module.trashMod = true
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Zul'Gurub"],
	AceLibrary("Babble-Zone-2.2")["Zul'Gurub"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "madservant",

	portal_cmd = "portal",
	portal_name = "Portal Alert",
	portal_desc = "Warn Portal of Madness.",

	trigger_portal = "Mad Servant casts Portal of Madness.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	bar_portal = "Void Spawn - Portal ",
	msg_portal = "D E L A Y  killing other imps if you value your life!",
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	portal = 11,
}
local icon = {
	portal = "spell_shadow_sealofkings",
}
local color = {
	portal = "White",
}
local syncName = {
}

local portalNum = 1
local lastPortalTime = GetTime()

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--trigger_portal
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CheckForWipe(event)
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= "Edge of Madness" or self.core:IsModuleActive(module.translatedName) then
		return
	elseif GetMinimapZoneText() == "Edge of Madness" then
		self.core:EnableModule(module.translatedName)
	end
end

function module:Event(msg)
	if msg == L["trigger_portal"] and self.db.profile.portal then
		self:Portal()
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
end


function module:Portal()
	if (GetTime() - lastPortalTime) > timer.portal then
		self:ResetCount()
	end
	
	self:Bar(L["bar_portal"]..portalNum, timer.portal, icon.portal, true, color.portal)
	self:Message(L["msg_portal"], "Urgent", false, nil, false)
	self:WarningSign(icon.portal, 1)
	self:Sound("Info")
	
	portalNum = portalNum + 1
	
	lastPortalTime = GetTime()
end

function module:ResetCount()
	portalNum = 1
end
