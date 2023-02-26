local commonMonk = {}

commonMonk.widgets = {
  {
    type = "text",
    uid = "MonkGeneralText",
    text = "----------------GENERAL--------------------",
  },
  {
    type = "slider",
    uid = "MonkInterruptPct",
    text = "Kick Cast Left (%)",
    default = 0,
    min = 0,
    max = 100
  },
}

function commonMonk:SpearHandStrike()
  if Spell.SpearHandStrike:CooldownRemaining() > 0 then return end

  for _, e in pairs(Combat.Targets) do
    local cast = e.IsInterruptible and e.CurrentCast
    if not cast then goto continue end

    local isChannel = e.CurrentChannel
    local castRemains = cast.CastEnd - wector.Game.Time
    local castTime = cast.CastEnd - cast.CastStart
    local castPctRemain = math.floor(castRemains / castTime * 100)

    if (castPctRemain < Settings.MonkInterruptPct or isChannel) and Spell.SpearHandStrike:CastEx(e) then return true end
    ::continue::
  end
end

return commonMonk
