local common = require("behaviors.wow_retail.evoker.common")

local options = {
  Name = "Evoker (Devastation)",
  Widgets = {
    {
      type = "text",
      uid = "EvokerDevastationText",
      text = ">> Defensives <<",
    },
  }
}

local auras = {
  essenceburst = 359618,
}

local empowerWanted = 0

local function EternitySurge(enemy)
  local spell = Spell.EternitySurge
  local spelldata = WoWSpell(spell.OverrideId)
  if spelldata:CooldownRemaining() > 0 then return false end

  local shouldAoe = Combat:GetEnemiesWithinDistance(25) > 1
  if Spell.Dragonrage:CooldownRemaining() <= 15000 and not shouldAoe then return false end

  local enemyCount = #enemy:GetUnitsAround(12)
  local empowerLevel = math.ceil(enemyCount / 2)

  if spell.IsUsable and not Me:IsMoving() then
    Spell.ShatteringStar:CastEx(enemy)
  end

  if spell:CastEx(enemy) then
    empowerWanted = empowerLevel
    return true
  end
end

local function FireBreath(enemy)
  local spell = Spell.FireBreath
  local spelldata = WoWSpell(spell.OverrideId)
  if spelldata:CooldownRemaining() > 0 then return false end

  local shouldAoe = Combat:GetEnemiesWithinDistance(25) > 1
  if Spell.Dragonrage:CooldownRemaining() <= 10000 and not shouldAoe then return false end

  local enemiesAround = #enemy:GetUnitsAround(10)
  local empowerLevel = 1

  if enemiesAround >= 5 then
    Spell.TipTheScales:CastEx(Me)
    empowerLevel = 4
  elseif enemiesAround == 4 then
    empowerLevel = 3
  elseif enemiesAround == 3 then
    empowerLevel = 2
  end

  if spell:CastEx(Me) then
    empowerWanted = empowerLevel
    return true
  end
end

local function Dragonrage()
  local spell = Spell.Dragonrage
  if spell:CooldownRemaining() > 0 then return false end

  local shouldAoe = Combat:GetEnemiesWithinDistance(25) > 1
  local breathReady = WoWSpell(Spell.FireBreath.OverrideId):CooldownRemaining() == 0
  local surgeReady = WoWSpell(Spell.EternitySurge.OverrideId):CooldownRemaining() == 0

  if shouldAoe then
    return spell:CastEx(Me)
  else
    return breathReady and surgeReady and spell:CastEx(Me)
  end
end

local function DeepBreath(enemy)
  local spell = Spell.DeepBreath
  if spell:CooldownRemaining() > 0 then return false end

  local enemiesAround = #enemy:GetUnitsAround(10)
  return enemiesAround >= 2 and spell:CastEx(enemy)
end

local function Pyre(enemy)
  local spell = Spell.Pyre
  if not spell.IsUsable then return false end

  local enemiesAround = #enemy:GetUnitsAround(8)
  local eb = Me:GetAura(auras.essenceburst)

  if eb and enemiesAround >= 3 and spell:CastEx(enemy) then return true end

  return enemiesAround > 4 and spell:CastEx(enemy)
end

local function Disintegrate(enemy)
  local spell = Spell.Disintegrate
  if not spell.IsUsable then return false end

  return spell:CastEx(enemy)
end

local function LivingFlame(enemy)
  local spell = Spell.LivingFlame

  return spell:CastEx(enemy)
end

local function AzureStrike(enemy)
  local spell = Spell.AzureStrike

  local enemiesAround = #enemy:GetUnitsAround(8)

  return (enemiesAround >= 3 or Me:IsMoving()) and spell:CastEx(enemy)
end

local function EmpowerHandler()
  local empowerLevel = common:GetEmpowerLevel()
  local empowerDone = empowerWanted > 0 and empowerLevel >= empowerWanted

  if empowerDone then
    local currentSpell = WoWSpell(Me.CurrentSpell.Id)

    if currentSpell.Id == Spell.EternitySurge.OverrideId then
      currentSpell = Spell.EternitySurge
    elseif currentSpell.Id == Spell.FireBreath.OverrideId then
      currentSpell = Spell.FireBreath
    end

    currentSpell:Cast(Me)
    empowerWanted = 0
  end
end

local function EvokerDevastation()
  EmpowerHandler()

  local GCD = wector.SpellBook.GCD
  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end

  if Me.HealthPct < 80 and Spell.ObsidianScales:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end

  if Dragonrage() then return end
  if FireBreath(target) then return end
  if EternitySurge(target) then return end
  if DeepBreath(target) then return end
  if Pyre(target) then return end
  if Disintegrate(target) then return end
  if AzureStrike(target) then return end
  if LivingFlame(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = EvokerDevastation
}

return { Options = options, Behaviors = behaviors }
