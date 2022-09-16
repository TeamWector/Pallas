local common = require('behaviors.deathknight.common')
local options = {
  Name = "Deathknight (UH)",
  Widgets = {
    {
      type = "checkbox",
      uid = "GargoyleCD",
      text = "Use Gargoyle",
      default = false
    },
    {
      type = "checkbox",
      uid = "Desolation",
      text = "Desolation Talented",
      default = true
    },
    {
      type = "checkbox",
      uid = "GnawSpell",
      text = "Gnaw Interrupt (Pet)",
      default = false
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function PetAttack(target)
  local pet = Me.Pet

  if not pet then return end

  local ghoulfrenzy = pet:GetVisibleAura(Spell.GhoulFrenzy.Name)

  if pet.Target ~= Me.Target then
    Me:PetAttack(target)
  end

  -- If gnaw on cooldown then spam claw, otherwise hold 30 energy for gnaw.
  if not Settings.GnawSpell and Spell.Claw:CastEx(target) or
      Settings.GnawSpell and (Spell.Gnaw:CooldownRemaining() > 2500 or pet.PowerPct >= 70) and
      Spell.Claw:CastEx(target) then return end

  if (not ghoulfrenzy or ghoulfrenzy.Remaining < 5000) and Spell.GhoulFrenzy:CastEx(Me) then return end
end

--Gargoyle logic
local function SummonGargoyle(target)
  if Me.PowerPct >= 60 and Spell.Berserking:CastEx(Me) then Spell.SummonGargoyle:CastEx(target) return end
  return Me.PowerPct >= 60 and Spell.SummonGargoyle:CastEx(target)
end

local GCD = WoWSpell(61304)
local function UnholyDamage(target)
  if not Me:IsAttacking(target) then Me:StartAttack(target) end
  -- Lets not do any spells if we on GCD.
  if GCD:CooldownRemaining() > 0 then return end

  local fever = target:GetAuraByMe(common.auras.frostfever.Name)
  local plague = target:GetAuraByMe(common.auras.bloodplague.Name)
  local desolation = Me:GetVisibleAura(common.auras.desolation.Name)

  if Combat.EnemiesInMeleeRange > 1 then
    common:Pestilence()
    common:DeathAndDecay(target)
    common:BloodBoil()
  end

  -- We swapping presence to maximize gargoyle damage (It's based on haste.)
  if Spell.SummonGargoyle:CooldownRemaining() == 0 and not Me:HasVisibleAura(common.auras.unholypresence.Name) and
      Spell.UnholyPresence:CastEx(Me) then return end
  if Spell.SummonGargoyle:CooldownRemaining() > 5000 and not Me:HasVisibleAura(common.auras.bloodpresence.Name) and
      Spell.BloodPresence:CastEx(Me) then return end

  if Settings.GargoyleCD and Me:HasVisibleAura(common.auras.unholypresence.Name) and SummonGargoyle(target) then return end

  -- Death coil spam if we dont have gargoyle ready.
  if (Me.PowerPct > 70 or Spell.SummonGargoyle:CooldownRemaining() > 4000) and Spell.DeathCoil:CastEx(target) then return end

  if target:TimeToDeath() > 5 and (not fever or fever.Remaining < 3000) then
    if Spell.IcyTouch:CastEx(target) then return end
  end

  if Settings.Desolation and (not desolation or desolation.Remaining < 3000) and Spell.BloodStrike:CastEx(target) then return end

  if target:TimeToDeath() > 5 and (not plague or plague.Remaining < 3000) then
    if Spell.PlagueStrike:CastEx(target) then return end
  end

  if common:DeathStrike(target) then return end
  if common:TargetHasDiseases(target) and desolation and Spell.ScourgeStrike:CastEx(target) then return end
  if target:TimeToDeath() < 5 and Spell.BloodStrike:CastEx(target) then return end
end

local Desolation = WoWSpell(66803)
local function DeathknightUnholy()
  if not Me.InCombat and common:PathOfFrost() then return end
  if Me.IsMounted then return end

  common:Interrupt()
  common:HornOfWinter()

  if not Me.Pet then
    -- Get Glyph of Raise Dead, it's bis :)
    if Spell.RaiseDead:CastEx(Me) then return end
  else
    -- follow on pet if we deselect target and we are out of combat.
    if Me.Pet.Target and not Me.Target and not Me.InCombat then Me:PetFollow() end
  end

  -- Bone shield for that 2% extra overall dmg
  if not Me:HasVisibleAura(Spell.BoneShield.Name) and Spell.BoneShield:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  if Me.Pet then
    PetAttack(target)
  end

  -- This is mostly done to seperate the actual damage rotation from the other stuff.
  UnholyDamage(target)
end

local function Ascii()
  wector.Console:Log("------------------------------------------------")
  wector.Console:Log("UNHOLY DEATHKNIGHT FUCKING LOADED")
  wector.Console:Log("DISABLE AUTOCAST ON ALL PET SPELLS EXCEPT LEAP")
  wector.Console:Log("SET YOUR FUCKING PET TO PASSIVE")
  wector.Console:Log("MAKE SURE TO VERIFY ALL SETTINGS IN THE GUI!")
  wector.Console:Log("------------------------------------------------")
end

Ascii()

local behaviors = {
  [BehaviorType.Combat] = DeathknightUnholy
}

return { Options = options, Behaviors = behaviors }
