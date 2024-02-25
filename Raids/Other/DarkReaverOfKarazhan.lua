
local module, L = BigWigs:ModuleDeclaration("Dark Reaver of Karazhan", "Deadwind Pass")

module.revision = 30051
module.enabletrigger = module.translatedName
module.toggleoptions = {"forlornspirit", "lurkingshadow", -1, "enrage", -1, "deterrence", "nimblereflexes", -1, "unbalancingstrike", "piercearmor", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Deadwind Pass"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "DarkReaverOfKarazhan",

	forlornspirit_cmd = "forlornspirit",
	forlornspirit_name = "Forlorn Spirit adds Alert",
	forlornspirit_desc = "Warn for Forlorn Spirit adds",

	lurkingshadow_cmd = "lurkingshadow",
	lurkingshadow_name = "Lurking Shadow adds Alert",
	lurkingshadow_desc = "Warn for Lurking Shadow adds",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warns for Enrage",
	
	deterrence_cmd = "deterrence",
	deterrence_name = "Deterrence Alert",
	deterrence_desc = "Warns for Deterrence",
	
	nimblereflexes_cmd = "nimblereflexes",
	nimblereflexes_name = "Nimble Reflexes Alert",
	nimblereflexes_desc = "Warns for Nimble Reflexes",
	
	unbalancingstrike_cmd = "unbalancingstrike",
	unbalancingstrike_name = "Unbalancing Strike Alert",
	unbalancingstrike_desc = "Warns for Unbalancing Strike",
	
	piercearmor_cmd = "piercearmor",
	piercearmor_name = "Pierce Armor Alert",
	piercearmor_desc = "Warns for Pierce Armor",
	
	
		--4 adds, yells every 20secs, spawns 2sec * count later (1st = 2sec, 2nd = 4sec, 3rd = 6sec, 4th = 8sec... later)
	trigger_forlornSpiritSpawn = "Spirits, rise, and drive back this rabble!",--CHAT_MSG_MONSTER_YELL
	trigger_forlornSpiritSpawn2 = "Rise, spirits. Defend the Master's lands!",--CHAT_MSG_MONSTER_YELL
	bar_forlornSpiritSpawnCd = "4 Forlorn Spirit",
	msg_forlornSpiritSpawn = "4 Forlorn Spirit Spawned!",
	
		--shaman (no caps)
		--spawns a Lurking Shadow, can be killed by only THAT class
	trigger_lurkingShadowSpawn = "A (.+) shadow appears next to (.+)...",--CHAT_MSG_MONSTER_EMOTE
	bar_lurkingShadowSpawn = "Lurking Shadow",
	-- SHAMAN! --  Lurking Shadow!
	msg_lurkingShadowSpawn = " Lurking Shadow!",
	
	trigger_enrage = "Dark Reaver of Karazhan gains Furious Anger.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	
		--25% dodge and parry, 10sec
	trigger_deterrence = "Dark Reaver of Karazhan gains Deterrence.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_deterrenceFade = "Deterrence fades from Dark Reaver of Karazhan.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_deterrence = "Deterrence 25% Dodge/Parry",
	
		--75% parry, 8sec
	trigger_nimbleReflexes = "Dark Reaver of Karazhan gains Nimble Reflexes.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_nimbleReflexesFade = "Nimble Reflexes fades from Dark Reaver of Karazhan.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_nimbleReflexes = "Reflexes 75% Parry",
	
		--6sec
	trigger_unbalancingStrike = "(.+) is afflicted by Unbalancing Strike.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_unbalancingStrikeYou = "You are afflicted by Unbalancing Strike.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_unbalancingStrikeFade = "Unbalancing Strike fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_unbalancingStrike = " Unbalancing",
	
		-- -50% or -75% armor, 20sec
	trigger_pierceArmor = "(.+) is afflicted by Pierce Armor.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_pierceArmorYou = "You are afflicted by Pierce Armor.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_pierceArmorFade = "Pierce Armor fades from (.+).",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_pierceArmor = " Pierce Armor",

	trigger_engage = "You desecrate the Master's lands with your filthy footsteps!",--CHAT_MSG_MONSTER_YELL
} end )

