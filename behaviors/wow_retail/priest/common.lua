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
  {
    type = "checkbox",
    uid = "PriestPurgeEnemies",
    text = "Dispel Magic (Purge)",
    default = false
  },
  {
    type = "checkbox",
    uid = "PriestAngelicFeather",
    text = "Angelic Feather",
    default = false
  },
}

local moveTime = 0
local startedMoving = 0
function commonPriest:MovementUpdate()
  local MovingForward = (Me.MovementFlags & MovementFlags.Forward) > 0

  if not MovingForward then
    moveTime = 0
    startedMoving = 0
  else
    if startedMoving == 0 then
      startedMoving = wector.Game.Time
    else
      moveTime = wector.Game.Time - startedMoving
    end
  end
end

function commonPriest:DesperatePrayer()
  local spell = Spell.DesperatePrayer
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PriestDesperatePrayerPct and spell:CastEx(Me)
end

local lastUsed = wector.Game.Time
function commonPriest:PowerWordFortitude()
  local spell = Spell.PowerWordFortitude
  if Me.InCombat or not Settings.PriestPowerWordFortitude then return false end
  if wector.Game.Time - lastUsed < 5000 then return false end

  local friends = WoWGroup:GetGroupUnits()

  for _, f in pairs(friends) do
    if spell:Apply(f) then lastUsed = wector.Game.Time return true end
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

function commonPriest:AngelicFeather()
  local spell = Spell.AngelicFeather
  if spell.Charges == 0 then return false end

  return Settings.PriestAngelicFeather and not Me:HasAura(spell.Name) and moveTime > 1000 and spell:CastEx(Me.Position)
end

function commonPriest:PowerWordLife()
  local spell = Spell.PowerWordLife
  if spell:CooldownRemaining() > 0 then return false end

  if Me.HealthPct < 35 and spell:CastEx(Me) then return true end

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit

    if friend.HealthPct < 35 and spell:CastEx(friend) then return true end
  end
end

function commonPriest:DispelMagic(priority)
  local spell = Spell.DispelMagic

  if not Settings.PriestPurgeEnemies then return false end

  if spell:Dispel(false, priority, WoWDispelType.Magic) then return true end
end

function commonPriest:Shadowfiend(enemy)
  local spell = Spell.Shadowfiend
  if spell:CooldownRemaining() > 0 then return false end

  local TTD = Combat:TargetsAverageDeathTime()

  return TTD ~= 9999 and TTD > 20 and Me.PowerPct < 85 and spell:CastEx(enemy)
end

function commonPriest:Mindgames(enemy)
  local spell = Spell.Mindgames
  if spell:CooldownRemaining() > 0 then return false end

  for _, e in pairs(Combat.Targets) do
    for _, friend in pairs(Heal.Friends.DPS) do
      if e.Target == friend then
        if spell:CastEx(e) then return true end
      end
    end
  end

  return spell:CastEx(enemy)
end

function commonPriest:ShadowWordDeath()
  local spell = Spell.ShadowWordDeath
  if spell:CooldownRemaining() > 0 then return false end

  for _, e in pairs(Combat.Targets) do
    if e.HealthPct < 20 and spell:CastEx(e) then return true end
  end

  return false
end

return commonPriest
