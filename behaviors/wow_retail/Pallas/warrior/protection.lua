local common = require('behaviors.wow_retail.warrior.common')

--[[ !TODO
  - Better thunder clap + demo should logic
  - Shockwave is a cone but we check 180 degrees
]]

local options = {
  -- The sub menu name
  Name = "Warrior (Prot)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "WarriorProtUseLastStand",
      text = "Use Last Stand",
      default = false
    },
    {
      type = "slider",
      uid = "WarriorProtLastStandHP",
      text = "Last Stand HP%",
      default = 15,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "WarriorProtUseShieldWall",
      text = "Use Shield Wall",
      default = false
    },
    {
      type = "slider",
      uid = "WarriorProtShieldWallHP",
      text = "Shield Wall HP%",
      default = 25,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "WarriorProtTaunt",
      text = "Auto-Taunt",
      default = false
    },
    {
      type = "slider",
      uid = "WarriorProtFiller",
      text = "Use filler (HS) Rage%",
      default = 65,
      min = 0,
      max = 100
    },
  }
}
for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function WarriorProtCombat()
  local target = Combat.BestTarget
  if not target then return end

  if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

  --if Me.HealthPct < 70 then
  --  if Spell.ImpendingVictory:CastEx(target) then return end
  --  if Spell.VictoryRush:CastEx(target) then return end
  --end

  if Me:HasVisibleAura("Violent Outburst") and Spell.ShieldSlam:CastEx(target) then return end

  if Me:GetPowerByType(PowerType.Rage) > 50 then
    if Me.HealthPct < 90 and not Me:HasVisibleAura("Shield Block") and Spell.ShieldBlock:CastEx(Me) then return end
    local ignorepain = Me:GetVisibleAura("Ignore Pain")
    if (not ignorepain or ignorepain.Remaining < 3000) and Spell.IgnorePain:CastEx(Me) then return end
    if Spell.Revenge:CastEx(target) then return end
  end
  if Spell.ThunderClap:CastEx(target, SpellCastExFlags.NoRange) then return end
  if Spell.ShieldSlam:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorProtCombat
  --[BehaviorType.Combat] = WarriorProtCombat
}

return { Options = options, Behaviors = behaviors }
