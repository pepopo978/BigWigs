
local module, L = BigWigs:ModuleDeclaration("Ysondre", "Ashenvale")

module.revision = 30087
module.enabletrigger = module.translatedName
module.toggleoptions = {"tailsweep", "dreamfog", "noxiousbreath", -1, "lightningwave", "summon", -1, "curseofthorns", "silence", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Ashenvale"],
	AceLibrary("Babble-Zone-2.2")["Duskwood"],
	AceLibrary("Babble-Zone-2.2")["The Hinterlands"],
	AceLibrary("Babble-Zone-2.2")["Feralas"]
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ysondre",

	tailsweep_cmd = "tailsweep",
	tailsweep_name = "Tail Sweep Alert",
	tailsweep_desc = "Warn for Tail Sweep",
	
	dreamfog_cmd = "dreamfog",
	dreamfog_name = "Dream Fog Sleep Alert",
	dreamfog_desc = "Warn for Dream Fog Sleep",
	
	noxiousbreath_cmd = "noxiousbreath",
	noxiousbreath_name = "Noxious Breath Alert",
	noxiousbreath_desc = "Warn for Noxious Breath",
	
	lightningwave_cmd = "lightningwave",
	lightningwave_name = "Lightning Wave Alert",
	lightningwave_desc = "Warn for Lightning Wave",
	
	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for Summon",
	
	curseofthorns_cmd = "curseofthorns",
	curseofthorns_name = "Curse of Thorns Alert",
	curseofthorns_desc = "Warn for Curse of Thorns",
	
	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for Silence",


	trigger_engage = "The strands of LIFE have been severed! The Dreamers must be avenged!", --CHAT_MSG_MONSTER_YELL
	
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
	
	trigger_lightningWave = "Ysondre's Lightning Wave hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_lightningWave = "Lightning Wave CD",
	
	--Come forth, ye Dreamers â€“ and claim your vengeance!
		--WTF are those weird chars?
	trigger_summon = "Come forth, you Dreamers - and claim your vengeance!", --CHAT_MSG_MONSTER_YELL
	trigger_summon2 = "Come forth, ye Dreamers", --CHAT_MSG_MONSTER_YELL
	msg_summon = "Demented Druid Spirits - Kill the Adds!",
	msg_summonSoon = "Adds Soon",
	
	
	trigger_curseOfThornsYou = "You are afflicted by Curse of Thorns.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_curseOfThornsOther = "(.+) is afflicted by Curse of Thorns.",  --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE //CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_curseOfThornsFade = "Curse of Thorns fades from (.+).",  --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_curseOfThorns = " Thorns",
	msg_curseOfThorns = " Curse of Thorns - Decurse!",
	
	trigger_silenceYou = "You are afflicted by Silence.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_silenceOther = "(.+)  is afflicted by Silence.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_silenceFade = "Silence fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_silence = " Silenced",
	msg_silence = " Silenced - Dispel!",
} end )

local timer = {
	dreamFog = 5,
	
	noxiousBreathFirstCd = 7,
	noxiousBreathCd = {9,11},
	noxiousBreathDur = 30,
	
	lightningWaveCd = {8.7,11},
	
	curseOfThornsDur = 180,
	
	silenceDur = 6,
}
local icon = {
	tailSweep = "inv_misc_monsterscales_05",
	dreamFog = "spell_nature_sleep",
	noxiousBreath = "spell_shadow_lifedrain02",
	
	lightningWave = "spell_nature_chainlightning",
	summon = "spell_holy_prayerofspirit",
	curseOfThorns = "spell_shadow_antishadow",
	silence = "spell_holy_silence",
}
local color = {
	noxiousBreathCd = "Black",
	noxiousBreathDur = "Red",
	
	lightningWaveCd = "Blue",
	
	curseOfThornsDur = "Magenta",
	
	silenceDur = "White",
}
local syncName = {
	noxiousBreath = "YsondreNoxiousBreath"..module.revision,
	noxiousBreathStacks = "YsondreNoxiousBreathStacks"..module.revision,
	noxiousBreathStacksFade = "YsondreNoxiousBreathStacksFade"..module.revision,
	
	lightningWave = "YsondreLightningWave"..module.revision,
	
	summon = "YsondreSummon"..module.revision,
	
	curseOfThorns = "YsondreCurseOfThorns"..module.revision,
	curseOfThornsFade = "YsondreCurseOfThornsFade"..module.revision,
	
	silence = "YsondreSilence"..module.revision,
	silenceFade = "YsondreSilenceFade"..module.revision,
}

