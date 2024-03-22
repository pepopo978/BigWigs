
local module, L = BigWigs:ModuleDeclaration("Fankriss the Unyielding", "Ahn'Qiraj")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"wound", "entangle", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Fankriss",
	
	wound_cmd = "wound",
	wound_name = "Wound 5 stacks alerts",
	wound_desc = "Alert for 5 stacks of Wound",
	
	entangle_cmd = "entangle",
	entangle_name = "Entangle Alert",
	entangle_desc = "Warn for Entangle",
	
	
	trigger_entangleYou = "You are afflicted by Entangle.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_entangleOther = "(.+) is afflicted by Entangle.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_entangleFade = "Entangle fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
	bar_entangle = " Entangled",
	
	trigger_woundYou = "You are afflicted by Mortal Wound %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_woundOther = "(.+) is afflicted by Mortal Wound %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_wound = " Wounds",
} end )


local timer = {
	entangle = 8,
	wound = 15,
}
local icon = {
	entangle = "Spell_Nature_Web",
	wound = "ability_criticalstrike",
}
local color = {
	entangle = "White",
	wound = "Black",
}
local syncName = {
	entangle = "FankrissEntangle"..module.revision,
	entangleFade = "FankrissEntangleFade"..module.revision,
	wound = "FankrissWound"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_entangleYou, trigger_woundYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_entangleOther, trigger_woundOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_entangleOther, trigger_woundOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_entangleFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_entangleFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_entangleFade
	
	self:ThrottleSync(0.1, syncName.entangle)
	self:ThrottleSync(0.1, syncName.entangleFade)
	self:ThrottleSync(3, syncName.wound)
end

function module:OnSetup()
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_entangleYou"] then
		self:Sync(syncName.entangle .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_entangleOther"]) then
		local _,_,entangledPerson = string.find(msg, L["trigger_entangleOther"])
		self:Sync(syncName.entangle .. " " .. entangledPerson)
		
	elseif string.find(msg, L["trigger_entangleFade"]) then
		local _,_,entangledFadePerson = string.find(msg, L["trigger_entangleFade"])
		self:Sync(syncName.entangleFade .. " " .. entangledFadePerson)
		
		
	elseif string.find(msg, L["trigger_woundYou"]) then
		local _,_,woundQty,_ = string.find(msg, L["trigger_woundYou"])
		local woundPlayer = UnitName("Player")
		local woundPlayerAndWoundQty = woundPlayer .. " " .. woundQty
		self:Sync(syncName.wound.." "..woundPlayerAndWoundQty)
		
	elseif string.find(msg, L["trigger_woundOther"]) then
		local _,_,woundPlayer,woundQty = string.find(msg, L["trigger_woundOther"])
		local woundPlayerAndWoundQty = woundPlayer .. " " .. woundQty
		self:Sync(syncName.wound.." "..woundPlayerAndWoundQty)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.entangle and rest and self.db.profile.entangle then
		self:Entangle(rest)
	elseif sync == syncName.entangleFade and rest and self.db.profile.entangle then
		self:EntangleFade(rest)
	elseif sync == syncName.wound and rest and self.db.profile.wound then
		self:Wound(rest)
	end
end

function module:Entangle(rest)
	self:Bar(rest..L["bar_entangle"], timer.entangle, icon.entangle, true, color.entangle)
end

function module:EntangleFade(rest)
	self:RemoveBar(rest..L["bar_entangle"])
end

function module:Wound(rest)
	local woundPlayer = strsub(rest,0,strfind(rest," ") - 1)
	local woundQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
	
	self:RemoveBar(woundPlayer.." ".."1"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."2"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."3"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."4"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."5"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."6"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."7"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."8"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."9"..L["bar_wound"])
	self:RemoveBar(woundPlayer.." ".."10"..L["bar_wound"])

	self:Bar(woundPlayer.." "..woundQty..L["bar_wound"], timer.wound, icon.wound, true, color.wound)
end
