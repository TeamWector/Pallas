-- BYEAS+uMNo6HaxL/ztTZBhrdcCAAAQAACKtWSpUOgkSOQSaSAAAAAAAkWIJSJBSiEpEgQkm0KhIJIogWA
local common = require("behaviors.wow_retail.paladin.common")

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
      uid = "PaladinProtWogSelfPct",
      text = "Word Of Glory Self(%)",
      default = 50,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "CrusaderAura",
      text = "Crusader Aura [Mounted]",
      default = false
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function IsCrusade()
  return Me:HasVisibleAura("Crusade")
end

local function TemplarsVerdict(enemy)
  local spell = Spell.TemplarsVerdict.IsKnown and Spell.TemplarsVerdict or Spell.FinalVerdict

  return spell:CastEx(enemy)
end

local judgement_aura = 197277
local function Judgment(enemy)
  local spell = Spell.Judgment

  return not enemy:HasAura(judgement_aura) and spell:CastEx(enemy)
end

local function BladeOfJustice(enemy)
  local spell = Spell.BladeOfJustice
  local hp = common:GetHolyPower()
  if spell:CooldownRemaining() > 0 then return false end

  return hp < 3 and spell:CastEx(enemy)
end

local function FinalReckoning(enemy)
  local spell = Spell.FinalReckoning

  return (IsCrusade() or Spell.Crusade:CooldownRemaining() == 45000) and spell:CastEx(enemy)
end

local function DivineToll(enemy)
  local spell = Spell.DivineToll

  return (IsCrusade() or Spell.Crusade:CooldownRemaining() == 45000) and spell:CastEx(enemy)
end

local function DivineStorm()
  local spell = Spell.DivineStorm

  return Combat:GetEnemiesWithinDistance(8) > 1 and spell:CastEx(Me)
end

local function WakeOfAshes(enemy)
  local spell = Spell.WakeOfAshes
  return spell:CastEx(enemy)
end

local function AvengingWrath()
  local spell = Spell.AvengingWrath

  return Spell.FinalReckoning:CooldownRemaining() == 0 and Spell.DivineToll:CooldownRemaining() == 0 and spell:CastEx(Me)
end

local function Crusade()
  local spell = Spell.Crusade

  return Spell.FinalReckoning:CooldownRemaining() == 0  and Spell.DivineToll:CooldownRemaining() == 0 and spell:CastEx(Me)
end


local function ShieldOfVengeance()
  local spell = Spell.ShieldOfVengeance

  return Me.HealthPct < 80 and spell:CastEx(Me)
end

local function DivineShield()
  local spell = Spell.DivineShield

  return Me.HealthPct < 15 and spell:CastEx(Me)
end

local function DivineProtection()
  local spell = Spell.DivineProtection

  return Me.HealthPct < 30 and spell:CastEx(Me)
end

local function Consecration()
  local spell = Spell.Consecration

  return not Me:IsMoving() and Combat:GetEnemiesWithinDistance(8) > 0 and spell:CastEx(Me)
end

local crusader_aura = 32223
local function CrusaderAura()
  local spell = Spell.CrusaderAura
  if not Settings.CrusaderAura then return false end

  return Me.IsMounted and not Me:HasAura(crusader_aura) and spell:CastEx(Me)
end

local retribution_aura = 183435
local function RetributionAura()
  local spell = Spell.RetributionAura

  return not Me:HasAura(retribution_aura) and spell:CastEx(Me)
end

local function isNotForbearance(friend)
  return not friend:HasAura("Forbearance")
end


local function getMyTarget()
  local target = Me.Target
  if not target then return end

  -- copy-paste from combat.lua
  if not Me:CanAttack(target) then
    return
  elseif not target.InCombat or (not Settings.PallasAttackOOC and not target.InCombat) then
    return
  elseif target.Dead or target.Health <= 0 then
    return
  elseif target:GetDistance(Me.ToUnit) > 40 then
    return
  elseif target.IsTapDenied and (not target.Target or target.Target ~= Me) then
    return
  elseif target:IsImmune() then
    return
  end
  return target
end

local function PaladinRetriCombat()
  if Me:IsStunned() or Me.IsCastingOrChanneling then return end

  if CrusaderAura() then return end

  if Me.IsMounted then return end

  if RetributionAura() then return end

  local target = getMyTarget()
  if target == nil then
    target = Combat.BestTarget
    if (not target) or (not target.IsPlayer) then return end
  end

  if common:DoInterrupt() then return end

  if DivineShield() then return end
  if DivineProtection() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if ShieldOfVengeance() then return end

  local friends = {}
  for _, v in pairs(Heal.PriorityList) do
    local unit = v.Unit
    table.insert(friends, unit)
  end

  table.sort(friends, function(a, b)
    return a:TimeToDeath() < b:TimeToDeath()
  end)
  for _, f in pairs(friends) do
    if f.HealthPct < 40 and Spell.WordOfGlory:CastEx(f) then return end
    if isNotForbearance(f) and f.HealthPct < 15 and Spell.LayOnHands:CastEx(f) then return end
    if isNotForbearance(f) and f.HealthPct < 25 and Spell.BlessingOfProtection:CastEx(f) then return end
    if f.HealthPct < 30 and Me.HealthPct > 75 and Spell.BlessingOfSacrifice:CastEx(f) then return end
    if f ~= Me and f:IsStunned() and Spell.BlessingOfSanctuary:CastEx(f) then return end
    if f ~= Me and f:IsRooted() and Spell.BlessingOfFreedom:CastEx(f) then return end
  end

  if Judgment(target) then return end
  if Crusade() then return end
  if FinalReckoning(target) then return end
  if DivineToll(target) then return end
  if TemplarsVerdict(target) then return end
  if WakeOfAshes(target) then return end
  if common:HammerOfWrath() then return end
  if BladeOfJustice(target) then return end
  if DivineStorm() then return end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinRetriCombat,
  [BehaviorType.Heal] = PaladinRetriCombat
}

return { Options = options, Behaviors = behaviors }
