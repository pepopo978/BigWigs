
local module, L = BigWigs:ModuleDeclaration("Mossheart", "The Black Morass")

module.revision = 30029
module.enabletrigger = module.translatedName
module.toggleoptions = {"mosscoveredhands", "entanglingroots", "dredgesickness", "rejuvenation", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["The Black Morass"],
	AceLibrary("Babble-Zone-2.2")["The Black Morass"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Mossheart",

	mosscoveredhands_cmd = "mosscoveredhands",
	mosscoveredhands_name = "Moss Covered Hands Alert",
	mosscoveredhands_desc = "Warn for Moss Covered Hands",
	
	entanglingroots_cmd = "entanglingroots",
	entanglingroots_name = "Entangling Roots Alert",
	entanglingroots_desc = "Warns for Rntangling Roots",
	
	dredgesickness_cmd = "dredgesickness",
	dredgesickness_name = "Dredge Sickness Alert",
	dredgesickness_desc = "Warns for Dredge Sickness",
	
	rejuvenation_cmd = "rejuvenation",
	rejuvenation_name = "Rejuvenation Alert",
	rejuvenation_desc = "Warns for Rejuvenation",
	
	
	trigger_engage = "Who dares defile the sanctity of the morass...",--CHAT_MSG_MONSTER_YELL
	
	trigger_mossCoveredHandsYou = "You are afflicted by Moss Covered Hands.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mossCoveredHandsOther = "(.+) is afflicted by Moss Covered Hands.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_mossCoveredHandsFade = "Moss Covered Hands fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mossCoveredHands = " Moss",
	
	trigger_entanglingRoots = "The very earth rises in defiance...",--CHAT_MSG_MONSTER_YELL
	bar_entanglingRootsCd = "Entangling Roots CD",
	
	--50% and 25%? or timed 46sec from pull and 25sec after?
	trigger_dredgeSickness = "afflicted by Dredge Sickness",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	
	trigger_rejuvenation = "Mossheart gains Rejuvenation.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_rejuvenationFade = "Rejuvenation fades from Mossheart.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_rejuvenation = "Rejuvenation",
	msg_rejuvenation = "Mossheart gains Rejuvenation, Purge / Dispel!",
} end )

local timer = {
	mossCoveredHands = 180,
	entanglingRootsCd = 25,
	--dredgeSickness = 300,
	rejuvenation = 12,
}
local icon = {
	mossCoveredHands = "spell_nature_magicimmunity",
	entanglingRootsCd = "spell_nature_stranglevines",
	dredgeSickness = "spell_nature_nullifydisease",
	rejuvenation = "spell_nature_rejuvenation",
}
local color = {
	mossCoveredHands = "Black",
	entanglingRootsCd = "Red",
	dredgeSickness = "Blue",
	rejuvenation = "Green",
}
local syncName = {
	mossCoveredHands = "MossheartMossCoveredHands"..module.revision,
	mossCoveredHandsFade = "MossheartMossCoveredHandsFade"..module.revision,
	entanglingRoots = "MosshearTentanglingRoots"..module.revision,
	dredgeSickness = "MossheartDredgeSickness"..module.revision,
	rejuvenation = "MossheartRejuvenation"..module.revision,
	rejuvenationFade = "MossheartRejuvenationFade"..module.revision,
}


