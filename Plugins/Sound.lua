assert(BigWigs, "BigWigs not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsSound")
--~~ local dewdrop = DewdropLib:GetInstance("1.0")

local sounds = {
	Long = "Interface\\AddOns\\BigWigs\\Sounds\\Long.mp3",
	Info = "Interface\\AddOns\\BigWigs\\Sounds\\Info.ogg",
	Alert = "Interface\\AddOns\\BigWigs\\Sounds\\Alert.mp3",
	Alarm = "Interface\\AddOns\\BigWigs\\Sounds\\Alarm.mp3",
	Victory = "Interface\\AddOns\\BigWigs\\Sounds\\Victory.mp3",

	Beware = "Interface\\AddOns\\BigWigs\\Sounds\\Beware.wav",
	RunAway = "Interface\\AddOns\\BigWigs\\Sounds\\RunAway.wav",

	One = "Interface\\AddOns\\BigWigs\\Sounds\\1.ogg",
	Two = "Interface\\AddOns\\BigWigs\\Sounds\\2.ogg",
	Three = "Interface\\AddOns\\BigWigs\\Sounds\\3.ogg",
	Four = "Interface\\AddOns\\BigWigs\\Sounds\\4.ogg",
	Five = "Interface\\AddOns\\BigWigs\\Sounds\\5.ogg",
	Six = "Interface\\AddOns\\BigWigs\\Sounds\\6.ogg",
	Seven = "Interface\\AddOns\\BigWigs\\Sounds\\7.ogg",
	Eight = "Interface\\AddOns\\BigWigs\\Sounds\\8.ogg",
	Nine = "Interface\\AddOns\\BigWigs\\Sounds\\9.ogg",
	Ten = "Interface\\AddOns\\BigWigs\\Sounds\\10.ogg",

	Murloc = "Sound\\Creature\\Murloc\\mMurlocAggroOld.wav",
	Pain = "Sound\\Creature\\Thaddius\\THAD_NAXX_ELECT.wav",

	Plague = "Interface\\AddOns\\BigWigs\\Sounds\\Plague.mp3",

	ShackleBroke = "Interface\\AddOns\\BigWigs\\Sounds\\ShackleBroke.mp3",
	ShackleOne = "Interface\\AddOns\\BigWigs\\Sounds\\ShackleOne.mp3",
	ShackleTwo = "Interface\\AddOns\\BigWigs\\Sounds\\ShackleTwo.mp3",
	ShackleThree = "Interface\\AddOns\\BigWigs\\Sounds\\ShackleThree.mp3",

	MarkOne = "Interface\\AddOns\\BigWigs\\Sounds\\MarkOne.mp3",
	MarkTwo = "Interface\\AddOns\\BigWigs\\Sounds\\MarkTwo.mp3",
	MarkThree = "Interface\\AddOns\\BigWigs\\Sounds\\MarkThree.mp3",
	MarkFour = "Interface\\AddOns\\BigWigs\\Sounds\\MarkFour.mp3",
	MarkFive = "Interface\\AddOns\\BigWigs\\Sounds\\MarkFive.mp3",
	MarkSix = "Interface\\AddOns\\BigWigs\\Sounds\\MarkSix.mp3",
	MarkSeven = "Interface\\AddOns\\BigWigs\\Sounds\\MarkSeven.mp3",
	MarkEight = "Interface\\AddOns\\BigWigs\\Sounds\\MarkEight.mp3",
	MarkNine = "Interface\\AddOns\\BigWigs\\Sounds\\MarkNine.mp3",
	MarkTen = "Interface\\AddOns\\BigWigs\\Sounds\\MarkTen.mp3",
	MarkEleven = "Interface\\AddOns\\BigWigs\\Sounds\\MarkEleven.mp3",
	MarkTwelve = "Interface\\AddOns\\BigWigs\\Sounds\\MarkTwelve.mp3",
	HealerOneRotate = "Interface\\AddOns\\BigWigs\\Sounds\\HealerOneRotate.mp3",
	HealerTwoRotate = "Interface\\AddOns\\BigWigs\\Sounds\\HealerTwoRotate.mp3",
	HealerThreeRotate = "Interface\\AddOns\\BigWigs\\Sounds\\HealerThreeRotate.mp3",
	VoidZoneMove = "Interface\\AddOns\\BigWigs\\Sounds\\VoidZoneMove.mp3",

	ShadowFissure = "Interface\\AddOns\\BigWigs\\Sounds\\ShadowFissure.mp3",
	MindControl = "Interface\\AddOns\\BigWigs\\Sounds\\MindControl.mp3",
	FrostBlast = "Interface\\AddOns\\BigWigs\\Sounds\\FrostBlast.mp3",

	Negative = "Interface\\AddOns\\BigWigs\\Sounds\\Negative.mp3",
	Positive = "Interface\\AddOns\\BigWigs\\Sounds\\Positive.mp3",
	NegativeSwitchSides = "Interface\\AddOns\\BigWigs\\Sounds\\NegativeSwitchSides.mp3",
	PositiveSwitchSides = "Interface\\AddOns\\BigWigs\\Sounds\\PositiveSwitchSides.mp3",

	DispelPoison = "Interface\\AddOns\\BigWigs\\Sounds\\DispelPoison.mp3",

	Dance = "Interface\\AddOns\\BigWigs\\Sounds\\Dance.mp3",
	FunDance = "Interface\\AddOns\\BigWigs\\Sounds\\FunDance.mp3",

	Scorch = "Interface\\AddOns\\BigWigs\\Sounds\\Scorch.mp3",
	ScorchResist = "Interface\\AddOns\\BigWigs\\Sounds\\ScorchResist.mp3",
	stopcasting = "Interface\\AddOns\\BigWigs\\Sounds\\stopcasting.mp3",
	IgniteDanger = "Interface\\AddOns\\BigWigs\\Sounds\\IgniteDanger.mp3",
	Pyro = "Interface\\AddOns\\BigWigs\\Sounds\\Pyro.mp3",
}


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function()
	return {
		["Sounds"] = true,
		["sounds"] = true,
		["Options for sounds."] = true,

		["toggle"] = true,
		["Use sounds"] = true,
		["Toggle sounds on or off."] = true,
		["default"] = true,
		["Default only"] = true,
		["Use only the default sound."] = true,
	}
