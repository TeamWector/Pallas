local options = {
  Name = "AntiAFK",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ExtraAntiAFK",
      text = "Enable AntiAFK",
      default = false
    }
  }
}

local lastAction = 0
local function AntiAFK()
  if not Settings.ExtraAntiAFK then return end
  local timePassed = wector.Game.Time - lastAction
  if timePassed > 60000 then
    lastAction = wector.Game.Time
    Me.LastHardwareAction = wector.Game.Time
  end
end

local behaviors = {
  [BehaviorType.Extra] = AntiAFK
}

return { Options = options, Behaviors = behaviors }
