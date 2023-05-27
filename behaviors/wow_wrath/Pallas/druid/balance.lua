local function BalanceHeal()

end

local function BalanceCombat()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  -- to many forms!
  local form = Me.ShapeshiftForm
  if form == ShapeshiftForm.Cat or form == ShapeshiftForm.Bear or form == ShapeshiftForm.Aqua or form == ShapeshiftForm.DireBear or form == ShapeshiftForm.EpicFlightForm or form == ShapeshiftForm.Travel then return end

  --if not Me.InCombat then
  --  if not Me:HasVisibleAura("Mark of the Wild") and Spell.MarkOfTheWild:CastEx(Me) then return end
  --  if not Me:HasVisibleAura("Thorns") and Spell.Thorns:CastEx(Me) then return end
  --end

  local target = Combat.BestTarget
  if not target then return end

  if target.CreatureType == CreatureType.Totem and Spell.Moonfire:CastEx(target) then return end

  if target:TimeToDeath() > 5 then
    if Me:IsFacing(target) and not target:HasDebuffByMe("Insect Swarm") and Spell.InsectSwarm:CastEx(target) then return end
    if Me:IsFacing(target) and not target:HasDebuffByMe("Moonfire") and Spell.Moonfire:CastEx(target) then return end
  end

  if Me:IsMoving() or not Me:IsFacing(target) then return end

  if Me:HasVisibleAura("Eclipse (Lunar)") and target:TimeToDeath() > 5 and Spell.Starfire:CastEx(target) then return end
  if Spell.Wrath:CastEx(target) then return end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = BalanceHeal,
    [BehaviorType.Combat] = BalanceCombat
  }
}
