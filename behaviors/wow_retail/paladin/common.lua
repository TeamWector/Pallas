local commonPaladin = {}

commonPaladin.widgets = {
  {
    type = "checkbox",
    uid = "PaladinRebuke",
    text = "Interrupt With Rebuke",
    default = false
  },
}

commonPaladin.auras = {
  blessingofdawn = 385127,
  blessingofdusk = 385126,
  divinepurpose = 223819,
  avengingwrath = 31884
}

function commonPaladin:DoInterrupt()
  if Spell.Rebuke:Interrupt() then return end
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
  for _, t in pairs(Combat.Targets) do
    if (t.HealthPct < 20 or Me:HasAura(self.auras.avengingwrath)) and Spell.HammerOfWrath:CastEx(t, SpellCastExFlags.NoUsable) then return true end
  end
end

return commonPaladin
