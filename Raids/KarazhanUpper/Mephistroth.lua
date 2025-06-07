local module, L = BigWigs:ModuleDeclaration("Mephistroth", "Karazhan")

module.revision = 30002
module.enabletrigger = module.translatedName
module.toggleoptions = { "shacklescast", "shacklesdebuff", "shackleshatter", "shards", "doomofoutland", "doommark", "sleepparalysis", "sleepparalysismark", "terror", "rainofoutland", -1, "bosskill", "debug_superwow" }
module.zonename = {
    AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
    AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
    "Outland",
    "???"
}

-- Module defaults
module.defaultDB = {
    shacklescast = true,
    shacklesdebuff = true,
    shackleshatter = false,
    shards = true,
    doomofoutland = true,
    doommark = true,
    sleepparalysis = true,
    sleepparalysismark = true,
    terror = true,
    rainofoutland = true,
    bosskill = true,
    debug_superwow = false,
}

L:RegisterTranslations("enUS", function()
    return {
        cmd = "Mephistroth",

        -- Options
        shacklescast_cmd = "shacklescast",
        shacklescast_name = "Shackles Cast Alert",
        shacklescast_desc = "Warn when Mephistroth begins casting Shackles of the Legion.",

        shacklesdebuff_cmd = "shacklesdebuff",
        shacklesdebuff_name = "Shackles Debuff Alert",
        shacklesdebuff_desc = "Warn and timer when Shackles of the Legion lands.",

        shackleshatter_cmd = "shackleshatter",
        shackleshatter_name = "Shackle Shatter Tattle",
        shackleshatter_desc = "Tell who failed standing still.",

        shards_cmd = "shards",
        shards_name = "Shards of Hellfury Alert",
        shards_desc = "Show Shards of Hellfury cast, cooldown, channel timers, and shard kill counter.",

        doomofoutland_cmd = "doomofoutland",
        doomofoutland_name = "Doom of Outland Alert",
        doomofoutland_desc = "Warn for Doom of Outland decurse.",

        doommark_cmd = "doommark",
        doommark_name = "Mark Doom Target",
        doommark_desc = "Mark Doomed players with Skull.",

        sleepparalysis_cmd = "sleepparalysis",
        sleepparalysis_name = "Sleep Paralysis Alert",
        sleepparalysis_desc = "Warn for Sleep Paralysis dispel.",

        sleepparalysismark_cmd = "sleepparalysismark",
        sleepparalysismark_name = "Mark Sleep Paralysis Target",
        sleepparalysismark_desc = "Mark a Sleep Paralysis player with Moon.",

        terror_cmd = "terror",
        terror_name = "Nathrezim Terror Alert",
        terror_desc = "Warn when Mephistroth casts Nathrezim Terror.",

        rainofoutland_cmd = "rainofoutland",
        rainofoutland_name = "Rain of Outland Alert",
        rainofoutland_desc = "Warn for Rain of Outland.",

        debug_superwow_cmd = "debug_superwow",
        debug_superwow_name = "Enable Superwow Mode",
        debug_superwow_desc = "Use superwow API to handle shackle cast, shard cast, shard channel, etc.",

        -- Triggers
        trigger_engage = "I foresaw your arrival", -- CHAT_MSG_MONSTER_YELL

        trigger_shackleCast = "Mephistroth begins to cast Shackles of the Legion", -- CHAT_MSG_RAID_BOSS_EMOTE
        trigger_shacklesDebuffYou = "You are afflicted by Shackles of the Legion", -- CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
        trigger_shacklesDebuffOther = "(.+) is afflicted by Shackles of the Legion", -- CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE, CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
        trigger_shacklesFade = "Shackles of the Legion fades from (.+).", -- CHAT_MSG_SPELL_AURA_GONE_SELF, CHAT_MSG_SPELL_AURA_GONE_PARTY, CHAT_MSG_SPELL_AURA_GONE_OTHER

        -- shackle damage trigger
        trigger_shackleShatterYou = "Your Shackle Shatter hits", -- CHAT_MSG_SPELL_SELF_DAMAGE
        trigger_shackleShatterOther = "(.+)'s Shackle Shatter hits", -- CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE, CHAT_MSG_SPELL_PARTY_DAMAGE

        -- TODO: add a dispel warning for the vampiric aura
        -- Is this necessary? Priests can see the debuff with Decursive. （While Shamans can't.)
        trigger_vampiricAura = "Mephistroth gains Vampiric Aura", -- CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS (Or maybe other events. Not tested yet.)

        trigger_sleepParalysisYou = "You are afflicted by Sleep Paralysis", -- CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
        trigger_sleepParalysisOther = "(.+) is afflicted by Sleep Paralysis", -- CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE, CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
        trigger_sleepParalysisFade = "Sleep Paralysis fades from (.+).", -- CHAT_MSG_SPELL_AURA_GONE_SELF, CHAT_MSG_SPELL_AURA_GONE_PARTY, CHAT_MSG_SPELL_AURA_GONE_OTHER

        trigger_terror = "Mephistroth begins to cast Nathrezim Terror", -- CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE

        trigger_shard = "Mephistroth begins to cast Shards of Hellfury", -- CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
        trigger_shardDeath = "Hellfury Shard dies", -- CHAT_MSG_COMBAT_HOSTILE_DEATH
        trigger_shardEnrage = "Mephistroth gains Unfathomed Hatred", -- Unknown Event Type

        trigger_rainOfOutland = "Mephistroth gains Rain of Outland", -- CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
        trigger_rainOfOutlandEnd = "Rain of Outland fades from Mephistroth", -- CHAT_MSG_SPELL_AURA_GONE_OTHER

        trigger_doomDebuffYou = "You are afflicted by Doom of Outland", -- CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
        trigger_doomDebuffOther = "(.+) is afflicted by Doom of Outland", -- CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE, CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
        trigger_doomDebuffFade = "Doom of Outland fades from (.+).", -- CHAT_MSG_SPELL_AURA_GONE_SELF, CHAT_MSG_SPELL_AURA_GONE_PARTY, CHAT_MSG_SPELL_AURA_GONE_OTHER

        trigger_bossDeath = "Mephistroth dies", -- CHAT_MSG_COMBAT_HOSTILE_DEATH

        -- Messages & Bars
        msg_shacklesCast = "Shackles of the Legion incoming! >>DO NOT MOVE<<",
        bar_shacklesCast = "Shackles of the Legion",
        msg_shacklesCastAlert = "Shackles Casting >>STOP MOVING<<",
        bar_shacklesCD = "Shackles of the Legion Cooldown",

        bar_shacklesDebuff = "Shackles",
        msg_shacklesDebuffYou = "You are shackled! >>DO NOT MOVE<<",
        -- msg_shacklesDebuffOther = "%s is shackled! >>DO NOT MOVE<<",

        msg_shackleShatter = "%s didn't keep still!",

        bar_shardsCast = "Shards of Hellfury",
        bar_shardsChannel = "Shards Enrage",
        bar_shardsCD = "Shards of Hellfury Cooldown",
        bar_shardsCounter = "Shard Kills",
        msg_shardsCast = "Hellfire Shards casting, go kill shards!",
        msg_shardsEnrage = "Enraged!",

        bar_doomDebuff = "%s Doom",
        msg_doomDebuffYou = "You are Doomed! Decurse!",
        msg_doomDebuffOther = "%s is Doomed! Decurse!",

        bar_sleepParalysis = "%s Sleep Paralysis",
        msg_sleepParalysisYou = "You are paralyzed! Dispel!",
        msg_sleepParalysisOther = "%s is paralyzed! Dispel!",

        bar_terror = "Nathrezim Terror",
        bar_terrorCD = "Nathrezim Terror Cooldown",
        msg_terror = "Fear incoming!",

        bar_rainOfOutland = "Rain of Outland",
        msg_rainOfOutland = "Rain of Outland! Go kill adds!",
        msg_rainOfOutlandEnd = "Rain of Outland ended.",
    }
end)

