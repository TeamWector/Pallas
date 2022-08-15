Settings = {
  Core = {
    AutoTarget = false,
    AttackOutOfCombat = false
  },
  Character = {}
}

function GetCharSetting(name)
  if not Me then return end

  return Settings.Character[Me.NameUnsafe][name]
end

function SetCharSetting(name, val)
  if not Me then return end

  Settings.Character[Me.NameUnsafe][name] = val
end

return Settings
