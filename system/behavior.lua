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

local function trim_and_lower(input)
  return input:gsub("%s+", ""):lower()
end

function Behavior:Initialize(isReload)
  local class_trim = trim_and_lower(Me.ClassName)

  self:CollectScriptPaths(class_trim)

  if isReload and self.LoadedClass == Me.ClassName then
    return
  end

  print('Initialize Behaviors')

  for _, scriptPath in ipairs(self.LoadableScripts) do
    print('Load ' .. scriptPath .. ' ' .. Me.ClassName .. ' Behaviors')
    local behavior = require(scriptPath)

    if behavior.Options then
      Menu:AddOptionMenu(behavior.Options)
    end

    for _, behaviorType in pairs(BehaviorType) do
      self:AddBehaviorFunction(behavior.Behaviors, behaviorType)
    end

    Menu.CombatBehavior:AddOption(scriptPath)
  end

  self:LoadExtraBehaviors()

  -- Check if the setting exists, if not set the default
  local behaviorSettingKey = self:getBehaviorSettingKey()
  local selectedbehavior
  if Settings[behaviorSettingKey] then
    selectedbehavior = Settings[behaviorSettingKey]
  else
    selectedbehavior = self.LoadableScripts[1]
    Settings[behaviorSettingKey] = selectedbehavior
  end

  self:LoadBehavior(selectedbehavior)

  self:ReportLoadedBehaviors()

  self.LoadedClass = Me.ClassName
end

function Behavior:LoadBehavior(scriptPath)
  -- reset behaviors
  for k, v in pairs(BehaviorType) do
    self[v] = {}
  end
  local behavior = require(scriptPath)

  for _, behaviorType in pairs(BehaviorType) do
    self:AddBehaviorFunction(behavior.Behaviors, behaviorType)
  end
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

function Behavior:CollectScriptPaths(class_name)
  local class_trim = trim_and_lower(class_name)

  -- <root>\scripts\Pallas\behaviors\<classname>
  local path = filesystem.Path(string.format('%s\\behaviors\\%s\\%s\\', wector.script_path, wector.CurrentScript.Game,
    class_trim))

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)
    -- if scriptPath contains "common" skip
    if s:find(".common") then
      goto continue
    end
    -- if file has extension '.lua'
    if s:len() > 4 and s:match('.lua', s:len() - 4) then
      local rel = filesystem.relative_base(v, wector.script_path):gsub('\\', '.')
      rel = rel:sub(1, rel:len() - 4)
      -- Add the processed relative path to the list of loadable scripts
      table.insert(Behavior.LoadableScripts, rel)
      wector.Console:Log(rel)
    end
    ::continue::
  end

  return Behavior.LoadableScripts
end

function Behavior:LoadScript(index)
  -- Get the script path from the index
  local scriptPath = self.LoadableScripts[index]
  if not scriptPath then return end
  local behaviorSettingKey = self:getBehaviorSettingKey()
  print('setting rotation to ' .. scriptPath)
  Settings[behaviorSettingKey] = scriptPath

  self:LoadBehavior(scriptPath)
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
    -- Initialize self[type] as an empty table if it's not initialized yet
    self[type] = self[type] or {}
    table.insert(self[type], fn)
  end
end

function Behavior:getBehaviorSettingKey()
  local class_trim = trim_and_lower(Me.ClassName)
  -- Update the setting
  local behaviorSettingKey = class_trim
  return behaviorSettingKey
end

return Behavior
