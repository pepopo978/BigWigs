assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsRaidIcon")
local lastplayer = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
	return {
		["Raid Icons"] = true,

		["raidicon"] = true,
		["place"] = true,
		["icon"] = true,
		["sticky"] = true,
		["chat"] = true,

		["Place"] = true,
		["Place Raid Icons"] = true,
		["Toggle placing of Raid Icons on players."] = true,

		["Icon"] = true,
		["Set Icon"] = true,
		["Set which icon to place on players."] = true,

		["Sticky"] = true,
		["Sticky Markers"] = true,
		["Markers are not removed by reapplying the same mark on a unit."] = true,

		["Chat"] = true,
		["Chat Markers"] = true,
		["Type {marker} to post it in chat channels."] = true,

		["Options for Raid Icons."] = true,

		["star"] = true,
		["circle"] = true,
		["diamond"] = true,
		["triangle"] = true,
		["moon"] = true,
		["square"] = true,
		["cross"] = true,
		["skull"] = true,
	}
end)

L:RegisterTranslations("esES", function()
	return {
		["Raid Icons"] = "Iconos de Banda",

		--["raidicon"] = "iconobanda",
		--["place"] = "colocar",
		--["icon"] = "icono",

		["Place"] = "Marcar",
		["Place Raid Icons"] = "Marcar con los iconos de banda",
		["Toggle placing of Raid Icons on players."] = "Alterna marcar los Iconos de Banda a los jugadores",

		["Icon"] = "Icono",
		["Set Icon"] = "Definir Icono",
		["Set which icon to place on players."] = "Define cual icono que marcar al jugador",

		["Options for Raid Icons."] = "Opciones para Iconos de Banda",

		["star"] = "estrella",
		["circle"] = "círculo",
		["diamond"] = "diamante",
		["triangle"] = "triángulo",
		["moon"] = "luna",
		["square"] = "cuadrado",
		["cross"] = "cruz",
		["skull"] = "calavera",
	}
end)

L:RegisterTranslations("koKR", function()
	return {
		["Raid Icons"] = "공격대 아이콘",

		["Place"] = "지정",
		["Place Raid Icons"] = "공격대 아이콘 지정",
		["Toggle placing of Raid Icons on players."] = "플레이어에 공격대 아이콘 지정 토글",

		["Icon"] = "아이콘",
		["Set Icon"] = "아이콘 설정",
		["Set which icon to place on players."] = "플레이어에 아이콘 지정을 위한 설정",

		["Options for Raid Icons."] = "공격대 아이콘에 대한 설정",

		["star"] = "별",
		["circle"] = "원",
		["diamond"] = "다이아몬드",
		["triangle"] = "세모",
		["moon"] = "달",
		["square"] = "네모",
		["cross"] = "가위표",
		["skull"] = "해골",

	}
end)

L:RegisterTranslations("zhCN", function()
	return {
		["Raid Icons"] = "团队图标",

		["Place"] = "标记",
		["Place Raid Icons"] = "标记团队图标",
		["Toggle placing of Raid Icons on players."] = "切换是否在玩家身上标记团队图标",

		["Icon"] = "图标",
		["Set Icon"] = "设置图标",
		["Set which icon to place on players."] = "设置玩家身上标记的图标。",

		["Options for Raid Icons."] = "团队图标设置",

		["star"] = "星星",
		["circle"] = "圆圈",
		["diamond"] = "钻石",
		["triangle"] = "三角",
		["moon"] = "月亮",
		["square"] = "方形",
		["cross"] = "十字",
		["skull"] = "骷髅",
	}
end)

L:RegisterTranslations("zhTW", function()
	return {
		["Raid Icons"] = "團隊圖示",

		["Place"] = "標記",
		["Place Raid Icons"] = "標記團隊圖示",
		["Toggle placing of Raid Icons on players."] = "切換是否在玩家身上標記團隊圖示",

		["Icon"] = "圖標",
		["Set Icon"] = "設置圖示",
		["Set which icon to place on players."] = "設置玩家身上標記的圖示。",

		["Options for Raid Icons."] = "團隊圖示設置",

		["star"] = "星星",
		["circle"] = "圓圈",
		["diamond"] = "方塊",
		["triangle"] = "三角",
		["moon"] = "月亮",
		["square"] = "方形",
		["cross"] = "十字",
		["skull"] = "骷髏",
	}
end)

L:RegisterTranslations("deDE", function()
	return {
		["Raid Icons"] = "Schlachtzug-Symbole",

		--["raidicon"] = "schlachtzugsymbol",
		--["place"] = "position",
		--["icon"] = "symbol",

		["Place"] = "Platzierung",
		["Place Raid Icons"] = "Schlachtzug-Symbole platzieren",
		["Toggle placing of Raid Icons on players."] = "Schlachtzug-Symbole auf Spieler setzen.",

		["Icon"] = "Symbol",
		["Set Icon"] = "Symbol platzieren",
		["Set which icon to place on players."] = "W\195\164hle, welches Symbol auf Spieler gesetzt wird.",

		["Options for Raid Icons."] = "Optionen f\195\188r Schlachtzug-Symbole.",

		["star"] = "Stern",
		["circle"] = "Kreis",
		["diamond"] = "Diamant",
		["triangle"] = "Dreieck",
		["moon"] = "Mond",
		["square"] = "Quadrat",
		["cross"] = "Kreuz",
		["skull"] = "Totenkopf",
	}
end)

