local exampleBehavior = {
  Name = "Example Behavior",
  Classes = {
    -- all the classes :)
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
  Behaviors = {
    [BehaviorType.Combat] = function()
      local target = Combat.BestTarget
      if not target then return end
    end,

    [BehaviorType.Heal] = function()
    end
  }
}

return exampleBehavior
