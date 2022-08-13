Behavior = {}
Behavior.LoadedClass = ''

---@enum BehaviorType
BehaviorType = {
  Heal = 1,
  Tank = 2,
  Combat = 3,
  Rest = 4
}

local behavior_map = {
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
  local specname = behavior_map[classname:lower()][specid]

  -- remove spaces and makes it all lower-case
  local specname_trim = specname:gsub("%s+", "")
  specname_trim = specname_trim:lower()

  if isReload and self.LoadedClass == classname then
    return
  end

  print('Initialize Behaviors')

  -- reset behaviors
  for k, v in pairs(BehaviorType) do
    print('Reset ' .. k .. ' behaviors')
    self[v] = {}
  end


  print('Load ' .. specname .. ' ' .. classname .. ' Behaviors')
  local behavior = require('behaviors.' .. class_trim .. '.' .. specname_trim)

  if behavior.Options then
    self:AddBehaviorOptions(behavior.Options)
  end

  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Heal)
  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Combat)
  self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Rest)

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
    for _, v in ipairs(self[k]) do
      v()
    end
  end
end

---@param type BehaviorType
function Behavior:HasBehavior(type)
  if next(self[type]) ~= nil then
    return true
  end
  return false
end

function Behavior:AddBehaviorOptions(options)
  if not options.Name then
    print('Options require Name field')
    return
  end
  if not options.Widgets then
    print('Options require Widgets field')
    return
  end

  local menu = Menu.MainMenu
  local submenu = menu:CreateSubMenu(options.Name)
  for k, v in pairs(options.Widgets) do
    local type = v[1]
    local id = v[2]
    local text = v[3]
    local label = text .. '##' .. id
    if type == "text" then
      submenu:Add(ImText(text))
    elseif type == "slider" then
      local val = v[4] and v[4] or 0
      local min = v[5] and v[5] or 0
      local max = v[6] and v[6] or 100
      submenu:Add(ImSlider(label, val, min, max))
    elseif type == "checkbox" then
      local val = v[4] and v[4] or false
      submenu:Add(ImCheckbox(label, val))
    elseif type == "combobox" then
      local val = v[4] and v[4] or {}
      if _G.type(val) ~= "table" then
        val = {}
      end
      submenu:Add(ImCombobox(label, val))
    end
  end
end

function Behavior:DecideBestSpecialization()
  local bestspec = -1
  local bestspecpoints = -1
  for _, v in pairs(Me.TalentTabs) do
    if v.PointsUsed > bestspecpoints then
      bestspec = v.Id
      bestspecpoints = v.PointsUsed
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
