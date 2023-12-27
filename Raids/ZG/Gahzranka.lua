
local module, L = BigWigs:ModuleDeclaration("Gahz'ranka", "Zul'Gurub")

module.revision = 30025
module.enabletrigger = module.translatedName
module.toggleoptions = {"frostbreath", "geyser", "slam", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gahzranka",
	
	frostbreath_cmd = "frostbreath",
	frostbreath_name = "Frost Breath alert",
	frostbreath_desc = "Warn when the boss is casting Frost Breath.",

	geyser_cmd = "geyser",
	geyser_name = "Massive Geyser alert",
	geyser_desc = "Warn when the boss is casting Massive Geyser.",
	
	slam_cmd = "slam",
	slam_name = "Slam alert",
	slam_desc = "Warn when the boss is casting Slam.",
	
	trigger_frostbreathCast = "Gahz'ranka begins to perform Frost Breath.",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_frostbreathCast = "FrostBreath Dmg+ManaBurn",
	msg_frostbreathCast = "Frost Breath, Damage + Mana Burn",
	bar_frostbreathCd = "Frost Breath CD",
	trigger_frostbreathYou = "Frost Breath hits you",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_frostBreathYou = "You got Mana Burned by Frost Breath!",
	
	trigger_geyserBegin = "Gahz'ranka begins to cast Massive Geyser.",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_geyserCast = "knockUP - Aggro Drop",
	msg_geyserCast = "knockUP - Aggro Drop",
	trigger_geyserCast = "Gahz'ranka casts Massive Geyser.",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_geyserCd = "knockUP AggroDrop CD",
	
	trigger_slam = "Gahz'ranka Slam",--CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_slam = "knockBACK - CD",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Gahzranka",

	frostbreath_trigger = "Gahz\'ranka comienza a lanzar Aliento de Escarcha\.",
	frostbreath_bar = "Aliento de Escarcha",
	massivegeyser_trigger = "Gahz\'ranka comienza a lanzar Géiser monumental\.",
	massivegeyser_bar = "Géiser monumental",

	--frostbreath_cmd = "frostbreath",
	frostbreath_name = "Alerta de Aliento de Escarcha",
	frostbreath_desc = "Avisa cuando el jefe lance Aliento de Escarcha.",

	--massivegeyser_cmd = "massivegeyser",
	massivegeyser_name = "Alerta de Géiser monumental",
	massivegeyser_desc = "Avisa cuando el jefe lance Géiser monumental.",
} end )

L:RegisterTranslations("deDE", function() return {
	--cmd = "Gahzranka",

	frostbreath_trigger = "Gahz\'ranka beginnt Frostatem auszuf\195\188hren\.",
	frostbreath_bar = "Frostatem",
	massivegeyser_trigger = "Gahz\'ranka beginnt Massiver Geysir zu wirken\.",
	massivegeyser_bar = "Massiver Geysir",

	--frostbreath_cmd = "frostbreath",
	frostbreath_name = "Alarm f\195\188r Frostatem",
	frostbreath_desc = "Warnen wenn Gahz'ranka beginnt Frostatem zu wirken.",

	--massivegeyser_cmd = "massivegeyser",
	massivegeyser_name = "Alarm f\195\188r Massiver Geysir",
	massivegeyser_desc = "Warnen wenn Gahz'ranka beginnt Massiver Geysir zu wirken.",
} end )

local timer = {
	frostbreathCast = 2,
	frostbreathCd = 7,--9 -2sec for cast = 7 (need more data)
	geyserCast = 1.5,
	geyserCd = 19,
	slam = 15,--need more data
}
local icon = {
	frostbreath = "spell_frost_frostnova",--Inflicts Frost damage to enemies in a cone in front of the caster, stealing their mana and reducing their movement speed for 10 sec.
	geyser = "spell_frost_summonwaterelemental",--Reduce Threat
	slam = "ability_devour",--Inflicts normal damage plus 250 to nearby enemies and knocks them back.
}
local color = {
	frostbreathCast = "Blue",
	frostbreathCd = "Black",
	geyserCast = "Red",
	geyserCd = "White",
	slam = "Red",
}
local syncName = {
	frostbreath = "gahzrankaFrostbreath"..module.revision,
	geyserBegin = "gahzrankaGeyserBegin"..module.revision,
	geyserCast = "gahzrankaGeyserCast"..module.revision,
	slam = "gahzrankaSlam"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SAY", "Event")--debug
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--trigger_slam, trigger_frostbreath, trigger_geyserBegin, trigger_geyserCast, trigger_frostbreathYou
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--trigger_slam, trigger_frostbreath, trigger_geyserBegin, trigger_geyserCast
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--trigger_slam, trigger_frostbreath, trigger_geyserBegin, trigger_geyserCast
	
	--self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function module:Event(msg)
	if msg == L["trigger_frostbreathCast"] then
		self:Sync(syncName.frostbreath)
	
	
	elseif string.find(msg, L["trigger_frostbreathYou"]) then
		if UnitClass("Player") == "Priest" then
			self:WarningSign(icon.frostbreath, 0.7)
			self:Sound("Info")
			self:Message(L["msg_frostBreathYou"], "Attention", false, nil, false)
		elseif UnitClass("Player") == "Mage" then
			self:WarningSign(icon.frostbreath, 0.7)
			self:Sound("Info")
			self:Message(L["msg_frostBreathYou"], "Attention", false, nil, false)
		elseif UnitClass("Player") == "Warlock" then
			self:WarningSign(icon.frostbreath, 0.7)
			self:Sound("Info")
			self:Message(L["msg_frostBreathYou"], "Attention", false, nil, false)
		end
		
		
	elseif msg == L["trigger_geyserBegin"] then
		self:Sync(syncName.geyserBegin)
	elseif msg == L["trigger_geyserCast"] then
		self:Sync(syncName.geyserCast)
	
	
	elseif string.find(msg, L["trigger_slam"]) then
		self:Sync(syncName.slam)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frostbreath and self.db.profile.frostbreath then
		self:Frostbreath()
		
	elseif sync == syncName.geyserBegin and self.db.profile.geyser then
		self:GeyserBegin()
	elseif sync == syncName.geyserCast and self.db.profile.geyser then
		self:GeyserCast()
		
	elseif sync == syncName.slam and self.db.profile.slam then
		self:Slam()
	end
end


function module:Frostbreath()
	self:RemoveBar(L["bar_frostbreathCd"])
	self:Bar(L["bar_frostbreathCast"], timer.frostbreathCast, icon.frostbreath, true, color.frostbreathCast)
	self:Message(L["msg_frostbreathCast"])
	self:DelayedBar(timer.frostbreathCast, L["bar_frostbreathCd"], timer.frostbreathCd, icon.frostbreath, true, color.frostbreathCd)
end

function module:GeyserBegin()
	self:RemoveBar(L["bar_geyserCd"])
	self:Bar(L["bar_geyserCast"], timer.geyserCast, icon.geyser, true, color.geyserCast)
	self:Message(L["msg_geyserCast"], "Urgent", false, nil, false)
end

function module:GeyserCast()
	self:RemoveBar(L["bar_geyserCast"])
	self:Bar(L["bar_geyserCd"], timer.geyserCd, icon.geyser, true, color.geyserCd)
end

function module:Slam()
	self:Bar(L["bar_slam"], timer.slam, icon.slam, true, color.slam)
end
