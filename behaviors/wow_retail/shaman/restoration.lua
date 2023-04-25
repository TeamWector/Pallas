local common = require("behaviors.wow_retail.shaman.common")

-- BgQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwB4AH4AOwBWwCcgDwBaQZBHQZBlDsgiFcABh0iEIaSSRgSiolEJJRD

local options = {
  Name = "Shaman (Restorationn) PVP",
  Widgets = {
    {
      type = "slider",
      uid = "RiptidePct",
      text = "Riptide (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingSurgePct",
      text = "Healing Surge (%)",
      default = 75,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingSurgeWithTidalWavesPct",
      text = "Healing Surge with Tidal Waves (%)",
      default = 78,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "EarthenWallTotemPct",
      text = "Earthen Wall Totem (%)",
      default = 58,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingTideTotemPct",
      text = "Heaing Tide Totem (%)",
      default = 37,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "SpiritLinkTotemPct",
      text = "Spirit Link Totem (%)",
      default = 26,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingWavePct",
      text = "Healing Wave (%)",
      default = 65,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "TotemicRecallPct",
      text = "Totemic Recall (%)",
      default = 49,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "UnleashLifePct",
      text = "Unleash Life (%)",
      default = 65,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "AscendancePct",
      text = "Ascendance (%)",
      default = 38,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HealingStreamTotemPct",
      text = "Healing Stream Totem (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "ShamanPurgeEnemies",
      text = "Use Purge",
      default = false
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local auras = {
  earthShield = 974,
}

local timeOfLastHealingStreamTotem = 0

local function HealingStreamTotem(friend)
  local timeSinceHealingStream = wector.Game.Time - timeOfLastHealingStreamTotem

  local spell = Spell.HealingStreamTotem
  if spell:CooldownRemaining() > 0 or timeSinceHealingStream < 12000 then return false end
  if friend.HealthPct < Settings.HealingStreamTotemPct and spell:CastEx(Me) then
    timeOfLastHealingStreamTotem = wector.Game.Time
    return true
  end
end

local function HealingTideTotem(friend)
  local spell = Spell.HealingTideTotem
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.HealingTideTotemPct and spell:CastEx(Me)
end

function IsTidalWaves()
  return Me:HasVisibleAura("Tidal Waves")
end

function IsAscendance()
  return Me:HasVisibleAura("Ascendance")
end

local function HealingSurge(friend)
  local spell = Spell.HealingSurge
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.HealingSurgePct and spell:CastEx(friend)
end

local function HealingSurgeWithTidalWaves(friend)
  local spell = Spell.HealingSurge
  if spell:CooldownRemaining() > 0 or not IsTidalWaves() then return false end
  return friend.HealthPct < Settings.HealingSurgeWithTidalWavesPct and spell:CastEx(friend)
end

local function HealingWave(friend)
  local spell = Spell.HealingWave
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.HealingWavePct and spell:CastEx(friend)
end

local function HealingWaveNaturesSwiftness(friend)
  local spell = Spell.HealingWave
  if spell:CooldownRemaining() > 0 or not Me:HasAura("Nature's Swiftness") then return false end
  return friend.HealthPct < Settings.HealingWavePct and spell:CastEx(friend)
end

local function TotemicRecall(friend)
  local spell = Spell.TotemicRecall
  if spell:CooldownRemaining() > 0 or Spell.EarthenWallTotem:CooldownRemaining() == 0 then return false end
  return friend.HealthPct < Settings.TotemicRecallPct and spell:CastEx(Me)
end

local function Riptide(friend)
  local spell = Spell.Riptide
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.RiptidePct and spell:CastEx(friend)
end

local function UnleashLife(friend)
  local spell = Spell.UnleashLife
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.UnleashLifePct and spell:CastEx(friend)
end

local function EarthenWallTotem(friend)
  local spell = Spell.EarthenWallTotem
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.EarthenWallTotemPct and spell:CastEx(friend)
end

local function EarthShield(friend)
  local spell = Spell.EarthShield
  if spell:CooldownRemaining() > 0 or friend:HasAura(auras.earthShield) or friend.HealthPct > 80 then return false end
  return spell:Apply(friend)
end

local function WaterShield()
  local spell = Spell.WaterShield
  if spell:Apply(Me) then return true end
end

local function Dispel(priority)
  local spell = Spell.PurifySpirit
  if spell:CooldownRemaining() > 0 then return false end
  spell:Dispel(true, priority or 1, WoWDispelType.Magic)
end

local function Purge(priority)
  local spell = Spell.GreaterPurge
  if not Settings.ShamanPurgeEnemies then return false end
  if spell:Dispel(false, priority, WoWDispelType.Magic) then return true end
end

local function NaturesSwiftness(friend)
  local spell = Spell.NaturesSwiftness
  if spell:CooldownRemaining() > 0 then return false end
  if friend.HealthPct < 35 and Spell.NaturesSwiftness:CastEx(Me) then return end
end

local function SpiritLinkTotem(friend)
  local spell = Spell.SpiritLinkTotem
  if spell:CooldownRemaining() > 0 or IsAscendance() then return false end
  return friend.HealthPct < Settings.SpiritLinkTotemPct and spell:CastEx(friend)
end

local function Ascendance(friend)
  local spell = Spell.Ascendance
  if spell:CooldownRemaining() > 0 or IsAscendance() then return false end
  return friend.HealthPct < Settings.AscendancePct and spell:CastEx(Me)
end


local function FlameShock(target)
  local spell = Spell.FlameShock
  if spell:CooldownRemaining() > 0 then return false end
  if spell:Apply(target) then return true end
end




local function ShamanRestoDamage()
  local target = Me.Target
  if not target then return false end

  -- copy-paste from combat.lua
  if not Me:CanAttack(target) then
    return false
  elseif not target.InCombat or (not Settings.PallasAttackOOC and not target.InCombat) then
    return false
  elseif target.Dead or target.Health <= 0 then
    return false
  elseif target:GetDistance(Me.ToUnit) > 40 then
    return false
  elseif target.IsTapDenied and (not target.Target or target.Target ~= Me) then
    return false
  elseif target:IsImmune() then
    return false
  end



  if not target then return false end
  local lowest = Heal:GetLowestMember()
  local shouldDPS = not lowest or lowest.HealthPct >= 85

  if not shouldDPS then return false end

  if Purge(DispelPriority.Medium) then return end
  if common:LightningBoltWithStormkeeper(target) then return true end
  if FlameShock(target) then return true end
  if Purge(DispelPriority.Low) then return true end
  if common:Stormkeeper() then return true end
  if common:LavaBurst(target) then return true end
  if (#target:GetUnitsAround(13) > 1) then
    if common:ChainLightning(target) then return true end
  else
    if common:LightningBolt(target) then return true end
  end
  if common:FrostShock(target) then return end
end

local function ShamanResto()
  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  if common:DoInterrupt() then return end

  local GCD = wector.SpellBook.GCD
  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end

  if common:AstralShift() then return end

  if common:EarthShield() then return end

  local friends = {}
  for _, v in pairs(Heal.PriorityList) do
    local unit = v.Unit
    table.insert(friends, unit)
  end

  table.sort(friends, function(a, b)
    return a:TimeToDeath() < b:TimeToDeath()
  end)



  -- BURST HEALING
  for _, f in pairs(friends) do
    if HealingWaveNaturesSwiftness(f) then return end
    if Ascendance(f) then return end
    if SpiritLinkTotem(f) then return end
    if NaturesSwiftness(f) then return end
    if Dispel(DispelPriority.High) then return end
    if Riptide(f) then return end
    if HealingTideTotem(f) then return end
    if EarthenWallTotem(f) then return end
    if Riptide(f) then return end
    if f.HealthPct < 60 and common:PrimordialWave(f) then return true end
    local earthShieldTarget = friends[1]
    if earthShieldTarget and earthShieldTarget == Me then earthShieldTarget = friends[2] end
    if earthShieldTarget and earthShieldTarget ~= Me and EarthShield(earthShieldTarget) then return end
    if TotemicRecall(f) then return end
    if Purge(DispelPriority.High) then return end
    if UnleashLife(f) then return end
    if HealingSurgeWithTidalWaves(f) then return end
    if HealingSurge(f) then return end
    --if HealingWave(f) then return end
    if HealingStreamTotem(f) then return end
    if Dispel(DispelPriority.Medium) then return end

    -- if (f.Class == 3 and f.Pet) then
    --   if f.Pet.HealthPct < 75 and Spell.Riptide:CastEx(f.Pet) then return end
    --   if f.Pet.HealthPct < 55 and Spell.HealingSurge:CastEx(f.Pet) then return end
    -- end
  end

  if WaterShield() then return end



  if Dispel(DispelPriority.Low) then return end


  if ShamanRestoDamage() then return end
end

local behaviors = {
  [BehaviorType.Heal] = ShamanResto,
  [BehaviorType.Combat] = ShamanResto
}

return { Options = options, Behaviors = behaviors }
