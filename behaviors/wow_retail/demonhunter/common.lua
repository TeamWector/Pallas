local commonDemonhunter = {}

--[[ !TODO
  - Everything
]]
commonDemonhunter.widgets = {
  {
    type = "checkbox",
    uid = "DemonhunterCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "DemonhunterCommonTrinket2",
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
    default = 0,
    min = 0,
    max = 100
  },
}


function commonDemonhunter:DoInterrupt()
  if Spell.Disrupt:Interrupt() then return true end
end

function commonDemonhunter:ArcaneTorrent()
  -- TODO FIX ME to use CastEx
  if Spell.ArcaneTorrent:Cast(Me) then return true end
end

function commonDemonhunter:ImmolationAura()
  if Spell.ImmolationAura:CastEx(Me) then return true end
end

function commonDemonhunter:SigilOfFlame(target)
  if Me.Power < 70 and Spell.SigilOfFlame:CastEx(target) then return true end
end

function commonDemonhunter:ThrowGlaive(target)
  if Spell.ThrowGlaive:CastEx(target) then return true end
end

function commonDemonhunter:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.DemonhunterCommonTrinket1 and trinket1:UseX() then return true end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.DemonhunterCommonTrinket2 and trinket2:UseX() then return true end
end

return commonDemonhunter
