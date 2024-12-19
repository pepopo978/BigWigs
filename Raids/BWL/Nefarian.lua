
local module, L = BigWigs:ModuleDeclaration("Nefarian", "Blackwing Lair")
local victor = AceLibrary("Babble-Boss-2.2")["Lord Victor Nefarius"]

module.revision = 30086
module.enabletrigger = {"Nefarian", "Lord Victor Nefarius"}
module.toggleoptions = {
	"mc",
	"icon",
	"drakonidcolor",
	"drakonidcounter",
	"landingparty",
	-1,
	"shadowflame",
	"fear",
	"curse",
	-1,
	"classcall",
	"wildpolymorph",
	"corruptedhealing",
	"bopnef",
	-1,
	"boneconstructs",
	"taillash", 
	-1,
	"parry",
	"bosskill"
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Nefarian",

--Phase 1
	mc_cmd = "mc",
	mc_name = "Mind Control Alert",
	mc_desc = "Warn for Mind Control",
	
	icon_cmd = "icon",
	icon_name = "Mind Control Raid Icon",
	icon_desc = "Raid Icon on Mind Control",
	
	drakonidcolor_cmd = "drakonidcolor",
	drakonidcolor_name = "Drakonid Color Alert",
	drakonidcolor_desc = "Warnings based on the Drakonids' Color",
	
	drakonidcounter_cmd = "drakonidcounter",
	drakonidcounter_name = "Drakonid Counter",
	drakonidcounter_desc = "Counter for Drakonids Killed",
	
	landingparty_cmd = "landingparty",
	landingparty_name = "Landing Party Alert",
	landingparty_desc = "Warn for Landing Party",
	
--Phase 2
	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame Alert",
	shadowflame_desc = "Warn for Shadow Flame",

	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Nefarian casts AoE Fear",
	
	curse_cmd = "curse",
	curse_name = "Veil Of Shadow",
	curse_desc = "Shows a timer bar for Veil Of Shadow.",
	
	classcall_cmd = "classcall",
	classcall_name = "Class Call Alert",
	classcall_desc = "Warn for Class Calls",
	
	wildpolymorph_cmd = "wildpolymorph",
	wildpolymorph_name = "Wild Polymorph Alert",
	wildpolymorph_desc = "Warn for Wild Polymorph",
	
	corruptedhealing_cmd = "corruptedhealing",
	corruptedhealing_name = "Corrupted Healing Alert",
	corruptedhealing_desc = "Warn for Corrupted Healing",
	
	bopnef_cmd = "bopnef",
	bopnef_name = "Blessing of Protection on Nefarian Alert",
	bopnef_desc = "Warn for Blessing of Protection on Nefarian",
	
	boneconstructs_cmd = "boneconstructs",
	boneconstructs_name = "Bone Constructs Alert",
	boneconstructs_desc = "Warn for Bone Constructs",
	
	taillash_cmd = "taillash",
	taillash_name = "Tail Lash Alert",
	taillash_desc = "Warn for Class Calls",
	
	parry_cmd = "parry",
	parry_name = "Parry Alert",
	parry_desc = "Warn for Parries",
	

--Phase 1
	trigger_engage = "Let the games begin!", --CHAT_MSG_MONSTER_YELL
	bar_mobsSpawn = "Drakonids Spawn",
	
	trigger_mcYou = "You are afflicted by Shadow Command", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_mcOther2 = "(.+) %(.+%) is afflicted by Shadow Command", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcOther = "(.+) is afflicted by Shadow Command", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
	trigger_mcFade = "Shadow Command fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_mc = " MC",
	msg_mc = " MC - Sheep!",
	trigger_deadOther = "(.+) dies.", --CHAT_MSG_COMBAT_FRIENDLY_DEATH
	
	bar_addCounter = "Drakonids Left",
	msg_red = "Red Drakonids - Does: Cone Fire Stacking Dot - Resist: Fire",
	msg_blue = "Blue Drakonids - Does: Mana Drain & Slow Atk Speed - Resist: Frost & Arcane",
	msg_green = "Green Drakonids - Does: Stuns - Resist: Nature Resistant",
	msg_black = "Black Drakonids - Does: Fire Attack - Resist: Shadow & Fire",
	msg_bronze = "Bronze Drakonids - Does: Slow Atk & Cast Speed - Resist: Arcane",
	
	msg_landingParty = "Nefarian Lands very soon, Landing Party, get in position!", -- this is based on kills not time on twow/vmangos
	
--Phase 2
	--nefarion engages at 40 dead drakonids, summoning stops one loop after 42 die, ending typically with 44 drakonid summoned total
	trigger_landingStart = "Well done, my minions. The mortals' courage begins to wane! Now, let's see how they contend with the true Lord of Blackrock Spire!!!", --CHAT_MSG_MONSTER_YELL
	bar_landingShadowFlame = "AoE Shadow Flame", --doesn't do damage on twow, not showing this bar
	bar_landingStart = "Nefarian Lands",
	msg_landingStart = "Nefarian is landing!",
	
	--ShadowFlame 12.5sec after landingStart, lands 0.5-1sec after
	trigger_landingNow = "BURN! You wretches! BURN!", --CHAT_MSG_MONSTER_YELL 22:14:23.782
	
	trigger_shadowFlame = "Nefarian begins to cast Shadow Flame.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_shadowFlameCd = "Shadow Flame CD",
	bar_shadowFlameCast = "Casting Shadow Flame",
	msg_shadowFlameCast = "Casting Shadow Flame!",
	
	trigger_fear = "Nefarian begins to cast Bellowing Roar.", --CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE
	bar_fearCd = "Fear CD",
	bar_fearSoon = "Fear Soon...",
	bar_fearCast = "Casting Fear!",
	msg_fearCast = "Casting Fear!",
	
	trigger_fearWard = "You gain Fear Ward.", --CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS
	trigger_fearWardFade = "Fear Ward fades from you.", --CHAT_MSG_SPELL_AURA_GONE_SELF
	msg_fearWard = "You have Fear Ward!",
	msg_fearWardFade = "Fear Ward faded",
	
	trigger_curseYou = "You are afflicted by Veil of Shadow.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_curseOther = "(.+) is afflicted by Veil of Shadow.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	trigger_curseFade = "Veil of Shadow fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_curseCd = "Veil of Shadow CD",
	bar_curseDur = " Veil of Shadow",
	msg_curse = " Veil of Shadow - Decurse!",

	trigger_classCall_Druid = "Druids and your silly shapeshifting. Lets see it in action!", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Hunter = "Hunters and your annoying pea%-shooters!", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Mage = "Mages too%?", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Paladin = "Paladins... I've heard you have many lives. Show me.", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Priest = "Priests! If you're going to keep", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Rogue = "Rogues%? Stop hiding and face me!", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Shaman = "Shamans, show me", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Warlock = "Warlocks, you shouldn't be playing with magic you don't understand. See what happens%?", --CHAT_MSG_MONSTER_YELL
	trigger_classCall_Warrior = "Warriors, I know you can hit harder than that! Lets see it!", --CHAT_MSG_MONSTER_YELL
	
	bar_classCall = "Class Call",
	
	msg_classCall_Druid = "Druid Class Call - Stuck in Cat Form!",
	msg_classCall_Hunter = "Hunter Class Call - Ranged Weapons Broken!",
	msg_classCall_Mage = "Mage Class Call - Random Sheeps - Mages Ice Block or Get Away!",
	msg_classCall_Paladin = "Paladin Class Call - Blessing of Protection on Nefarian!",
	msg_classCall_Priest = "Priest Class Call - Direct Heals Hurt - Use Renew / Shield only!",
	msg_classCall_Rogue = "Rogue Class Call - Rogues Teleported and Rooted - Turn the Boss!",
	msg_classCall_Shaman = "Shaman Class Call - Kill Totems!",
	msg_classCall_Warlock = "Warlock Class Call - Kill the Infernals!",
	msg_classCall_Warrior = "Warrior Class Call - Stuck in Berserker Stance!",
	
	msg_classCall_soon3 = "Class Call in 3 seconds - Hunters, swap Ranged Weapon!",
	
	trigger_wildPolymorphYou = "You are afflicted by Wild Polymorph.", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE --guessing
	trigger_wildPolymorphOther = "(.+) is afflicted by Wild Polymorph.", --CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE --guessing
	trigger_wildPolymorphFade = "Wild Polymorph fades from (.+).", --CHAT_MSG_SPELL_AURA_GONE_SELF // CHAT_MSG_SPELL_AURA_GONE_PARTY // CHAT_MSG_SPELL_AURA_GONE_OTHER --guessing
	bar_wildPolymorph = " Sheeped",
	msg_wildPolymorph = " Sheeped - Dispel!",
	
	trigger_corruptedHealing = "afflicted by Corrupted Healing", --CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE --guessing
	msg_corruptedHealing = "A Priest's direct heal caused Corrupted Healing!",
	
	--lasts 5sec, but fade->regain doesn't always happen, he's bop'd by 30sec straight usually
	trigger_bopNef = "Nefarian gains Improved Blessing of Protection.", --CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	trigger_bopNefFade = "Improved Blessing of Protection fades from Nefarian.", --CHAT_MSG_SPELL_AURA_GONE_OTHER
	bar_bopNef = "Nefarian Blessing of Protection",
	
	msg_lowHp = "Nefarian under 25% - Bone Constructs Soon (@ 20%)!",
	
	trigger_boneConstructs = "Impossible! Rise my minions! Serve your master once more!", --CHAT_MSG_MONSTER_YELL
	msg_boneConstructs = "Bone Constructs incoming - AOE!",
	
	trigger_tailLash = "Nefarian's Tail Lash hits you", --CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE
	msg_tailLash = "Tail Lash hits behind the boss for 30 yards.",
	
	trigger_parryYou = "You attack. Nefarian parries.", --CHAT_MSG_COMBAT_SELF_MISSES
	msg_parryYou = "Nefarian Parried your attack - Stop killing the tank you idiot!",
} end)

