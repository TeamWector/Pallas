local commonPaladin = {}

commonPaladin.widgets = {
  {
    type = "text",
    uid = "PaladinGeneral",
    text = ">> General <<",
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

commonPaladin.auras = {
  blessingofdawn = 385127,
  blessingofdusk = 385126,
  divinepurpose = 223819,
  avengingwrath = 31884
}

function commonPaladin:DoInterrupt()
  local spell = Spell.Rebuke
  if spell:CooldownRemaining() > 0 then return false end

  if spell:Interrupt() then return end
end

function commonPaladin:GetHolyPower()
  return Me:GetPowerByType(PowerType.HolyPower)
end

function commonPaladin:HasDawn()
  local dawn = Me:GetAura(self.auras.blessingofdawn)
  return dawn and dawn.Remaining > 6000
end

function commonPaladin:HasDusk()
  local dusk = Me:GetAura(self.auras.blessingofdusk)
  return dusk and dusk.Remaining > 6000
end

function commonPaladin:HasPurpose()
  return Me:GetAura(self.auras.divinepurpose) ~= nil
end

function commonPaladin:HammerOfWrath()
  local units = table.length(Combat.Targets) > 0 and Combat.Targets or Tank.Targets
  for _, t in pairs(units) do
    if Me:IsFacing(t) and (t.HealthPct < 20 or Me:HasAura(self.auras.avengingwrath))
        and Spell.HammerOfWrath:CastEx(t, SpellCastExFlags.NoUsable) then
      return true
    end
  end
end

return commonPaladin
