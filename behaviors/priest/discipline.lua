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
    },
  }
}

local spells = {
  Renew = WoWSpell("Renew"),
  FlashHeal = WoWSpell("Flash Heal"),
  BindingHeal = WoWSpell("Binding Heal"),
  PrayerOfMending = WoWSpell("Prayer of Mending"),
  PowerWordShield = WoWSpell("Power Word: Shield"),
  GreaterHealRank1 = WoWSpell("Greater Heal(Rank 1)"),
  GreaterHealMax = WoWSpell("Greater Heal"),
  InnerFire = WoWSpell("Inner Fire"),
  Penance = WoWSpell("Penance"),
  PainSuppresion = WoWSpell("Pain Suppression"),

  ShadowWordPain = WoWSpell("Shadow Word: Pain"),
  HolyFire = WoWSpell("Holy Fire"),
  Smite = WoWSpell("Smite")
}

local function PriestDiscHeal()
  if Me.IsCastingOrChanneling then return end
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  if (not Me:HasVisibleAura("Inner Fire")) and spells.InnerFire:CastEx(Me) then return end

  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit

    if Settings.UsePainSuppression and u.HealthPct < 35 and spells.PainSuppresion:CastEx(u) then return end

    if u.HealthPct < 40 and Me:GetHealthPercent() < 50 and spells.BindingHeal:CastEx(u) then return end

    if u.HealthPct < 40 and spells.FlashHeal:CastEx(u) then return end

    if u.HealthPct < 55 and not u:HasVisibleAura("Weakened Soul") and spells.PowerWordShield:CastEx(u) then return end

    if u.HealthPct < 75 and spells.Penance:CastEx(u) then return end

    if u.HealthPct < 80 and spells.GreaterHealRank1:CastEx(u) then return end

    if u.HealthPct < 90 and u.InCombat and spells.PrayerOfMending:CastEx(u) then return end

    if u.HealthPct < 90 and not u:HasVisibleAura("Renew") and spells.Renew:CastEx(u) then return end

  end

end

local function PriestDiscDamage() 
  if Me.IsCastingOrChanneling then return end
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  local target = Combat.BestTarget
  if (not target) or (not target.IsEnemy) or Me.PowerPct < 50 then return end

  local shadowWordPain = target:GetVisibleAura("Shadow Word: Pain")
  if (not shadowWordPain) and spells.ShadowWordPain:CastEx(target) then return end

  local holyFire = target:GetVisibleAura("Holy Fire")
  if (not holyFire) and spells.HolyFire:CastEx(target) then return end

  if spells.Smite:CastEx(target) then return end
end 

local behaviors = {
  [BehaviorType.Heal] = PriestDiscHeal,
  [BehaviorType.Combat] = PriestDiscDamage
}

--return { Options = options, Behaviors = behaviors }
return { Behaviors = behaviors }
