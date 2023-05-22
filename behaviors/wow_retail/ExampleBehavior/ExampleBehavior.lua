local DemonhunterHavoc = require('behaviors.wow_retail.ExampleBehavior.demonhunter.havoc')
local DemonhunterVengeance = require('behaviors.wow_retail.ExampleBehavior.demonhunter.vengeance')

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
  Callbacks = {
    ["deathknight"] = {
      ["Blood"] = {
        [BehaviorType.Combat] = function() end,
        [BehaviorType.Heal] = function() end,
      },
    },
    ["demonhunter"] = {
      ["Havoc"] = DemonhunterHavoc,
      ["Vengeance"] = DemonhunterVengeance,
    },
  }
}

return exampleBehavior
