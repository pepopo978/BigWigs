
local module, L = BigWigs:ModuleDeclaration("Flesh Hunter", "Ruins of Ahn'Qiraj")

module.revision = 20041
module.enabletrigger = module.translatedName
module.toggleoptions = {}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "FleshHunter",
	consumeother_trigger = "(.*) is afflicted by Consume",
	consume_bar = " Consumed!",
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	consume = 15,
}

local icon = {
	consume = "spell_nature_drowsy",
}

local syncName = {
	consume = "FleshHunterConsume",
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.consume then
		if rest == UnitName("player") then
			self:Bar(string.format(UnitName("player") .. L["consume_bar"]), timer.consume, icon.consume)
		else
			self:Bar(string.format(rest .. L["consume_bar"] .. " >Click Me!<"), timer.consume, icon.consume)
			self:SetCandyBarOnClick("BigWigsBar "..string.format(rest .. L["consume_bar"] .. " >Click Me!<"), function(name, button, extra) TargetByName(extra, true) end, rest)
		end
	end
end

function module:Event(msg)
	local _,_,consumeother, mcverb = string.find(msg, L["consumeother_trigger"])
	if consumeother then
		self:Sync(syncName.consume .. " " .. consumeother)
	end
end
