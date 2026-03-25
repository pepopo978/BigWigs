local module, L = BigWigs:ModuleDeclaration("Anubisath Defender", "Ahn'Qiraj")

module.revision = 30069
module.enabletrigger = module.translatedName
module.toggleoptions = { "reflect", "plague", "icon", "thunderclap", "shadowstorm", "meteor", -1, "explode", "enrage" }
module.trashMod = true
module.defaultDB = {
	bosskill = false,
}

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Defender",

		reflect_cmd = "reflect",
		reflect_name = "Spell Reflect Alert",
		reflect_desc = "Shows bars for which reflect the Defender has",

		plague_cmd = "plague",
		plague_name = "Plague Alert",
		plague_desc = "Warns for Plague",

		icon_cmd = "icon",
		icon_name = "Raid Icon for Plague",
		icon_desc = "Place Raid Icon on the last plagued person (requires promoted or higher)",

		thunderclap_cmd = "thunderclap",
		thunderclap_name = "Thunder Clap Alert",
		thunderclap_desc = "Warns for Thunder Clap",

		shadowstorm_cmd = "shadowstorm",
		shadowstorm_name = "Shadow Storm Alert",
		shadowstorm_desc = "Warns for Shadow Storm",

		meteor_cmd = "meteor",
		meteor_name = "Meteor Alert",
		meteor_desc = "Warns for Meteor",

		explode_cmd = "explode",
		explode_name = "Explode Alert",
		explode_desc = "Warns for Explode",

		enrage_cmd = "enrage",
		enrage_name = "Enrage Alert",
		enrage_desc = "Warns for Enrage",


		trigger_arcaneFireReflect1 = "Moonfire is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_arcaneFireReflect2 = "Scorch is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_arcaneFireReflect3 = "Flame Shock is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_arcaneFireReflect4 = "Fireball is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_arcaneFireReflect5 = "Flame Lash is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_arcaneFireReflect6 = "Detect Magic is reflected", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		bar_fireArcaneReflect = "Fire & Arcane Reflect",

		trigger_shadowFrostReflect1 = "Shadow Word: Pain is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_shadowFrostReflect2 = "Corruption is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_shadowFrostReflect3 = "Frostbolt is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_shadowFrostReflect4 = "Frost Shock is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
		trigger_shadowFrostReflect5 = "Anubisath Defender is afflicted by Detect Magic.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
		bar_shadowFrostReflect = "Shadow & Frost Reflect",

		trigger_selfReflect = "Your (.*) is reflected back by Anubisath Defender.", --CHAT_MSG_SPELL_SELF_DAMAGE
		msg_selfReflect = "Spell Reflect - STOP KILLING YOURSELF!",

		trigger_plagueYou = "You are afflicted by Plague.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
		trigger_plagueOther = "(.+) is afflicted by Plague.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
		bar_plague = " Plagued",
		msg_plague = "Plague on ",

		trigger_thunderClap = "Anubisath Defender's Thunderclap hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_thunderClap = "Thunder Clap",
		msg_thunderClap = "Thunder Clap - Ranged get Out!",

		trigger_shadowStorm = "Anubisath Defender's Shadow Storm hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_shadowStorm = "Shadow Storm",
		msg_shadowStorm = "Shadow Storm - Ranged get In!",

		trigger_meteor = "Anubisath Defender's Meteor hits", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
		bar_meteor = "Meteor",
		msg_meteor = "Meteor!",

		trigger_explode = "Anubisath Defender gains Explode.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		bar_explode = "Exploding!",
		msg_explode = "Exploding!",

		trigger_enrage = "Anubisath Defender gains Enrage.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
		msg_enrage = "Enraged!",
	}
end)

