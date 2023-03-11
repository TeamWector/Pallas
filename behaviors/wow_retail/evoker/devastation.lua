local options = {
}

local function EvokerDevastation()
end

local behaviors = {
  [BehaviorType.Combat] = EvokerDevastation
}

return { Options = options, Behaviors = behaviors }
