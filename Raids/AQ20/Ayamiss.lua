
local module, L = BigWigs:ModuleDeclaration("Ayamiss the Hunter", "Ruins of Ahn'Qiraj")

module.revision = 30069
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "sacrifice", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Ayamiss",

	sacrifice_cmd = "sacrifice",
	sacrifice_name = "Sacrifice Alert",
	sacrifice_desc = "Warn for Sacrifice",
	
	bigicon_cmd = "bigicons",
	bigicon_name = "Kill the larva icon alert",
	bigicon_desc = "Shows a big icon when a larva spawns",
	
	
	sacrificeother_trigger = "(.*) is afflicted by Paralyze.",
	sacrificeyou_trigger = "(.*) are afflicted by Paralyze.",
	sacrificeend_trigger = "Paralyze fades from",
	
	larva_bar = "Larva >Click Me!<",
	nextlarva_bar = "Larva/Sacrifice CD",
	
	msg_sacrifice = " Sacrificed, Kill the larva!",
	
	p2_msg = "Phase 2",

	larvaname = "Hive'Zara Larva",	
} end )

local timer = {
	sacrifice = 10,
	larvacd = 14,
}

local icon = {
	sacrifice = "ability_creature_poison_05",
}

local syncName = {
	sacrifice = "AyamissSacrifice"..module.revision,
	p2 = "AyamissP2"..module.revision,
	larvaend = "AyamissLarvaEnd"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("UNIT_HEALTH")
	
	self:ThrottleSync(5, syncName.sacrifice)
	self:ThrottleSync(5, syncName.p2)
	self:ThrottleSync(3, syncName.larvaend)
end

function module:OnSetup()
self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	local p2 = nil
	self:Bar(L["nextlarva_bar"], timer.larvacd, icon.sacrifice, true, "white")
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	if msg == string.format(UNITDIESOTHER, L["larvaname"]) then
		self:Sync(syncName.larvaend)
	end
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		local maxHealth = UnitHealthMax(arg1)
		if math.ceil(100*health/maxHealth) > 65 and math.ceil(100*health/maxHealth) <= 70 and not p2 then
			self:Sync(syncName.p2)
			p2 = true
		elseif math.ceil(100*health/maxHealth) > 70 and p2 then
			p2 = nil
		end
	end
end

function module:Event(msg)
	local _,_,sacrificeother = string.find(msg, L["sacrificeother_trigger"])
	if string.find(msg, L["sacrificeyou_trigger"]) then
		self:Sync(syncName.sacrifice.." "..UnitName("player"))
	elseif sacrificeother then
		self:Sync(syncName.sacrifice.." "..sacrificeother)
	end
	if string.find(msg, L["sacrificeend_trigger"]) then
		self:Sync(syncName.larvaend)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.sacrifice and rest and self.db.profile.sacrifice then
		self:Sacrifice(rest)
	elseif sync == syncName.p2 then
		self:Phase2()
	elseif sync == syncName.larvaend and self.db.profile.sacrifice then
		self:LarvaEnd()
	end
end

function module:Sacrifice(rest)
	self:Message(rest..L["msg_sacrifice"], "Urgent", false, "Beware")
	self:Bar(L["larva_bar"], timer.larva, icon.sacrifice, true, "red")
	self:SetCandyBarOnClick("BigWigsBar "..L["larva_bar"], function(name, button, extra) TargetByName("Hive'Zara Larva", true) end, rest)
	
	if self.db.profile.bigicon then
		self:WarningSign(icon.sacrifice, 0.7)
	end
	
	bwPlayerIsAttacking = nil
	if IsRaidLeader() or IsRaidOfficer() then
		if UnitClass("Player") ~= "Rogue" and UnitClass("Player") ~= "Druid" then
			if PlayerFrame.inCombat then
				bwPlayerIsAttacking = true
			end
			
			TargetByName(rest,true)
			SetRaidTarget("target",8)
			TargetLastTarget()
			if bwPlayerIsAttacking then
				AttackTarget()
			end
		end
	end
	
	self:Bar(L["nextlarva_bar"], timer.larvacd, icon.sacrifice, true, "white")
end

function module:Phase2()
	self:Message(L["p2_msg"], "Attention")
	p2 = true
end

function module:LarvaEnd()
	self:RemoveBar(L["larva_bar"])
end