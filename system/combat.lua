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

function Combat:Reset()
  self.BestTarget = nil -- reset
  self.EnemiesInMeleeRange = 0
end

function Combat:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Combat) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end

  return Settings.PallasAttackOOC or (Me.UnitFlags & UnitFlags.InCombat) == UnitFlags.InCombat
end

function Combat:CollectTargets()
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

function Combat:ExclusionFilter()
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
    elseif u:IsImmune() then
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
    elseif target.DeadOrGhost or target.Health <= 0 then
      return
    end

    table.insert(self.Targets, target)
  end
end

function Combat:WeighFilter()
  local priorityList = {}
  for _, u in pairs(self.Targets) do
    local priority = 0

    if Me:InMeleeRange(u) then
      self.EnemiesInMeleeRange = self.EnemiesInMeleeRange + 1
    end

    -- our only priority right now, current target
    if Me.Target and Me.Target == u then
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
  if not Settings.PallasAutoTarget then return end

  if not Me.Target then
    Me:SetTarget(self.BestTarget)
  elseif Me.Target.Guid ~= self.BestTarget.Guid then
    Me:SetTarget(self.BestTarget)
  end
end

---@return number deathtime seconds until all targets we are in combat with die.
function Combat:TargetsAverageDeathTime()
  local count = table.length(self.Targets)
  local seconds = 0

  if count == 0 then return 0 end

  for _, u in pairs(self.Targets) do
    local ttd = u:TimeToDeath()
    seconds = seconds + ttd
  end

  return seconds / count
end

---@return number count Amount of mobs that are within the distance you provided.
---@param dist number Range from myself to check for enemies
function Combat:GetEnemiesWithinDistance(dist)
  local count = 0

  for _, u in pairs(self.Targets) do
    if Me:GetDistance(u) <= dist then
      count = count + 1
    end
  end

  return count
end

---@return boolean, number found returns both a boolean if it found any and how many.
---@param aura any aura id or name
---@param duration number? optional, amount of time left on the buff to consider it applied. (MS)
function Combat:CheckTargetsForAuraByMe(aura, duration)
  local count = 0
  for _, t in pairs(self.Targets) do
    local a = t:GetAuraByMe(aura)
    if a and (not duration or a.Remaining > duration) then
      count = count + 1
    end
  end

  return count > 0, count
end

---@return number targetsaround number of targets around our unit
---@param unit WoWUnit Unit to check for targets
---@param distance integer Distance from unit to check for targets
function Combat:GetTargetsAround(unit, distance)
  local count = 0

  for _, target in pairs(self.Targets) do
    if unit:GetDistance(target) <= distance then
      count = count + 1
    end
  end

  return count
end

---@return boolean gathered if all targets are gathered near eachother.
---@param distance integer how far in yrds from each other do the targets have to be.
function Combat:AllTargetsGathered(distance)
  if table.length(self.Targets) == 0 then return false end

  local gathered = true

  for _, target in pairs(self.Targets) do
    if not target.IsCastingOrChanneling then
      for _, otarget in pairs(self.Targets) do
        if otarget:GetDistance(target) > distance then
          gathered = false
        end
      end
    end
  end

  return gathered
end

return Combat
