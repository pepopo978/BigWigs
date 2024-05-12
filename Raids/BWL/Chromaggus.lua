
local module, L = BigWigs:ModuleDeclaration("Chromaggus", "Blackwing Lair")

module.revision = 30088
module.enabletrigger = module.translatedName
module.toggleoptions = {"frenzy", "enrage", -1, "breath", "vulnerability", "affliction", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Chromaggus",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for Frenzy",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	breath_cmd = "breath",
	breath_name = "Breaths Alert",
	breath_desc = "Warn for Breaths",

	vulnerability_cmd = "vulnerability",
	vulnerability_name = "Vulnerability Alert",
	vulnerability_desc = "Warn for Vulnerability",
	
	affliction_cmd = "affliction",
	affliction_name = "Afflictions Alert",
	affliction_desc = "Warn for Afflictions",
	

	trigger_frenzy = "Chromaggus gains Frenzy.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_frenzyFade = "Frenzy fades from Chromaggus.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_frenzyCd = "Frenzy CD",
	bar_frenzyDur = "Frenzy!",
	msg_frenzy = "Frenzy - Tranq now!",

	msg_lowHp = "Chromaggus under 25% - Enrages soon (at 20%)!",

	trigger_enrage = "Chromaggus gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Chromaggus is Enraged!",


	--5 breaths, 2sec cast time, 30sec between and from start
		--Incinerate
			--3675 Fire Dmg
		--Corrosive Acid
			--875 - 1125 Nature dmg /3sec, -4500 armor, 15sec
		--Frost Burn
			--1750 Frost Dmg, -400% atk speed, 15sec
		--Ignite Flesh
			--657 Fire dmg /3sec, stacks, 60sec
		--Time Lapse
			--Stunned and loses aggro, 8sec (or 6?)

	trigger_breath = "Chromaggus begins to cast (.+).", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_breathCast = "Casting ",
	bar_breathCd = " CD",
	msg_breathSoon5 = " in 5 seconds",
	msg_breathCast = "Casting ",


	trigger_vulnerabilityChanged = "flinches as its skin shimmers.", --CHAT_MSG_MONSTER_EMOTE
	msg_vulnerability = "Current Vulnerability - ",
	bar_vulnerability = " Vulnerability",
	
		-- "^[%w]+[%s's]* ([%w%s:]+) ([%w]+) Chromaggus for ([%d]+) ([%w]+) damage%.[%s%(]*([%d]*)"
		-- [Fashu's] [Firebolt] [hits] Battleguard Sartura for [44] [Fire] damage. ([14] resisted)
		-- spellName: Firebolt; hitOrCrit: hits; dmg: 44; school: Fire; partial: 14
		-- Kan's Life Steal crits Battleguard Sartura for 45 Shadow damage. (15 resisted)
	trigger_directDamage = "^[%w]+[%s's]* ([%w%s:]+) ([%w]+) Chromaggus for ([%d]+) ([%w]+) damage%.[%s%(]*([%d]*)",
	trigger_dotDamage = "^Chromaggus suffers ([%d]+) ([%w]+) damage from [%w]+[%s's]* ([%w%s:]+)%.[%s%(]*([%d]*)",


	--5 afflictions
		--Black
			--inv_misc_head_dragon_black
			--Curse, +100% fire damage taken, 10min
				--if not Ignite Flesh and not Incinerate, don't bother!
		--Blue
			--inv_misc_head_dragon_blue
			--Magic, Burns Mana, 50% slow cast, 30% slow move, 10min
		--Bronze
			--inv_misc_head_dragon_bronze
			--N/A, Random 4sec Stun, 10min
		--Green
			--inv_misc_head_dragon_green
			--Poison, 250dmg/5sec, -50% healing, 10min
		--Red
			--inv_misc_head_dragon_01
			--Disease, 50dmg/3sec, Heals Chromag 150k on death, 10min

	trigger_bronzeYou = "You are afflicted by Brood Affliction: Bronze.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_bronzeYou = "Brood Affliction: Bronze - Consider using Hourglass Sand",
} end )

