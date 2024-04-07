
local module, L = BigWigs:ModuleDeclaration("High Priestess Mar'li", "Zul'Gurub")

module.revision = 30078
module.enabletrigger = module.translatedName
module.toggleoptions = {"webs", "charge", "drain", "phase", "spider", "volley", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Marli",
	
	webs_cmd = "webs",
	webs_name = "Enveloping Webs Alert",
	webs_desc = "Warn for Enveloping Webs",
	
	charge_cmd = "charge",
	charge_name = "Charge Alert",
	charge_desc = "Warn for Charge",
	
	drain_cmd = "drain",
	drain_name = "Drain Life Alert",
	drain_desc = "Warn for Drain Life",
	
	phase_cmd = "phase",
	phase_name = "Phase Change Alert",
	phase_desc = "Warn for Phase Change",
	
	spider_cmd = "spider",
	spider_name = "Spider Adds Alert",
	spider_desc = "Warn for Spider Adds",

	volley_cmd = "volley",
	volley_name = "Poison Bolt Volley Alert",
	volley_desc = "Warn for Poison Bolt Volleys",
	
	
	trigger_engage = "Draw me to your web mistress Shadra. Unleash your venom!",--CHAT_MSG_MONSTER_YELL
	trigger_bossDead = "High Priestess Mar'li dies.",--CHAT_MSG_COMBAT_HOSTILE_DEATH
	--trigger_addDead = "Spawn of Mar'li dies.",--CHAT_MSG_COMBAT_HOSTILE_DEATH
	
	trigger_websOther = "(.+) is afflicted by Enveloping Webs.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	trigger_websYou = "You are afflicted by Enveloping Webs.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	bar_websCd = "Enveloping Webs CD",
	
	trigger_charge = "High Priestess Mar'li's Charge",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_chargeCd = "Charge CD",
	
	--if registering CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE then will Warlock's...
	trigger_drainLifeOther = "(.+) is afflicted by Drain Life.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_drainLifeYou = "You are afflicted by Drain Life.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_drainLifeFade = "Drain Life fades from (.+)",--CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_drainLife = "Drain Life",
	msg_drainLife = "Drain Life - Interrupt/Dispel!",
	
	trigger_spiderPhase = "Shadra, make of me your avatar!",--CHAT_MSG_MONSTER_YELL
	bar_spiderPhaseTimer = "Next Troll Phase",
	
	--no trigger for Troll Phase
	bar_trollPhaseTimer = "Next Spider Phase",
	
	--no trigger for adds spawn
	bar_addsCd = "Spider adds spawn",
	msg_addsDead = "/4 Spiders Dead",
	msg_spidersSpawn = "Kill the Spider add!",
	
	trigger_poisonVolley = "afflicted by Poison Bolt Volley.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	bar_poisonVolleyCd = "Poison Volley CD",
} end )

local timer = {
	websFirstCd = 5,
	websCd = {10,20},--saw 11,19 
	
	chargeCd = {10,20},--to be confirmed, saw 18, first one is very random, saw 6
	drainLife = 7,
	trollPhase = 35,
	spiderPhase = 35,
	
	spiderAddCd = 20, --sometimes 1, sometimes 4 o.0?, spawn after spider phase is random? saw 5 and 20
	
	poisonVolleyFirstCd = 15,
	poisonVolleyCd = {10,19},--saw 10,19
}
local icon = {
	webs = "Spell_Nature_EarthBind",
	charge = "ability_warrior_charge",
	drainLife = "spell_shadow_lifedrain02",
	trollPhase = "inv_misc_head_troll_02",
	spiderPhase = "inv_misc_monsterspidercarapace_01",
	spiderAdd = "inv_egg_04",
	poisonVolley = "spell_nature_corrosivebreath",
}
local color = {
	websCd = "Blue",
	chargeCd = "Red",
	drainLife = "Red",
	trollPhase = "White",
	spiderPhase = "White",
	spiderAdd = "Black",
	poisonVolley = "Green",
}
local syncName = {
	webs = "MarliWebs"..module.revision,
	charge = "MarliCharge"..module.revision,
	
	drainStart = "MarliDrainStart"..module.revision,
	drainOver = "MarliDrainEnd"..module.revision,
	
	trollPhase = "MarliTrollPhase"..module.revision,
	spiderPhase = "MarliSpiderPhase"..module.revision,
	
	spidersSpawn = "MarliSpiders"..module.revision,
	poisonVolley = "MarliVolley"..module.revision,
}

