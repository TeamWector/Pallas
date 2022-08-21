local options = {
  -- The sub menu name
  Name = "Deathknight (Blood)",
   -- widgets
  Widgets = {
    
  }
}

local spells = {
  BloodStrike = WoWSpell("Blood Strike"),
  IcyTouch = WoWSpell("Icy Touch"),
  PlagueStrike = WoWSpell("Plague Strike"),
  DeathCoil = WoWSpell("Death Coil"),
}

local RuneTypes = {
  Blood = 0,
  Unholy = 1,
  Frost = 2
}

local function getRuneCount(runeType) 
  local count = 0
  for i=0,5 do 
    if Me:GetRuneType(i) == runeType and Me:GetRuneCooldown(i) == 0 then
       count = count + 1
    end
  end
  return count
end

local function DeathknightBlood()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1
  
    -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- frost fever and icy touch
  local frostFever = target:GetAura("Frost Fever")
  
  if not frostFever or frostFever.Remaining < 2 * 1000 then
    spells.IcyTouch:CastEx(target)
    return
  end

  -- blood plague and plague strike
  local bloodPlague = target:GetAura("Blood Plague") 

  if not bloodPlague or bloodPlague.Remaining < 2 * 1000 then
    print('bloodPlague ending, castingerrooo')
    spells.PlagueStrike:CastEx(target)
    return
  end

  if Me:GetPowerByType(PowerType.RunicPower) > 50 and spells.DeathCoil:CastEx(target) then return end

  -- blood strike spam red runes away
  if spells.BloodStrike:CastEx(target) then return end


  -- here we get lazy to spend 1 rune of unholy
  -- doesnt actually work, thinks we have 2 runes when we have 1, after it goes inside once.
  if getRuneCount(RuneTypes.Unholy) > 1 then
    spells.PlagueStrike:CastEx(target)
    return
  end

end

local behaviors = {
  [BehaviorType.Combat] = DeathknightBlood
}

return { Options = options, Behaviors = behaviors }