local timer = {
    shacklesCD = {40, 100}, -- Estimated cooldown range from WCL
    shacklesCast = 2.5,
    shacklesDebuff = 6,

    shardsCast = 6,
    shardsCD = {90, 180}, -- Estimated cooldown range from WCL
    shardsChannel = 25,

    vampiricAuraCD = {20, 30},   -- not used atm

    terrorCD = {25, 60}, -- Estimated cooldown range from WCL
    terrorCast = 2.5,

    doomDuration = 8,
    rainOfOutland = 25,
}

local icon = {
    shackles = "inv_belt_18",
    shards = "spell_fire_soulburn",
    shardsChannel = "spell_fire_soulburn",
    shardsCounter = "spell_fire_soulburn",
    doom = "spell_shadow_antishadow",
    terror = "spell_shadow_deathcoil",
    sleepParalysis = "inv_misc_eye_01",
    rainOfOutland = "spell_shadow_rainoffire",
}

local color = {
    shacklesCast = "Red",
    shacklesDebuff = "Orange",
    shards = "Orange",
    shardsChannel = "Red",
    shardsCounter = "Yellow",
    doomDebuff = "Black",
    sleepParalysis = "Blue",
    terror = "Yellow",
    rainOfOutland = "Red",
}

local syncName = {
    shacklesCast = "MephistrothShacklesCast" .. module.revision,
    shacklesDebuff = "MephistrothShacklesDebuff" .. module.revision,
    shackleShatter = "MephistrothShackleShatter" .. module.revision,
    shacklesFade = "MephistrothShacklesFade" .. module.revision,
    shards = "MephistrothShardsOfHellfury" .. module.revision,
    shardsChannel = "MephistrothShardsOfHellfuryChannel" .. module.revision,
    shardsChannelEnd = "MephistrothShardsOfHellfuryChannelEnd" .. module.revision,
    shardsDeath = "MephistrothShardsOfHellfuryDeath" .. module.revision,
    shardsEnrage = "MephistrothShardsEnrage" .. module.revision,
    doomDebuff = "MephistrothDoomDebuff" .. module.revision,
    doomDebuffFade = "MephistrothDoomDebuffFade" .. module.revision,
    terror = "MephistrothTerror" .. module.revision,
    sleepParalysis = "MephistrothSleepParalysis" .. module.revision,
    sleepParalysisFade = "MephistrothSleepParalysisFade" .. module.revision,
    rainOfOutland = "MephistrothRainOfOutland" .. module.revision,
    rainOfOutlandEnd = "MephistrothRainOfOutlandEnd" .. module.revision,
}

