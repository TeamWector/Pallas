local commonShaman = {}

commonShaman.widgets = {
  {
    type = "slider",
    uid = "ShamanAstralShift",
    text = "Use Astral Shift below HP%",
    default = 25,
    min = 0,
    max = 100
  },
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

function commonShaman:FireElemental(target)
  if Spell.FireElemental:CastEx(target) then return true end
end

function commonShaman:EarthShield()
  if not Me:HasVisibleAura("Earth Shield") and Spell.EarthShield:CastEx(Me) then return true end
end

function commonShaman:LightningShield()
  if not Me:HasVisibleAura("Lightning Shield") and Spell.LightningShield:CastEx(Me) then return true end
end

function commonShaman:FlametongueWeapon()
  if not Me:HasVisibleAura("Improved Flametongue Weapon") and Spell.FlametongueWeapon:CastEx(Me) then return true end
end

function commonShaman:AstralShift()
  if Settings.ShamanAstralShift > Me.HealthPct and Spell.AstralShift:CastEx(Me) then return true end
end

function commonShaman:EarthShock(target)
  local spell = Spell.EarthShock
  if spell:CooldownRemaining() > 0 then return false end
  if Me.Power > 80 and spell:CastEx(target) then return true end
end


function commonShaman:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.ShamanCommonTrinket1 and trinket1:UseX() then return true end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.ShamanCommonTrinket2 and trinket2:UseX() then return true end
end

return commonShaman
