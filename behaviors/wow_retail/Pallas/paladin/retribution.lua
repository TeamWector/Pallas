local common = require("behaviors.wow_retail.Pallas.paladin.common")

local options = {
  Name = "Paladin (Retri)",
  Widgets = {
    {
      type = "text",
      uid = "PaladinRetribution",
      text = ">> Retribution <<",
    },
    {
      type = "slider",
      uid = "PaladinRetDsPct",
      text = "Divine Shield (%)",
      default = 15,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetDpPct",
      text = "Divine Protection (%)",
      default = 75,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetFolSelfPct",
      text = "Flash of Light Self (%)",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetSovPct",
      text = "Shield Of Vengenace (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetWogSelfPct",
      text = "Word Of Glory Self (%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "text",
      uid = "PaladinRetributionAssist",
      text = ">> Assist Party <<",
    },
    {
      type = "slider",
      uid = "PaladinRetFolAssistPct",
      text = "Flash of Light Party (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetBosAssistPct",
      text = "Blessing of Sacrifice Party (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetWogAssistPct",
      text = "Word Of Glory Party (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "PaladinRetBopAssistPct",
      text = "Blessing Of Protection Party (%)",
      default = 0,
      min = 0,
      max = 100
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local divine_arbiter = 406975
local function TemplarsVerdict(enemy)
  local spell = Spell.FinalVerdict.IsKnown and Spell.FinalVerdict or Spell.TemplarsVerdict
  local arbiter = Me:GetAura(divine_arbiter)
  local should_use = arbiter and arbiter.Stacks == 25 or Combat:GetEnemiesWithinDistance(8) < 2

  return should_use and common:GetHolyPower() > 4 and spell:CastEx(enemy)
end

local function CrusaderStrike(enemy)
  local spell = Spell.CrusaderStrike
  if spell:CooldownRemaining() > 0 then return false end

  return spell:CastEx(enemy)
end

local judgment = 197277
local function Judgment(enemy, hp)
  local spell = Spell.Judgment
  if spell:CooldownRemaining() > 0 then return false end
  if hp and common:GetHolyPower() > hp then return false end

  if not enemy:HasAura(judgment) then
    return spell:CastEx(enemy)
  else
    for _, target in pairs(Combat.Targets) do
      if Me:IsFacing(target) and not target:HasAura(judgment) then spell:CastEx(target) end
    end
  end

  return spell:CastEx(enemy)
end

local function BladeOfJustice(enemy)
  local spell = Spell.BladeOfJustice
  if spell:CooldownRemaining() > 0 then return false end
  if common:GetHolyPower() > 3 then return false end

  return spell:CastEx(enemy)
end

local function DivineStorm(holypower)
  local spell = Spell.DivineStorm
  if common:GetHolyPower() < holypower then return false end

  return Combat:GetEnemiesWithinDistance(8) > 1 and spell:CastEx(Me)
end

local function Consecration()
  local spell = Spell.Consecration
  if spell:CooldownRemaining() > 0 then return false end

  return not Me:IsMoving() and Combat:GetEnemiesWithinDistance(8) > 0 and spell:CastEx(Me)
end

local function FinalReckoning(enemy)
  local spell = Spell.FinalReckoning
  if spell:CooldownRemaining() > 0 then return false end

  return Combat.Burst and common:GetHolyPower() > 4 and spell:CastEx(enemy)
end

local function WakeOfAshes(enemy)
  local spell = Spell.WakeOfAshes
  if spell:CooldownRemaining() > 0 then return false end

  return Me:GetDistance(enemy) < 14 and common:GetHolyPower() <= 2 and spell:CastEx(Me)
end

local function DivineToll(enemy)
  local spell = Spell.DivineToll
  if spell:CooldownRemaining() > 0 then return false end
  if Me:IsMoving() or not Me:InMeleeRange(enemy) then return false end

  return common:GetHolyPower() < 3 and spell:CastEx(enemy)
end

local function HammerOfWrath(enemy, st)
  local spell = Spell.HammerOfWrath
  if spell:CooldownRemaining() > 0 then return false end
  if st and Combat.Enemies > 1 then return false end

  if spell:CastEx(enemy) then return true end

  for _, target in pairs(Combat.Targets) do
    if target.HealthPct < 20 then return spell:CastEx(target, SpellCastExFlags.NoUsable) end
  end
end

local function WakeOfAshes(enemy)
  local spell = Spell.WakeOfAshes
  if spell:CooldownRemaining() > 0 then return false end

  return Me:GetDistance(enemy) < 14 and common:GetHolyPower() <= 2 and spell:CastEx(Me)
end

local function DivineToll(enemy)
  local spell = Spell.DivineToll
  if spell:CooldownRemaining() > 0 then return false end
  if Me:IsMoving() or not Me:InMeleeRange(enemy) then return false end

  return common:GetHolyPower() < 3 and spell:CastEx(enemy)
end

local function HammerOfWrath(enemy, st)
  local spell = Spell.HammerOfWrath
  if spell:CooldownRemaining() > 0 then return false end
  if st and Combat.Enemies > 1 then return false end

  if spell:CastEx(enemy) then return true end

  for _, target in pairs(Combat.Targets) do
    if Me:IsFacing(target) and target.HealthPct < 20 and spell:CastEx(target, SpellCastExFlags.NoUsable) then return true end
  end
end

local function RetributionAura()
  local spell = Spell.RetributionAura

  return spell:Apply(Me)
end

local function ShieldOfVengeance()
  local spell = Spell.ShieldOfVengeance
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetSovPct and spell:CastEx(Me)
end

local function DivineProtection()
  local spell = Spell.DivineProtection
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetDpPct and spell:CastEx(Me)
end

local function DivineShield()
  local spell = Spell.DivineShield
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetDsPct and spell:CastEx(Me)
end

local function PaladinRetriDefensive()
  if DivineShield() then return true end
  if ShieldOfVengeance() then return true end
  if DivineProtection() then return true end

  if Me.HealthPct < Settings.PaladinRetWogSelfPct then
    if Spell.WordOfGlory:CastEx(Me) then return true end
  end

  if Me.HealthPct < Settings.PaladinRetFolSelfPct then
    if Spell.FlashOfLight:CastEx(Me) then return true end
  end

  local lowest = Heal:GetLowestMember()

  if not lowest then return end

  if lowest.HealthPct < Settings.PaladinRetBopAssistPct then
    if Spell.BlessingOfProtection:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetBosAssistPct then
    if Spell.BlessingOfSacrifice:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetWogAssistPct then
    if Spell.WordOfGlory:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetFolAssistPct then
    if Spell.FlashOfLight:CastEx(lowest) then return true end
  end
end

local function ShieldOfVengeance()
  local spell = Spell.ShieldOfVengeance
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetSovPct and spell:CastEx(Me)
end

local function DivineProtection()
  local spell = Spell.DivineProtection
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetDpPct and spell:CastEx(Me)
end

local function DivineShield()
  local spell = Spell.DivineShield
  if spell:CooldownRemaining() > 0 then return false end

  return Me.HealthPct < Settings.PaladinRetDsPct and spell:CastEx(Me)
end

local function PaladinRetriDefensive()
  if DivineShield() then return true end
  if ShieldOfVengeance() then return true end
  if DivineProtection() then return true end

  if Me.HealthPct < Settings.PaladinRetWogSelfPct then
    if Spell.WordOfGlory:CastEx(Me) then return true end
  end

  if Me.HealthPct < Settings.PaladinRetFolSelfPct then
    if Spell.FlashOfLight:CastEx(Me) then return true end
  end

  local lowest = Heal:GetLowestMember()

  if not lowest or lowest ~= Me then return end

  if lowest.HealthPct < Settings.PaladinRetBopAssistPct then
    if Spell.BlessingOfProtection:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetBosAssistPct then
    if Spell.BlessingOfSacrifice:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetWogAssistPct then
    if Spell.WordOfGlory:CastEx(lowest) then return true end
  end

  if lowest.HealthPct < Settings.PaladinRetFolAssistPct then
    if Spell.FlashOfLight:CastEx(lowest) then return true end
  end
end

local function PaladinRetriCombat()
  if Me:IsStunned() or Me.IsCastingOrChanneling then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if common:CrusaderAura() then return end

  if Me.IsMounted then return end

  if RetributionAura() then return end
  if PaladinRetriDefensive() then return end

  if common:DoInterrupt() then return end

  local target = Combat.BestTarget
  if not target or not Me:IsFacing(target) then return end

  if common:UseTrinkets() then return end

  if common:AvengingWrath() then return end
  if FinalReckoning(target) then return end
  if DivineStorm(5) then return end
  if common:UseTrinkets() then return end

  if common:AvengingWrath() then return end
  if FinalReckoning(target) then return end
  if TemplarsVerdict(target) then return end
  if DivineStorm(5) then return end
  if TemplarsVerdict(target) then return end
  if WakeOfAshes(target) then return end
  if DivineToll(target) then return end
  if HammerOfWrath(target, true) then return end
  if Judgment(target, 3) then return end
  if BladeOfJustice(target) then return end
  if Judgment(target) then return end
  if CrusaderStrike(target) then return end
  if HammerOfWrath(target) then return end
  if Consecration() then return end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinRetriCombat,
  [BehaviorType.Heal] = PaladinRetriCombat
}

return { Options = options, Behaviors = behaviors }