local timer = {
--Phase 1
	mobSpawn = 10, --ok
	mcDur = 15, --ok
	-- landingParty = 115, --guessing landing is time-based from engage, gives 20sec to get in position
						--if it is kill-based, will put it @ 37 kill
						--112 was missing 3 sec, adjusted to 115
--Phase 2	
	landing = 13, --ok, 1st hit from nef at 13.5
	landingShadowFlame = 12.4, --doesn't do damage on twow, not showing this bar
	
	shadowFlameFirstCd = 19.7, --saw 19.747
	shadowFlameCd = {16.5,23}, --saw 18.891 to 25.002, minus 2sec cast
	shadowFlameCast = 2,
	
	fearFirstCd = 25, --saw 26.03
		--saw 25.11 to 29.929
	fearCd = 23.5, --show Berserker @ timer.fearCd - 3.5
	fearSoon = 5,
	fearCast = 1.5,
	
	curseFirstCd = 16, --saw 16.164
	curseCd = {10,15}, --saw 10.613 to 14.162
	curseDur = 6,
	
	classCallFirstCd = 26.5, --saw 26.545
	classCallCd = {25,35}, --saw 25.893 to 32.462
	classCallDur = 30,
	
	wildPolymorph = 20,
	bopNef = 30,
	
	tailLash = 2,
}
local icon = {
--Phase 1
	phase = "inv_misc_head_dragon_01",
	mc = "Spell_Shadow_Charm",
	addCounter = "Inv_misc_head_dragon_black",
	
	red = "Inv_misc_head_dragon_red",
	blue = "Inv_misc_head_dragon_blue",
	green = "Inv_misc_head_dragon_green",
	black = "Inv_misc_head_dragon_black",
	bronze = "Inv_misc_head_dragon_bronze",
	
--Phase 2
	shadowFlame = "Spell_Fire_Incinerate",
	
	fear = "Spell_Shadow_Possession",
	fearWard = "spell_holy_excorcism",
	
	berserker = "spell_nature_ancestralguardian",
	curse = "Spell_Shadow_GatherShadows",

	classCall = "Spell_Shadow_Charm",
	Druid = "ability_druid_catformattack",
	Hunter = "inv_ammo_arrow_01",
	Mage = "spell_nature_polymorph",
	Paladin = "spell_holy_sealofprotection",
	Priest = "spell_holy_renew",
	Rogue = "spell_shadow_teleport",
	Shaman = "spell_totem_wardofdraining",
	Warlock = "spell_shadow_summoninfernal",
	Warrior = "ability_warrior_offensivestance",

	wildPolymorph = "spell_nature_polymorph",
	bopNef = "spell_holy_sealofprotection",

	boneConstructs = "inv_misc_bone_02",

	tailLash = "inv_misc_monsterscales_05",

	parry = "ability_parry",
}
local color = {
--Phase 1
	phase = "White",
	mc = "Black",
	addCounter = "Cyan",

--Phase 2
	shadowFlameCd = "Orange",
	shadowFlameCast = "Red",

	fearCd = "Yellow",
	fearSoon = "Green",
	fearCast = "Magenta",

	curseCd = "Cyan",
	curseDur = "Blue",

	classCallCd = "White",
	classCallDur = "Black",

	wildPolymorph = "Black",
	bopNef = "Black",
}
local syncName = {
--Phase 1
	mc = "NefarianMc"..module.revision,
	mcFade = "NefarianMcFade"..module.revision,
	addDead = "NefarianDrakonidDead"..module.revision,
	drakonidColor = "NefarianDrakonidColor"..module.revision,
	landingParty = "NefarianLandingParty"..module.revision,

--Phase 2
	landingStart = "NefarianLandingStart"..module.revision,
	landingNow = "NefarianLandingNow2"..module.revision,

	shadowFlame = "NefarianShadowflame"..module.revision,

	fear = "NefarianFear"..module.revision,

	curse = "NefarianCurse"..module.revision,
	curseFade = "NefarianCurseFade"..module.revision,

	classCall = "NefarianClassCall"..module.revision,

	wildPolymorph = "NefarianWildPolymorph"..module.revision,
	wildPolymorphFade = "NefarianWildPolymorphFade"..module.revision,

	corruptedHealing = "NefarianCorruptedHealing"..module.revision,

	bopNef = "NefarianBop"..module.revision,
	bopNefFade = "NefarianBopFade"..module.revision,

	lowHp = "NefarianLowHp"..module.revision,

	boneConstructs = "NefarianBoneConstructs"..module.revision,
}

