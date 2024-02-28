
local module, L = BigWigs:ModuleDeclaration("Gri'lek", "Zul'Gurub")

module.revision = 30057
module.enabletrigger = module.translatedName
module.toggleoptions = {"avatar", "puticon", "stun", "groundtremor", "roots", "sweepingstrikes", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grilek",
	
	avatar_cmd = "avatar",
	avatar_name = "Avatar Alert",
	avatar_desc = "Warn for Avatar.",

	puticon_cmd = "puticon",
	puticon_name = "Place Icon on Gri'lek's Target",
	puticon_desc = "Place a Raid Icon on the Player targetted by Gri'lek.",

	stun_cmd = "stun",
	stun_name = "Boss Stunned Alert",
	stun_desc = "Warn for Gri'lek is Stunned (2sec) after Avatar.",
	
	groundtremor_cmd = "groundtremor",
	groundtremor_name = "Ground Tremor Alert",
	groundtremor_desc = "Warn for Ground Tremor.",
	
	roots_cmd = "roots",
	roots_name = "Entangling Roots Alert",
	roots_desc = "Warn for Entangling Roots.",
	
	sweepingstrikes_cmd = "sweepingstrikes",
	sweepingstrikes_name = "Sweeping Strikes Alert",
	sweepingstrikes_desc = "Warn for Sweeping Strikes.",
	
	
	trigger_avatar = "Gri'lek is afflicted by Avatar.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	trigger_avatarFade = "Avatar fades from Gri'lek.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_avatarCd = "Avatar CD",
	bar_avatarDur = "Avatar!",
	msg_avatar = "Avatar - Run away from the boss!",
	
	trigger_stun = "Gri'lek is afflicted by Stun.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	trigger_stunFade = "Stun fades from Gri'lek.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_stun = "Gri'lek Stunned",
	
	trigger_groundTremor = "afflicted by Ground Tremor.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_groundTremorFade = "Ground Tremor fades from", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_groundTremorCd = "Ground Tremor CD",
	bar_groundTremorDur = "Ground Tremor Stun",
	
	trigger_rootsYou = "You are afflicted by Entangling Roots.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_rootsOther = "(.+) is afflicted by Entangling Roots.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_rootsFade = "Entangling Roots fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_roots = " Rooted",
	
	--untested
	trigger_sweepingStrikes = "Gri'lek gains Sweeping Strikes.", --guessing CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_sweepingStrikes2 = "Gri'lek is afflicted Sweeping Strikes.", --guessing CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	trigger_sweepingStrikesFade = "Sweeping Strikes fades from Gri'lek.", --guessing CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_sweepingStrikes = "Sweeping Strikes!",
} end )

