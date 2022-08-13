local options = {
  -- The sub menu name
  Name = "Rogue (Combat)",

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

local function RogueCombatCombat()
  -- these are all things that should be handled by Combat module
  local me = wector.Game.ActivePlayer
  if not me then return end
  local target = me.Target
  if not target then return end
  if not target.IsEnemy then return end

  -- Start combat behaviors

  -- only attack melee
  if me.Position:DistanceSq(target.Position) > 8 then return end

  local ss = WoWSpell("Sinister Strike")
  if me.PowerPct > 40 and ss.IsUsable and ss:Cast(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = RogueCombatCombat
}

return { Options = options, Behaviors = behaviors }