local fail_shards = 0
local shardDeaths = 0
local shardDeathsSelfCount = 0
local lastShardsCastTime = 0
local maxShards = 6
local bossHealth = 100
local shacklesThresholdReached = false
local terrorThresholdReached = false

function module:OnSetup()
    self.started = nil
    fail_shards = 0
    shardDeaths = 0
    shardDeathsSelfCount = 0
    lastShardsCastTime = 0
    bossHealth = 100
    shacklesThresholdReached = false
    terrorThresholdReached = false
end

function module:OnEnable()
    if SUPERWOW_STRING or SetAutoloot then
        self:RegisterEvent("UNIT_CASTEVENT", "MephistrothCastEvent")
    end

    self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event") -- Engage

    self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event") -- Shackles of the Legion without superwow
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") -- Nathrezim Terror
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") -- Shards of Hellfury Casting
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") -- Vampiric Aura, Rain of Outland
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") -- Doom of Outland, Sleep Paralysis
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") -- Doom of Outland, Sleep Paralysis
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") -- Doom of Outland, Sleep Paralysis

    -- Debuff fades. Not fully tested yet. Please test this in your encounters.
    self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") -- Shackles, Doom, Sleep Paralysis
    self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
    self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

    self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event") -- Shackle Shatter
    self:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE", "Event")
    self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Event")

    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH") -- Shards death, Boss death

    self:ThrottleSync(2, syncName.shacklesCast)
    self:ThrottleSync(2, syncName.shacklesDebuff)
    self:ThrottleSync(2, syncName.shackleShatter)
    self:ThrottleSync(2, syncName.shacklesFade)
    self:ThrottleSync(2, syncName.shards)
    self:ThrottleSync(5, syncName.shardsChannel)
    self:ThrottleSync(5, syncName.shardsChannelEnd)
    self:ThrottleSync(0, syncName.shardsDeath)
    self:ThrottleSync(2, syncName.shardsEnrage)
    self:ThrottleSync(2, syncName.doomDebuff)
    self:ThrottleSync(2, syncName.doomDebuffFade)
    self:ThrottleSync(2, syncName.terror)
    self:ThrottleSync(2, syncName.sleepParalysis)
    self:ThrottleSync(2, syncName.sleepParalysisFade)
    self:ThrottleSync(5, syncName.rainOfOutland)
    self:ThrottleSync(5, syncName.rainOfOutlandEnd)
end

