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

local function TemplarsVerdict(enemy)
  local spell = Spell.TemplarsVerdict.IsKnown and Spell.TemplarsVerdict or Spell.FinalVerdict

  return spell:CastEx(enemy)
end

local function CrusaderStrike(enemy)
  local spell = Spell.CrusaderStrike

  return spell:CastEx(enemy)
end

local function Judgment(enemy)
  local spell = Spell.Judgment

  return spell:CastEx(enemy)
end

local function BladeOfJustice(enemy)
  local spell = Spell.BladeOfJustice
  local hp = common:GetHolyPower()
  if spell:CooldownRemaining() > 0 then return false end

  return hp <= 3 and spell:CastEx(enemy)
end

local function DivineStorm()
  local spell = Spell.DivineStorm

  return Combat:GetEnemiesWithinDistance(8) > 1 and spell:CastEx(Me)
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

local function PaladinRetriCombat()
  if Me:IsStunned() or Me.IsCastingOrChanneling then return end

  if CrusaderAura() then return end

  if Me.IsMounted then return end

  if RetributionAura() then return end

  local target = Combat.BestTarget
  if not target then return end

  if common:DoInterrupt() then return end

  local GCD = wector.SpellBook.GCD
  if GCD:CooldownRemaining() > 0 then return end

  if DivineStorm() then return end
  if TemplarsVerdict(target) then return end
  if common:HammerOfWrath() then return end
  if BladeOfJustice(target) then return end
  if Judgment(target) then return end
  if CrusaderStrike(target) then return end
  if Consecration() then return end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinRetriCombat,
  [BehaviorType.Heal] = PaladinRetriCombat
}

return { Options = options, Behaviors = behaviors }
