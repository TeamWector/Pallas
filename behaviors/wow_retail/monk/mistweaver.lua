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
      uid = "InstantVivifyPct",
      text = "Instant Vivify (%)",
      default = 0,
      min = 0,
      max = 100
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
      uid = "MonkTrinket1Pct",
      text = "Trinket 1 (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "MonkTrinket2Pct",
      text = "Trinket 2 (%)",
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
    {
      type = "slider",
      uid = "SheilunPct",
      text = "Sheilun's Gift (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "SheilunCount",
      text = "Sheilun's Gift Count",
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
  invokechiji = 343820,
  sheilunsgift = 399510,
  chijibird = 325197
}

local function HealTrinket(friend)
  local trink1Pct = Settings.MonkTrinket1Pct
  local trink2Pct = Settings.MonkTrinket2Pct
  local trinket1 = WoWItem:GetUsableEquipment(EquipSlot.Trinket1)
  local trinket2 = WoWItem:GetUsableEquipment(EquipSlot.Trinket2)

  if trink1Pct == 0 and trink2Pct == 0 then return false end

  if trinket1 then
    if friend.HealthPct < trink1Pct and trinket1:UseX(friend) then return true end
  end

  if trinket2 then
    if friend.HealthPct < trink2Pct and trinket2:UseX(friend) then return true end
  end
end

local function IsCastingOrChanneling()
  return Me.CurrentSpell and Me.CurrentSpell.Id ~= Spell.SoothingMist.Id
      and Me.CurrentSpell.Id ~= Spell.CracklingJadeLightning.Id
      and Me.CurrentSpell.Id ~= Spell.SpinningCraneKick.Id
end

local function RenewingMist()
  local spell = Spell.RenewingMist
  if spell.Charges == 0 or not Settings.RMSpread then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, f in pairs(friends) do
    if spell:Apply(f) then return true end
  end
end

local function EnvelopingMist(friend)
  local spell = Spell.EnvelopingMist
  local chiji = Me:GetAura(auras.invokechiji)

  if chiji and chiji.Stacks > 1 then
    local tanks = WoWGroup:GetTankUnits()

    for _, v in pairs(Heal.PriorityList) do
      local f = v.Unit
      if spell:Apply(f) then return true end
    end

    for _, t in pairs(tanks) do
      if spell:Apply(t) then return true end
    end
  end

  if not friend then return false end

  if friend.HealthPct < Settings.EnvelopPct then
    return spell:Apply(friend)
  end
end

local function SoothingMist(friend)
  if friend.HealthPct < Settings.SoothingPct then
    return Spell.SoothingMist:Apply(friend)
  end
end

-- todo add logic for damage prevention
local function LifeCocoon(friend)
  if Spell.LifeCocoon:CooldownRemaining() > 0 then return false end

  if friend.HealthPct < Settings.CocoonPct then
    return #friend:GetUnitsAround(8) > 0 and Spell.LifeCocoon:CastEx(friend)
  end
end

local function Vivify(friend)
  local instant = Me:GetAura(392883)

  if friend.HealthPct < Settings.VivifyPct or instant and friend.HealthPct < Settings.InstantVivifyPct then
    return Spell.Vivify:CastEx(friend)
  end
end

local function ZenPulse(friend)
  if Spell.ZenPulse:CooldownRemaining() > 0 then return false end

  if friend.HealthPct < Settings.ZenPulsePct then
    local enemy8 = #friend:GetUnitsAround(8)
    local reverb = not Settings.ZenReverb or
        friend:GetAuraByMe(auras.envelopingmist) and friend:GetAuraByMe(auras.renewingmist)
    if reverb or enemy8 > 4 then
      return enemy8 > 0 and Spell.ZenPulse:CastEx(friend)
    end
  end
end

local function EssenceFont()
  if Spell.EssenceFont:CooldownRemaining() > 0 then return false end

  return Me:IsMoving() and Spell.EssenceFont:CastEx(Me)
end

local function SpinningCraneKick()
  local enemyCount = Combat.EnemiesInMeleeRange
  local hasaoekick = Me:GetAura(auras.ancientconcordance)

  if (enemyCount < 7 and hasaoekick or enemyCount < 3) or Spell.RisingSunKick:CooldownRemaining() == 0 then return false end

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
  local shouldMultikick = teachings and teachings.Stacks > 1 or Me.PowerPct >= 95

  return (Spell.RisingSunKick:CooldownRemaining() > 2000 and shouldMultikick) and Spell.BlackoutKick:CastEx(enemy)
end

local function TigerPalm(enemy)
  return Spell.TigerPalm:CastEx(enemy)
end

local function ChiBurst()
  local spell = Spell.ChiBurst
  if spell:CooldownRemaining() > 0 then return false end

  local hitcount = 0

  for _, enemy in pairs(Combat.Targets) do
    if Me:IsFacing(enemy) then
      hitcount = hitcount + 1
    end
  end

  for _, v in pairs(Heal.PriorityList) do
    local friend = v.Unit
    if Me:IsFacing(friend) then
      hitcount = hitcount + 1
    end
  end

  return hitcount > 2 and Spell.ChiBurst:CastEx(Me)