function module:OnEngage()
    fail_shards = 0
    shardDeaths = 0
    shardDeathsSelfCount = 0
    lastShardsCastTime = 0
    bossHealth = 100
    shacklesThresholdReached = false
    terrorThresholdReached = false
    self:ScheduleRepeatingEvent("CheckBossHP", self.CheckBossHP, 1, self)
    if not SUPERWOW_STRING then
        self.db.profile.debug_superwow = false
    end
end

function module:OnDisengage()
    if self:IsEventScheduled("CheckBossHP") then
		self:CancelScheduledEvent("CheckBossHP")
	end
    self:RemoveBar(L["bar_shardsCD"])
    self:RemoveBar(L["bar_shardsChannel"])
    self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_shardsCounter"])
    self:RemoveBar(L["bar_terrorCD"])
end

function module:CheckBossHP()
    -- todo: warn phase changes at different HP
    for i = 1, GetNumRaidMembers() do
        local targetString = "raid" .. i .. "target"
        local targetName = UnitName(targetString)
        if targetName == module.translatedName then
            local health = UnitHealth(targetString)
            local maxHealth = UnitHealthMax(targetString)
            if health > 0 and maxHealth > 0 then
                local healthPercent = (health / maxHealth) * 100
                if healthPercent < bossHealth then
                    bossHealth = healthPercent
                end

                -- Check Shackles threshold (90% HP). 
                -- Need to confirm. Maybe the threshold is not 90% but 80% or 85%? But I'm sure that the boss will not cast this above 90%
                if bossHealth < 90 and not shacklesThresholdReached then
                    shacklesThresholdReached = true
                    if self.db.profile.shacklescast then
                        self:IntervalBar(L["bar_shacklesCD"], timer.shacklesCD[1], timer.shacklesCD[2], icon.shackles, true, color.shacklesCast)
                    end
                end

                -- Check Terror threshold (50% HP)
                -- The boss starts terror cooldown after reaching 50% (The 1st rain of outland phase)
                if bossHealth < 50 and not terrorThresholdReached then
                    terrorThresholdReached = true
                    if self.db.profile.terror then
                        self:IntervalBar(L["bar_terrorCD"], timer.terrorCD[1], timer.terrorCD[2], icon.terror, true, color.terror)
                    end
                end
            end
            break
        end
    end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
    if string.find(msg, L["trigger_bossDeath"]) then
        BigWigs:CheckForBossDeath(msg, self)
    elseif string.find(msg, L["trigger_shardDeath"]) then
        shardDeathsSelfCount = shardDeathsSelfCount + 1
        if shardDeathsSelfCount <= maxShards then
            self:Sync(syncName.shardsDeath .. " " .. tostring(shardDeathsSelfCount))
            if shardDeathsSelfCount == maxShards then
                shardDeathsSelfCount = 0
            end
        end
    end
end

-- superwow mode not tested yet
function module:MephistrothCastEvent(casterGuid, targetGuid, eventType, spellId, castTime)
    if not self.db.profile.debug_superwow then return end

	if spellId == 51916 and (eventType == "START" or eventType == "CHANNEL") then
		self:Sync(syncName.shacklesCast .. " " .. (castTime / 1000))
	elseif spellId == 51917 then
		self:Sync(syncName.shackleShatter .. " " .. UnitName(casterGuid))
	elseif spellId == 51942 and eventType == "START" then
		fail_shards = 0
		self:Sync(syncName.shardsCast)
	elseif spellId == 51947 then
		if eventType == "CHANNEL" then
			self:Sync(syncName.shardsChannel .. " " .. (castTime / 1000))
		elseif eventType == "FAIL" then
			fail_shards = fail_shards + 1
			if fail_shards == maxShards then
				fail_shards = 0
				self:Sync(syncName.shardsChannelEnd)
			end
		end
	end
end

