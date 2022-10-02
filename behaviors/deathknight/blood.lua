local common = require('behaviors.deathknight.common')

local options = {
  -- The sub menu name
  Name = "Deathknight (Blood)",
  -- widgets
  Widgets = {

  }
}

local spells = {
  BloodStrike = WoWSpell("Blood Strike"),
  IcyTouch = WoWSpell("Icy Touch"),
  PlagueStrike = WoWSpell("Plague Strike"),
  DeathCoil = WoWSpell("Death Coil"),
}

local RuneTypes = {
  Blood = 0,
  Unholy = 1,
  Frost = 2
}

local function BloodMulti(target)
  if common:DeathAndDecay() then return end
  if common:Pestilence() then return end
  if common:BloodBoil() then return end
end

local GCD = WoWSpell(61304)

local function BloodDamage(target)
  if not Me:IsAttacking(target) then Me:StartAttack(target) end
  -- Lets not do any spells if we on GCD.
  if GCD:CooldownRemaining() > 0 then return end
  -- Let's pop trinkets before spells :)
  common:DoTrinkets(target)

  local fever = target:GetAuraByMe(common.auras.frostfever.Name)
  local plague = target:GetAuraByMe(common.auras.bloodplague.Name)
  local diseaseTarget = common:GetDiseaseTarget()

  if (not Me:HasVisibleAura(common.auras.frostpresence.Name)) and Spell.FrostPresence:CastEx(Me) then return end

  -- Death pact if we have pet up and hp lower than settings hp
  if common:DeathPact() then return end
  -- Death strike will only happen if target has both diseases.
  if common:DeathStrike(target) then return end

  if Combat:GetEnemiesWithinDistance(10) > 1 then
    -- if this returns true, we are forcing the multi target routine.
    if BloodMulti(target) then return end
  end

  -- Maybe use pestilence to refresh diseases?
  if common:PestilenceRefresh(target) then return end

  if (not diseaseTarget or diseaseTarget == target) and target:TimeToDeath() > 5 and
      (not fever or fever.Remaining < 3000) then
    if Spell.IcyTouch:CastEx(target) then return end
  end

  if (not diseaseTarget or diseaseTarget == target) and target:TimeToDeath() > 5 and
      (not plague or plague.Remaining < 3000) then
    if Spell.PlagueStrike:CastEx(target) then return end
  end

  if ((Me.Power > 80 or Spell.MindFreeze:CooldownRemaining() > 5000)) and Spell.DeathCoil:CastEx(target) then return end

  -- Slap target with bloodstrike if he's soon dead or we are capped on blood runes. Mostly to trigger desolation but also works as a good finisher.
  if (target:TimeToDeath() < 5 or common:GetRuneCount(RuneType.Blood) == 2) and Spell.BloodStrike:CastEx(target) then return end

end

local function DeathknightBlood()
  if Me.IsCastingOrChanneling then return end
  if not Me.InCombat and common:PathOfFrost() then return end
  if Me.IsMounted then return end

  common:Interrupt()
  if common:HornOfWinter() then return end

  -- Bone shield for that 2% extra overall dmg

  local target = Combat.BestTarget
  if not target then return end

  if common:BloodTap() then return end

  if common:RuneTap() then return end

  -- This is mostly done to seperate the actual damage rotation from the other stuff.
  BloodDamage(target)
end

local function Ascii()
  wector.Console:Log("------------------------------------------------")
  wector.Console:Log("BLOOD DEATHKNIGHT FUCKING LOADED")
  wector.Console:Log("MAKE SURE TO VERIFY ALL SETTINGS IN THE GUI!")
  wector.Console:Log("------------------------------------------------")
end

Ascii()


local behaviors = {
  [BehaviorType.Combat] = DeathknightBlood
}

return { Behaviors = behaviors }
