local common = require("behaviors.wow_retail.priest.common")
local options = {
}

local spells = {
  mindflayv2 = 391403
}

local function PriestShadow()
  if Me.IsMounted then return end

  if Me:GetSpellCast().Id == spells.mindflayv2 then return end

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
  if not target:IsMoving() and Spell.ShadowCrash:CastEx(target) then return end
  for _, t in pairs(Combat.Targets) do
    if Spell.VampiricTouch:Apply(t) then return end
    if Spell.DevouringPlague:Apply(t) then return end
  end
  if Spell.MindBlast:CastEx(target) then return end
  if Spell.MindFlay:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = PriestShadow
}

return { Options = options, Behaviors = behaviors }
