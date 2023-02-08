local options = {
  -- The sub menu name
  Name = "Priest (Discpiline)",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "UsePainSuppression",
      text = "Use Pain Suppresion",
      default = false
    }
  }
}

local function IsCastingHeal()
  return Me.CurrentCast == Spell.FlashHeal or Me.CurrentCast == Spell.GreaterHeal or Me.CurrentCast == Spell.BindingHeal
end

local function PriestDiscHeal()
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  if (not Me:HasVisibleAura("Inner Fire")) and Spell.InnerFire:CastEx(Me) then return end

  local spelltarget = WoWSpell:GetCastTarget()

  if Me.IsCasting and IsCastingHeal() and spelltarget then
    if spelltarget.HealthPct > 98 then Me:StopCasting() end
  end


  -- DO ME FIRST

  if Settings.UsePainSuppression and Me.HealthPct < 35 and Spell.PainSuppresion:CastEx(Me) then return end

  if Me.HealthPct < 75 and not Me:HasAura("Weakened Soul") and Spell.PowerWordShield:CastEx(Me) then return end

  if Me.HealthPct < 60 and Spell.FlashHeal:CastEx(Me) then return end

  if Me.HealthPct < 90 and Me.InCombat and Spell.PrayerOfMending:CastEx(Me) then return end

  if Me.HealthPct < 90 and not Me:HasAura("Renew") and Spell.Renew:CastEx(Me) then return end





  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit

    if Settings.UsePainSuppression and u.HealthPct < 25 and Spell.PainSuppresion:CastEx(u) then return end

    if u.HealthPct < 40 and Me:GetHealthPercent() < 50 and Spell.BindingHeal:CastEx(u) then return end

    if u.HealthPct < 55 and not u:HasAura("Weakened Soul") and Spell.PowerWordShield:CastEx(u) then return end

    if u.HealthPct < 40 and Spell.FlashHeal:CastEx(u) then return end

    if u.HealthPct < 75 and Spell.Penance:CastEx(u) then return end

    if u.HealthPct < 80 and Spell.GreaterHeal:CastEx(u) then return end

    if u.HealthPct < 90 and u.InCombat and Spell.PrayerOfMending:CastEx(u) then return end

    if u.HealthPct < 90 and not u:HasAura("Renew") and Spell.Renew:CastEx(u) then return end

  end

end

local function PriestDiscDamage()
  if Me.IsCastingOrChanneling then return end
  if not Me.InCombat then return end
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  local target = Me.Target
  if (not target) or (not target.IsEnemy) or Me.PowerPct < 50 or Me.HealthPct < 85 then return end

  local shadowWordPain = target:GetVisibleAura("Shadow Word: Pain")
  if (not shadowWordPain) and Spell.ShadowWordPain:CastEx(target) then return end

  local holyFire = target:GetVisibleAura("Holy Fire")
  if (not holyFire) and Spell.HolyFire:CastEx(target) then return end

  if Spell.Smite:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestDiscHeal,
  [BehaviorType.Combat] = PriestDiscDamage
}

return { Options = options, Behaviors = behaviors }
