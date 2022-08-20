local common = require('behaviors.warrior.common')

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

local spells = common.spells

local function WarriorFuryCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  common:DoInterrupt()
  common:DoShout()

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- Victory Rush
  if spells.VictoryRush:CastEx(target) then return end

  -- pool rage
  if Me.PowerPct < Settings.WarriorFuryPool then return end

  -- Rampage
  local rampage = Me:GetVisibleAura("Rampage")
  if (not rampage or rampage.Remaining < 5000) and spells.Rampage:CastEx(target) then return end

  -- Sweeping Strikes
  if aoe and Settings.WarriorFurySweeping and spells.SweepingStrikes:CastEx(Me) then return end

  -- Blood Thirst, make sure we cast blood thirst if ready before continuing
  if spells.BloodThirst:CastEx(target) then return end

  -- Whirlwind
  if spells.Whirlwind:CastEx(target) then return end

  -- Heroic Strike/Cleave
  local hs_or_cleave = aoe and spells.Cleave or spells.HeroicStrike
  if Me.PowerPct > Settings.WarriorFuryFiller and hs_or_cleave:CastEx(target) then return end

  -- Execute
  if Settings.WarriorFuryExecute and spells.Execute:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
