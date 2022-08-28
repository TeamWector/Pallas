local spells = {
  Starfire = WoWSpell("Starfire"),
  Wrath = WoWSpell("Wrath"),
  InsectSwarm = WoWSpell("Insect Swarm"),
  Moonfire = WoWSpell("Moonfire"),

  MarkOfTheWild = WoWSpell("Mark of the Wild"),
  Thorns = WoWSpell("Thorns"),
}

local function BalanceHeal()

end

local function BalanceCombat()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  -- to many forms!
  local form = Me.ShapeshiftForm
  if form == ShapeshiftForm.Cat or form == ShapeshiftForm.Bear or form == ShapeshiftForm.Aqua or form == ShapeshiftForm.DireBear or form == ShapeshiftForm.EpicFlightForm or form == ShapeshiftForm.Travel then return end

  if not Me.InCombat then
    if not Me:HasVisibleAura("Mark of the Wild") and spells.MarkOfTheWild:CastEx(Me) then return end
    if not Me:HasVisibleAura("Thorns") and spells.Thorns:CastEx(Me) then return end
  end

  local target = Combat.BestTarget
  if not target then return end

  if target:TimeToDeath() > 5 then
    if Me:IsFacing(target) and not target:HasVisibleAura("Insect Swarm") and spells.InsectSwarm:CastEx(target) then return end
    if Me:IsFacing(target) and not target:HasVisibleAura("Moonfire") and spells.Moonfire:CastEx(target) then return end
  end

  if Me:IsMoving() then return end
  if Me:IsFacing(target) and spells.Starfire:CastEx(target) then return end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = BalanceHeal,
    [BehaviorType.Combat] = BalanceCombat
  }
}
