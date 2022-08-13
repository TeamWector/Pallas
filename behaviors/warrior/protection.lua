local options = {
  -- The sub menu name
  Name = "Warrior (Prot)",

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
  ShieldSlam = WoWSpell("Shield Slam"),
  Devastate = WoWSpell("Devastate"),
  Revenge = WoWSpell("Revenge"),
  ThunderClap = WoWSpell("Thunder Clap"),
  BattleShout = WoWSpell("Battle Shout"),
  DemoralizingShout = WoWSpell("Demoralizing Shout"),
  SpellReflection = WoWSpell("Spell Reflection"),
  ShieldBlock = WoWSpell("Shield Block"),
  ShieldBash = WoWSpell("Shield Bash"),
  ConcussionBlow = WoWSpell("Concussion Blow"),

  HeroicStrike = WoWSpell("Heroic Strike"),
  Cleave = WoWSpell("Cleave"),

  -- racial
  Berserking = WoWSpell("Berserking")
}

local function WarriorProtCombat()
  local target = Combat.BestTarget
  if not target then return end

  local aoe = Combat.EnemiesInMeleeRange > 1

  -- buff
  local bs = false
  local auras = Me.Auras
  for _, aura in pairs(auras) do
    if aura.Name == "Battle Shout" and aura.Remaining > 5000 then
      bs = true
    end
  end

  local sr = false
  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell
    if castorchan and spell and spells.ShieldBash.IsReady and spells.ShieldBash:IsUsable() and Me:InMeleeRange(u) then
      spells.ShieldBash:Cast(u)
      return
    end

    if castorchan and spell and spells.ConcussionBlow.IsReady and spells.ConcussionBlow:IsUsable() and Me:InMeleeRange(u) then
      spells.ConcussionBlow:Cast(u)
      return
    end

    local ut = u.Target
    if u.IsCasting and spell and ut and ut == Me.Guid then
      sr = true
    end
  end

  -- debuff
  local ds = true
  local tc = true
  local units = wector.Game.Units
  for _, u in pairs(units) do
    if spells.ThunderClap:InRange(u) then
      local uauras = u.VisibleAuras
      for _, aura in pairs(uauras) do
        if aura.Name == "Polymorph" or aura.Name == "Sap" or aura.Name == "Blind" or aura.Name == "Shackle Undead" then
          tc = false
          aoe = false
        end
      end
    end
  end

  local target_auras = target.VisibleAuras
  for _, aura in pairs(target_auras) do
    if aura.Name == "Demoralizing Shout" and aura.Remaining > 2000 then
      ds = false
    end

    if aura.Name == "Thunder Clap" and aura.Remaining > 2000 then
      tc = false
    end
  end

  -- only melee spells from here on
  if not Me:InMeleeRange(target) then return end

  if spells.ShieldSlam.IsReady and spells.ShieldSlam:IsUsable() then
    spells.ShieldSlam:Cast(target)
  end

  if spells.Revenge.IsReady and spells.Revenge:IsUsable() then
    spells.Revenge:Cast(target)
  end

  if not bs and spells.BattleShout.IsReady and spells.BattleShout:IsUsable() then
    spells.BattleShout:Cast(target)
  end

  if ds and spells.DemoralizingShout.IsReady and spells.DemoralizingShout:IsUsable() then
    spells.DemoralizingShout:Cast(target)
  end

  if tc and spells.ThunderClap.IsReady and spells.ThunderClap:IsUsable() then
    spells.ThunderClap:Cast(target)
  end

  if sr and Me:GetPowerPctByType(PowerType.Rage) > 45 and spells.SpellReflection.IsReady and spells.SpellReflection:IsUsable() then
    spells.SpellReflection:Cast(Me.ToUnit)
  end

  if Me:GetPowerPctByType(PowerType.Rage) > 55 and spells.ShieldBlock.IsReady and spells.ShieldBlock:IsUsable() then
    spells.ShieldBlock:Cast(Me.ToUnit)
  end

  local hs_or_cleave = aoe and spells.HeroicStrike or spells.Cleave
  if Me:GetPowerPctByType(PowerType.Rage) > 75 and hs_or_cleave.IsReady and hs_or_cleave:IsUsable() then
    hs_or_cleave:Cast(target)
  end

  if spells.Devastate.IsReady and spells.Devastate:IsUsable() then
    spells.Devastate:Cast(target)
  end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorProtCombat
}

return { Options = options, Behaviors = behaviors }