function module:Event(msg)
    -- engage
    if string.find(msg, L["trigger_engage"]) then
        self:Engage()
    end

    -- event handlers without superwow mode
    if not self.db.profile.debug_superwow or not SUPERWOW_STRING then
        -- shackle cast (without superwow)
        if string.find(msg, L["trigger_shackleCast"]) then
            self:Sync(syncName.shacklesCast)
        end

        -- shackle shatter
        if string.find(msg, L["trigger_shackleShatterYou"]) then
            self:Sync(syncName.shackleShatter .. " " .. UnitName("player"))
        elseif string.find(msg, L["trigger_shackleShatterOther"]) then
            local _, _, player = string.find(msg, L["trigger_shackleShatterOther"])
            self:Sync(syncName.shackleShatter .. " " .. player)
        end

        -- shards of hellfury
        if string.find(msg, L["trigger_shard"]) then
            shardDeathsSelfCount = 0
            self:Sync(syncName.shards)
        end
    end

    -- shackle debuff
    if string.find(msg, L["trigger_shacklesDebuffYou"]) then
        self:Sync(syncName.shacklesDebuff .. " " .. UnitName("player"))
    elseif string.find(msg, L["trigger_shacklesDebuffOther"]) then
        local _, _, player = string.find(msg, L["trigger_shacklesDebuffOther"])
        self:Sync(syncName.shacklesDebuff .. " " .. player)
    end

    -- shackles fade
    local _, _, player = string.find(msg, L["trigger_shacklesFade"])
    if player then
        player = player == "you" and UnitName("player") or player
        self:Sync(syncName.shacklesFade .. " " .. player)
    end

    -- doom of outland
    if string.find(msg, L["trigger_doomDebuffYou"]) then
        self:Sync(syncName.doomDebuff .. " " .. UnitName("player"))
    elseif string.find(msg, L["trigger_doomDebuffOther"]) then
        local _, _, player = string.find(msg, L["trigger_doomDebuffOther"])
        self:Sync(syncName.doomDebuff .. " " .. player)
    end

    -- doom of outland fade
    _, _, player = string.find(msg, L["trigger_doomDebuffFade"])
    if player then
        player = player == "you" and UnitName("player") or player
        self:Sync(syncName.doomDebuffFade .. " " .. player)
    end

    -- sleep paralysis
    if string.find(msg, L["trigger_sleepParalysisYou"]) then
        self:Sync(syncName.sleepParalysis .. " " .. UnitName("player"))
    elseif string.find(msg, L["trigger_sleepParalysisOther"]) then
        local _, _, player = string.find(msg, L["trigger_sleepParalysisOther"])
        self:Sync(syncName.sleepParalysis .. " " .. player)
    end

    -- sleep paralysis fade
    _, _, player = string.find(msg, L["trigger_sleepParalysisFade"])
    if player then
        player = player == "you" and UnitName("player") or player
        self:Sync(syncName.sleepParalysisFade .. " " .. player)
    end

    -- terror
    if string.find(msg, L["trigger_terror"]) then
        self:Sync(syncName.terror)
    end

    -- rain of outland
    if string.find(msg, L["trigger_rainOfOutland"]) then
        self:Sync(syncName.rainOfOutland)
    elseif string.find(msg, L["trigger_rainOfOutlandEnd"]) then
        self:Sync(syncName.rainOfOutlandEnd)
    end

    -- rain of outland ends
    if string.find(msg, L["trigger_rainOfOutlandEnd"]) then
        self:Sync(syncName.rainOfOutlandEnd)
    end

    -- shards enrage
    if string.find(msg, L["trigger_shardEnrage"]) then
         shardDeathsSelfCount = 0
        self:Sync(syncName.shardsEnrage)
    end
end

function module:BigWigs_RecvSync(sync, rest, nick)
    if sync == syncName.shacklesCast then
        local castTime = tonumber(rest) or timer.shacklesCast
        self:ShacklesCast(castTime)
    elseif sync == syncName.shacklesDebuff and rest then
        self:ShacklesDebuff(rest)
    elseif sync == syncName.shacklesFade and rest then
        self:ShacklesFade(rest)
    elseif sync == syncName.shackleShatter and rest then
        self:ShackleShatter(rest)
    elseif sync == syncName.shards then
        self:ShardsCast()
    elseif sync == syncName.shardsChannel and rest then  -- for superwow mode only
        local castTime = tonumber(rest)
        self:ShardsChannel(castTime)
    elseif sync == syncName.shardsChannelEnd then  -- for superwow mode only
        self:ShardsChannelEnd()
    elseif sync == syncName.shardsDeath and rest then
        self:ShardsDeathHandler(rest)
    elseif sync == syncName.shardsEnrage then
        self:ShardsEnrage()
    elseif sync == syncName.doomDebuff and rest and self.db.profile.doomofoutland then
        self:DoomDebuff(rest)
    elseif sync == syncName.doomDebuffFade and rest and self.db.profile.doomofoutland then
        self:DoomDebuffFade(rest)
    elseif sync == syncName.sleepParalysis and rest and self.db.profile.sleepparalysis then
        self:SleepParalysis(rest)
    elseif sync == syncName.sleepParalysisFade and rest and self.db.profile.sleepparalysis then
        self:SleepParalysisFade(rest)
    elseif sync == syncName.terror and self.db.profile.terror then
        self:Terror()
    elseif sync == syncName.rainOfOutland and self.db.profile.rainofoutland then
        self:RainOfOutland()
    elseif sync == syncName.rainOfOutlandEnd and self.db.profile.rainofoutland then
        self:RainOfOutlandEnd()
    end