local drakonidsSelfCount = 0
local drakonidsDead = 0
local drakonidsDeadMax = 44 -- nef spawns at 40 dead, add stop summoning at 44
local lowHp = nil
local phase = "phase1"
local redFound = nil
local blueFound = nil
local greenFound = nil
local blackFound = nil
local bronzeFound = nil
local bopNefFadeCheck = nil
local pallyCallTime = 0

function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") --Debug

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") --trigger_engage, trigger_landingStart, trigger_landingNow, classCalls, trigger_boneConstructs

	self:RegisterEvent("UNIT_HEALTH") --lowHp

	self:RegisterEvent("PLAYER_TARGET_CHANGED") --drakonid color detection

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") --trigger_mcYou, trigger_curseYou, trigger_wildPolymorphYou, trigger_corruptedHealing
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") --trigger_mcOther, trigger_curseOther, trigger_wildPolymorphOther, trigger_corruptedHealing
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") --trigger_mcOther, trigger_curseOther, trigger_wildPolymorphOther, trigger_corruptedHealing
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", "Event") --trigger_mcOther

	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") --trigger_mcFade, trigger_fearWardFade, trigger_curseFade, trigger_wildPolymorphFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") --trigger_mcFade, trigger_curseFade, trigger_wildPolymorphFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") --trigger_mcFade, trigger_curseFade, trigger_wildPolymorphFade, trigger_bopNefFade

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") --trigger_tailLash
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") --trigger_shadowFlame, trigger_fear

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Event") --trigger_fearWard

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") --trigger_bopNef

	self:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES", "Event") --trigger_parryYou


