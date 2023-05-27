local behaviors = {
  [BehaviorType.Combat] = function() end
}

local exampleCallback = {Options = {}, Behaviors = behaviors}

local exampleBehavior = {
  Name = "Retail Example Behavior",
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
  Callbacks = {
    ["deathknight"] = {
      ["Blood"] = exampleCallback,
      ["Frost"] = exampleCallback,
      ["Unholy"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["demonhunter"] = {
      ["Havoc"] = exampleCallback,
      ["Vengeance"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["druid"] = {
      ["Balance"] = exampleCallback,
      ["Feral"] = exampleCallback,
      ["Guardian"] = exampleCallback,
      ["Restoration"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["evoker"] = {
      ["devastation"] = exampleCallback,
      ["preservation"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["hunter"] = {
      ["Beast Mastery"] = exampleCallback,
      ["Marksmanship"] = exampleCallback,
      ["Survival"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["mage"] = {
      ["Arcane"] = exampleCallback,
      ["Fire"] = exampleCallback,
      ["Frost"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["monk"] = {
      ["Brewmaster"] = exampleCallback,
      ["Mistweaver"] = exampleCallback,
      ["Windwalker"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["paladin"] = {
      ["Holy"] = exampleCallback,
      ["Protection"] = exampleCallback,
      ["Retribution"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["priest"] = {
      ["Discipline"] = exampleCallback,
      ["Holy"] = exampleCallback,
      ["Shadow"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["rogue"] = {
      ["Assassination"] = exampleCallback,
      ["Outlaw"] = exampleCallback,
      ["Subtlety"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["shaman"] = {
      ["Elemental"] = exampleCallback,
      ["Enhancement"] = exampleCallback,
      ["Restoration"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["warlock"] = {
      ["Affliction"] = exampleCallback,
      ["Demonology"] = exampleCallback,
      ["Destruction"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["warrior"] = {
      ["Arms"] = exampleCallback,
      ["Fury"] = exampleCallback,
      ["Protection"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
  }
}

return exampleBehavior
