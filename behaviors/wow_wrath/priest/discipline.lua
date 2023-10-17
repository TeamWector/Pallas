local options = {
  -- The sub menu name
  Name = "Priest (Discpiline)",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "UsePainSuppression",
      text = "Use Pain Suppresion",
      default = true
    },
    {
      type = "combobox",
      uid = "CommonDispels",
      text = "Dispel",
      default = 0,
      options = { "Disabled", "Any", "Whitelist" }
    }
  }
}

local function IsCastingHeal()
  return Me.CurrentCast == Spell.FlashHeal or Me.CurrentCast == Spell.GreaterHeal or Me.CurrentCast == Spell.BindingHeal or Me.CurrentCast == Spell.GreaterHeal
end

local function IsCastingDamage()
  return Me.CurrentCast == Spell.Smite or Me.CurrentCast == Spell.HolyFire
end

local function Dispel(priority)
  local spell = Spell.DispelMagic
  if spell:CooldownRemaining() > 0 then return false end
  spell:Dispel(true, priority or 1, WoWDispelType.Magic)
end


local function AbolishDisease(priority)
  local spell = Spell.AbolishDisease
  if spell:CooldownRemaining() > 0 then return false end
  spell:Dispel(true, priority or 1, WoWDispelType.Disease)
end

local function PriestDiscDamage()
  local GCD = wector.SpellBook.GCD
  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end  if not Me.InCombat then return end
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  local target = Me.Target
  if (not target) or (not target.IsEnemy) or (target.HealthPct < 1) or Me.PowerPct < 50 or Me.HealthPct < 75 then return end

  local shadowWordPain = target:GetVisibleAura("Shadow Word: Pain")
  if (not shadowWordPain) and Spell.ShadowWordPain:CastEx(target) then return end

  local holyFire = target:GetVisibleAura("Holy Fire")
  if (not holyFire) and Spell.HolyFire:CastEx(target) then return end

  if Spell.Smite:CastEx(target) then return end
end


local function PriestDiscHeal()
  if Me.IsMounted then return end
  if Me.StandStance == StandStance.Sit then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if (not Me:HasVisibleAura("Inner Fire")) and Spell.InnerFire:CastEx(Me) then return end

  local spelltarget = WoWSpell.Target

  if Me.IsCasting and IsCastingHeal() and spelltarget then
    if spelltarget.HealthPct > 98 then Me:StopCasting() end
  end

  for _, v in pairs(Heal.PriorityList) do
    -- check for low hp peoparu
    local u = v.Unit
    if Me.IsCasting and IsCastingDamage() and Me.CurrentCast:CastRemaining() > 500 and u.HealthPct < 80 then
      Me:StopCasting()
    end
  end

  -- this check lets us out if we've overriden something by pressing buttons.
  if Me.IsCastingOrChanneling then return end


  -- DO ME FIRST

  if Settings.UsePainSuppression and Me.HealthPct < 30 and Me.InCombat and Spell.PainSuppression:CastEx(Me) then return end

  if Me.HealthPct < 75 and not Me:HasAura("Weakened Soul") and Spell.PowerWordShield:CastEx(Me) then return end

  if Me.HealthPct < 50 and Spell.DesperatePrayer:CastEx(Me) then return end

  if Me.HealthPct < 40 and Spell.FlashHeal:CastEx(Me) then return end

  if Me.HealthPct < 90 and Me.InCombat and Spell.PrayerOfMending:CastEx(Me) then return end

  --if Me.HealthPct < 90 and not Me:HasAura("Renew") and Spell.Renew:CastEx(Me) then return end



  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit

    if u.HealthPct < 25 and u.InCombat and Spell.PainSuppresion:CastEx(u) then return end

    if u.HealthPct < 40 and Me.HealthPct < 50 and Spell.BindingHeal:CastEx(u) then return end

    if u.HealthPct < 65 and not u:HasAura("Weakened Soul") and Spell.PowerWordShield:CastEx(u) then return end

    if u.HealthPct < 50 and Spell.FlashHeal:CastEx(u) then return end

    if u.HealthPct < 80 and Spell.Penance:CastEx(u) then return end

    if u.HealthPct < 90 and u.InCombat and Spell.PrayerOfMending:CastEx(u) then return end

    -- renew not important in wotlk disc
    -- if u.HealthPct < 90 and not u:HasAura("Renew") and Spell.Renew:CastEx(u) then return end
  end

  for _, dps in pairs(Heal.Friends.DPS) do
    if dps.HealthPct < 90 and dps.InCombat and Spell.Renew:Apply(dps) then return end
  end

  for _, tank in pairs(Heal.Friends.Tanks) do
    if tank.HealthPct < 80 and Spell.GreaterHeal:CastEx(tank) then return end
  end

  if Dispel() then return end
  if AbolishDisease() then return end

  PriestDiscDamage()
end


local behaviors = {
  [BehaviorType.Heal] = PriestDiscHeal,
  [BehaviorType.Combat] = PriestDiscHeal
}

return { Options = options, Behaviors = behaviors }
