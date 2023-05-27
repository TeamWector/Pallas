local function DruidInitial()
  local target = Combat.BestTarget
  if not target then return end

  if not Me:IsFacing(target) then return end

  if Me.ShapeshiftForm == ShapeshiftForm.Bear then
    if Spell.Mange:CastEx(target) then return end
  elseif Me.ShapeshiftForm == ShapeshiftForm.Cat then
    if Me:GetPowerByType(PowerType.ComboPoints) > 2 and Spell.FerociousBite:CastEx(target) then return end
    if Spell.Shred:CastEx(target) then return end
  elseif Me.ShapeshiftForm == ShapeshiftForm.Normal then
    if not target:HasDebuffByMe("Moonfire") and Spell.Moonfire:CastEx(target) then return end
    if Spell.Wrath:CastEx(target) then return end
  end

  if not Me:HasVisibleAura("Mark of the Wild") and Spell.MarkOfTheWild:CastEx(Me) then return end
end

local function DruidInitialHeal()
  if Me.HealthPct < 60 and Spell.Regrowth:CastEx(Me) then return end
end

return {
  Behaviors = {
    [BehaviorType.Combat] = DruidInitial,
    [BehaviorType.Heal] = DruidInitialHeal,
  }
}
