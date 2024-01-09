
local module, L = BigWigs:ModuleDeclaration("Anubisath Defender", "Ahn'Qiraj")

module.revision = 30039
module.enabletrigger = module.translatedName
module.toggleoptions = {"reflect", "plagueyou", "plagueother", "icon", "thunderclap", "shadowstorm", "meteor", -1, "explode", "enrage"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Defender",
	
	reflect_cmd = "reflect",
	reflect_name = "Spell reflect alert",
	reflect_desc = "Shows bars for which reflect the Defender has",
	
	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn if you got the Plague",
	
	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn if others got the Plague",
	
	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	shadowstorm_cmd = "shadowstorm",
	shadowstorm_name = "Shadowstorm Alert",
	shadowstorm_desc = "Warn for Shadowstorm",
	
	meteor_cmd = "meteor",
	meteor_name = "Meteor Alert",
	meteor_desc = "Warn for meteor",
	
	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for Explode",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	
	trigger_arcaneFireReflect1 = "Moonfire is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect2 = "Scorch is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect3 = "Flame Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect4 = "Firebolt is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect5 = "Flame Lash is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect6 = "Detect Magic is reflected",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	arcrefwarn = "Fire & Arcane reflect",
	
	trigger_shadowFrostReflect1 = "Shadow Word: Pain is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect2 = "Corruption is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect3 = "Frostbolt is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect4 = "Frost Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect5 = "Anubisath Defender is afflicted by Detect Magic.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	sharefwarn = "Shadow & Frost reflect",
	
	thunderclaptrigger = "Anubisath Defender's Thunderclap hits",
	thunderclap_split = "Thunderclap -- 2 GROUPS!!",

	shadowstormtrigger = "Anubisath Defender's Shadow Storm hits",
	shadowstorm_stay = "!!STACK IN MELEE RANGE!!",

	meteortrigger = "Anubisath Defender's Meteor",
	meteorbar = "Meteor CD",
	meteorwarn = "Meteor!",
	
	explodetrigger = "Anubisath Defender gains Explode.",
	explodewarn = "Exploding!",

	enragetrigger = "Anubisath Defender gains Enrage.",
	enragewarn = "Enraged!",

	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the Plague!",
	plagueyou = "You",
	plagueare = "are",
	plague_onme = "Plague on ",
	
	trigger_selfReflect = "Your (.*) is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	msg_selfReflect = "STOP KILLING YOURSELF!",
} end )

module.defaultDB = {
	bosskill = false,
	enrage = false,
}

local timer = {
	meteor = {6.4,13},--saw 6.4
	explode = 6,
	arcref = 600,
	sharef = 600,
}

local icon = {
	plague = "Spell_Shadow_CurseOfTounges",
	meteor = "Spell_Fire_Fireball02",
	explode = "spell_fire_selfdestruct",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
}

local syncName = {
	enrage = "DefenderEnrage"..module.revision,
	explode = "DefenderExplode"..module.revision,
	thunderclap = "DefenderThunderclap"..module.revision,
	shadowstorm = "DefenderShadowstorm"..module.revision,
	meteor = "DefenderMeteor"..module.revision,
	arcref = "DefenderArcaneReflect"..module.revision,
	sharef = "DefenderShadowReflect"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--Explosion and Enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--Plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--Plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--Plague
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--Thunderclap and Shadowstorm

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")--arcaneFireReflect, shadowFrostReflect
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")--arcaneFireReflect, shadowFrostReflect
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE","Event")--arcaneFireReflect, shadowFrostReflect
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE","Event")--Anubisath Defender is afflicted by Detect Magic
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.explode)
	self:ThrottleSync(6, syncName.thunderclap)
	self:ThrottleSync(6, syncName.shadowstorm)
	self:ThrottleSync(10, syncName.sharef)
	self:ThrottleSync(10, syncName.arcref)
end

function module:OnSetup()
end

function module:OnEngage()
	bwDefendersFirst = true
	bwDefendersFirstArcRef = true
	bwDefendersFirstShaRef = true
	self:RemoveBar(L["arcrefwarn"])
	self:RemoveBar(L["sharefwarn"])
end

function module:OnDisengage()
	bwDefendersFirst = true
	bwDefendersFirstArcRef = true
	bwDefendersFirstShaRef = true
end

