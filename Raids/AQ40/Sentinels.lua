
local module, L = BigWigs:ModuleDeclaration("Anubisath Sentinel", "Ahn'Qiraj")

module.revision = 30082
module.enabletrigger = module.translatedName
module.toggleoptions = {"abilities", "selfreflect"}
module.trashMod = true
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Sentinel",
	
	abilities_cmd = "abilities",
	abilities_name = "Abilities Alert",
	abilities_desc = "Warn for Abilities",
	
	selfreflect_cmd = "selfreflect",
	selfreflect_name = "Reflecting Spells on Self Alert",
	selfreflect_desc = "Warn for Spells being Reflected back at you.",
	
	
	bar_knockBack = " has Knockback",
    buffIcon_knockBack = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
	
	bar_manaBurn = " has Mana Burn",
    buffIcon_manaBurn = "Interface\\Icons\\Spell_Shadow_ManaBurn",
	
	bar_mending = " has Mending",
    buffIcon_mending = "Interface\\Icons\\Spell_Nature_ResistNature",
	
	bar_mortalStrike = " has Mortal Strike",
    buffIcon_mortalStrike = "Interface\\Icons\\Ability_Warrior_SavageBlow",
	
	bar_shadowStorm = " has Shadow Storm",
    buffIcon_shadowStorm = "Interface\\Icons\\Spell_Shadow_Haunting",
	
	bar_thorns = " has Thorns",
    buffIcon_thorns = "Interface\\Icons\\Spell_Nature_Thorns",
	
	bar_thunderClap = " has Thunderclap",
	buffIcon_thunderClap = "Interface\\Icons\\Ability_ThunderClap",   

	trigger_fireArcaneReflect1 = "Your Moonfire is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflect2 = "Your Scorch is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflect3 = "Your Flame Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflect4 = "Your Fireball is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflect5 = "Your Flame Lash is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflect6 = "Your Detect Magic is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_fireArcaneReflectOther = "(.+)'s Detect Magic is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE
	bar_fireArcaneReflect = " reflect Fire & Arcane",
		--not used for TurtleWoW
	--buffIcon_fireArcaneReflect = "nil",
	
	trigger_shadowFrostReflect1 = "Your Shadow Word: Pain is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect2 = "Your Corruption is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect3 = "Your Frostbolt is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect4 = "Your Frost Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflectOther = "(.+)'s Corruption is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE
	bar_shadowFrostReflect = " reflect Shadow & Frost",
		--not used for TurtleWoW
	--buffIcon_shadowFrostReflect = "Interface\\Icons\\Spell_Arcane_Blink",
	
	trigger_selfReflect = "Your (.*) is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_SELF_DAMAGE
	msg_selfReflect = "STOP KILLING YOURSELF!",
	
	["You have slain %s!"] = true,
} end )

local timer = {
	knockBack = 600,
	manaBurn = 600,
	mending = 600,
	mortalStrike = 600,
	shadowStorm = 600,
	thorns = 600,
	thunderClap = 600,
	fireArcaneReflect = 600,
	shadowFrostReflect = 600,
}
local icon = {
	knockBack = "Inv_Gauntlets_05",
	manaBurn = "Spell_Shadow_Manaburn",
	mending = "spell_nature_resistnature",
	mortalStrike = "ability_warrior_savageblow",
	shadowStorm = "spell_shadow_shadowbolt",
	thorns = "Spell_Nature_Thorns",
	thunderClap = "Ability_ThunderClap",
	fireArcaneReflect = "spell_arcane_portaldarnassus",
	shadowFrostReflect = "spell_arcane_portalundercity",
}
local color = {
	knockBack = "yellow",
	manaBurn = "red",
	mending = "green",
	mortalStrike = "yellow",
	shadowStorm = "red",
	thorns = "orange",
	thunderClap = "orange",
	fireArcaneReflect = "yellow",
	shadowFrostReflect = "yellow",
}
local syncName = {
	knockBack = "SentinelKnockback"..module.revision,
	manaBurn = "SentinelManaburn"..module.revision,
	mending = "SentinelMend"..module.revision,
	mortalStrike = "SentinelMortalstrike"..module.revision,
	shadowStorm = "SentinelShadowstorm"..module.revision,
	thorns = "SentinelThorns"..module.revision,
	thunderClap = "SentinelThunderclap"..module.revision,
	fireArcaneReflect = "SentinelArcref2"..module.revision,
	shadowFrostReflect = "SentinelSharef2"..module.revision,
	
	addDead = "SentinelAddDead"..module.revision,
}

