Menu2 = {}
Menu2.MainMenu = nil
Menu2.SubMenus = {}  -- New table for storing submenus
Menu2.MenuFlags = {} -- New table for storing menu flags

Menu2.EventListener = wector.FrameScript:CreateListener()
Menu2.EventListener:RegisterEvent('PLAYER_LEAVING_WORLD')

function Menu2.EventListener:PLAYER_LEAVING_WORLD()
  for k, v in pairs(Menu2) do
    if type(v) == 'table' and Menu2.MenuFlags[k] then
      Menu2[k] = nil
      Menu2.MenuFlags[k] = nil
    end
  end

  collectgarbage("collect")
  Menu2:Initialize()
end

function Menu2:Initialize()
  print('Initialize menu 2')
end

function Menu2:CreateBehaviorMenu(behaviorName)
  if not behaviorName then
    print('Behavior name required')
    return
  end

  local newMainMenu = ImMenu(behaviorName)
  self[behaviorName] = newMainMenu
  self.SubMenus[behaviorName] = {}    -- Create a submenus table for this behavior
  self.MenuFlags[behaviorName] = true -- Set the menu flag for this behavior

  print('Menu created for behavior: ' .. behaviorName)
end

function Menu2:AddOptionMenu(behaviorName, options)
  if not behaviorName or not self[behaviorName] then
    print('Invalid behavior name ' .. behaviorName)
    return
  end

  if not options.Name then
    print('Options require Name field')
    return
  end

  if not options.Widgets then
    print('Options require Widgets field')
    return
  end

  local submenu = self.SubMenus[behaviorName][options.Name]
  if not submenu then
    print('Submenu does not exist: ' .. options.Name)
    return
  end

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

function Menu2:CreateSubmenu(parentMenuName, submenuName)
  if not parentMenuName or not self[parentMenuName] then
    print('Invalid parent menu name ' .. parentMenuName)
    return
  end

  if not submenuName then
    print('Submenu name not provided')
    return
  end

  local submenu = self[parentMenuName]:CreateSubMenu(submenuName)
  if submenu then
    self.SubMenus[parentMenuName][submenuName] = submenu
    self.MenuFlags[string.format('%s.%s', parentMenuName, submenuName)] = true -- Set the menu flag for this submenu
    print('Submenu created: ' .. submenuName)
  else
    print('Failed to create submenu: ' .. submenuName)
  end
end

return Menu2
