local commonHunter = {}

commonHunter.widgets = {
  {
    type = "checkbox",
    uid = "HunterCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "HunterCommonTrinket2",
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

function commonHunter:DoInterrupt()
  if Spell.CounterShot:Interrupt() then return end
end

function commonHunter:CallPet(petChoice)
  local petChoice = Settings.HunterPetChoice
  if petChoice == 0 then return end

  if Me.Pet == nil and petChoice == 1 then
    Spell.CallPet1:CastEx(Me)
  end
  if Me.Pet == nil and petChoice == 2 then
    Spell.CallPet2:CastEx(Me)
  end
  if Me.Pet == nil and petChoice == 3 then
    Spell.CallPet1:CastEx(Me)
  end
  if Me.Pet == nil and petChoice == 4 then
    Spell.CallPet4:CastEx(Me)
  end
  if Me.Pet == nil and petChoice == 5 then
    Spell.CallPet5:CastEx(Me)
  end
end

function commonHunter:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.HunterCommonTrinket1 and trinket1:UseX() then return end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.HunterCommonTrinket2 and trinket2:UseX() then return end
end

return commonHunter
