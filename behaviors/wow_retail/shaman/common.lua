local commonShaman = {}

commonShaman.widgets = {
  {
    type = "checkbox",
    uid = "ShamanCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "ShamanCommonTrinket2",
    text = "Use Trinket 2",
    default = false
  },
  {
    type = "slider",
    uid = "InterruptTime",
    text = "Interrupt Time (MS)",
    default = 500,
    min = 0,
    max = 2000
  },
}

local random = math.random(100, 200)
function commonShaman:DoInterrupt()
  local units = wector.Game.Units
  for _, u in pairs(Combat.Targets) do
    if u.CurrentSpell then
      local cast = u.CurrentCast
      local timeLeft = 0
      local channel = u.CurrentChannel

      if cast then
        timeLeft = cast.CastEnd - wector.Game.Time
      end

      if timeLeft <= Settings.InterruptTime + random or channel then
        if Spell.WindShear:CastEx(u) then return end
      end
    end
  end
end

function commonShaman:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.ShamanCommonTrinket1 and trinket1:UseX() then return end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.ShamanCommonTrinket2 and trinket2:UseX() then return end
end

return commonShaman
