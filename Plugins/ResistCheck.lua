assert(BigWigs, "BigWigs not found!")

local BWL = nil
local L = AceLibrary("AceLocale-2.2"):new("BigWigsResistCheck")
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

local RESISTANCE_TYPES = {
 [0] = "Physical",
 [1] = "Holy",
 [2] = "Fire",
 [3] = "Nature",
 [4] = "Frost",
 [5] = "Shadow",
 [6] = "Arcane"
}

local COLOR_GREEN = "00ff00"
local COLOR_RED = "ff0000"
local COLOR_WHITE = "ffffff"

---------------------------------
--      Localization           --
---------------------------------

L:RegisterTranslations("enUS", function()
 return {
  ["resistcheck"] = true,
  ["Resist Check"] = true,
  ["Commands for checking the raid's resistances."] = true,
  ["Query already running, please wait 5 seconds before trying again."] = true,
  ["Querying resistances for "] = true,
  ["BigWigs Resist Check"] = true,
  ["Close window"] = true,
  ["Showing resistance for "] = true,
  ["Player"] = true,
  ["Resistance"] = true,
  ["Query done."] = true,
  ["Closes the resistance query window."] = true,
  ["Physical"] = true,
  ["Holy"] = true,
  ["Fire"] = true,
  ["Nature"] = true,
  ["Frost"] = true,
  ["Shadow"] = true,
  ["Arcane"] = true,
  ["Resistance Type"] = true,
  ["Check"] = true,
  ["Runs a resistance check on the raid."] = true,
  ["Average"] = true,
  ["Minimum"] = true,
  ["Maximum"] = true,
  ["Players below"] = true,
  ["Notify low resistance"] = true,
  ["List people with resistance below threshold to raid chat."] = true,
  ["Threshold"] = true,
  ["Set the threshold value for low resistance warnings."] = true,
  ["<threshold>"] = true,
  ["People with low %s resistance (%d):"] = true,
  ["No Response"] = true,
 }
end)

---------------------------------
--      Addon Declaration      --
---------------------------------

BigWigsResistCheck = BigWigs:NewModule("Resist Check")

