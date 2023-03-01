local options = {
  Name = "Warlock (Affli)",
  Widgets = {
    {
      type = "checkbox",
      uid = "WarlockWin",
      text = "Win?",
      default = false,
    },
  }
}

local function WarlockAffliction()
  if Spell.UnendingBreath:Apply(Me) then return end

  local target = Combat.BestTarget
  if not target then return end

  if Spell.UnstableAffliction:Apply(target, not Combat:CheckTargetsForAuraByMe(Spell.UnstableAffliction.Name, 3000)) then return end
  if Spell.Corruption:Apply(target) then return end
  if Spell.Agony:Apply(target) then return end

  -- Simple AoE Dot.
  for _, t in pairs(Combat.Targets) do
    if Spell.Agony:Apply(t) then return end
    if Spell.Corruption:Apply(t) then return end
  end

end

local behaviors = {
  [BehaviorType.Combat] = WarlockAffliction
}

return { Options = options, Behaviors = behaviors }
