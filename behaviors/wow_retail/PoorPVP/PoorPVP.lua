-- demonhunter
local DemonhunterHavoc = require('behaviors.wow_retail.PoorPvp.demonhunter.havoc')

-- paladin
local PaladinRetribution = require('behaviors.wow_retail.PoorPvp.paladin.retribution')

-- druid
local DruidRestoration = require('behaviors.wow_retail.PoorPvp.druid.restoration')

-- priest
local PriestDiscipline = require('behaviors.wow_retail.PoorPvp.priest.discipline')

-- shaman
local ShamanElemental = require('behaviors.wow_retail.PoorPvp.shaman.elemental')
local ShamanRestoration = require('behaviors.wow_retail.PoorPvp.shaman.restoration')


local behaviors = {
  [BehaviorType.Combat] = function() print(Me:SpecializationName() .. ' is not implemented') end
}

local exampleCallback = {Options = {}, Behaviors = behaviors}
local poorPvpRetail = {
  Name = "Poor PVP Retail",
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
      ["Havoc"] = DemonhunterHavoc,
      ["Vengeance"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["druid"] = {
      ["Balance"] = exampleCallback,
      ["Feral"] = exampleCallback,
      ["Guardian"] = exampleCallback,
      ["Restoration"] = DruidRestoration,
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
      ["Retribution"] = PaladinRetribution,
      ["Initial"] = exampleCallback,
    },
    ["priest"] = {
      ["Discipline"] = PriestDiscipline,
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
      ["Elemental"] = ShamanElemental,
      ["Enhancement"] = exampleCallback,
      ["Restoration"] = ShamanRestoration,
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

return poorPvpRetail
