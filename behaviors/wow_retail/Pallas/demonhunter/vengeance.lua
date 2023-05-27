local common = require('behaviors.wow_retail.demonhunter.common')

local options = {
  -- The sub menu name
  Name = "Demonhunter (Vengeance)",
  -- widgets  TODO
  Widgets = {
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function TheHunt(target)
  local frailtyAura = target:GetAura("Frailty")
  if frailtyAura and frailtyAura.Stacks > 2 and Spell.TheHunt:CastEx(target) then return true end
end

local function SoulCarver(target)
  local frailtyAura = target:GetAura("Frailty")
  if frailtyAura and frailtyAura.Stacks > 3 and Spell.SoulCarver:CastEx(target) then return true end
end

local function FelDevastation(target)
  if Me.Power >= 50 and Spell.FelDevastation:CastEx(target) then return true end
end

local function SoulCleave(target)
  if Me.Power > 70 and Spell.SoulCleave:CastEx(target) then return true end
end

local function DemonSpikes()
  -- todo revisit me charges is nil
  if Me.HealthPct < 55 and Spell.DemonSpikes.Charges > 0 and not Me:GetVisibleAura("Demon Spikes") then
    if Spell.DemonSpikes:CastEx() then return true end
  end
end

local function FieryBrand(target)
  if Me.HealthPct < 40 then
    if Spell.FieryBrand:CastEx(target) then return true end
  end
end

local function SpiritBomb()
  local soulFragmentAura = Me:GetVisibleAura("Soul Fragments")
  if soulFragmentAura and soulFragmentAura.Stacks > 2 and Me.Power >= 40 then
    if Spell.SpiritBomb:CastEx(Me) then return true end
  end
end

-- Also casts Shear if Fracture is not known
local function Fracture(target)
  if Spell.Fracture.IsKnown then
    if Spell.Fracture:CastEx(target) then return true end
  else
    if Spell.Shear:CastEx(target) then return true end
  end
end


local function DemonhunterVengeanceCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if not target then return end
  if Me.IsCastingOrChanneling then return end
  if common:DoInterrupt() then return end


  if DemonSpikes() then return end
  if TheHunt(target) then return end

  if not Me:InMeleeRange(target) and Me:IsFacing(target) then
    if common:ThrowGlaive(target) then return end
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

  if FieryBrand(target) then return end
  -- -- todo optional infernalStrike
  if SpiritBomb() then return end
  if common:ImmolationAura() then return end
  if FelDevastation(target) then return end
  if SoulCarver(target) then return end

  if Combat.EnemiesInMeleeRange > 1 then
    if common:UseTrinkets() then return end
  end

   if SoulCleave(target) then return end
  if common:SigilOfFlame(target) then return end
  if Fracture(target) then return end
  if common:ThrowGlaive(target) then return end
  if common:ArcaneTorrent() then return end
end

local behaviors = {
  [BehaviorType.Combat] = DemonhunterVengeanceCombat
}

return { Options = options, Behaviors = behaviors }
