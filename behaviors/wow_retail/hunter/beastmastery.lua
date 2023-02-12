local common = require('behaviors.wow_retail.hunter.common')

local options = {
  -- The sub menu name
  Name = "Hunter (Beast Mastery)",

  -- widgets
  Widgets = {
    {
       type = "slider",
      uid = "HunterAspectoftheTurtlePercent",
      text = "Use Aspect of the Turtle below HP%",
      default = 25,
      min = 0,
      max = 100
    },
    {
     type = "slider",
      uid = "HunterSurvivaloftheFittestPercent",
      text = "Use Survival of the Fittest below HP%",
      default = 40,
      min = 0,
      max = 100
	},
    {
      type = "slider",
      uid = "HunterFortitudeoftheBearPercent",
      text = "Use Fortitude of the Bear below HP%%",
      default = 65,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "HunterAOEtargets",
      text = "USE AOE Rotation if targets are more than",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "checkbox",
      uid = "HunterUseCooldowns",
      text = "Allow the usage of Big Cooldowns",
      default = true
    },
    {
      type = "combobox",
      uid = "HunterPetChoice",
      text = "Select your Pet",
      default = 0,
      options = { "No Pet", "Pet 1", "Pet 2", "Pet 3", "Pet 4", "Pet 5" }
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function PetAttack(target)
   
    Spell.Rake:CastEx(target)
    Spell.Claw:CastEx(target)
end


local function HunterBeastmasteryCombat()
  
  local fortitudeOfTheBear = WoWSpell(272679)

  if Me.Pet == nil then
    common:CallPet(HunterPetChoice)
  end
	
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
  local target = Combat.BestTarget
  if not target then return end
  if not Me:IsFacing(target) then return end
  if Me.IsCastingOrChanneling then return end
  if Settings.PallasAttackOOC then return end

  PetAttack(target)

  

  if Me.HealthPct <= Settings.HunterFortitudeoftheBearPercent and fortitudeOfTheBear:CooldownRemaining() < 1 then	
		if Spell.FortitudeOfTheBear:CastEx(Me) then return end
	end

  if Me.HealthPct <= Settings.HunterSurvivaloftheFittestPercent then	
		if Spell.SurvivalOfTheFittest:CastEx(Me) then return end
	end

  if Me.HealthPct <= Settings.HunterAspectoftheTurtlePercent then	
		if Spell.AspectOfTheTurtle:CastEx(Me) then return end
	end

  if #target:GetUnitsAround(5) <= Settings.HunterAOEtargets then
      if (not Me.Pet:GetAura(272790) or Me.Pet:GetAura(272790).Remaining < 2500 or Me.Pet:GetAura(272790).Stacks < 3)  then
        if Spell.BarbedShot:CastEx(target) then return end
      end
    
      if target.HealthPct > 20 then 
        if Spell.KillShot:CastEx(target) then return end
      end

      if (Spell.BestialWrath:CooldownRemaining() < 2000 or Spell.BestialWrath:CooldownRemaining() == 0) and Settings.HunterUseCooldowns then
        common:UseTrinkets()
        if Spell.BloodFury:CastEx(Me) then return end
        if Spell.Berserking:CastEx(Me) then return end
        if Spell.Fireblood:CastEx(Me) then return end
        if Spell.BestialWrath:CastEx(target) then return end
      end

      if (Settings.petChoice ~= 0 and Me.Pet:GetVisibleAura(272790) and Me.Pet:GetVisibleAura(272790).Stacks >= 2)  then
        if Spell.KillCommand:CastEx(target) then return end
      end

      if Spell.DireBeast:CastEx(target) then return end
      if Spell.BloodShed:CastEx(target) then return end
      if Spell.DeathChakram:CastEx(target) then return end
      if Spell.CobraShot:CastEx(target) then return end
    end

    if #target:GetUnitsAround(5) > Settings.HunterAOEtargets then
      if (Me.Pet ~= nil and (not Me.Pet:GetAura(272790) or Me.Pet:GetAura(272790).Remaining < 2500 or Me.Pet:GetAura(272790).Stacks < 3)) then
        if Spell.BarbedShot:CastEx(target) then return end
      end

      if (not Me:GetVisibleAura(268877) or Me:GetVisibleAura(268877).Remaining < 1500)  then
        if Spell.Multishot:CastEx(target) then return end
      end
    
      if target.HealthPct > 20 then 
        if Spell.KillShot:CastEx(target) then return end
      end

      if (Settings.petChoice ~= 0 and Me.Pet:GetVisibleAura(272790) and Me.Pet:GetVisibleAura(272790).Stacks >= 2)  then
        if Spell.KillCommand:CastEx(target) then return end
      end

      if Spell.BloodShed:CastEx(target) then return end
      if Spell.DeathChakram:CastEx(target) then return end

      if (Spell.BestialWrath:CooldownRemaining() < 2000 or Spell.BestialWrath:CooldownRemaining() == 0) and Settings.HunterUseCooldowns then
        common:UseTrinkets()
        if Spell.BloodFury:CastEx(Me) then return end
        if Spell.Berserking:CastEx(Me) then return end
        if Spell.Fireblood:CastEx(Me) then return end
        if Spell.BestialWrath:CastEx(target) then return end
      end

      if Spell.DireBeast:CastEx(target) then return end
      
      if Me.Pet ~= nil then
        if Me:GetPowerByType(PowerType.Focus) > 75 then
          if( Me.Pet:GetVisibleAura(272790).Remaining < 3500) then
            if Spell.CobraShot:CastEx(target) then return end  
          end
        end
      end
      
      if Me.Pet ~= nil then
        if Me.Pet:GetVisibleAura(272790) and Me.Pet:GetAura(272790).Remaining < 3500 then
          if Spell.WailingArrow:CastEx(target) then return end
        end
      end
      if Spell.CobraShot:CastEx(target) then return end  
    end
end

local behaviors = {
  [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }