local options = {
  -- The sub menu name
  Name = "Deathknight (Unholy)",
  -- widgets
  Widgets = {

  }
}

local spells = {
  BloodStrike = WoWSpell("Blood Strike"),
  IcyTouch = WoWSpell("Icy Touch"),
  PlagueStrike = WoWSpell("Plague Strike"),
  DeathCoil = WoWSpell("Death Coil"),
  RaiseDead = WoWSpell("Raise Dead"),
  BoneShield = WoWSpell("Bone Shield"),
  GhoulFrenzy = WoWSpell("Ghoul Frenzy"),
  DeathAndDecay = WoWSpell("Death and Decay"),
  ArmyOfTheDead = WoWSpell("Army of the Dead"),
  HornOfWinter = WoWSpell("Horn of Winter"),
  BloodTap = WoWSpell("Blood Tap"),
  SummonGargoyle = WoWSpell("Summon Gargoyle"),
  EmpowerRuneWeapon = WoWSpell("Empower Rune Weapon"),
  UnholyPresence = WoWSpell("Unholy Presence"),
  BloodPresence = WoWSpell("Blood Presence"),
  BloodBoil = WoWSpell("Blood Boil"),
  Pestilence = WoWSpell("Pestilence")
}

local RuneTypes = {
  Blood = 0,
  Unholy = 1,
  Frost = 2
}

local function getRuneCount(runeType)
  local count = 0
  for i = 0, 5 do
    if Me:GetRuneType(i) == runeType and Me:GetRuneCooldown(i) == 0 then
      count = count + 1
    end
  end
  return count
end

local function DeathknightUnholy()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  -- TBC UNTESTED - I'll come back to this at 70 and optimisation
  -- if Me:HasBuff("Unholy Presence") then
  --   spells.UnholyPresence:CastEx(Me)
  -- end

  if (not Me.Pet or Me.Pet.Dead) and spells.RaiseDead:CastEx(Me) then return end

  -- Only do this when pet is active
  if Me.Pet then
    -- Pet Attack my target
    --if Me.Pet.Target ~= Me.Target then
      Me:PetAttack(target)
    --end
  end

  if not Me:HasBuff("Blood Presence") and spells.BloodPresence:CastEx(Me) then return end

  -- local hornOfWinter = Me:GetAura("Horn of Winter")

  -- if not hornOfWinter or hornOfWinter.Remaining < 10000 then
  --   spells.HornOfWinter:CastEx(Me)
  --   return
  -- end

  if spells.BloodTap:CastEx(Me) then return end

  if not Me:HasBuff("Bone Shield") and spells.BoneShield:CastEx(Me) then return end

  -- BURST for laziness both gargoyle and empower rune wep
  if spells.SummonGargoyle:CastEx(target) then return end
  if spells.EmpowerRuneWeapon:CastEx(Me) then return end

  if Me.Power > 50 and spells.DeathCoil:CastEx(target) then return end

  -- frost fever and icy touch
  local frostFever = target:GetAura("Frost Fever")
  if (not frostFever or frostFever.Remaining < 2 * 1000) and spells.IcyTouch:CastEx(target) then return end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- blood plague and plague strike
  local bloodPlague = target:GetAura("Blood Plague")
  if (not bloodPlague or bloodPlague.Remaining < 2 * 1000) then spells.PlagueStrike:CastEx(target) return end

  -- local desolation = Me:GetAura("Desolation")

  --if not desolation or desolation.Remaining < 2*1000 then
  -- if not desolation then
  --   print(desolation.Remaining)
  --   spells.BloodStrike:CastEx(target)
  --   return
  -- end

  if aoe and spells.Pestilence:CastEx(target) then return end

  if spells.BloodTap:CastEx(Me) then return end

  if spells.DeathAndDecay:CastEx(Me.Position) then return end

  if Me.Pet then
    local petGhoulFrenzy = Me.Pet:GetAura("Ghoul Frenzy")
    if not petGhoulFrenzy or petGhoulFrenzy.Remaining < 10000 and spells.GhoulFrenzy:CastEx(target) then return end
  end

  if spells.IcyTouch:CastEx(target) then return end

  if spells.PlagueStrike:CastEx(target) then return end

  if aoe then
    if spells.Pestilence:CastEx(target) then return end
  else
    if spells.BloodBoil:CastEx(target) then return end
  end

end

local behaviors = {
  [BehaviorType.Combat] = DeathknightUnholy
}

return { Options = options, Behaviors = behaviors }