function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_mossCoveredHandsYou, trigger_dredgeSickness
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_mossCoveredHandsOther, trigger_dredgeSickness
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_mossCoveredHandsOther, trigger_dredgeSickness
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_mossCoveredHandsFade, trigger_rejuvenationFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_mossCoveredHandsFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_mossCoveredHandsFade
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_rejuvenation
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage
	
	self:ThrottleSync(1, syncName.mossCoveredHands)
	self:ThrottleSync(1, syncName.mossCoveredHandsFade)
	self:ThrottleSync(1, syncName.entanglingRoots)
	self:ThrottleSync(1, syncName.dredgeSickness)
	self:ThrottleSync(1, syncName.rejuvenation)
	self:ThrottleSync(1, syncName.rejuvenationFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.entanglingroots then
		self:Bar(L["bar_entanglingRootsCd"], timer.entanglingRootsCd, icon.entanglingRootsCd, true, color.entanglingRootsCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if UnitName("Player") == "Relar" then DEFAULT_CHAT_FRAME:AddMessage("msg: "..msg) end
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	elseif msg == L["trigger_entanglingRoots"] then
		self:Sync(syncName.entanglingRoots)
	end
end

function module:Event(msg)
	if msg == L["trigger_mossCoveredHandsYou"] then
		self:Sync(syncName.mossCoveredHands .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_mossCoveredHandsOther"]) then
		local _,_, mossCoveredHandsPlayer, _ = string.find(msg, L["trigger_mossCoveredHandsOther"])
		self:Sync(syncName.mossCoveredHands .. " " .. mossCoveredHandsPlayer)
		
	elseif string.find(msg, L["trigger_mossCoveredHandsFade"]) then
		local _,_, mossCoveredHandsFadePlayer, _ = string.find(msg, L["trigger_mossCoveredHandsFade"])
		if mossCoveredHandsFadePlayer == "you" then mossCoveredHandsFadePlayer = UnitName("Player") end
		self:Sync(syncName.mossCoveredHandsFade .. " " .. mossCoveredHandsFadePlayer)
	
	
	elseif string.find(msg, L["trigger_dredgeSickness"]) then
		self:Sync(syncName.dredgeSickness)
	
	
	elseif msg == L["trigger_rejuvenation"] then
		self:Sync(syncName.rejuvenation)
	elseif msg == L["trigger_rejuvenationFade"] then
		self:Sync(syncName.rejuvenationFade)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mossCoveredHands and rest and self.db.profile.mosscoveredhands then
		self:MossCoveredHands(rest)
	elseif sync == syncName.mossCoveredHandsFade and rest and self.db.profile.mosscoveredhands then
		self:MossCoveredHandsFade(rest)
	
	elseif sync == syncName.entanglingRoots and self.db.profile.entanglingroots then
		self:EntanglingRoots()
		
	elseif sync == syncName.dredgeSickness and self.db.profile.dredgesickness then
		self:DredgeSickness()
	
	
	elseif sync == syncName.rejuvenation and self.db.profile.rejuvenation then
		self:Rejuvenation()
	elseif sync == syncName.rejuvenationFade and self.db.profile.rejuvenation then
		self:RejuvenationFade()
	
	end
end


function module:MossCoveredHands(rest)
	self:Bar(rest..L["bar_mossCoveredHands"], timer.mossCoveredHands, icon.mossCoveredHands, true, color.mossCoveredHands)
	
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" then
		self:WarningSign(icon.mossCoveredHands, 0.7)
		self:Sound("Info")
	end
end

function module:MossCoveredHandsFade(rest)
	self:RemoveBar(rest..L["bar_mossCoveredHands"])
end

function module:EntanglingRoots()
	self:RemoveBar(L["bar_entanglingRootsCd"])
	self:Bar(L["bar_entanglingRootsCd"], timer.entanglingRootsCd, icon.entanglingRootsCd, true, color.entanglingRootsCd)
	
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" then
		self:WarningSign(icon.entanglingRootsCd, 0.7)
		self:Sound("Info")
	end
end

function module:DredgeSickness()
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" then
		self:WarningSign(icon.dredgeSickness, 0.7)
		self:Sound("Info")
	end
end

function module:Rejuvenation()
	self:Bar(L["bar_rejuvenation"], timer.rejuvenation, icon.rejuvenation, true, color.rejuvenation)
	if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Priest" then
		self:WarningSign(icon.rejuvenation, timer.rejuvenation)
		self:Sound("Info")
		self:Message(L["msg_rejuvenation"], "Urgent", false, nil, false)
	end
end

function module:RejuvenationFade()
	self:RemoveBar(L["bar_rejuvenation"])
	self:RemoveWarningSign(icon.rejuvenation)
end
