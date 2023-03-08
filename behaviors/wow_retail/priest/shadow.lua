local options = {
}

local function PriestShadow()
end

local behaviors = {
  [BehaviorType.Combat] = PriestShadow
}

return { Options = options, Behaviors = behaviors }