local raidIcon_knockBack = 2
local raidIcon_manaBurn = 4
local raidIcon_mending = 8
local raidIcon_mortalStrike = 6
local raidIcon_thorns = 7
local raidIcon_thunderClap = 3
local raidIcon_shadowStorm = 5
local raidIcon_fireArcaneReflect = "No Icon"
local raidIcon_shadowFrostReflect = 1

local knockBackFound = nil
local manaBurnFound = nil
local mendingFound = nil
local mortalStrikeFound = nil
local shadowStormFound = nil
local thornsFound = nil
local thunderClapFound = nil
local fireArcaneReflectFound = nil
local shadowFrostReflectFound = nil

local addDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") --trigger_selfReflect, reflect type detection
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event") --reflect type detection
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event") --reflect type detection
	
	
	self:ThrottleSync(5, syncName.knockBack)
	self:ThrottleSync(5, syncName.manaBurn)
	self:ThrottleSync(5, syncName.mending)
	self:ThrottleSync(5, syncName.mortalStrike)
	self:ThrottleSync(5, syncName.shadowStorm)
	self:ThrottleSync(5, syncName.thorns)
	self:ThrottleSync(5, syncName.thunderClap)
	self:ThrottleSync(5, syncName.fireArcaneReflect)
	self:ThrottleSync(5, syncName.shadowFrostReflect)
	
	self:ThrottleSync(3, syncName.addDead)
end

function module:OnSetup()
	self.started = nil
	
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	addDead = 0
	
	self:ResetAllBars()
	
	raidIcon_knockBack = 2
	raidIcon_manaBurn = 4
	raidIcon_mending = 8
	raidIcon_mortalStrike = 6
	raidIcon_thorns = 7
	raidIcon_thunderClap = 3
	raidIcon_shadowStorm = 5
	raidIcon_fireArcaneReflect = "No Icon"
	raidIcon_shadowFrostReflect = 1
	
	knockBackFound = nil
	manaBurnFound = nil
	mendingFound = nil
	mortalStrikeFound = nil
	shadowStormFound = nil
	thornsFound = nil
	thunderClapFound = nil
	fireArcaneReflectFound = nil
	shadowFrostReflectFound = nil
	
	self:ScheduleRepeatingEvent("AbilitiesScan", self.AbilitiesScan, 0.5, self)
end

