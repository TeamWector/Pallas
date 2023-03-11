local options = {
}

local function EvokerInitial()
end

local behaviors = {
  [BehaviorType.Combat] = EvokerInitial
}

return { Options = options, Behaviors = behaviors }
