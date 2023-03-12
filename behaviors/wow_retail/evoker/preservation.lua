local common = require("behaviors.wow_retail.evoker.common")

local options = {
  Name = "Evoker (Preserve)",
  Widgets = {
    {
      type = "text",
      uid = "EvokerPreservationST",
      text = ">> SINGLE TARGET HEALS <<",
    },
    {
      type = "slider",
      uid = "PresLivingFlamePct",
      text = "Living Flame (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PresReversionPct",
      text = "Reversion (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PresVerdantEmbracePct",
      text = "Verdant Embrace (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PresEchoPct",
      text = "Echo (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PresTimeDilationPct",
      text = "Time Dilation (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PresSpiritbloomPct",
      text = "Spiritbloom (%)",
      default = 0,
      min = 0,
      max = 100
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local auras = {
  essenceburst = 369299
}

local function Dispel()
  local naturalize = Spell.Naturalize
  local cauterize = Spell.CauterizingFlame
  if naturalize:CooldownRemaining() > 0 and cauterize:CooldownRemaining() > 0 then return false end

  local types = WoWDispelType
  if naturalize:Dispel(types.Magic, types.Poison) then return true end
  if cauterize:Dispel(types.Bleed, types.Curse, types.Disease) then return true end
end

local function Disintegrate(enemy)
  local spell = Spell.Disintegrate
  local burst = Me:GetAura(auras.essenceburst)

  return burst and burst.Stacks == 2 and spell:CastEx(enemy)
end

local function FireBreath(enemy)
  local spell = Spell.FireBreath
  local spelldata = WoWSpell(Spell.FireBreath.OverrideId)
  if spelldata:CooldownRemaining() > 0 or not Combat:AllTargetsGathered(10) or Me:GetDistance(enemy) > 25 then return false end

  if spell:IsUsable() then
    Spell.TipTheScales:CastEx(Me)
  end

  if not Me:IsFacing(enemy, 30) then return false end

  return spell:CastEx(Me)
end

local function VerdantEmbrace(friend)
  local spell = Spell.VerdantEmbrace
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.PresVerdantEmbracePct and spell:CastEx(friend)
end

local function Echo(friend)
  local spell = Spell.Echo
  if not spell:IsUsable() then return false end

  local burst = Me:GetAura(auras.essenceburst)

  return (friend.HealthPct < Settings.PresEchoPct or burst and burst.Remaining < 3000) and spell:Apply(friend)
end

local function TimeDilation(friend)
  local spell = Spell.TimeDilation
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.PresTimeDilationPct and spell:CastEx(friend)
end

local function Spiritbloom(friend)
  local spell = Spell.Spiritbloom
  if spell:CooldownRemaining() > 0 then return false end

  if friend then
    if friend.HealthPct < Settings.PresSpiritbloomPct and spell:CastEx(friend) then
      common:EmpowerTo(1)
    end
  end
end

local function Reversion(friend)
  local spell = Spell.Reversion
  local charges = spell.Charges
  if charges == 0 then return false end

  local tanks = WoWGroup:GetTankUnits()

  for _, tank in pairs(tanks) do
    if spell:Apply(tank) then return true end
  end

  return friend and charges == 2 and spell:Apply(friend)
end

local function TemporalAnomaly()
  local spell = Spell.TemporalAnomaly
  if spell:CooldownRemaining() > 0 then return false end

  local hits = 0
  local friends = WoWGroup:GetGroupUnits()
  for _, friend in pairs(friends) do
    if Me:IsFacing(friend, 30) then
      hits = hits + 1
    end
  end

  return hits > 1 and spell:CastEx(Me)
end

local function PreservationDamage()
  local target = Combat.BestTarget
  if not target then return false end

  if not Me:IsFacing(target) then return false end

  if FireBreath(target) then
    common:EmpowerTo(4)
    return true
  end

  if Disintegrate(target) then return true end
  if Me:IsMoving() and Spell.AzureStrike:CastEx(target) then return true end
  if Spell.LivingFlame:CastEx(target) then return true end
end

local function LivingFlame(friend)
  local spell = Spell.LivingFlame

  return friend.HealthPct < Settings.PresLivingFlamePct and spell:CastEx(friend)
end

local function EvokerPreservation()
  common:EmpowerHandler()

  if Me:IsSitting() or Me:IsStunned() or Me.IsCastingOrChanneling then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if Echo(f) then return end
    if VerdantEmbrace(f) then return end
    if TimeDilation(f) then return end
    if Spiritbloom(f) then return end
    if Reversion(f) then return end
    if LivingFlame(f) then return end
  end

  if Dispel() then return end
  if TemporalAnomaly() then return end
  if Reversion() then return end
  if PreservationDamage() then return end
end

local behaviors = {
  [BehaviorType.Heal] = EvokerPreservation,
  [BehaviorType.Combat] = EvokerPreservation
}

return { Options = options, Behaviors = behaviors }
