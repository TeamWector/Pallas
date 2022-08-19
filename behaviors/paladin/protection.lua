local spells = {
  SealOfRighteousness = WoWSpell("Seal of Righteousness"),
  SealOfTheCrusader = WoWSpell("Seal of The Crusader"),
  RighteousFury = WoWSpell("Righteous Fury"),

  Consecration = WoWSpell("Consecration"),
  Judgement = WoWSpell("Judgement"),
  HolyShield = WoWSpell("Holy Shield"),
  HammerOfWrath = WoWSpell("Hammer of Wrath"),
  AvengersShield = WoWSpell("Avenger's Shield")
}

local function PaladinProtLeveling()
  if not Me:HasVisibleAura(spells.RighteousFury.Id) and spells.RighteousFury:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  if not target:HasVisibleAura("Judgement of the Crusader") then
    if not Me:HasVisibleAura(spells.SealOfTheCrusader.Id) then
      spells.SealOfTheCrusader:CastEx(Me)
      return
    end

    if not spells.Judgement:CastEx(target) then
      return
    end

    return
  end

  if not Me:HasVisibleAura(spells.SealOfRighteousness.Id) then
    if spells.SealOfRighteousness:CastEx(Me) then return end
  else
    if Me.PowerPct > 40 and spells.Judgement:CastEx(target) then return end
  end

  if not Me:IsMoving() and Me:InMeleeRange(target) and spells.Consecration:CastEx(Me) then
    return
  end
end

return {
  Behaviors = {
    [BehaviorType.Combat] = PaladinProtLeveling
  }
}
