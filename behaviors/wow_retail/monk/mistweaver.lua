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
  improvedDetox = 388874
}

MonkMWListener = wector.FrameScript:CreateListener()
MonkMWListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

-- Fix Enveloping
local EMFix = 0
function MonkMWListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
  if unitTarget == Me and spellID == Spell.EnvelopingMist.Id then
    EMFix = wector.Game.Time + 100
  end
end

local function IsCastingOrChanneling()
  return Me.CurrentSpell and Me.CurrentSpell.Id ~= Spell.SoothingMist.Id and
      Me.CurrentSpell.Id ~= Spell.CracklingJadeLightning.Id
end

local function RenewingMist()
  if Spell.RenewingMist.Charges == 0 or not Settings.RMSpread then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, f in pairs(friends) do
    local rm = f:GetAuraByMe(auras.renewingmist)
    if not rm or rm.Remaining <= 3000 then
      if Spell.RenewingMist:CastEx(f) then return true end
    end
  end
end

local function EnvelopingMist(friend)
  local shouldEM = (wector.Game.Time - EMFix) > 0
  if friend.HealthPct < Settings.EnvelopPct then
    return shouldEM and not friend:GetAuraByMe(auras.envelopingmist) and Spell.EnvelopingMist:CastEx(friend)
  end
end

local function SoothingMist(friend)
  if friend.HealthPct < Settings.SoothingPct then
    return not friend:GetAuraByMe(auras.soothingmist) and Spell.SoothingMist:CastEx(friend)
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
  return count >= Settings.EssenceFontCount and Spell.EssenceFont:CastEx(Me)
end

local function SpinningCraneKick()
  local enemyCount = Combat:GetEnemiesWithinDistance(8)

  if enemyCount < 2 or Spell.RisingSunKick:CooldownRemaining() == 0 then return false end
  return Spell.SpinningCraneKick:CastEx(Me)
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
  return not enemy:GetAuraByMe(Spell.CracklingJadeLightning.Id) and Spell.CracklingJadeLightning:CastEx(enemy)
end

local Pos = Vec3(0, 0, 0)
local function FaelineStomp()
  if Spell.FaelineStomp:CooldownRemaining() > 0 then return end
  if Me:GetAura(auras.faeline) and Me.Position:DistanceSq(Pos) < 10 then return end

  if Me.InCombat and not Me:IsMoving() and Spell.FaelineStomp:CastEx(Me) then
    Pos = Me.Position
    return true
  end
end

local function HealingElixir()
  return Me.HealthPct < Settings.HealingElixirPct and Spell.HealingElixir:CastEx(Me)
end

local function ChijiRedCrane()
  local spell = Spell.ChijiTheRedCrane
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
  if Me:GetAura(auras.improvedDetox) then
    if common:Detox("Magic", "Poison", "Disease") then return true end
  end

  if common:Detox("Magic") then return true end
end

local function MonkMistweaverDamage()
  if Me:IsSitting() or Me.IsMounted then return end

  local target = Combat.BestTarget
  if wector.SpellBook.GCD:CooldownRemaining() > 0 or (not target or not Me:IsFacing(target)) then return end

  if IsCastingOrChanneling() then return end

  local lowest = Heal:GetLowestMember()
  if lowest and lowest.HealthPct < Settings.VivifyPct then return end

  if Dispel() then return end
  if common:LegSweep() then return end
  if common:TouchOfDeath(target) then return end
  if FaelineStomp() then return end
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

  if common:SpearHandStrike() then return end

  if IsCastingOrChanneling() then return end

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
    if f.HealthPct < Settings.RenewingPct and not f:GetAuraByMe(auras.renewingmist) and Spell.RenewingMist:CastEx(f) then return end
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
