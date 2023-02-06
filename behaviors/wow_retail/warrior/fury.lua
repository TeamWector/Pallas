local common = require('behaviors.wow_retail.warrior.common')

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

  -- only melee spells from here on
  if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

  if Me.HealthPct < 60 then
    if Spell.ImpendingVictory:CastEx(target) then return end
    if Spell.VictoryRush:CastEx(target) then return end
  end

  if Combat.EnemiesInMeleeRange > 1 then
    if not Me:HasVisibleAura("Whirlwind") and Spell.Whirlwind:CastEx(target) then return end
  end

  if Spell.Execute:CastEx(target) then return end
  if Spell.Rampage:CastEx(target) then return end
  if Spell.RagingBlow:CastEx(target) then return end
  if Spell.Bloodbath:CastEx(target) then return end
  if Spell.Bloodthirst:CastEx(target) then return end
  if Spell.Whirlwind:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