--Phase 1
	self:ThrottleSync(3, syncName.mc)
	self:ThrottleSync(3, syncName.mcFade)
	self:ThrottleSync(0, syncName.addDead)
	self:ThrottleSync(0.5, syncName.drakonidColor)
	self:ThrottleSync(120, syncName.landingParty)

--Phase 2
	self:ThrottleSync(3, syncName.landingStart)
	self:ThrottleSync(3, syncName.landingNow)

	self:ThrottleSync(3, syncName.shadowFlame)

	self:ThrottleSync(3, syncName.fear)

	self:ThrottleSync(3, syncName.curse)
	self:ThrottleSync(3, syncName.curseFade)

	self:ThrottleSync(3, syncName.classCall)

	self:ThrottleSync(0.5, syncName.wildPolymorph)
	self:ThrottleSync(0.25, syncName.wildPolymorphFade)

	self:ThrottleSync(1, syncName.corruptedHealing)

	self:ThrottleSync(30, syncName.bopNef)
	self:ThrottleSync(3, syncName.bopNefFade)

	self:ThrottleSync(3, syncName.lowHp)

	self:ThrottleSync(3, syncName.boneConstructs)
end

function module:OnSetup()
	self.started = nil

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") --bar_addCounter
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH") --trigger_deadOther
end

function module:OnEngage()
	drakonidsDead = 0
	drakonidsSelfCount = 0
	lowHp = nil
	phase = "phase1"
	redFound = nil
	blueFound = nil
	greenFound = nil
	blackFound = nil
	bronzeFound = nil
	bopNefFadeCheck = nil
	pallyCallTime = 0

	self:Bar(L["bar_mobsSpawn"], timer.mobSpawn, icon.phase, true, color.phase)

	if self.db.profile.drakonidcounter then
		self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_addCounter"], drakonidsDeadMax, "Interface\\Icons\\"..icon.addCounter, true, color.addCounter)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_addCounter"], drakonidsDead)
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)

	if string.find(msg, " Drakonid dies.") then
		drakonidsSelfCount = drakonidsSelfCount + 1
		if drakonidsSelfCount <= drakonidsDeadMax then
			self:Sync(syncName.addDead .. " " .. drakonidsSelfCount)
		end
		if drakonidsSelfCount >= drakonidsDeadMax - 8 then -- warn landing party 4 adds (2 per side) before nef begins to land
			self:Sync(syncName.landingParty)
		end
	end
end