end

function module:ShacklesCast(castTime)
    if not self.db.profile.shacklescast then return end
    shacklesThresholdReached = true
    local dur = castTime or timer.shacklesCast
    self:Sound("Beware")
    self:WarningSign(icon.shackles, dur, true, L["msg_shacklesCastAlert"])
    self:RemoveBar(L["bar_shacklesCD"])
    self:Bar(L["bar_shacklesCast"], dur, icon.shackles, true, color.shacklesCast)
    self:DelayedIntervalBar(dur, L["bar_shacklesCD"], timer.shacklesCD[1]-timer.shacklesCast, timer.shacklesCD[2]-timer.shacklesCast, icon.shackles, true, color.shacklesCast)
end

function module:ShacklesDebuff(player)
    if not self.db.profile.shacklesdebuff then return end
    if player == UnitName("player") then
        self:Message(L["msg_shacklesDebuffYou"], "Personal", false, nil, false)
        self:WarningSign(icon.shackles, timer.shacklesDebuff + 0.3, true, L["msg_shacklesDebuffYou"])
        self:Sound("Alarm")
        self:Bar(string.format(L["bar_shacklesDebuff"]), timer.shacklesDebuff + 0.3, icon.shackles, true, color.shacklesDebuff)
    end
end

function module:ShacklesFade(player)
    if not self.db.profile.shacklesdebuff then return end
    if player == UnitName("player") then
        self:RemoveBar(L["bar_shacklesDebuff"])
        self:RemoveWarningSign(icon.shackles)
    end
end

function module:ShackleShatter(player)
    if not self.db.profile.shackleshatter then return end
    player = player == UnitName("player") and "You" or player
    self:Message(string.format(L["msg_shackleShatter"], player), "Important", false, nil, false)
    self:Sound("Info")
end

function module:ShardsCast()
    if not self.db.profile.shards then return end
    lastShardsCastTime = GetTime()
    shardDeaths = 0
    self:RemoveBar(L["bar_shardsCD"])
    self:Bar(L["bar_shardsCast"], timer.shardsCast, icon.shards, true, color.shards)
    self:Message(L["msg_shardsCast"], "Important", false, nil, false)
    self:Sound("Alert")


    if not self.db.profile.debug_superwow or not SUPERWOW_STRING then
        self:DelayedBar(timer.shardsCast, L["bar_shardsChannel"], timer.shardsChannel, icon.shardsChannel, true, color.shardsChannel)
        -- start shard kill counter bar
        self:TriggerEvent("BigWigs_StartCounterBar", self, L["bar_shardsCounter"], maxShards, "Interface\\Icons\\"..icon.shards, true, color.shards)
        self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_shardsCounter"], shardDeaths)
    else  -- Add a shards CD timer for superwow mode
        self:DelayedIntervalBar(timer.shardsCast, L["bar_shardsCD"], timer.shardsCD[1]-timer.timer.shardsCast, timer.shardsCD[2]-timer.timer.shardsCast, icon.shards, true, color.shards)
    end
end

function module:ShardsChannel(castTime)   -- superwow mode only
    if not self.db.profile.shards then return end
    local dur = castTime or timer.shardsChannel
    self:Sound("Alarm")
    self:Bar(L["bar_shardsChannel"], dur, icon.shardsChannel, true, color.shardsChannel)
end

function module:ShardsChannelEnd()  -- superwow mode only
    if not self.db.profile.shards then return end
    self:RemoveBar(L["bar_shardsChannel"])
end