L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
	cmd = "Defender",
	
	reflect_cmd = "reflect",
    reflect_name = "法术反射警报",
    reflect_desc = "显示防御者拥有的反射法术的计时条",

    plague_cmd = "plague",
    plague_name = "瘟疫警报",
    plague_desc = "瘟疫出现时进行警告",

    icon_cmd = "icon",
    icon_name = "瘟疫团队标记",
    icon_desc = "在最后一个被瘟疫感染的人身上放置团队标记（需要助理或更高权限）",

    thunderclap_cmd = "thunderclap",
    thunderclap_name = "雷霆一击警报",
    thunderclap_desc = "雷霆一击出现时进行警告",

    shadowstorm_cmd = "shadowstorm",
    shadowstorm_name = "暗影风暴警报",
    shadowstorm_desc = "暗影风暴出现时进行警告",

    meteor_cmd = "meteor",
    meteor_name = "流星警报",
    meteor_desc = "流星出现时进行警告",

    explode_cmd = "explode",
    explode_name = "爆炸警报",
    explode_desc = "爆炸出现时进行警告",

    enrage_cmd = "enrage",
    enrage_name = "激怒警报",
    enrage_desc = "激怒出现时进行警告",
	
	
	trigger_arcaneFireReflect1 = "月火术被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect2 = "灼烧被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect3 = "烈焰震击被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect4 = "火球术被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect5 = "烈焰鞭笞被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_arcaneFireReflect6 = "侦测魔法被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
    bar_fireArcaneReflect = "火焰 & 奥术反射",
	
	trigger_shadowFrostReflect1 = "暗言术：痛被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect2 = "腐蚀术被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect3 = "寒冰箭被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect4 = "冰霜震击被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PARTY_DAMAGE // CHAT_MSG_SPELL_SELF_DAMAGE
	trigger_shadowFrostReflect5 = "阿努比萨斯防御者受到了侦测魔法效果的影响。",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
    bar_shadowFrostReflect = "暗影 & 冰霜反射",
	
	trigger_selfReflect = "你的(.*)被阿努比萨斯防御者反弹回来。",--CHAT_MSG_SPELL_SELF_DAMAGE
    msg_selfReflect = "法术反射 - 停止自残！",
	
	trigger_plagueYou = "你受到了瘟疫效果的影响。", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_plagueOther = "(.+)受到了瘟疫效果的影响。", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
    bar_plague = "瘟疫",
    msg_plague = "瘟疫在 ",
	
	trigger_thunderClap = "阿努比萨斯防御者的雷霆震击", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_thunderClap = "雷霆一击",
    msg_thunderClap = "雷霆一击 - 远程远离！",

	trigger_shadowStorm = "阿努比萨斯防御者的暗影风暴", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_shadowStorm = "暗影风暴",
    msg_shadowStorm = "暗影风暴 - 远程靠近！",

	trigger_meteor = "阿努比萨斯防御者的流星", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE // CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
    bar_meteor = "流星",
    msg_meteor = "流星！",
	
	trigger_explode = "阿努比萨斯防御者获得了爆炸的效果。", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
    bar_explode = "即将爆炸！",
    msg_explode = "即将爆炸！快跑！！！",

	trigger_enrage = "阿努比萨斯防御者获得了狂怒的效果。", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
    msg_enrage = "狂暴！加大治疗！",
} end )
local timer = {
	--the timers for tClap, sStorm, meteor vary too much,
	--will just put 600 so bars tell people what abilities they have
	fireArcaneReflect = 600,
	shadowFrostReflect = 600,
	plague = 40,
	thunderClap = 600, --saw 3 and saw 8
	shadowStorm = 600,
	meteor = 600, --saw 6.4 and saw 13
	explode = 6,
}
local icon = {
	fireArcaneReflect = "spell_arcane_portaldarnassus",
	shadowFrostReflect = "spell_arcane_portalundercity",
	plague = "Spell_Shadow_CurseOfTounges",
	thunderClap = "Ability_ThunderClap",
	shadowStorm = "spell_shadow_shadowbolt",
	meteor = "Spell_Fire_Fireball02",
	explode = "spell_fire_selfdestruct",
	enrage = "spell_shadow_unholyfrenzy",
}
local color = {
	fireArcaneReflect = "Red",
	shadowFrostReflect = "Blue",
	plague = "Green",
	thunderClap = "Yellow",
	shadowStorm = "White",
	meteor = "Cyan",
	explode = "Black",
}
local syncName = {
	fireArcaneReflect = "DefenderArcaneReflect" .. module.revision,
	shadowFrostReflect = "DefenderShadowReflect" .. module.revision,
	plague = "DefenderPlague" .. module.revision,
	thunderClap = "DefenderThunderclap" .. module.revision,
	shadowStorm = "DefenderShadowstorm" .. module.revision,
	meteor = "DefenderMeteor" .. module.revision,
	explode = "DefenderExplode" .. module.revision,
	enrage = "DefenderEnrage" .. module.revision,
}

