local module, L = BigWigs:ModuleDeclaration("Nerubian Overseer", "Eastern Plaguelands")

module.revision = 30070
module.enabletrigger = module.translatedName
module.toggleoptions = { "shadowshock", "venomspit", "poisoncloud", "corrosivepoison", "necroticpoison", "webspray", "explode", "bosskill" }
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
	AceLibrary("Babble-Zone-2.2")["Eastern Plaguelands"],
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "NerubianOverseer",

		shadowshock_cmd = "shadowshock",
		shadowshock_name = "Shadow Shock adds Alert",
		shadowshock_desc = "Warn for Shadow Shock",

		venomspit_cmd = "venomspit",
		venomspit_name = "Venom Spit adds Alert",
		venomspit_desc = "Warn for Venom Spit",

		poisoncloud_cmd = "poisoncloud",
		poisoncloud_name = "Poison Cloud Alert",
		poisoncloud_desc = "Warns for Poison Cloud",

		corrosivepoison_cmd = "corrosivepoison",
		corrosivepoison_name = "Corrosive Poison Alert",
		corrosivepoison_desc = "Warns for Corrosive Poison",

		necroticpoison_cmd = "necroticpoison",
		necroticpoison_name = "Necrotic Poison Alert",
		necroticpoison_desc = "Warns for Necrotic Poison",

		webspray_cmd = "webspray",
		webspray_name = "Web Spray Alert",
		webspray_desc = "Warns for Web Spray",

		explode_cmd = "explode",
		explode_name = "Explode Alert",
		explode_desc = "Warns for Explode",


		--750 shadow damage, 10sec CD
		trigger_shadowShock = "Nerubian Overseer's Shadow Shock hits", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
		bar_shadowShock = "Shadow Shock",

		--poison dot, 30sec flat
		trigger_venomSpit = "afflicted by Venom Spit", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_venomSpit = "Venom Spit",

		trigger_poisonCloud = "You are afflicted by Poison Cloud.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_poisonCloudFade = "Poison Cloud fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF

		-- -5k armor, 700dmg/5sec 30sec, poison
		trigger_corrosivePoison = "(.+) is afflicted by Corrosive Poison.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_corrosivePoisonYou = "You are afflicted by Corrosive Poison.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_corrosivePoisonFade = "Corrosive Poison fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
		bar_corrosivePoison = " Corrosive Poison",

		-- -90% healing, 30sec, happens on anyone, often, only warn if on tank
		trigger_necroticPoison = "(.+) is afflicted by Necrotic Poison.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_necroticPoisonYou = "You are afflicted by Necrotic Poison.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_necroticPoisonFade = "Necrotic Poison fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_OTHER // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_SELF
		bar_necroticPoison = " Necrotic Poison",

		trigger_webSpray = "(.+) is afflicted by Web Spray.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
		trigger_webSprayYou = "You are afflicted by Web Spray.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		bar_webSprayCd = "Next Web Spray",
		bar_webSprayAfflic = " Web Spray",

		trigger_explode = "(.+) explodes.", --CHAT_MSG_RAID_BOSS_EMOTE
		trigger_explodeYou = "You explode.", --CHAT_MSG_RAID_BOSS_EMOTE
		msg_explode = " exploded, 4 Nerublings spawned!",
	}
end)

