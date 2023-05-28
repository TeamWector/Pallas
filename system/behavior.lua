Behavior = {}
Behavior.Loaded = {}
Behavior.Active = nil
Behavior.Extras = {}

--- XXX: ugly ugly ugly /ejt
Behavior.EventListener = wector.FrameScript:CreateListener()
Behavior.EventListener:RegisterEvent('PLAYER_LEAVING_WORLD')
function Behavior.EventListener:PLAYER_LEAVING_WORLD()
  Behavior.Loaded = {}
  Behavior.Active = nil
  Behavior.Extras = {}
end

---@enum BehaviorType
BehaviorType = {
  Heal = 1,
  Tank = 2,
  Combat = 3,
  Rest = 4,
  Extra = 5
}


function Behavior:Initialize(isReload)
  if isReload and self.LoadedClass == Me.ClassName then
    return
  end

  print('Initialize Behaviors')

  local behaviors = self:CollectScriptPaths()
  for _, scriptPath in ipairs(behaviors) do
    -- pcall require so we can catch errors
    local status, behavior = pcall(require, scriptPath)
    if status and self:ValidateBehavior(behavior) then
      -- TODO @IAN @SOVIET remove this when we have options refresh

      -- create a menu for this behavior
      Menu2:CreateBehaviorMenu(behavior.Name)

      -- iterate over all callbacks in behavior
      for className, classCallbacks in pairs(behavior.Callbacks) do
        for specname, specCallbacks in pairs(classCallbacks) do
          -- check if the Options field exists and add it to the menu
          if specCallbacks.Options and next(specCallbacks.Options) ~= nil then
            -- create a submenu under the behavior menu for these options
            Menu2:CreateSubmenu(behavior.Name, specCallbacks.Options.Name)
            -- add options for this submenu
            Menu2:AddOptionMenu(behavior.Name, specCallbacks.Options)
          end
        end
      end

      -- END TODO @IAN @SOVIET remove this when we have options refresh


      Menu.CombatBehavior:AddOption(behavior.Name)
      table.insert(self.Loaded, behavior)
    else
      print('Failed to load ' .. scriptPath)
    end
  end

  if table.length(self.Loaded) > 0 then
    if not Settings.ActiveBehavior then
      self:setActive(self.Loaded[1])
    else
      for k, v in ipairs(self.Loaded) do
        if v.Name == Settings.ActiveBehavior then
          self:setActive(self.Loaded[k])
        end
      end
      if not self.Active then
        Settings.ActiveBehavior = ""
        print('Could not find behavior found in settings, is it deleted?')
      end
    end
  end

  self:LoadExtraBehaviors()

  self:ReportLoadedBehaviors()
end

function Behavior:Update()
  local behavior = self.Active
  -- if no behavior is active, return
  if not behavior then return end

  local className = Me.ClassName:lower():gsub("%s+", "")
  local specname = Me:SpecializationName()

  -- Loop through BehaviorTypes
  for _, type in pairs(BehaviorType) do
    -- Check if a callback exists for the player's class, specialization and behavior type
    if behavior.Callbacks[className] and behavior.Callbacks[className][specname] and behavior.Callbacks[className][specname].Behaviors and behavior.Callbacks[className][specname].Behaviors[type] then
      -- Call the callback
      behavior.Callbacks[className][specname].Behaviors[type]()
    end
  end

  -- Handle Extras first
  for _, extraBehavior in pairs(self.Extras) do
    -- Iterate through all callbacks in this extra behavior
    for callbackName, callback in pairs(extraBehavior.Callbacks) do
      -- Check if Behaviors exists and is a function
      if callback.Behaviors then
        callback.Behaviors[BehaviorType.Extra]()
      else
        print('Failed to run ' .. callbackName .. ': Not a valid callback function')
      end
    end
  end
end

function Behavior:setActive(behavior)
  print(string.format('Setting active behavior to %s', behavior.Name))
  Settings.ActiveBehavior = behavior.Name
  self.Active = behavior

  -- TODO @IAN: Add Options when feature exists for the given specialization on behavior change
  -- find the appropriate options for this specialization
  -- local className = Me.ClassName:lower():gsub("%s+", "")
  -- local specname = Me:SpecializationName()

  -- if behavior.Callbacks[className] and behavior.Callbacks[className][specname] and behavior.Callbacks[className][specname].Options then
  --   Menu:AddOptionMenu(behavior.Callbacks[className][specname].Options)
  -- end
  -- XXX: add back when we can change ImText text value
  --Menu.CurrentBehavior.Text = behavior.Name