function module:ShardsDeathHandler(count)
    -- not enabled for superwow_mode
    if not self.db.profile.shards or (self.db.profile.debug_superwow and SUPERWOW_STRING) then return end
    local newCount = tonumber(count)
    if newCount and newCount > shardDeaths and newCount <= maxShards then
        shardDeaths = newCount
        -- Update counter bar
        self:TriggerEvent("BigWigs_SetCounterBar", self, L["bar_shardsCounter"], shardDeaths)
        if shardDeaths >= maxShards then
            self:RemoveBar(L["bar_shardsChannel"])
            self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_shardsCounter"])

            -- calculate the cooldown for the next shards cast
            local elapsed = GetTime() - lastShardsCastTime
            local minCD = timer.shardsCD[1] - elapsed
            local maxCD = timer.shardsCD[2] - elapsed
            if minCD < 0 then minCD = 0 end
            if maxCD < 0 then maxCD = 0 end
            self:IntervalBar(L["bar_shardsCD"], minCD, maxCD, icon.shards, true, color.shards)
        end
    end
end

function module:ShardsEnrage()
    if not self.db.profile.shards then return end
    shardDeaths = 0
    self:RemoveBar(L["bar_shardsChannel"])
    self:TriggerEvent("BigWigs_StopCounterBar", self, L["bar_shardsCounter"])
    self:Message(L["msg_shardsEnrage"], "Important", false, nil, false)
end

function module:DoomDebuff(player)
    if not self.db.profile.doomofoutland then return end
    if player == UnitName("player") then
        self:Message(L["msg_doomDebuffYou"], "Personal", false, nil, false)
    else
        self:Message(string.format(L["msg_doomDebuffOther"], player), "Urgent", false, nil, false)
    end
    self:Bar(string.format(L["bar_doomDebuff"], player), timer.doomDuration, icon.doom, true, color.doomDebuff)
    if self.db.profile.doommark then
        self:SetRaidTargetForPlayer(player, 8)
    end
end

function module:DoomDebuffFade(player)
    if not self.db.profile.doomofoutland then return end
    self:RemoveBar(string.format(L["bar_doomDebuff"], player))
    if self.db.profile.doommark then
        self:RestorePreviousRaidTargetForPlayer(player)
    end
end

function module:SleepParalysis(player)
    if not self.db.profile.sleepparalysis then return end
    if player == UnitName("player") then
        self:Message(L["msg_sleepParalysisYou"], "Personal", false, nil, false)
    else
        self:Message(string.format(L["msg_sleepParalysisOther"], player), "Urgent", false, nil, false)
    end
    if self.db.profile.sleepparalysismark then
        self:SetRaidTargetForPlayer(player, 5)
    end
end

function module:SleepParalysisFade(player)
    if not self.db.profile.sleepparalysis then return end
    if self.db.profile.sleepparalysismark then
        self:RestorePreviousRaidTargetForPlayer(player)
    end
end

function module:Terror()
    terrorThresholdReached = true
    if not self.db.profile.terror then return end
    self:RemoveBar("bar_terrorCD")
    self:Message(L["msg_terror"], "Urgent", false, nil, false)
    self:Sound("Alarm")
    self:WarningSign(icon.terror, timer.terrorCast)
    self:Bar(L["bar_terror"], timer.terrorCast, icon.terror, true, color.terror)
    self:DelayedIntervalBar(timer.terrorCast, L["bar_terrorCD"], timer.terrorCD[1]-timer.terrorCast, timer.terrorCD[2]-timer.terrorCast, icon.terror, true, color.terror)
end

function module:RainOfOutland()
    if not self.db.profile.rainofoutland then return end
    self:Message(L["msg_rainOfOutland"], "Important", false, nil, false)
    self:Bar(L["bar_rainOfOutland"], timer.rainOfOutland, icon.rainOfOutland, true, color.rainOfOutland) -- Assumed duration
end

function module:RainOfOutlandEnd()
    if not self.db.profile.rainofoutland then return end
    self:Message(L["msg_rainOfOutlandEnd"], "Positive", false, nil, false)
    self:RemoveBar(L["bar_rainOfOutland"])
end

