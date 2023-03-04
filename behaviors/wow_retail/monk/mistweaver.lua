local common = require('behaviors.wow_retail.monk.common')

local options = {
  -- The sub menu name
  Name = "Monk (Mistweaver)",
  -- widgets
  Widgets = {
    {
      type = "text",
      uid = "MonkMistweaverText",
      text = "----------------MISTWEAVER-ST--------------",
    },
    {
      type = "slider",
      uid = "VivifyPct",
      text = "Vivify (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "EnvelopPct",
      text = "Enveloping Mist (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "SoothingPct",
      text = "Soothing Mist (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "RenewingPct",
      text = "Renewing Mist (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "CocoonPct",
      text = "Life Cocoon (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingElixirPct",
      text = "Healing Elixir (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ZenPulsePct",
      text = "Zen Pulse (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "TeachingsPct",
      text = "Teachings Mana (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "ZenReverb",
      text = "Zen Pulse Reverb",
      default = false
    },
    {
      type = "checkbox",
      uid = "RMSpread",
      text = "Spread Renewing Mist on CD",
      default = false
    },
    {
      type = "text",
      uid = "MonkMistweaverAoEText",
      text = "----------------MISTWEAVER-AOE-------------",
    },
    {
      type = "slider",
      uid = "EssenceFontPct",
      text = "Essence Font (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "EssenceFontCount",
      text = "Esssence Font Count",
      default = 1,
      min = 1,
      max = 5
    },
    {
      type = "slider",
      uid = "ChijiPct",
      text = "Chiji (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ChijiCount",
      text = "Chiji Count",
      default = 1,
      min = 1,
      max = 5
    },
    {
      type = "slider",
      uid = "RevivalPct",
      text = "Revival (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "RevivalCount",
      text = "Revival Count",
      default = 1,
      min = 1,
      max = 5
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local auras = {
  renewingmist = 119611,
  envelopingmist = 124682,
  soothingmist = 115175,
  teachingsofthemonastery = 202090,
  essencefont = 191840,
  faeline = 388193,
  improvedDetox = 388874,
  ancientteachings = 388026,
  ancientconcordance = 389391,
  invokechiji = 343820
}

local function IsCastingOrChanneling()
  return Me.CurrentSpell and Me.CurrentSpell.Id ~= Spell.SoothingMist.Id
      and Me.CurrentSpell.Id ~= Spell.CracklingJadeLightning.Id
      and Me.CurrentSpell.Id ~= Spell.SpinningCraneKick.Id
end

local function RenewingMist()
  if Spell.RenewingMist.Charges == 0 or not Settings.RMSpread then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, f in pairs(friends) do
    if Spell.RenewingMist:Apply(f) then return true end
  end
end

local function EnvelopingMist(friend)
  local chiji = Me:GetAura(auras.invokechiji)

  if chiji and chiji.Stacks == 3 then
    for _, v in pairs(Heal.Tanks) do
      local f = v.Unit
      if Spell.EnvelopingMist:Apply(f) then return true end
    end

    for _, v in pairs(Heal.PriorityList) do
      local f = v.Unit
      if Spell.EnvelopingMist:Apply(f) then return true end
    end
  end

  if friend.HealthPct < Settings.EnvelopPct then
    return Spell.EnvelopingMist:Apply(friend)
  end
end

local function SoothingMist(friend)
  if friend.HealthPct < Settings.SoothingPct then
    return Spell.SoothingMist:Apply(friend)
  end
end

-- todo add logic for damage prevention
local function LifeCocoon(friend)
  if Spell.LifeCocoon:CooldownRemaining() > 0 then return end

  if friend.HealthPct < Settings.CocoonPct then
    return #friend:GetUnitsAround(8) > 0 and Spell.LifeCocoon:CastEx(friend)
  end
end

local function Vivify(friend)
  if friend.HealthPct < Settings.VivifyPct then
    return Spell.Vivify:CastEx(friend)
  end
end

local function ZenPulse(friend)
  if Spell.ZenPulse:CooldownRemaining() > 0 then return end

  if friend.HealthPct < Settings.ZenPulsePct then
    if not Settings.ZenReverb or friend:GetAuraByMe(auras.envelopingmist) and friend:GetAuraByMe(auras.renewingmist) then
      return #friend:GetUnitsAround(8) > 0 and Spell.ZenPulse:CastEx(friend)
    end
  end
end

local function EssenceFont()
  if Spell.EssenceFont:CooldownRemaining() > 0 then return end

  local below, count = Heal:GetMembersBelow(Settings.EssenceFontPct)
  return count >= Settings.EssenceFontCount and Me:IsMoving() and Spell.EssenceFont:CastEx(Me)
end

local function SpinningCraneKick()
  local enemyCount = Combat:GetEnemiesWithinDistance(8)

  if (enemyCount < 5 and Me:GetAura(auras.ancientconcordance) or enemyCount < 3) or Spell.RisingSunKick:CooldownRemaining() == 0 then return false end
  return not Me.IsCastingOrChanneling and Spell.SpinningCraneKick:CastEx(Me)
end

local function RisingSunKick(enemy)
  local spell = Spell.RisingSunKick

  if spell:CooldownRemaining() == 0 and spell:InRange(enemy) then
    Spell.ThunderFocusTea:CastEx(Me)
  end

  return spell:CastEx(enemy)
end

local function BlackoutKick(enemy)
  local teachings = Me:GetAura(auras.teachingsofthemonastery)
  return (Spell.RisingSunKick:CooldownRemaining() > 2000 and (Me.PowerPct > Settings.TeachingsPct or teachings and teachings.Stacks == 3)) and
      Spell.BlackoutKick:CastEx(enemy)
end

local function TigerPalm(enemy)
  return Spell.TigerPalm:CastEx(enemy)
end

local function ChiBurst(enemy)
  return Spell.ChiBurst:CastEx(enemy)
end

local function ChiWave(enemy)
  return Spell.ChiWave:CastEx(enemy)
end

local function CracklingJadeLightning(enemy)
  return Me:GetDistance(enemy) > 15 and Spell.CracklingJadeLightning:Apply(enemy)
end

local function FaelineStomp(enemy)
  if Spell.FaelineStomp:CooldownRemaining() > 0 then return end
  if Me:GetAura(auras.ancientconcordance) and Me:GetAura(auras.ancientteachings) then return end

  if Me.InCombat and not Me:IsMoving() and Me:InMeleeRange(enemy) and Spell.FaelineStomp:CastEx(Me) then
    return true
  end
end

local function HealingElixir()
  return Me.HealthPct < Settings.HealingElixirPct and Spell.HealingElixir:CastEx(Me)
end

local function ChijiRedCrane()
  local spell = Spell.InvokeChijiTheRedCrane
  if spell:CooldownRemaining() > 0 then return end

  local below, count = Heal:GetMembersBelow(Settings.ChijiPct)

  return count >= Settings.ChijiCount and spell:CastEx(Me)
end

local function Revival()
  local spell = Spell.Revival
  if spell:CooldownRemaining() > 0 then return end

  local below, count = Heal:GetMembersBelow(Settings.RevivalPct)

  return count >= Settings.RevivalCount and spell:CastEx(Me)
end

local function Dispel()
  local DispelType = WoWDispelType

  if Me:GetAura(auras.improvedDetox) then
    if Spell.Detox:Dispel(true, DispelType.Magic, DispelType.Disease, WoWDispelType.Poison or 4) then return true end
    return
  end

  if Spell.Detox:Dispel(true, DispelType.Magic) then return true end
end

local function ManaTea()
  local below, count = Heal:GetMembersBelow(80)
  if count > 2 and Spell.ManaTea:CastEx(Me) then return true end
end

local function MonkMistweaverDamage()
  if Me:IsSitting() or Me.IsMounted then return end

  local target = Combat.BestTarget
  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 or (not target or not Me:IsFacing(target)) then return end

  if IsCastingOrChanneling() or not Me:IsFacing(target) then return end

  local lowest = Heal:GetLowestMember()
  if lowest and lowest.HealthPct < Settings.VivifyPct and Spell.Vivify:IsUsable() then return end

  if Dispel() then return end
  if common:LegSweep() then return end
  if common:TouchOfDeath(target) then return end
  if FaelineStomp(target) then return end
  if ChiBurst(target) then return end
  if ChiWave(target) then return end
  if SpinningCraneKick() then return end
  if RisingSunKick(target) then return end
  if BlackoutKick(target) then return end
  if TigerPalm(target) then return end
  if CracklingJadeLightning(target) then return end
end

local function MonkMistweaver()
  if Me:IsSitting() or Me.IsMounted then return end

  if Spell.SpearHandStrike:Interrupt() then return end

  if IsCastingOrChanneling() then return end

  if ManaTea() then return end
  if common:DiffuseMagic() then return end
  if common:FortifyingBrew() then return end
  if common:DampenHarm() then return end
  if common:TigersLust() then return end
  if HealingElixir() then return end
  if Revival() then return end
  if ChijiRedCrane() then return end
  if EssenceFont() then return end

  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if LifeCocoon(f) then return end
    if ZenPulse(f) then return end
    if SoothingMist(f) then return end
    if EnvelopingMist(f) then return end
    if Vivify(f) then return end
    if f.HealthPct < Settings.RenewingPct and Spell.RenewingMist:Apply(f) then return end
  end

  if RenewingMist() then return end
end

return {
  Options = options,
  Behaviors = {
    [BehaviorType.Heal] = MonkMistweaver,
    [BehaviorType.Combat] = MonkMistweaverDamage
  }
}
