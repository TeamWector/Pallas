local spells = {
  TigersFury = WoWSpell("Tiger's Fury"),
  Rake = WoWSpell("Rake"),
  Rip = WoWSpell("Rip"),
  FerociousBite = WoWSpell("Ferocious Bite"),
  Claw = WoWSpell("Claw"),
  FaerieFireFeral = WoWSpell("Faerie Fire (Feral)"),

  MarkOfTheWild = WoWSpell("Mark of the Wild"),
  Thorns = WoWSpell("Thorns"),
}

local function DruidFeralHeal()

end

local function DruidFeralCombat()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  if not Me.InCombat then
    if not Me:HasVisibleAura("Mark of the Wild") and spells.MarkOfTheWild:CastEx(Me) then return end
    if not Me:HasVisibleAura("Thorns") and spells.Thorns:CastEx(Me) then return end
  end

  if Me.ShapeshiftForm ~= ShapeshiftForm.Cat then return end

  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end

  if not Me:HasAura("Tiger's Fury") and spells.TigersFury:CastEx(Me) then return end
  if not target:HasAura("Faerie Fire (Feral)") and spells.FaerieFireFeral:CastEx(target) then return end

  local comboPoints = Me:GetPowerByType(PowerType.Obsolete)
  if comboPoints == 5 then
    if target:TimeToDeath() > 10 and spells.Rip:CastEx(target) then return end
    if target:TimeToDeath() < 10 and spells.FerociousBite:CastEx(target) then return end
  elseif comboPoints > 2 and target:TimeToDeath() < 5 and spells.FerociousBite:CastEx(target) then
    return
  else
    if not target:HasAura("Rake") and spells.Rake:CastEx(target) then return end
    if spells.Claw:CastEx(target) then return end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidFeralHeal,
    [BehaviorType.Combat] = DruidFeralCombat
  }
}
