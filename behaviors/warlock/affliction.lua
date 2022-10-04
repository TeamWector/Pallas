local options = {
  -- The sub menu name
  Name = "Warlock (Affli)",

  -- widgets
  Widgets = {
    {
      type = "slider",
      uid = "UAThreshold",
      text = "UA Threshold",
      default = 2000,
      min = 0,
      max = 20000
    },
    {
      type = "slider",
      uid = "CorruptionThreshold",
      text = "Corruption Threshold",
      default = 1000,
      min = 0,
      max = 20000
    },
    {
      type = "slider",
      uid = "AgonyThreshold",
      text = "Agony Threshold",
      default = 1000,
      min = 0,
      max = 20000
    },
  }
}


WarlockAfflListener = wector.FrameScript:CreateListener()
WarlockAfflListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

-- This fixes the problem of double casting UA
local UAFix = 0
function WarlockAfflListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
  if unitTarget == Me and spellID == Spell.UnstableAffliction.Id then
    UAFix = wector.Game.Time + 100
  end
end

local GCD = WoWSpell(61304)
local function WarlockAfflictionCombat()
  if Me.IsMounted then return end
  if not Me.IsChanneling and Me.HealthPct > 85 and (Me.PowerPct < 60 or not Me.InCombat and Me.PowerPct < 95) and Spell.LifeTap:CastEx(Me) then return end

  if not Me.InCombat then
    if not Me:HasVisibleAura(Spell.FelArmor.Name) and Spell.FelArmor:CastEx(Me) then return end
    if not Me:HasVisibleAura(Spell.UnendingBreath.Name) and Me:IsSwimming() and Spell.UnendingBreath:CastEx(Me) then return end
    if not Me:HasVisibleAura(Spell.DetectInvisibility.Name) and Spell.DetectInvisibility:CastEx(Me) then return end
  end

  -- Make sure we have a target before continuing
  local target = Combat.BestTarget
  if not target then return end

  -- Only do this when pet is active
  if Me.Pet then
    -- Pet Attack my target
    if not Me.Pet.Target or Me.Pet.Target ~= Me.Target then
      Me:PetAttack(target)
    end

    Spell.Torment:CastEx(target)

    if Me.InCombat and #Me:GetUnitsAround(10) > 0 then
      Spell.Sacrifice:CastEx(Me.Pet)
    end
  end

  if GCD:CooldownRemaining() > 0 then return end

  -- CAST PART
  local ua = target:GetAuraByMe(Spell.UnstableAffliction.Name)
  local corruption = target:GetAuraByMe(Spell.Corruption.Name)
  local agony = target:GetAuraByMe(Spell.CurseOfAgony.Name)
  local shouldUA = (wector.Game.Time - UAFix) > 0
  local targetttd = target:TimeToDeath()

  if target.HealthPct <= 25 and targetttd > 4 then
    if not Me.IsChanneling then
      local cast = Me.CurrentCast
      if cast and cast:CastRemaining() > 1000 then
          Me:StopCasting()
      end
    else
      return
    end
    if Spell.DrainSoul:CastEx(target) then return end
    return
  end

  if Me.IsCastingOrChanneling then return end

  if Spell.Haunt:CastEx(target) then return end
  if Me:HasVisibleAura("Shadow Trance") and Spell.ShadowBolt:CastEx(target) then return end

  if targetttd > 10 then
    if target.Health > Settings.UAThreshold and shouldUA and (not ua or ua.Remaining < 1500) and
        Spell.UnstableAffliction:CastEx(target) then return end
    if target.Health > Settings.CorruptionThreshold and (not corruption or corruption.Remaining < 2000) and
        Spell.Corruption:CastEx(target) then return end
    if target.Health > Settings.AgonyThreshold and (not agony or agony.Remaining < 2000) and
        Spell.CurseOfAgony:CastEx(target) then return end
  end

  -- AoE Dot
  for _, unit in pairs(Combat.Targets) do
    local corr = unit:GetAuraByMe(Spell.Corruption.Name)
    local unstab = unit:GetAuraByMe(Spell.UnstableAffliction.Name)
    local uttd = unit:TimeToDeath()

    if uttd > 6 and unit.Health > Settings.CorruptionThreshold and (not corr or corr.Remaining < 2000) and
        Spell.Corruption:CastEx(unit) then return end
    if uttd > 12 and shouldUA and unit.Health > Settings.UAThreshold and (not unstab or unstab.Remaining < 2000) and
        Spell.UnstableAffliction:CastEx(unit) then return end
  end

  if Me.HealthPct < 60 and Spell.DrainLife:CastEx(target) then return end
  if Spell.ShadowBolt:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarlockAfflictionCombat
}

return { Options = options, Behaviors = behaviors }