local addsDead = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--trigger_engage, trigger_spiderSpawn
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_websYou, trigger_poisonVolley
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_websOther, trigger_poisonVolley
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_websOther, trigger_poisonVolley
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_charge
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_charge
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_drainLifeFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_drainLifeFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_drainLifeFade
	
	
	self:ThrottleSync(3, syncName.webs)
	self:ThrottleSync(3, syncName.charge)
	self:ThrottleSync(5, syncName.drainStart)
	self:ThrottleSync(5, syncName.drainOver)
	self:ThrottleSync(5, syncName.trollPhase)
	self:ThrottleSync(5, syncName.spiderPhase)
	self:ThrottleSync(15, syncName.spidersSpawn)
	self:ThrottleSync(9, syncName.poisonVolley)
end

function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	if self.db.profile.phase then
		self:TrollPhase()
	end
	
	if self.db.profile.volley then
		self:Bar(L["bar_poisonVolleyCd"], timer.poisonVolleyFirstCd, icon.poisonVolley, true, color.poisonVolley)
	end
	
	if self.db.profile.spider then
		self:Bar(L["bar_addsCd"], timer.spiderAddCd, icon.spiderAdd, true, color.spiderAdd)
	end
	
	addsDead = 0
	watchForSpawn = nil
end

function module:OnDisengage()
	self:CancelScheduledEvent("EnableSpiderAddCheck")
	self:CancelScheduledEvent("MarliSpiderAddCheck")
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()

	elseif string.find(msg, L["trigger_spiderPhase"]) then
		self:Sync(syncName.spiderPhase)
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == L["trigger_bossDead"] then
		self:SendBossDeathSync()
	
	elseif msg == string.format(UNITDIESOTHER, "Spawn of Mar'li") then
		if addsDead < 4 then
			addsDead = addsDead + 1
			self:Message(addsDead..L["msg_addsDead"], "Positive", false, nil, false)
		else
			self:ScheduleRepeatingEvent("MarliSpiderAddCheck", self.SpiderAddCheck, 0.5, self)
		end
	end
end

function module:SpiderAddCheck()
	if UnitName("target") == "Spawn of Mar'li" and not UnitIsDeadOrGhost("target") and UnitExists("target") then
		self:CancelScheduledEvent("MarliSpiderAddCheck")
		if (IsRaidLeader() or IsRaidOfficer()) then
			SetRaidTarget("target",8)
		end
		self:Sync(syncName.spidersSpawn)
	else
		for i = 1,GetNumRaidMembers() do
			if UnitName("Raid"..i.."target") == "Spawn of Mar'li" and not UnitIsDeadOrGhost("Raid"..i.."target") and UnitExists("Raid"..i.."target") then
				self:CancelScheduledEvent("MarliSpiderAddCheck")
				if (IsRaidLeader() or IsRaidOfficer()) then
					SetRaidTarget("Raid"..i.."target",8)
				end
				self:Sync(syncName.spidersSpawn)
				break
			end
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_websYou"] then
		self:Sync(syncName.webs)
	elseif string.find(msg, L["trigger_websOther"]) then
		self:Sync(syncName.webs)
	
	elseif string.find(msg, L["trigger_charge"]) then
		self:Sync(syncName.charge)
	
	elseif msg == L["trigger_drainLifeYou"] then
		self:Sync(syncName.drainStart)
	elseif string.find(msg, L["trigger_drainLifeOther"]) then
		self:Sync(syncName.drainStart)
	elseif string.find(msg, L["trigger_drainLifeFade"]) then
		self:Sync(syncName.drainOver)
	
	elseif string.find(msg, L["trigger_poisonVolley"]) then
		self:Sync(syncName.poisonVolley)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.webs and self.db.profile.webs then
		self:Webs()
	elseif sync == syncName.charge and self.db.profile.charge then
		self:Charge()
	elseif sync == syncName.drainStart and self.db.profile.drain then
		self:DrainStart()
	elseif sync == syncName.drainOver and self.db.profile.drain then
		self:DrainOver()
	elseif sync == syncName.spiderPhase and self.db.profile.phase then
		self:SpiderPhase()
	elseif sync == syncName.trollPhase and self.db.profile.phase then
		self:TrollPhase()
	elseif sync == syncName.spidersSpawn and self.db.profile.spider then
		self:SpidersSpawn()
	elseif sync == syncName.poisonVolley and self.db.profile.volley then
		self:PoisonVolley()
	end
