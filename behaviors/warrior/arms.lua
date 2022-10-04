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
    if Me:HasVisibleAura("Bladestorm") then return end

    -- Execute
    if Spell.Execute:CastEx(target) then return end

    -- Overpower
    if Spell.Overpower:CastEx(target) then return end

    local hamstring = target:GetAura("Hamstring")
    local freedom = target:GetAura("Hand of Freedom")
    local crip = target:GetAura("Crippling Poison")
    if target.IsPlayer and not hamstring and not freedom and not crip and Spell.Hamstring:CastEx(target) then return end

    -- Sweeping Strikes
    if aoe and Spell.SweepingStrikes:CastEx(Me) then return end

    if Spell.BloodFury:CastEx(Me) then return end

    common:UseTrinkets()

    -- Bladestorm
    if Me:HasBuffByMe("Sweeping Strikes") and Me:InMeleeRange(target) and Spell.Bladestorm:CastEx(Me) then return end

    -- Mortal Strike, make sure we cast blood thirst if ready before continuing
    if Spell.MortalStrike:CastEx(target) then return end

    common:DoShout()

    if not target:HasDebuffByMe("Rend") and Spell.Rend:CastEx(target) then return end

    -- Victory Rush
    if Spell.VictoryRush:CastEx(target) then return end

    -- Whirlwind
    if Spell.Whirlwind:CastEx(target) then return end

    -- Revenge
    if Spell.Revenge:CastEx(target) then return end

    -- Shield Slam
    if Spell.ShieldSlam:CastEx(target) then return end

    -- Heroic Strike/Cleave
    if Spell.Cleave.IsKnown then
      local hs_or_cleave = aoe and Spell.Cleave or Spell.HeroicStrike
      if Me.PowerPct > Settings.WarriorArmsFiller and hs_or_cleave:CastEx(target) then return end
    else
      if Me.PowerPct > Settings.WarriorArmsFiller and Spell.HeroicStrike:CastEx(target) then return end
    end
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorArmsCombat
}

return { Options = options, Behaviors = behaviors }
