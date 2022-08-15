local options = {
  -- The sub menu name
  Name = "Warrior (Prot)",

  -- widgets
  Widgets = {
    --{ "text", "TestText", "Hello Text", },
    { "checkbox", "UseLastStand", "Use Last Stand", false },
    { "slider", "LastStandHP", "Last Stand HP%", 30, 0, 100 },
    { "checkbox", "UseShieldWall", "Use Shield Wall", false },
    { "slider", "ShieldWallHP", "Shield Wall HP%", 15, 0, 100 },
    { "checkbox", "Taunt", "Auto-Taunt", false },
    { "combobox", "Shout", "Shout", {
        "Battle Shout",
        "Commanding Shout"
      }
    },

    -- !NYI
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
  BattleShout = WoWSpell("Battle Shout"),
  CommandingShout = WoWSpell("Commanding Shout"),

  ThunderClap = WoWSpell("Thunder Clap"),
  DemoralizingShout = WoWSpell("Demoralizing Shout"),

  ShieldSlam = WoWSpell("Shield Slam"),
  Devastate = WoWSpell("Devastate"),
  Revenge = WoWSpell("Revenge"),
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

    -- Shield Bash
    if castorchan and spell and Me:InMeleeRange(u) and spells.ShieldBash:CastEx(target) then return end

    -- Concussion Blow
    if castorchan and spell and Me:InMeleeRange(u) and spells.ConcussionBlow:CastEx(target) then return end

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

  -- Shield Slam
  if spells.ShieldSlam:CastEx(target) then return end

  -- Revenge
  if spells.Revenge:CastEx(target) then return end

  -- Battle Shout
  local shoutType = math.tointeger(GetCharSetting("Shout"))
  if shoutType == 0 then
    local bs = Me:GetAura("Battle Shout")
    -- Manual Cast here because CastEx gets fucked range.
    if not bs or bs.Remaining < 15 * 1000 and spells.BattleShout.IsReady and spells.BattleShout:IsUsable() then
      spells.BattleShout:Cast(target)
    end
  elseif shoutType == 1 then
    local cs = Me:GetAura("Commanding Shout")
    -- Manual Cast here because CastEx gets fucked range.
    if not cs or cs.Remaining < 15 * 1000 and spells.CommandingShout.IsReady and spells.CommandingShout:IsUsable() then
      spells.CommandingShout:Cast(target)
    end
  end

  -- Demoralizing Shout
  if ds and spells.DemoralizingShout:CastEx(target) then return end

  -- Thunder Clap
  if tc and spells.ThunderClap:CastEx(target) then return end

  -- Spell Reflection
  if sr and Me.PowerPct > 45 and spells.SpellReflection:CastEx(target) then return end

  -- Shield Block
  if Me.PowerPct > 55 and spells.ShieldBlock:CastEx(target) then return end

  -- Filler (Heroic Strike or Cleave)
  local hs_or_cleave = aoe and spells.HeroicStrike or spells.Cleave
  if Me.PowerPct > 75 and hs_or_cleave:CastEx(target) then return end

  -- Devastate
  if spells.Devastate:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = WarriorProtCombat
}

return { Options = options, Behaviors = behaviors }
