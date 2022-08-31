local common = require('behaviors.warrior.common')

local options = {
  -- The sub menu name
  Name = "Warrior (Arms)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "WarriorArmsExecute",
      text = "Use Execute",
      default = false
    },
    {
      type = "slider",
      uid = "WarriorArmsPool",
      text = "Pool rage%",
      default = 35,
      min = 0,
      max = 100
    },
    {
      type = "slider",
      uid = "WarriorArmsFiller",
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

local spells = common.spells

local function WarriorArmsCombat()
  local target = Combat.BestTarget
  if not target then return end

  --Me:StartAttack(target)

  local aoe = Combat.EnemiesInMeleeRange > 1

  if target:HasVisibleAura("Blessing of Protection") or target:HasVisibleAura("Divine Shield") or target:HasVisibleAura("Ice Block") then
    return
  end

  --if not Me:IsAttacking(target) then
  --  Me:StartAttack(target)
  --end

  common:DoInterrupt()

  if Me:IsFacing(target) then
    -- Execute
    if spells.Execute:CastEx(target) then return end

    -- Overpower
    if spells.Overpower:CastEx(target) then return end

    local hamstring = target:GetAura("Hamstring")
    local freedom = target:GetAura("Blessing of Freedom")
    local crip = target:GetAura("Crippling Poison")
    if target.IsPlayer and not hamstring and not freedom and not crip and spells.Hamstring:CastEx(target) then return end

    -- Mortal Strike, make sure we cast blood thirst if ready before continuing
    if spells.MortalStrike:CastEx(target) then return end

    common:DoShout()

    if not target:HasDebuffByMe("Rend") and spells.Rend:CastEx(target) then return end

    -- Sweeping Strikes
    if aoe and spells.SweepingStrikes:CastEx(Me) then return end

    -- Victory Rush
    if spells.VictoryRush:CastEx(target) then return end

    -- Whirlwind
    if spells.Whirlwind:CastEx(target) then return end

    -- Heroic Strike/Cleave
    if Me.PowerPct > Settings.WarriorArmsFiller and spells.HeroicStrike:CastEx(target) then return end
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorArmsCombat
}

return { Options = options, Behaviors = behaviors }
