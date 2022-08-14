---@diagnostic disable: param-type-mismatch

---@class Combat : Targeting
Combat = Combat or Targeting:New()

---@type WoWUnit?
Combat.BestTarget = nil
Combat.EnemiesInMeleeRange = 0

Combat.EventListener = wector.FrameScript:CreateListener()
Combat.EventListener:RegisterEvent("PLAYER_ENTER_COMBAT")
Combat.EventListener:RegisterEvent("PLAYER_LEAVE_COMBAT")

local combatStart = 0
function Combat.EventListener:PLAYER_ENTER_COMBAT()
  combatStart = wector.Chrono.Time
end

function Combat.EventListener:PLAYER_LEAVE_COMBAT()
  combatStart = 0
end

function Combat:Update()
  Targeting.Update(self)

  if combatStart > 0 then
    Combat.TimeInCombat = wector.Chrono.Time - combatStart
  else
    Combat.TimeInCombat = 0
  end
end

function Combat:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Combat) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  return (Me.UnitFlags & UnitFlags.InCombat) == UnitFlags.InCombat
end

function Combat:CollectTargets()
  local flags = ObjectTypeFlag.Unit
  local units = wector.Game:GetObjectsByFlag(flags)

  -- copy unit list
  self.Targets = {} -- ensure empty
  for k, u in pairs(units) do
    self.Targets[k] = u.ToUnit
  end
end

function Combat:ExclusionFilter()
  for k, u in pairs(self.Targets) do
    if not Me:CanAttack(u) then
      self.Targets[k] = nil
    elseif not u.InCombat then
      self.Targets[k] = nil
    elseif u.Dead or u.Health <= 0 then
      self.Targets[k] = nil
    elseif u:GetDistance(Me.ToUnit) > 10 then
      self.Targets[k] = nil
    elseif u.IsTapDenied and (not u.Target or u.Target.Guid ~= Me.Guid) then
      self.Targets[k] = nil
    end
  end
end

function Combat:InclusionFilter()
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
    elseif target.Dead or target.Health <= 0 then
      return
    end

    table.insert(self.Targets, target)
  end
end

function Combat:WeighFilter()
  self.BestTarget = nil -- reset
  self.EnemiesInMeleeRange = 0

  local priorityList = {}
  for _, u in pairs(self.Targets) do
    local priority = 0

    if Me:InMeleeRange(u) then
      self.EnemiesInMeleeRange = self.EnemiesInMeleeRange + 1
    end

    -- our only priority right now, current target
    if Me.Target and Me.Target.Guid == u.Guid then
      priority = priority + 50
    end

    table.insert(priorityList, { Unit = u, Priority = priority })
  end

  table.sort(priorityList, function(a, b)
    return a.Priority > b.Priority
  end)

  if #priorityList == 0 then
    return
  end

  self.BestTarget = priorityList[1].Unit

  -- If auto-target is disabled we're done here
  if not Settings.Core.AutoTarget then return end

  if not Me.Target then
    Me:SetTarget(self.BestTarget)
  elseif Me.Target.Guid ~= self.BestTarget.Guid then
    Me:SetTarget(self.BestTarget)
  end
end

return Combat
