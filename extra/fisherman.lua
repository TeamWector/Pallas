local options = {
  Name = "Fisherman",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ExtraFisherman",
      text = "Enable Fisherman",
      default = true
    },
  }
}

local spells = {
  Fishing = WoWSpell("Fishing"),
}

FishermanState = {
  Idle = 1,
  Fishing = 2,
  Looting = 3,
}
local state = FishermanState.Idle

local function Fisherman()
  -- reset to idle if moving
  if Me:IsMoving() then
    state = FishermanState.Idle
    return
  end

  if state == FishermanState.Idle then

  elseif state == FishermanState.Fishing then

  elseif state == FishermanState.Looting then

  end
end

local behaviors = {
  [BehaviorType.Extra] = Fisherman
}

return { Options = options, Behaviors = behaviors }
