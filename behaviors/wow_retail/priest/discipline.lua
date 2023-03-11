local options = {
}

local function PriestDiscipline()
end

local behaviors = {
  [BehaviorType.Combat] = PriestDiscipline
}

return { Options = options, Behaviors = behaviors }
