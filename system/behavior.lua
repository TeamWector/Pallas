Behavior = {}
Behavior.LoadedClass = ''
Behavior.Behaviors = {}

---@enum BehaviorType
BehaviorType = {
  Heal = 1,
  Tank = 2,
  Combat = 3,
  Rest = 4,
  Extra = 5
}

local behavior_map = {
  deathknight = {
    [398] = 'Blood',
    [399] = 'Frost',
    [400] = 'Unholy'
  },

  druid = {
    [283] = 'Balance',
    [281] = 'Feral',
    [282] = 'Restoration'
  },

  hunter = {
    [361] = 'Beast Mastery',
    [363] = 'Marksmanship',
    [362] = 'Survival'
  },

  mage = {
    [81] = 'Arcane',
    [41] = 'Fire',
    [61] = 'Frost'
  },

  paladin = {
    [382] = 'Holy',
    [383] = 'Protection',
    [381] = 'Retribution'
  },

  priest = {
    [201] = 'Discipline',
    [202] = 'Holy',
    [203] = 'Shadow'
  },

  rogue = {
    [182] = 'Assassination',
    [181] = 'Combat',
    [183] = 'Sublety'
  },

  shaman = {
    [261] = 'Elemental',
    [263] = 'Enhancement',
    [262] = 'Restoration'
  },

  warlock = {
    [302] = 'Affliction',
    [303] = 'Demonology',
    [301] = 'Destruction'
  },

  warrior = {
    [161] = 'Arms',
    [164] = 'Fury',
    [163] = 'Protection'
  }
}

---
--- Loads the behavior that best fits the current character specialization
function Behavior:Initialize(isReload)
  local classname = Me.ClassName

  -- remove spaces and makes it all lower-case
  local class_trim = classname:gsub("%s+", "")
  class_trim = class_trim:lower()

  local specid = self:DecideBestSpecialization()
  local specname = behavior_map[class_trim:lower()][specid]

  -- remove spaces and makes it all lower-case
  local specname_trim = specname:gsub("%s+", "")
  specname_trim = specname_trim:lower()

  if isReload and self.LoadedClass == classname then
    return
  end

  print('Initialize Behaviors')

  -- reset behaviors
  for k, v in pairs(BehaviorType) do
    self[v] = {}
  end

  print('Load ' .. specname .. ' ' .. classname .. ' Behaviors')
  local behavior = require('behaviors.' .. class_trim .. '.' .. specname_trim)

  if behavior.Options then
    Menu:AddOptionMenu(behavior.Options)
  end

  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Heal)
  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Combat)
  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Tank)
  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Rest)

  -- extra stuff
  local autoloot = require('extra.autoloot')
  if autoloot.Options then
    Menu:AddOptionMenu(autoloot.Options)
  end
  self:AddBehaviorFunction(autoloot.Behaviors, BehaviorType.Extra)

  local loaded_behaviors = 0
  for _, v in pairs(BehaviorType) do
    if #self[v] > 0 then
      loaded_behaviors = loaded_behaviors + #self[v]
    end
  end

  self.LoadedClass = classname
  print('Loaded ' .. loaded_behaviors .. ' behaviors for ' .. classname)
end

function Behavior:Update()
  -- Call all behaviors in whatever order they are in
  -- Could sort to call them in a specific order
  for _, k in pairs(BehaviorType) do
    if not self[k] then goto continue end
    for _, v in ipairs(self[k]) do
      v()
    end
    ::continue::
  end
end

function Behavior:CollectScriptPaths(name)
  -- <root>\scripts\Pallas\behaviors\<classname>
  local path = filesystem.Path(string.format('%s\\behaviors\\%s\\', wector.script_path, name))

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)
    -- if file has extension '.lua'
    if s:len() > 4 and s:match('.lua', s:len() - 4) then
      local rel = filesystem.relative_base(v, wector.script_path):gsub('\\', '.')
      rel = rel:sub(1, rel:len() - 4)
      wector.Console:Log(rel)
      local behavior = require(rel)
      if type(behavior) == 'boolean' and behavior then
        wector.Console:Log('Failed to load "' .. rel .. '"')
      end
    end
  end
end

---@param type BehaviorType
function Behavior:HasBehavior(type)
  if not self[type] then return false end
  if next(self[type]) ~= nil then
    return true
  end
  return false
end

function Behavior:DecideBestSpecialization()
  local bestspec = -1
  local bestspecpoints = -1
  for _, v in pairs(Me.Talents.ActiveTalentGroup.Tabs) do
    if v.Points > bestspecpoints then
      bestspec = v.Id
      bestspecpoints = v.Points
    end
  end
  return bestspec
end

function Behavior:AddBehaviorFunction(tbl, type)
  if not tbl or not tbl[type] then return end
  local fn = tbl[type]
  if fn then
    table.insert(self[type], fn)
  end
end

return Behavior
