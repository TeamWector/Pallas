---@enum DispelPriority
DispelPriority = {
    None = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4,
}


local dispels = {
  -- Ahn'kahet: The Old Kingdom
  [56728] = { "Magic", DispelPriority.Low }, -- Eye in the Dark (OK)
  [59108] = { "Poison", DispelPriority.Low }, -- Glutinous Poison (OK)
  [56708] = { "Disease", DispelPriority.Low }, -- Contagion of Rot (OK)
  -- Azjol-Nerub
  -- The Culling of Stratholme
  -- Drak'Tharon Keep
  -- Gundrak
  -- Halls of Stone
  [50761] = { "Magic", DispelPriority.Low }, -- Pillar of Woe (HOS)
  -- Halls of Lightning
  -- The Nexus
  [56860] = { "Magic", DispelPriority.Low }, -- Magic burn
  [47731] = { "Magic", DispelPriority.Low }, -- Polymorph
  [57063] = { "Magic", DispelPriority.Low }, -- Arcane atraction
  [57050] = { "Magic", DispelPriority.Low }, -- Crystal Chains
  [48179] = { "Magic", DispelPriority.Low }, -- Crystalize
  [57091] = { "Magic", DispelPriority.Low }, -- Crystalfire Breath
  -- The Oculus
  [59261] = { "Magic", DispelPriority.Low }, -- Water Tomb
  -- The Violet Hold
  -- Utgarde Keep
  -- Utgarde Pinnacle

  -- Dragonflight --
  -- The Azure Vault
  [384978] = { "Magic", DispelPriority.Low }, -- Dragon Strike
  -- ***** PVP *****
  -- PURGE
  [1022] = { "Magic", DispelPriority.High },   -- Paladin - Blessing of Protection
  [1044] = { "Magic", DispelPriority.Medium }, -- Paladin - Blessing of Freedom
  [383648] = { "Magic", DispelPriority.High }, -- Shaman - Earth Shield
  [21562] = { "Magic", DispelPriority.Low },   -- Priest - Powerword Fortitude
  [17] = { "Magic", DispelPriority.Medium },   -- Priest - Powerword Shield
  [11426] = { "Magic", DispelPriority.High },  -- Mage - Ice Barrier
  -- FRIEND DISPEL
  [358385] = { "Magic", DispelPriority.Medium }, -- Evoker - Land Slide
  [217832] = { "Magic", DispelPriority.High }, -- Demon Hunter - Imprison
  [339] = { "Magic", DispelPriority.Medium },  -- Druid - Entangling Roots
  [2637] = { "Magic", DispelPriority.High },   -- Druid - Hibernate
  [102359] = { "Magic", DispelPriority.High }, -- Druid - Mass Entanglement
  [467] = { "Magic", DispelPriority.High },    -- Druid - Thorns
  [209790] = { "Magic", DispelPriority.High }, -- Hunter - Freezing Arrow
  [3355] = { "Magic", DispelPriority.High },   -- Hunter - Freezing Trap
  [19386] = { "Poison", DispelPriority.High }, -- Hunter - Wyvern Sting
  [31661] = { "Magic", DispelPriority.Medium }, -- Mage - Dragon's Breath
  [122] = { "Magic", DispelPriority.Medium },  -- Mage - Frost Nova
  [61305] = { "Magic", DispelPriority.High },  -- Mage - Polymorph (Cat)
  [161354] = { "Magic", DispelPriority.High }, -- Mage - Polymorph (Monkey)
  [161355] = { "Magic", DispelPriority.High }, -- Mage - Polymorph (Penguin)
  [28272] = { "Magic", DispelPriority.High },  -- Mage - Polymorph (Pig)
  [161353] = { "Magic", DispelPriority.High }, -- Mage - Polymorph (Polar Bear)
  [126819] = { "Magic", DispelPriority.High }, -- Mage - Polymorph (Porcupine)
  [61721] = { "Magic", DispelPriority.High },  -- Mage - Polymorph (Rabbit)
  [118] = { "Magic", DispelPriority.High },    -- Mage - Polymorph (Sheep)
  [61780] = { "Magic", DispelPriority.High },  -- Mage - Polymorph (Turkey)
  [28271] = { "Magic", DispelPriority.High },  -- Mage - Polymorph (Turtle)
  [20066] = { "Magic", DispelPriority.High },  -- Paladin - Repentance
  [853] = { "Magic", DispelPriority.High },    -- Paladin - Hammer of Justice
  [8122] = { "Magic", DispelPriority.High },   -- Priest - Psychic Scream
  [9484] = { "Magic", DispelPriority.Medium }, -- Priest - Shackle Undead
  [375901] = { "Magic", DispelPriority.High }, -- Priest - Mindgames
  [64695] = { "Magic", DispelPriority.Medium }, -- Shaman - Earthgrab Totem
  [211015] = { "Curse", DispelPriority.High }, -- Shaman - Hex (Cockroach)
  [210873] = { "Curse", DispelPriority.High }, -- Shaman - Hex (Compy)
  [51514] = { "Curse", DispelPriority.High },  -- Shaman - Hex (Frog)
  [211010] = { "Curse", DispelPriority.High }, -- Shaman - Hex (Snake)
  [211004] = { "Curse", DispelPriority.High }, -- Shaman - Hex (Spider)
  [196942] = { "Curse", DispelPriority.High }, -- Shaman - Voodoo Totem: Hex
  [118699] = { "Magic", DispelPriority.High }, -- Warlock - Fear
  [5484] = { "Magic", DispelPriority.Medium }, -- Warlock - Howl of Terror
  [710] = { "Magic", DispelPriority.Medium },  -- Warlock - Banish
}

return dispels
