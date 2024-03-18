
local module, L = BigWigs:ModuleDeclaration("Deathknight Cavalier", "Naxxramas")

module.revision = 30067
module.enabletrigger = {"Deathknight Cavalier", "Death Lord"}
module.toggleoptions = {"deathcoil"}
module.trashMod = true
module.defaultDB = {
	bosskill = nil,
}

L:RegisterTranslations("enUS", function() return {
	cmd = "DeathknightCavalier",

	deathcoil_cmd = "deathcoil",
	deathcoil_name = "Death Coil Alert",
	deathcoil_desc = "Warn for Death Coil",
	
	
	trigger_deathCoilYou = "You are afflicted by Death Coil.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_deathCoilOther = "(.+) is afflicted by Death Coil.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_deathCoilFade = "Death Coil fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_PARTY_OTHER // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_deathCoil = " Death Coil",
	
	["You have slain %s!"] = true,
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	deathCoil = 3,
}
local icon = {
	deathCoil = "spell_shadow_deathcoil",
}
local color = {
	deathCoil = "Black",
}
local syncName = {
	deathCoil = "DeathknightCavalierDeathCoil"..module.revision,
	deathCoilFade = "DeathknightCavalierDeathCoilFade"..module.revision,
}

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event")--Debug
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_deathCoilYou
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_deathCoilOther
	self:RegisterEvent("CHAT_MSG_CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_deathCoilOther
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_deathCoilFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_PARTY_OTHER", "Event") --trigger_deathCoilFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_deathCoilFade
	
	self:ThrottleSync(0.1, syncName.deathCoil)
	self:ThrottleSync(0.1, syncName.deathCoilFade)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CheckForBossDeath(msg)
	if msg == string.format(UNITDIESOTHER, self:ToString())
		or msg == string.format(L["You have slain %s!"], "Deathknight Cavalier")
		or msg == string.format(L["You have slain %s!"], "Death Lord") then
		local function IsBossInCombat()
			local t = module.enabletrigger
			if not t then return false end
			if type(t) == "string" then t = {t} end

			if UnitExists("target") and UnitAffectingCombat("target") then
				local target = UnitName("target")
				for _, mob in pairs(t) do
					if target == mob then
						return true
					end
				end
			end

			local num = GetNumRaidMembers()
			for i = 1, num do
				local raidUnit = string.format("raid%starget", i)
				if UnitExists(raidUnit) and UnitAffectingCombat(raidUnit) then
					local target = UnitName(raidUnit)
					for _, mob in pairs(t) do
						if target == mob then
							return true
						end
					end
				end
			end
			return false
		end

		if not IsBossInCombat() then
			self:SendBossDeathSync()
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_deathCoilYou"] then
		self:Sync(syncName.deathCoil .. " " .. UnitName("Player"))
	
	elseif string.find(msg, L["trigger_deathCoilOther"]) then
		local _,_, deathCoilPlayer, _ = string.find(msg, L["trigger_deathCoilOther"])
		self:Sync(syncName.deathCoil .. " " .. deathCoilPlayer)
	
	elseif string.find(msg, L["trigger_deathCoilFade"]) then
		local _,_, deathCoilFadePlayer, _ = string.find(msg, L["trigger_deathCoilFade"])
		if deathCoilFadePlayer == "you" then deathCoilFadePlayer = UnitName("Player") end
		self:Sync(syncName.deathCoilFade .. " " .. deathCoilFadePlayer)
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.deathCoil and rest and self.db.profile.deathcoil then
		self:DeathCoil(rest)
	elseif sync == syncName.deathCoilFade and rest and self.db.profile.deathcoil then
		self:DeathCoilFade(rest)
	end
end


function module:DeathCoil(rest)
	self:Bar(rest..L["bar_deathCoil"], timer.deathCoil, icon.deathCoil, true, color.deathCoil)
end

function module:DeathCoilFade(rest)
	self:RemoveBar(rest..L["bar_deathCoil"])
end
