
local module, L = BigWigs:ModuleDeclaration("High Priest Venoxis", "Zul'Gurub")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"phase", "adds", "renew", "holyfire", "enrage", "announce", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd                 = "Venoxis",

	adds_cmd            = "adds",
	adds_name           = "Dead adds counter",
	adds_desc           = "Announces dead Razzashi Cobras",

	renew_cmd           = "renew",
	renew_name          = "Renew Alert",
	renew_desc          = "Warn for Renew",

	holyfire_cmd        = "holyfire",
	holyfire_name       = "Holy Fire Alert",
	holyfire_desc       = "Warn for Holy Fire",

	phase_cmd           = "phase",
	phase_name          = "Phase Notification",
	phase_desc          = "Announces the boss' phase transition",

	announce_cmd        = "whispers",
	announce_name       = "Whisper to people in Poison Clouds",
	announce_desc       = "Sends a whisper to players that stand in poison\n\n(Requires assistant or higher)\n\n(Disclaimer: to avoid spamming whispers, it will only whisper people that actually take damage from the Poison Clouds)",

	enrage_cmd          = "enrage",
	enrage_name         = "Enrage Alert",
	enrage_desc         = "Warn for Enrage",
	
	
	renew_trigger = "High Priest Venoxis gains Renew.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	renewend_trigger = "Renew fades from High Priest Venoxis.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	enrage_trigger = "High Priest Venoxis gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	holyfire_trigger = "High Priest Venoxis begins to cast Holy Fire.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	phase2_trigger = "Let the coils of hate unfurl!",--CHAT_MSG_MONSTER_YELL
	
	attack_trigger1 = "High Priest Venoxis attacks",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES
	attack_trigger2 = "High Priest Venoxis misses",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES // CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES
	attack_trigger3 = "High Priest Venoxis hits",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS
	attack_trigger4 = "High Priest Venoxis crits",--CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS // CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS // CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS

	poisoncloudhitsyou_trigger = "You suffer (.+) Nature damage from High Priest Venoxis's Poison Cloud",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE

	add_name = "Razzashi Cobra",
	deadaddtrigger = "Razzashi Cobra dies",
	deadbosstrigger = "High Priest Venoxis dies",

	holyfirebar = "Holy Fire",
	renewbar = "Renew",
	renew_message = "Renew! Dispel it!",
	phase2_message = "Snake Phase",
	enrage_message = "Boss is enraged! Spam heals!",
	poisonyou_message = "Move away from poison cloud!",
	addmsg = "%d/4 Razzashi Cobras dead!",
	you = "you",

	
	["Next Holy Fire"] = true,
} end )

module.wipemobs = { L["add_name"] }

local timer = {
	holyfireCast = 3.5,
	holyfire = 8,
	renew = 20,
}
local icon = {
	addDead = "INV_WAEPON_BOW_ZULGRUB_D_01",
	cloud = "Ability_Creature_Disease_02",
	renew = "Spell_Holy_Renew",
	holyfire = "Spell_Holy_SearingLight",
}
local syncName = {
	phase2 = "VenoxisPhaseTwo"..module.revision,
	renew = "VenoxisRenewStart"..module.revision,
	renewOver = "VenoxisRenewStop"..module.revision,
	holyfire = "VenoxisHolyFireStart"..module.revision,
	holyfireOver = "VenoxisHolyFireStop"..module.revision,
	enrage = "VenoxisEnrage"..module.revision,
	addDead = "VenoxisAddDead"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")--p2trigger
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--poisonYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--renew, enrage
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "Event")--holyFire Cast Ended
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "Event")--holyFire Cast Ended
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS", "Event")--holyFire Cast Ended
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES", "Event")--holyFire Cast Ended
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS", "Event")--holyFire Cast Ended
	self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES", "Event")--holyFire Cast Ended

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--cast holyFire
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--renewEnd

	self:ThrottleSync(10, syncName.phase2)
	self:ThrottleSync(2, syncName.renew)
	self:ThrottleSync(2, syncName.renewOver)
	self:ThrottleSync(2, syncName.holyfire)
	self:ThrottleSync(2, syncName.holyfireOver)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
	self.cobra = 0

	castingholyfire = 0
	holyfiretime = 0

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
end

function module:OnEngage()
	self.cobra = 0
	castingholyfire = 0
	holyfiretime = 0
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if string.find(msg, L["deadaddtrigger"]) then
		self:Sync(syncName.addDead .. " " .. tostring(self.cobra + 1))
	end
end

function module:Event(msg)
	if string.find(msg, L["holyfire_trigger"]) then
		self:Sync(syncName.holyfire)
	elseif string.find(msg, L["attack_trigger1"]) or string.find(msg, L["attack_trigger2"]) or string.find(msg, L["attack_trigger3"]) or string.find(msg, L["attack_trigger4"]) then
		if castingholyfire == 1 then
			if (GetTime() - holyfiretime) < timer.holyfireCast then
				self:Sync(syncName.holyfireOver)
			elseif (GetTime() - holyfiretime) >= timer.holyfireCast then
				castingholyfire = 0
			end
		end
		
	elseif string.find(msg, L["renew_trigger"]) then
		self:Sync(syncName.renew)
	elseif string.find(msg, L["renewend_trigger"]) then
		self:Sync(syncName.renewOver)
	
	elseif string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.enrage)
		
	elseif string.find(msg, L["poisoncloudhitsyou_trigger"]) then
		self:WarningSign(icon.cloud, 0.7)
		self:Message(L["poisonyou_message"], "Attention", "Alarm")
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["phase2_trigger"]) then
		self:Sync(syncName.phase2)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.phase2 and self.db.profile.phase then
		self:Phase2()
	elseif sync == syncName.renew and self.db.profile.renew then
		self:Renew()
	elseif sync == syncName.renewOver and self.db.profile.renew then
		self:RenewOver()
	elseif sync == syncName.holyfire and self.db.profile.holyfire then
		self:HolyFire()
	elseif sync == syncName.holyfireOver and self.db.profile.holyfire then
		self:HolyFireOver()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	elseif sync == syncName.addDead and rest and rest ~= "" and self.db.profile.adds then
		self:Adds(rest)
	end
end

function module:Phase2()
	self:Message(L["phase2_message"], "Attention")
	self:RemoveBar(L["holyfirebar"])
end

function module:Renew()
	self:Message(L["renew_message"], "Urgent")
	self:Bar(L["renewbar"], timer.renew, icon.renew, true, "blue")
end

function module:RenewOver()
	self:RemoveBar(L["renewbar"])
end

function module:HolyFire()
	holyfiretime = GetTime()
	castingholyfire = 1
	
	self:Bar(L["holyfirebar"], timer.holyfireCast, icon.holyfire, true, "red")
	self:Bar(L["Next Holy Fire"], timer.holyfire, icon.holyfire, true, "white")
end

function module:HolyFireOver()
	castingholyfire = 0
	self:RemoveBar(L["holyfirebar"])
end

function module:Enrage()
	self:Message(L["enrage_message"], "Attention")
end

function module:Adds(rest)
	rest = tonumber(rest)
	if rest <= 4 and self.cobra < rest then
		self.cobra = rest
		self:Message(string.format(L["addmsg"], self.cobra), "Positive")
	end
end
