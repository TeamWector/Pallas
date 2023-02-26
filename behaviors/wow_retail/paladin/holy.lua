-- Holy paladin M+ Rotation
-- BEEAwtJ2KpR8WbGzhz/jy2AP8AAAAAAQSAAAAAAA0SCQJSSaNRKSIlAaJHIRTEJpkESSUSRSIFEB

local common = require("behaviors.wow_retail.paladin.common")

local options = {
  Name = "Paladin (Holy)",
  Widgets = {
    {
      type = "slider",
      uid = "HolyShockPct",
      text = "Holy Shock (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyWogPct",
      text = "WoG (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyFoLPct",
      text = "FoL (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyLightPct",
      text = "Holy Light (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HolyLohPct",
      text = "LoH (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "BeaconOfVirtuePct",
      text = "BoV (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "LightOfDawnPct",
      text = "LoD (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "AuraMasteryPct",
      text = "Aura Mastery (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DivineFavorPct",
      text = "Divine Favor (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DivineTollPct",
      text = "Divine Toll (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "BoSPct",
      text = "BoS (%)",
      default = 0,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "LoDRange",
      text = "LoD Range (yd)",
      default = 15,
      min = 15,
      max = 40
    },
    {
      type = "checkbox",
      uid = "shouldGlimmer",
      text = "Glimmer Talent",
      default = false
    },
  }
}

local auras = {
  glimmeroflight = 287280,
  judgementoflight = 196941,
  empyreanlegacy = 387178,
  infusionoflight = 54149,
  divinefavor = 210294
}

local function HolyShock(lowest)
  if Spell.HolyShock:CooldownRemaining() > 0 then return end

  local friends = WoWGroup:GetGroupUnits()

  if Settings.shouldGlimmer then
    for _, f in pairs(friends) do
      local hasGlimmer = f:GetAura(auras.glimmeroflight)
      if not hasGlimmer and Spell.HolyShock:CastEx(f) then return end
    end
  end

  if lowest and lowest.HealthPct < Settings.HolyShockPct and Spell.HolyShock:CastEx(lowest) then return true end

  local target = Combat.BestTarget
  if target and Spell.HolyShock:CastEx(target) then return true end
end

local function LayOnHands(lowest)
  if not lowest or Spell.LayOnHands:CooldownRemaining() > 0 then return end

  if lowest.HealthPct < Settings.HolyLohPct then
    if #lowest:GetUnitsAround(8) > 0 and Spell.LayOnHands:CastEx(lowest) then return true end
  end
end

local function Judgement()
  if Spell.Judgment:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if target and not target:HasAura(auras.judgementoflight) and Spell.Judgment:CastEx(target) then return true end

  for _, t in pairs(Combat.Targets) do
    if not t:HasAura(auras.judgementoflight) and Spell.Judgment:CastEx(t) then return true end
  end

  if target and Spell.Judgment:CastEx(target) then return end
end

local function CrusaderStrike()
  if Spell.CrusaderStrike.Charges < 1 or Spell.HolyShock:CooldownRemaining() < 1500 or common:GetHolyPower() >= 5 then return end
  local target = Combat.BestTarget

  if Spell.CrusaderStrike:CastEx(target) then return true end

  for _, t in pairs(Combat.Targets) do
    if Spell.CrusaderStrike:CastEx(t) then return true end
  end
end

local function WorldOfGlory(lowest)
  if common:GetHolyPower() < 3 or not lowest or not common:HasDawn() then return end
  local purpose = Me:GetAura(common.auras.divinepurpose)

  if (lowest.HealthPct < Settings.HolyWogPct or purpose and purpose.Remaining < 5000) and Spell.WordOfGlory:CastEx(lowest) then return true end
end

local function LightOfDawn(lowest)
  local spell = Spell.LightOfDawn

  if Me:HasAura(auras.empyreanlegacy) then
    spell = Spell.WordOfGlory
  end

  if common:GetHolyPower() < 3 or not common:HasDawn() or not lowest then return end

  local friends, count = Heal:GetMembersBelow(Settings.LightOfDawnPct)

  if count > 1 then
    for _, f in pairs(friends) do
      if Me:GetDistance(f) <= Settings.LoDRange and Me:IsFacing(f) and spell:CastEx(lowest) then return true end
    end
  end
end

local function Consecration()
  return not Me:IsMoving() and Combat:GetEnemiesWithinDistance(8) > 0 and Spell.Consecration:CastEx(Me)
end

