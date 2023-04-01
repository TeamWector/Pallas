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
  [56728] = DispelPriority.Low, -- Eye in the Dark (OK)
  [59108] = DispelPriority.Low, -- Glutinous Poison (OK)
  [56708] = DispelPriority.Low, -- Contagion of Rot (OK)
  -- Azjol-Nerub
  -- The Culling of Stratholme
  -- Drak'Tharon Keep
  -- Gundrak
  -- Halls of Stone
  [50761] = DispelPriority.Low, -- Pillar of Woe (HOS)
  -- Halls of Lightning
  -- The Nexus
  [56860] = DispelPriority.Low, -- Magic burn
  [47731] = DispelPriority.Low, -- Polymorph
  [57063] = DispelPriority.Low, -- Arcane atraction
  [57050] = DispelPriority.Low, -- Crystal Chains
  [48179] = DispelPriority.Low, -- Crystalize
  [57091] = DispelPriority.Low, -- Crystalfire Breath
  -- The Oculus
  [59261] = DispelPriority.Low, -- Water Tomb
  -- The Violet Hold
  -- Utgarde Keep
  -- Utgarde Pinnacle

  -- Dragonflight --
  -- The Azure Vault
  [384978] = DispelPriority.Low, -- Dragon Strike
  -- ***** PVP *****
  -- PURGE
  [1022] = DispelPriority.High,   -- Paladin - Blessing of Protection
  [1044] = DispelPriority.Medium, -- Paladin - Blessing of Freedom
  [383648] = DispelPriority.High, -- Shaman - Earth Shield
  [21562] = DispelPriority.Low,   -- Priest - Powerword Fortitude
  [17] = DispelPriority.Medium,   -- Priest - Powerword Shield
  [11426] = DispelPriority.High,  -- Mage - Ice Barrier
  -- FRIEND DISPEL
  [358385] = DispelPriority.Medium, -- Evoker - Land Slide
  [217832] = DispelPriority.High, -- Demon Hunter - Imprison
  [339] = DispelPriority.Medium,  -- Druid - Entangling Roots
  [2637] = DispelPriority.High,   -- Druid - Hibernate
  [102359] = DispelPriority.High, -- Druid - Mass Entanglement
  [467] = DispelPriority.High,    -- Druid - Thorns
  [209790] = DispelPriority.High, -- Hunter - Freezing Arrow
  [3355] = DispelPriority.High,   -- Hunter - Freezing Trap
  [19386] = DispelPriority.High, -- Hunter - Wyvern Sting
  [31661] = DispelPriority.Medium, -- Mage - Dragon's Breath
  [122] = DispelPriority.Medium,  -- Mage - Frost Nova
  [61305] = DispelPriority.High,  -- Mage - Polymorph (Cat)
  [161354] = DispelPriority.High, -- Mage - Polymorph (Monkey)
  [161355] = DispelPriority.High, -- Mage - Polymorph (Penguin)
  [28272] = DispelPriority.High,  -- Mage - Polymorph (Pig)
  [161353] = DispelPriority.High, -- Mage - Polymorph (Polar Bear)
  [126819] = DispelPriority.High, -- Mage - Polymorph (Porcupine)
  [61721] = DispelPriority.High,  -- Mage - Polymorph (Rabbit)
  [118] = DispelPriority.High,    -- Mage - Polymorph (Sheep)
  [61780] = DispelPriority.High,  -- Mage - Polymorph (Turkey)
  [28271] = DispelPriority.High,  -- Mage - Polymorph (Turtle)
  [20066] = DispelPriority.High,  -- Paladin - Repentance
  [853] = DispelPriority.High,    -- Paladin - Hammer of Justice
  [8122] = DispelPriority.High,   -- Priest - Psychic Scream
  [9484] = DispelPriority.Medium, -- Priest - Shackle Undead
  [375901] = DispelPriority.High, -- Priest - Mindgames
  [64695] = DispelPriority.Medium, -- Shaman - Earthgrab Totem
  [211015] = DispelPriority.High, -- Shaman - Hex (Cockroach)
  [210873] = DispelPriority.High, -- Shaman - Hex (Compy)
  [51514] = DispelPriority.High,  -- Shaman - Hex (Frog)
  [211010] = DispelPriority.High, -- Shaman - Hex (Snake)
  [211004] = DispelPriority.High, -- Shaman - Hex (Spider)
  [196942] = DispelPriority.High, -- Shaman - Voodoo Totem: Hex
  [118699] = DispelPriority.High, -- Warlock - Fear
  [5484] = DispelPriority.Medium, -- Warlock - Howl of Terror
  [710] = DispelPriority.Medium,  -- Warlock - Banish
}

return dispels