local timer = {
	frenzyCd = {14.8,17}, --saw 14.829 to 16.995
	frenzyDur = 8,

	breathFirstCd = 30,
	breathCd = 28, --30 - 2sec cast
	breathCast = 2,

	vulnerability = 20,--was 45, changed to 20 in early dec 2023 patch
}
local icon = {
	frenzy = "Ability_Druid_ChallangingRoar",
	tranquil = "Spell_Nature_Drowsy",

	enrage = "Spell_Shadow_UnholyFrenzy",

	breath1 = "INV_Misc_QuestionMark",
	breath2 = "INV_Misc_QuestionMark",
	--breath_unknown = "INV_Misc_QuestionMark",
	breath_corrosiveAcid = "spell_nature_acid_01",
	breath_frostBurn = "spell_frost_chillingblast",
	breath_igniteFlesh = "spell_fire_fire",
	breath_incinerate = "spell_fire_flameshock",
	breath_timeLapse = "spell_arcane_portalorgrimmar",

	--vulnerability_unknown = "INV_Misc_QuestionMark",
	vulnerability_arcane = "spell_nature_starfall",
	vulnerability_fire = "spell_fire_flamebolt",
	vulnerability_frost = "spell_frost_frostbolt02",
	vulnerability_nature = "spell_nature_protectionformnature",
	vulnerability_shadow = "spell_shadow_shadowbolt",

	affliction_black = "inv_misc_head_dragon_black",
	affliction_blue = "inv_misc_head_dragon_blue",
	affliction_bronze = "inv_misc_head_dragon_bronze",
	affliction_green = "inv_misc_head_dragon_green",
	affliction_red = "inv_misc_head_dragon_red",
}
local color = {
	frenzyCd = "Black",
	frenzyDur = "Magenta",

	breath1 = "White",
	breath2 = "White",
	--breath_unknown = "White",
	breath_corrosiveAcid = "Green",
	breath_frostBurn = "Blue",
	breath_igniteFlesh = "Orange",
	breath_incinerate = "Red",
	breath_timeLapse = "Yellow",

	vulnerability_arcane = "Magenta",
	vulnerability_fire = "Red",
	vulnerability_frost = "Blue",
	vulnerability_nature = "Green",
	vulnerability_shadow = "Black",

	affliction = "White",
	--curse = "White",
	--magic = "White",
	--poison = "White",
	--disease = "White",
}
local syncName = {
	frenzy = "ChromaggusFrenzyStart"..module.revision,
	frenzyFade = "ChromaggusFrenzyStop"..module.revision,
	lowHp = "ChromaggusLowHp"..module.revision,
	enrage = "ChromaggusEnrage"..module.revision,

	breath = "ChromaggusBreath2"..module.revision,

	vulnerability = "ChromaggusVulnerability2"..module.revision,

	affliction = "ChromaggusAffliction"..module.revision,
}

local frenzyStartTime = 0
local frenzyEndTime = 0
local lowHp = nil

local breath1 = "???"
local breath2 = "???"
local breathA = true

local currentVulnerability = "???"
local vulnerabilityResetTime = GetTime()

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug

	self:RegisterEvent("UNIT_HEALTH") --lowHp

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE") --trigger_vulnerabilityChanged

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_frenzy, trigger_enrage

	--self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --
	--self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_frenzyFade

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_breath

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_bronzeYou

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_directDamage
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event") --trigger_directDamage
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_directDamage
	self:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE", "Event") --trigger_directDamage

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event") --trigger_dotDamage


	self:ThrottleSync(5, syncName.frenzy)
	self:ThrottleSync(1, syncName.frenzyFade)
	self:ThrottleSync(10, syncName.lowHp)
	self:ThrottleSync(10, syncName.enrage)

	self:ThrottleSync(25, syncName.breath)

	self:ThrottleSync(0.5, syncName.vulnerability)
	
	self:ThrottleSync(1, syncName.affliction)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	frenzyStartTime = 0
	frenzyEndTime = 0
	lowHp = nil
	
	breathA = true
	
	currentVulnerability = "???"
	vulnerabilityResetTime = GetTime()
	
	if self.db.profile.frenzy then
		self:IntervalBar(L["bar_frenzyCd"], timer.frenzyCd[1], timer.frenzyCd[2], icon.frenzy, true, color.frenzyCd)
	end
	
	if self.db.profile.breath then
		self:Bar(breath1..L["bar_breathCd"], timer.breathFirstCd, icon.breath1, true, color.breath1)
		self:DelayedMessage(timer.breathFirstCd - 5, breath1..L["msg_breathSoon5"], "Attention", false, nil, false)
		self:DelayedSound(timer.breathFirstCd - 3, "Three")
		self:DelayedSound(timer.breathFirstCd - 2, "Two")
		self:DelayedSound(timer.breathFirstCd - 1, "One")
		end

	if self.db.profile.vulnerability then
		--self:Bar(currentVulnerability..L["bar_vulnerability"], timer.vulnerability, icon.vulnerability, true, color.vulnerability)
	end
	end

