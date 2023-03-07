---returns a table of units that belong to your group.
---@return WoWUnit[]
function WoWGroup:GetGroupUnits()
  local group = self(GroupType.Auto)
  local members = {}

  if not group.InGroup then
    table.insert(members, Me.ToUnit)
  else
    local companions = group.Members
    for _, m in pairs(companions) do
      local unit = wector.Game:GetObjectByGuid(m.Guid)
      if unit and unit.Position:DistanceSq(Me.Position) <= 40 then
        table.insert(members, unit.ToUnit)
      end
    end
  end

  return members
end

function WoWGroup:GetTankUnits()
  local group = self(GroupType.Auto)
  local tanks = {}

  if not group.InGroup then return {} end

  local companions = group.Members
  for _, m in pairs(companions) do
    if m.Role & GroupRole.Tank == GroupRole.Tank then
      local unit = wector.Game:GetObjectByGuid(m.Guid)
      if unit and unit.Position:DistanceSq(Me.Position) <= 40 then
        table.insert(tanks, unit.ToUnit)
      end
    end
  end

  return tanks
end
