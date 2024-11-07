
local module, L = BigWigs:ModuleDeclaration("Taerar", "Ashenvale")

module.revision = 30087
module.enabletrigger = module.translatedName
module.toggleoptions = {"tailsweep", "dreamfog", "noxiousbreath", -1, "fear", "arcaneblast", "summon", -1, "poisoncloud", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Ashenvale"],
	AceLibrary("Babble-Zone-2.2")["Duskwood"],
	AceLibrary("Babble-Zone-2.2")["The Hinterlands"],
	AceLibrary("Babble-Zone-2.2")["Feralas"]
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Taerar",

	tailsweep_cmd = "tailsweep",
	tailsweep_name = "Tail Sweep Alert",
	tailsweep_desc = "Warn for Tail Sweep",
	
	dreamfog_cmd = "dreamfog",
	dreamfog_name = "Dream Fog Sleep Alert",
	dreamfog_desc = "Warn for Dream Fog Sleep",
	
	noxiousbreath_cmd = "noxiousbreath",
	noxiousbreath_name = "Noxious Breath Alert",
	noxiousbreath_desc = "Warn for Noxious Breath",
	
	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for Fear",
	
	arcaneblast_cmd = "arcaneblast",
	arcaneblast_name = "Arcane Blast Alert",
	arcaneblast_desc = "Warn for Arcane Blast",
	
	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for Summon",
	
	poisoncloud_cmd = "poisoncloud",
	poisoncloud_name = "Poison Cloud Alert",
	poisoncloud_desc = "Warn for Poison Cloud",


	trigger_engage = "Peace is but a fleeting dream! Let the NIGHTMARE reign!", --CHAT_MSG_MONSTER_YELL
	
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
	
	trigger_fear = "Taerar begins to cast Bellowing Roar.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fearCast = "Fear!",
	bar_fearCd = "Fear CD",
	
	trigger_arcaneBast = "Taerar's Arcane Blast", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_arcaneBlast = "Arcane Blast CD",
	
	trigger_summon = "Children of Madness - I release you upon this world!", --CHAT_MSG_MONSTER_YELL
	msg_summon = "3 Shades of Taerar - Kill the Adds!",
	msg_summonSoon = "Adds Soon",
	msg_shadeDead = "/3 Shade of Tarear Dead",
	
	trigger_poisonCloud = "You are afflicted by Poison Cloud.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_poisonCloudFade = "Poison Cloud fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_poisonCloud = "Move away from the Poison Cloud!",
} end )

local timer = {
	dreamFog = 5,
	
	noxiousBreathFirstCd = 7,
	noxiousBreathCd = {9,11},
	noxiousBreathDur = 30,
	
	fearFirstCd = 20,
	fearCd = 30,
	fearCast = 1.5,
	
	arcaneBlast = {10,12},
	
	poisonCloud = 10,
}
local icon = {
	tailSweep = "inv_misc_monsterscales_05",
	dreamFog = "spell_nature_sleep",
	noxiousBreath = "spell_shadow_lifedrain02",
	
	fear = "spell_shadow_charm",
	arcaneBlast = "spell_shadow_deathpact",
	summon = "spell_holy_prayerofspirit",
	poisonCloud = "spell_nature_naturetouchdecay",
}
local color = {
	noxiousBreathCd = "Black",
	noxiousBreathDur = "Red",
	
	fearCd = "Cyan",
	fearCast = "Blue",
	
	arcaneBlast = "Magenta"
}
local syncName = {
	noxiousBreath = "TaerarNoxiousBreath"..module.revision,
	noxiousBreathStacks = "TaerarNoxiousBreathStacks"..module.revision,
	noxiousBreathStacksFade = "TaerarNoxiousBreathStacksFade"..module.revision,
	
	fear = "Taerarfear"..module.revision,
	
	arcaneBlast = "TaerarArcaneBlast"..module.revision,
	
	summon = "TaerarSummon"..module.revision,
	shadeDead = "TaerarShadeDead"..module.revision,
}

