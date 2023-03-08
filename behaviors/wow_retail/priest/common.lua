local commonPriest = {}

commonPriest.widgets = {
  {
    type = "text",
    uid = "PriestGeneralText",
    text = ">> General <<",
  },
  {
    type = "slider",
    uid = "PriestDesperatePrayerPct",
    text = "Desperate Prayer (%)",
    default = 0,
    min = 0,
    max = 100
  },
  {
    type = "combobox",
    uid = "CommonDispels",
    text = "Dispel",
    default = 0,
    options = { "Disabled", "Any", "Whitelist" }
  },
  {
    type = "checkbox",
    uid = "PriestPowerWordFortitude",
    text = "PW: Fortitude Friends",
    default = false
  },
}

function commonPriest:DesperatePrayer()
  local spell = Spell.DesperatePrayer
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PriestDesperatePrayerPct and spell:CastEx(Me)
end

function commonPriest:PowerWordFortitude()
  local spell = Spell.PowerWordFortitude
  if Me.InCombat or not Settings.PriestPowerWordFortitude then return false end

  local friends = WoWGroup:GetGroupUnits()

  for _, f in pairs(friends) do
    if spell:Apply(f) then return true end
  end
end

function commonPriest:Fade()
  local spell = Spell.Fade
  if not Me.InCombat or spell:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    local target = enemy.Target
    if target and target == Me then
      if spell:CastEx(Me) then return true end
    end
  end
end

return commonPriest