function module:ResetAllBars()
	self:RemoveBar("No Icon"..L["bar_knockBack"])
	self:RemoveBar("Star"..L["bar_knockBack"])
	self:RemoveBar("Circle"..L["bar_knockBack"])
	self:RemoveBar("Diamond"..L["bar_knockBack"])
	self:RemoveBar("Triangle"..L["bar_knockBack"])
	self:RemoveBar("Moon"..L["bar_knockBack"])
	self:RemoveBar("Square"..L["bar_knockBack"])
	self:RemoveBar("X"..L["bar_knockBack"])
	self:RemoveBar("Skull"..L["bar_knockBack"])
	
	self:RemoveBar("No Icon"..L["bar_manaBurn"])
	self:RemoveBar("Star"..L["bar_manaBurn"])
	self:RemoveBar("Circle"..L["bar_manaBurn"])
	self:RemoveBar("Diamond"..L["bar_manaBurn"])
	self:RemoveBar("Triangle"..L["bar_manaBurn"])
	self:RemoveBar("Moon"..L["bar_manaBurn"])
	self:RemoveBar("Square"..L["bar_manaBurn"])
	self:RemoveBar("X"..L["bar_manaBurn"])
	self:RemoveBar("Skull"..L["bar_manaBurn"])
	
	self:RemoveBar("No Icon"..L["bar_mending"])
	self:RemoveBar("Star"..L["bar_mending"])
	self:RemoveBar("Circle"..L["bar_mending"])
	self:RemoveBar("Diamond"..L["bar_mending"])
	self:RemoveBar("Triangle"..L["bar_mending"])
	self:RemoveBar("Moon"..L["bar_mending"])
	self:RemoveBar("Square"..L["bar_mending"])
	self:RemoveBar("X"..L["bar_mending"])
	self:RemoveBar("Skull"..L["bar_mending"])
	
	self:RemoveBar("No Icon"..L["bar_mortalStrike"])
	self:RemoveBar("Star"..L["bar_mortalStrike"])
	self:RemoveBar("Circle"..L["bar_mortalStrike"])
	self:RemoveBar("Diamond"..L["bar_mortalStrike"])
	self:RemoveBar("Triangle"..L["bar_mortalStrike"])
	self:RemoveBar("Moon"..L["bar_mortalStrike"])
	self:RemoveBar("Square"..L["bar_mortalStrike"])
	self:RemoveBar("X"..L["bar_mortalStrike"])
	self:RemoveBar("Skull"..L["bar_mortalStrike"])
	
	self:RemoveBar("No Icon"..L["bar_shadowStorm"])
	self:RemoveBar("Star"..L["bar_shadowStorm"])
	self:RemoveBar("Circle"..L["bar_shadowStorm"])
	self:RemoveBar("Diamond"..L["bar_shadowStorm"])
	self:RemoveBar("Triangle"..L["bar_shadowStorm"])
	self:RemoveBar("Moon"..L["bar_shadowStorm"])
	self:RemoveBar("Square"..L["bar_shadowStorm"])
	self:RemoveBar("X"..L["bar_shadowStorm"])
	self:RemoveBar("Skull"..L["bar_shadowStorm"])
	
	self:RemoveBar("No Icon"..L["bar_thorns"])
	self:RemoveBar("Star"..L["bar_thorns"])
	self:RemoveBar("Circle"..L["bar_thorns"])
	self:RemoveBar("Diamond"..L["bar_thorns"])
	self:RemoveBar("Triangle"..L["bar_thorns"])
	self:RemoveBar("Moon"..L["bar_thorns"])
	self:RemoveBar("Square"..L["bar_thorns"])
	self:RemoveBar("X"..L["bar_thorns"])
	self:RemoveBar("Skull"..L["bar_thorns"])
	
	self:RemoveBar("No Icon"..L["bar_thunderClap"])
	self:RemoveBar("Star"..L["bar_thunderClap"])
	self:RemoveBar("Circle"..L["bar_thunderClap"])
	self:RemoveBar("Diamond"..L["bar_thunderClap"])
	self:RemoveBar("Triangle"..L["bar_thunderClap"])
	self:RemoveBar("Moon"..L["bar_thunderClap"])
	self:RemoveBar("Square"..L["bar_thunderClap"])
	self:RemoveBar("X"..L["bar_thunderClap"])
	self:RemoveBar("Skull"..L["bar_thunderClap"])
	
	self:RemoveBar("No Icon"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Star"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Circle"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Diamond"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Triangle"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Moon"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Square"..L["bar_fireArcaneReflect"])
	self:RemoveBar("X"..L["bar_fireArcaneReflect"])
	self:RemoveBar("Skull"..L["bar_fireArcaneReflect"])
	
	self:RemoveBar("No Icon"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Star"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Circle"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Diamond"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Triangle"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Moon"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Square"..L["bar_shadowFrostReflect"])
	self:RemoveBar("X"..L["bar_shadowFrostReflect"])
	self:RemoveBar("Skull"..L["bar_shadowFrostReflect"])
end

