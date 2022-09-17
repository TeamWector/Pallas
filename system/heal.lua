---@diagnostic disable: param-type-mismatch
Heal = Heal or Targeting:New()

---@type table<WoWUnit[], number>
Heal.PriorityList = {}

---@type table<WoWUnit[], number>
Heal.Tanks = {}

function Heal:Update()
  Targeting.Update(self)
end

function Heal:Reset()
  Heal.PriorityList = {}
  Heal.Tanks = {}
end

function Heal:WantToRun()
  if not Behavior:HasBehavior(BehaviorType.Heal) then return false end
  if not Me then return false end
  if Me.IsMounted then return false end

  if (Me.UnitFlags & UnitFlags.Looting) == UnitFlags.Looting then return false end
  if Me:HasAura("Preparation") then return false end
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
  local manaMulti = 30
  local group = WoWGroup(GroupType.Auto)

  for _, u in pairs(self.Targets) do
    local priority = 0
    local istank = false

    -- only heal group members for now
    local member = group:GetMemberByGuid(u.Guid)
    if not member and Me.Guid ~= u.Guid then goto continue end

    if member then
      if member.Role == GroupRole.Tank then
        priority = priority + 20
        istank = true
      end
      if member.Role == GroupRole.Healer then priority = priority + 10 end
      if member.Role == GroupRole.Damage then priority = priority + 5 end
    end

    priority = priority + (100 - u.HealthPct)
    priority = priority - ((100 - Me.PowerPct) * (manaMulti / 100))

    if priority > 0 or u.InCombat then
      table.insert(self.PriorityList, { Unit = u, Priority = priority })
    end

    if istank then
      table.insert(self.Tanks, { Unit = u, Priority = priority })
    end

    ::continue::
  end

  table.sort(self.PriorityList, function(a, b)
    return a.Priority > b.Priority
  end)

  table.sort(self.Tanks, function(a, b)
    return a.Priority > b.Priority
  end)
end

function Heal:GetLowestMember()
  local lowest
  for _, v in pairs(Heal.PriorityList) do
    local u = v.Unit
    if not lowest or lowest.HealthPct > u.HealthPct then
      lowest = u
    end
  end

  return lowest
end

return Heal
