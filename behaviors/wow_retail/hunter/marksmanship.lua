local common = require('behaviors.wow_retail.hunter.common')

local options = {
  -- The sub menu name
  Name = "Hunter (Marksmann)",

  -- widgets
  Widgets = {
    {
       type = "slider",
      uid = "HunterAspectoftheTurtle",
      text = "Use Aspect of the Turtle below HP%",
      default = 25,
      min = 0,
      max = 100
    },
    {
     type = "slider",
      uid = "HunterSurvivaloftheFittest",
      text = "Use Survival of the Fittest below HP%",
      default = 40,
      min = 0,
      max = 100
	},
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function HunterMarksmanshipCombat()


  local target = Combat.BestTarget

  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end

  if Me.IsCastingOrChanneling then return end

  if #target:GetUnitsAround(10) < 2 then
    common:UseTrinkets()
    if Spell.AimedShot.Charges > 1 and Spell.AimedShot:CooldownRemaining() > 3000 then
        if Spell.AimedShot:CastEx(target) then return end
    end

    if Spell.SteelTrap:CastEx(target) then return end
    if Spell.Trueshot:CastEx(target) then return end
    if Spell.KillShot:CastEx(target) then return end
    if Spell.RapidFire:CastEx(target) then return end
    if Spell.AimedShot:CastEx(target) then return end
    if Me:GetPowerByType(PowerType.Focus) > 55 then
        if Spell.ArcaneShot:CastEx(target) then return end
    end
    if Spell.SteadyShot:CastEx(target) then return end
  end

  if #target:GetUnitsAround(10) >= 2 then
    common:UseTrinkets()
    if Spell.Trickshots.isKnown and not Me:GetAura(257622) then
      if Spell.Multishot:CastEx(target) then return end
    end
    if Spell.SteelTrap:CastEx(target) then return end
    if Spell.Trueshot:CastEx(target) then return end
    if Spell.KillShot:CastEx(target) then return end
    if Spell.RapidFire:CastEx(target) then return end
    if Spell.DeathChakram:CastEx(target) then return end
    if Spell.ExplosiveShot:CastEx(target) then return end
    if Spell.AimedShot:CastEx(target) then return end
  end

end


local behaviors = {
    [BehaviorType.Combat] = HunterMarksmanshipCombat
  }
  
  return { Options = options, Behaviors = behaviors }