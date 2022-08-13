Menu = {}
---@type ImMenu
Menu.MainMenu = nil

function Menu:OnCheckboxClick(oldValue, newValue)
  print('State of ' .. self.Label .. ' changed from ' .. tostring(oldValue) .. ' to ' .. tostring(newValue))
end

function Menu:OnSliderValueChanged(oldValue, newValue)
  print('State of ' .. self.Label .. ' changed from ' .. tostring(oldValue) .. ' to ' .. tostring(newValue))
end

function Menu:OnComboSelect(oldValue, oldIdx, newValue, newIdx)
  print('State of ' .. self.Label .. ' changed from ' ..
    tostring(oldValue) .. ' (' .. oldIdx .. ') to ' ..
    tostring(newValue) .. ' (' .. newIdx .. ')')
end

function Menu:Initialize()
  if Menu.MainMenu then return end

  print('Initialize menu')

  Menu.MainMenu = ImMenu("Pallas")

  Menu.GroupTest = ImGroupbox("Combat")

  local autotarget = ImCheckbox("Auto-target", Settings.Core.AutoTarget)
  autotarget.OnClick = function(_, _, newValue) Settings.Core.AutoTarget = newValue end
  Menu.GroupTest:Add(autotarget)

  Menu.MainMenu:Add(Menu.GroupTest)
end

return Menu
