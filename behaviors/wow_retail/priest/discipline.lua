local common = require("behaviors.wow_retail.priest.common")

local options = {
  Name = "Priest (Discipline) PVP",
  Widgets = {
    {
      type = "slider",
      uid = "DiscPowerWordBarrierPct",
      text = "PW: Barrier (%)",
      default = 40,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscPowerWordShieldPct",
      text = "PW: Shield (%)",
      default = 80,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscPowerWordRadiancePct",
      text = "PW: Radiance (%)",
      default = 55,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscPenancePct",
      text = "Penance (%)",
      default = 69,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscFlashHealPct",
      text = "Flash Heal (%)",
      default = 75,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscPainSuppressionPct",
      text = "Pain Suppression (%)",
      default = 34,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscRapturePct",
      text = "Rapture (%)",
      default = 38,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "DiscVoidShift",
      text = "Void Shift (%)",
      default = 24,
      min = 0,
      max = 100
    },

  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local auras = {
  painSuppression = 33206,
  powerOfTheDarkSide = 198068,
  purgeTheWicked = 204213,
  powerWordShield = 17,
}

local function PowerWordBarrier(friend)
  local spell = Spell.PowerWordBarrier
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.DiscPowerWordBarrierPct and spell:CastEx(friend)
end


local function PowerWordShield(friend)
  local spell = Spell.PowerWordShield
  if spell:CooldownRemaining() > 0 then return false end

  return friend.HealthPct < Settings.DiscPowerWordShieldPct and (not friend:HasAura(auras.powerWordShield)) and
      spell:CastEx(friend)
end

local function PowerWordRadiance(friend)
  local spell = Spell.PowerWordRadiance
  if spell:CooldownRemaining() > 0 or spell.Charges < 2 then return false end
  return friend.HealthPct < Settings.DiscPowerWordRadiancePct and spell:CastEx(friend)
end

local function PowerWordRadianceOneCharge(friend)
  local spell = Spell.PowerWordRadiance
  if spell:CooldownRemaining() > 0 or spell.Charges < 1 then return false end
  return friend.HealthPct < Settings.DiscPowerWordRadiancePct and spell:CastEx(friend)
end


local function Penance(friend)
  local spell = Spell.Penance
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.DiscPenancePct and spell:CastEx(friend)
end

local function FlashHeal(friend)
  local spell = Spell.FlashHeal
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.DiscFlashHealPct and spell:CastEx(friend)
end

local function PainSuppression(friend)
  local spell = Spell.PainSuppression
  if spell:CooldownRemaining() > 0 or friend:HasAura(auras.painSuppression) then return false end
  return friend.HealthPct < Settings.DiscPainSuppressionPct and spell:CastEx(friend)
end

local function Rapture(friend)
  local spell = Spell.Rapture
  if spell:CooldownRemaining() > 0 or friend:HasAura(auras.painSuppression) then return false end
  return friend.HealthPct < Settings.DiscRapturePct and spell:CastEx(friend)
end

local function PenanceOffensive(target)
  local spell = Spell.Penance
  if spell:CooldownRemaining() > 0 or not Me:HasAura(auras.powerOfTheDarkSide) == nil then return false end
  return spell:CastEx(target)
end

local function PurgeTheWicked(target)
  local spell = Spell.PurgeTheWicked
  if spell:CooldownRemaining() > 0 or target:HasAura(auras.purgeTheWicked) then return false end
  return spell:CastEx(target)
end

local function PowerInfusionMyself()
  local spell = Spell.PowerInfusion
  if spell:CooldownRemaining() > 0 then return false end
  return spell:CastEx(Me)
end

local function Schism(target)
  local spell = Spell.Schism
  if spell:CooldownRemaining() > 0 then return false end
  return spell:CastEx(target)
end

local function PowerWordSolace(target)
  local spell = Spell.PowerWordSolace
  if spell:CooldownRemaining() > 0 then return false end
  return spell:CastEx(target)
end

local function MindBlast(target)
  local spell = Spell.MindBlast
  if spell:CooldownRemaining() > 0 then return false end
  return spell:CastEx(target)
end

local function Smite(target)
  local spell = Spell.Smite
  if spell:CooldownRemaining() > 0 then return false end
  return spell:CastEx(target)
end

local function Dispel(priority)
  local spell = Spell.Purify
  if spell:CooldownRemaining() > 0 then return false end
  spell:Dispel(true, priority or 1, WoWDispelType.Magic)
end

local function VoidShift(friend)
  if (friend == Me) then return false end
  local spell = Spell.VoidShift
  if spell:CooldownRemaining() > 0 then return false end
  return friend.HealthPct < Settings.DiscVoidShift and spell:CastEx(friend)
end

local function MassDispel()
  local spell = Spell.MassDispel
  if spell:CooldownRemaining() > 0 then return false end
  for _, enemy in pairs(Combat.Targets) do
    if enemy:HasAura("Ice Block") or enemy:HasAura("Divine Shield") then
      if spell:CastEx(enemy) then return true end
    end
  end
end

local function FlashHealSurgeOfLight(friend)
  local spell = Spell.FlashHeal
  if spell:CooldownRemaining() > 0 then return false end
  return Me:HasAura("Surge of Light") and friend.HealthPct < Settings.DiscFlashHealPct and spell:CastEx(friend)
end


-- TODO REVISIT ME
local function MaintainAtonement()
  if not Me:InArena() or Me:HasArenaPreparation() then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, f in pairs(friends) do

  end
end

local function PriestDiscDamage()
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
  local shouldDPS = not lowest or lowest.HealthPct >= Settings.DiscFlashHealPct

  if not shouldDPS then return false end

  if common:DispelMagic(DispelPriority.Medium) then return end

  if PurgeTheWicked(target) then return true end
  --if PowerInfusionMyself() then return true end
  if common:Shadowfiend(target) then return true end
  if Schism(target) then return true end
  if (target.HealthPct < 50) then
    if common:Mindgames(target) then return true end
  end
  if common:ShadowWordDeath() then return true end
  if PenanceOffensive(target) then return true end
  if common:DispelMagic(DispelPriority.Low) then return end
  if MindBlast(target) then return true end
  if Smite(target) then return true end
end

local function PriestDiscipline()
  if Me:IsSitting() or Me.IsMounted or Me:IsStunned() then return end

  common:MovementUpdate()

  local GCD = wector.SpellBook.GCD
  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end

  if common:PowerWordLife() then return end
  if MassDispel() then return end
  if common:DesperatePrayer() then return end

  -- BURST HEALING
  for _, v in pairs(Heal.PriorityList) do
    local f = v.Unit

    if PainSuppression(f) then return end
    if Rapture(f) then return end
    if VoidShift(f) then return end
    if PowerWordBarrier(f) then return end
    if PowerWordShield(f) then return end
    if PowerWordRadiance(f) then return end
    if FlashHealSurgeOfLight(f) then return end
    if Dispel(DispelPriority.High) then return end
    if common:DispelMagic(DispelPriority.High) then return end
    if Penance(f) then return end
    if FlashHeal(f) then return end
    if PowerWordRadianceOneCharge(f) then return end
  end

  if Dispel(DispelPriority.Low) then return end

  if MaintainAtonement() then return end

  if PriestDiscDamage() then return end
end

local behaviors = {
  [BehaviorType.Heal] = PriestDiscipline,
  [BehaviorType.Combat] = PriestDiscipline
}

return { Options = options, Behaviors = behaviors }
