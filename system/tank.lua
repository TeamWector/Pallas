---@class Tank : Targeting
Tank = Tank or Targeting:New()

---@type table<WoWUnit[], number>
Tank.PriorityList = {}

---@type WoWUnit?
Tank.BestTarget = nil

function Tank:Update()
  Targeting.Update(self)

end

function Tank:Reset()
  self.Targets = {}
  self.PriorityList = {}
  self.BestTarget = nil
end

function Tank:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Tank) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end

  return Settings.PallasAttackOOC or (Me.UnitFlags & UnitFlags.InCombat) == UnitFlags.InCombat
end

function Tank:CollectTargets()
  local flags = ObjectTypeFlag.Unit
  local units = wector.Game:GetObjectsByFlag(flags)

  if not Me.InCombat and Settings.PallasAttackOOC then
    local target = Me.Target
    if target and not target.IsTapDenied then
      table.insert(self.Targets, Me.Target)
    end
  else
    -- copy unit list
    for k, u in pairs(units) do
      self.Targets[k] = u.ToUnit
    end
  end
end

function Tank:ExclusionFilter()
  for k, u in pairs(self.Targets) do
    if not Me:CanAttack(u) then
      self.Targets[k] = nil
    elseif not u.InCombat or (not Settings.PallasAttackOOC and not u.InCombat) then
      self.Targets[k] = nil
    elseif u.DeadOrGhost or u.Health <= 0 then
      self.Targets[k] = nil
    elseif u:GetDistance(Me.ToUnit) > 40 then
      self.Targets[k] = nil
    elseif u.IsTapDenied and (not u.Target or u.Target ~= Me) then
      self.Targets[k] = nil
    end
  end
end

function Tank:InclusionFilter()
  local target = Me.Target
  if target then
    for _, u in pairs(self.Targets) do
      if u.Guid == target.Guid then
        -- target already exists in our list
        return
      end
    end

    if not target.IsEnemy and Me:GetReaction(target) > UnitReaction.Neutral then
      return
    elseif target.DeadOrGhost or target.Health <= 0 then
      return
    end

    table.insert(self.Targets, target)
  end
end

function Tank:WeighFilter()
  for _, u in pairs(self.Targets) do
    local priority = 0
    ---@type UnitThreatEntry
    local threatentry = u:GetThreatEntry(Me.ToUnit)

    if threatentry.Status == UnitThreatStatus.NoThreat then
      priority = 50
    elseif threatentry.Status == UnitThreatStatus.InsecurelyTanking then
      priority = 25
    end

    priority = priority + (400 - threatentry.RawPct)
    table.insert(self.PriorityList, { Unit = u, Priority = priority })
  end

  table.sort(self.PriorityList, function(a, b)
    return a.Priority > b.Priority
  end)

  if #self.PriorityList == 0 then
    return
  end

  self.BestTarget = self.PriorityList[1].Unit

  -- If auto-target is disabled we're done here
  if not Settings.PallasAutoTarget then return end

  if not Me.Target then
    Me:SetTarget(self.BestTarget)
  elseif Me.Target.Guid ~= self.BestTarget.Guid then
    Me:SetTarget(self.BestTarget)
  end
end

return Tank