function module:OnDisengage()
	self:ResetAllBars()
	self:CancelScheduledEvent("AbilitiesScan")
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	--BigWigs:CheckForBossDeath(msg, self)

	if (msg == string.format(UNITDIESOTHER, "Anubisath Sentinel")) then
		addDead = addDead + 1
		if addDead <= 4 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	end
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("Target") and UnitAffectingCombat("Target") then
				local target = UnitName("Target")
				for _, mob in pairs(t) do
					if target == mob then
						return true
					end
				end
			end

			local num = GetNumRaidMembers()
			for i = 1, num do
				local raidUnit = string.format("raid%starget", i)
				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
					local target = UnitName(raidUnit)
					for _, mob in pairs(t) do
						if target == mob then
							return true
						end
					end
				end
			end
			return false
		end

		if not IsBossInCombat() then
			self:SendBossDeathSync()
			self:TriggerEvent("BigWigs_RebootModule", module.translatedName)
		end
	end
end

function module:Event(msg)
	if msg == "add" then
		addDead = addDead + 1
		if addDead <= 4 then
			self:Sync(syncName.addDead .. " " .. addDead)
		end
	end
	--debug
	
	if string.find(msg, L["trigger_selfReflect"]) and self.db.profile.selfreflect and not (string.find(msg, "Elemental Vulnerability") or string.find(msg, "Fire Strike")) then
		self:SelfReflect()
	end
	
	
	-- Arcane Reflect
	if fireArcaneReflectFound == nil and UnitName("Target") == "Anubisath Sentinel" and
		string.find(msg, L["trigger_fireArcaneReflect1"]) or
	string.find(msg, L["trigger_fireArcaneReflect2"]) or
	string.find(msg, L["trigger_fireArcaneReflect3"]) or
	string.find(msg, L["trigger_fireArcaneReflect4"]) or
	string.find(msg, L["trigger_fireArcaneReflect5"]) or
	string.find(msg, L["trigger_fireArcaneReflect6"]) then
		if GetRaidTargetIndex("Target") == nil	then raidIcon_fireArcaneReflect = "No Icon"		end
		if GetRaidTargetIndex("Target") == 1	then raidIcon_fireArcaneReflect = "Star"		end
		if GetRaidTargetIndex("Target") == 2	then raidIcon_fireArcaneReflect = "Circle"		end
		if GetRaidTargetIndex("Target") == 3	then raidIcon_fireArcaneReflect = "Diamond"		end
		if GetRaidTargetIndex("Target") == 4	then raidIcon_fireArcaneReflect = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5	then raidIcon_fireArcaneReflect = "Moon"		end
		if GetRaidTargetIndex("Target") == 6	then raidIcon_fireArcaneReflect = "Square"		end
		if GetRaidTargetIndex("Target") == 7	then raidIcon_fireArcaneReflect = "Cross"		end
		if GetRaidTargetIndex("Target") == 8	then raidIcon_fireArcaneReflect = "Skull"		end
		self:Sync(syncName.fireArcaneReflect .. " "..raidIcon_fireArcaneReflect)
	
	elseif fireArcaneReflectFound == nil and UnitName("Target") == "Anubisath Sentinel" and string.find(msg, L["trigger_fireArcaneReflectOther"]) then
		local _,_, arcaneFireReflectPerson, _ = string.find(msg, L["trigger_fireArcaneReflectOther"])
		for i=1,GetNumRaidMembers() do
			if UnitName("Raid"..i) == arcaneFireReflectPerson then
				if UnitName("Raid"..i.."Target") == "Anubisath Sentinel" then
					if GetRaidTargetIndex("Raid"..i.."Target")== nil then raidIcon_fireArcaneReflect = "No Icon"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 1	then raidIcon_fireArcaneReflect = "Star"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 2	then raidIcon_fireArcaneReflect = "Circle"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 3	then raidIcon_fireArcaneReflect = "Diamond"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 4	then raidIcon_fireArcaneReflect = "Triangle"	end
					if GetRaidTargetIndex("Raid"..i.."Target")== 5	then raidIcon_fireArcaneReflect = "Moon"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 6	then raidIcon_fireArcaneReflect = "Square"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 7	then raidIcon_fireArcaneReflect = "Cross"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 8	then raidIcon_fireArcaneReflect = "Skull"		end
				end
				break
			end
		end
		self:Sync(syncName.fireArcaneReflect .. " "..raidIcon_fireArcaneReflect)
		
	
	-- Shadow Reflect
	elseif shadowFrostReflectFound == nil and UnitName("Target") == "Anubisath Sentinel" and
		string.find(msg, L["trigger_shadowFrostReflect1"]) or
	string.find(msg, L["trigger_shadowFrostReflect2"]) or
	string.find(msg, L["trigger_shadowFrostReflect3"]) or
	string.find(msg, L["trigger_shadowFrostReflect4"]) then
		if GetRaidTargetIndex("Target") == nil	then raidIcon_shadowFrostReflect = "No Icon"	end
		if GetRaidTargetIndex("Target") == 1	then raidIcon_shadowFrostReflect = "Star"		end
		if GetRaidTargetIndex("Target") == 2	then raidIcon_shadowFrostReflect = "Circle"		end
		if GetRaidTargetIndex("Target") == 3	then raidIcon_shadowFrostReflect = "Diamond"	end
		if GetRaidTargetIndex("Target") == 4	then raidIcon_shadowFrostReflect = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5	then raidIcon_shadowFrostReflect = "Moon"		end
		if GetRaidTargetIndex("Target") == 6	then raidIcon_shadowFrostReflect = "Square"		end
		if GetRaidTargetIndex("Target") == 7	then raidIcon_shadowFrostReflect = "Cross"		end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_shadowFrostReflect = "Skull"		end
		self:Sync(syncName.shadowFrostReflect .. " "..raidIcon_shadowFrostReflect)
	
		
	elseif shadowFrostReflectFound == nil and UnitName("Target") == "Anubisath Sentinel" and string.find(msg, L["trigger_shadowFrostReflectOther"]) then
		local _,_, shadowFrostReflectPerson, _ = string.find(msg, L["trigger_shadowFrostReflectOther"])
		for i=1,GetNumRaidMembers() do
			if UnitName("Raid"..i) == shadowFrostReflectPerson then
				if UnitName("Raid"..i.."Target") == "Anubisath Sentinel" then
					if GetRaidTargetIndex("Raid"..i.."Target")== nil then raidIcon_shadowFrostReflect = "No Icon"	end
					if GetRaidTargetIndex("Raid"..i.."Target")== 1	then raidIcon_shadowFrostReflect = "Star"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 2	then raidIcon_shadowFrostReflect = "Circle"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 3	then raidIcon_shadowFrostReflect = "Diamond"	end
					if GetRaidTargetIndex("Raid"..i.."Target")== 4	then raidIcon_shadowFrostReflect = "Triangle"	end
					if GetRaidTargetIndex("Raid"..i.."Target")== 5	then raidIcon_shadowFrostReflect = "Moon"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 6	then raidIcon_shadowFrostReflect = "Square"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 7	then raidIcon_shadowFrostReflect = "Cross"		end
					if GetRaidTargetIndex("Raid"..i.."Target")== 8	then raidIcon_shadowFrostReflect = "Skull"		end
				end
				break
			end
		end
		self:Sync(syncName.shadowFrostReflect .. " "..raidIcon_shadowFrostReflect)
	end