local fireArcaneReflectFound = nil
local shadowFrostReflectFound = nil
local thunderClapFound = nil
local shadowStormFound = nil
local meteorFound = nil

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --debug

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")--arcaneFireReflect, shadowFrostReflect, trigger_selfReflect
	self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")--arcaneFireReflect, shadowFrostReflect
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")--arcaneFireReflect, shadowFrostReflect
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")--Anubisath Defender is afflicted by Detect Magic

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--Explosion and Enrage

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_plagueYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_plagueOther
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_plagueOther

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--Thunderclap and Shadowstorm


	self:ThrottleSync(5, syncName.fireArcaneReflect)
	self:ThrottleSync(5, syncName.shadowFrostReflect)
	self:ThrottleSync(5, syncName.plague)
	self:ThrottleSync(5, syncName.thunderClap)
	self:ThrottleSync(5, syncName.shadowStorm)
	self:ThrottleSync(5, syncName.meteor)
	self:ThrottleSync(5, syncName.explode)
	self:ThrottleSync(5, syncName.enrage)
end

function module:OnSetup()
end

function module:OnEngage()
	fireArcaneReflectFound = nil
	shadowFrostReflectFound = nil
	thunderClapFound = nil
	shadowStormFound = nil
	meteorFound = nil

	--in case the bars are still there when pulling a new one
	self:RemoveBar(L["bar_fireArcaneReflect"])
	self:RemoveBar(L["bar_shadowFrostReflect"])
	self:RemoveBar(L["bar_shadowStorm"])
	self:RemoveBar(L["bar_thunderClap"])
	self:RemoveBar(L["bar_meteor"])
end

function module:OnDisengage()
	fireArcaneReflectFound = nil
	shadowFrostReflectFound = nil
	thunderClapFound = nil
	shadowStormFound = nil
	meteorFound = nil
end