local timer = {
	--forlornSpiritSpawnCd = 22,
	lurkingShadowSpawn = 10,
	deterrence = 10,
	nimbleReflexes = 8,
	unbalancingStrike = 6,
	pierceArmor = 20,
}
local icon = {
	forlornSpiritSpawnCd = "spell_shadow_burningspirit",
	lurkingShadowSpawn = "ability_creature_poison_05",
	enrage = "Spell_Shadow_UnholyFrenzy",
	deterrence = "ability_whirlwind",
	nimbleReflexes = "ability_meleedamage",
	unbalancingStrike = "ability_warrior_decisivestrike",
	pierceArmor = "spell_shadow_vampiricaura",
}
local color = {
	forlornSpiritSpawnCd = "Black",
	lurkingShadowSpawn = "White",
	deterrence = "Orange",
	nimbleReflexes = "Green",
	unbalancingStrike = "Red",
	pierceArmor = "Blue",
}
local syncName = {
	forlornSpiritSpawn = "DrkForlornSpiritSpawn"..module.revision,
	lurkingShadowSpawn = "DrkLurkingShadowSpawn"..module.revision,
	enrage = "DrkEnrage"..module.revision,
	deterrence = "DrkDeterrence"..module.revision,
	deterrenceFade = "DrkDeterrenceFade"..module.revision,
	nimbleReflexes = "DrkNimbleReflexes"..module.revision,
	nimbleReflexesFade = "DrkNimbleReflexesFade"..module.revision,
	unbalancingStrike = "DrkUnbalancingStrike"..module.revision,
	unbalancingStrikeFade = "DrkUnbalancingStrikeFade"..module.revision,
	pierceArmor = "DrkPierceArmor"..module.revision,
	pierceArmorFade = "DrkPierceArmorFade"..module.revision,
}

local forlornCount = 0

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage, trigger_addsSpawn
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")--trigger_lurkingShadowSpawn
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--trigger_enrage, trigger_deterrence, trigger_nimbleReflexes
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_unbalancingStrikeYou, trigger_pierceArmorYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_unbalancingStrike, trigger_pierceArmor
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_unbalancingStrike, trigger_pierceArmor
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")-- trigger_unbalancingStrikeFade, trigger_pierceArmorFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_unbalancingStrikeFade, trigger_pierceArmorFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_deterrenceFade, trigger_nimbleReflexesFade, trigger_unbalancingStrikeFade, trigger_pierceArmorFade
	
	self:ThrottleSync(10, syncName.forlornSpiritSpawn)
	self:ThrottleSync(1, syncName.lurkingShadowSpawn)
	self:ThrottleSync(3, syncName.enrage)
	self:ThrottleSync(3, syncName.deterrence)
	self:ThrottleSync(3, syncName.deterrenceFade)
	self:ThrottleSync(3, syncName.nimbleReflexes)
	self:ThrottleSync(3, syncName.nimbleReflexesFade)
	self:ThrottleSync(3, syncName.unbalancingStrike)
	self:ThrottleSync(3, syncName.unbalancingStrikeFade)
	self:ThrottleSync(3, syncName.pierceArmor)
	self:ThrottleSync(3, syncName.pierceArmorFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.forlornspirit then
		self:Bar(L["bar_forlornSpiritSpawnCd"], 22, icon.forlornSpiritSpawnCd, true, color.forlornSpiritSpawnCd)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg, sender)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	elseif msg == L["trigger_forlornSpiritSpawn"] or msg == L["trigger_forlornSpiritSpawn2"] then
		self:Sync(syncName.forlornSpiritSpawn)
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg, sender)
	if string.find(msg, L["trigger_lurkingShadowSpawn"]) then
		local _,_, lurkingClass, lurkingPlayer = string.find(msg, L["trigger_lurkingShadowSpawn"])
		self:Sync(syncName.lurkingShadowSpawn .. " " .. lurkingClass)
	end
end

