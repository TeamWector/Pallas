local common = require("behaviors.wow_retail.Pallas.priest.common")
local options = {
}

local spells = {
  mindflayv2 = 391403
}

local function PriestShadow()
  if Me.IsMounted then return end

  if Me.IsCastingOrChanneling and Me:GetSpellCast() ~= Spell.MindFlay then return end

  if Spell.Shadowform:Apply(Me) then return end
  if Spell.PowerWordShield:Apply(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  if common:ShadowWordDeath() then return end
  if Spell.DarkAscension:CastEx(Me) then return end
  if Spell.PowerInfusion:CastEx(Me) then return end
  if Spell.Halo:CastEx(Me) then return end
  if Spell.Mindgames:CastEx(target) then return end
  --if Spell.Mindbender:CastEx(target) then return end -- Will report as having it even if you dont have it...
  if Combat:GetTargetsAround(target, 10) > 1 and not target:IsMoving() and Spell.ShadowCrash:CastEx(target) then return end
  for _, t in pairs(Combat.Targets) do
    if Spell.VampiricTouch:Apply(t) then return end
    if Spell.DevouringPlague:Apply(t) then return end
  end
  if Spell.VoidTorrent:CastEx(target) then return end
  if Spell.MindSpikeInsanity:CastEx(target) then return end
  if Spell.MindBlast:CastEx(target) then return end
  if Spell.MindFlay:CastEx(target) then return end
  if Spell.MindSpike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = PriestShadow
}

return { Options = options, Behaviors = behaviors }