local timer = {
	shadowShock = 10,
	venomSpit = 30,
	poisonCloud = 30,
	corrosivePoison = 30,
	necroticPoison = 30,
	firstWebSprayCd = 19,
	webSprayCd = 24,
	webSprayAfflic = 10,
}
local icon = {
	shadowShock = "spell_shadow_shadowbolt",
	venomSpit = "spell_nature_corrosivebreath",
	poisonCloud = "spell_nature_abolishmagic",
	corrosivePoison = "Corrosive Acid Spit",
	necroticPoison = "ability_creature_poison_03",
	webSprayCd = "spell_nature_web",
	webSprayAfflic = "inv_egg_04",

	poisonTotem = "spell_nature_poisoncleansingtotem"
}
local color = {
	shadowShock = "Black",
	venomSpit = "Green",
	corrosivePoison = "White",
	necroticPoison = "Red",
	webSprayCd = "Cyan",
	webSprayAfflic = "Orange",
}
local syncName = {
	shadowShock = "NerubOverShadowShock" .. module.revision,
	venomSpit = "NerubOverVenomSpit" .. module.revision,
	corrosivePoison = "NerubOverCorrosivePoison" .. module.revision,
	corrosivePoisonFade = "NerubOverCorrosivePoisonFade" .. module.revision,
	necroticPoison = "NerubOverNecroticPoison" .. module.revision,
	necroticPoisonFade = "NerubOverNecroticPoisonFade" .. module.revision,
	webSprayCd = "NerubOverWebSprayCd" .. module.revision,
	webSprayAfflic = "NerubOverWebSprayAfflic" .. module.revision,
	explode = "NerubOverExplode" .. module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug

	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")--trigger_explode, trigger_explodeYou

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_shadowShock
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_shadowShock

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_venomSpit, trigger_poisonCloud, trigger_corrosivePoisonYou, trigger_necroticPoisonYou, trigger_webSprayYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_venomSpit, trigger_corrosivePoison, trigger_necroticPoison, trigger_webSpray
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_venomSpit, trigger_corrosivePoison, trigger_necroticPoison, trigger_webSpray

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--trigger_poisonCloudFade, trigger_corrosivePoisonFade, trigger_necroticPoisonFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")--trigger_corrosivePoisonFade, trigger_necroticPoisonFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--trigger_corrosivePoisonFade, trigger_necroticPoisonFade

	self:ThrottleSync(3, syncName.shadowShock)
	self:ThrottleSync(10, syncName.venomSpit)
	self:ThrottleSync(1, syncName.corrosivePoison)
	self:ThrottleSync(0, syncName.corrosivePoisonFade)
	self:ThrottleSync(1, syncName.necroticPoison)
	self:ThrottleSync(0, syncName.necroticPoisonFade)
	self:ThrottleSync(2, syncName.webSprayCd)
	self:ThrottleSync(3, syncName.webSprayAfflic)
	self:ThrottleSync(3, syncName.explode)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.shadowshock then
		self:ShadowShock()
	end

	if self.db.profile.venomspit then
		self:VenomSpit()
	end

	if self.db.profile.webspray then
		self:Bar(L["bar_webSprayCd"], timer.firstWebSprayCd, icon.webSprayCd, true, color.webSprayCd)
		self:DelayedSync(timer.firstWebSprayCd, syncName.webSprayCd)
	end
end

function module:OnDisengage()
	self:CancelScheduledEvent("webSprayCdBar")
end

function module:CHAT_MSG_RAID_BOSS_EMOTE(msg, sender)
	if string.find(msg, L["trigger_explode"]) then
		local _, _, explodePlayer, _ = string.find(msg, L["trigger_explode"])
		self:Sync(syncName.explode .. " " .. explodePlayer)

	elseif string.find(msg, L["trigger_explodeYou"]) then
		self:Sync(syncName.explode .. " " .. UnitName("Player"))
	end
end

function module:Event(msg)
	if string.find(msg, L["trigger_shadowShock"]) then
		self:Sync(syncName.shadowShock)

	elseif string.find(msg, L["trigger_venomSpit"]) then
		self:Sync(syncName.venomSpit)

	elseif msg == L["trigger_poisonCloud"] then
		self:PoisonCloud()
	elseif msg == L["trigger_poisonCloudFade"] then
		self:PoisonCloudFade()


	elseif string.find(msg, L["trigger_corrosivePoison"]) then
		local _, _, corrosivePlayer, _ = string.find(msg, L["trigger_corrosivePoison"])
		self:Sync(syncName.corrosivePoison .. " " .. corrosivePlayer)

	elseif msg == L["trigger_corrosivePoisonYou"] then
		self:Sync(syncName.corrosivePoison .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_corrosivePoisonFade"]) then
		local _, _, corrosiveFadePlayer, _ = string.find(msg, L["trigger_corrosivePoisonFade"])
		if corrosiveFadePlayer == "you" then
			corrosiveFadePlayer = UnitName("Player")
		end
		self:Sync(syncName.corrosivePoisonFade .. " " .. corrosiveFadePlayer)


	elseif string.find(msg, L["trigger_necroticPoison"]) then
		local _, _, necroticPlayer, _ = string.find(msg, L["trigger_necroticPoison"])
		if UnitName("Target") == "Nerubian Overseer" and UnitName("TargetTarget") == necroticPlayer then
			self:Sync(syncName.necroticPoison .. " " .. necroticPlayer)
		end

	elseif msg == L["trigger_necroticPoisonYou"] then
		if UnitName("Target") == "Nerubian Overseer" and UnitName("TargetTarget") == UnitName("Player") then
			self:Sync(syncName.necroticPoison .. " " .. UnitName("Player"))
		end

	elseif string.find(msg, L["trigger_necroticPoisonFade"]) then
		local _, _, necroticFadePlayer, _ = string.find(msg, L["trigger_necroticPoisonFade"])
		if necroticFadePlayer == "you" then
			necroticFadePlayer = UnitName("Player")
		end
		self:Sync(syncName.necroticPoisonFade .. " " .. necroticFadePlayer)


	elseif string.find(msg, L["trigger_webSpray"]) then
		local _, _, webSprayPlayer, _ = string.find(msg, L["trigger_webSpray"])
		self:Sync(syncName.webSprayAfflic .. " " .. webSprayPlayer)

	elseif msg == L["trigger_webSprayYou"] then
		self:Sync(syncName.webSprayAfflic .. " " .. UnitName("Player"))
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shadowShock and self.db.profile.shadowshock then
		self:ShadowShock()
	elseif sync == syncName.venomSpit and self.db.profile.venomspit then
		self:VenomSpit()
	elseif sync == syncName.corrosivePoison and rest and self.db.profile.corrosivepoison then
		self:CorrosivePoison(rest)
	elseif sync == syncName.corrosivePoisonFade and rest and self.db.profile.corrosivepoison then
		self:CorrosivePoisonFade(rest)
	elseif sync == syncName.necroticPoison and rest and self.db.profile.necroticpoison then
		self:NecroticPoison(rest)
	elseif sync == syncName.necroticPoisonFade and rest and self.db.profile.necroticpoison then
		self:NecroticPoisonFade(rest)
	elseif sync == syncName.webSprayAfflic and rest and self.db.profile.webspray then
		self:WebSprayAfflic(rest)
	elseif sync == syncName.webSprayCd and self.db.profile.webspray then
		self:WebSprayCd()
	elseif sync == syncName.explode and rest and self.db.profile.explode then
		self:Explode(rest)
	end
end

function module:ShadowShock()
	self:RemoveBar(L["bar_shadowShock"])
	self:Bar(L["bar_shadowShock"], timer.shadowShock, icon.shadowShock, true, color.shadowShock)
end

function module:VenomSpit()
	self:RemoveBar(L["bar_venomSpit"])
	self:Bar(L["bar_venomSpit"], timer.venomSpit, icon.venomSpit, true, color.venomSpit)

	if UnitClass("Player") == "Shaman" then
		self:WarningSign(icon.poisonTotem, 0.7)
	end
end

function module:PoisonCloud()
	self:WarningSign(icon.poisonCloud, timer.poisonCloud)
	self:Sound("RunAway")
end

function module:PoisonCloudFade()
	self:RemoveWarningSign(icon.poisonCloud)
end

function module:CorrosivePoison(rest)
	self:Bar(rest .. L["bar_corrosivePoison"], timer.corrosivePoison, icon.corrosivePoison, true, color.corrosivePoison)

	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Druid" then
		self:WarningSign(icon.corrosivePoison, 0.7)
	end
end

function module:CorrosivePoisonFade(rest)
	self:RemoveBar(rest .. L["bar_corrosivePoison"])
end

function module:NecroticPoison(rest)
	self:Bar(rest .. L["bar_necroticPoison"], timer.necroticPoison, icon.necroticPoison, true, color.necroticPoison)

	if UnitClass("Player") == "Paladin" or UnitClass("Player") == "Shaman" or UnitClass("Player") == "Druid" then
		self:WarningSign(icon.necroticPoison, 0.7)
	end
end

function module:NecroticPoisonFade(rest)
	self:RemoveBar(rest .. L["bar_necroticPoison"])
end

function module:WebSprayAfflic(rest)
	self:Bar(rest .. L["bar_webSprayAfflic"], timer.webSprayAfflic, icon.webSprayAfflic, true, color.webSprayAfflic)

	self:Sync(syncName.webSprayCd)
end

function module:WebSprayCd()
	self:CancelScheduledEvent("webSprayCdBar")
	self:ScheduleRepeatingEvent("webSprayCdBar", self.WebSprayCdBar, timer.webSprayCd, self)

	self:WebSprayCdBar()
end

function module:Explode(rest)
	self:RemoveBar(rest .. L["bar_webSprayAfflic"])
	self:Message(rest .. L["msg_explode"], "Attention", false, nil, false)
end

function module:WebSprayCdBar()
	self:RemoveBar(L["bar_webSprayCd"])
	self:Bar(L["bar_webSprayCd"], timer.webSprayCd, icon.webSprayCd, true, color.webSprayCd)
end
