local commonMage = {}

--[[ !TODO
  - Everything
]]

commonMage.widgets = {
  {
    type = "checkbox",
    uid = "MageCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "MageCommonTrinket2",
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
}

function commonMage:DoInterrupt()
  if Spell.Counterspell:Interrupt() then return end
end

function commonMage:ArcaneIntellect()
  if not Me:HasVisibleAura("Arcane Intellect") then
      if Spell.ArcaneIntellect:CastEx(Me) then return end
  end
end

function commonMage:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.MageCommonTrinket1 and trinket1:UseX() then return end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.MageCommonTrinket2 and trinket2:UseX() then return end
end

return commonMage