end

function module:AbilitiesScan()
	if knockBackFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_knockBack"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_knockBack)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_knockBack = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_knockBack = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_knockBack = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_knockBack = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_knockBack = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_knockBack = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_knockBack = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_knockBack = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_knockBack = "Skull"	end
		
		self:Sync(syncName.knockBack .. " "..raidIcon_knockBack)
	
	elseif manaBurnFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_manaBurn"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_manaBurn)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_manaBurn = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_manaBurn = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_manaBurn = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_manaBurn = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_manaBurn = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_manaBurn = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_manaBurn = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_manaBurn = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_manaBurn = "Skull"	end
		
		self:Sync(syncName.manaBurn .. " "..raidIcon_manaBurn)
		
		
	elseif mendingFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_mending"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_mending)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_mending = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_mending = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_mending = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_mending = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_mending = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_mending = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_mending = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_mending = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_mending = "Skull"	end
		
		self:Sync(syncName.mending .. " "..raidIcon_mending)

		
	elseif mortalStrikeFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_mortalStrike"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_mortalStrike)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_mortalStrike = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_mortalStrike = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_mortalStrike = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_mortalStrike = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_mortalStrike = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_mortalStrike = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_mortalStrike = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_mortalStrike = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_mortalStrike = "Skull"	end
		
		self:Sync(syncName.mortalStrike .. " "..raidIcon_mortalStrike)
		
	
	elseif shadowStormFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_shadowStorm"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_shadowStorm)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_shadowStorm = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_shadowStorm = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_shadowStorm = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_shadowStorm = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_shadowStorm = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_shadowStorm = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_shadowStorm = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_shadowStorm = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_shadowStorm = "Skull"	end
		
		self:Sync(syncName.shadowStorm .. " "..raidIcon_shadowStorm)
	
	
	elseif thornsFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_thorns"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_thorns)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_thorns = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_thorns = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_thorns = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_thorns = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_thorns = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_thorns = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_thorns = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_thorns = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_thorns = "Skull"	end
		
		self:Sync(syncName.thorns .. " "..raidIcon_thorns)
	
	
	elseif thunderClapFound == nil and UnitName("Target") == "Anubisath Sentinel" and UnitBuff("Target",1) == L["buffIcon_thunderClap"] then
		if GetRaidTargetIndex("Target") == nil then 
			if (IsRaidLeader() or IsRaidOfficer()) then
				SetRaidTarget("Target", raidIcon_thunderClap)
			end
		end
		if GetRaidTargetIndex("Target") == nil	then raidIcon_thunderClap = "NoIcon"	end
		if GetRaidTargetIndex("Target") == 1 	then raidIcon_thunderClap = "Star"		end
		if GetRaidTargetIndex("Target") == 2 	then raidIcon_thunderClap = "Circle"	end
		if GetRaidTargetIndex("Target") == 3 	then raidIcon_thunderClap = "Diamond" 	end
		if GetRaidTargetIndex("Target") == 4 	then raidIcon_thunderClap = "Triangle"	end
		if GetRaidTargetIndex("Target") == 5 	then raidIcon_thunderClap = "Moon"		end
		if GetRaidTargetIndex("Target") == 6 	then raidIcon_thunderClap = "Square"	end
		if GetRaidTargetIndex("Target") == 7 	then raidIcon_thunderClap = "Cross"	end
		if GetRaidTargetIndex("Target") == 8 	then raidIcon_thunderClap = "Skull"	end
		
		self:Sync(syncName.thunderClap .. " "..raidIcon_thunderClap)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.knockBack and rest and knockBackFound == nil then
		self:KnockBack(rest)
	elseif sync == syncName.manaBurn and rest and manaBurnFound == nil then
		self:ManaBurn(rest)
	elseif sync == syncName.mending and rest and mendingFound == nil then
		self:Mending(rest)
	elseif sync == syncName.mortalStrike and rest and mortalStrikeFound == nil then
		self:MortalStrike(rest)
	elseif sync == syncName.shadowStorm and rest and shadowStormFound == nil then
		self:ShadowStorm(rest)
	elseif sync == syncName.thorns and rest and thornsFound == nil then
		self:Thorns(rest)
	elseif sync == syncName.thunderClap and rest and thunderClapFound == nil then
		self:ThunderClap(rest)
	
	elseif sync == syncName.fireArcaneReflect and rest and fireArcaneReflectFound == nil then
		self:FireArcaneReflect(rest)
	elseif sync == syncName.shadowFrostReflect and rest and shadowFrostReflectFound == nil then
		self:ShadowFrostReflect(rest)
		
	elseif sync == syncName.addDead and rest then
		self:AddDead(rest)
	end
