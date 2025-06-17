local module, L = BigWigs:ModuleDeclaration("Kruul", "Karazhan")

-- module variables
module.revision = 30001
module.enabletrigger = module.translatedName
module.toggleoptions = { "markofthelord", "markofthelordmark", "remorsestrikes", "proximity", "bosskill" }
module.zonename = {
 AceLibrary("AceLocale-2.2"):new("BigWigs")["Tower of Karazhan"],
 AceLibrary("Babble-Zone-2.2")["Tower of Karazhan"],
 "Outland",
 "???"
}

local _, playerClass = UnitClass("player")

-- module defaults
module.defaultDB = {
 markofthelord = true,
 markofthelordmark = true,
 remorsestrikes = playerClass ~= "MAGE" and playerClass ~= "WARLOCK" and playerClass ~= "HUNTER",
 proximity = playerClass ~= "WARRIOR" and playerClass ~= "ROGUE",
}

local syncName = {
 markofthelord = "KruulMarkOfTheLord" .. module.revision,
 markofthelordFade = "KruulMarkOfTheLordFade" .. module.revision,
 remorselessStrikes = "KruulRemorselessStrikes" .. module.revision,
}

-- localization
L:RegisterTranslations("enUS", function()
 return {
  cmd = "Kruul",

  markofthelord_cmd = "markofthelord",
  markofthelord_name = "Mark of the Highlord Alert",
  markofthelord_desc = "Warns when players get afflicted by Mark of the Highlord",

  markofthelordmark_cmd = "markofthelordmark",
  markofthelordmark_name = "Mark of the Highlord Raid Mark",
  markofthelordmark_desc = "Marks players with Mark of the Highlord and restores previous mark when it fades",

  remorsestrikes_cmd = "remorsestrikes",
  remorsestrikes_name = "Next Remorseless Strikes Alert",
  remorsestrikes_desc = "Shows a timer for Kruul's next Remorseless Strikes",

  proximity_cmd = "proximity",
  proximity_name = "Proximity Warning",
  proximity_desc = "Show Proximity Warning Frame",

  trigger_markofthelordYou = "You are afflicted by Mark of the Highlord",
  trigger_markofthelordOther = "(.+) is afflicted by Mark of the Highlord",
  trigger_markofthelordFade = "Mark of the Highlord fades from you",
  trigger_markofthelordFadeOther = "Mark of the Highlord fades from (.+)",
  trigger_wrathOfTheHighlord = "Kruul gains Wrath of the Highlord",

  msg_markofthelordYou = "Mark of the Highlord on YOU - GET OUT!",
  msg_markofthelordOther = "Mark of the Highlord on %s!",
  msg_wrathOfTheHighlord = "Kruul is ENRAGED - Good luck!",

  bar_markofthelordExpires = "Mark on YOU! GET OUT!",
  bar_nextCurses = "Next Curses",

  sync_markofthelord = syncName.markofthelord .. "(.*)", -- pattern to isolate player name
  sync_markofthelordfade = syncName.markofthelordFade .. "(.*)", -- pattern to isolate player name

  bar_nextRemorselessStrikes = "Next Remorseless Strikes",
  trigger_remorselessStrikes = "Kruul's Remorseless Strikes",

  trigger_engage = "Stepping before the High Lord of the Burning Legion",
 }
end)

module.proximityCheck = function(unit)
 return CheckInteractDistance(unit, 2)
end
module.proximitySilent = true

module:RegisterYellEngage(L.trigger_engage)

-- timer and icon variables
local timer = {
 markofthelordDuration = 20,
 nextCurses = 30,
 nextCursesEnraged = 15,
 firstRemorselessStrikes = 2,
 remorselessStrikes = 4,
}

local icon = {
 markofthelord = "Spell_Shadow_AntiShadow",
 nextCurses = "Spell_Shadow_AntiShadow",
 remorselessStrikes = "Spell_Shadow_RaiseDead",
}

local color = {
 red = "Red",
}

function module:OnEnable()
 -- only use self + party to avoid rate limiting
 self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "AfflictionEvent")
 self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "AfflictionEvent")

 self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
 self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
 self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "OnFriendlyDeath")

 self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "DamageEvent") --trigger_ww
 self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "DamageEvent") --trigger_ww

 -- Add detection for Wrath of the Highlord
 self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")

 -- other syncs will default to 1 second throttle
 self:ThrottleSync(1, syncName.remorselessStrikes)