function module:Event(msg)
	if string.find(msg, L["trigger_selfReflect"]) and not (string.find(msg, "Elemental Vulnerability") or string.find(msg, "Fire Strike")) then
		self:SelfReflect()
	end

	if string.find(msg, L["trigger_arcaneFireReflect1"]) or
			string.find(msg, L["trigger_arcaneFireReflect2"]) or
			string.find(msg, L["trigger_arcaneFireReflect3"]) or
			string.find(msg, L["trigger_arcaneFireReflect4"]) or
			string.find(msg, L["trigger_arcaneFireReflect5"]) or
			string.find(msg, L["trigger_arcaneFireReflect6"]) then
		self:Sync(syncName.fireArcaneReflect)

	elseif string.find(msg, L["trigger_shadowFrostReflect1"]) or
			string.find(msg, L["trigger_shadowFrostReflect2"]) or
			string.find(msg, L["trigger_shadowFrostReflect3"]) or
			string.find(msg, L["trigger_shadowFrostReflect4"]) or
			string.find(msg, L["trigger_shadowFrostReflect5"]) then
		self:Sync(syncName.shadowFrostReflect)


	elseif msg == L["trigger_plagueYou"] then
		self:Sync(syncName.plague .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_plagueOther"]) then
		local _, _, plaguePlayer, _ = string.find(msg, L["trigger_plagueOther"])
		self:Sync(syncName.plague .. " " .. plaguePlayer)

	elseif string.find(msg, L["trigger_thunderClap"]) then
		self:Sync(syncName.thunderClap)
	elseif string.find(msg, L["trigger_shadowStorm"]) then
		self:Sync(syncName.shadowStorm)

	elseif string.find(msg, L["trigger_meteor"]) then
		self:Sync(syncName.meteor)

	elseif msg == L["trigger_explode"] then
		self:Sync(syncName.explode)
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.fireArcaneReflect and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.shadowFrostReflect and self.db.profile.reflect then
		self:ShadowReflect()

	elseif sync == syncName.plague and rest and self.db.profile.plague then
		self:Plague(rest)

	elseif sync == syncName.thunderClap and self.db.profile.thunderclap then
		self:Thunderclap()
	elseif sync == syncName.shadowStorm and self.db.profile.shadowstorm then
		self:ShadowStorm()

	elseif sync == syncName.meteor and self.db.profile.meteor then
		self:Meteor()

	elseif sync == syncName.explode and self.db.profile.explode then
		self:Explode()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end

function module:ArcaneReflect()
	if fireArcaneReflectFound == nil then
		self:Bar(L["bar_fireArcaneReflect"], timer.fireArcaneReflect, icon.fireArcaneReflect, true, color.fireArcaneReflect)

		if UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" then
			self:WarningSign(icon.fireArcaneReflect, 1)
		end

		self:RemoveBar(L["bar_shadowFrostReflect"])

		shadowFrostReflectFound = nil
		fireArcaneReflectFound = true
	end
end

function module:ShadowReflect()
	if shadowFrostReflectFound == nil then
		self:Bar(L["bar_shadowFrostReflect"], timer.shadowFrostReflect, icon.shadowFrostReflect, true, color.shadowFrostReflect)

		if UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" or UnitClass("Player") == "Priest" or UnitClass("Player") == "Shaman" then
			self:WarningSign(icon.shadowFrostReflect, 1)
		end

		self:RemoveBar(L["bar_fireArcaneReflect"])

		shadowFrostReflectFound = true
		fireArcaneReflectFound = nil
	end
end

function module:Plague(rest)
	self:Bar(rest .. L["bar_plague"], timer.plague, icon.plague, true, color.plague)
	self:Message(L["msg_plague"] .. rest, "Important", false, nil, false)

	if rest == UnitName("Player") then
		self:WarningSign(icon.plague, 1)
		SendChatMessage("Plague on " .. rest .. "!", "SAY")
		self:Sound("Plague")
	end

	if self.db.profile.icon and (IsRaidLeader() or IsRaidOfficer()) then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid" .. i) == rest then
				SetRaidTarget("raid" .. i, 8)
			end
		end
	end

	meteorFound = nil
end

function module:Thunderclap()
	if thunderClapFound == nil then
		self:Bar(L["bar_thunderClap"], timer.thunderClap, icon.thunderClap, true, color.thunderClap)
		self:Message(L["msg_thunderClap"], "Urgent", false, nil, false)
		self:WarningSign(icon.thunderClap, 1)
		self:Sound("Beware")
	end

	self:RemoveBar(L["bar_shadowStorm"])

	thunderClapFound = true
	shadowStormFound = nil
end

function module:ShadowStorm()
	if shadowStormFound == nil then
		self:Bar(L["bar_shadowStorm"], timer.shadowStorm, icon.shadowStorm, true, color.shadowStorm)
		self:Message(L["msg_shadowStorm"], "Attention", false, nil, false)
		self:WarningSign(icon.shadowStorm, 1)
		self:Sound("Beware")
	end

	self:RemoveBar(L["bar_thunderClap"])

	thunderClapFound = nil
	shadowStormFound = true
end

function module:Meteor()
	if meteorFound == nil then
		self:Bar(L["bar_meteor"], timer.meteor, icon.meteor, true, color.meteor)
		self:Message(L["msg_meteor"], "Important", false, nil, false)
		self:WarningSign(icon.meteor, 1)
	end

	meteorFound = true
end

function module:Explode()
	self:Bar(L["bar_explode"], timer.explode, icon.explode, true, color.explode)
	self:Message(L["msg_explode"], "Urgent", false, nil, false)
	self:WarningSign(icon.explode, timer.explode)
	self:Sound("RunAway")
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important", false, nil, false)
	self:WarningSign(icon.enrage, 1)
end

function module:SelfReflect()
	self:Message(L["msg_selfReflect"], "Personal", false, nil, false)
	self:Sound("Info")
end
