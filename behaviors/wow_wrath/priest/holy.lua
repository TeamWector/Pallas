-- !NYI
--[[
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
for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end
    ]]

local spells = {
  Renew = WoWSpell("Renew"),
  FlashHeal = WoWSpell("Flash Heal"),
  PrayerOfMending = WoWSpell("Prayer of Mending"),
  PowerWordShield = WoWSpell("Power Word: Shield"),
  GreaterHealRank1 = WoWSpell("Greater Heal(Rank 1)"),
  GreaterHealMax = WoWSpell("Greater Heal"),
}

local function PriestHolyHeal()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit

    if u.HealthPct < 60 and not u:HasVisibleAura("Weakened Soul") and spells.PowerWordShield:CastEx(u) then return end

    if u.HealthPct < 60 and spells.FlashHeal:CastEx(u) then return end

    if u.HealthPct < 80 and spells.GreaterHealRank1:CastEx(u) then return end

    if u.HealthPct < 90 and u.InCombat and spells.PrayerOfMending:CastEx(u) then return end

    if u.HealthPct < 90 and not u:HasVisibleAura("Renew") and spells.Renew:CastEx(u) then return end
  end
end

local behaviors = {
  [BehaviorType.Heal] = PriestHolyHeal
}

--return { Options = options, Behaviors = behaviors }
return { Behaviors = behaviors }
