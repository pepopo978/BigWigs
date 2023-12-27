local module, L = BigWigs:ModuleDeclaration("Qiraji Mindslayer", "Ahn'Qiraj")

module.revision = 20046
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "mindflay"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Mindslayer",

	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",
	
	mindflay_cmd = "mindflay",
	mindflay_name = "Mind Flay Alert",
	mindflay_desc = "Warn for Mind Flay",

	mcplayer = "You are afflicted by Cause Insanity",
	mcplayerother = "(.*) is afflicted by Cause Insanity",
	mcplayeryouend = "Cause Insanity fades from you.",
	mcplayerotherend = "Cause Insanity fades from (.*).",
	mcplayer_message = "You are mindcontrolled!",
	mcplayerother_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",
	deathyou_trigger = "You die.",
    deathother_trigger = "(.*) dies.",

	mindflayplayer = "You are afflicted by Mind Flay",
	mindflayplayerother = "(.*) is afflicted by Mind Flay",
	mindflayplayeryouend = "Mind Flay fades from you.",
	mindflayplayerotherend = "Mind Flay fades from (.*).",
	mindflayplayer_message = "You are Mind Flayed!",
	mindflayplayerother_message = "%s is Mind Flayed!",
	mindflay_bar = "Mind Flay: %s",
	
	mobdead = "Qiraji Mindslayer dies",
} end )

local timer = {
	mc = 9.5,
	mindflay = 8,
}

local icon = {
	mc = "Spell_Shadow_Charm",
	mindflay = "spell_shadow_siphonmana",
}

local syncName = {
	mc = "MindslayerMC"..module.revision,
	mcOver = "MindslayerMCEnd"..module.revision,
	mindflay = "Mindslayermindflay"..module.revision,
	mindflayOver = "MindslayermindflayEnd"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	diesoon = false
end

function module:OnDisengage()
end


function module:Event(msg)
	local _,_, mindcontrolother, mctype = string.find(msg, L["mcplayerother"])
	local _,_, mindcontrolotherend, mctype = string.find(msg, L["mcplayerotherend"])
	local _,_, mindcontrolotherdeath,mctype = string.find(msg, L["deathother_trigger"])
		
	if string.find(msg, L["mcplayer"]) then
		self:Sync(syncName.mc .. " " .. UnitName("player"))
	elseif string.find(msg, L["mcplayeryouend"]) then
		self:Sync(syncName.mcOver .. " " .. UnitName("player"))
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:Sync(syncName.mcOver .. " " .. UnitName("player"))
	elseif mindcontrolother then
		self:Sync(syncName.mc .. " " .. mindcontrolother)
	elseif mindcontrolotherend then
		self:Sync(syncName.mcOver .. " " .. mindcontrolotherend)
	elseif mindcontrolotherdeath then
		self:Sync(syncName.mcOver .. " " .. mindcontrolotherdeath)
	end

	local _,_, mindflayother, mctype = string.find(msg, L["mindflayplayerother"])
	local _,_, mindflayotherend, mctype = string.find(msg, L["mindflayplayerotherend"])
	local _,_, mindflayotherdeath,mctype = string.find(msg, L["deathother_trigger"])
		
	if string.find(msg, L["mindflayplayer"]) then
		self:Sync(syncName.mindflay .. " " .. UnitName("player"))
	elseif string.find(msg, L["mindflayplayeryouend"]) then
		self:Sync(syncName.mindflayOver .. " " .. UnitName("player"))
	elseif string.find(msg, L["deathyou_trigger"]) then
		self:Sync(syncName.mindflayOver .. " " .. UnitName("player"))
	elseif mindflayother then
		self:Sync(syncName.mindflay .. " " .. mindflayother)
	elseif mindflayotherend then
		self:Sync(syncName.mindflayOver .. " " .. mindflayotherend)
	elseif mindflayotherdeath then
		self:Sync(syncName.mindflayOver .. " " .. mindflayotherdeath)
	end
	if string.find(msg, L["mobdead"]) then
		diesoon = false
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == self.translatedName then
		if UnitHealthMax(msg) == 100 then
			if  UnitHealth(msg) < 15 and not diesoon then
				if GetRaidTargetIndex("target")==nil then mobicon = "NoIcon"; end
				if GetRaidTargetIndex("target")==1 then mobicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then mobicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then mobicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then mobicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then mobicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then mobicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then mobicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then mobicon = "Skull"; end
				self:Message(mobicon.." dies soon, max range!", "Urgent")
				self:Sound("Alarm")
				diesoon = true
				self:UnregisterEvent("UNIT_HEALTH")
			end
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.mc then
		if self.db.profile.mc then
			if rest == UnitName("player") then
				self:Bar(string.format(L["mindcontrol_bar"], UnitName("player")), timer.mc, icon.mc, true, "red")
			else
				self:Bar(string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"), timer.mc, icon.mc, true, "red")
				self:SetCandyBarOnClick("BigWigsBar "..string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"), function(name, button, extra) TargetByName(extra, true) end, rest)
			end
		end
	elseif sync == syncName.mcOver then
		if self.db.profile.mc then
			self:RemoveBar(string.format(L["mindcontrol_bar"], rest .. " >Click Me!<"))
		end
	end

	if sync == syncName.mindflay then
		if self.db.profile.mindflay then
			if rest == UnitName("player") then
				self:Bar(string.format(L["mindflay_bar"], UnitName("player")), timer.mindflay, icon.mindflay, true, "black")
			else
				self:Bar(string.format(L["mindflay_bar"], rest), timer.mindflay, icon.mindflay, true, "black")
			end
		end
	elseif sync == syncName.mindflayOver then
		if self.db.profile.mindflay then
			self:RemoveBar(string.format(L["mindflay_bar"], rest))
		end
	end
end
