
local module, L = BigWigs:ModuleDeclaration("Ragnaros", "Molten Core")

module.revision = 30078
module.enabletrigger = module.translatedName
module.toggleoptions = {"emerge", "wrathofragnaros", "lava", "adds", "melt", "elementalfire", "bosskill"}
module.wipemobs = {"Son of Flame"}
module.defaultDB = {
	adds = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ragnaros",

	emerge_cmd = "emerge",
	emerge_name = "Emerge / Submerge Alert",
	emerge_desc = "Warn for Ragnaros Emerge / Submerge",
	
	wrathofragnaros_cmd = "wrathofragnaros",
	wrathofragnaros_name = "Wrath of Ragnaros (Knockback) Alert",
	wrathofragnaros_desc = "Warn for Wrath of Ragnaros Knockback",
	
	lava_cmd = "lava",
	lava_name = "Touching Lava Alert",
	lava_desc = "Warn for Touching Lava",
	
	adds_cmd = "adds",
	adds_name = "Son of Flame Dies Alert",
	adds_desc = "Warn for Son of Flame Deaths",
	
	melt_cmd = "melt",
	melt_name = "Melt Weapon Alert",
	melt_desc = "Warn for Melt Weapon",
	
	elementalfire_cmd = "elementalfire",
	elementalfire_name = "Elemental Fire Alert",
	elementalfire_desc = "Warn for Elemental Fire",
	

		--74.137
	trigger_domoStart1 = "Imprudent whelps! You've rushed headlong to your own deaths! See now, the master stirs!", --CHAT_MSG_MONSTER_YELL
	bar_domoStart = "Ragnaros Engage",
	msg_domoStart = "Ragnaros RP has started - Tanks, equip your Fire Resist!",
		--58.792
	trigger_domoStart2 = "Behold Ragnaros, the Firelord! He who was ancient when this world was young! Bow before him, mortals! Bow before your ending!", --CHAT_MSG_MONSTER_YELL
		--45.457
	trigger_domoStart3 = "TOO SOON! YOU HAVE AWAKENED ME TOO SOON, EXECUTUS! WHAT IS THE MEANING OF THIS INTRUSION???", --CHAT_MSG_MONSTER_YELL
		--32.144
	trigger_domoStart4 = "These mortal infidels, my lord! They have invaded your sanctum and seek to steal your secrets!", --CHAT_MSG_MONSTER_YELL
		--23.9
	trigger_domoStart5 = "FOOL! YOU ALLOWED THESE INSECTS TO RUN RAMPANT THROUGH THE HALLOWED CORE, AND NOW YOU LEAD THEM TO MY VERY LAIR? YOU HAVE FAILED ME, EXECUTUS! JUSTICE SHALL BE MET, INDEED!", --CHAT_MSG_MONSTER_YELL
		--19:44:21.439
	trigger_engage = "NOW FOR YOU, INSECTS! BOLDLY, YOU SOUGHT THE POWER OF RAGNAROS. NOW YOU SHALL SEE IT FIRSTHAND!", --CHAT_MSG_MONSTER_YELL
	
	trigger_submerge = "COME FORTH, MY SERVANTS! DEFEND YOUR MASTER!", --CHAT_MSG_MONSTER_YELL (to be confirmed)
	trigger_submerge2 = "YOU CANNOT DEFEAT THE LIVING FLAME! COME YOU MINIONS OF FIRE! COME FORTH YOU CREATURES OF HATE! YOUR MASTER CALLS!", --CHAT_MSG_MONSTER_YELL (to be confirmed)
	bar_nextEmerge = "Emerge",
	msg_submerge = "Ragnaros Submerged - Incoming Sons of Flame!",
	
	msg_emergeSoon = "Emerge in 10 seconds!",
	msg_emerge = "Ragnaros Emerged!",
	bar_nextSubmerge = "Submerge",
	msg_submergeSoon = "Submerge in 10 seconds!",
	
		--melee knockback
	trigger_knockback = "TASTE THE FLAMES OF SULFURON!", --CHAT_MSG_MONSTER_YELL
	bar_knockbackCd = "Knockback CD",
	bar_knockbackSoon = "Knockback Soon...",
	msg_knockbackSoon = "Knockback Soon - Melee Out!",
	msg_knockback = "Knockback - Melee In!",
	
	trigger_lavaYou = "You lose (.+) health for swimming in lava.", --CHAT_MSG_COMBAT_SELF_HITS
	msg_lavaYou = "You're standing in lava!",

	msg_addDead = "/8 Son of Flame Dead",
	
	trigger_meltWeapon = "Ragnaros casts Melt Weapon on you: (.+) damaged.", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	bar_melt = "Melt Damage: ",
	
	trigger_elementalFireYou = "You are afflicted by Elemental Fire.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_elementalFireOther = "(.+) is afflicted by Elemental Fire.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE //CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_elementalFireFade = "Elemental Fire fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHERà
	bar_elementalFire = " Elemental Fire",
} end)

