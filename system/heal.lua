---@diagnostic disable: param-type-mismatch

Heal = Heal or Targeting:New()

---@type WoWUnit[]
Heal.PriorityList = {}

function Heal:Update()
  Targeting.Update(self)
end

function Heal:Reset()
  Heal.PriorityList = {}
end

function Heal:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Heal) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  return true
end

function Heal:CollectTargets()
  local flags = ObjectTypeFlag.Unit | ObjectTypeFlag.Player | ObjectTypeFlag.ActivePlayer
  local units = wector.Game:GetObjectsByFlag(flags)

  -- copy unit list
  for k, u in pairs(units) do
    self.Targets[k] = u.ToUnit
  end
end

function Heal:ExclusionFilter()
  for k, u in pairs(self.Targets) do
    if Me:CanAttack(u) then
      self.Targets[k] = nil
    elseif u.HealthPct == 100 then
      self.Targets[k] = nil
    elseif u.Dead or u.Health <= 1 then
      self.Targets[k] = nil
    elseif Me:GetDistance(u) > 40 then
      self.Targets[k] = nil
    end
  end
end

function Heal:InclusionFilter()
end

function Heal:WeighFilter()
  for _, u in pairs(self.Targets) do
    local priority = 0

    priority = 0 - u.HealthPct

    table.insert(self.PriorityList, { Unit = u, Priority = priority })
  end

  table.sort(self.PriorityList, function(a, b)
    return a.Priority > b.Priority
  end)
end

return Heal
