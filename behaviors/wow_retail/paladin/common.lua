local commonPaladin = {}

commonPaladin.widgets = {
  {
    type = "text",
    uid = "PaladinGeneral",
    text = ">> General <<",
  },
  {
    type = "checkbox",
    uid = "PaladinCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "PaladinCommonTrinket2",
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
    type = "checkbox",
    uid = "CommonHoJInterrupt",
    text = "HoJ Interrupt",
    default = false
  },
  {
    type = "checkbox",
    uid = "CrusaderAura",
    text = "Crusader Aura [Mounted]",
    default = false
  },
}

commonPaladin.auras = {
  blessingofdawn = 385127,
  blessingofdusk = 385126,
  divinepurpose = 223819,
  avengingwrath = 31884,
  sentinel = 389539,
  finalverdict = 383329
}

function commonPaladin:DoInterrupt()
  if Spell.Rebuke:Interrupt() then return true end

  if Settings.CommonHoJInterrupt and Spell.HammerOfJustice:Interrupt() then return true end
end

function commonPaladin:GetHolyPower()
  return Me:GetPowerByType(PowerType.HolyPower)
end

function commonPaladin:HasWings()
  return Me:HasAura(self.auras.avengingwrath) or Me:HasAura(self.auras.sentinel)
end

function commonPaladin:HasPurpose()
  return Me:GetAura(self.auras.divinepurpose) ~= nil
end

function commonPaladin:HammerOfWrath()
  local units = Combat.Targets
  for _, t in pairs(units) do
    if Me:IsFacing(t) and (t.HealthPct < 20 or self:HasWings() or Me:HasAura(self.auras.finalverdict))
        and Spell.HammerOfWrath:CastEx(t, SpellCastExFlags.NoUsable) then
      return true
    end
  end
end

function commonPaladin:CrusaderAura()
  local spell = Spell.CrusaderAura
  if not Settings.CrusaderAura then return false end

  return Me.IsMounted and spell:Apply(Me)
end

function commonPaladin:AvengingWrath()
  local spell = Spell.AvengingWrath
  if spell:CooldownRemaining() > 0 then return false end

  return Combat.Burst and spell:CastEx(Me)
end

function commonPaladin:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.PaladinCommonTrinket1 and trinket1:UseX() then return true end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.PaladinCommonTrinket2 and trinket2:UseX() then return true end
end

return commonPaladin
