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
    default = 40,
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

function commonShaman:Stormkeeper()
  local spell = Spell.Stormkeeper
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(Me) then return true end
end

function commonShaman:IsStormkeeper()
  return Me:HasVisibleAura("Stormkeeper")
end

function commonShaman:LightningBoltWithStormkeeper(target)
  if commonShaman:IsStormkeeper() and commonShaman:LightningBolt(target) then return true end
end

function commonShaman:PrimordialWave(target)
  local spell = Spell.PrimordialWave
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end

function commonShaman:FlametongueWeapon()
  if not Me:HasVisibleAura("Improved Flametongue Weapon") and Spell.FlametongueWeapon:CastEx(Me) then return true end
end

function commonShaman:AstralShift()
  if Settings.ShamanAstralShift > Me.HealthPct and Spell.AstralShift:CastEx(Me) then return true end
end

function commonShaman:LightningBolt(target)
  local spell = Spell.LightningBolt
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end


function commonShaman:ChainLightning(target)
  local spell = Spell.ChainLightning
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end


function commonShaman:LavaBurst(target)
  local spell = Spell.LavaBurst
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end

-- Loop through all units find one without flame shock or lowest duration to cast Flame Shock
function commonShaman:FlameShock()
  local spell = Spell.FlameShock
  if spell:CooldownRemaining() > 0 then return false end
  for _, u in pairs(Combat.Targets) do
      local flameShockAura = u:GetAuraByMe("Flame Shock")
      if (not flameShockAura or flameShockAura.Remaining < 5400) and spell:CastEx(u) then return true end
  end
end


function commonShaman:EarthShock(target)
  local spell = Spell.EarthShock
  if spell:CooldownRemaining() > 0 then return false end
  if Me.Power > 80 and spell:CastEx(target) then return true end
end

function commonShaman:FrostShock(target)
  local spell = Spell.FrostShock
  if spell:CooldownRemaining() > 0 then return false end
  if (not target:HasAura("Frost Shock")) and spell:CastEx(target) then return true end
end


function commonShaman:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.ShamanCommonTrinket1 and trinket1:UseX() then return true end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.ShamanCommonTrinket2 and trinket2:UseX() then return true end
end

return commonShaman