local timer = {
	firstAvatar = 25,
	avatarCd = 10, --25s - duration
	avatarDur = 15,
	
	stun = 2,
	
	firstGroundTremor = 18,
	groundTremorCd = 18, --20s - duration
	groundTremorDur = 2,
	
	roots = 10,
	
	--does he do it on Twow?
	sweepingStrikes = 20,
}
local icon = {
	avatar = "Ability_Creature_Cursed_05",
	stun = "spell_frost_stun",
	groundTremor = "spell_nature_earthquake",
	roots = "spell_nature_stranglevines",
	
	--does he do it on Twow?
	sweepingStrikes = "ability_rogue_slicedice",
}
local color = {
	avatarCd = "White",
	avatarDur = "Cyan",
	stun = "Blue",
	groundTremor = "Black",
	roots = "Green",
	
	--does he do it on Twow?
	sweepingStrikes = "Red",
}
local syncName = {
	avatar = "GrilekAvatar"..module.revision,
	avatarOver = "GrilekAvatarStop"..module.revision,
	stun = "GrilekStun"..module.revision,
	stunFade = "GrilekStunFade"..module.revision,
	groundTremor = "GrilekGroundTremor"..module.revision,
	groundTremorFade = "GrilekGroundTremorFade"..module.revision,
	roots = "GrilekRoots"..module.revision,
	rootsFade = "GrilekRootsFade"..module.revision,
	
	--does he do it on Twow?
	sweepingStrikes = "GrilekSweepingStrikes"..module.revision,
	sweepingStrikesFade = "GrilekSweepingStrikesFade"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_sweepingStrikes
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event") --trigger_avatar, trigger_stun, trigger_sweepingStrikes2
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_groundTremor, trigger_rootsYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_groundTremor, trigger_rootsOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_groundTremor, trigger_rootsOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_rootsFade, trigger_groundTremorFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_rootsFade, trigger_groundTremorFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_avatarFade, trigger_stunFade, trigger_rootsFade, trigger_sweepingStrikesFade, trigger_groundTremorFade

	self:ThrottleSync(3, syncName.avatar)
	self:ThrottleSync(3, syncName.avatarOver)
	self:ThrottleSync(3, syncName.stun)
	self:ThrottleSync(3, syncName.stunFade)
	self:ThrottleSync(3, syncName.groundTremor)
	self:ThrottleSync(3, syncName.groundTremorFade)
	self:ThrottleSync(3, syncName.roots)
	self:ThrottleSync(0, syncName.rootsFade)
	
	--does he do it on Twow?
	self:ThrottleSync(3, syncName.sweepingStrikes)
	self:ThrottleSync(3, syncName.sweepingStrikesFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.avatar then
		self:Bar(L["bar_avatarCd"], timer.firstAvatar, icon.avatar, true, color.avatarCd)
	end
	
	if self.db.profile.groundtremor then
		self:Bar(L["bar_groundTremorCd"], timer.firstGroundTremor, icon.groundTremor, true, color.groundTremor)
	end
	
	if self.db.profile.puticon then
		self:ScheduleRepeatingEvent("grilekTargetCheck", self.GrilekTarget, 0.5, self)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("grilekTargetCheck")
end

function module:GrilekTarget()
	if (IsRaidLeader() or IsRaidOfficer()) and UnitName("Target") ~= nil and UnitName("TargetTarget") ~= nil then
		if UnitName("Target") == "Gri'lek" and UnitName("TargetTarget") ~= nil then
			SetRaidTargetIcon("TargetTarget",8)
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_avatar"] then
		self:Sync(syncName.avatar)
	elseif msg == L["trigger_avatarFade"] then
		self:Sync(syncName.avatarOver)
	
	elseif msg == L["trigger_stun"] then
		self:Sync(syncName.stun)
	elseif msg == L["trigger_stunFade"] then
		self:Sync(syncName.stunFade)
	
	elseif string.find(msg, L["trigger_groundTremor"]) then
		self:Sync(syncName.groundTremor)
	elseif string.find(msg, L["trigger_groundTremorFade"]) then
		self:Sync(syncName.groundTremorFade)
		
		
	elseif string.find(msg, L["trigger_rootsYou"]) then
		self:Sync(syncName.roots .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_rootsOther"]) then
		local _, _, rootsPlayer, _ = string.find(msg, L["trigger_rootsOther"])
		self:Sync(syncName.roots .. " " .. rootsPlayer)
	
	elseif string.find(msg, L["trigger_rootsFade"]) then
		local _, _, rootsFadePlayer, _ = string.find(msg, L["trigger_rootsFade"])
		if rootsFadePlayer == "you" then rootsFadePlayer = UnitName("Player") end
		self:Sync(syncName.rootsFade .. " " .. rootsFadePlayer)
	
	
	elseif msg == L["trigger_sweepingStrikes"] or msg == L["trigger_sweepingStrikes2"] then
		self:Sync(syncName.sweepingStrikes)
	elseif msg == L["trigger_sweepingStrikesFade"] then
		self:Sync(syncName.sweepingStrikesFade)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.avatar and self.db.profile.avatar then
		self:Avatar()
	elseif sync == syncName.avatarOver and self.db.profile.avatar then
		self:AvatarOver()
		
	elseif sync == syncName.stun and self.db.profile.stun then
		self:Stun()
	elseif sync == syncName.stunFade and self.db.profile.stun then
		self:StunFade()
		
	elseif sync == syncName.groundTremor and self.db.profile.groundtremor then
		self:GroundTremor()
	elseif sync == syncName.groundTremorFade and self.db.profile.groundtremor then
		self:GroundTremorFade()
		
	elseif sync == syncName.roots and rest and self.db.profile.roots then
		self:Roots(rest)
	elseif sync == syncName.rootsFade and rest and self.db.profile.roots then
		self:RootsFade(rest)
		
	elseif sync == syncName.sweepingStrikes and self.db.profile.sweepingstrikes then
		self:SweepingStrikes()
	elseif sync == syncName.sweepingStrikesFade and self.db.profile.sweepingstrikes then
		self:SweepingStrikesFade()
	end
end


function module:Avatar()
	self:RemoveBar(L["bar_avatarCd"])
	
	self:Bar(L["bar_avatarDur"], timer.avatarDur, icon.avatar, true, color.avatarDur)
	self:Message(L["msg_avatar"], "Urgent", false, nil, false)
	self:WarningSign(icon.avatar, 1)
	self:Sound("RunAway")
end

function module:AvatarOver()
	self:RemoveBar(L["bar_avatarDur"])
	self:Bar(L["bar_avatarCd"], timer.avatarCd, icon.avatar, true, color.avatarCd)
end

function module:Stun()
	self:Bar(L["bar_stun"], timer.stun, icon.stun, true, color.stun)
end

function module:StunFade()
	self:RemoveBar(L["bar_stun"])
end

function module:GroundTremor()
	self:RemoveBar(L["bar_groundTremorCd"])
	self:Bar(L["bar_groundTremorDur"], timer.groundTremorDur, icon.groundTremor, true, color.groundTremor)
end

function module:GroundTremorFade()
	self:RemoveBar(L["bar_groundTremorDur"])
	self:Bar(L["bar_groundTremorCd"], timer.groundTremorCd, icon.groundTremor, true, color.groundTremor)
end

function module:Roots(rest)
	self:Bar(rest..L["bar_roots"], timer.roots, icon.roots, true, color.roots)
	
	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Priest" then
		self:WarningSign(icon.roots, 0.7)
		self:Sound("Info")
	end
end

function module:RootsFade(rest)
	self:RemoveBar(rest..L["bar_roots"])
end

function module:SweepingStrikes()
	self:Bar(L["bar_sweepingStrikes"], timer.sweepingStrikes, icon.sweepingStrikes, true, color.sweepingStrikes)
	
	if UnitClass("Player") == "Warrior" or UnitClass("Player") == "Paladin" or UnitClass("Player") == "Rogue" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Druid" then
		self:WarningSign(icon.sweepingStrikes, 1)
		self:Sound("Beware")
	end
end

function module:SweepingStrikesFade()
	self:RemoveBar(L["bar_sweepingStrikes"])
end
