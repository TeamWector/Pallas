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

  if not Settings.GnawSpell then
    Spell.Claw:CastEx(target)
  elseif Settings.GnawSpell and (Spell.Gnaw:CooldownRemaining() > 2500 or pet.PowerPct >= 70) then
    Spell.Claw:CastEx(target)
  end

  if (not ghoulfrenzy or ghoulfrenzy.Remaining < 5000) and Spell.GhoulFrenzy:CastEx(Me) then return end
end

--Gargoyle logic
local function SummonGargoyle(target)
  if Me.Power >= 60 and Spell.Berserking:CastEx(Me) then Spell.SummonGargoyle:CastEx(target) return end
  return Me.Power >= 60 and Spell.SummonGargoyle:CastEx(target)
end

local function UnholyMulti(target)
  -- Force multi target waiting for runes if we are fighting more than 3 units.
  if Combat.EnemiesInMeleeRange > 3 then
    -- Force pestilence because Wandering Plague talent is imba.
    if common:Pestilence() then return true end
    if common:DeathAndDecay() then return end
    if common:BloodBoil() then return end
    return true
  end

  if common:Pestilence() then return end
  if common:DeathAndDecay() then return end
  if common:BloodBoil() then return end
end

local GCD = WoWSpell(61304)
local function UnholyDamage(target)
  if not Me:IsAttacking(target) then Me:StartAttack(target) end
  -- Lets not do any spells if we on GCD.
  if GCD:CooldownRemaining() > 0 then return end

  local fever = target:GetAuraByMe(common.auras.frostfever.Name)
  local plague = target:GetAuraByMe(common.auras.bloodplague.Name)
  local desolation = Me:GetVisibleAura(common.auras.desolation.Name)
  local diseaseTarget = common:GetDiseaseTarget()

  -- Death pact if we have pet up and hp lower than settings hp
  if common:DeathPact() then return end
  -- Death strike will only happen if target has both diseases.
  if common:DeathStrike(target) then return end

  -- Death coil spam if we dont have gargoyle ready or mind freeze is on cooldown for more than 5 sec.
  if (Me.Power > 65 or (Spell.SummonGargoyle:CooldownRemaining() > 4000 or Spell.MindFreeze:CooldownRemaining() > 5000)) and Spell.DeathCoil:CastEx(target) then return end

  if Combat.EnemiesInMeleeRange > 1 then
    -- if this returns true, we are forcing the multi target routine.
    if UnholyMulti(target) then return end
  end

  -- We swapping presence to maximize gargoyle damage (It's based on haste.)
  if Spell.SummonGargoyle:CooldownRemaining() == 0 and not Me:HasVisibleAura(common.auras.unholypresence.Name) and
      Spell.UnholyPresence:CastEx(Me) then return end
  if Spell.SummonGargoyle:CooldownRemaining() > 5000 and not Me:HasVisibleAura(common.auras.bloodpresence.Name) and
      Spell.BloodPresence:CastEx(Me) then return end

  if Settings.GargoyleCD and Me:HasVisibleAura(common.auras.unholypresence.Name) and SummonGargoyle(target) then return end

  if (not diseaseTarget or diseaseTarget == target) and target:TimeToDeath() > 5 and
      (not fever or fever.Remaining < 3000) then
    if Spell.IcyTouch:CastEx(target) then return end
  end

  if Settings.Desolation and (not desolation or desolation.Remaining < 3000) and Spell.BloodStrike:CastEx(target) then return end

  if (not diseaseTarget or diseaseTarget == target) and target:TimeToDeath() > 5 and
      (not plague or plague.Remaining < 3000) then
    if Spell.PlagueStrike:CastEx(target) then return end
  end

  -- Let's make sure we have all prereqs for max damage before using ScourgeStrike
  if common:TargetHasDiseases(target) and desolation and Spell.ScourgeStrike:CastEx(target) then return end

  -- Slap target with bloodstrike if he's soon dead or we are capped on blood runes. Mostly to trigger desolation but also works as a good finisher.
  if (target:TimeToDeath() < 5 or common:GetRuneCount(RuneType.Blood) == 2) and Spell.BloodStrike:CastEx(target) then return end
end

local function DeathknightUnholy()
  if Me.IsCastingOrChanneling then return end
  if not Me.InCombat and common:PathOfFrost() then return end
  if Me.IsMounted then return end

  common:Interrupt()
  if not Me.InCombat and common:HornOfWinter() then return end

  if not Me.Pet then
    -- Get Glyph of Raise Dead, it's bis :)
    if Spell.RaiseDead:CastEx(Me) then return end
  else
    -- follow on pet if we deselect target and we are out of combat.
    if Me.Pet.Target and (not Me.Target or Me.Target ~= Me.Pet.Target) and not Me.InCombat then Me:PetFollow() end
  end

  -- Bone shield for that 2% extra overall dmg
  if not Me:HasVisibleAura(Spell.BoneShield.Name) and Spell.BoneShield:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  if common:BloodTap() then return end

  if Me.Pet then
    PetAttack(target)
  end

  -- This is mostly done to seperate the actual damage rotation from the other stuff.
  UnholyDamage(target)
end

local function Ascii()
  wector.Console:Log("------------------------------------------------")
  wector.Console:Log("UNHOLY DEATHKNIGHT FUCKING LOADED")
  wector.Console:Log("GET:GLYPH OF DISEASE AND MINOR GLYPH OF RAISE DEAD")
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
