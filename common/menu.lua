Menu = {}
---@type ImMenu
Menu.MainMenu = nil
---@type ImCombobox
Menu.CombatBehavior = nil

Menu.EventListener = wector.FrameScript:CreateListener()
Menu.EventListener:RegisterEvent('PLAYER_LEAVING_WORLD')
function Menu.EventListener:PLAYER_LEAVING_WORLD()
  Menu.MainMenu = nil
  collectgarbage("collect")
  Menu:Initialize()
end

function Menu:Initialize()
  if Menu.MainMenu then return end
  print('Initialize menu')

  Menu.MainMenu = ImMenu("Pallas")

  -- Behavior
  Menu.BehaviorGroup = ImGroupbox("Behavior")

  -- XXX: add back when ImText text value can be changed!
  --Menu.CurrentBehavior = ImText('')
  --Menu.BehaviorGroup:Add(Menu.CurrentBehavior)

  Menu.CombatBehavior = ImCombobox("Routine")
  Menu.CombatBehavior:AddOption("Change Routine") -- Add dummy option at 0th index
  -- Load the selected script when an option is selected
  Menu.CombatBehavior.OnSelect = function(_, _, _, _, newIdx)
    if newIdx > 0 then
      Behavior:onSelectBehavior(newIdx)
    end
  end

  Menu.BehaviorGroup:Add(Menu.CombatBehavior)
  -- End Behavior

  -- Combat
  Menu.CombatGroup = ImGroupbox("Combat")
  if Settings.PallasAutoTarget == nil then Settings.PallasAutoTarget = false end
  local autotarget = ImCheckbox("Auto-target", Settings.PallasAutoTarget)
  autotarget.OnClick = function(_, _, newValue) Settings.PallasAutoTarget = newValue end
  Menu.CombatGroup:Add(autotarget)

  if Settings.PallasAttackOOC == nil then Settings.PallasAttackOOC = false end
  local attackooc = ImCheckbox("Attack out of combat", Settings.PallasAttackOOC)
  attackooc.OnClick = function(_, _, newValue) Settings.PallasAttackOOC = newValue end
  Menu.CombatGroup:Add(attackooc)

  Menu.SpellGroup = ImGroupbox("Spell")

  if Settings.PallasGlobalDelay == nil then Settings.PallasGlobalDelay = false end
  local globaldelay = ImCheckbox("Spell Delay", Settings.PallasGlobalDelay)
  globaldelay.OnClick = function(_, _, newValue) Settings.PallasGlobalDelay = newValue end

  Menu.SpellGroup:Add(globaldelay)

  Menu.GeneralGroup = ImGroupbox("General")

  if Settings.PallasHealthstonePct == nil then Settings.PallasHealthstonePct = 30 end
  local healthstone = ImSlider("Healthstone at %", Settings.PallasHealthstonePct, 0, 100)
  healthstone.OnValueChanged = function(_, _, newValue) Settings.PallasHealthstonePct = newValue end
  Menu.GeneralGroup:Add(healthstone)

  Menu.MainMenu:Add(Menu.BehaviorGroup)
  Menu.MainMenu:Add(Menu.SpellGroup)
  Menu.MainMenu:Add(Menu.GeneralGroup)
  Menu.MainMenu:Add(Menu.CombatGroup)
end

function Menu:AddOptionMenu(options)
  -- sanity checks
  if not options.Name then
    print('Options require Name field')
    return
  end

  if not options.Widgets then
    print('Options require Widgets field')
    return
  end

  local submenu = self.MainMenu:CreateSubMenu(options.Name)
  for _, v in pairs(options.Widgets) do
    -- sanity checks
    if not v.type then
      print('Widget does not have a type')
      goto continue
    end
    if not v.uid then
      print('Widget does not have a unique id')
      goto continue
    end
    if not v.text then
      print('Widget does not have a text')
      goto continue
    end
    if v.type ~= 'text' and type(v.default) == 'nil' then
      print('Widget does not have a default value')
      goto continue
    end

    local label = string.format('%s##%s', v.text, v.uid)
    local safe_uid = v.uid:gsub("%s+", "")

    local value = nil
    if v.type ~= 'text' then
      if Settings[safe_uid] == nil then Settings[safe_uid] = v.default end
      value = Settings[safe_uid]
    end

    if v.type == "text" then
      submenu:Add(ImText(v.text))
    elseif v.type == "slider" then
      local min = v.min and v.min or 0
      local max = v.max and v.max or 100

      local slider = ImSlider(label, value, min, max)
      slider.OnValueChanged = function(_, _, newValue) Settings[safe_uid] = newValue end
      submenu:Add(slider)
    elseif v.type == "checkbox" then
      local cb = ImCheckbox(label, value)
      cb.OnClick = function(_, _, newValue) Settings[safe_uid] = newValue end
      submenu:Add(cb)
    elseif v.type == "combobox" then
      if not v.options or type(v.options) ~= 'table' then
        print('Combobox does not provide any options or is not a table')
        goto continue
      end
      for _, option in pairs(v.options) do
        if type(option) ~= 'string' then
          print('Combobox contains an option that is not a string!')
          goto continue
        end
      end

      local cb = ImCombobox(label, v.options, value)
      cb.OnSelect = function(_, _, _, _, newIdx) Settings[safe_uid] = newIdx end
      submenu:Add(cb)
    end

    ::continue::
  end
end

return Menu
