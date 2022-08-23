function WoWSpell:CastEx(a1, ...)
  local arg1, arg2, arg3 = a1, ...
  if not arg1 then return false end

  -- generic checks

  -- is spell ready?
  if not self.IsReady then return false end

  -- are we already casting (i.e. actionbar button is highlighted)?
  if self.IsActive then return false end

  -- is spell usable?
  if not self:IsUsable() then return false end

  -- if spell has cast time, are we moving?
  if self.CastTime > 0 and Me:IsMoving() then return false end

  if type(arg1) == 'userdata' and type(arg1.ToUnit) ~= 'nil' then
    -- cast at unit
    local unit = arg1.ToUnit

    -- unit specific checks

    -- are we in range of unit?
    if self:HasRange(unit) and not self:InRange(unit) then return false end

    if not Me:WithinLineOfSight(unit) then return false end

    return self:Cast(arg1.ToUnit)
  else
    -- cast at position
    local x, y, z = 0, 0, 0
    if type(arg1) == 'userdata' and type(arg1.z) ~= 'nil' then
      -- Vec3 input
      x, y, z = arg1.x, arg1.y, arg1.z
    elseif arg2 and arg3 then
      -- x, y, z input
      x, y, z = arg1, arg2, arg3
    else
      -- unknown type
      return false
    end

    -- position specific checks

    return self:Cast(x, y, z)
  end
end

function WoWSpell:HasRange(target)
  local min, max = 0, 0
  if target then
    min, max = self:GetRange(target)
  else
    min, max = self:GetRange()
  end

  return min > 0 or max > 0
end

---@deprecated
function WoWSpell:CanUse(target)
  if not target then target = wector.Game.ActivePlayer.ToUnit end
  return self.IsReady and not self.IsActive and self:IsUsable() and self:InRange(target) and
      (self.CastTime == 0 or not wector.Game.ActivePlayer:IsMoving())
end