end

function module:OnSetup()
 self.started = nil
 self.enragePhase = false

 -- Enable proximity warning
 if self.db.profile.proximity then
  self:Proximity()
 end
end

function module:OnEngage()
 self.enragePhase = false

 -- Start Next Curses timer when fight starts
 if self.db.profile.markofthelord then
  self:Bar(L["bar_nextCurses"], timer.nextCurses, icon.nextCurses)
 end

 -- Start first Remorseless Strikes timer
 if self.db.profile.remorsestrikes then
  self:Bar(L["bar_nextRemorselessStrikes"], timer.firstRemorselessStrikes, icon.remorselessStrikes)
 end

 -- Enable proximity warning
 if self.db.profile.proximity then
  self:Proximity()
 end
end

function module:OnDisengage()
 self:RemoveProximity()
end

function module:DamageEvent(msg)
 if string.find(msg, L["trigger_remorselessStrikes"]) then
  self:Sync(syncName.remorselessStrikes)
 end
end

function module:RemorselessStrikes()
 if self.db.profile.remorsestrikes then
  self:Bar(L["bar_nextRemorselessStrikes"], timer.remorselessStrikes, icon.remorselessStrikes)
 end
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
 if string.find(msg, L["trigger_wrathOfTheHighlord"]) then
  self.enragePhase = true
  if self.db.profile.markofthelord then
   self:Message(L["msg_wrathOfTheHighlord"], "Important", true, "Alarm")
  end
 end
end

function module:AfflictionEvent(msg)
 -- Mark of the Highlord
 if string.find(msg, L["trigger_markofthelordYou"]) then
  self:Sync(syncName.markofthelord .. UnitName("player")) -- include player name in sync to throttle for each player
 else
  local _, _, player = string.find(msg, L["trigger_markofthelordOther"])
  if player then
   self:Sync(syncName.markofthelord .. player) -- include player name in sync to throttle for each player
  end
 end
end

function module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
 if string.find(msg, L["trigger_markofthelordFade"]) then
  self:Sync(syncName.markofthelordFade .. UnitName("player"))
  self:RemoveBar(L["bar_markofthelordExpires"])
 end
end

function module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
 local _, _, player = string.find(msg, L["trigger_markofthelordFadeOther"])
 if player then
  self:Sync(syncName.markofthelordFade .. player)
 end
end

function module:OnFriendlyDeath(msg)
 local _, _, player = string.find(msg, "(.+) dies")
 if player then
  self:Sync(syncName.markofthelordFade .. player)
 end
end

function module:BigWigs_RecvSync(sync, rest, nick)
 if sync == syncName.remorselessStrikes then
  self:RemorselessStrikes()
  return
 end

 local _, _, markedPlayer = string.find(sync, L["sync_markofthelord"])

 if markedPlayer then
  self:MarkOfTheLord(markedPlayer)
  return
 end

 local _, _, unmarkedPlayer = string.find(sync, L["sync_markofthelordfade"])
 if unmarkedPlayer then
  self:MarkOfTheLordFade(unmarkedPlayer)
  return
 end
end

function module:MarkOfTheLord(player)
 if self.db.profile.markofthelord then
  if player == UnitName("player") then
   self:Sound("Beware")
   self:Message(L["msg_markofthelordYou"], "Important", true, "Alarm")
   self:WarningSign(icon.markofthelord, 5, true, "GET OUT")
   self:Bar(L["bar_markofthelordExpires"], timer.markofthelordDuration, icon.markofthelord, true, color.red)
  else
   self:Message(string.format(L["msg_markofthelordOther"], player), "Important", nil, "Alert")
  end

  -- Reset the next curses timer
  self:RemoveBar(L["bar_nextCurses"])
  if self.enragePhase then
   self:Bar(L["bar_nextCurses"], timer.nextCursesEnraged, icon.nextCurses)
  else
   self:Bar(L["bar_nextCurses"], timer.nextCurses, icon.nextCurses)
  end
 end

 -- Set raid mark if enabled
 if self.db.profile.markofthelordmark then
  self:SetCurseMark(player)
 end
end

