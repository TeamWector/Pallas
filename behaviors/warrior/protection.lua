local common = require('behaviors.warrior.common')

local options = {
  -- The sub menu name
  Name = "Warrior (Prot)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "UseLastStand",
      text = "Use Last Stand",
      default = false
    },
    {
      type = "slider",
      uid = "LastStandHP",
      text = "Last Stand HP%",
      default = 30,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "UseShieldWall",
      text = "Use Shield Wall",
      default = false
    },
    {
      type = "slider",
      uid = "ShieldWallHP",
      text = "Shield Wall HP%",
      default = 15,
      min = 0,
      max = 100
    },
    {
      type = "checkbox",
      uid = "Taunt",
      text = "Auto-Taunt",
      default = false
    },

    -- !NYI
    --[[
    { "groupbox", "TestGroupbox", "Hello Groupbox", {
        { "text", "TestText", "Hello Text", },
        { "slider", "TestSlider", "Hello Slider", 50, 0, 100 },
        { "checkbox", "TestCheckbox", "Hello Checkbox" },
        { "combobox", "TestCombobox", {
            "Hello Option 1",
            "Hello Option 2",
            "Hello Option 3",
            "Hello Option 4",
          }
        }
      }
    }
    ]]
  }
}
for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local function WarriorProtCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

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

  if target:HasAura("Demoralizing Shout") then
    ds = false
  end
  if target:HasAura("Thunder Clap") then
    tc = false
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  -- Demoralizing Shout
  if ds and Spell.DemoralizingShout:CastEx(target) then return end

  -- Thunder Clap
  if (tc or aoe) and Spell.ThunderClap:CastEx(target) then return end

  -- Shield Slam
  if Spell.ShieldSlam:CastEx(target) then return end

  -- Revenge
  if Spell.Revenge:CastEx(target) then return end

  -- Shout
  common:DoShout()

  -- Spell Reflection
  if sr and Me.PowerPct > 45 and Spell.SpellReflection:CastEx(target) then return end

  -- Shield Block
  if Me.PowerPct > 55 and Spell.ShieldBlock:CastEx(target) then return end

  -- Heroic Strike Filler
  if Me.PowerPct > 75 and Spell.HeroicStrike:CastEx(target) then return end

  -- Devastate
  local sunders = target:GetAura("Sunder Armor")
  if ((not sunders or (sunders.Stacks < 5 or sunders.Remaining < 4000)) or Me.PowerPct > 35) and Spell.Devastate:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorProtCombat
}

return { Options = options, Behaviors = behaviors }
