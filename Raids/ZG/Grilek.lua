
local module, L = BigWigs:ModuleDeclaration("Gri'lek", "Zul'Gurub")

module.revision = 30047
module.enabletrigger = module.translatedName
module.toggleoptions = {"avatar", "melee", "puticon", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grilek",
	
	avatar_cmd = "avatar",
	avatar_name = "Avatar alert",
	avatar_desc = "Announce when the boss has Avatar (enrage phase).",

	melee_cmd = "melee",
	melee_name = "Warnings for melee",
	melee_desc = "Warn before Avatar is cast, so melee classes can get away from the boss in time.",

	puticon_cmd = "puticon",
	puticon_name = "Place icon",
	puticon_desc = "Place a raid icon on the targetted player.\n\n(Requires assistant or higher)",
	
	trigger_avatar = "Gri'lek gains Avatar.",
	msg_avatarSoon = "Avatar soon! Melee get out!",
	bar_avatar = "Avatar",
	msg_avatar = "Avatar! Run away from the boss!",
	
	trigger_avatarFade = "Avatar fades from Gri'lek.",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Grilek",

	trigger_avatar = "Gri\'lek gana Avatar\.",
	msg_avatarSoon = "¡Avatar pronto! Retroceden los melee!",
	bar_avatar = "Avatar",
	msg_avatar = "¡Avatar! Váyanse del jefe!",
	trigger_avatarFade = "Avatar desaparece de Gri\'lek\.",
	avatar_watch = "¡Gri'lek está viniendo hacia ",

	--avatar_cmd = "avatar",
	avatar_name = "Alerta de Avatar",
	avatar_desc = "Anuncia cuando el jefe tenga Avatar.",

	--melee_cmd = "melee",
	melee_name = "Alerta para melee",
	melee_desc = "Avisa antes de que el jefe lance Avatar para que los melee puedan retroceder del jefe.",

	--announce_cmd = "announce",
	announce_name = "Susurrar a los jugadores",
	announce_desc = "Susurra a los jugadores para que sepan que son el objetivo de Gril'ek.",

	--puticon_cmd = "puticon",
	puticon_name = "Marcar el objetivo de Gri'lek",
	puticon_desc = "Marca con un icono el objetivo de Gri'lek.\n\n(Require asistente o líder)",
} end )

L:RegisterTranslations("deDE", function() return {
	cmd = "Grilek",

	trigger_avatar = "Gri\'lek bekommt \'Avatar\'\.",
	msg_avatarSoon = "Avatar bald! Nahk\195\164mpfer raus!",
	bar_avatar = "Avatar",
	msg_avatar = "Avatar! Geh weg vom Boss!",
	trigger_avatarFade = "Avatar schwindet von Gri\'lek\.",
	avatar_watch = "Gri'lek verfolgt ",

	avatar_cmd = "avatar",
	avatar_name = "Alarm f\195\188r Avatar",
	avatar_desc = "Ank\195\188ndingen wenn der Boss Avatar ist (Raserei Phase).",

	melee_cmd = "melee",
	melee_name = "Warnunken f\195\188r die Nahk\195\164mpfer",
	melee_desc = "Warnt bevor Avatar gewirkt wird, sodass die Nahk\195\164mpfe Zeit haben um sich vom Boss zu entfernen.",

	announce_cmd = "announce",
	announce_name = "Benachrichtigt Spieler",
	announce_desc = "Informiert Spieler, dass Gri\'lek sie verfolgt, sodass sie rechtzeitig weglaufen k\195\182nnen.",

	puticon_cmd = "puticon",
	puticon_name = "Setzt Schlachtzugssymbole",
	puticon_desc = "Setzt ein Schlachtzugssymbol auf den verfolgten Spieler.\n\n(Ben\195\182tigt Schlachtzugleiter oder Assistent)",
} end )

local timer = {
	melee = 10,
	avatar = 15,
}
local icon = {
	avatar = "Ability_Creature_Cursed_05",
}
local color = {
	avatar = "White",
}
local syncName = {
	meleeIni = "GrilekMeleeIni"..module.revision,
	melee = "GrilekMelee"..module.revision,
	avatar = "GrilekAvatar"..module.revision,
	avatarOver = "GrilekAvatarStop"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:ThrottleSync(8, syncName.meleeIni)
	self:ThrottleSync(8, syncName.melee)
	self:ThrottleSync(10, syncName.avatar)
	self:ThrottleSync(10, syncName.avatarOver)
end

function module:OnSetup()
	self.started = nil
	firstwarn = 0
	nameoftarget = nil
	avatarTarget = nil
end

function module:OnEngage()
	if firstwarn == 0 then
		self:Sync(syncName.meleeIni)
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_avatar"] then
		self:Sync(syncName.avatar)
	elseif msg == L["trigger_avatarFade"] then
		self:Sync(syncName.avatarOver)
		self:Sync(syncName.melee)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.meleeIni then
		self:MeleeIni()
		
	elseif sync == syncName.melee and self.db.profile.melee then
		self:Melee()
		
	elseif sync == syncName.avatar and self.db.profile.avatar then
		self:Avatar()
		
	elseif sync == syncName.avatarOver and self.db.profile.avatar then
		self:AvatarOver()
	end
end


function module:MeleeIni()
	firstwarn = 1
	
	if self.db.profile.melee then
		self:Melee()
	end
end

function module:Melee()
	self:DelayedMessage(timer.melee, L["msg_avatarSoon"], "Attention", false, nil, false)
	self:DelayedSound(timer.melee, "Alarm")
end

function module:Avatar()
	self:ScheduleRepeatingEvent("grilektargetchangedcheck", self.TargetChangedCheck, 0.5, self)
	
	self:Bar(L["bar_avatar"], timer.avatar, icon.avatar, true, color.avatar)
	self:Message(L["msg_avatar"], "Urgent", false, nil, false)
end

function module:AvatarOver()
	self:RemoveBar(L["bar_avatar"])
	self:CancelScheduledEvent("grilektargetchangedcheck")
	
	if avatarTarget ~= nil and (IsRaidLeader() or IsRaidOfficer()) and self.db.profile.puticon then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == avatarTarget then
				SetRaidTarget("raid"..i, 0)
			end
		end
	end
end

function module:TargetChangedCheck()
	if UnitName("target") ~= nil and UnitName("targettarget") ~= nil and (IsRaidLeader() or IsRaidOfficer()) then
		if UnitName("target") == "Gri'lek" then
			if self.db.profile.puticon then
				SetRaidTarget("targettarget",8)
			end
			avatarTarget = UnitName("TargetTarget")
		end
	end
end
