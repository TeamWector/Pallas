local spells = {
  TigersFury = WoWSpell("Tiger's Fury"),
  Rake = WoWSpell("Rake"),
  Rip = WoWSpell("Rip"),
  FerociousBite = WoWSpell("Ferocious Bite"),
  Claw = WoWSpell("Claw"),
  FaerieFireFeral = WoWSpell("Faerie Fire (Feral)"),
  MangleBear = WoWSpell("Mangle (Bear)"),
  MangleCat = WoWSpell("Mangle (Cat)"),

  MarkOfTheWild = WoWSpell("Mark of the Wild"),
  Thorns = WoWSpell("Thorns"),
}

local function DruidFeralHeal()

end

local function DruidFeralCombat()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  if not Me.InCombat then
    -- to many forms!
    local form = Me.ShapeshiftForm
    if form ~= ShapeshiftForm.Cat and form ~= ShapeshiftForm.Bear and form ~= ShapeshiftForm.Aqua and form ~= ShapeshiftForm.DireBear and form ~= ShapeshiftForm.EpicFlightForm and form ~= ShapeshiftForm.Travel then
      if not Me:HasVisibleAura("Mark of the Wild") and  not Me:HasVisibleAura("Gift of the Wild") and spells.MarkOfTheWild:CastEx(Me) then return end
      if not Me:HasVisibleAura("Thorns") and spells.Thorns:CastEx(Me) then return end
    end
  end

  if Me.ShapeshiftForm ~= ShapeshiftForm.Cat then return end

  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end

  --if not Me:HasAura("Tiger's Fury") and spells.TigersFury:CastEx(Me) then return end
  if not target:HasAura("Faerie Fire (Feral)") and spells.FaerieFireFeral:CastEx(target) then return end

  local comboPoints = Me:GetPowerByType(PowerType.Obsolete)
  if comboPoints == 5 then
    if target:TimeToDeath() > 10 and spells.Rip:CastEx(target) then return end
    if target:TimeToDeath() < 10 and spells.FerociousBite:CastEx(target) then return end
  elseif comboPoints > 2 and target:TimeToDeath() < 5 and spells.FerociousBite:CastEx(target) then
    return
  elseif spells.MangleCat.IsKnown then
    if not target:HasAura("Rake") and target.IsPlayer and spells.Rake:CastEx(target) then return end
    if spells.MangleCat:CastEx(target) then return end
  else
    if not target:HasAura("Rake") and spells.Rake:CastEx(target) then return end
    if spells.MangleCat:CastEx(target) then return end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidFeralHeal,
    [BehaviorType.Combat] = DruidFeralCombat
  }
}