function module:OnDisengage()
end

function module:UNIT_HEALTH( msg )
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 26 and lowHp ~= nil then
			lowHp = nil
		elseif healthPct <= 25 and lowHp == nil then
			self:Sync(syncName.lowHp)
		end
	end
end

function module:CHAT_MSG_MONSTER_EMOTE(msg)
	if string.find(msg, L["trigger_vulnerabilityChanged"]) then
		self:Sync(syncName.vulnerability .. " " .."???")
		end
	end

function module:Event(msg)
	if msg == L["trigger_frenzy"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["trigger_frenzyFade"] then
		self:Sync(syncName.frenzyFade)
	
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_breath"]) then
		local _,_, breath, _ = string.find(msg, L["trigger_breath"])
		self:Sync(syncName.breath .. " " ..breath)
			end
	
	
	
	--check for vulnerability from dots
	if string.find(msg, L["trigger_dotDamage"]) and currentVulnerability == "???" and (GetTime() > (vulnerabilityResetTime + 3)) then
		local _, _, dmg, school, spellName, partial = string.find(msg, L["trigger_dotDamage"])
		if hitOrCrit == nil or dmg == nil or school == nil then return end
		if not type(school) == "string" then return end
		dmg = tonumber(dmg)
		if partial and partial ~= "" then dmg = tonumber(dmg) + tonumber(partial) end
		
		if school == "Arcane" then
			if dmg >= 250 then
				self:Sync(syncName.vulnerability .. " " ..school)
		end
			
		elseif school == "Fire" and not string.find(spellName, "Ignite") then
			if dmg >= 400 then
				self:Sync(syncName.vulnerability .. " " ..school)
	end

		elseif school == "Nature" then
			if dmg >= 300 then
				self:Sync(syncName.vulnerability .. " " ..school)
	end

		elseif school == "Shadow" then
			if string.find(spellName, "Curse of Doom") then
				if dmg >= 3000 then
					self:Sync(syncName.vulnerability .. " " ..school)
					end
				else
				if dmg >= 500 then
					self:Sync(syncName.vulnerability .. " " ..school)
					end
				end
					end
					end
	
	--check for vulnerability from hits / crits
	if string.find(msg, L["trigger_directDamage"]) and currentVulnerability == "???" and (GetTime() > (vulnerabilityResetTime + 3)) then
		local _, _, spellName, hitOrCrit, dmg, school, partial = string.find(msg, L["trigger_directDamage"])
		local hit = nil
		local crit = nil
		if hitOrCrit == nil or dmg == nil or school == nil then return end
		if not type(school) == "string" then return end
		if hitOrCrit == "hits" then hit = true elseif hitOrCrit == "crits" then crit = true end
		dmg = tonumber(dmg)
		if partial and partial ~= "" then dmg = tonumber(dmg) + tonumber(partial) end
		
		if school == "Arcane" then
			if string.find(spellName, "Starfire") then
				if (hit and dmg >= 800) or (crit and dmg >= 1200) then 
					self:Sync(syncName.vulnerability .. " " ..school)
				end
				else
				if (hit and dmg >= 600) or (crit and dmg >= 1200) then 
					self:Sync(syncName.vulnerability .. " " ..school)
					end
				end
			
		elseif school == "Fire" then
			if (hit and dmg >= 1300) or (crit and dmg >= 2600) then 
				self:Sync(syncName.vulnerability .. " " ..school)
						end
		
		elseif school == "Frost" then
			if (hit and dmg >= 800) or (crit and dmg >= 1600) then 
				self:Sync(syncName.vulnerability .. " " ..school)
						end
		
		elseif school == "Nature" then
			if string.find(spellName, "Thunderfury") then
				if (hit and dmg >= 800) or (crit and dmg >= 1200) then 
					self:Sync(syncName.vulnerability .. " " ..school)
					end
				else
				if (hit and dmg >= 900) or (crit and dmg >= 1800) then 
					self:Sync(syncName.vulnerability .. " " ..school)
						end
						end
		
		elseif school == "Shadow" then
			if (hit and dmg >= 1700) or (crit and dmg >= 3400) then 
				self:Sync(syncName.vulnerability .. " " ..school)
					end
				end
			end
	
	
	if msg == L["trigger_bronzeYou"] and self.db.profile.affliction then
		self:BronzeYou()
		end
	end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Frenzy()
	elseif sync == syncName.frenzyFade and self.db.profile.frenzy then
		self:FrenzyFade()

	elseif sync == syncName.lowHp and lowHp == nil then
		self:LowHp()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()

	elseif sync == syncName.vulnerability and rest and self.db.profile.vulnerability then
		self:Vulnerability(rest)

	elseif sync == syncName.breath and rest and self.db.profile.breath then
		self:Breath(rest)
				end
			end


function module:Frenzy()
	self:RemoveBar(L["bar_frenzyCd"])
	
	if UnitClass("Player") == "Hunter" then
		self:Message(L["msg_frenzy"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.tranquil, 1)
						end
	
	self:Bar(L["bar_frenzyDur"], timer.frenzyDur, icon.frenzy, true, color.frenzyDur)
	frenzyStartTime = GetTime()
						end

function module:FrenzyFade()
	self:RemoveBar(L["bar_frenzyDur"])
	self:RemoveWarningSign(icon.tranquil)
	
	frenzyEndTime = GetTime()
	
	self:IntervalBar(L["bar_frenzyCd"], timer.frenzyCd[1] - (frenzyEndTime - frenzyStartTime), timer.frenzyCd[2] - (frenzyEndTime - frenzyStartTime), icon.frenzy, true, color.frenzyCd)
					end

function module:LowHp()
	lowHp = true
	
	if self.db.profile.enrage then
		self:Message(L["msg_lowHp"], "Important", false, nil, false)
						end
						end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:Sound("Beware")
	self:WarningSign(icon.enrage, 0.7)
					end

function module:Breath(rest)
	self:CancelDelayedMessage(breath1..L["msg_breathSoon5"])
	self:CancelDelayedMessage(breath2..L["msg_breathSoon5"])
	self:CancelDelayedSound("Three")
	self:CancelDelayedSound("Two")
	self:CancelDelayedSound("One")
	self:RemoveBar(breath1..L["bar_breathCd"])
	self:RemoveBar(breath2..L["bar_breathCd"])
	
	if breath1 == "???" and breathA then
		breath1 = rest
		if breath1 == "Corrosive Acid" then
			icon.breath1 = icon.breath_corrosiveAcid
			color.breath1 = color.breath_corrosiveAcid
		elseif breath1 == "Frost Burn" then
			icon.breath1 = icon.breath_frostBurn
			color.breath1 = color.breath_frostBurn
		elseif breath1 == "Ignite Flesh" then
			icon.breath1 = icon.breath_igniteFlesh
			color.breath1 = color.breath_igniteFlesh
		elseif breath1 == "Incinerate" then
			icon.breath1 = icon.breath_incinerate
			color.breath1 = color.breath_incinerate
		elseif breath1 == "Time Lapse" then
			icon.breath1 = icon.breath_timeLapse
			color.breath1 = color.breath_timeLapse
				end
		
	elseif breath2 == "???" and not breathA then
		breath2 = rest
		if breath2 == "Corrosive Acid" then
			icon.breath2 = icon.breath_corrosiveAcid
			color.breath2 = color.breath_corrosiveAcid
		elseif breath2 == "Frost Burn" then
			icon.breath2 = icon.breath_frostBurn
			color.breath2 = color.breath_frostBurn
		elseif breath2 == "Ignite Flesh" then
			icon.breath2 = icon.breath_igniteFlesh
			color.breath2 = color.breath_igniteFlesh
		elseif breath2 == "Incinerate" then
			icon.breath2 = icon.breath_incinerate
			color.breath2 = color.breath_incinerate
		elseif breath2 == "Time Lapse" then
			icon.breath2 = icon.breath_timeLapse
			color.breath2 = color.breath_timeLapse
					end
					end
	
	if breathA then
		self:Message(L["msg_breathCast"]..breath1, "Attention", false, nil, false)
		
		self:Bar(L["bar_breathCast"]..breath1, timer.breathCast, icon.breath1, true, color.breath1)
		
		self:DelayedBar(timer.breathCast, breath2..L["bar_breathCd"], timer.breathCd, icon.breath2, true, color.breath2)
		self:DelayedMessage(timer.breathCast + timer.breathCd - 5, breath2..L["msg_breathSoon5"], "Attention", false, nil, false)
		self:DelayedSound(timer.breathCast + timer.breathCd - 3, "Three")
		self:DelayedSound(timer.breathCast + timer.breathCd - 2, "Two")
		self:DelayedSound(timer.breathCast + timer.breathCd - 1, "One")

		breathA = nil
				else
		self:Message(L["msg_breathCast"]..breath2, "Attention", false, nil, false)
		
		self:Bar(L["bar_breathCast"]..breath2, timer.breathCast, icon.breath2, true, color.breath2)
		
		self:DelayedBar(timer.breathCast, breath1..L["bar_breathCd"], timer.breathCd, icon.breath1, true, color.breath1)
		self:DelayedMessage(timer.breathCast + timer.breathCd - 5, breath1..L["msg_breathSoon5"], "Attention", false, nil, false)
		self:DelayedSound(timer.breathCast + timer.breathCd - 3, "Three")
		self:DelayedSound(timer.breathCast + timer.breathCd - 2, "Two")
		self:DelayedSound(timer.breathCast + timer.breathCd - 1, "One")
		
		breathA = true
	end
end

function module:Vulnerability(rest)
	self:RemoveBar(currentVulnerability..L["bar_vulnerability"])
	
	currentVulnerability = rest
	
	if rest == "???" then
		vulnerabilityResetTime = GetTime()
		
		breathA = true
	end
end

function module:Vulnerability(rest)
	self:RemoveBar(currentVulnerability..L["bar_vulnerability"])
	
	currentVulnerability = rest
	
	if rest == "???" then
		vulnerabilityResetTime = GetTime()
	elseif (GetTime() > (vulnerabilityResetTime + 3)) then
		if currentVulnerability == "Arcane" then
			icon.vulnerability = icon.vulnerability_arcane
			color.vulnerability = color.vulnerability_arcane
			if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
				self:WarningSign(icon.vulnerability, 1)
		end

		elseif currentVulnerability == "Fire" then
			icon.vulnerability = icon.vulnerability_fire
			color.vulnerability = color.vulnerability_fire
			if UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" then
				self:WarningSign(icon.vulnerability, 1)
			end

		elseif currentVulnerability == "Frost" then
			icon.vulnerability = icon.vulnerability_frost
			color.vulnerability = color.vulnerability_frost
			if UnitClass("Player") == "Mage" then
				self:WarningSign(icon.vulnerability, 1)
			end
			
		elseif currentVulnerability == "Nature" then
			icon.vulnerability = icon.vulnerability_nature
			color.vulnerability = color.vulnerability_nature
			if UnitClass("Player") == "Shaman" or UnitClass("Player") == "Druid" then
				self:WarningSign(icon.vulnerability, 1)
		end
			
		elseif currentVulnerability == "Shadow" then
			icon.vulnerability = icon.vulnerability_shadow
			color.vulnerability = color.vulnerability_shadow
			if UnitClass("Player") == "Warlock" or UnitClass("Player") == "Priest" then
				self:WarningSign(icon.vulnerability, 1)
			end
		end
		
		self:Bar(currentVulnerability..L["bar_vulnerability"], timer.vulnerability - (GetTime() - vulnerabilityResetTime), icon.vulnerability, true, color.vulnerability)
		
		self:Message(L["msg_vulnerability"]..currentVulnerability, "Positive", false, nil, false)
	end
end

function module:BronzeYou()
	self:WarningSign(icon.affliction_bronze, 1.5)
	self:Message(L["msg_bronzeYou"], "Personal", false, nil, false)
	self:Sound("Info")
end
