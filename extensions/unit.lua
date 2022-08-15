function WoWUnit:HasBuff(buffname)
  local auras = self.Auras
  for _, aura in pairs(auras) do
    if aura.Name == buffname then
      return true
    end
  end

  return false
end

function WoWUnit:HasDebuffByMe(dname)
  local auras = self.Auras
  for _, aura in pairs(auras) do
    if aura.Name == dname and aura.HasCaster and aura.Caster == wector.Game.ActivePlayer.ToUnit then
        return true
    end
  end

  return false
end

function WoWUnit:IsMoving()
  return self.MovementFlags > 0
end

function WoWUnit:GetHealthPercent()
  return (self.Health / self.HealthMax) * 100
end

function WoWUnit:InCombatWithMe()
  for k,v in pairs(self.ThreatTable) do
    if Me.Guid == v.Guid then return true end
  end

  return false
end