local seventyFiveSoon = nil
local fiftySoon = nil
local twentyFiveSoon = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_summon, trigger_summon2
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_tailSweepYou, trigger_noxiousBreathYou, trigger_lightningWave
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_lightningWave
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_lightningWave
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_dreamFogYou, trigger_noxiousBreathStackYou, trigger_curseOfThornsYou, trigger_silenceYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther, trigger_curseOfThornsOther, trigger_silenceOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther, trigger_curseOfThornsOther, trigger_silenceOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_dreamFogYouFade, trigger_noxiousBreathFade, trigger_curseOfThornsFade, trigger_silenceFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_noxiousBreathFade, trigger_curseOfThornsFade, trigger_silenceFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_noxiousBreathFade, trigger_curseOfThornsFade, trigger_silenceFade
	
	
	self:ThrottleSync(0.1, syncName.noxiousBreath)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacks)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacksFade)
	
	self:ThrottleSync(3, syncName.lightningWave)
	
	self:ThrottleSync(3, syncName.summon)
	
	self:ThrottleSync(0.1, syncName.curseOfThorns)
	self:ThrottleSync(0.1, syncName.curseOfThornsFade)
	
	self:ThrottleSync(0.1, syncName.silence)
	self:ThrottleSync(0.1, syncName.silenceFade)
end

function module:OnSetup()
end

