local common = require("behaviors.wow_retail.Pallas.evoker.common")

local options = {
  Name = "Evoker (Initial)",
  Widgets = {
    {
      type = "text",
      uid = "EvokerInitialText",
      text = ">> Initial <<",
    },
  }
}

local empowerWanted = 0

local function FireBreath()
  if Spell.FireBreath:CastEx(Me) then
    empowerWanted = 4
    return true
  end
end

local function EvokerInitial()
  local empowerLevel = common:GetEmpowerLevel()
  local empowerDone = empowerWanted > 0 and empowerLevel == empowerWanted

  if empowerDone then
    local currentSpell = WoWSpell(Me.CurrentSpell.Id)

    currentSpell:Cast(Me)
    empowerWanted = 0
  end

  local GCD = wector.SpellBook.GCD

  if Me.IsCastingOrChanneling or GCD:CooldownRemaining() > 0 then return end

  if Me.Target and not Me:CanAttack(Me.Target) and Me.Target.HealthPct < 100 then
    if Spell.LivingFlame:CastEx(Me.Target) then return end
  end

  if Me.HealthPct < 80 and Spell.EmeraldBlossom:CastEx(Me) then return end
  if Me.HealthPct < 60 and Spell.LivingFlame:CastEx(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  local TTD = target:TimeToDeath()

  if TTD > 6 and FireBreath() then return end
  if TTD > 6 and Spell.Disintegrate:CastEx(target) then return end
  if Spell.LivingFlame:CastEx(target) then return end
  if Spell.AzureStrike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = EvokerInitial
}

return { Options = options, Behaviors = behaviors }
