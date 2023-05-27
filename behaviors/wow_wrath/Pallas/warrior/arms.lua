local common = require('behaviors.wow_wrath.warrior.common')

local options = {
  -- The sub menu name
  Name = "Warrior (Arms)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "WarriorArmsUnrelentingProt",
      text = "Unrelenting Assault Tank",
      default = false
    },
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

function WarriorArmsProt()
  local target = Tank.BestTarget
  if not target then return end

  --if Me.Target and not Me:IsAttacking() then
  --  Me:StartAttack(Me.Target)
  --end

  local shockwaveUnits = 0
  local unitsInMelee = 0
  for _, v in pairs(Tank.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit
    if Me:IsFacing(u) and Spell.Shockwave:InRange(u) then
      shockwaveUnits = shockwaveUnits + 1
    end
    if Me:InMeleeRange(u) then
      unitsInMelee = unitsInMelee + 1
    end
  end

  local aoe = unitsInMelee > 2

  local sr = common:DoInterrupt()

  -- debuff
  local ds = true
  local tc = true
  local units = wector.Game.Units
  for _, u in pairs(units) do
    if Spell.ThunderClap:InRange(u) then
      if u:HasAura("Polymorph") or u:HasAura("Sap") or u:HasAura("Blind") or u:HasAura("Shackle Undead") then
        tc = false
        aoe = false
      end
    end
  end

  -- Shout
  common:DoShout()

  for _, v in pairs(Tank.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit

    if u:HasAura("Demoralizing Shout") then
      ds = false
    end

    -- Sweeping Strikes
    if aoe and Spell.SweepingStrikes:CastEx(Me) then return end

    -- Spell Reflection
    if sr and Me.PowerPct > 45 and Spell.SpellReflection:CastEx(u) then return end

    -- Shield Block
    if Me.HealthPct < 55 and Spell.ShieldBlock:CastEx(u) then return end

    -- only melee spells from here on
    if not Me:InMeleeRange(u) or not Me:IsFacing(u) then goto continue end

    -- Heroic Strike/Cleave
    if Spell.Cleave.IsKnown then
      local hs_or_cleave = aoe and Spell.Cleave or Spell.HeroicStrike
      if Me.PowerPct > Settings.WarriorArmsFiller and hs_or_cleave:CastEx(u) then return end
    else
      if Me.PowerPct > Settings.WarriorArmsFiller and Spell.HeroicStrike:CastEx(u) then return end
    end

    -- Revenge
    if Spell.Revenge:CastEx(u) then return end

    -- Shield Slam
    if Spell.MortalStrike:CastEx(u) then return end

    -- Thunder Clap
    if (tc or aoe) and Spell.ThunderClap:CastEx(u) then return end

    -- Shield Slam
    if Spell.ShieldSlam:CastEx(u) then return end

    -- Demoralizing Shout
    if Settings.WarriorCommonDemo and ds and Spell.DemoralizingShout:CastEx(u) then return end

    -- Devastate
    local sunders = u:GetAura("Sunder Armor")
    if ((not sunders or (sunders.Stacks < 5 or sunders.Remaining < 4000)) or Me.PowerPct > 35) and
        Spell.SunderArmor:CastEx(u) then return end

    ::continue::
  end
end

local function WarriorArmsCombat()
  if Settings.WarriorArmsUnrelentingProt then
    WarriorArmsProt()
    return
  end

  local target = Combat.BestTarget
  if not target then return end
  if target.Name == "Risen Zombie" then return end

  --Me:StartAttack(target)

  local aoe = Combat.EnemiesInMeleeRange > 1

  if target:HasVisibleAura("Blessing of Protection") or target:HasVisibleAura("Divine Shield") or
      target:HasVisibleAura("Ice Block") then
    return
  end

  --if not Me:IsAttacking(target) then
  --  Me:StartAttack(target)
  --end

  common:DoInterrupt()

  if Me:IsFacing(target) then
    if Me:HasVisibleAura("Bladestorm") then return end

    -- Rend
    if not target:HasDebuffByMe("Rend") and Spell.Rend:CastEx(target) then return end

    -- Sunder bosses and throw shattering throw
    local sunder = target:GetVisibleAura("Sunder Armor")
    if (target.Classification == 3 or (target.Classification == 1 and target.Level == 82)) and
        (not sunder or (sunder.Stacks < 5 or sunder.Remaining < 3000)) and Spell.SunderArmor:CastEx(target) then return end
    if (target.Classification == 3 or (target.Classification == 1 and target.Level == 82)) and sunder and
        sunder.Stacks == 5 and not target:HasVisibleAura("Shattering Throw") and Spell.ShatteringThrow:CastEx(target) then return end

    -- Execute
    if Spell.Execute:CastEx(target) then return end

    -- Overpower
    if Spell.Overpower:CastEx(target) then return end

    local hamstring = target:GetAura("Hamstring")
    local freedom = target:GetAura("Hand of Freedom")
    local crip = target:GetAura("Crippling Poison")
    if target.IsPlayer and not hamstring and not freedom and not crip and Spell.Hamstring:CastEx(target) then return end

    -- Sweeping Strikes
    --if aoe and Spell.SweepingStrikes:CastEx(Me) then return end

    if Spell.BloodFury:CastEx(Me) then return end

    common:UseTrinkets()

    -- Bladestorm
    if Me:HasBuffByMe("Sweeping Strikes") and Me:InMeleeRange(target) and target:TimeToDeath() > 10 and
        Spell.Bladestorm:CastEx(Me) then return end

    -- Mortal Strike, make sure we cast blood thirst if ready before continuing
    if Spell.MortalStrike:CastEx(target) then return end

    common:DoShout()

    -- Victory Rush
    if Spell.VictoryRush:CastEx(target) then return end

    -- Whirlwind
    if Spell.Whirlwind:CastEx(target) then return end

    -- Revenge
    if Spell.Revenge:CastEx(target) then return end

    -- Shield Slam
    if Spell.ShieldSlam:CastEx(target) then return end

    -- Shield Slam
    if Me.PowerPct > 40 and not target:HasVisibleAura("Thunder Clap") and Spell.ThunderClap:CastEx(target) then return end

    -- Shield Slam
    if Me.PowerPct > 50 and not Me:IsMoving() and Spell.Slam:CastEx(target) then return end

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
  [BehaviorType.Combat] = WarriorArmsCombat,
  [BehaviorType.Tank] = WarriorArmsCombat
}

return { Options = options, Behaviors = behaviors }
