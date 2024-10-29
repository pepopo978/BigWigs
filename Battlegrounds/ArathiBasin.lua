----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Arathi Basin", "Arathi Basin")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
	return {
		cmd = "Arathi",
		one_min_countdown_timer = "The Battle for Arathi Basin begins in 1 minute",
		thirty_sec_countdown_timer = "The Battle for Arathi Basin begins in 30 seconds",
		defended = "(.+) has defended the (.+)",
		assaulted = "(.+) has assaulted the (.+)",
		claimed = "(.+) claims the (.+)! If left unchallenged, the (.+) will control it in 1 minute!",
		bar_gameStart = "Game Start",
	}
end)

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20005 -- To be overridden by the module!
module.enabletrigger = { } -- string or table {boss, add1, add2}
module.toggleoptions = {
}


-- locals
local timer = {
	base = 60
}
local icon = {
	bannerA = "inv_bannerpvp_02",
	bannerH = "inv_bannerpvp_01",
	gameStart = "inv_misc_pocketwatch_01"
}

------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "BgEvent")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "BgEvent")
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "BgEvent")
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()

end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers	    --
------------------------------

local _, race = UnitRace('player')
race = string.lower(race)

local faction = 'a'
if race ~= 'human' and race ~= 'gnome' and race ~= 'dwarf' and race ~= 'nightelf' and race ~= 'bloodelf' then
	faction = 'h'
end

function getFaction(j)

	for i = 0, GetNumRaidMembers() do
		if GetRaidRosterInfo(i) then
			local n = GetRaidRosterInfo(i);
			if n == j then
				if faction == 'a' then
					return 'a'
				else
					return 'h'
				end
			end
		end
	end

	return 'a'

end

function bw_ucFirst(a)
	return string.upper(string.sub(a, 1, 1)) .. string.lower(string.sub(a, 2, string.len(a)))
end

function fixBase(f)
	if f == 'lumber mill' then
		return 'Lumber Mill'
	end

	return bw_ucFirst(f)
end

function module:BgEvent(msg)
	local _, _, player, base = string.find(msg, L["assaulted"])
	if player and base then
		local l_icon = icon.bannerA
		if getFaction(player) == 'h' then
			l_icon = icon.bannerH
		end

		self:RemoveBar(bw_ucFirst(base))
		self:Bar(bw_ucFirst(base), timer.base, l_icon)
		return
	end

	local _, _, dplayer, dbase = string.find(msg, L["defended"])
	if dplayer and dbase then
		self:RemoveBar(bw_ucFirst(dbase))
		return
	end

	local _, _, cplayer, cbase, cfaction = string.find(msg, L["claimed"])
	if cplayer and cbase and cfaction then
		local l_icon = icon.bannerA
		if cfaction == 'Horde' then
			l_icon = icon.bannerH
		end

		self:RemoveBar(bw_ucFirst(cbase))
		self:Bar(bw_ucFirst(cbase), timer.base, l_icon)
		return
	end

	if string.find(msg, L["one_min_countdown_timer"]) then
		self:Bar(L["bar_gameStart"], 60, icon.gameStart, true, "White")
		return
	end

	if string.find(msg, L["thirty_sec_countdown_timer"]) then
		self:Bar(L["bar_gameStart"], 30, icon.gameStart, true, "White")
		return
	end
end
