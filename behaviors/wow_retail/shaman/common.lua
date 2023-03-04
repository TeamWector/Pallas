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

function commonShaman:DoInterrupt()
  if Spell.WindShear:Interrupt() then return true end
end

function commonShaman:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.ShamanCommonTrinket1 and trinket1:UseX() then return true end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.ShamanCommonTrinket2 and trinket2:UseX() then return true end
end

return commonShaman