function module:OnEngage()
	--if self.core:IsModuleActive("Ysondre", "Ashenvale") then self.core:DisableModule("Ysondre", "Ashenvale") end
	if self.core:IsModuleActive("Lethon", "Ashenvale") then self.core:DisableModule("Lethon", "Ashenvale") end
	if self.core:IsModuleActive("Taerar", "Ashenvale") then self.core:DisableModule("Taerar", "Ashenvale") end
	if self.core:IsModuleActive("Emeriss", "Ashenvale") then self.core:DisableModule("Emeriss", "Ashenvale") end
	
	seventyFiveSoon = nil
	fiftySoon = nil
	twentyFiveSoon = nil
	
	if self.db.profile.noxiousbreath then
		self:Bar(L["bar_noxiousBreathCd"], timer.noxiousBreathFirstCd, icon.noxiousBreath, true, color.noxiousBreathCd)
	end
	
	if self.db.profile.lightningwave then
		self:IntervalBar(L["bar_lightningWave"], timer.lightningWaveCd[1], timer.lightningWaveCd[2], icon.lightningWave, true, color.lightningWave)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	
	elseif string.find(msg, L["trigger_summon"]) or string.find(msg, L["trigger_summon2"]) then
		self:Sync(syncName.summon)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 75 and healthPct <= 80 and seventyFiveSoon == nil and self.db.profile.summon then
			self:SeventyFiveSoon()
		elseif healthPct > 50 and healthPct <= 55 and fiftySoon == nil and self.db.profile.summon then
			self:FiftySoon()
		elseif healthPct > 25 and healthPct <= 30 and twentyFiveSoon == nil and self.db.profile.summon then
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
		
		
	elseif string.find(msg, L["trigger_lightningWave"]) then
		self:Sync(syncName.lightningWave)
		
		
	elseif string.find(msg, L["trigger_curseOfThornsYou"]) then
		self:Sync(syncName.curseOfThorns .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_curseOfThornsOther"]) then
		local _,_,curseOfThornsPlayer = string.find(msg, L["trigger_curseOfThornsOther"])
		self:Sync(syncName.curseOfThorns .. " " .. curseOfThornsPlayer)
	
	elseif string.find(msg, L["trigger_curseOfThornsFade"]) then
		local _,_,curseOfThornsFadePlayer = string.find(msg, L["trigger_curseOfThornsFade"])
		if curseOfThornsFadePlayer == "you" then curseOfThornsFadePlayer = UnitName("Player") end
		self:Sync(syncName.curseOfThornsFade .. " " .. curseOfThornsFadePlayer)
		
		
	elseif string.find(msg, L["trigger_silenceYou"]) then
		self:Sync(syncName.silence .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_silenceOther"]) then
		local _,_,silencePlayer = string.find(msg, L["trigger_silenceOther"])
		self:Sync(syncName.silence .. " " .. silencePlayer)
	
	elseif string.find(msg, L["trigger_silenceFade"]) then
		local _,_,silenceFadePlayer = string.find(msg, L["trigger_silenceFade"])
		if silenceFadePlayer == "you" then silenceFadePlayer = UnitName("Player") end
		self:Sync(syncName.silenceFade .. " " .. silenceFadePlayer)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.noxiousBreath and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreath(rest)
	elseif sync == syncName.noxiousBreathStacks and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacks(rest)
	elseif sync == syncName.noxiousBreathStacksFade and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacksFade(rest)
	
	elseif sync == syncName.lightningWave and self.db.profile.lightningwave then
		self:LightningWave()
		
	elseif sync == syncName.summon and self.db.profile.summon then
		self:Summon()
	
	elseif sync == syncName.curseOfThorns and rest and self.db.profile.curseofthorns then
		self:CurseOfThorns(rest)
	elseif sync == syncName.curseOfThornsFade and rest and self.db.profile.curseofthorns then
		self:CurseOfThornsFade(rest)
	
	elseif sync == syncName.silence and rest and self.db.profile.silence then
		self:Silence(rest)
	elseif sync == syncName.silenceFade and rest and self.db.profile.silence then
		self:SilenceFade(rest)
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
			if UnitName("raid"..i.."Target") == "Ysondre" then
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

function module:LightningWave()
	self:IntervalBar(L["bar_lightningWave"], timer.lightningWaveCd[1], timer.lightningWaveCd[2], icon.lightningWave, true, color.lightningWaveCd)
end

function module:Summon()
	self:Message(L["msg_summon"], "Urgent", false, nil, false)
	self:Sound("Alarm")
	self:WarningSign(icon.summon, 1)
end

function module:SeventyFiveSoon()
	seventyFiveSoon = nil
	self:Message(L["msg_summonSoon"])
end

function module:FiftySoon()
	fiftySoon = nil
	self:Message(L["msg_summonSoon"])
end

function module:TwentyFiveSoon()
	twentyFiveSoon = nil
	self:Message(L["msg_summonSoon"])
end

function module:CurseOfThorns(rest)
	self:Bar(rest..L["bar_curseOfThorns"], timer.curseOfThornsDur, icon.curseOfThorns, true, color.curseOfThornsDur)
	
	if UnitClass("Player") == "Druid" or UnitClass("Player") == "Mage" then
		self:Message(rest..L["msg_curseOfThorns"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.curseOfThorns, 0.7)
	end
end

function module:CurseOfThornsFade(rest)
	self:RemoveBar(rest..L["bar_curseOfThorns"])
end

function module:Silence(rest)
	self:Bar(rest..L["bar_silence"], timer.silenceDur, icon.silence, true, color.silenceDur)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(rest..L["msg_silence"], "Important", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.silence, 0.7)
	end
end

function module:SilenceFade(rest)
	self:RemoveBar(rest..L["bar_silence"])
end
