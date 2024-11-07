
local module, L = BigWigs:ModuleDeclaration("Emeriss", "Ashenvale")

module.revision = 30087
module.enabletrigger = module.translatedName
module.toggleoptions = {"tailsweep", "dreamfog", "noxiousbreath", -1, "sporecloud", "volatileinfection", "corruption", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Ashenvale"],
	AceLibrary("Babble-Zone-2.2")["Duskwood"],
	AceLibrary("Babble-Zone-2.2")["The Hinterlands"],
	AceLibrary("Babble-Zone-2.2")["Feralas"]
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Emeriss",

	tailsweep_cmd = "tailsweep",
	tailsweep_name = "Tail Sweep Alert",
	tailsweep_desc = "Warn for Tail Sweep",
	
	dreamfog_cmd = "dreamfog",
	dreamfog_name = "Dream Fog Sleep Alert",
	dreamfog_desc = "Warn for Dream Fog Sleep",
	
	noxiousbreath_cmd = "noxiousbreath",
	noxiousbreath_name = "Noxious Breath Alert",
	noxiousbreath_desc = "Warn for Noxious Breath",
	
	sporecloud_cmd = "sporecloud",
	sporecloud_name = "Spore Cloud Alert",
	sporecloud_desc = "Warn for Spore Cloud",
	
	volatileinfection_cmd = "volatileinfection",
	volatileinfection_name = "Volatile Infection Alert",
	volatileinfection_desc = "Warn for Volatile Infection",
	
	corruption_cmd = "corruption",
	corruption_name = "Corruption of the Earth Alert",
	corruption_desc = "Warn for Corruption of the Earth ",
	

	trigger_engage = "Hope is a DISEASE of the soul! This land shall wither and die!", --CHAT_MSG_MONSTER_YELL
	
	--self
	trigger_tailSweepYou = "Tail Sweep hits you for", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_tailSweepYou = "Tail Sweep - Don't stand behind Dragons!",
	
	--self
	trigger_dreamFogYou = "You are afflicted by Sleep.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_dreamFogYouFade = "Sleep fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_dreamFogYou = "Dream Fog Sleep - Don't stand in the Dream Fog!",

	--if nox you, for loop, find bossTarget, if bossTarget not you then WarningSign + msg only tank should
	trigger_noxiousBreathYou = "You are afflicted by Noxious Breath", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_noxiousBreathOther = "(.+) is afflicted by Noxious Breath", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_noxiousBreathCd = "Noxious Breath CD",
	msg_noxiousBreathYou = "Noxious Breath - Don't stand in front of Dragons!",

	--if is 3+ then bar
	trigger_noxiousBreathStackYou = "You are afflicted by Noxious Breath %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_noxiousBreathStackOther = "(.+) is afflicted by Noxious Breath %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_noxiousBreathFade = "Noxious Breath fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_noxiousBreath = " Noxious Breath",
	
	--when someone dies, they become a spore cloud, everyone around takes high damage
		--Explode? DoT? Afflic?
	trigger_sporeCloud = "To Be Determined", --TBD
	
	trigger_volatileInfectionYou = "You are afflicted by Volatile Infection.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_volatileInfectionOther = "(.+) is afflicted by Volatile Infection.",  --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE //CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_volatileInfectionFade = "Volatile Infection fades from (.+).",  --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_volatileInfection = " Volatile Infection",
	msg_volatileInfection = " Volatile Infection - Cleanse Disease!",

	trigger_corruption = "Taste your world's corruption!", --CHAT_MSG_MONSTER_YELL
	bar_corruption = "Corruption of the Earth",
	msg_corruption = "Corruption of the Earth - 20% dmg / 2sec - Heal up!",
	msg_corruptionSoon = "Corruption of the Earth Soon",
} end )

local timer = {
	dreamFog = 5,
	
	noxiousBreathFirstCd = 7,
	noxiousBreathCd = {9,11},
	noxiousBreathDur = 30,
	
	sporeCloud = 99,
	
	volatileInfection = 120,
	
	corruption = 10,
}
local icon = {
	tailSweep = "inv_misc_monsterscales_05",
	dreamFog = "spell_nature_sleep",
	noxiousBreath = "spell_shadow_lifedrain02",
	
	sporeCloud = "spell_nature_dryaddispelmagic",
	volatileInfection = "spell_holy_harmundeadaura",
	corruption = "ability_creature_cursed_03",
}
local color = {
	noxiousBreathCd = "Black",
	noxiousBreathDur = "Red",
	
	sporeCloud = "Orange",
	
	volatileInfection = "Green",
	
	corruption = "Magenta",
}
local syncName = {
	noxiousBreath = "EmerissNoxiousBreath"..module.revision,
	noxiousBreathStacks = "EmerissNoxiousBreathStacks"..module.revision,
	noxiousBreathStacksFade = "EmerissNoxiousBreathStacksFade"..module.revision,
	
	sporeCloud = "EmerissSporeCloud"..module.revision,
	
	volatileInfection = "EmerissVolatileInfection"..module.revision,
	volatileInfectionFade = "EmerissVolatileInfectionFade"..module.revision,
	
	corruption = "EmerissCorruption"..module.revision,
}

