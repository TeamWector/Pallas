function WoWSpell:CanUse(target)
  if not target then target = wector.Game.ActivePlayer.ToUnit end
  return self.IsReady and not self.IsActive and self:IsUsable() and self:InRange(target) and (self.CastTime == 0 or not wector.Game.ActivePlayer:IsMoving())
end
