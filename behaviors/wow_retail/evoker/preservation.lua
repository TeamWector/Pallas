local options = {
}

local function EvokerPreservation()
end

local behaviors = {
  [BehaviorType.Combat] = EvokerPreservation
}

return { Options = options, Behaviors = behaviors }