local timer = {
	domoStart1 = 74.137,
	domoStart2 = 58.792,
	domoStart3 = 45.457,
	domoStart4 = 32.144,
	domoStart5 = 23.9,
	
	nextEmerge = 90,
	nextSubmerge = 180,
	
	knockbackCd = 25, --supposed to be 25,30
	knockbackSoon = 8,
	
	elementalFire = 8,
}
local icon = {
	domoStart = "inv_misc_pocketwatch_01",
	
	emerge = "ability_stealth",
	submerge = "spell_fire_lavaspawn",
	
	knockback = "ability_smash",
	
	lava = "spell_fire_fire",
	
	elementalFire = "spell_fire_flametounge",
	
	melt = "inv_sword_36",
}
local color = {
	domoStart = "White",
	
	emerge = "White",
	
	knockbackCd = "Black",
	knockbackSoon = "Cyan",
	
	elementalFire = "Red",
	
	melt = "Yellow",
}
local syncName = {
	submerge = "RagnarosSubmerge"..module.revision,
	emerge = "RagnarosEmerge"..module.revision,
	
	knockback = "RagnarosKnockback"..module.revision,
	
	addDead = "RagnarosSonDead"..module.revision,
	
	elementalFire = "RagnarosElementalFire"..module.revision,
	elementalFireFade = "RagnarosElementalFireFade"..module.revision,
}

local addDead = 0

local melt1 = nil
local melt2 = nil
local melt3 = nil

local meltCount1 = 50
local meltCount2 = 50
local meltCount3 = 50

local phase = nil

local lastKnockTime = 0
local submergeTime = 0
local emergeTime = 0

function module:OnRegister()
	self:RegisterEvent("MINIMAP_ZONE_CHANGED")
end

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_domoStart1, 2, 3, 4, 5, trigger_engage
	
	self:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS", "Event") --trigger_lavaYou
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_meltWeapon
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_elementalFireYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_elementalFireOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_elementalFireOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_elementalFireFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_elementalFireFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_elementalFireFade
	
	
	self:ThrottleSync(5, syncName.knockback)
	self:ThrottleSync(5, syncName.submerge)
	self:ThrottleSync(5, syncName.emerge)
	self:ThrottleSync(0.5, syncName.addDead)
	self:ThrottleSync(1, syncName.elementalFire)
	self:ThrottleSync(0.1, syncName.elementalFireFade)
end

function module:OnSetup()
	self.started = nil
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	self:RemoveBar(L["bar_domoStart"])
	
	addDead = 0
	
	melt1 = nil
	melt2 = nil
	melt3 = nil

	meltCount1 = 50
	meltCount2 = 50
	meltCount3 = 50
	
	phase = "emerged"
	
	lastKnockTime = 0
	submergeTime = 0
	emergeTime = 0
end

function module:OnDisengage()
end

