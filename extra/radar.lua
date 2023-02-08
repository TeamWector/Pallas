local gatherables = require("data.gatherables")
local herbs, ores, treasures = gatherables.herb, gatherables.ore, gatherables.treasure
local colors = require("data.colors")

local options = {
    Name = "Radar",
    -- widgets
    Widgets = {
        {
            type = "checkbox",
            uid = "ExtraRadar",
            text = "Enable Radar",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackHerbs",
            text = "Track Herbs",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackOres",
            text = "Track Ores",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackTreasures",
            text = "Track Treasures",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackQuests",
            text = "Track QuestObjects",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarTrackRares",
            text = "Track Rares",
            default = false
        },
        {
            type = "checkbox",
            uid = "ExtraRadarDrawLines",
            text = "Draw Lines",
            default = true
        },
        {
            type = "checkbox",
            uid = "ExtraRadarDrawDistance",
            text = "Draw Distance",
            default = false
        },
        {
            type = "slider",
            uid = "ExtraRadarLoadDistance",
            text = "Radar Load Distance",
            default = 200,
            min = 1,
            max = 200
        },
    }
}
local objectColors = {
    ["herb"] = colors.green,
    ["vein"] = colors.orange,
    ["treasure"] = colors.silver,
    ["rare"] = colors.purple,
    ["tracked"] = colors.white,
    ["quests"] = colors.pink
}

local manuallytracked = {}
local function ManualTrack(name)
  if manuallytracked[name] then
    manuallytracked[name] = nil
    wector.Console:Log("UNTRACKING: " .. name)
  else
    manuallytracked[name] = true
    wector.Console:Log("TRACKING: " .. name)
  end
end

local function IsTracked(name)
  return manuallytracked[name] ~= nil
end

RadarListener = wector.FrameScript:CreateListener()
RadarListener:RegisterEvent('CONSOLE_MESSAGE')

-- Easy way of manually adding target i guess..
function RadarListener:CONSOLE_MESSAGE(msg)
  local isTrackMessage = string.match(msg, "track")
  local isClearTrackedMessage = string.match(msg, "clearmanual")

  if isTrackMessage then
    if Me.Target then
      ManualTrack(Me.Target.Name)
    end
  end

  if isClearTrackedMessage then
    manuallytracked = {}
  end
end

local onscreen = {}
local offscreen = {}

local function IsOffscreen(object)
  local pos = object.Position
  local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
  return finish.x == -1.0 or finish.y == 1.0
end

---@param t string object type (rare, quest, herb, ore, treasure, tracked)
---@param o WoWObject WoWObject to check
function AddToScreenList(o, t)
  local list = IsOffscreen(o) and offscreen or onscreen
  table.insert(list, { object = o, type = t })
end

local function CollectVisuals()
  local objects = wector.Game.GameObjects
  local units = wector.Game.Units
  -- Settings
  local settings = {
      trackHerbs = Settings.ExtraRadarTrackHerbs,
      trackOres = Settings.ExtraRadarTrackOres,
      trackTreasures = Settings.ExtraRadarTrackTreasures,
      trackRares = Settings.ExtraRadarTrackRares,
      trackQuests = Settings.ExtraRadarTrackQuests,
      trackManual = table.length(manuallytracked) > 0,
      loadRange = Settings.ExtraRadarLoadDistance,
  }

  onscreen = {}
  offscreen = {}

  for _, unit in pairs(units) do
    local distance = Me.Position:DistanceSq(unit.Position)
    if distance <= settings.loadRange then
      if unit.Classification == Classification.Rare and settings.trackRares then
        AddToScreenList(unit, "rare")
      elseif IsTracked(unit.Name) and settings.trackManual then
        AddToScreenList(unit, "tracked")
      end
    end
  end

  for _, object in pairs(objects) do
    local distance = Me.Position:DistanceSq(object.Position)
    if distance <= settings.loadRange then
      local isQuest = object.DynamicFlags & 0x04 > 1 and settings.trackQuests
      local isHerb = herbs[object.EntryId] and settings.trackHerbs
      local isOre = ores[object.EntryId] and settings.trackOres
      local isTreasure = treasures[object.EntryId] and settings.trackTreasures

      if isQuest then
        AddToScreenList(object, "quest")
      elseif isHerb then
        AddToScreenList(object, "herb")
      elseif isOre then
        AddToScreenList(object, "vein")
      elseif isTreasure then
        AddToScreenList(object, "treasure")
      end
    end
  end
end

local function DrawColoredLines()
  if not Settings.ExtraRadarDrawLines then return end

  for _, o in pairs(onscreen) do
    local object = o.object
    local type = o.type
    local pos = object.Position
    local start = World2Screen(Me.Position)
    local finish = World2Screen(Vec3(pos.x, pos.y, pos.z + object.DisplayHeight))
    local color = objectColors[type] or colors.white

    DrawLine(start, finish, color, 2)
  end
end

local function DrawColoredText()
  local add = 1
  local max = 4
  local count = 0
  local mepos = Me.Position

  for _, o in pairs(offscreen) do
    if count >= max then break end
    local object = o.object
    local textpos = World2Screen(Vec3(mepos.x, mepos.y, mepos.z + add))
    local text = "Not On Screen: " ..
        object.Name .. ", Distance: " .. math.floor(Me.Position:DistanceSq(object.Position)) .. " yards"

    DrawText(textpos, colors.teal, text)
    add = add + 0.4
    count = count + 1
  end

  for _, o in pairs(onscreen) do
    local object = o.object
    local type = o.type
    local textpos = World2Screen(Vec3(object.Position.x, object.Position.y,
            object.Position.z + object.DisplayHeight + 1))
    local text = "[" .. string.upper(type:sub(1, 1)) .. "] " .. object.Name

    if Settings.ExtraRadarDrawDistance then
      text = text .. ", Distance: " .. math.floor(Me.Position:DistanceSq(object.Position)) .. "yd"
    end

    DrawText(textpos, colors.yellow, text)
  end
end

local function Radar()
  if not Settings.ExtraRadar then return end

  CollectVisuals()
  DrawColoredText()
  DrawColoredLines()
end

local behaviors = {
    [BehaviorType.Extra] = Radar
}

wector.Console:Log("Radar Loaded")

return { Options = options, Behaviors = behaviors }
