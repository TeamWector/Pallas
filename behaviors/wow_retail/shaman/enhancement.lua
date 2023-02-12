local common = require('behaviors.wow_retail.shaman.common')

local options = {
  -- The sub menu name
  Name = "Shaman (Enhancement)",

  -- widgets
  Widgets = {
    {
      type = "slider",
      uid = "ShamanAstralShift",
      text = "Use Astral Shift below HP%",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "ShamanAOEtargets",
      text = "USE AOE Rotation if targets are more than",
      default = 3,
      min = 1,
      max = 10
    },
    {
      type = "checkbox",
      uid = "ShamanUseCooldowns",
      text = "Allow the usage of Big Cooldowns",
      default = true
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function ShamanEnhancementCombat()
    local windfuryTotem = WoWSpell(8512)
    local lavaLash = WoWSpell(60103)
    local sundering = WoWSpell(197214)

    local maelstrom = Me:GetAura(344179)
    local hotHand = Me:GetAura(215785)
    local ashenCatalyst = Me:GetAura(390371)
    local feralSpirit = Me:GetAura(333957)
    local maelstromOfElements = Me:GetAura(394677)
    local hailStorm = Me:GetAura(384357)

    if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
    local target = Combat.BestTarget
    if not target then return end
    if not Me:IsFacing(target) then return end
    if Me.IsCastingOrChanneling then return end
    if not Settings.PallasAttackOOC then return end
   
    if Me.HealthPct <= Settings.ShamanAstralShift and Spell.AstralShift:CooldownRemaining() == 0 then	
		if Spell.AstralShift:CastEx(Me) then return end
	end

    if (Spell.FeralSpirit:GetCooldown() == 0 or (feralSpirit and feralSpirit.Remaining > 8000 )) then
        common:UseTrinkets()
    end
    
    
    if Spell.FeralSpirit:CastEx(target) then return end
    
   
    if(hotHand or (ashenCatalyst and ashenCatalyst.Stacks >= 7)) then
        if Spell.LavaLash:CastEx(target) then return end
    end

    if not Me:GetVisibleAura(327942) then
        if windfuryTotem:CastEx(Me) then return end
    end

    if #target:GetUnitsAround(5) >= Settings.ShamanAOEtargets then
        if Spell.CrashLightning:CastEx(Me) then return end
    end

    if Spell.PrimordialWave:CastEx(target) then return end

    if not target:HasAura(188389) then
        
        if Spell.FlameShock:CastEx(target) then return end
    end

    if (maelstrom and maelstrom.Stacks >= 8 and Me:GetAura(375986)) then
        if #target:GetUnitsAround(5) <= Settings.ShamanAOEtargets then
            if Spell.LightningBolt:CastEx(target) then return end
        else
            if Spell.ChainLightning:CastEx(target) then return end
        end
    end

    
    if ((maelstrom and maelstrom.Stacks >= 8 and Spell.ElementalBlast.Charges > 1) or (feralSpirit and Spell.ElementalBlast.Charges > 0)) then
        if Spell.ElementalBlast:CastEx(target) then return end
    end

    if (maelstrom and maelstrom.Stacks >= 5 and Spell.ElementalBlast.Charges > 0) then
        if Spell.ElementalBlast:CastEx(target) then return end
    end
    
    if Spell.IceStrike:CastEx(target) then return end
    
    if(not maelstromOfElements and maelstrom and maelstrom.Stacks >=5 and Spell.Stormstrike.Charges > 0 ) then
        
        if Spell.Stormstrike:CastEx(target) then return end
    end

    if Spell.Sundering:CastEx(Me) then return end

    if(maelstrom and maelstrom.Stacks == 10) then
        if #target:GetUnitsAround(5) <= Settings.ShamanAOEtargets then
            if Spell.LightningBolt:CastEx(target) then return end
        else
            if Spell.ChainLightning:CastEx(target) then return end
        end
    end

    if hailStorm then
        if Spell.FrostShock:CastEx(target) then return end
    end

    if (target:HasDebuffByMe("Flame Shock") and target:GetAuraByMe("Flame Shock").Remaining < 5000 ) then
        if Spell.LavaLash:CastEx(target) then return end
    end
    
    if Spell.LavaLash:CastEx(target) then return end
    
   

    if (maelstrom and maelstrom.Stacks >= 5) then
        if #target:GetUnitsAround(5) <= Settings.ShamanAOEtargets then
            if Spell.LightningBolt:CastEx(target) then return end
        else
            if Spell.ChainLightning:CastEx(target) then return end
        end
    end

    
    if Spell.FrostShock:CastEx(target) then return end
    if Spell.CrashLightning:CastEx(Me) then return end
    
    if Spell.Stormstrike:CastEx(target) then return end
    print("------ Nothing more in Prio - Casting Flame Shock!! --------")
    if Spell.FlameShock:CastEx(target) then return end
    
    if not Me:InMeleeRange(target) and Me:IsFacing(target) then
        if Spell.LightningBolt:CastEx(target) then return end
        if Spell.FlameShock:CastEx(target) then return end
        if Spell.FrostShock:CastEx(target) then return end
      end
end

local behaviors = {
    [BehaviorType.Combat] = ShamanEnhancementCombat
  }
  
  return { Options = options, Behaviors = behaviors }