end

function Behavior:onSelectBehavior(idx)
  if idx <= table.length(self.Loaded) then
    self:setActive(self.Loaded[idx])
  end
end

function Behavior:ValidateBehavior(behavior)
  if not behavior.Name then
    print('Invalid behavior, it does not contain a name')
    return false
  end

  if not behavior.Classes or not type(behavior.Classes):match('[table|integer]') then
    print('Invalid behavior, it does not have any supported classes')
    return false
  end

  if behavior.Classes ~= Me.Class and (type(behavior.Classes) ~= 'table' or not behavior.Classes[Me.Class]) then
    wector.Console:Log(string.format('Behavior %s does not support %s, skipping', behavior.Name, Me.ClassName))
    return false
  end

  return true
end

function Behavior:LoadExtraBehaviors()
  -- <root>\behaviors\generic\
  local path = filesystem.Path(string.format('%s\\behaviors\\generic\\', wector.script_path))

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)

    if s:sub(-4) == ".lua" then
      -- find the last backslash in path to extract the behavior name
      local idx = s:find("\\[^\\]*$")
      if idx then
        local behaviorPath = string.format(s)
        local rel = filesystem.relative_base(behaviorPath, wector.script_path):gsub('\\', '.'):sub(1, -5)

        local status, behavior = pcall(require, rel)
        if status then
          if behavior.Callbacks and next(behavior.Callbacks) then
            -- create a menu for this behavior
            Menu2:CreateBehaviorMenu(behavior.Name)

            -- iterate over all callbacks in behavior
            for callbackName, callback in pairs(behavior.Callbacks) do
              -- check if the Options field exists and add it to the menu
              if callback.Options and next(callback.Options) ~= nil then
                -- create a submenu under the behavior menu for these options
                Menu2:CreateSubmenu(behavior.Name, callback.Options.Name)
                -- add options for this submenu
                Menu2:AddOptionMenu(behavior.Name, callback.Options)
              end
            end

            table.insert(self.Loaded, behavior)
            table.insert(self.Extras, behavior) -- insert the behavior into Extras
          else
            print('Failed to load ' .. behaviorPath .. ': Invalid behavior, it does not have any callbacks')
          end
        else
          print('Failed to load ' .. behaviorPath .. ': ' .. behavior)
        end
      end
    end
  end
end

function Behavior:ReportLoadedBehaviors()
  print('Loaded ' .. table.length(self.Loaded) .. ' behavior(s) for ' .. Me.ClassName)
end

function Behavior:CollectScriptPaths()
  local behaviors = {}

  -- <root>\behaviors\<game>\
  local path = filesystem.Path(string.format('%s\\behaviors\\%s\\', wector.script_path, wector.CurrentScript.Game))

  -- iterate all files in class behaviors directory
  local it = filesystem.Directory(path)
  for _, v in pairs(it) do
    local s = tostring(v)

    -- find the last backslash in path to extract the behavior name
    local idx = s:find("\\[^\\]*$")
    if idx then
      local behavior_name = s:sub(idx + 1, s:len())

      local behavior_path = string.format('%s\\%s', s, behavior_name)
      local rel = filesystem.relative_base(behavior_path, wector.script_path):gsub('\\', '.')
      wector.Console:Log('Adding behavior to list: ' .. rel)
      table.insert(behaviors, rel)
    end
  end

  return behaviors
end

---@param type BehaviorType
function Behavior:HasBehavior(type)
  local behavior = self.Active
  -- if no behavior is active, return
  if not behavior then return false end

  local className = Me.ClassName:lower():gsub("%s+", "")
  local specname = Me:SpecializationName()

  -- Check if a callback exists for the player's class, specialization, and behavior type
  if behavior.Callbacks[className] and behavior.Callbacks[className][specname] and behavior.Callbacks[className][specname].Behaviors and behavior.Callbacks[className][specname].Behaviors[type] then
    return true
  end

  return false
end

return Behavior
