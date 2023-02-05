local options = {
  -- The sub menu name
  Name = "Paladin (Prot)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "UseDivineSacrifice",
      text = "Use Divine Sacrifice",
      default = false
    },
  }
}

PaladinListener = wector.FrameScript:CreateListener()
PaladinListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

local GCDFix = 0
function PaladinListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
  if unitTarget == Me and spellID == Spell.HandOfReckoning.Id then
    GCDFix = wector.Game.Time + 300
  end
end

local function PaladinProtCombat()
  -- Crusader Aura
  if Me.IsMounted and not Me:HasVisibleAura(Spell.CrusaderAura.Name) and Spell.CrusaderAura:CastEx(Me) then return end
  -- Devotion when not mounted ofcourse
  if not Me.IsMounted and not Me:HasVisibleAura(Spell.DevotionAura.Name) and Spell.DevotionAura:CastEx(Me) then return end

  -- Let's not dismount by doing stupid shit...
  if Me.IsMounted then return end

  -- Pre Buffs
  if not Me:HasVisibleAura(Spell.RighteousFury.Name) and Spell.RighteousFury:CastEx(Me) then return end
  if not Me:HasVisibleAura(Spell.BlessingOfSanctuary.Name) and
      not Me:HasVisibleAura(Spell.GreaterBlessingOfSanctuary.Name) and Spell.BlessingOfSanctuary:CastEx(Me) then return end
  if not Me:HasVisibleAura(Spell.SealOfCorruption.Name) and Spell.SealOfCorruption:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  local aoe = #Me:GetUnitsAround(8) > 1
  local escapee = Me:GetUnitNotAttackingMe()

  -- Hand of reckoning on anything that is attacking my group and not me.
  local shouldRighteous = wector.Game.Time - GCDFix > 0
  if escapee and Spell.HandOfReckoning:CastEx(escapee) then return end
  if escapee and shouldRighteous and Spell.RighteousDefense:CastEx(escapee.Target) then return end

  if Me.InCombat then
    -- Lets spread our judgements on multiple targets for max efficiency.
    local judgementee = Me:GetTargetForDebuff(Spell.JudgementOfWisdom)

    if Me:InMeleeRange(target) and not Me:IsAttacking(target) then Me:StartAttack(target) end
    if not Me:HasVisibleAura(Spell.HolyShield.Name) and Me:InMeleeRange(target) and Spell.HolyShield:CastEx(Me) then return end
    if Spell.HammerOfWrath:CastEx(target) then return end
    if Spell.AvengersShield:CastEx(target) then return end
    if not target:HasVisibleAura(Spell.JudgementOfWisdom.Name) and Spell.JudgementOfWisdom:CastEx(target) then return end
    if judgementee and Spell.JudgementOfWisdom:CastEx(judgementee) then return end
    if not Me:IsMoving() and aoe and Spell.Consecration:CastEx(Me) then return end
    if Spell.HammerOfTheRighteous:CastEx(target) then return end
    if Spell.JudgementOfWisdom:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinProtCombat
}

return { Options = options, Behaviors = behaviors }