end


function module:ManaBurn(rest)
	manaBurnFound = true
	
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_manaBurn"], timer.manaBurn, icon.manaBurn, true, color.manaBurn)
		if UnitName("Target") == "Anubisath Sentinel" and UnitName("TargetTarget") == UnitName("Player") then
			if GetRaidTargetIndex("Target") == nil	and rest == "NoIcon"	or
			GetRaidTargetIndex("Target") == 1 		and rest == "Star"		or
			GetRaidTargetIndex("Target") == 2 		and rest == "Circle"	or
			GetRaidTargetIndex("Target") == 3 		and rest == "Diamond" 	or
			GetRaidTargetIndex("Target") == 4 		and rest == "Triangle"	or
			GetRaidTargetIndex("Target") == 5 		and rest == "Moon"		or
			GetRaidTargetIndex("Target") == 6 		and rest == "Square"	or
			GetRaidTargetIndex("Target") == 7 		and rest == "Cross"		or
			GetRaidTargetIndex("Target") == 8 		and rest == "Skull"		then
				self:Message("Mana Burn - Pull "..rest.." Away!", "Urgent", false, nil, false)
			end
		end
	end
end

function module:Mending(rest)
	mendingFound = true
	
	if self.db.profile.abilities then	
		self:Bar(rest .. L["bar_mending"], timer.mending, icon.mending, true, color.mending)
	end
