
local module, L = BigWigs:ModuleDeclaration("Anubisath Sentinel", "Ahn'Qiraj")

module.revision = 30039
module.enabletrigger = module.translatedName
module.toggleoptions = {"abilities"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Sentinel",
	
	abilities_cmd = "abilities",
	abilities_name = "Abilities Alert",
	abilities_desc = "Warn for Abilities",
	
	hittrigger = "Anubisath Sentinel hits you",
	
	manaburnwarn = " has Mana Burn!",
    thornswarn = " has Thorns!",
    thunderclapwarn = " has Thunderclap!",
    knockbackwarn = " has Knockback!",
    mortalstrikewarn = " has Mortal Strike!",
    shadowstormwarn = " has Shadow Storm!",
    mendwarn = " has Mending!",
    sharefwarn = " has Shadow and Frost!",
	arcrefwarn = " has Fire and Arcane!",

	trigger_arcaneFireReflect1 = "Your Moonfire is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect2 = "Your Scorch is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect3 = "Your Flame Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect4 = "Your Firebolt is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect5 = "Your Flame Lash is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect6 = "Your Detect Magic is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflectOther = "(.+)'s Detect Magic is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE
	
	trigger_shadowFrostReflect1 = "Your Shadow Word: Pain is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect2 = "Your Corruption is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect3 = "Your Frostbolt is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect4 = "Your Frost Shock is reflected back by Anubisath Defender.",--CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflectOther = "(.+)'s Corruption is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE
	
	manaburnbufficon = "Interface\\Icons\\Spell_Shadow_ManaBurn",
	thunderclapbufficon = "Interface\\Icons\\Ability_ThunderClap",
	thornsbufficon = "Interface\\Icons\\Spell_Nature_Thorns",
	knockbackbufficon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
	mortalstrikebufficon = "Interface\\Icons\\Ability_Warrior_SavageBlow",
	shadowstormbufficon = "Interface\\Icons\\Spell_Shadow_Haunting",
	--arcrefbufficon = "nil",
	--sharefbufficon = "Interface\\Icons\\Spell_Arcane_Blink",
	mendbufficon = "Interface\\Icons\\Spell_Nature_ResistNature",
	
	trigger_selfReflect = "Your (.*) is reflected back by Anubisath Sentinel.",--CHAT_MSG_SPELL_SELF_DAMAGE
	msg_selfReflect = "STOP KILLING YOURSELF!",
	
	["You have slain %s!"] = true,
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	manaburn = 600,
	thunderclap = 600,
	thorns = 600,
	knockback = 600,
	mortalstrike = 600,
	shadowstorm = 600,
	arcref = 600,
	sharef = 600,
	mend = 600,
}

local icon = {
	manaburn = "Spell_Shadow_Manaburn",
	thunderclap = "Ability_ThunderClap",
	thorns = "Spell_Nature_Thorns",
	knockback = "Inv_Gauntlets_05",
	mortalstrike = "ability_warrior_savageblow",
	shadowstorm = "spell_shadow_shadowbolt",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
	mend = "spell_nature_resistnature",
}

local color = {
	mend = "green",
	mortalstrike = "yellow",
	sharef = "yellow",
	arcref = "yellow",
	knockback = "yellow",
	thorns = "orange",
	thunderclap = "orange",
	manaburn = "red",
	shadowstorm = "red",
}

local syncName = {
	manaburn = "SentinelManaburn"..module.revision,
	thunderclap = "SentinelThunderclap"..module.revision,
	thorns = "SentinelThorns"..module.revision,
	knockback = "SentinelKnockback"..module.revision,
	mortalstrike = "SentinelMortalstrike"..module.revision,
	shadowstorm = "SentinelShadowstorm"..module.revision,
	arcref = "SentinelArcref2"..module.revision,
	sharef = "SentinelSharef2"..module.revision,
	mend = "SentinelMend"..module.revision,
}

mendraidicon = 8
thornsraidicon = 7
mortalstrikeraidicon = 6
--sharefraidicon = 1
--arcrefraidicon = "No Icon"
knockbackraidicon = 2
thunderclapraidicon = 3
manaburnraidicon = 4
shadowstormraidicon = 5

local firstmanaburn = true
local firstthunderclap = true
local firstthorns = true
local firstknockback = true
local firstmortalstrike = true
local firstshadowstorm = true
local firstarcref = true
local firstsharef = true
local firstmend = true

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Abilities")--Debug
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Abilities")
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Abilities")
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Abilities")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Abilities")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Abilities")--sharef
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
firstmanaburn = true
firstthunderclap = true
firstthorns = true
firstknockback = true
firstmortalstrike = true
firstshadowstorm = true
firstarcref = true
firstsharef = true
firstmend = true
self:RemoveBar(L["sharefwarn"])
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], self.translatedName) then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("target") and UnitAffectingCombat("target") then
				local target = UnitName("target")
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
		end
	end