function module:MINIMAP_ZONE_CHANGED(msg)
	if GetMinimapZoneText() ~= "Ragnaros' Lair" or self.core:IsModuleActive(module.translatedName) then
		return
	end
	
	self.core:EnableModule(module.translatedName)
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Son of Flame")) then
		addDead = addDead + 1
		if addDead <= 8 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_domoStart1"] then
		self:DomoStart1()
	elseif msg == L["trigger_domoStart2"] then
		self:DomoStart2()
	elseif msg == L["trigger_domoStart3"] then
		self:DomoStart3()
	elseif msg == L["trigger_domoStart4"] then
		self:DomoStart4()
	elseif msg == L["trigger_domoStart5"] then
		self:DomoStart5()
	
	elseif msg == L["trigger_knockback"] then
		self:Sync(syncName.knockback)
	
	elseif msg == L["trigger_submerge"] or msg == L["trigger_submerge2"] then
		self:Sync(syncName.submerge)
	
	elseif string.find(msg, L["trigger_engage"]) then
		self:SendEngageSync()
		
			--old (bad) BigWigs will send bad engage syncs, this is the fix for it
		self:TrueEngage()
	end
end

function module:TrueEngage()
	if self.db.profile.wrathofragnaros then
		self:Bar(L["bar_knockbackCd"], timer.knockbackCd, icon.knockback, true, color.knockbackCd)
		self:DelayedBar(timer.knockbackCd, L["bar_knockbackSoon"], timer.knockbackSoon, icon.knockback, true, color.knockbackSoon)
		
		if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Warlock") then
			self:DelayedWarningSign(timer.knockbackCd - 3, icon.knockback, 10)
			self:DelayedMessage(timer.knockbackCd - 3, L["msg_knockbackSoon"], "Urgent", false, nil, false)
			self:DelayedSound(timer.knockbackCd - 3, "RunAway")
		end
	end
	
	if self.db.profile.emerge then
		self:Bar(L["bar_nextSubmerge"], timer.nextSubmerge, icon.submerge, true, color.emerge)
		self:DelayedMessage(timer.nextSubmerge - 10, L["msg_submergeSoon"], "Attention", false, nil, false)
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_lavaYou"]) and self.db.profile.lava then
		self:LavaYou()
		
	elseif string.find(msg, L["trigger_meltWeapon"]) and self.db.profile.melt then
		local _,_, meltWeapon, _ = string.find(msg, L["trigger_meltWeapon"])
		self:MeltWeapon(meltWeapon)
		
		
	elseif msg == L["trigger_elementalFireYou"] then
		self:Sync(syncName.elementalFire .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_elementalFireOther"]) then
		local _,_, elementalFirePerson, _ = string.find(msg, L["trigger_elementalFireOther"])
		self:Sync(syncName.elementalFire .. " " .. elementalFirePerson)
	
	elseif string.find(msg, L["trigger_elementalFireFade"]) then
		local _,_, elementalFireFadePerson, _ = string.find(msg, L["trigger_elementalFireFade"])
		if elementalFireFadePerson == "you" then elementalFireFadePerson = UnitName("Player") end
		self:Sync(syncName.elementalFireFade .. " " .. elementalFireFadePerson)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.knockback and self.db.profile.wrathofragnaros then
		self:Knockback()

	elseif sync == syncName.submerge then
		self:Submerge()
	elseif sync == syncName.emerge then
		self:Emerge()
	elseif sync == syncName.addDead and rest and self.db.profile.adds then
		self:AddDead(rest)
		
	elseif sync == syncName.elementalFire and rest and self.db.profile.elementalfire then
		self:ElementalFire(rest)
	elseif sync == syncName.elementalFireFade and rest and self.db.profile.elementalfire then
		self:ElementalFireFade(rest)
	end
end


function module:DomoStart1()
	self:Bar(L["bar_domoStart"], timer.domoStart1, icon.domoStart, true, color.domoStart)
	self:Message(L["msg_domoStart"])
end

function module:DomoStart2()
	self:Bar(L["bar_domoStart"], timer.domoStart2, icon.domoStart, true, color.domoStart)
end

function module:DomoStart3()
	self:Bar(L["bar_domoStart"], timer.domoStart3, icon.domoStart, true, color.domoStart)
end

function module:DomoStart4()
	self:Bar(L["bar_domoStart"], timer.domoStart4, icon.domoStart, true, color.domoStart)
end

function module:DomoStart5()
	self:Bar(L["bar_domoStart"], timer.domoStart5, icon.domoStart, true, color.domoStart)
end


function module:Knockback()
	self:RemoveBar(L["bar_knockbackCd"])
	self:CancelDelayedBar(L["bar_knockbackSoon"])
	self:RemoveBar(L["bar_knockbackSoon"])
	self:CancelDelayedWarningSign(icon.knockback)
	self:RemoveWarningSign(icon.knockback)
	self:CancelDelayedMessage(L["msg_knockbackSoon"])
	self:CancelDelayedSound("RunAway")
	
	self:Message(L["msg_knockback"], "Important", false, nil, false)
	
	self:Bar(L["bar_knockbackCd"], timer.knockbackCd, icon.knockback, true, color.knockbackCd)
	self:DelayedBar(timer.knockbackCd, L["bar_knockbackSoon"], timer.knockbackSoon, icon.knockback, true, color.knockbackSoon)
	
	if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Warlock") then
		self:DelayedWarningSign(timer.knockbackCd - 3, icon.knockback, 12)
		self:DelayedMessage(timer.knockbackCd - 3, L["msg_knockbackSoon"], "Urgent", false, nil, false)
		self:DelayedSound(timer.knockbackCd - 3, "RunAway")
	end
	
	lastKnockTime = GetTime()
end

function module:Submerge()
	if UnitName("Player") == "Dreadsome" or UnitName("Player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("   BigWigs_Ragnaros:Debug -- Submerge")
	end
	
	phase = "submerged"
	
		--knockback stuff
	self:RemoveBar(L["bar_knockbackCd"])
	self:CancelDelayedBar(L["bar_knockbackSoon"])
	self:RemoveBar(L["bar_knockbackSoon"])
	self:CancelDelayedWarningSign(icon.knockback)
	self:RemoveWarningSign(icon.knockback)
	self:CancelDelayedMessage(L["msg_knockbackSoon"])
	self:CancelDelayedSound("RunAway")
	
		--submerge stuff
	self:RemoveBar(L["bar_nextSubmerge"])
	self:CancelDelayedMessage(L["msg_submergeSoon"])
	
	submergeTime = GetTime()

	if self.db.profile.emerge then
		self:Message(L["msg_submerge"], "Attention", false, nil, false)

		self:Bar(L["bar_nextEmerge"], timer.nextEmerge, icon.emerge, true, color.emerge)
		self:DelayedMessage(timer.nextEmerge - 10, L["msg_emergeSoon"], "Attention", false, nil, false)
	end
	
	self:ScheduleRepeatingEvent("CheckForEmerge", self.CheckForEmerge, 1, self)
end

function module:Emerge()
	if UnitName("Player") == "Dreadsome" or UnitName("Player") == "Relar" then
		DEFAULT_CHAT_FRAME:AddMessage("   BigWigs_Ragnaros:Debug -- Emerge")
	end
	
	self:CancelScheduledEvent("CheckForEmerge")
	
	phase = "emerged"
	addDead = 0
	emergeTime = GetTime()
	
	self:RemoveBar(L["bar_nextEmerge"])
	self:CancelDelayedMessage(L["msg_emergeSoon"])
	
	if self.db.profile.emerge then
		self:Message(L["msg_emerge"], "Attention", false, nil, false)
		
		self:Bar(L["bar_nextSubmerge"], timer.nextSubmerge, icon.submerge, true, color.emerge)
		self:DelayedMessage(timer.nextSubmerge - 10, L["msg_submergeSoon"], "Attention", false, nil, false)
	end
	
	
	if self.db.profile.wrathofragnaros then
			--possibleTime - elapsedTime = timeLeft
		local knockbackTimeLeft = (timer.knockbackCd + timer.knockbackSoon) - (submergeTime - lastKnockTime)
		
			--if timeLeft is before warn, regular bars with remaining time
		if knockbackTimeLeft > timer.knockbackSoon + 3 then
			self:Bar(L["bar_knockbackCd"], knockbackTimeLeft - timer.knockbackSoon, icon.knockback, true, color.knockbackCd)
			self:DelayedBar(knockbackTimeLeft - timer.knockbackSoon, L["bar_knockbackSoon"], timer.knockbackSoon, icon.knockback, true, color.knockbackSoon)
			
			if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Warlock") then
				self:DelayedWarningSign(knockbackTimeLeft - timer.knockbackSoon - 3, icon.knockback, 12)
				self:DelayedMessage(knockbackTimeLeft - timer.knockbackSoon - 3, L["msg_knockbackSoon"], "Urgent", false, nil, false)
				self:DelayedSound(knockbackTimeLeft - timer.knockbackSoon - 3, "RunAway")
			end			
			
			--if timeLeft is 0, expect knockback right the hell now
		elseif knockbackTimeLeft <= 0 then
			if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Warlock") then
				self:WarningSign(icon.knockback, 12)
				self:Message(L["msg_knockbackSoon"], "Urgent", false, nil, false)
				self:Sound("RunAway")
			end			
			
			--if timeLeft is after warn, warn and only start bar soon
		else
			self:Bar(L["bar_knockbackSoon"], knockbackTimeLeft, icon.knockback, true, color.knockbackSoon)
			
			if not (UnitClass("Player") == "Mage" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Warlock") then
				self:WarningSign(icon.knockback, knockbackTimeLeft + 1)
				self:Message(L["msg_knockbackSoon"], "Urgent", false, nil, false)
				self:Sound("RunAway")
			end
		end
	end
end

function module:CheckForEmerge()
	if UnitExists("Target") and UnitName("Target") == module.translatedName and UnitExists("TargetTarget") and UnitName("TargetTarget") ~= "Majordomo Executus" then
		self:Sync(syncName.emerge)
	else
		for i=1,GetNumRaidMembers() do
			if UnitExists("raid"..i.."Target") and UnitName("raid"..i.."Target") == module.translatedName and UnitExists("raid"..i.."TargetTarget") and UnitName("raid"..i.."TargetTarget") ~= "Majordomo Executus" then
				self:Sync(syncName.emerge)
				break
			end
		end
	end
end

function module:LavaYou()
	self:Message(L["msg_lavaYou"])
	self:WarningSign(icon.lava, 0.7)
	self:Sound("Info")
end

function module:AddDead(rest)
	self:Message(rest..L["msg_addDead"], "Positive", false, nil, false)
	
	if tonumber(rest) == 8 and phase == "submerged" then
		self:Sync(syncName.emerge)
	end
end

function module:MeltWeapon(rest)
	if melt1 == nil then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_melt"]..rest, 50, "Interface\\Icons\\"..icon.melt, true, color.melt)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..rest, (50 - 0.1))
		melt1 = rest
	elseif rest ~= melt1 and melt2 == nil then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_melt"]..rest, 50, "Interface\\Icons\\"..icon.melt, true, color.melt)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..rest, (50 - 0.1))
		melt2 = rest
	elseif rest ~= melt1 and rest ~= melt2 and melt3 == nil then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_melt"]..rest, 50, "Interface\\Icons\\"..icon.melt, true, color.melt)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..rest, (50 - 0.1))
		melt3 = rest
	end
		
	if rest == melt1 then
		meltCount1 = meltCount1 - 1
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..melt1, meltCount1)
	elseif rest == melt2 then
		meltCount2 = meltCount2 - 1
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..melt2, meltCount2)
	elseif rest == melt3 then
		meltCount3 = meltCount3 - 1
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_melt"]..melt3, meltCount3)
	end
end

function module:ElementalFire(rest)
	self:Bar(rest..L["bar_elementalFire"], timer.elementalFire, icon.elementalFire, true, color.elementalFire)
end

function module:ElementalFireFade(rest)
	self:RemoveBar(rest..L["bar_elementalFire"])
end
