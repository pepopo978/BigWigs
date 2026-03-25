
local module, L = BigWigs:ModuleDeclaration("Living Monstrosity", "Naxxramas")

module.revision = 30067
module.enabletrigger = module.translatedName
module.toggleoptions = {"lightningtotem", "autotarget"}
module.trashMod = true
module.defaultDB = {
	bosskill = false,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Monstrosity",
	
	lightningtotem_cmd = "lightningtotem",
	lightningtotem_name = "Lightning Totem Alert",
	lightningtotem_desc = "Warn for Lightning Totem summon",
	
	autotarget_cmd = "autotarget",
	autotarget_name = "Auto-Target Lightning Totem",
	autotarget_desc = "Targets the totem automatically upon summon",
	
	
	trigger_totemUp = "Living Monstrosity casts Lightning Totem.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_totemUp = "Lightning Totem!",
	
	trigger_totemDead = "Lightning Totem dies.",--CHAT_MSG_COMBAT_HOSTILE_DEATH
	msg_totemDead = "Totem is dead =)",
} end )


L:RegisterTranslations("zhCN", function() return {
	-- Wind汉化修复Turtle-WOW中文数据
	-- Last update: 2024-06-22
    cmd = "Monstrosity",

    lightningtotem_cmd = "lightningtotem",
    lightningtotem_name = "闪电图腾警报",
    lightningtotem_desc = "召唤闪电图腾时进行警告",

    autotarget_cmd = "autotarget",
    autotarget_name = "自动目标闪电图腾",
    autotarget_desc = "召唤图腾时自动选择为目标",

    trigger_totemUp = "畸形妖开始施放闪电图腾。",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
    msg_totemUp = "转火闪电图腾！",

    trigger_totemDead = "闪电图腾死亡了。",--CHAT_MSG_COMBAT_HOSTILE_DEATH
    msg_totemDead = "图腾死了 =)",
} end )
local timer = {
}
local icon = {
	lightningTotem = "Spell_Nature_Lightning"
}
local syncName = {
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--totem up
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event")--totem dead
end

function module:OnSetup()
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_totemUp"] then
		if self.db.profile.lightningtotem then
			self:Message(L["msg_totemUp"], "Urgent", false, nil, false)
			self:WarningSign(icon.lightningTotem, 0.7)
		end
		if self.db.profile.autotarget then
			if UnitClass("Player") == "Rogue" then
				TargetByName("Lightning Totem",true)
				--DEFAULT_CHAT_FRAME:AddMessage("Rogue")
			end
			--if UnitClass("Player") == "Paladin" then
			--	DEFAULT_CHAT_FRAME:AddMessage("Paladin")
			--end
			if UnitClass("Player") == "Hunter" then
				TargetByName("Lightning Totem",true)
				--DEFAULT_CHAT_FRAME:AddMessage("Hunter")
			end
			if UnitClass("Player") == "Warrior" then
				TargetByName("Lightning Totem",true)
				--DEFAULT_CHAT_FRAME:AddMessage("Warrior")
			end
			if UnitClass("Player") == "Mage" then
				TargetByName("Lightning Totem",true)
				--DEFAULT_CHAT_FRAME:AddMessage("Mage")
			end
			if UnitClass("Player") == "Warlock" then
				TargetByName("Lightning Totem",true)
				--DEFAULT_CHAT_FRAME:AddMessage("Warlock")
			end
		end
	elseif msg == L["trigger_totemDead"] and self.db.profile.lightningtotem then
		self:Message(L["msg_totemDead"], "Urgent", false, nil, false)
	end
end