end

function module:MortalStrike(rest)
	mortalStrikeFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_mortalStrike"], timer.mortalStrike, icon.mortalStrike, true, color.mortalStrike)
	end
end

function module:ShadowStorm(rest)
	shadowStormFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_shadowStorm"], timer.shadowStorm, icon.shadowStorm, true, color.shadowStorm)
		if UnitName("Target") == "Anubisath Sentinel" and UnitName("TargetTarget") == UnitName("Player") then
			if GetRaidTargetIndex("Target") == nil	and rest == "NoIcon"	or
			GetRaidTargetIndex("Target") == 1 		and rest == "Star"		or
			GetRaidTargetIndex("Target") == 2 		and rest == "Circle"	or
			GetRaidTargetIndex("Target") == 3 		and rest == "Diamond" 	or
			GetRaidTargetIndex("Target") == 4 		and rest == "Triangle"	or
			GetRaidTargetIndex("Target") == 5 		and rest == "Moon"		or
			GetRaidTargetIndex("Target") == 6 		and rest == "Square"	or
			GetRaidTargetIndex("Target") == 7 		and rest == "Cross"		or
			GetRaidTargetIndex("Target") == 8 		and rest == "Skull"		then
				self:Message("Shadow Storm - Stack "..rest.." on Casters!", "Urgent", false, nil, false)
			end
		end
	end
end

function module:Thorns(rest)
	thornsFound = true
	
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_thorns"], timer.thorns, icon.thorns, true, color.thorns)
	end
end

function module:KnockBack(rest)
	knockBackFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_knockBack"], timer.knockBack, icon.knockBack, true, color.knockBack)
	end
end

function module:ThunderClap(rest)
	thunderClapFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_thunderClap"], timer.thunderClap, icon.thunderClap, true, color.thunderClap)
	end
end


function module:FireArcaneReflect(rest)
	fireArcaneReflectFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_fireArcaneReflect"], timer.fireArcaneReflect, icon.fireArcaneReflect, true, color.fireArcaneReflect)
	end
end

function module:ShadowFrostReflect(rest)
	shadowFrostReflectFound = true
		
	if self.db.profile.abilities then
		self:Bar(rest .. L["bar_shadowFrostReflect"], timer.shadowFrostReflect, icon.shadowFrostReflect, true, color.shadowFrostReflect)
	end
end


function module:SelfReflect()
	self:Message(L["msg_selfReflect"], "Personal", false, nil, false)
	self:Sound("Beware")
end

function module:AddDead(rest)
	if tonumber(rest) == 4 then
		self:SendBossDeathSync()
		self:TriggerEvent("BigWigs_RebootModule", module.translatedName)
	end
end