function module:Event(msg)
	if string.find(msg, L["plaguetrigger"]) then
		local _,_, pplayer, ptype = string.find(msg, L["plaguetrigger"])
		if pplayer then
			if self.db.profile.plagueyou and pplayer == L["plagueyou"] then
				SendChatMessage("Plague on "..UnitName("player").."!","SAY")
				self:Message(L["plagueyouwarn"], "Personal")
				self:Message(UnitName("player") .. L["plaguewarn"])
				self:WarningSign(icon.plague, 5)
				self:Sound("RunAway")
			elseif self.db.profile.plagueother then
				self:Message(pplayer .. L["plaguewarn"], "Attention")
				self:TriggerEvent("BigWigs_SendTell", pplayer, L["plagueyouwarn"])
			end
			if self.db.profile.icon then
				self:TriggerEvent("BigWigs_SetRaidIcon", pplayer)
			end
		end
		
	elseif string.find(msg, L["meteortrigger"]) then
		self:Sync(syncName.meteor)
	elseif string.find(msg, L["thunderclaptrigger"]) then
		self:Sync(syncName.thunderclap)
	elseif string.find(msg, L["shadowstormtrigger"]) then
		self:Sync(syncName.shadowstorm)
	elseif msg == L["explodetrigger"] then
		self:Sync(syncName.explode)
	elseif msg == L["enragetrigger"] then
		self:Sync(syncName.enrage)
	elseif string.find(msg, L["trigger_arcaneFireReflect1"]) or string.find(msg, L["trigger_arcaneFireReflect2"]) or string.find(msg, L["trigger_arcaneFireReflect3"]) or string.find(msg, L["trigger_arcaneFireReflect4"]) or string.find(msg, L["trigger_arcaneFireReflect5"]) or string.find(msg, L["trigger_arcaneFireReflect6"]) then
		self:Sync(syncName.arcref)
	elseif string.find(msg, L["trigger_shadowFrostReflect1"]) or string.find(msg, L["trigger_shadowFrostReflect2"]) or string.find(msg, L["trigger_shadowFrostReflect3"]) or string.find(msg, L["trigger_shadowFrostReflect4"]) or string.find(msg, L["trigger_shadowFrostReflect5"]) then
		self:Sync(syncName.sharef)		
	end
	
	if string.find(msg, L["trigger_selfReflect"]) then
		self:SelfReflect()
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.explode and self.db.profile.explode then
		self:Explode()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.meteor and self.db.profile.meteor then
		self:Meteor()
	elseif sync == syncName.thunderclap and self.db.profile.thunderclap then
		self:Thunderclap()
	elseif sync == syncName.shadowstorm and self.db.profile.shadowstorm then
		self:ShadowStorm()
	elseif sync == syncName.arcref and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.sharef and self.db.profile.reflect then
		self:ShadowReflect()
	end
end

function module:Explode()
	self:Message(L["explodewarn"], "Important", false, nil, false)
	self:Bar(L["explodewarn"], timer.explode, icon.explode, true, "Black")
	self:WarningSign(icon.explode, timer.explode)
	self:Sound("RunAway")
end

function module:Enrage()
	self:Message(L["enragewarn"], "Important", false, nil, false)
end

function module:Thunderclap()
	if bwDefendersFirst == true then
		self:Message(L["thunderclap_split"], "Attention", false, nil, false)
		bwDefendersFirst = false
	end
end

function module:ShadowStorm()
	if bwDefendersFirst == true then
		self:Message(L["shadowstorm_stay"], "Attention", false, nil, false)
		bwDefendersFirst = false
	end
end

function module:ArcaneReflect()
	if bwDefendersFirstArcRef == true then
		self:Bar(L["arcrefwarn"], timer.arcref, icon.arcref, true, "red")
		bwDefendersFirstArcRef = false
	end
end

function module:ShadowReflect()
	if bwDefendersFirstShaRef == true then 
		self:Bar(L["sharefwarn"], timer.sharef, icon.sharef, true, "blue")
		bwDefendersFirstShaRef = false
	end
end

function module:Meteor()
	self:IntervalBar(L["meteorbar"], timer.meteor[1], timer.meteor[2], icon.meteor, true, "cyan")
	self:Message(L["meteorwarn"], "Important", false, nil, false)
end

function module:SelfReflect()
	self:Message(L["msg_selfReflect"], "Personal", false, nil, false)
	self:Sound("Beware")
end