function module:Event(msg)
	if msg == "test" then
		module:SendEngageSync()
	elseif msg == L["trigger_forlornSpiritSpawn"] or msg == L["trigger_forlornSpiritSpawn2"] then
		self:Sync(syncName.forlornSpiritSpawn)
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_deterrence"]) then
		self:Sync(syncName.deterrence)
	elseif string.find(msg, L["trigger_deterrenceFade"]) then
		self:Sync(syncName.deterrenceFade)
		
	elseif string.find(msg, L["trigger_nimbleReflexes"]) then
		self:Sync(syncName.nimbleReflexes)
	elseif string.find(msg, L["trigger_nimbleReflexesFade"]) then
		self:Sync(syncName.nimbleReflexesFade)
	
	
	
	elseif string.find(msg, L["trigger_unbalancingStrike"]) then
		local _,_, unbalTarget, _ = string.find(msg, L["trigger_unbalancingStrike"])
		self:Sync(syncName.unbalancingStrike .. " " .. unbalTarget)
		
	elseif string.find(msg, L["trigger_unbalancingStrikeYou"]) then
		self:Sync(syncName.unbalancingStrike .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_unbalancingStrikeFade"]) then
		local _,_, unbalFadeTarget, _ = string.find(msg, L["trigger_unbalancingStrikeFade"])
		if unbalFadeTarget == "you" then unbalFadeTarget = UnitName("Player") end
		self:Sync(syncName.unbalancingStrikeFade .. " " .. unbalFadeTarget)
		
		
		
	elseif string.find(msg, L["trigger_pierceArmor"]) then
		local _,_, pierceTarget, _ = string.find(msg, L["trigger_pierceArmor"])
		self:Sync(syncName.pierceArmor .. " " .. pierceTarget)
	
	elseif string.find(msg, L["trigger_pierceArmorYou"]) then
		self:Sync(syncName.pierceArmor .. " " .. UnitName("Player"))
		
	elseif string.find(msg, L["trigger_pierceArmorFade"]) then
		local _,_, pierceFadeTarget, _ = string.find(msg, L["trigger_pierceArmorFade"])
		if pierceFadeTarget == "you" then pierceFadeTarget = UnitName("Player") end
		self:Sync(syncName.pierceArmorFade .. " " .. pierceFadeTarget)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.forlornSpiritSpawn and self.db.profile.forlornspirit then
		self:ForlornSpiritSpawn()
	elseif sync == syncName.lurkingShadowSpawn and rest and self.db.profile.lurkingshadow then
		self:LurkingShadowSpawn(rest)
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.deterrence and self.db.profile.deterrence then
		self:Deterrence()
	elseif sync == syncName.deterrenceFade and self.db.profile.deterrence then
		self:DeterrenceFade()
	elseif sync == syncName.nimbleReflexes and self.db.profile.nimblereflexes then
		self:NimbleReflexes()
	elseif sync == syncName.nimbleReflexesFade and self.db.profile.nimblereflexes then
		self:NimbleReflexesFade()
	elseif sync == syncName.unbalancingStrike and rest and self.db.profile.unbalancingstrike then
		self:UnbalancingStrike(rest)
	elseif sync == syncName.unbalancingStrikeFade and rest and self.db.profile.unbalancingstrike then
		self:UnbalancingStrikeFade(rest)
	elseif sync == syncName.pierceArmor and rest and self.db.profile.piercearmor then
		self:PierceArmor(rest)
	elseif sync == syncName.pierceArmorFade and rest and self.db.profile.piercearmor then
		self:PierceArmorFade(rest)	
	end
end


function module:ForlornSpiritSpawn()
	self:RemoveBar(L["bar_forlornSpiritSpawnCd"])
	
	forlornCount = forlornCount + 1
	--on yell, 2 * forlornCount
	self:Bar(L["bar_forlornSpiritSpawnCd"], 2 * forlornCount, icon.forlornSpiritSpawnCd, true, color.forlornSpiritSpawnCd)
	
	--2s delay & 22sec total, 4-24, 6-26, 8-28
	self:DelayedBar(2 * forlornCount, L["bar_forlornSpiritSpawnCd"], 20, icon.forlornSpiritSpawnCd, true, color.forlornSpiritSpawnCd)
	self:DelayedMessage(2 * forlornCount, L["msg_forlornSpiritSpawn"], "Positive", false, nil, false)
end

function module:LurkingShadowSpawn(rest)
	self:Bar(rest.." "..L["bar_lurkingShadowSpawn"].." >Click Me!<", timer.lurkingShadowSpawn, icon.lurkingShadowSpawn, true, color.lurkingShadowSpawn)
	self:SetCandyBarOnClick("BigWigsBar "..rest.." "..L["bar_lurkingShadowSpawn"].." >Click Me!<", function(name, button, extra) TargetByName(extra, true) end, "Lurking Shadow")
	
	self:Message(rest..L["msg_lurkingShadowSpawn"], "Attention", false, nil, false)
	
	if string.lower(UnitClass("Player")) == rest then
		self:Sound("Beware")
		self:WarningSign(icon.lurkingShadowSpawn, 1)
	end
end

function module:Enrage()
	self:WarningSign(icon.enrage, 0.7)
end

function module:Deterrence()
	self:Bar(L["bar_deterrence"], timer.deterrence, icon.deterrence, true, color.deterrence)
end

function module:DeterrenceFade()
	self:RemoveBar(L["bar_deterrence"])
end

function module:NimbleReflexes()
	self:Bar(L["bar_nimbleReflexes"], timer.nimbleReflexes, icon.nimbleReflexes, true, color.nimbleReflexes)
end

function module:NimbleReflexesFade()
	self:RemoveBar(L["bar_nimbleReflexes"])
end

function module:UnbalancingStrike(rest)
	self:Bar(rest..L["bar_unbalancingStrike"], timer.unbalancingStrike, icon.unbalancingStrike, true, color.unbalancingStrike)
end

function module:UnbalancingStrikeFade(rest)
	self:RemoveBar(rest..L["bar_unbalancingStrike"])
end

function module:PierceArmor(rest)
	self:Bar(rest..L["bar_pierceArmor"], timer.pierceArmor, icon.pierceArmor, true, color.pierceArmor)
end

function module:PierceArmorFade(rest)
	self:RemoveBar(rest..L["bar_pierceArmor"])
end
