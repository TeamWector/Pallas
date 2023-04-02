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
    type = "combobox",
    uid = "CommonInterrupts",
    text = "Interrupt",
    default = 0,
    options = { "Disabled", "Any", "Whitelist" }
  },
    {
    type = "slider",
    uid = "CommonInterruptPct",
    text = "Kick Cast Left (%)",
    default = 20,
    min = 0,
    max = 100
  },
  {
    type = "combobox",
    uid = "CommonDispels",
    text = "Dispel",
    default = 0,
    options = { "Disabled", "Any", "Whitelist" }
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