local seventyFiveSoon = nil
local fiftySoon = nil
local twentyFiveSoon = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_corruption
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_tailSweepYou, trigger_noxiousBreathYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_dreamFogYou, trigger_noxiousBreathStackYou, trigger_volatileInfectionYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther, trigger_volatileInfectionOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther, trigger_volatileInfectionOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_dreamFogYouFade, trigger_noxiousBreathFade, trigger_volatileInfectionFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_noxiousBreathFade, trigger_volatileInfectionFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_noxiousBreathFade, trigger_volatileInfectionFade
	
	
	self:ThrottleSync(0.1, syncName.noxiousBreath)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacks)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacksFade)
	
	self:ThrottleSync(3, syncName.sporeCloud)
	
	self:ThrottleSync(0.1, syncName.volatileInfection)
	self:ThrottleSync(0.1, syncName.volatileInfectionFade)
	
	self:ThrottleSync(3, syncName.corruption)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.core:IsModuleActive("Ysondre", "Ashenvale") then self.core:DisableModule("Ysondre", "Ashenvale") end
	if self.core:IsModuleActive("Lethon", "Ashenvale") then self.core:DisableModule("Lethon", "Ashenvale") end
	if self.core:IsModuleActive("Taerar", "Ashenvale") then self.core:DisableModule("Taerar", "Ashenvale") end
	--if self.core:IsModuleActive("Emeriss", "Ashenvale") then self.core:DisableModule("Emeriss", "Ashenvale") end
	
	seventyFiveSoon = nil
	fiftySoon = nil
	twentyFiveSoon = nil
	
	if self.db.profile.noxiousbreath then
		self:Bar(L["bar_noxiousBreathCd"], timer.noxiousBreathFirstCd, icon.noxiousBreath, true, color.noxiousBreathCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	
	elseif msg == L["trigger_corruption"] then
		self:Sync(syncName.corruption)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 75 and healthPct <= 80 and seventyFiveSoon == nil and self.db.profile.corruption then
			self:SeventyFiveSoon()
		elseif healthPct > 50 and healthPct <= 55 and fiftySoon == nil and self.db.profile.corruption then
			self:FiftySoon()
		elseif healthPct > 25 and healthPct <= 30 and twentyFiveSoon == nil and self.db.profile.corruption then
			self:TwentyFiveSoon()		
		end
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_noxiousBreathYou"]) then
		self:Sync(syncName.noxiousBreath .. " " .. UnitName("Player"))
	elseif string.find(msg, L["trigger_noxiousBreathOther"]) then
		local _,_,noxiousBreathPlayer = string.find(msg, L["trigger_noxiousBreathOther"])
		self:Sync(syncName.noxiousBreath .. " " .. noxiousBreathPlayer)
	end
	
	if string.find(msg, L["trigger_tailSweepYou"]) and self.db.profile.tailsweep then
		self:TailSweep()
	
	elseif msg == L["trigger_dreamFogYou"] and self.db.profile.dreamfog then
		self:DreamFog()
	elseif msg == L["trigger_dreamFogYouFade"] and self.db.profile.dreamfog then
		self:DreamFogFade()
	
	elseif string.find(msg, L["trigger_noxiousBreathStackYou"]) then
		local _,_,stacksQty,_ = string.find(msg, L["trigger_noxiousBreathStackYou"])
		local stacksPlayer = UnitName("Player")
		local stacksPlayerAndStacksQty = stacksPlayer .. " " .. stacksQty
		self:Sync(syncName.noxiousBreathStacks.." "..stacksPlayerAndStacksQty)
		
	elseif string.find(msg, L["trigger_noxiousBreathStackOther"]) then
		local _,_,stacksPlayer,stacksQty = string.find(msg, L["trigger_noxiousBreathStackOther"])
		local stacksPlayerAndStacksQty = stacksPlayer .. " " .. stacksQty
		self:Sync(syncName.noxiousBreathStacks.." "..stacksPlayerAndStacksQty)
	
	elseif string.find(msg, L["trigger_noxiousBreathFade"]) then
		local _,_,noxiousBreathFadePlayer = string.find(msg, L["trigger_noxiousBreathFade"])
		if noxiousBreathFadePlayer == "you" then noxiousBreathFadePlayer = UnitName("Player") end
		self:Sync(syncName.noxiousBreathStacksFade .. " " .. noxiousBreathFadePlayer)
	
	
	elseif string.find(msg, L["trigger_volatileInfectionYou"]) then
		self:Sync(syncName.volatileInfection .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_volatileInfectionOther"]) then
		local _,_,volatileInfectionPlayer = string.find(msg, L["trigger_volatileInfectionOther"])
		self:Sync(syncName.volatileInfection .. " " .. volatileInfectionPlayer)
	
	elseif string.find(msg, L["trigger_volatileInfectionFade"]) then
		local _,_,volatileInfectionFadePlayer = string.find(msg, L["trigger_volatileInfectionFade"])
		if volatileInfectionFadePlayer == "you" then volatileInfectionFadePlayer = UnitName("Player") end
		self:Sync(syncName.volatileInfectionFade .. " " .. volatileInfectionFadePlayer)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.noxiousBreath and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreath(rest)
	elseif sync == syncName.noxiousBreathStacks and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacks(rest)
	elseif sync == syncName.noxiousBreathStacksFade and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacksFade(rest)
	
	elseif sync == syncName.sporeCloud and rest and self.db.profile.sporecloud then
		self:SporeCloud(rest)
		
	elseif sync == syncName.corruption and self.db.profile.corruption then
		self:Corruption()
	
	elseif sync == syncName.volatileInfection and rest and self.db.profile.volatileinfection then
		self:VolatileInfection(rest)
	elseif sync == syncName.volatileInfectionFade and rest and self.db.profile.volatileinfection then
		self:VolatileInfectionFade(rest)
	end
end


function module:TailSweep()
	self:Message(L["msg_tailSweepYou"], "Personal", false, nil, false)
	self:WarningSign(icon.tailSweep, 1)
end

function module:DreamFog()
	self:Message(L["msg_dreamFogYou"], "Personal", false, nil, false)
	self:WarningSign(icon.dreamFog, timer.dreamFog)
end

function module:DreamFogFade()
	self:RemoveWarningSign(icon.dreamFog)
end

function module:NoxiousBreath(rest)
	self:IntervalBar(L["bar_noxiousBreathCd"], timer.noxiousBreathCd[1], timer.noxiousBreathCd[2], icon.noxiousBreath, true, color.noxiousBreathCd)
	
	if rest == UnitName("Player") then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i.."Target") == "Emeriss" then
				if UnitName("raid"..i.."TargetTarget") ~= UnitName("Player") then
					self:Message(L["msg_noxiousBreathYou"], "Urgent", false, nil, false)
					self:Sound("Beware")
					self:WarningSign(icon.noxiousBreath, 1)
				end
				break
			end
		end
	end
end

function module:NoxiousBreathStacks(rest)
	local stacksPlayer = strsub(rest,0,strfind(rest," ") - 1)
	local stacksQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
	
	if type(stacksQty) == "number" then
		if stacksQty >= 3 then
			for i=1,GetNumRaidMembers() do
				if UnitName("raid"..i) == stacksPlayer then
					self:RemoveBar(stacksPlayer.." ".."3"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."4"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."5"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."6"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."7"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."8"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."9"..L["bar_noxiousBreath"])
					self:RemoveBar(stacksPlayer.." ".."10"..L["bar_noxiousBreath"])

					self:Bar(stacksPlayer.." "..stacksQty..L["bar_noxiousBreath"], timer.noxiousBreathDur, icon.noxiousBreath, true, color.noxiousBreathDur)
					break
				end
			end
		end
	end
end

function module:NoxiousBreathStacksFade(rest)
	self:RemoveBar(rest.." ".."3"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."4"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."5"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."6"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."7"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."8"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."9"..L["bar_noxiousBreath"])
	self:RemoveBar(rest.." ".."10"..L["bar_noxiousBreath"])
end

function module:SporeCloud(rest)

end

function module:Corruption()
	self:Bar(L["bar_corruption"], timer.corruption, icon.corruption, true, color.corruption)
	self:Message(L["msg_corruption"], "Urgent", false, nil, false)
	self:Sound("Alarm")
	self:WarningSign(icon.corruption, 1)
end

function module:SeventyFiveSoon()
	seventyFiveSoon = nil
	self:Message(L["msg_corruptionSoon"])
end

function module:FiftySoon()
	fiftySoon = nil
	self:Message(L["msg_corruptionSoon"])
end

function module:TwentyFiveSoon()
	twentyFiveSoon = nil
	self:Message(L["msg_corruptionSoon"])
end

function module:VolatileInfection(rest)
	self:Bar(rest..L["bar_volatileInfection"], timer.volatileInfection, icon.volatileInfection, true, color.volatileInfection)
	
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" then
		self:Message(rest..L["msg_volatileInfection"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.volatileInfection, 0.7)
	end
end

function module:VolatileInfectionFade(rest)
	self:RemoveBar(rest..L["bar_volatileInfection"])
end
