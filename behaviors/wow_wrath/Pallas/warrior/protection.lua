local common = require('behaviors.wow_wrath.warrior.common')

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

  -- Last Stand
  if Settings.WarriorProtUseLastStand and Me.HealthPct < Settings.WarriorProtLastStandHP and Spell.LastStand:CastEx(Me) then return end

  -- Shield Wall
  if Settings.WarriorProtUseShieldWall and Me.HealthPct < Settings.WarriorProtShieldWallHP and
      Spell.ShieldWall:CastEx(Me) then return end

  -- Shockwave
  if shockwaveUnits > 0 and table.length(Tank.PriorityList) / shockwaveUnits > 0.8 and Spell.Shockwave:CastEx(Me) then return end

  -- Shout
  common:DoShout()

  for _, v in pairs(Tank.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit

    if u:HasAura("Demoralizing Shout") then
      ds = false
    end

    -- Taunt
    if Settings.WarriorProtTaunt then
      local threatentry = u:GetThreatEntry(Me.ToUnit)
      if threatentry.RawPct < 100 and Spell.Taunt:CastEx(u) then return end
    end

    -- Thunder Clap
    if (tc or aoe) and Spell.ThunderClap:CastEx(u) then return end

    -- only melee spells from here on
    if not Me:InMeleeRange(u) or not Me:IsFacing(u) then goto continue end

    -- Revenge
    if Spell.Revenge:CastEx(u) then return end

    -- Shield Slam
    if Spell.ShieldSlam:CastEx(u) then return end

    -- Demoralizing Shout
    if Settings.WarriorCommonDemo and ds and Spell.DemoralizingShout:CastEx(u) then return end

    -- Spell Reflection
    if sr and Me.PowerPct > 45 and Spell.SpellReflection:CastEx(u) then return end

    -- Shield Block
    if Me.HealthPct < 55 and Spell.ShieldBlock:CastEx(u) then return end

    -- Devastate
    local sunders = u:GetAura("Sunder Armor")
    if ((not sunders or (sunders.Stacks < 5 or sunders.Remaining < 4000)) or Me.PowerPct > 35) and
        Spell.Devastate:CastEx(u) then return end

    -- Heroic Strike/Cleave
    if Spell.Cleave.IsKnown then
      local hs_or_cleave = aoe and Spell.Cleave or Spell.HeroicStrike
      if Me.PowerPct > Settings.WarriorProtFiller and hs_or_cleave:CastEx(u) then return end
    else
      if Me.PowerPct > Settings.WarriorProtFiller and Spell.HeroicStrike:CastEx(u) then return end
    end

    ::continue::
  end
end

local behaviors = {
  [BehaviorType.Tank] = WarriorProtCombat
  --[BehaviorType.Combat] = WarriorProtCombat
}

return { Options = options, Behaviors = behaviors }