BigWigsResistCheck.defaultDB = {
 threshold = 222,
}
BigWigsResistCheck.consoleCmd = L["resistcheck"]
BigWigsResistCheck.consoleOptions = {
 type = "group",
 name = L["Resist Check"],
 desc = L["Commands for checking the raid's resistances."],
 args = {
  [L["Physical"]] = {
   type = "execute",
   name = L["Physical"],
   order = 1,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(0)
   end,
  },
  [L["Holy"]] = {
   type = "execute",
   name = L["Holy"],
   order = 2,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(1)
   end,
  },
  [L["Fire"]] = {
   type = "execute",
   name = L["Fire"],
   order = 3,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(2)
   end,
  },
  [L["Nature"]] = {
   type = "execute",
   name = L["Nature"],
   order = 4,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(3)
   end,
  },
  [L["Frost"]] = {
   type = "execute",
   name = L["Frost"],
   order = 5,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(4)
   end,
  },
  [L["Shadow"]] = {
   type = "execute",
   name = L["Shadow"],
   order = 6,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(5)
   end,
  },
  [L["Arcane"]] = {
   type = "execute",
   name = L["Arcane"],
   order = 7,
   desc = L["Runs a resistance check on the raid."],
   func = function()
    BigWigsResistCheck:QueryResistance(6)
   end,
  },
  spacer = {
   type = "header",
   name = " ",
   order = 10,
  },
  threshold = {
   type = "text",
   name = L["Threshold"],
   desc = L["Set the threshold value for low resistance warnings."],
   usage = L["<threshold>"],
   get = function()
    return tostring(BigWigsResistCheck.db.profile.threshold)
   end,
   set = function(v)
    BigWigsResistCheck.db.profile.threshold = tonumber(v) or 100
   end,
   order = 11,
  },
 }
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsResistCheck:OnEnable()
 self.queryRunning = nil
 self.responseTable = {}
 self.missingResponsesList = {}
 self.currentResistanceType = 0
 self.responses = 0

 BWL = AceLibrary("AceLocale-2.2"):new("BigWigs")

 self:RegisterEvent("BigWigs_RecvSync")
 self:TriggerEvent("BigWigs_ThrottleSync", "BWRQ", 0)
 self:TriggerEvent("BigWigs_ThrottleSync", "BWRR", 0)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsResistCheck:UpdateTablet()
 if not tablet:IsRegistered("BigWigs_ResistCheck") then
  tablet:Register("BigWigs_ResistCheck",
    "children", function()
     tablet:SetTitle(L["BigWigs Resist Check"])
     self:OnTooltipUpdate()
    end,
    "clickable", true,
    "showTitleWhenDetached", true,
    "showHintWhenDetached", true,
    "cantAttach", true,
    "menu", function()
     for index, resistType in pairs(RESISTANCE_TYPES) do
      local resistIndex = index -- Create a local copy of the index for each iteration
      dewdrop:AddLine(
        "text", L[resistType],
        "tooltipTitle", L[resistType],
        "tooltipText", L["Runs a resistance check on the raid."],
        "func", function()
         self:QueryResistance(resistIndex) -- Use the local copy
        end)
     end
     dewdrop:AddLine(
       "text", L["Notify low resistance"],
       "tooltipTitle", L["Notify low resistance"],
       "tooltipText", L["List people with resistance below threshold to raid chat."],
       "func", function()
        self:NotifyLowResistance()
       end)
     dewdrop:AddLine(
       "text", L["Close window"],
       "tooltipTitle", L["Close window"],
       "tooltipText", L["Closes the resistance query window."],
       "func", function()
        tablet:Attach("BigWigs_ResistCheck")
        dewdrop:Close()
       end)
    end
  )
 end
 if tablet:IsAttached("BigWigs_ResistCheck") then
  tablet:Detach("BigWigs_ResistCheck")
 else
  tablet:Refresh("BigWigs_ResistCheck")
 end
end

function BigWigsResistCheck:OnTooltipUpdate()
 local typeCat = tablet:AddCategory(
   "columns", 1,
   "text", L["Resistance Type"],
   "child_justify1", "LEFT"
 )
 typeCat:AddLine("text", L[RESISTANCE_TYPES[self.currentResistanceType]])

 local statsCat = tablet:AddCategory(
   "columns", 2,
   "text", L["Average"],
   "text2", self:GetAverageResistance(),
   "child_justify1", "LEFT",
   "child_justify2", "RIGHT"
 )
 statsCat:AddLine("text", L["Minimum"], "text2", self:GetMinResistance())
 statsCat:AddLine("text", L["Maximum"], "text2", self:GetMaxResistance())
 statsCat:AddLine("text", L["Players below"] .. " " .. self.db.profile.threshold,
   "text2", self:CountBelowThreshold())

 local playersCat = tablet:AddCategory(
   "columns", 2,
   "text", L["Player"],
   "text2", L["Resistance"],
   "child_justify1", "LEFT",
   "child_justify2", "RIGHT"
 )

 -- Sort players by resistance value
 local sortedPlayers = {}
 for name, resistance in pairs(self.responseTable) do
  table.insert(sortedPlayers, { name = name, resistance = resistance })
 end
 table.sort(sortedPlayers, function(a, b)
  return a.resistance > b.resistance
 end)

 for _, player in ipairs(sortedPlayers) do
  local color = COLOR_WHITE
  if player.resistance < self.db.profile.threshold then
   color = COLOR_RED
  elseif player.resistance >= 200 then
   color = COLOR_GREEN
  end
  playersCat:AddLine("text", player.name, "text2", "|cff" .. color .. player.resistance .. "|r")
 end

 -- Add a category for players who didn't respond
 if self.missingResponsesList and next(self.missingResponsesList) then
  local missingCat = tablet:AddCategory(
    "columns", 1,
    "text", L["No Response"],
    "child_justify1", "LEFT"
  )

  local missingPlayers = {}
  for name in pairs(self.missingResponsesList) do
   table.insert(missingPlayers, name)
  end
  table.sort(missingPlayers)

  for _, name in ipairs(missingPlayers) do
   missingCat:AddLine("text", name)
  end
 end
end

function BigWigsResistCheck:GetAverageResistance()
 local sum = 0
 local count = 0
 for _, resist in pairs(self.responseTable) do
  sum = sum + resist
  count = count + 1
 end
 return count > 0 and math.floor(sum / count) or 0
end

function BigWigsResistCheck:GetMinResistance()
 local min = nil
 for _, resist in pairs(self.responseTable) do
  if min == nil or resist < min then
   min = resist
  end
 end
 return min or 0
end

function BigWigsResistCheck:GetMaxResistance()
 local max = 0
 for _, resist in pairs(self.responseTable) do
  if resist > max then
   max = resist
  end
 end
 return max
end

function BigWigsResistCheck:CountBelowThreshold()
 local count = 0
 for _, resist in pairs(self.responseTable) do
  if resist < self.db.profile.threshold then
   count = count + 1
  end
 end
 return count
end

function BigWigsResistCheck:QueryResistanceAndShowWindow(resistType)
 self:QueryResistance(resistType)
 self:UpdateTablet()
end

function BigWigsResistCheck:QueryResistance(resistType)
 if self.queryRunning then
  self.core:Print(L["Query already running, please wait 5 seconds before trying again."])
  return
 end

 resistType = tonumber(resistType) or 0
 if resistType < 0 or resistType > 6 then
  resistType = 0
 end

 self.currentResistanceType = resistType

 self.core:Print(L["Querying resistances for "] .. "|cff" .. COLOR_GREEN .. L[RESISTANCE_TYPES[resistType]] .. "|r.")

 self.queryRunning = true

 -- Clear previous responses
 self.responseTable = {}
 self.missingResponsesList = {}

 -- Track all raid members who should respond
 if UnitInRaid("player") then
  for i = 1, GetNumRaidMembers() do
   local name = UnitName("raid" .. i)
   if name then
    self.missingResponsesList[name] = true
   end
  end
 else
  -- If not in raid, just handle party
  self.missingResponsesList[UnitName("player")] = true
  for i = 1, GetNumPartyMembers() do
   local name = UnitName("party" .. i)
   if name then
    self.missingResponsesList[name] = true
   end
  end
 end

 -- End the query after 5 seconds
 self:ScheduleEvent(function()
  BigWigsResistCheck.queryRunning = nil
  BigWigsResistCheck.core:Print(L["Query done."])
  BigWigsResistCheck:UpdateTablet()
 end, 5)

 -- Add our own resistance
 local _, totalResistance = UnitResistance("player", self.currentResistanceType)
 self.responseTable[UnitName("player")] = totalResistance
 self.missingResponsesList[UnitName("player")] = nil
 self.responses = 1

 -- Query the raid
 self:TriggerEvent("BigWigs_SendSync", "BWRQ " .. resistType)

 -- Update the display
 self:UpdateTablet()
end

function BigWigsResistCheck:NotifyLowResistance()
 if not self.responseTable or not next(self.responseTable) then
  return
 end

 local lowPlayers = {}
 for name, resistance in pairs(self.responseTable) do
  if resistance < self.db.profile.threshold then
   table.insert(lowPlayers, name .. ": " .. resistance)
  end
 end

 if table.getn(lowPlayers) > 0 then
  SendChatMessage(string.format(L["People with low %s resistance (%d):"],
    L[RESISTANCE_TYPES[self.currentResistanceType]],
    self.db.profile.threshold), "RAID")

  -- Send in chunks to avoid message length limits
  local message = ""
  for i, player in ipairs(lowPlayers) do
   if string.len(message) + string.len(player) > 240 then
    SendChatMessage(message, "RAID")
    message = player
   else
    if message == "" then
     message = player
    else
     message = message .. ", " .. player
    end
   end
  end

  if message ~= "" then
   SendChatMessage(message, "RAID")
  end
 end
end

function BigWigsResistCheck:BigWigs_RecvSync(sync, rest, nick)
 if sync == "BWRQ" and nick ~= UnitName("player") and rest then
  local resistType = tonumber(rest)
  if resistType and resistType >= 0 and resistType <= 6 then
   local _, totalResistance = UnitResistance("player", resistType)
   self:TriggerEvent("BigWigs_SendSync", "BWRR " .. totalResistance .. " " .. nick)
  end
 elseif sync == "BWRR" and self.queryRunning and nick and rest then
  local resistance, queryNick = self:ParseReply(rest)
  if queryNick == UnitName("player") then
   self.responseTable[nick] = resistance
   self.missingResponsesList[nick] = nil
   self.responses = self.responses + 1
   self:UpdateTablet()
  end
 end
end

function BigWigsResistCheck:ParseReply(reply)
 -- Reply format: "RESISTANCE_VALUE QUERYING_PLAYER_NAME"
 local first, last = string.find(reply, " ")
 if not first or not last then
  return 0, nil
 end

 local resistance = string.sub(reply, 1, first - 1)
 local nick = string.sub(reply, last + 1)

 return tonumber(resistance) or 0, nick
end