local seventyFiveSoon = nil
local fiftySoon = nil
local twentyFiveSoon = nil
local shadeDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_summon
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_tailSweepYou, trigger_noxiousBreathYou, trigger_arcaneBast
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_arcaneBast
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_fear, trigger_arcaneBast
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_dreamFogYou, trigger_noxiousBreathStackYou, trigger_poisonCloud
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_noxiousBreathOther, trigger_noxiousBreathStackOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_dreamFogYouFade, trigger_noxiousBreathFade, trigger_poisonCloudFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_noxiousBreathFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_noxiousBreathFade
	
	
	self:ThrottleSync(0.1, syncName.noxiousBreath)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacks)
	self:ThrottleSync(0.1, syncName.noxiousBreathStacksFade)
	
	self:ThrottleSync(3, syncName.fear)
	self:ThrottleSync(3, syncName.arcaneBlast)
	
	self:ThrottleSync(3, syncName.summon)
	self:ThrottleSync(0.5, syncName.shadeDead)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.core:IsModuleActive("Ysondre", "Ashenvale") then self.core:DisableModule("Ysondre", "Ashenvale") end
	if self.core:IsModuleActive("Lethon", "Ashenvale") then self.core:DisableModule("Lethon", "Ashenvale") end
	--if self.core:IsModuleActive("Taerar", "Ashenvale") then self.core:DisableModule("Taerar", "Ashenvale") end
	if self.core:IsModuleActive("Emeriss", "Ashenvale") then self.core:DisableModule("Emeriss", "Ashenvale") end
	
	seventyFiveSoon = nil
	fiftySoon = nil
	twentyFiveSoon = nil
	shadeDead = 0
	
	if self.db.profile.noxiousbreath then
		self:Bar(L["bar_noxiousBreathCd"], timer.noxiousBreathFirstCd, icon.noxiousBreath, true, color.noxiousBreathCd)
	end
	
	if self.db.profile.fear then
		self:Bar(L["bar_fearCd"], timer.fearFirstCd, icon.fear, true, color.fearCd)
	end
	
	if self.db.profile.arcaneblast then
		self:IntervalBar(L["bar_arcaneBlast"], timer.arcaneBlast[1], timer.arcaneBlast[2], icon.arcaneBlast, true, color.arcaneBlast)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Shade of Taerar")) then
		shadeDead = shadeDead + 1
		if shadeDead <= 3 then
			self:Sync(syncName.shadeDead .. " " .. shadeDead)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()
	
	elseif msg == L["trigger_summon"] then
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
		
		
	elseif msg == L["trigger_fear"] then
		self:Sync(syncName.fear)
		
	elseif string.find(msg, L["trigger_arcaneBast"]) then
		self:Sync(syncName.arcaneBlast)
		
	elseif msg == L["trigger_poisonCloud"] and self.db.profile.poisoncloud then
		self:PoisonCloud()
		
	elseif msg == L["trigger_poisonCloudFade"] and self.db.profile.poisoncloud then
		self:PoisonCloudFade()
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.noxiousBreath and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreath(rest)
	elseif sync == syncName.noxiousBreathStacks and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacks(rest)
	elseif sync == syncName.noxiousBreathStacksFade and rest and self.db.profile.noxiousbreath then
		self:NoxiousBreathStacksFade(rest)
	
	elseif sync == syncName.fear and self.db.profile.fear then
		self:fear()
		
	elseif sync == syncName.arcaneBlast and self.db.profile.arcaneblast then
		self:ArcaneBlast()
		
	elseif sync == syncName.summon and self.db.profile.summon then
		self:Summon()
	elseif sync == syncName.shadeDead and rest and self.db.profile.summon then
		self:ShadeDead(rest)
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
			if UnitName("raid"..i.."Target") == "Taerar" then
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

function module:fear()
	self:RemoveBar(L["bar_fearCd"])
	
	self:Bar(L["bar_fearCast"], timer.fearCast, icon.fear, true, color.fearCast)
	self:WarningSign(icon.fear, timer.fearCast)
	self:Sound("Beware")
	
	self:DelayedBar(timer.fearCast, L["bar_fearCd"], timer.fearCd, icon.fear, true, color.fearCd)
end

function module: ArcaneBlast()
	self:IntervalBar(L["bar_arcaneBlast"], timer.arcaneBlast[1], timer.arcaneBlast[2], icon.arcaneBlast, true, color.arcaneBlast)
end

function module:Summon()
	shadeDead = 0
	
	self:RemoveBar(L["bar_fearCd"])
	self:RemoveBar(L["bar_fearCast"])
	self:RemoveBar(L["bar_noxiousBreathCd"])
	self:RemoveBar(L["bar_arcaneBlast"])
	
	self:Message(L["msg_summon"], "Urgent", false, nil, false)
	self:Sound("Alarm")
	self:WarningSign(icon.summon, 1)
end

function module:ShadeDead(rest)
	self:Message(rest..L["msg_shadeDead"], "Positive", false, nil, false)
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

function module:PoisonCloud()
	self:Message(L["msg_poisonCloud"], "Attention", false, nil, false)
	self:Sound("Info")
	self:WarningSign(icon.poisonCloud, timer.poisonCloud)
end

function module:PoisonCloudFade()
	self:RemoveWarningSign(icon.poisonCloud)
end