end

function module:Abilities(msg)
	if string.find(msg, L["trigger_selfReflect"]) then
		self:SelfReflect()
	end
	
	
	-- Mana Burn
	if firstmanaburn == true then
		if UnitBuff("target",1) == L["manaburnbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then manaburnicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then manaburnicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then manaburnicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then manaburnicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then manaburnicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then manaburnicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then manaburnicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then manaburnicon = "Skull"; end
				self:Sync(syncName.manaburn .. " "..manaburnicon)
				self:IntervalBar(string.format(manaburnicon .. L["manaburnwarn"]), timer.manaburn, timer.manaburn, icon.manaburn, true, color.manaburn)
				firstmanaburn = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", manaburnraidicon)
				end
			end			
		end
	end

	-- Thunderclap
	if firstthunderclap == true then
		if UnitBuff("target",1) == L["thunderclapbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then thunderclapicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then thunderclapicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then thunderclapicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then thunderclapicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then thunderclapicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then thunderclapicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then thunderclapicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then thunderclapicon = "Skull"; end
				self:Sync(syncName.thunderclap .. " "..thunderclapicon)
				self:IntervalBar(string.format(thunderclapicon .. L["thunderclapwarn"]), timer.thunderclap, timer.thunderclap, icon.thunderclap, true, color.thunderclap)
				firstthunderclap = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", thunderclapraidicon)
				end
			end			
		end
	end

	-- Thorns
	if firstthorns == true then
		if UnitBuff("target",1) == L["thornsbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then thornsicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then thornsicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then thornsicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then thornsicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then thornsicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then thornsicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then thornsicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then thornsicon = "Skull"; end
				self:Sync(syncName.thorns .. " "..thornsicon)
				self:IntervalBar(string.format(thornsicon .. L["thornswarn"]), timer.thorns, timer.thorns, icon.thorns, true, color.thorns)
				firstthorns = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", thornsraidicon)
				end
			end			
		end
	end
	
	-- Knockback
	if firstknockback == true then
		if UnitBuff("target",1) == L["knockbackbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then knockbackicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then knockbackicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then knockbackicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then knockbackicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then knockbackicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then knockbackicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then knockbackicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then knockbackicon = "Skull"; end
				self:Sync(syncName.knockback .. " "..knockbackicon)
				self:IntervalBar(string.format(knockbackicon .. L["knockbackwarn"]), timer.knockback, timer.knockback, icon.knockback, true, color.knockback)
				firstknockback = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", knockbackraidicon)
				end
			end			
		end
	end

	-- Mortal Strike
	if firstmortalstrike == true then
		if UnitBuff("target",1) == L["mortalstrikebufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then mortalstrikeicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then mortalstrikeicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then mortalstrikeicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then mortalstrikeicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then mortalstrikeicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then mortalstrikeicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then mortalstrikeicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then mortalstrikeicon = "Skull"; end
				self:Sync(syncName.mortalstrike .. " "..mortalstrikeicon)
				self:IntervalBar(string.format(mortalstrikeicon .. L["mortalstrikewarn"]), timer.mortalstrike, timer.mortalstrike, icon.mortalstrike, true, color.mortalstrike)
				firstmortalstrike = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", mortalstrikeraidicon)
				end
			end			
		end
	end

	-- Shadow Storm
	if firstshadowstorm == true then
		if UnitBuff("target",1) == L["shadowstormbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then shadowstormicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then shadowstormicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then shadowstormicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then shadowstormicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then shadowstormicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then shadowstormicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then shadowstormicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then shadowstormicon = "Skull"; end
				self:Sync(syncName.shadowstorm .. " "..shadowstormicon)
				self:IntervalBar(string.format(shadowstormicon .. L["shadowstormwarn"]), timer.shadowstorm, timer.shadowstorm, icon.shadowstorm, true, color.shadowstorm)
				firstshadowstorm = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", shadowstormraidicon)
				end
			end	
		end
	end

	--Mend
	if firstmend == true then
		if UnitBuff("target",1) == L["mendbufficon"] then
			if GetRaidTargetIndex("target")~= nil then 
				if GetRaidTargetIndex("target")==1 then mendicon = "Star"; end
				if GetRaidTargetIndex("target")==2 then mendicon = "Circle"; end
				if GetRaidTargetIndex("target")==3 then mendicon = "Diamond"; end
				if GetRaidTargetIndex("target")==4 then mendicon = "Triangle"; end
				if GetRaidTargetIndex("target")==5 then mendicon = "Moon"; end
				if GetRaidTargetIndex("target")==6 then mendicon = "Square"; end
				if GetRaidTargetIndex("target")==7 then mendicon = "Cross"; end
				if GetRaidTargetIndex("target")==8 then mendicon = "Skull"; end
				self:Sync(syncName.mend .. " "..mendicon)
				self:IntervalBar(string.format(mendicon .. L["mendwarn"]), timer.mend, timer.mend, icon.mend, true, color.mend)
				firstmend = false
			elseif UnitName("target")~= nil then
				if UnitName("target") == "Anubisath Sentinel" then
					SetRaidTarget("target", mendraidicon)
				end
			end			
		end
	end
	
	
	-- Arcane Reflect
	if firstarcref == true then
		if string.find(msg, L["trigger_arcaneFireReflect1"]) or string.find(msg, L["trigger_arcaneFireReflect2"]) or string.find(msg, L["trigger_arcaneFireReflect3"]) or string.find(msg, L["trigger_arcaneFireReflect4"]) or string.find(msg, L["trigger_arcaneFireReflect5"]) or string.find(msg, L["trigger_arcaneFireReflect6"]) then
			if UnitName("Target") ~= nil then
				if UnitName("Target") == "Anubisath Sentinel" then
					if GetRaidTargetIndex("target")== nil then arcreficon = "No Icon" end
					if GetRaidTargetIndex("target")==1 then arcreficon = "Star"; end
					if GetRaidTargetIndex("target")==2 then arcreficon = "Circle"; end
					if GetRaidTargetIndex("target")==3 then arcreficon = "Diamond"; end
					if GetRaidTargetIndex("target")==4 then arcreficon = "Triangle"; end
					if GetRaidTargetIndex("target")==5 then arcreficon = "Moon"; end
					if GetRaidTargetIndex("target")==6 then arcreficon = "Square"; end
					if GetRaidTargetIndex("target")==7 then arcreficon = "Cross"; end
					if GetRaidTargetIndex("target")==8 then arcreficon = "Skull"; end
					self:Sync(syncName.arcref .. " "..arcreficon)
					self:IntervalBar(string.format(arcreficon .. L["arcrefwarn"]), timer.arcref, timer.arcref, icon.arcref, true, color.arcref)
					firstarcref = false
				end
			end
		end
	end
	
	if firstarcref == true then
		if string.find(msg, L["trigger_arcaneFireReflectOther"]) then
			local _,_, arcaneFireReflectPerson, _ = string.find(msg, L["trigger_arcaneFireReflectOther"])
			
			TargetByName(arcaneFireReflectPerson,true)
			if GetRaidTargetIndex("targettarget")== nil then arcreficon = "No Icon" end
			if GetRaidTargetIndex("targettarget")==1 then arcreficon = "Star"; end
			if GetRaidTargetIndex("targettarget")==2 then arcreficon = "Circle"; end
			if GetRaidTargetIndex("targettarget")==3 then arcreficon = "Diamond"; end
			if GetRaidTargetIndex("targettarget")==4 then arcreficon = "Triangle"; end
			if GetRaidTargetIndex("targettarget")==5 then arcreficon = "Moon"; end
			if GetRaidTargetIndex("targettarget")==6 then arcreficon = "Square"; end
			if GetRaidTargetIndex("targettarget")==7 then arcreficon = "Cross"; end
			if GetRaidTargetIndex("targettarget")==8 then arcreficon = "Skull"; end
			TargetLastTarget()
			
			self:Sync(syncName.arcref .. " "..arcreficon)
			self:IntervalBar(string.format(arcreficon .. L["arcrefwarn"]), timer.arcref, timer.arcref, icon.arcref, true, color.arcref)
			firstarcref = false
		end
	end
			
			
	-- Shadow Reflect
	if firstsharef == true then
		if string.find(msg, L["trigger_shadowFrostReflect1"]) or string.find(msg, L["trigger_shadowFrostReflect2"]) or string.find(msg, L["trigger_shadowFrostReflect3"]) or string.find(msg, L["trigger_shadowFrostReflect4"]) then
			if UnitName("Target") ~= nil then
				if UnitName("Target") == "Anubisath Sentinel" then
					if GetRaidTargetIndex("target")== nil then shareficon = "No Icon" end
					if GetRaidTargetIndex("target")==1 then shareficon = "Star"; end
					if GetRaidTargetIndex("target")==2 then shareficon = "Circle"; end
					if GetRaidTargetIndex("target")==3 then shareficon = "Diamond"; end
					if GetRaidTargetIndex("target")==4 then shareficon = "Triangle"; end
					if GetRaidTargetIndex("target")==5 then shareficon = "Moon"; end
					if GetRaidTargetIndex("target")==6 then shareficon = "Square"; end
					if GetRaidTargetIndex("target")==7 then shareficon = "Cross"; end
					if GetRaidTargetIndex("target")==8 then shareficon = "Skull"; end
					self:Sync(syncName.sharef .. " "..shareficon)
					self:IntervalBar(string.format(shareficon .. L["sharefwarn"]), timer.sharef, timer.sharef, icon.sharef, true, color.sharef)
					firstsharef = false
				end
			end
		end
	end
	if firstsharef == true then
		if string.find(msg, L["trigger_shadowFrostReflectOther"]) then
			local _,_, shadowFrostReflectPerson, _ = string.find(msg, L["trigger_shadowFrostReflectOther"])
			
			TargetByName(shadowFrostReflectPerson,true)
			if GetRaidTargetIndex("targettarget")== nil then shareficon = "No Icon" end
			if GetRaidTargetIndex("targettarget")==1 then shareficon = "Star"; end
			if GetRaidTargetIndex("targettarget")==2 then shareficon = "Circle"; end
			if GetRaidTargetIndex("targettarget")==3 then shareficon = "Diamond"; end
			if GetRaidTargetIndex("targettarget")==4 then shareficon = "Triangle"; end
			if GetRaidTargetIndex("targettarget")==5 then shareficon = "Moon"; end
			if GetRaidTargetIndex("targettarget")==6 then shareficon = "Square"; end
			if GetRaidTargetIndex("targettarget")==7 then shareficon = "Cross"; end
			if GetRaidTargetIndex("targettarget")==8 then shareficon = "Skull"; end
			TargetLastTarget()
			
			self:Sync(syncName.sharef .. " "..shareficon)
			self:IntervalBar(string.format(shareficon .. L["sharefwarn"]), timer.sharef, timer.sharef, icon.sharef, true, color.sharef)
			firstsharef = false
		end
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.manaburn and rest then
		if firstmanaburn == true then
			self:IntervalBar(string.format(rest .. L["manaburnwarn"]), timer.manaburn, timer.manaburn, icon.manaburn, true, color.manaburn)
			self:Message("Pull " .. rest .. " Away!", "Attention")
			firstmanaburn = false
		end
		
	elseif sync == syncName.thunderclap and rest then
		if firstthunderclap == true then
			self:IntervalBar(string.format(rest .. L["thunderclapwarn"]), timer.thunderclap, timer.thunderclap, icon.thunderclap, true, color.thunderclap)
			firstthunderclap = false
		end
		
	elseif sync == syncName.thorns and rest then
		if firstthorns == true then
			self:IntervalBar(string.format(rest .. L["thornswarn"]), timer.thorns, timer.thorns, icon.thorns, true, color.thorns)
			firstthorns = false
		end
		
	elseif sync == syncName.knockback and rest then
		if firstknockback == true then
			self:IntervalBar(string.format(rest .. L["knockbackwarn"]), timer.knockback, timer.knockback, icon.knockback, true, color.knockback)
			firstknockback = false
		end
		
	elseif sync == syncName.mortalstrike and rest then
		if firstmortalstrike == true then
			self:IntervalBar(string.format(rest .. L["mortalstrikewarn"]), timer.mortalstrike, timer.mortalstrike, icon.mortalstrike, true, color.mortalstrike)
			firstmortalstrike = false
		end
		
	elseif sync == syncName.shadowstorm and rest then
		if firstshadowstorm == true then
			self:IntervalBar(string.format(rest .. L["shadowstormwarn"]), timer.shadowstorm, timer.shadowstorm, icon.shadowstorm, true, color.shadowstorm)
			self:Message("Stack ".. rest .. " on Casters!", "Attention")
			firstshadowstorm = false
		end
		
	elseif sync == syncName.arcref and rest then
		if firstarcref == true then
			self:IntervalBar(string.format(rest .. L["arcrefwarn"]), timer.arcref, timer.arcref, icon.arcref, true, color.arcref)
			firstarcref = false
		end
		
	elseif sync == syncName.sharef and rest then
		if firstsharef == true then
			self:IntervalBar(string.format(rest .. L["sharefwarn"]), timer.sharef, timer.sharef, icon.sharef, true, color.sharef)
			firstsharef = false
		end
		
	elseif sync == syncName.mend and rest then
		if firstmend == true then
			self:IntervalBar(string.format(rest .. L["mendwarn"]), timer.mend, timer.mend, icon.mend, true, color.mend)
			firstmend = false
		end
		
	end
end

function module:SelfReflect()
	self:Message(L["msg_selfReflect"], "Personal", false, nil, false)
	self:Sound("Beware")
end