--------------------------------------------------------------------------------
--  Tests
--------------------------------------------------------------------------------
function module:Test()
	BigWigs:EnableModule("Mephistroth")

	-- simulate engage
	self:Engage()

	-- 1) simulate the cast starting (START event)
	-- self:UNIT_CASTEVENT("player", "player", "START", 51916, 2)
	-- or CHANNEL:
	-- self:MephistrothCastEvent(nil, "player", "CHANNEL", 51916, 2)

	-- after cast finishes, simulate the debuff landing
	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest1", function()
		self:Event("You are afflicted by Shackles of the Legion")
	end, 2.1)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest2", function()
		self:Event("Ehawne is afflicted by Shackles of the Legion.")
	end, 2.1 + 7)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest3", function()
		self:Event("Ehawne is afflicted by Shackles of the Legion (1).")
	end, 2.1 + 15)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest4", function()
		self:Event("Milkpress is afflicted by Shackles of the Legion (1).")
	end, 2.1 + 23)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest5", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "START", 51916, 4000)
	end, 2.1 + 28) -- test this!

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CAST", 51917, 2000)
	end, 2.1 + 35)

	self:ScheduleEvent(self:ToString() .. "ShacklesDebuffTest6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CAST", 51917, 2000)
	end, 2.1 + 35)

	self:ScheduleEvent(self:ToString() .. "ShardsCDTest1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "START", 51942, 6000)
	end, 2.1 + 40)

	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "CHANNEL", 51947, 25000)
	end, 2.1 + 42)

	-- simulate hellfire shards ending their channel, naturally or by dying
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_1", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 47)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_2", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 48)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_3", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 48)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_4", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 49)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_5", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 49)
	self:ScheduleEvent(self:ToString() .. "ShardsChannelTest1_6", function()
		BigWigs:TriggerEvent("UNIT_CASTEVENT", "player", "player", "FAIL", 51947, 2000)
	end, 2.1 + 51)

	self:ScheduleEvent(self:ToString() .. "DoomTest1", function()
		self:Event(UnitName("player").." is afflicted by Doom of Outland (1).")
	end, 2.1 + 54)
	self:ScheduleEvent(self:ToString() .. "DoomTest2", function()
		self:Event("Doom of Outland fades from you.")
	end, 2.1 + 57)

	self:ScheduleEvent(self:ToString() .. "DoomTest3", function()
		self:Event("You are afflicted by Doom of Outland (1).")
	end, 2.1 + 60)
	self:ScheduleEvent(self:ToString() .. "DoomTest4", function()
		self:Event("Doom of Outland fades from "..UnitName("player")..".")
	end, 2.1 + 63)

	-- after the normal debuff duration, simulate fade
	-- self:ScheduleEvent(self:ToString() .. "ShacklesFadeTest", function()
	--   self:DebuffFade("Shackles of the Legion fades from " .. UnitName("player"))
	-- end, 2.1 + timer.shacklesDebuff + 0.1)

	BigWigs:Print("Mephistroth Shackles self‑test running...")
end
-- /run BigWigs:GetModule("Mephistroth"):Test()

-- Other test commands
if false then
--[[
/run BigWigs:EnableModule("Mephistroth") 

/script BigWigs:TriggerEvent("CHAT_MSG_MONSTER_YELL", "I foresaw your arrival. I don't remember the rest XD.")

/script BigWigs:TriggerEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Mephistroth begins to cast Shackles of the Legion.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Shackles of the Legion.")
/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Tbcisbest is afflicted by Shackles of the Legion.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Shackles of the Legion fades from you.")
/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Shackles of the Legion fades from Illidan.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Your Shackle Shatter hits Illidan for 7000 damage.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE", "Tbcisbest's Shackle Shatter hits You for 2000 damage.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Mephistroth gains Vampiric Aura (1).")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Sleep Paralysis.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Tbcisbest is afflicted by Sleep Paralysis.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Sleep Paralysis fades from you.") 
/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Sleep Paralysis fades from Tbcisbest.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Mephistroth begins to cast Nathrezim Terror.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Mephistroth begins to cast Shards of Hellfury.")

/script BigWigs:TriggerEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Hellfury Shard dies.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Mephistroth gains Unfathomed Hatred (1).")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Mephistroth gains Rain of Outland (1).")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Rain of Outland fades from Mephistroth.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "You are afflicted by Doom of Outland.")
/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Tbcisbest is afflicted by Doom of Outland.")

/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Doom of Outland fades from you.") 
/script BigWigs:TriggerEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Doom of Outland fades from Tbcisbest.")

/script BigWigs:TriggerEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Mephistroth dies.")

/script BigWigs:DisableModule("Mephistroth")

--]]
end