end


function module:Webs()
	self:RemoveBar(L["bar_websCd"])
	self:IntervalBar(L["bar_websCd"], timer.websCd[1], timer.websCd[2], icon.webs, true, color.websCd)
	if UnitClass("Player") == "Paladin" then
		self:WarningSign(icon.webs, 0.7)
		self:Sound("Info")
	end
end

function module:Charge()
	self:RemoveBar(L["bar_chargeCd"])
	self:IntervalBar(L["bar_chargeCd"], timer.chargeCd[1], timer.chargeCd[2], icon.charge, true, color.chargeCd)
end

function module:DrainStart()
	self:Bar(L["bar_drainLife"], timer.drainLife, icon.drainLife, true, color.drainLife)
	self:Message(L["msg_drainLife"], "Attention", false, nil, false)
	
	if UnitClass("Player") == "Rogue" or UnitClass("Player") == "Warrior" or UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Mage" then
		self:WarningSign(icon.drainLife, timer.drainLife)
		self:Sound("Beware")
	end
end

function module:DrainOver()
	self:RemoveBar(L["bar_drainLife"])
	self:RemoveWarningSign(icon.drainLife)
end

function module:SpiderPhase()
	self:RemoveBar(L["bar_drainLife"])
	self:RemoveBar(L["bar_poisonVolleyCd"])
	self:RemoveBar(L["bar_trollPhaseTimer"])
	
	self:Bar(L["bar_spiderPhaseTimer"], timer.spiderPhase, icon.spiderPhase, true, color.spiderPhase)
	
	if self.db.profile.webs then
		self:Bar(L["bar_websCd"], timer.websFirstCd, icon.webs, true, color.webs)
	end
	
	self:DelayedSync(timer.spiderPhase, syncName.trollPhase)
end

function module:SendTrollPhaseSync()
	self:Sync(syncName.trollPhase)
end

function module:TrollPhase()
	self:CancelDelayedSync(syncName.trollPhase)
	self:RemoveBar(L["bar_websCd"])
	self:RemoveBar(L["bar_chargeCd"])
	self:RemoveBar(L["bar_spiderPhaseTimer"])
	
	self:Bar(L["bar_trollPhaseTimer"], timer.trollPhase, icon.trollPhase, true, color.trollPhase)
end

function module:SpidersSpawn()
	self:CancelScheduledEvent("EnableSpiderAddCheck")
	self:CancelScheduledEvent("MarliSpiderAddCheck")
	self:Message(L["msg_spidersSpawn"], "Attention", false, nil, false)
	self:Sound("BikeHorn")
	
	self:ScheduleEvent("EnableSpiderAddCheck", self.EnableSpiderAddCheck, timer.spiderAddCd - 5, self)
end

function module:EnableSpiderAddCheck()
	self:ScheduleRepeatingEvent("MarliSpiderAddCheck", self.SpiderAddCheck, 0.5, self)
end

function module:PoisonVolley()
	self:IntervalBar(L["bar_poisonVolleyCd"], timer.poisonVolleyCd[1], timer.poisonVolleyCd[2], icon.poisonVolley, true, color.poisonVolley)
	if UnitClass("Player") == "Shaman" then
		self:WarningSign(icon.poisonVolley, 0.7)
		self:Sound("Info")
	end
end