function module:CHAT_MSG_COMBAT_FRIENDLY_DEATH(msg)
	if string.find(msg, L["trigger_deadOther"]) then
		local _,_, deadPerson, _ = string.find(msg, L["trigger_deadOther"])
		self:Sync(syncName.mcFade .. " " .. deadPerson)
	end
end

function module:UNIT_HEALTH(msg)
	if UnitName(msg) == module.translatedName then
		local healthPct = UnitHealth(msg) * 100 / UnitHealthMax(msg)
		if healthPct >= 26 and lowHp ~= nil then
			lowHp = nil
		elseif healthPct < 25 and lowHp == nil then
			self:Sync(syncName.lowHp)
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		module:SendEngageSync()

	elseif string.find(msg, L["trigger_landingStart"]) then
		self:Sync(syncName.landingStart)

	elseif string.find(msg, L["trigger_landingNow"]) then
		self:Sync(syncName.landingNow)

	elseif string.find(msg, L["trigger_classCall_Druid"]) then
		self:Sync(syncName.classCall.." ".."Druid")
	elseif string.find(msg, L["trigger_classCall_Hunter"]) then
		self:Sync(syncName.classCall.." ".."Hunter")
	elseif string.find(msg, L["trigger_classCall_Mage"]) then
		self:Sync(syncName.classCall.." ".."Mage")
	elseif string.find(msg, L["trigger_classCall_Paladin"]) then
		self:Sync(syncName.classCall.." ".."Paladin")
	elseif string.find(msg, L["trigger_classCall_Priest"]) then
		self:Sync(syncName.classCall.." ".."Priest")
	elseif string.find(msg, L["trigger_classCall_Rogue"]) then
		self:Sync(syncName.classCall.." ".."Rogue")
	elseif string.find(msg, L["trigger_classCall_Shaman"]) then
		self:Sync(syncName.classCall.." ".."Shaman")
	elseif string.find(msg, L["trigger_classCall_Warlock"]) then
		self:Sync(syncName.classCall.." ".."Warlock")
	elseif string.find(msg, L["trigger_classCall_Warrior"]) then
		self:Sync(syncName.classCall.." ".."Warrior")

	elseif msg == L["trigger_boneConstructs"] then
		self:Sync(syncName.boneConstructs)
	end
end

function module:PLAYER_TARGET_CHANGED()
	if phase == "phase1" and UnitName("Target") ~= nil then
		if string.find(UnitName("Target"), " Drakonid") then
			if string.find(UnitName("Target"), "Red") and not redFound then
				self:Sync(syncName.drakonidColor .. " " .. "Red")
			elseif string.find(UnitName("Target"), "Blue") and not blueFound then
				self:Sync(syncName.drakonidColor .. " " .. "Blue")
			elseif string.find(UnitName("Target"), "Green") and not greenFound then
				self:Sync(syncName.drakonidColor .. " " .. "Green")
			elseif string.find(UnitName("Target"), "Black") and not blackFound then
				self:Sync(syncName.drakonidColor .. " " .. "Black")
			elseif string.find(UnitName("Target"), "Bronze") and not bronzeFound then
				self:Sync(syncName.drakonidColor .. " " .. "Bronze")
			end
		end
	end
end