L:RegisterTranslations("frFR", function()
	return {
		["Raid Icons"] = "Icônes de raid",

		["Place"] = "Placement",
		["Place Raid Icons"] = "Placer les icônes de raid",
		["Toggle placing of Raid Icons on players."] = "Place ou non les icônes de raid sur les joueurs.",

		["Icon"] = "Icône",
		["Set Icon"] = "Déterminer l'icône",
		["Set which icon to place on players."] = "Détermine quelle icône sera placée sur les joueurs.",

		["Options for Raid Icons."] = "Options concernant les icônes de raid.",

		["star"] = "étoile",
		["circle"] = "cercle",
		["diamond"] = "diamant",
		["triangle"] = "triangle",
		["moon"] = "lune",
		["square"] = "carré",
		["cross"] = "croix",
		["skull"] = "crâne",
	}
end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsRaidIcon = BigWigs:NewModule(L["Raid Icons"], "AceHook-2.1")
BigWigsRaidIcon.defaultDB = {
	place = true,
	icon = L["skull"],
	sticky = true,
	chat = true,
}
BigWigsRaidIcon.icontonumber = {
	[L["star"]] = 1,
	[L["circle"]] = 2,
	[L["diamond"]] = 3,
	[L["triangle"]] = 4,
	[L["moon"]] = 5,
	[L["square"]] = 6,
	[L["cross"]] = 7,
	[L["skull"]] = 8,
}
BigWigsRaidIcon.consoleCmd = L["raidicon"]
BigWigsRaidIcon.consoleOptions = {
	type = "group",
	name = L["Raid Icons"],
	desc = L["Options for Raid Icons."],
	args = {
		[L["place"]] = {
			type = "toggle",
			name = L["Place Raid Icons"],
			desc = L["Toggle placing of Raid Icons on players."],
			get = function()
				return BigWigsRaidIcon.db.profile.place
			end,
			set = function(v)
				BigWigsRaidIcon.db.profile.place = v
			end,
		},
		[L["icon"]] = {
			type = "text",
			name = L["Set Icon"],
			desc = L["Set which icon to place on players."],
			get = function()
				return BigWigsRaidIcon.db.profile.icon
			end,
			set = function(v)
				BigWigsRaidIcon.db.profile.icon = v
			end,
			validate = { L["star"], L["circle"], L["diamond"], L["triangle"], L["moon"], L["square"], L["cross"], L["skull"] },
		},
		[L["sticky"]] = {
			type = "toggle",
			name = L["Sticky Markers"],
			desc = L["Markers are not removed by reapplying the same mark on a unit."],
			get = function()
				return BigWigsRaidIcon.db.profile.sticky
			end,
			set = function(v)
				BigWigsRaidIcon.db.profile.sticky = v
			end,
		},
		[L["chat"]] = {
			type = "toggle",
			name = L["Chat Markers"],
			desc = L["Type {marker} to post it in chat channels."],
			get = function()
				return BigWigsRaidIcon.db.profile.chat
			end,
			set = function(v)
				BigWigsRaidIcon.db.profile.chat = v
			end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsRaidIcon:OnEnable()
	self:RegisterEvent("BigWigs_SetRaidIcon")
	self:RegisterEvent("BigWigs_RemoveRaidIcon")
	self:Hook("SetRaidTargetIcon", "StickySetRaidTarget")
	self:Hook("SendChatMessage", "ConvertRaidMarkers")
end

function BigWigsRaidIcon:BigWigs_SetRaidIcon(player, iconnumber)
	if not self.db.profile.place or not player then
		return
	end
	local icon = self.db.profile.icon
	if not self.icontonumber[icon] then
		icon = L["skull"]
	end
	icon = self.icontonumber[icon]

	for i = 1, GetNumRaidMembers() do
		if UnitName("raid" .. i) == player then
			if not iconnumber then
				SetRaidTarget("raid" .. i, icon)
				lastplayer = player
			else
				SetRaidTarget("raid" .. i, iconnumber)
				lastplayer = player
			end
		end
	end

end

function BigWigsRaidIcon:BigWigs_RemoveRaidIcon()
	if not self.db.profile.place or not lastplayer then
		return
	end
	for i = 1, GetNumRaidMembers() do
		if UnitName("raid" .. i) == lastplayer then
			SetRaidTarget("raid" .. i, 0)
		end
	end
	lastplayer = nil
end

function BigWigsRaidIcon:StickySetRaidTarget(unit, index)
	-- skull mark
	if index == 8 then
		local _, guid = UnitExists(unit)
		if guid then
			self:TriggerEvent("BigWigs_SendSync", "BWCAAF " .. guid)
		end
	end

	self.hooks["SetRaidTargetIcon"](unit, index)
	if self.db.profile.sticky then
		SetRaidTarget(unit, index);
	end
end

function BigWigsRaidIcon:ConvertRaidMarkers(msg, chatType, language, channel)
	if self.db.profile.chat then
		msg = string.gsub(msg, "{star}", SpellstatusV2IndexToIcon[1])
		msg = string.gsub(msg, "{circle}", SpellstatusV2IndexToIcon[2])
		msg = string.gsub(msg, "{diamond}", SpellstatusV2IndexToIcon[3])
		msg = string.gsub(msg, "{triangle}", SpellstatusV2IndexToIcon[4])
		msg = string.gsub(msg, "{moon}", SpellstatusV2IndexToIcon[5])
		msg = string.gsub(msg, "{square}", SpellstatusV2IndexToIcon[6])
		msg = string.gsub(msg, "{cross}", SpellstatusV2IndexToIcon[7])
		msg = string.gsub(msg, "{skull}", SpellstatusV2IndexToIcon[8])
	end
	self.hooks["SendChatMessage"](msg, chatType, language, channel)
end
