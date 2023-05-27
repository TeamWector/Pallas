-- demonhunter
local DemonhunterHavoc = require('behaviors.wow_retail.Pallas.demonhunter.havoc')
local DemonhunterVengeance = require('behaviors.wow_retail.Pallas.demonhunter.vengeance')

-- paladin
local PaladinHoly = require('behaviors.wow_retail.Pallas.paladin.holy')
local PaladinRetribution = require('behaviors.wow_retail.Pallas.paladin.retribution')
local PaladinProtection = require('behaviors.wow_retail.Pallas.paladin.protection')

-- druid
local DruidRestoration = require('behaviors.wow_retail.Pallas.druid.restoration')
local DruidFeral = require('behaviors.wow_retail.Pallas.druid.feral')
local DruidInitial = require('behaviors.wow_retail.Pallas.druid.initial')

-- evoker
local EvokerDevastation = require('behaviors.wow_retail.Pallas.evoker.devastation')
local EvokerPreservation = require('behaviors.wow_retail.Pallas.evoker.preservation')
local EvokerInitial = require('behaviors.wow_retail.Pallas.evoker.initial')

-- hunter
local HunterBeastmastery = require('behaviors.wow_retail.Pallas.hunter.beastmastery')
local HunterMarksmanship = require('behaviors.wow_retail.Pallas.hunter.marksmanship')

-- mage
local MageFrost = require('behaviors.wow_retail.Pallas.mage.frost')

-- monk
local MonkMistweaver = require('behaviors.wow_retail.Pallas.monk.mistweaver')

-- priest
local PriestHoly = require('behaviors.wow_retail.Pallas.priest.holy')
local PriestShadow = require('behaviors.wow_retail.Pallas.priest.shadow')

-- shaman
local ShamanElemental = require('behaviors.wow_retail.Pallas.shaman.elemental')
local ShamanEnhancement = require('behaviors.wow_retail.Pallas.shaman.enhancement')

-- warlock
local WarlockAffliction = require('behaviors.wow_retail.Pallas.warlock.affliction')

-- warrior
local WarriorFury = require('behaviors.wow_retail.Pallas.warrior.fury')
local WarriorProtection = require('behaviors.wow_retail.Pallas.warrior.protection')


local behaviors = {
  [BehaviorType.Combat] = function() print(Me:SpecializationName() .. ' is not implemented') end
}

local exampleCallback = {Options = {}, Behaviors = behaviors}

local pallasRetail = {
  Name = "Pallas Retail",
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
      ["Vengeance"] = DemonhunterVengeance,
      ["Initial"] = exampleCallback,
    },
    ["druid"] = {
      ["Balance"] = exampleCallback,
      ["Feral"] = DruidFeral,
      ["Guardian"] = exampleCallback,
      ["Restoration"] = DruidRestoration,
      ["Initial"] = DruidInitial,
    },
    ["evoker"] = {
      ["devastation"] = EvokerDevastation,
      ["preservation"] = EvokerPreservation,
      ["Initial"] = EvokerInitial,
    },
    ["hunter"] = {
      ["Beast Mastery"] = HunterBeastmastery,
      ["Marksmanship"] = HunterMarksmanship,
      ["Survival"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["mage"] = {
      ["Arcane"] = exampleCallback,
      ["Fire"] = exampleCallback,
      ["Frost"] = MageFrost,
      ["Initial"] = exampleCallback,
    },
    ["monk"] = {
      ["Brewmaster"] = exampleCallback,
      ["Mistweaver"] = MonkMistweaver,
      ["Windwalker"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["paladin"] = {
      ["Holy"] = PaladinHoly,
      ["Protection"] = PaladinProtection,
      ["Retribution"] = PaladinRetribution,
      ["Initial"] = exampleCallback,
    },
    ["priest"] = {
      ["Discipline"] = exampleCallback,
      ["Holy"] = PriestHoly,
      ["Shadow"] = PriestShadow,
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
      ["Enhancement"] = ShamanEnhancement,
      ["Restoration"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["warlock"] = {
      ["Affliction"] = WarlockAffliction,
      ["Demonology"] = exampleCallback,
      ["Destruction"] = exampleCallback,
      ["Initial"] = exampleCallback,
    },
    ["warrior"] = {
      ["Arms"] = exampleCallback,
      ["Fury"] = WarriorFury,
      ["Protection"] = WarriorProtection,
      ["Initial"] = exampleCallback,
    },
  }
}

return pallasRetail
