local common = require("behaviors.wow_retail.paladin.common")

local options = {
  Name = "Paladin (Prot)",
  Widgets = {
    {
      type = "slider",
      uid = "PaladinProtWogSelfPct",
      text = "Word Of Glory Self(%)",
      default = 50,
      min = 0,
      max = 100
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local gcd = wector.SpellBook.GCD

local auras = {
  shininglight = 327510,
  consecration = 188370,
  divinepurpose = 223817,
  judgment = 197277,
  crusader = 32223,
  devotion = 465,
  bastionoflight = 378974
}

local function Consecration()
  local spell = Spell.Consecration
  if spell:CooldownRemaining() > 0 then return false end

  return not Me:IsMoving() and not Me:HasAura(auras.consecration) and spell:CastEx(Me)
end

local function ShieldOfTheRighteous()
  local spell = Spell.ShieldOfTheRighteous
  local holypower = common:GetHolyPower()

  if holypower < 5 and not Me:HasAura(auras.bastionoflight) then return false end

  for _, target in pairs(Combat.Targets) do
    if Me:InMeleeRange(target) and Me:IsFacing(target) then
      return spell:CastEx(Me)
    end
  end
end

local function Judgment(enemy)
  local spell = Spell.Judgment
  if spell:CooldownRemaining() > 0 then return false end

  for _, target in pairs(Combat.Targets) do
    if Me:IsFacing(target) and not target:HasAura(auras.judgment) and spell:CastEx(target) then return true end
  end

  return spell:CastEx(enemy)
end

local function AvengersShield(enemy)
  local spell = Spell.AvengersShield
  if spell:CooldownRemaining() > 0 then return false end

  if spell:Interrupt() then
    wector.Console:Log("Interrupt Shield")
    return true
  end

  return spell:CastEx(enemy)
end

local function BlessedHammer()
  local spell = Spell.BlessedHammer
  if spell:CooldownRemaining() > 0 then return end

  return Combat.EnemiesInMeleeRange > 0 and spell:CastEx(Me)
end

local function HandOfReckoning()
  local spell = Spell.HandOfReckoning
  if spell.Charges == 0 then return end

  for _, target in pairs(Combat.Targets) do
    if target.InCombat and target.Target and not target.Aggro then
      return spell:CastEx(target)
    end
  end
end

local function BlessingOfFreedom()
  local spell = Spell.BlessingOfFreedom
  if spell:CooldownRemaining() > 0 then return false end

  local friends = WoWGroup:GetGroupUnits()
  for _, f in pairs(friends) do
    if f:IsRooted() and spell:CastEx(f) then return true end
  end
end

local function BlessingOfSacrifice()
  local spell = Spell.BlessingOfSacrifice
  if spell:CooldownRemaining() > 0 then return false end

  for _, t in pairs(Combat.Targets) do
    local target = t.Target

    if target and not target.IsActivePlayer and not target.IsEnemy then
      if spell:CastEx(target) then return true end
    end
  end
end

local function BlessingOfSpellwarding()
  local spell = Spell.BlessingOfSpellwarding
  if spell:CooldownRemaining() > 0 then return false end

  for _, enemy in pairs(Combat.Targets) do
    if not enemy.IsCastingOrChanneling then goto continue end

    local spellInfo = enemy.SpellInfo
    local castingFriend = wector.Game:GetObjectByGuid(spellInfo.TargetGuid1)
    local castingRemain = spellInfo.CastEnd - wector.Game.Time

    if castingFriend
        and not castingFriend.IsActivePlayer
        and castingFriend and not castingFriend.ToUnit.IsEnemy
        and castingRemain < 1000 and
        spell:CastEx(castingFriend) then
      return true
    end

    ::continue::
  end
end

local function DivineToll()
  local spell = Spell.DivineToll
  if spell:CooldownRemaining() > 0 then return false end
  local HP = common:GetHolyPower()

  return HP <= 2 and Combat:GetEnemiesWithinDistance(30) > 2 and spell:CastEx(Me)
end

local function BastionOfLight()
  local spell = Spell.BastionOfLight
  if spell:CooldownRemaining() > 0 then return false end

  return Combat.EnemiesInMeleeRange > 0 and spell:CastEx(Me)
end

local function EyeOfTyr()
  local spell = Spell.EyeOfTyr
  if spell:CooldownRemaining() > 0 then return false end
  if Me:IsMoving() then return false end

  return Combat.EnemiesInMeleeRange > 0 and Combat:AllTargetsGathered(8) and spell:CastEx(Me)
end

local function AuraSwitch()
  if Me.IsMounted and not Me:HasAura(auras.crusader) and Spell.CrusaderAura:CastEx(Me) then return true end
  if not Me.IsMounted and not Me:HasAura(auras.devotion) and Spell.DevotionAura:CastEx(Me) then return true end
end

local function PaladinProtCombat()
  if Me.IsCastingOrChanneling then return end

  if AuraSwitch() then return end

  if Me.IsMounted then return end

  if HandOfReckoning() then return end
  if BlessingOfFreedom() then return end
  if BlessingOfSacrifice() then return end
  if BlessingOfSpellwarding() then return end
  if ShieldOfTheRighteous() then return end

  local target = Combat.BestTarget
  if not target or not Me:IsFacing(target) then return end

  -- Lets do a GCD check so our priority is followed.
  if gcd:CooldownRemaining() > 0 then return end

  -- Keep priority down here.
  if common:DoInterrupt() then return end
  if Spell.HammerOfJustice:Interrupt() then return end
  if EyeOfTyr() then return end
  if BastionOfLight() then return end
  if DivineToll() then return end
  if Consecration() then return end
  if Judgment(target) then return end
  if common:HammerOfWrath() then return end
  if AvengersShield(target) then return end
  if BlessedHammer() then return end
end

local function PaladinProtHeal()
  if Me.IsCastingOrChanneling then return end

  local lowest = Heal:GetLowestMember()

  if Me.HealthPct < Settings.PaladinProtWogSelfPct and Spell.WordOfGlory:CastEx(Me) then return end

  if not lowest then return end

  if lowest.HealthPct < 20 and Spell.LayOnHands:CastEx(lowest) then
    return
  end
  -- Heal friend with WoG
  if lowest.HealthPct < 50 and Spell.WordOfGlory:CastEx(lowest) then
    return
  end
end

local behaviors = {
  [BehaviorType.Combat] = PaladinProtCombat,
  [BehaviorType.Heal] = PaladinProtHeal
}

return { Options = options, Behaviors = behaviors }
