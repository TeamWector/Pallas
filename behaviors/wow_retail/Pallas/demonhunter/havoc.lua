local common = require('behaviors.wow_retail.demonhunter.common')
local colors = require("data.colors")

local options = {
  -- The sub menu name
  Name = "Demonhunter (Havoc)",
  -- widgets  TODO
  Widgets = {
    {
      type = "checkbox",
      uid = "HavocMomentumDrawText",
      text = "Tells you when to use fel rush / vengeful retreat",
      default = true
    }
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local useVengefulRetreat = false
local useFelRush = false

local function TheHunt(target)
  if Spell.TheHunt:CastEx(target) then return true end
end

local function DeathSweep()
  if Spell.EssenceBreak:CooldownRemaining() > 3000 then
    if Spell.DeathSweep:CastEx(Me) then return true end
  end
end

local function EyeBeam(target)
  if Spell.EyeBeam:CastEx(target) then return true end
end

local function VengefulRetreat()
  if Settings.HavocMomentumDrawText and Spell.EssenceBreak:CooldownRemaining() == 0 or Spell.EssenceBreak:CooldownRemaining() > 10000 then
    if Spell.VengefulRetreat:CooldownRemaining() == 0 then
      useVengefulRetreat = true
      return
    end
  end
end

local function EssenceBreak(target)
  if Spell.EssenceBreak:CastEx(target) then return true end
end

local function Metamorphosis(target)
  if (Spell.BladeDance:CooldownRemaining() > 0 or Spell.DeathSweep:CooldownRemaining() > 0) and (Spell.EyeBeam:CooldownRemaining() > 0) then
    if Spell.Metamorphosis:CastEx(target) then return true end
  end
end

local function BladeDance()
  if Spell.EssenceBreak:CooldownRemaining() > 3000 and Spell.EyeBeam:CooldownRemaining() > 3000 and Me.Power > 35 then
    if Spell.BladeDance:CastEx(Me) then return true end
  end
end

local function AnnihilationEssenceBreakDebuff(target)
  if target:HasVisibleAura("Essence Break") then
    if Spell.Annihilation:CastEx(target) then return true end
  end
end

local function ThrowGlaiveOvercap(target)
  if Spell.ThrowGlaive.Charges > 1 then
    if Spell.ThrowGlaive:CastEx(target) then return true end
  end
end

local function FelRushUnboundChaosBuff()
  if Settings.HavocMomentumDrawText and Me:HasVisibleAura("Unbound Chaos") and Spell.FelRush:CooldownRemaining() == 0 then
    useFelRush = true
    return
  end
end

local function AnnihilationRotation(target)
  if Spell.Annihilation:CastEx(target) then return true end
end

local function Felblade(target)
  if Me.Power < 70 and Spell.Felblade:CastEx(target) then return true end
end

local function ChaosStrike(target)
  if Me.Power > 40 and Spell.ChaosStrike:CastEx(target) then return true end
end

local function FelRushMomentum()
  if Settings.HavocMomentumDrawText and (not Me:HasVisibleAura("Momentum")) and Spell.FelRush:CooldownRemaining() == 0 then
    useFelRush = true
    return
  end
end

local function DrawInstruction(instruction)
  local textpos = World2Screen(Vec3(Me.Position.x, Me.Position.y, Me.Position.z + 1))
  DrawText(textpos, colors.pink, instruction)
end

local function DrawTextForHavoc()
  if not (Settings.HavocMomentumDrawText) then return end
  local message = ""
  if useVengefulRetreat then
    message = message .. "  Use VengefulRetreat  "
  end

  if useFelRush then
    message = message .. " Use Fel Rush "
  end

  if useVengefulRetreat and Spell.VengefulRetreat:CooldownRemaining() > 0 then
    useVengefulRetreat = false
  end

  if not Me:HasVisibleAura("Unbound Chaos") and Me:HasVisibleAura("Momentum") then
    useFelRush = false
  end

  DrawInstruction(message)
end



local function DemonhunterHavocCombat()
  DrawTextForHavoc()

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if not target then return end
  if Me.IsCastingOrChanneling then return end

  if TheHunt(target) then return end

  if not Me:InMeleeRange(target) and Me:IsFacing(target) then
    if Spell.ThrowGlaive:CastEx(target) then return end
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

  if common:DoInterrupt() then return end
  if DeathSweep() then return end
  if EyeBeam(target) then return end
  VengefulRetreat()
  if EssenceBreak(target) then return end
  if Metamorphosis(target) then return end
  if BladeDance() then return end
  if AnnihilationEssenceBreakDebuff(target) then return end
  if common:ImmolationAura() then return end
  FelRushUnboundChaosBuff()
  if Combat.EnemiesInMeleeRange > 1 then
    common:UseTrinkets()
  end
  if ThrowGlaiveOvercap(target) then return end
  if AnnihilationRotation(target) then return end
  if common:ThrowGlaive(target) then return end
  if Felblade(target) then return end
  if ChaosStrike(target) then return end
  FelRushMomentum()
  if common:SigilOfFlame(target) then return end
  if common:ArcaneTorrent() then return end
end

local behaviors = {
      [BehaviorType.Combat] = DemonhunterHavocCombat
}

return { Options = options, Behaviors = behaviors }
