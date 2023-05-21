local function DemonhunterHavocCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if not target then return end
  if Me.IsCastingOrChanneling then return end

  if Spell.Felblade:CastEx(target) then return end
end

local function DemonhunterVengeanceCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = Combat.BestTarget
  if not target then return end
  if Me.IsCastingOrChanneling then return end

  if Spell.Fracture:CastEx(target) then return end
end

local exampleBehavior = {
  Name = "Example Behavior",
  Classes = {
    ClassType.DeathKnight,
    ClassType.DemonHunter,
    ClassType.Druid,
    ClassType.Evoker,
    ClassType.Hunter,
    ClassType.Mage,
    ClassType.Monk,
    ClassType.Paladin,
    ClassType.Priest,
    ClassType.Rogue,
    ClassType.Shaman,
    ClassType.Warlock,
    ClassType.Warrior
  },
  Options = {
    Name = "Example Behavior",
    Widgets = {}
  },
  Callbacks = {
    ["deathknight"] = {
      ["Blood"] = {
        [BehaviorType.Combat] = function() end,
        [BehaviorType.Heal] = function() end,
      },
      -- Add more specializations for DeathKnight if needed
    },
    -- Demon Hunter
    ["demonhunter"] = {
      ["Havoc"] = {
        [BehaviorType.Combat] = DemonhunterHavocCombat
        -- You could also add more BehaviorTypes
      },
      ["Vengeance"] = {
        [BehaviorType.Combat] = DemonhunterVengeanceCombat
      },
      -- Add more specializations for Demon Hunter if needed
    },
    -- Add more classes as necessary
  }
}

return exampleBehavior
