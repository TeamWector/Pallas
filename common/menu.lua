Menu = {}
---@type ImMenu
Menu.MainMenu = nil

function Menu:Initialize()
  if Menu.MainMenu then return end

  print('Initialize menu')

  Menu.MainMenu = ImMenu("Pallas")

  Menu.GroupTest = ImGroupbox("Combat")

  local autotarget = ImCheckbox("Auto-target", Settings.Core.AutoTarget)
  autotarget.OnClick = function(_, _, newValue) Settings.Core.AutoTarget = newValue end
  Menu.GroupTest:Add(autotarget)

  local attackooc = ImCheckbox("Attack out of combat", Settings.Core.AttackOutOfCombat)
  attackooc.OnClick = function(_, _, newValue) Settings.Core.AttackOutOfCombat = newValue end
  Menu.GroupTest:Add(attackooc)

  Menu.MainMenu:Add(Menu.GroupTest)
end

return Menu
