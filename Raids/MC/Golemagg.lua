
local module, L = BigWigs:ModuleDeclaration("Golemagg the Incinerator", "Molten Core")
local BC = AceLibrary("Babble-Class-2.2")

module.revision = 30075
module.enabletrigger = module.translatedName
module.toggleoptions = {"enrage", "earthquake", "magma", "bosskill"}
module.wipemobs = {"Core Rager"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Golemagg",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	earthquake_cmd = "earthquake",
	earthquake_name = "Earthquake Alert",
	earthquake_desc = "Warn for Earthquake",
	
	magma_cmd = "magma",
	magma_name = "Magma Splash Alert",
	magma_desc = "Warn for Magma Splash",
	
	
	trigger_enrage = "Golemagg the Incinerator gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Golemagg is Enraged - Casting Earthquakes!",
	msg_enrageSoon = "Enrage Soon (at 10%) - Earthquake Soon",
	
	trigger_earthquake = "Golemagg the Incinerator's Earthquake", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_earthquake = "Earthquake",
	
	trigger_magmaSplash = "You are afflicted by Magma Splash %((.+)%).", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_magmaSplash = "Warning - High Magma Splash Stacks: ",
} end)

L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
	cmd = "Golemagg",

	enrage_cmd = "enrage",
	enrage_name = "激怒警报",
	enrage_desc = "激怒出现时进行警告",

	earthquake_cmd = "earthquake",
	earthquake_name = "地震术警报",
	earthquake_desc = "地震术出现时进行警告",

	magma_cmd = "magma",
	magma_name = "熔岩喷溅警报",
	magma_desc = "熔岩喷溅出现时进行警告",
	
	
	trigger_enrage = "焚化者古雷曼格获得了激怒的效果。", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "焚化者古雷曼格激怒了 - 正在施放地震术！",
	msg_enrageSoon = "即将激怒（在10%时） - 即将地震",
	
	trigger_earthquake = "焚化者古雷曼格的地震术", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_earthquake = "地震术",
	
	trigger_magmaSplash = "你受到了熔岩喷溅效果的影响%（(.+)%）。", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_magmaSplash = "警告 - 熔岩喷溅层数过高：",
} end)

local timer = {
	earthquake = 3
}
local icon = {
	enrage = "spell_shadow_unholyfrenzy",
	earthquake = "spell_nature_earthquake",
	magmaSplash = "spell_fire_immolation",
}
local color = {
	earthquake = "Orange",
}
local syncName = {
	enrageSoon = "GolemaggEnrageSoon"..module.revision,
	enrage = "GolemaggEnrage"..module.revision,
	earthquake = "GolemaggEarthquake"..module.revision,
}

local enrageSoon = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug
	
	self:RegisterEvent("UNIT_HEALTH")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_enrage
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_earthquake
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") --trigger_earthquake
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_earthquake
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_magmaSplash
	
	
	self:ThrottleSync(10, syncName.enrageSoon)
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(1, syncName.earthquake)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	enrageSoon = nil
end

function module:OnDisengage()
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct > 15 and healthPct <= 20 and enrageSoon == nil and self.db.profile.enrage then
			self:Sync(syncName.enrageSoon)
		elseif healthPct > 21 and enrageSoon == true then
			enrageSoon = nil
		elseif healthPct <= 10 and enrageSoon == nil then
			enrageSoon = true
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	
	elseif string.find(msg, L["trigger_earthquake"]) then
		self:Sync(syncName.earthquake)
	
	elseif string.find(msg, L["trigger_magmaSplash"]) then
		local _,_, stacks, _ = string.find(msg, L["trigger_magmaSplash"])
		local stacksNum = tonumber(stacks)
		if stacksNum >= 12 then
			self:MagmaSplash(stacksNum)
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrageSoon and self.db.profile.enrage then
		self:EnrageSoon()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	
	elseif sync == syncName.earthquake and self.db.profile.earthquake then
		self:Earthquake()
	end
end


function module:EnrageSoon()
	enrageSoon = true
	
	if UnitClass("Player") == BC["Warrior"] or UnitClass("Player") == BC["Rogue"] or UnitClass("Player") == BC["Paladin"] or UnitClass("Player") == BC["Shaman"] or UnitClass("Player") == BC["Druid"] then
		self:Message(L["msg_enrageSoon"], "Attention", false, nil, false)
	end
end

function module:Enrage()
	enrageSoon = true
	
	self:WarningSign(icon.enrage, 1)
	self:Message(L["msg_enrage"], "Urgent", false, nil, false)
	self:Sound("Beware")
	self:Earthquake()
end

function module:Earthquake()
	self:Bar(L["bar_earthquake"], timer.earthquake, icon.earthquake, true, color.earthquake)
end

function module:MagmaSplash(rest)
	self:Message(L["msg_magmaSplash"]..rest)
	self:WarningSign(icon.magmaSplash, 0.7)
end
