local options = {
  -- The sub menu name
  Name = "Warrior (Fury)",

  -- widgets
  Widgets = {
    { "text", "TestText", "Hello Text", },
    { "slider", "TestSlider", "Hello Slider", 50, 0, 100 },
    { "checkbox", "TestCheckbox", "Hello Checkbox", true },
    { "combobox", "TestCombobox", "Hello Combobox", {
        "Hello Option 1",
        "Hello Option 2",
        "Hello Option 3",
        "Hello Option 4",
      }
    },
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
  }
}

local spells = {
  BloodThirst = WoWSpell("Bloodthirst"),
  Whirlwind = WoWSpell("Whirlwind"),
  Execute = WoWSpell("Execute"),
  Rampage = WoWSpell("Rampage"),
  HeroicStrike = WoWSpell("Heroic Strike"),
  Cleave = WoWSpell("Cleave"),
  BattleShout = WoWSpell("Battle Shout"),
  VictoryRush = WoWSpell("Victory Rush"),
  BerserkerStance = WoWSpell("Berserker Stance"),
  SweepingStrikes = WoWSpell("Sweeping Strikes"),

  -- racial
  Berserking = WoWSpell("Berserking")
}

local function WarriorFuryCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  -- buff
  local bs = false
  local ramp = false
  local stance = 0
  local auras = Me.Auras
  for _, v in pairs(auras) do
    if (v.Name == "Battle Shout") then
      bs = true
    end
    if (v.Name == "Rampage") and v.Remaining > 5000 then
      ramp = true
    end
    if v.Name == "Battle Stance" then
      stance = 1
    elseif v.Name == "Defensive Stance" then
      stance = 2
    elseif v.Name == "Berserker Stance" then
      stance = 3
    end
  end

  if not bs and spells.BattleShout.IsReady and spells.BattleShout:IsUsable() then
    spells.BattleShout:Cast(target)
  end

  if aoe and Me:InMeleeRange(target) and spells.SweepingStrikes.IsReady and spells.SweepingStrikes:IsUsable() then
    spells.SweepingStrikes:Cast(target)
  end

  if spells.VictoryRush:InRange(target) and spells.VictoryRush.IsReady and spells.VictoryRush:IsUsable() then
    spells.VictoryRush:Cast(target)
  end

  if spells.BloodThirst:InRange(target) and spells.BloodThirst.IsReady and spells.BloodThirst:IsUsable() then
    spells.BloodThirst:Cast(target)
  end

  if spells.Whirlwind:InRange(target) and spells.Whirlwind.IsReady and spells.Whirlwind:IsUsable() then
    spells.Whirlwind:Cast(target)
  end

  --if spells.Execute:InRange(target) and spells.Execute.IsReady and spells.Execute:IsUsable() then
  --  spells.Execute:Cast(target)
  --end

  if not ramp and spells.Rampage:InRange(target) and spells.Rampage.IsReady and spells.Rampage:IsUsable() then
    spells.Rampage:Cast(target)
  end

  local hs_or_cleave = aoe and spells.HeroicStrike or spells.Cleave
  if Me:GetPowerPctByType(PowerType.Rage) > 75 and hs_or_cleave:InRange(target) and hs_or_cleave.IsReady and hs_or_cleave:IsUsable() then
    hs_or_cleave:Cast(target)
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorFuryCombat
}

return { Options = options, Behaviors = behaviors }
