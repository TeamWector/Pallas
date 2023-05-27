local function DruidFeralDamage()
  local target = Combat.BestTarget
  if not target then return end

  if Me:HasVisibleAura("Predatory Swiftness") and Spell.Regrowth:CastEx(Me) then return end

  if Me.ShapeshiftForm == ShapeshiftForm.Normal then
    if Me:InMeleeRange(target) and Me:IsFacing(target) and Spell.CatForm:CastEx(Me) then return end
  end

  if Me.ShapeshiftForm == ShapeshiftForm.Cat and Me:InMeleeRange(target) and Me:IsFacing(target) then
    if not target:HasDebuffByMe("Rake") and Spell.Rake:CastEx(target) then return end
    if not target:HasDebuffByMe("Thrash") and Spell.Thrash:CastEx(target) then return end
    if Me:GetPowerByType(PowerType.ComboPoints) == 5 then
      local rip = target:GetAuraByMe("Rip")
      if not rip and target:TimeToDeath() > 12 and Spell.Rip:CastEx(target) then return end
      if Spell.FerociousBite:CastEx(target) then return end
    end
    if #target:GetUnitsAround(10) > 2 then
      if Spell.Swipe:CastEx(target) then return end
    else
      if Spell.Shred:CastEx(target) then return end
    end
  end
end

return {
    Behaviors = {
        [BehaviorType.Combat] = DruidFeralDamage,
    }
}