local function ShieldOfTheRighteous()
  local hp = common:GetHolyPower()
  local lowest = Heal:GetLowestMember()
  local enemies = Combat.EnemiesInMeleeRange
  local dusk = common:HasDusk()
  local dawn = common:HasDawn()

  if hp < 3 or (lowest and lowest.HealthPct < Settings.HolyWogPct) or (enemies < 2 and dusk) or not dawn then return end

  if Spell.ShieldOfTheRighteous:CastEx(Me) then return true end
end

local function BeaconOfVirtue()
  if Spell.BeaconOfVirtue:CooldownRemaining() > 0 then return end

  local friends, count = Heal:GetMembersBelow(Settings.BeaconOfVirtuePct)

  if count > 1 then
    for _, v in pairs(Heal.Tanks) do
      local t = v.Unit
      if Spell.BeaconOfVirtue:CastEx(t) then return true end
    end

    if Spell.BeaconOfVirtue:CastEx(Me) then return true end
  end
end

local function FlashOfLight(lowest)
  if not lowest then return end
  return (lowest.HealthPct < Settings.HolyFoLPct) and Spell.FlashOfLight:CastEx(lowest)
end

local function LightsHammer()
  local target = Combat.BestTarget
  if not target or Spell.LightsHammer:CooldownRemaining() > 0 then return end

  if Combat:TargetsAverageDeathTime() > 10 then
    return not Me:IsMoving() and not target:IsMoving() and Spell.LightsHammer:CastEx(target.Position)
  end
end

local function AuraMastery()
  if Spell.AuraMastery:CooldownRemaining() > 0 then return end
  local friends, count = Heal:GetMembersBelow(Settings.AuraMasteryPct)
  return count > 1 and Spell.AuraMastery:CastEx(Me)
end

local function DivineFavor(lowest)
  if not lowest or Spell.DivineFavor:CooldownRemaining() > 0 then return end
  return lowest.HealthPct < Settings.DivineFavorPct and Spell.DivineFavor:CastEx(Me)
end

local function DivineToll(lowest)
  if not lowest or Spell.DivineToll:CooldownRemaining() > 0 then return end
  local friends, count = Heal:GetMembersBelow(Settings.DivineTollPct)

  return count > 2 and Spell.DivineToll:CastEx(lowest)
end

local function SeasonBlesings()
  if Spell.BlessingOfSpring:IsUsable() then
    for _, v in pairs(Heal.Tanks) do
      local t = v.Unit
      if t.InCombat and Spell.BlessingOfSpring:CastEx(t) then return end
    end
  end

  if Spell.BlessingOfSummer:IsUsable() then
    for _, v in pairs(Heal.DPS) do
      local d = v.Unit
      print(d.NameUnsafe)
      if d.InCombat and Spell.BlessingOfSummer:CastEx(d) then return end
    end
  end

  if Spell.BlessingOfAutumn:IsUsable() and Spell.BlessingOfAutumn:CastEx(Me) then return end

  if Spell.BlessingOfWinter:IsUsable() then
    if Me.PowerPct < 100 and Spell.BlessingOfWinter:CastEx(Me) then return end
  end
end

local function HolyLight(lowest)
  if not lowest then return end
  local infusion = Me:GetAura(auras.infusionoflight)
  local divine = Me:GetAura(auras.divinefavor)
  local hp = common:GetHolyPower()

  if (infusion and divine and hp < 5 or lowest.HealthPct < Settings.HolyLightPct) and Spell.HolyLight:CastEx(lowest) then return end
end

local function BlessingOfSacrifice()
  for _, v in pairs(Heal.Tanks) do
    local t = v.Unit
    if t.InCombat and t.HealthPct < Settings.BoSPct and Spell.BlessingOfSacrifice:CastEx(t) then return end
  end
end

local function HolyPaladinHeal()
  if Me:IsSitting() or Me.IsCastingOrChanneling then return end

  local lowest = Heal:GetLowestMember()

  if AuraMastery() then return end
  if DivineFavor(lowest) then return end
  if LayOnHands(lowest) then return end
  if DivineToll(lowest) then return end
  if BlessingOfSacrifice() then return end
  if HolyShock(lowest) then return end
  if BeaconOfVirtue() then return end
  if WorldOfGlory(lowest) then return end
  if LightOfDawn(lowest) then return end
  if HolyLight(lowest) then return end
  if FlashOfLight(lowest) then return end
end

local function HolyPaladinDamage()
  if Me:IsSitting() or Me.IsCastingOrChanneling then return end

  if CrusaderStrike() then return end
  if common:HammerOfWrath() then return end
  if Judgement() then return end
  if ShieldOfTheRighteous() then return end
  if LightsHammer() then return end
  if Consecration() then return end
end

local behaviors = {
  [BehaviorType.Heal] = HolyPaladinHeal,
  [BehaviorType.Combat] = HolyPaladinDamage
}

return { Options = options, Behaviors = behaviors }