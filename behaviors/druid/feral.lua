local function DruidFeralHeal()

end

local function DruidFeralCombat()
  if Me.IsMounted then return end
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  if not Me.InCombat then
    -- to many forms!
    local form = Me.ShapeshiftForm
    if (Me.MovementFlags & MovementFlags.Flying == 0) and form ~= ShapeshiftForm.Cat and form ~= ShapeshiftForm.Bear and form ~= ShapeshiftForm.Aqua and form ~= ShapeshiftForm.DireBear and form ~= ShapeshiftForm.EpicFlightForm and form ~= ShapeshiftForm.Travel then
      if not Me:HasVisibleAura("Mark of the Wild") and  not Me:HasVisibleAura("Gift of the Wild") and Spell.MarkOfTheWild:CastEx(Me) then return end
      if not Me:HasVisibleAura("Thorns") and Spell.Thorns:CastEx(Me) then return end
    end
  end

  if Me.ShapeshiftForm ~= ShapeshiftForm.Cat then return end

  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end

  if not Me:HasAura("Tiger's Fury") and target:TimeToDeath() > 6 and Spell.TigersFury:CastEx(Me) then return end
  if not target:HasAura("Faerie Fire (Feral)") and Spell.FaerieFireFeral:CastEx(target) then return end

  local comboPoints = Me:GetPowerByType(PowerType.Obsolete)
  if comboPoints == 5 then
    if target:TimeToDeath() > 10 and Spell.Rip:CastEx(target) then return end
    if target:TimeToDeath() < 10 and Spell.FerociousBite:CastEx(target) then return end
  elseif comboPoints > 2 and target:TimeToDeath() < 5 and Spell.FerociousBite:CastEx(target) then
    return
  elseif Spell.MangleCat.IsKnown then
    if not target:HasAura("Rake") and target.IsPlayer and Spell.Rake:CastEx(target) then return end
    if Spell.MangleCat:CastEx(target) then return end
  else
    if not target:HasAura("Rake") and Spell.Rake:CastEx(target) then return end
    if Spell.Claw:CastEx(target) then return end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidFeralHeal,
    [BehaviorType.Combat] = DruidFeralCombat
  }
}
