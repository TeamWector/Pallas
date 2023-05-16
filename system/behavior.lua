Behavior = {}
Behavior.LoadedClass = ''
Behavior.Routines = {}
Behavior.Behaviors = {}

---@enum BehaviorType
BehaviorType = {
  Heal = 1,
  Tank = 2,
  Combat = 3,
  Rest = 4,
  Extra = 5
}

local behavior_map = require('data.specializations')

---
--- Loads the behavior that best fits the current character specialization
function Behavior:Initialize(isReload)
  local classname = Me.ClassName

  -- remove spaces and makes it all lower-case
  local class_trim = classname:gsub("%s+", "")
  class_trim = class_trim:lower()

  -- HAX REMOVE ME
  self:CollectScriptPaths(class_trim)
  -- HAX REMOVE ME END

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
  local behavior = require('behaviors.' .. wector.CurrentScript.Game .. '.' .. class_trim .. '.' .. specname_trim)

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

  local antiafk = require('extra.antiafk')
  if antiafk.Options then
    Menu:AddOptionMenu(antiafk.Options)
  end
  self:AddBehaviorFunction(antiafk.Behaviors, BehaviorType.Extra)

  local radar = require('extra.radar')
  if radar.Options then
    Menu:AddOptionMenu(radar.Options)
  end
  self:AddBehaviorFunction(radar.Behaviors, BehaviorType.Extra)

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
  local class_trim = name:gsub("%s+", "")
  class_trim = class_trim:lower()
  -- <root>\scripts\Pallas\behaviors\<classname>
  local path = filesystem.Path(string.format('%s\\behaviors\\%s\\%s\\', wector.script_path, wector.CurrentScript.Game,
  class_trim))

  self.LoadableScripts = {} -- Initialize the list of loadable scripts

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)
    -- if file has extension '.lua'
    if s:len() > 4 and s:match('.lua', s:len() - 4) then
      local rel = filesystem.relative_base(v, wector.script_path):gsub('\\', '.')
      rel = rel:sub(1, rel:len() - 4)

      -- Add the relative path to the list of loadable scripts
      table.insert(self.LoadableScripts, rel)

      wector.Console:Log(rel)
    end
  end

  return self.LoadableScripts
end

function table.tostring(tbl)
  local result = "{"
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      v = table.tostring(v)
    end
    result = result .. tostring(k) .. ": " .. tostring(v) .. ", "
  end
  return result .. "}"
end

function Behavior:LoadScript(index)
  -- Get the script path from the index
  local scriptPath = self.LoadableScripts[index]
  if scriptPath then
    -- Convert the current state of the Behaviors table to a string and print it
    print('Behaviors table before loading: ' .. table.tostring(self))

    -- Print the path of the script being loaded
    print('Loading script: ' .. scriptPath)

    -- Load the script
    local behavior = require(scriptPath)
    if type(behavior) == 'table' then
      -- If the loaded script has options, add them to the menu
      if behavior.Options then
        Menu:AddOptionMenu(behavior.Options)
      end

      -- Add behavior functions for each behavior type
      self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Heal)
      self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Combat)
      self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Tank)
      self:AddBehaviorFunction(behavior.Behaviors, BehaviorType.Rest)

      -- Print a message indicating the number of behaviors loaded
      local loaded_behaviors = 0
      for _, v in pairs(BehaviorType) do
        if #self[v] > 0 then
          loaded_behaviors = loaded_behaviors + #self[v]
        end
      end
      print('Loaded ' .. loaded_behaviors .. ' behaviors from ' .. scriptPath)

      -- Convert the new state of the Behaviors table to a string and print it
      print('Behaviors table after loading: ' .. table.tostring(self))
    else
      wector.Console:Log('Failed to load "' .. scriptPath .. '"')
    end
  else
    wector.Console:Log('No script at index ' .. index)
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
  if wector.CurrentScript.Game == 'wow_retail' then
    return Me.Talents.ActiveSpecializationId
  elseif wector.CurrentScript.Game == 'wow_wrath' then
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
  return -1
end

function Behavior:AddBehaviorFunction(tbl, type)
  if not tbl or not tbl[type] then return end
  local fn = tbl[type]
  if fn then
    table.insert(self[type], fn)
  end
end

return Behavior
