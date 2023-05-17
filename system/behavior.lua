Behavior = {}
Behavior.LoadedClass = ''
Behavior.LoadableScripts = {}
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

local function trim_and_lower(input)
  return input:gsub("%s+", ""):lower()
end

function Behavior:Initialize(isReload)
  local class_trim = trim_and_lower(Me.ClassName)

  local specid = self:DecideBestSpecialization()
  local defaultspecname = behavior_map[class_trim][specid]

  self:CollectScriptPaths(class_trim, defaultspecname)

  -- Check if the setting exists, if not set the default
  local behaviorSettingKey = self:getBehaviorSettingKey()
  local specname_trim
  if Settings[behaviorSettingKey] then
    specname_trim = Settings[behaviorSettingKey]
  else
    specname_trim = trim_and_lower(defaultspecname)
    Settings[behaviorSettingKey] = specname_trim
  end

  if isReload and self.LoadedClass == Me.ClassName then
    return
  end

  print('Initialize Behaviors')

  self:LoadBehaviors(class_trim, specname_trim)

  self:LoadExtraBehaviors()

  self:ReportLoadedBehaviors()
end

function Behavior:LoadBehaviors(class_trim, specname_trim)
   -- reset behaviors
  for k, v in pairs(BehaviorType) do
    self[v] = {}
  end

  print('Load ' .. specname_trim .. ' ' .. Me.ClassName .. ' Behaviors')
  local behavior = require('behaviors.' .. wector.CurrentScript.Game .. '.' .. class_trim .. '.' .. specname_trim)

  if behavior.Options then
    Menu:AddOptionMenu(behavior.Options)
  end

  for _, behaviorType in pairs(BehaviorType) do
    self:AddBehaviorFunction(behavior.Behaviors, behaviorType)
  end

  self.LoadedClass = Me.ClassName
end

function Behavior:LoadExtraBehaviors()
  local extras = { 'autoloot', 'antiafk', 'radar' }

  for _, extra in ipairs(extras) do
    local module = require('extra.' .. extra)
    if module.Options then
      Menu:AddOptionMenu(module.Options)
    end
    self:AddBehaviorFunction(module.Behaviors, BehaviorType.Extra)
  end
end

function Behavior:ReportLoadedBehaviors()
  local loaded_behaviors = 0
  for _, v in pairs(BehaviorType) do
    if #self[v] > 0 then
      loaded_behaviors = loaded_behaviors + #self[v]
    end
  end

  print('Loaded ' .. loaded_behaviors .. ' behaviors for ' .. Me.ClassName)
end

function Behavior:LoadScript(index)
  -- Get the script path from the index
  local specname_trim = self.LoadableScripts[index]
  if not specname_trim then return end

  local class_trim = trim_and_lower(Me.ClassName)
  local behaviorSettingKey = self:getBehaviorSettingKey()
  print('setting rotation to ' .. specname_trim)
  Settings[behaviorSettingKey] = specname_trim

  Menu.MainMenu = nil
  collectgarbage("collect")

  Menu:Initialize()

  self:LoadBehaviors(class_trim, specname_trim)

  self:LoadExtraBehaviors()

  self:ReportLoadedBehaviors()
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

function Behavior:CollectScriptPaths(class_name, spec_name)
  local class_trim = trim_and_lower(class_name)
  local spec_trim = trim_and_lower(spec_name)

  -- <root>\scripts\Pallas\behaviors\<classname>
  local path = filesystem.Path(string.format('%s\\behaviors\\%s\\%s\\', wector.script_path, wector.CurrentScript.Game,
  class_trim))

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)
    -- if file has extension '.lua'
    if s:len() > 4 and s:match('.lua', s:len() - 4) then
      local rel = filesystem.relative_base(v, wector.script_path):gsub('\\', '.')
      rel = rel:sub(1, rel:len() - 4)

      -- Process rel one more time, capture everything after the last "."
      rel = rel:match(".*%.(.*)")

      -- If rel contains spec_trim, add the processed relative path to the list of loadable scripts
      if rel:find(spec_trim) then
        table.insert(Behavior.LoadableScripts, rel)
        Menu.CombatBehavior:AddOption(rel)
        wector.Console:Log(rel)
      end
    end
  end

  return Behavior.LoadableScripts
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

function Behavior:getBehaviorSettingKey()
  local class_trim = trim_and_lower(Me.ClassName)
  local specid = self:DecideBestSpecialization()

  -- Update the setting
  local behaviorSettingKey = class_trim .. specid .. 'rotation'

  return behaviorSettingKey
end

return Behavior