function module:MarkOfTheLordFade(player)
 -- Restore previous raid mark if enabled
 if self.db.profile.markofthelordmark then
  self:RestoreMark(player)
 end
end

function module:SetCurseMark(player)
 local markToUse = self:GetAvailableRaidMark()
 if markToUse then
  self:SetRaidTargetForPlayer(player, markToUse)
 end
end

function module:RestoreMark(player)
 self:RestorePreviousRaidTargetForPlayer(player)
end

function module:Test()
 -- Initialize module state
 self:OnSetup()
 self:Engage()

 -- Get test player names
 local testPlayerName1 = UnitName("raid1") or "TestPlayer1"
 local testPlayerName2 = UnitName("raid2") or "TestPlayer2"
 local testPlayerName3 = UnitName("raid3") or "TestPlayer3"

 local events = {
  -- Mark of the Highlord events - all 3 players at once
  { time = 1, func = function()
   local msg = testPlayerName1 .. " is afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  { time = 1.1, func = function()
   local msg = testPlayerName2 .. " is afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  { time = 1.2, func = function()
   local msg = testPlayerName3 .. " is afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  -- Marks fade after duration
  { time = 11, func = function()
   local msg = "Mark of the Highlord fades from " .. testPlayerName1
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
  end },

  { time = 11.1, func = function()
   local msg = "Mark of the Highlord fades from " .. testPlayerName2
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
  end },

  { time = 13.2, func = function()
   local msg = "Mark of the Highlord fades from " .. testPlayerName3
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
  end },

  -- Second wave of marks
  { time = 15, func = function()
   local msg = "You are afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  { time = 15.3, func = function()
   local msg = testPlayerName1 .. " is afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  { time = 15.5, func = function()
   local msg = testPlayerName2 .. " is afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  -- One player dies with mark
  { time = 20, func = function()
   local msg = testPlayerName1 .. " dies"
   print("Test: " .. msg)
   module:OnFriendlyDeath(msg)
  end },

  -- Test enrage phase
  { time = 20, func = function()
   local msg = "Kruul gains Wrath of the Highlord"
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
  end },

  -- Other marks fade
  { time = 22, func = function()
   local msg = "Mark of the Highlord fades from you"
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_AURA_GONE_SELF(msg)
  end },

  { time = 23.1, func = function()
   local msg = "Mark of the Highlord fades from " .. testPlayerName2
   print("Test: " .. msg)
   module:CHAT_MSG_SPELL_AURA_GONE_OTHER(msg)
  end },

  { time = 25, func = function()
   local msg = "You are afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  { time = 40, func = function()
   local msg = "You are afflicted by Mark of the Highlord"
   print("Test: " .. msg)
   module:AfflictionEvent(msg)
  end },

  -- Test Remorseless Strikes scenarios
  { time = 5, func = function()
   local msg = "Kruul's Remorseless Strikes misses you."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  { time = 10, func = function()
   local msg = "Kruul's Remorseless Strikes hits " .. testPlayerName1 .. " for 1507."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  -- Test rapid Remorseless Strikes events (should only trigger once with throttle)
  { time = 14.9, func = function()
   local msg = "Kruul's Remorseless Strikes misses you."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  { time = 15.2, func = function()
   local msg = "Kruul's Remorseless Strikes hits " .. testPlayerName2 .. " for 1507."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  { time = 20, func = function()
   local msg = "Kruul's Remorseless Strikes hits " .. testPlayerName2 .. " for 1507."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },


  { time = 25, func = function()
   local msg = "Kruul's Remorseless Strikes hits " .. testPlayerName2 .. " for 1507."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  { time = 30, func = function()
   local msg = "Kruul's Remorseless Strikes hits " .. testPlayerName2 .. " for 1507."
   print("Test: " .. msg)
   module:DamageEvent(msg)
  end },

  -- End test
  { time = 35, func = function()
   print("Test: Disengage")
   module:Disengage()
  end },
 }

 -- Schedule each event at its absolute time
 for i, event in ipairs(events) do
  self:ScheduleEvent("KruulTest" .. i, event.func, event.time)
 end

 self:Message("Kruul test started", "Positive")
 return true
end

-- Test command:
-- /run local m=BigWigs:GetModule("Kruul"); BigWigs:SetupModule("Kruul");m:Test();