end)

L:RegisterTranslations("esES", function()
	return {
		["Sounds"] = "Sonidos",
		--["sounds"] = true,
		["Options for sounds."] = "Opciones para sonidos",

		--["toggle"] = "Alternar",
		["Use sounds"] = "Usar sonidos",
		["Toggle sounds on or off."] = "Alterna los sonidos activos o desactivos",
		--["default"] = "defecto",
		["Default only"] = "Solamente defecto",
		["Use only the default sound."] = "Solamente usa el sonido por defecto",
	}
end)

L:RegisterTranslations("koKR", function()
	return {
		["Sounds"] = "효과음",
		["Options for sounds."] = "효과음 옵션.",

		["Use sounds"] = "효과음 사용",
		["Toggle sounds on or off."] = "효과음을 켜거나 끔.",
		["Default only"] = "기본음",
		["Use only the default sound."] = "기본음만 사용.",
	}
end)

L:RegisterTranslations("deDE", function()
	return {
		["Sounds"] = "Sound",
		["Options for sounds."] = "Optionen f\195\188r Sound.",
		["Use sounds"] = "Sound nutzen",
		["Toggle sounds on or off."] = "Sound aktivieren/deaktivieren.",
		["Default only"] = "Nur Standard",
		["Use only the default sound."] = "Nur Standard Sound.",
	}
end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsSound = BigWigs:NewModule(L["Sounds"])
BigWigsSound.defaultDB = {
	defaultonly = false,
	sound = true,
}
BigWigsSound.consoleCmd = L["sounds"]
BigWigsSound.consoleOptions = {
	type = "group",
	name = L["Sounds"],
	desc = L["Options for sounds."],
	args = {
		[L["toggle"]] = {
			type = "toggle",
			name = L["Sounds"],
			desc = L["Toggle sounds on or off."],
			get = function()
				return BigWigsSound.db.profile.sound
			end,
			set = function(v)
				BigWigsSound.db.profile.sound = v
				BigWigs:ToggleModuleActive(L["Sounds"], v)
			end,
		},
		[L["default"]] = {
			type = "toggle",
			name = L["Default only"],
			desc = L["Use only the default sound."],
			get = function()
				return BigWigsSound.db.profile.defaultonly
			end,
			set = function(v)
				BigWigsSound.db.profile.defaultonly = v
			end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsSound:OnEnable()
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("BigWigs_Sound")
end
function BigWigsSound:OnDisable()
	BigWigs:DebugMessage("OnDisable")
end

function BigWigsSound:BigWigs_Message(text, color, noraidsay, sound, broadcastonly)
	if self.db.profile.sound then
		if not text or sound == false or broadcastonly then
			return
		end

		if sounds[sound] and not self.db.profile.defaultonly then
			PlaySoundFile(sounds[sound])
		else
			PlaySound("RaidWarning")
		end
	end
end

function BigWigsSound:BigWigs_Sound(sound)
	if self.db.profile.sound then
		if sounds[sound] and not self.db.profile.defaultonly then
			PlaySoundFile(sounds[sound])
		else
			PlaySound("RaidWarning")
		end
	end
end
