local behaviors = {
  [BehaviorType.Combat] = function() end
}

local exampleCallback = {Options = {}, Behaviors = behaviors}

local wotlkBehavior = {
  Name = "Wrath of the Lich King Example Behavior",
  Classes = {
    ClassType.DeathKnight,
    ClassType.Druid,
    ClassType.Hunter,
    ClassType.Mage,
    ClassType.Paladin,
    ClassType.Priest,
    ClassType.Rogue,
    ClassType.Shaman,
    ClassType.Warlock,
    ClassType.Warrior
  },
  Callbacks = {
    ["deathknight"] = {
      ["Blood"] = exampleCallback,
      ["Frost"] = exampleCallback,
      ["Unholy"] = exampleCallback,
    },
    ["druid"] = {
      ["Balance"] = exampleCallback,
      ["Feral"] = exampleCallback,
      ["Restoration"] = exampleCallback,
    },
    ["hunter"] = {
      ["Beast Mastery"] = exampleCallback,
      ["Marksmanship"] = exampleCallback,
      ["Survival"] = exampleCallback,
    },
    ["mage"] = {
      ["Arcane"] = exampleCallback,
      ["Fire"] = exampleCallback,
      ["Frost"] = exampleCallback,
    },
    ["paladin"] = {
      ["Holy"] = exampleCallback,
      ["Protection"] = exampleCallback,
      ["Retribution"] = exampleCallback,
    },
    ["priest"] = {
      ["Discipline"] = exampleCallback,
      ["Holy"] = exampleCallback,
      ["Shadow"] = exampleCallback,
    },
    ["rogue"] = {
      ["Assassination"] = exampleCallback,
      ["Combat"] = exampleCallback,
      ["Subtlety"] = exampleCallback,
    },
    ["shaman"] = {
      ["Elemental"] = exampleCallback,
      ["Enhancement"] = exampleCallback,
      ["Restoration"] = exampleCallback,
    },
    ["warlock"] = {
      ["Affliction"] = exampleCallback,
      ["Demonology"] = exampleCallback,
      ["Destruction"] = exampleCallback,
    },
    ["warrior"] = {
      ["Arms"] = exampleCallback,
      ["Fury"] = exampleCallback,
      ["Protection"] = exampleCallback,
    },
  }
}

return wotlkBehavior
