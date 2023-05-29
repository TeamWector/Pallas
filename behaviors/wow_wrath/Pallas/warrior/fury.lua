local common = require('behaviors.wow_wrath.Pallas.warrior.common')

local options = {
  -- The sub menu name
  Name = "Warrior (Fury)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "WarriorFurySweeping",
      text = "Use Sweeping Strikes",
      default = true
    },
    {
      type = "checkbox",
      uid = "WarriorFuryExecute",
      text = "Use Execute",
      default = false
    },
    {
      type = "slider",
      uid = "WarriorFuryFiller",
      text = "Use filler (HS/Cleave) Rage%",
      default = 65,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "WarriorFuryPool",
      text = "Pool rage%",
      default = 35,
      min = 0,
      max = 100
    },
  }
}
for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function WarriorFuryCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  common:DoInterrupt()
  common:DoShout()

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- Sunder bosses and throw shattering throw
  local sunder = target:GetVisibleAura("Sunder Armor")
  if not target:HasVisibleAura("Expose Armor") and
      (target.Classification == 3 or (target.Classification == 1 and target.Level == 82)) and
      (not sunder or (sunder.Stacks < 5 or sunder.Remaining < 3000)) and Spell.SunderArmor:CastEx(target) then return end
  if (target.Classification == 3 or (target.Classification == 1 and target.Level == 82)) and sunder and
      sunder.Stacks == 5 and not target:HasVisibleAura("Shattering Throw") and Spell.ShatteringThrow:CastEx(target) then return end

  if Spell.BloodFury:CastEx(Me) then return end
  common:UseTrinkets()

  if Me.Level < 40 and not target:HasVisibleAura("Rend") and Spell.Rend:CastEx(target) then return end

  -- pool rage
  if Me.PowerPct < Settings.WarriorFuryPool then return end

  -- Sweeping Strikes
  if aoe and Settings.WarriorFurySweeping and Spell.SweepingStrikes:CastEx(Me) then return end

  if Me:IsFacing(target) then
    -- Heroic Strike/Cleave
    local hs_or_cleave = aoe and Spell.Cleave or Spell.HeroicStrike
    if Me.PowerPct > Settings.WarriorFuryFiller and hs_or_cleave:CastEx(target) then return end

    if aoe then
      if Spell.Bloodthirst:CastEx(target) then return end
      if Spell.Whirlwind:CastEx(target) then return end
    else
      if Spell.Whirlwind:CastEx(target) then return end
      if Spell.Bloodthirst:CastEx(target) then return end
    end

    -- Execute
    if Settings.WarriorFuryExecute and Spell.Execute:CastEx(target) then return end

    if Me:HasVisibleAura("Slam!") and Spell.Slam:CastEx(target) then return end

    -- Victory Rush
    if Spell.VictoryRush:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
