local common = require('behaviors.wow_retail.demonhunter.common')

local options = {
    -- The sub menu name
    Name = "Demonhunter (Havoc)",
    -- widgets  TODO
    Widgets = {
    }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function TheHunt(target)
  if Spell.TheHunt:CastEx(target) then return end
end

local function DeathSweep()
  if Spell.EssenceBreak:CooldownRemaining() > 3000 then
    if Spell.DeathSweep:CastEx(Me) then return end
  end
end

local function EyeBeam(target)
  if Spell.EyeBeam:CastEx(target) then return end
end

local function VengefulRetreat()
  if Spell.EssenceBreak:CooldownRemaining() == 0 or Spell.EssenceBreak:CooldownRemaining() > 10000 then
    if Spell.VengefulRetreat:CastEx(Me) then return end
  end
end

local function EssenceBreak(target)
  if Spell.EssenceBreak:CastEx(target) then return end
end

local function Metamorphosis(target)
  if (Spell.BladeDance:CooldownRemaining() > 0 or Spell.DeathSweep:CooldownRemaining() > 0) and (Spell.EyeBeam:CooldownRemaining() > 0) then
    if Spell.Metamorphosis:CastEx(target) then return end
  end
end

local function BladeDance()
  if Spell.EssenceBreak:CooldownRemaining() > 3000 and Spell.EyeBeam:CooldownRemaining() > 3000 and Me.Power > 35 then
    if Spell.BladeDance:CastEx(Me) then return end
  end
end

local function AnnihilationEssenceBreakDebuff(target)
  if target:HasVisibleAura("Essence Break") then
    if Spell.Annihilation:CastEx(target) then return end
  end
end

local function ThrowGlaiveOvercap(target)
  if Spell.ThrowGlaive.Charges > 1 then
    if Spell.ThrowGlaive:CastEx(target) then return end
  end
end

local function FelRushUnboundChaosBuff()
  if Me:HasAura("Unbound Chaos") then
    if Spell.FelRush:CastEx() then return end
  end
end

local function AnnihilationRotation(target)
  if Spell.Annihilation:CastEx(target) then return end
end

local function Felblade(target)
    if Me.Power < 70 and Spell.Felblade:CastEx(target) then return end
  end

local function ChaosStrike(target)
  if Me.Power > 50 and Spell.ChaosStrike:CastEx(target) then return end
end

local function FelRushMomentum()
  if not Me:HasVisibleAura("Momentum") then
    if Spell.FelRush:CastEx() then return end
  end
end

local function DemonhunterHavocCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if not target then return end
  if Me.IsCastingOrChanneling then return end
  TheHunt(target)

  if not Me:InMeleeRange(target) and Me:IsFacing(target) then
    if Spell.ThrowGlaive:CastEx(target) then return end
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

  common:DoInterrupt()
  DeathSweep()
  EyeBeam(target)
  -- TODO vengefulRetreat logic, function exists, but do you really want to move? PERHAPS A MESSAGE ON SCREEN
  EssenceBreak(target)
  Metamorphosis(target)
  BladeDance()
  AnnihilationEssenceBreakDebuff(target)
  common:ImmolationAura()
  if Combat.EnemiesInMeleeRange > 1 then
    common:UseTrinkets()
  end
  ThrowGlaiveOvercap(target)
  -- TODO FelRushUnboundChaosBuff function exists, PERHAPS A MESSAGE ON SCREEN
  AnnihilationRotation(target)
  common:ThrowGlaive(target)
  Felblade(target)
  ChaosStrike(target)
  common:SigilOfFlame(target)
  common:ArcaneTorrent()
end

local behaviors = {
    [BehaviorType.Combat] = DemonhunterHavocCombat
}

return { Options = options, Behaviors = behaviors }
