-- deathknight
local DeathknightBlood = require('behaviors.wow_wrath.Pallas.deathknight.blood')
local DeathknightFrost = require('behaviors.wow_wrath.Pallas.deathknight.frost')
local DeathknightUnholy = require('behaviors.wow_wrath.Pallas.deathknight.unholy')

-- druid
local DruidBalance = require('behaviors.wow_wrath.Pallas.druid.balance')
local DruidFeral = require('behaviors.wow_wrath.Pallas.druid.feral')
local DruidRestoration = require('behaviors.wow_wrath.Pallas.druid.restoration')

-- hunter
local HunterBeastmastery = require('behaviors.wow_wrath.Pallas.hunter.beastmastery')
local HunterMarksmanship = require('behaviors.wow_wrath.Pallas.hunter.marksmanship')
local HunterSurvival = require('behaviors.wow_wrath.Pallas.hunter.survival')

-- mage
local MageArcane = require('behaviors.wow_wrath.Pallas.mage.arcane')
local MageFire = require('behaviors.wow_wrath.Pallas.mage.fire')
local MageFrost = require('behaviors.wow_wrath.Pallas.mage.frost')

-- paladin
local PaladinHoly = require('behaviors.wow_wrath.Pallas.paladin.holy')
local PaladinProtection = require('behaviors.wow_wrath.Pallas.paladin.protection')
local PaladinRetribution = require('behaviors.wow_wrath.Pallas.paladin.retribution')

-- priest
local PriestDiscipline = require('behaviors.wow_wrath.Pallas.priest.discipline')
local PriestHoly = require('behaviors.wow_wrath.Pallas.priest.holy')
local PriestShadow = require('behaviors.wow_wrath.Pallas.priest.shadow')

-- rogue
local RogueAssassination = require('behaviors.wow_wrath.Pallas.rogue.assassination')
local RogueCombat = require('behaviors.wow_wrath.Pallas.rogue.combat')
local RogueSubtlety = require('behaviors.wow_wrath.Pallas.rogue.subtlety')

-- shaman
local ShamanElemental = require('behaviors.wow_wrath.Pallas.shaman.elemental')
local ShamanEnhancement = require('behaviors.wow_wrath.Pallas.shaman.enhancement')
local ShamanRestoration = require('behaviors.wow_wrath.Pallas.shaman.restoration')

-- warlock
local WarlockAffliction = require('behaviors.wow_wrath.Pallas.warlock.affliction')
local WarlockDemonology = require('behaviors.wow_wrath.Pallas.warlock.demonology')
local WarlockDestruction = require('behaviors.wow_wrath.Pallas.warlock.destruction')

-- warrior
local WarriorArms = require('behaviors.wow_wrath.Pallas.warrior.arms')
local WarriorFury = require('behaviors.wow_wrath.Pallas.warrior.fury')
local WarriorProtection = require('behaviors.wow_wrath.Pallas.warrior.protection')

local pallasWotlk = {
  Name = "Pallas WOTLK",
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
      ["Blood"] = DeathknightBlood,
      ["Frost"] = DeathknightFrost,
      ["Unholy"] = DeathknightUnholy,
    },
    ["druid"] = {
      ["Balance"] = DruidBalance,
      ["Feral"] = DruidFeral,
      ["Restoration"] = DruidRestoration,
    },
    ["hunter"] = {
      ["Beast Mastery"] = HunterBeastmastery,
      ["Marksmanship"] = HunterMarksmanship,
      ["Survival"] = HunterSurvival,
    },
    ["mage"] = {
      ["Arcane"] = MageArcane,
      ["Fire"] = MageFire,
      ["Frost"] = MageFrost,
    },
    ["paladin"] = {
      ["Holy"] = PaladinHoly,
      ["Protection"] = PaladinProtection,
      ["Retribution"] = PaladinRetribution,
    },
    ["priest"] = {
      ["Discipline"] = PriestDiscipline,
      ["Holy"] = PriestHoly,
      ["Shadow"] = PriestShadow,
    },
    ["rogue"] = {
      ["Assassination"] = RogueAssassination,
      ["Combat"] = RogueCombat,
      ["Subtlety"] = RogueSubtlety,
    },
    ["shaman"] = {
      ["Elemental"] = ShamanElemental,
      ["Enhancement"] = ShamanEnhancement,
      ["Restoration"] = ShamanRestoration,
    },
    ["warlock"] = {
      ["Affliction"] = WarlockAffliction,
      ["Demonology"] = WarlockDemonology,
      ["Destruction"] = WarlockDestruction,
    },
    ["warrior"] = {
      ["Arms"] = WarriorArms,
      ["Fury"] = WarriorFury,
      ["Protection"] = WarriorProtection,
    },
  }
}

return pallasWotlk
