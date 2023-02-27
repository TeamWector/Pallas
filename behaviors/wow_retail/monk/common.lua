local commonMonk = {}
local dispels = require('data.dispels')

commonMonk.widgets = {
  {
    type = "text",
    uid = "MonkGeneralText",
    text = "----------------GENERAL--------------------",
  },
  {
    type = "slider",
    uid = "MonkInterruptPct",
    text = "Kick Cast Left (%)",
    default = 0,
    min = 0,
    max = 100
  },
  {
    type = "slider",
    uid = "MonkFortifyingPct",
    text = "Fortifying Brew (%)",
    default = 0,
    min = 0,
    max = 100
  },
  {
    type = "slider",
    uid = "MonkDampenPct",
    text = "Dampen Harm (%)",
    default = 0,
    min = 0,
    max = 100
  },
  {
    type = "slider",
    uid = "MonkDiffuseMagicPct",
    text = "Diffuse Magic (%)",
    default = 0,
    min = 0,
    max = 100
  },
  {
    type = "checkbox",
    uid = "MonkShouldDetox",
    text = "Dispel Party",
    default = false
  },
}

function commonMonk:Detox(...)
  if not Settings.MonkShouldDetox or Spell.Detox:CooldownRemaining() > 0 then return end

  local dispelTypes = { ... }
  local group = WoWGroup:GetGroupUnits()

  for _, unit in pairs(group) do
    local auras = unit.VisibleAuras
    for _, aura in pairs(auras) do
      local debuff = aura.IsDebuff or aura.Caster and aura.Caster.IsEnemy
      if debuff and dispels[aura.Id] and aura.Remaining > 2000 then
        for _, dispelType in pairs(dispelTypes) do
          if dispels[aura.Id] == dispelType then
            return Spell.Detox:CastEx(unit)
          end
        end
      end
    end
  end
end

function commonMonk:SpearHandStrike()
  if Spell.SpearHandStrike:CooldownRemaining() > 0 then return end

  for _, e in pairs(Combat.Targets) do
    local cast = e.IsInterruptible and e.CurrentCast
    if not cast then goto continue end

    local isChannel = e.CurrentChannel
    local castRemains = cast.CastEnd - wector.Game.Time
    local castTime = cast.CastEnd - cast.CastStart
    local castPctRemain = math.floor(castRemains / castTime * 100)

    if (castPctRemain < Settings.MonkInterruptPct or isChannel) and Spell.SpearHandStrike:CastEx(e) then return true end
    ::continue::
  end
end

function commonMonk:TouchOfDeath(enemy)
  local spell = Spell.TouchOfDeath
  if spell:CooldownRemaining() > 0 then return end
  local improved = Me:GetAura(322113)

  for _, t in pairs(Combat.Targets) do
    local valid = t.Health < Me.Health or improved and t.HealthPct < 15

    if valid and spell:CastEx(t, SpellCastExFlags.NoUsable) then return true end
  end
end

function commonMonk:TigersLust()
  local spell = Spell.TigersLust
  if spell:CooldownRemaining() > 0 then return end
  local friends = WoWGroup:GetGroupUnits()

  for _, f in pairs(friends) do
    local rooted = (f.MovementFlags & MovementFlags.Root > 0)
    if rooted and spell:CastEx(f) then return true end
  end
end

function commonMonk:LegSweep()
  local spell = Spell.LegSweep
  if spell:CooldownRemaining() > 0 or Me:IsMoving() then return end

  local count = 0

  for _, enemy in pairs(Combat.Targets) do
    if Me:GetDistance(enemy) <= 6 and not enemy:IsStunned() then
      count = count + 1
    end
  end

  return count > 1 and spell:CastEx(Me)
end

function commonMonk:FortifyingBrew()
  local spell = Spell.FortifyingBrew
  if spell:CooldownRemaining() > 0 then return end

  return Me.InCombat and Me.HealthPct < Settings.MonkFortifyingPct and spell:CastEx(Me)
end

function commonMonk:DampenHarm()
  local spell = Spell.DampenHarm
  if spell:CooldownRemaining() > 0 then return end

  return Me.InCombat and Me.HealthPct < Settings.MonkDampenPct and spell:CastEx(Me)
end

--- Will only use diffuse magic if someone is casting on us and we are below threshold.
function commonMonk:DiffuseMagic()
  local spell = Spell.DiffuseMagic
  if spell:CooldownRemaining() > 0 or Me.HealthPct > Settings.MonkDiffuseMagicPct then return end

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.IsCastingOrChanneling then goto continue end

    local spellInfo = enemy.SpellInfo
    local castingMe = spellInfo.TargetGuid1 == Me.Guid
    local castingRemain = spellInfo.CastEnd - wector.Game.Time

    if castingMe and castingRemain < 200 and Spell.DiffuseMagic:CastEx(Me) then return true end

    ::continue::
  end
end

return commonMonk
