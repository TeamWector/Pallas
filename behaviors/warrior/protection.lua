local options = {
  -- The sub menu name
  Name = "Warrior (Prot)",

  -- widgets
  Widgets = {
    --{ "text", "TestText", "Hello Text", },
    { "checkbox", "UseLastStand", "Use Last Stand", false },
    { "slider", "LastStandHP", "Last Stand HP%", 30, 0, 100 },
    { "checkbox", "UseShieldWall", "Use Shield Wall", false },
    { "slider", "ShieldWallHP", "Last Stand HP%", 15, 0, 100 },
    { "checkbox", "Taunt", "Auto-Taunt", true },
    { "combobox", "Shout", "Shout", {
        "Battle Shout",
        "Commanding Shout"
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

  if spells.ShieldSlam.IsReady and spells.ShieldSlam:IsUsable() then
    spells.ShieldSlam:Cast(target)
  end

  if spells.Revenge.IsReady and spells.Revenge:IsUsable() then
    spells.Revenge:Cast(target)
  end

  -- Battle Shout
  local bs = Me:GetAura("Battle Shout")
  if not bs or bs.Remaining < 15 * 1000 and spells.BattleShout.IsReady and spells.BattleShout:IsUsable() then
    spells.BattleShout:Cast(target)
  end

  if ds and spells.DemoralizingShout.IsReady and spells.DemoralizingShout:IsUsable() then
    spells.DemoralizingShout:Cast(target)
  end

  if tc and spells.ThunderClap.IsReady and spells.ThunderClap:IsUsable() then
    spells.ThunderClap:Cast(target)
  end

  if sr and Me.PowerPct > 45 and spells.SpellReflection.IsReady and spells.SpellReflection:IsUsable() then
    spells.SpellReflection:Cast(Me.ToUnit)
  end

  if Me.PowerPct > 55 and spells.ShieldBlock.IsReady and spells.ShieldBlock:IsUsable() then
    spells.ShieldBlock:Cast(Me.ToUnit)
  end

  local hs_or_cleave = aoe and spells.HeroicStrike or spells.Cleave
  if Me.PowerPct > 75 and not hs_or_cleave.IsActive and hs_or_cleave.IsReady and hs_or_cleave:IsUsable() then
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