function module:Event(msg)
	if msg == L["trigger_mcYou"] then
		self:Sync(syncName.mc .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_mcOther2"]) then
		local _,_,mcPlayer,_ = string.find(msg, L["trigger_mcOther2"])
		self:Sync(syncName.mc .. " " .. mcPlayer)
	elseif string.find(msg, L["trigger_mcOther"]) then
		local _,_,mcPlayer,_ = string.find(msg, L["trigger_mcOther"])
		self:Sync(syncName.mc .. " " .. mcPlayer)

	elseif string.find(msg, L["trigger_mcFade"]) then
		local _,_,mcFadePlayer,_ = string.find(msg, L["trigger_mcFade"])
		if mcFadePlayer == "you" then mcFadePlayer = UnitName("Player") end
		self:Sync(syncName.mcFade .. " " .. mcFadePlayer)


	elseif msg == L["trigger_shadowFlame"] then
		self:Sync(syncName.shadowFlame)

	elseif msg == L["trigger_fear"] then
		self:Sync(syncName.fear)

	elseif msg == L["trigger_fearWard"] then
		self:FearWard()
	elseif msg == L["trigger_fearWardFade"] then
		self:FearWardFade()

	elseif msg == L["trigger_curseYou"] then
		self:Sync(syncName.curse .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_curseOther"]) then
		local _,_,cursePlayer,_ = string.find(msg, L["trigger_curseOther"])
		self:Sync(syncName.curse .. " " .. cursePlayer)

	elseif string.find(msg, L["trigger_curseFade"]) then
		local _,_,curseFadePlayer,_ = string.find(msg, L["trigger_curseFade"])
		if curseFadePlayer == "you" then curseFadePlayer = UnitName("Player") end
		self:Sync(syncName.curseFade .. " " .. curseFadePlayer)


	elseif msg == L["trigger_wildPolymorphYou"] then
		self:Sync(syncName.wildPolymorph .. " " .. UnitName("Player"))

	elseif string.find(msg, L["trigger_wildPolymorphOther"]) then
		local _,_,wildPolymorphPlayer,_ = string.find(msg, L["trigger_wildPolymorphOther"])
		self:Sync(syncName.wildPolymorph .. " " .. wildPolymorphPlayer)

	elseif string.find(msg, L["trigger_wildPolymorphFade"]) then
		local _,_,wildPolymorphFadePlayer,_ = string.find(msg, L["trigger_wildPolymorphFade"])
		if wildPolymorphFadePlayer == "you" then wildPolymorphFadePlayer = UnitName("Player") end
		self:Sync(syncName.wildPolymorphFade .. " " .. wildPolymorphFadePlayer)


	elseif string.find(msg, L["trigger_corruptedHealing"]) then
		self:Sync(syncName.corruptedHealing)


	elseif msg == L["trigger_bopNef"] then
		self:Sync(syncName.bopNef)
	elseif msg == L["trigger_bopNefFade"] then
		self:Sync(syncName.bopNefFade)

	elseif string.find(msg, L["trigger_tailLash"]) and self.db.profile.taillash then
		self:TailLash()

	elseif string.find(msg, L["trigger_parryYou"]) and self.db.profile.parry then
		if UnitName("Target") ~= nil and UnitName("TargetTarget") ~= nil then
			if UnitName("Target") == "Nefarian" and UnitName("TargetTarget") ~= UnitName("Player") then
				self:ParryYou()
			end
		end
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
--Phase 1
	if sync == syncName.mc and rest and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcFade and rest and self.db.profile.mc then
		self:McFade(rest)

	elseif sync == syncName.addDead and rest and self.db.profile.drakonidcounter then
		self:DrakonidCounter(rest)

	elseif sync == syncName.drakonidColor and rest and self.db.profile.drakonidcolor then
		self:DrakonidColor(rest)

	elseif sync == syncName.landingParty then
		self:LandingWarn()

--Phase 2
	elseif sync == syncName.landingStart then
		self:LandingStart()
	elseif sync == syncName.landingNow then
		self:LandingNow()

	elseif sync == syncName.shadowFlame and self.db.profile.shadowflame then
		self:ShadowFlame()

	elseif sync == syncName.fear and self.db.profile.fear then
		self:Fear()

	elseif sync == syncName.curse and rest and self.db.profile.curse then
		self:Curse(rest)
	elseif sync == syncName.curseFade and rest and self.db.profile.curse then
		self:CurseFade(rest)

	elseif sync == syncName.classCall and rest and self.db.profile.classcall then
		self:ClassCall(rest)

	elseif sync == syncName.wildPolymorph and rest and self.db.profile.wildpolymorph then
		self:WildPolymorph(rest)
	elseif sync == syncName.wildPolymorphFade and rest and self.db.profile.wildpolymorph then
		self:WildPolymorphFade(rest)

	elseif sync == syncName.corruptedHealing and self.db.profile.corruptedhealing then
		self:CorruptedHealing()

	elseif sync == syncName.bopNef and self.db.profile.bopnef then
		self:BopNef()
	elseif sync == syncName.bopNefFade and self.db.profile.bopnef then
		self:BopNefFade()

	elseif sync == syncName.lowHp and self.db.profile.boneconstructs then
		self:LowHp()

	elseif sync == syncName.boneConstructs and self.db.profile.boneconstructs then
		self:BoneConstructs()
	end
end


--Phase 1
function module:Mc(rest)
	self:Bar(rest..L["bar_mc"], timer.mcDur, icon.mc, true, color.mc)
	self:Message(rest..L["msg_mc"], "Urgent", false, nil, false)

	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Warlock" then
		self:WarningSign(icon.mc, 1)
		self:Sound("Info")
	end

	if self.db.profile.icon and (IsRaidLeader() or IsRaidOfficer()) then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 4)
			end
		end
	end
end
function module:McFade(rest)
	self:RemoveBar(rest..L["bar_mc"])
	self:RemoveWarningSign(icon.mc)

	if self.db.profile.icon and (IsRaidLeader() or IsRaidOfficer()) then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == rest then
				SetRaidTarget("raid"..i, 0)
			end
		end
	end
end

function module:DrakonidCounter(rest)
	if tonumber(rest) > drakonidsDead then
		drakonidsDead = tonumber(rest)
		self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_addCounter"], drakonidsDead)
	end
	if tonumber(rest) >= drakonidsDeadMax then
		self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_addCounter"])
	end
end

function module:DrakonidColor(rest)
	if rest == "Red" and not redFound then
		redFound = true
		self:Message(L["msg_red"], "Red", false, nil, false)

	elseif rest == "Blue" and not blueFound then
		blueFound = true
		self:Message(L["msg_blue"], "Blue", false, nil, false)

	elseif rest == "Green" and not greenFound then
		greenFound = true
		self:Message(L["msg_green"], "Green", false, nil, false)

	elseif rest == "Black" and not blackFound then
		blackFound = true
		self:Message(L["msg_black"], "Magenta", false, nil, false)

	elseif rest == "Bronze" and not bronzeFound then
		bronzeFound = true
		self:Message(L["msg_bronze"], "Yellow", false, nil, false)
	end
end

function module:LandingWarn(rest)
	self:Message(L["msg_landingParty"], "Important", false, nil, false)
	self:WarningSign(icon.phase, 1)
	self:Sound("Beware")
end

--Phase 2
function module:LandingStart()
	phase = "phase2"
	--self:Bar(L["bar_landingShadowFlame"], timer.landingShadowFlame, icon.shadowFlame, true, color.shadowFlameCast)
	self:Bar(L["bar_landingStart"], timer.landing, icon.phase, true, color.phase)
	self:Message(L["msg_landingStart"], "Important", false, nil, false)
	self:WarningSign(icon.phase, 1)
	self:Sound("Beware")
end

function module:LandingNow()
	--self:RemoveBar(L["bar_landingShadowFlame"])

	if self.db.profile.shadowflame then
		self:Bar(L["bar_shadowFlameCd"], timer.shadowFlameFirstCd, icon.shadowFlame, true, color.shadowFlameCd)
	end

	if self.db.profile.fear then
		self:Bar(L["bar_fearCd"], timer.fearFirstCd, icon.fear, true, color.fearCd)
		self:DelayedBar(timer.fearFirstCd, L["bar_fearSoon"], timer.fearSoon, icon.fear, true, color.fearSoon)

		if UnitClass("Player") == "Warrior" then
			self:DelayedWarningSign(timer.fearFirstCd - 3.5, icon.berserker, 1)
			self:DelayedSound(timer.fearFirstCd - 3.5, "BikeHorn")
		end
	end

	if self.db.profile.curse then
		self:Bar(L["bar_curseCd"], timer.curseFirstCd, icon.curse, true, color.curseCd)
	end

	if self.db.profile.classcall then
		self:Bar(L["bar_classCall"].." CD", timer.classCallFirstCd, icon.classCall, true, color.classCallCd)
		self:DelayedMessage(timer.classCallFirstCd - 3, L["msg_classCall_soon3"], "Personal", false, nil, false)
	end
end

function module:ShadowFlame()
	self:RemoveBar(L["bar_shadowFlameCd"])

	self:Bar(L["bar_shadowFlameCast"], timer.shadowFlameCast, icon.shadowFlame, true, color.shadowFlameCast)
	self:Message(L["msg_shadowFlameCast"], "Urgent", false, nil, false)

	self:DelayedIntervalBar(timer.shadowFlameCast, L["bar_shadowFlameCd"], timer.shadowFlameCd[1], timer.shadowFlameCd[2], icon.shadowFlame, true, color.shadowFlameCd)
end

function module:FearWard()
	if phase == "phase2" then
		fearWard = true

		self:CancelDelayedWarningSign(icon.berserker)
		self:CancelDelayedSound("BikeHorn")

		self:Message(L["msg_fearWard"], "Positive", false, nil, false)
		self:WarningSign(icon.fearWard, 1)
	end
end
function module:FearWardFade()
	fearWard = nil
	self:Message(L["msg_fearWardFade"])
end

function module:Fear()
	self:RemoveBar(L["bar_fearCd"])
	self:CancelDelayedBar(L["bar_fearSoon"])
	self:RemoveBar(L["bar_fearSoon"])

	self:CancelDelayedWarningSign(icon.berserker)
	self:CancelDelayedSound("BikeHorn")

	self:Bar(L["bar_fearCast"], timer.fearCast, icon.fear, true, color.fearCast)
	self:Message(L["msg_fearCast"], "Urgent", false, nil, false)
	self:WarningSign(icon.fear, 0.7)
	self:Sound("Alarm")

	self:DelayedBar(timer.fearCast, L["bar_fearCd"], timer.fearCd, icon.fear, true, color.fearCd)
	self:DelayedBar(timer.fearCast + timer.fearCd, L["bar_fearSoon"], timer.fearSoon, icon.fear, true, color.fearSoon)

	if UnitClass("Player") == "Warrior" then
		self:DelayedWarningSign(timer.fearCast + timer.fearCd - 3.5, icon.berserker, 1)
		self:DelayedSound(timer.fearCast + timer.fearCd - 3.5, "BikeHorn")
	end
end

function module:Curse(rest)
	self:RemoveBar(L["bar_curseCd"])

	self:Bar(rest..L["bar_curseDur"], timer.curseDur, icon.curse, true, color.curseDur)

	if UnitClass("Player") == "Mage" or UnitClass("Player") == "Druid" then
		self:Message(rest..L["msg_curse"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.curse, timer.curseDur)
	end

	--just delay the bar by 5sec to not clutter the screen
	self:DelayedIntervalBar(5, L["bar_curseCd"], timer.curseCd[1] - 5, timer.curseCd[2] - 5, icon.curse, true, color.curseCd)
end
function module:CurseFade(rest)
	self:RemoveBar(rest..L["bar_curseDur"])
	self:RemoveWarningSign(icon.curse)
end

function module:ClassCall(rest)
	self:RemoveBar(L["bar_classCall"].." CD")
	self:CancelDelayedBar(L["bar_classCall"].." Soon")
	self:RemoveBar(L["bar_classCall"].." Soon")

	self:Bar(rest.." "..L["bar_classCall"], timer.classCallDur, icon.classCall, true, color.classCallDur)
	self:Message(L["msg_classCall_"..rest], "Positive", false, nil, false)

	if UnitClass("Player") == rest then
		self:Sound("Beware")
		self:WarningSign(icon[rest], 2, true, "YOUR CLASS CALL")
	end
	
	if rest == "Paladin" then
		self:ThrottleSync(1, syncName.bopNef)
		bopNefFadeCheck = nil
		self:CancelScheduledEvent("Nefarian_BopNef_EnableFadeCheck")
		self:ScheduleEvent("Nefarian_BopNef_EnableFadeCheck", self.BopNef_EnableFadeCheck, 30, self)
		
		pallyCallTime = GetTime()
	end
	
	--class call is every 25-35sec, dur is 30sec, 2 class calls can overlap by 5sec, can also have 5sec without class call
	self:DelayedBar(timer.classCallDur, L["bar_classCall"].." Soon", timer.classCallCd[2] - timer.classCallDur, icon.classCall, true, color.classCallCd)
	self:DelayedMessage(timer.classCallDur - 8, L["msg_classCall_soon3"], "Personal", false, nil, false)
end

function module:WildPolymorph(rest)
	self:Bar(rest..L["bar_wildPolymorph"], timer.wildPolymorph, icon.wildPolymorph, true, color.wildPolymorph)
	
	if UnitClass("Player") == "Priest" or UnitClass("Player") == "Paladin" then
		self:Message(rest..L["msg_wildPolymorph"], "Urgent", false, nil, false)
		self:Sound("Info")
		self:WarningSign(icon.wildPolymorph, 0.7)
	end
end
function module:WildPolymorphFade(rest)
	self:RemoveBar(rest..L["bar_wildPolymorph"])
end

function module:CorruptedHealing()
	self:Message(L["msg_corruptedHealing"])
end

function module:BopNef()
	self:ThrottleSync(30, syncName.bopNef)
	
	if (GetTime() - pallyCallTime) < 20 then
		self:Bar(L["bar_bopNef"], timer.bopNef, icon.bopNef, true, color.bopNef)
	else
		self:Bar(L["bar_bopNef"], 5, icon.bopNef, true, color.bopNef)
	end
end
function module:BopNef_EnableFadeCheck()
	bopNefFadeCheck = true
end
function module:BopNefFade()
	if bopNefFadeCheck then
		self:RemoveBar(L["bar_bopNef"])
	end
end

function module:LowHp()
	lowHp = true
	
	self:Message(L["msg_lowHp"], "Attention", false, nil, false)
	self:Sound("Alert")
end

function module:BoneConstructs()
	self:Message(L["msg_boneConstructs"], "Attention", false, nil, false)
	self:WarningSign(icon.boneConstructs, 1)
	self:Sound("Beware")
end

function module:TailLash()
	self:Message(L["msg_tailLash"], "Personal", false, nil, false)
	self:WarningSign(icon.tailLash, timer.tailLash)
end

function module:ParryYou()
	self:WarningSign(icon.parry, 0.7)
	self:Message(L["msg_parryYou"], "Personal", false, nil, false)
	self:Sound("Info")
end