end

local function ChiWave(enemy)
  return Spell.ChiWave:CastEx(enemy)
end

local function CracklingJadeLightning(enemy)
  return not Me.IsCastingOrChanneling and Me:GetDistance(enemy) > 15 and Spell.CracklingJadeLightning:Apply(enemy)
end

local function FaelineStomp(enemy)
  if Spell.FaelineStomp:CooldownRemaining() > 0 then return false end
  if Me:GetAura(auras.ancientconcordance) and Me:GetAura(auras.ancientteachings) then return false end

  local TTD = Combat:TargetsAverageDeathTime()
  if TTD < 10 or TTD == 9999 then return false end

  if Me.InCombat and not Me:IsMoving() and Me:InMeleeRange(enemy) and Spell.FaelineStomp:CastEx(Me) then
    return true
  end
end

local function HealingElixir()
  return Me.HealthPct < Settings.HealingElixirPct and Spell.HealingElixir:CastEx(Me)
end

local function ChijiRedCrane()
  local spell = Spell.InvokeChijiTheRedCrane
  local target = Combat.BestTarget
  local TTD = Combat:TargetsAverageDeathTime()
  if spell:CooldownRemaining() > 0 or not Me.InCombat or not target then return false end
  if TTD == 9999 or TTD < 12 then return false end

  return Me:InMeleeRange(target) and spell:CastEx(Me)
end

local function Revival()
  local spell = Spell.Revival
  if spell:CooldownRemaining() > 0 then return false end

  return spell:CastEx(Me)
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
  if count >= 2 and Spell.ManaTea:CastEx(Me) then return true end
end

local function SheilunsGift()
  local spell = Spell.SheilunsGift
  local sheilun = Me:GetAura(auras.sheilunsgift)
  if not sheilun or sheilun.Stacks == 0 then return false end
  local lowest = Heal:GetLowestMember() or Me

  return sheilun.Stacks > 2 and spell:CastEx(lowest)
end

local function AoEHeal()
  local revivalBelow, revivalCount = Heal:GetMembersBelow(Settings.RevivalPct)
  local sheilunBelow, sheilunCount = Heal:GetMembersBelow(Settings.SheilunPct)
  local chijiBelow, chijiCount = Heal:GetMembersBelow(Settings.ChijiPct)
  local essenceBelow, essenceCount = Heal:GetMembersBelow(Settings.EssenceFontPct)

  if revivalCount >= Settings.RevivalCount and Revival() then
    return true
  elseif chijiCount >= Settings.ChijiCount and ChijiRedCrane() then
    return true
  elseif sheilunCount >= Settings.SheilunCount and SheilunsGift() then
    return true
  elseif essenceCount >= Settings.EssenceFontCount and EssenceFont() then
    return true
  end

  return false
end

local function BirdRotation()
  local target = Combat.BestTarget

  if EnvelopingMist() then return true end
  if FaelineStomp(target) then return true end
  if RisingSunKick(target) then return true end
  if BlackoutKick(target) then return true end
  if TigerPalm(target) then return true end
end

local function MonkMistweaverDamage()
  local target = Combat.BestTarget
  if not target or not Me:IsFacing(target) then return false end

  if IsCastingOrChanneling() or not Me:IsFacing(target) then return false end

  local lowest = Heal:GetLowestMember()
  if lowest and lowest.HealthPct < Settings.VivifyPct and Spell.Vivify:IsUsable() then return false end

  if common:LegSweep() then return true end
  if common:TouchOfDeath() then return true end
  if FaelineStomp(target) then return true end
  if ChiBurst() then return true end
  if ChiWave(target) then return true end
  if SpinningCraneKick() then return true end
  if RisingSunKick(target) then return true end
  if BlackoutKick(target) then return true end
  if TigerPalm(target) then return true end
  if CracklingJadeLightning(target) then return true end
end

local function MonkMistweaver()
  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if not Me.IsCastingOrChanneling and Spell.SpearHandStrike:Interrupt() then return end

  if IsCastingOrChanneling() then return end

  local birdExists = Me:GetAura(auras.chijibird)

  if ManaTea() then return end
  if common:DiffuseMagic() then return end
  if common:FortifyingBrew() then return end
  if common:DampenHarm() then return end
  if HealingElixir() then return end

  if birdExists and Combat.EnemiesInMeleeRange > 0 then
    if BirdRotation() then return end
    return
  end

  if AoEHeal() then return end

  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if HealTrinket(f) then return end
    if LifeCocoon(f) then return end
    if ZenPulse(f) then return end
    if SoothingMist(f) then return end
    if EnvelopingMist(f) then return end
    if Vivify(f) then return end
    if f.HealthPct < Settings.RenewingPct and Spell.RenewingMist:Apply(f) then return end
  end

  if Dispel() then return end
  if common:TigersLust() then return end
  if common:ExpelHarm() then return end
  if RenewingMist() then return end

  if MonkMistweaverDamage() then return end
end

return {
  Options = options,
  Behaviors = {
    [BehaviorType.Heal] = MonkMistweaver,
    [BehaviorType.Combat] = MonkMistweaver
  }
}
