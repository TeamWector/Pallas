---@enum SpellCastExFlags
SpellCastExFlags = {
  NoUsable = 0x1
}

local CastTarget = nil
---@return WoWUnit
function WoWSpell:GetCastTarget()
  return CastTarget
end

local spellDelay = {}

SpellListener = wector.FrameScript:CreateListener()
SpellListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

function SpellListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
  if unitTarget == Me then
    CastTarget = nil
  end
end

function WoWSpell:CastEx(a1, ...)
  local arg1, arg2, arg3 = a1, ...
  if not arg1 then return false end
  -- generic checks

  -- delay
  if spellDelay[self.Id] and spellDelay[self.Id] > wector.Game.Time then return false end

  -- is spell ready?
  if not self.IsReady then return false end

  -- are we already casting (i.e. actionbar button is highlighted)?
  if self.IsActive then return false end

  -- if spell has cast time, are we moving?
  if self.CastTime > 0 and Me:IsMoving() then return false end

  if type(arg1) == 'userdata' and type(arg1.ToUnit) ~= 'nil' then
    -- cast at unit
    local unit = arg1.ToUnit
    local flags = arg2 and arg2 or 0x0

    -- is spell usable?
    if (flags & SpellCastExFlags.NoUsable) == 0 and not self:IsUsable() then return false end

    -- unit specific checks

    -- are we in range of unit?
    if self:HasRange(unit) and not self:InRange(unit) then return false end

    if not Me:WithinLineOfSight(unit) then return false end

    wector.Console:Log('Cast ' .. self.Name)
    spellDelay[self.Id] = wector.Game.Time + math.random(150, 500)
    CastTarget = arg1.ToUnit
    return self:Cast(arg1.ToUnit)
  else
    -- cast at position
    local x, y, z = 0, 0, 0
    if type(arg1) == 'userdata' and type(arg1.z) ~= 'nil' then

      -- is spell usable?
      if not self:IsUsable() then return false end

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

    spellDelay[self.Id] = wector.Game.Time + math.random(150, 500)
    return self:Cast(x, y, z)
  end
end

function WoWSpell:CooldownRemaining()
  local start, dur, enabled, modrate = self:GetCooldown()
  if dur ~= 0 then
    return start + dur - wector.Game.Time
  end

  return 0
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

function WoWSpell:CastRemaining()
  return self.CastEnd - wector.Game.Time
end

---@deprecated
function WoWSpell:CanUse(target)
  if not target then target = wector.Game.ActivePlayer.ToUnit end
  return self.IsReady and not self.IsActive and self:IsUsable() and self:InRange(target) and
      (self.CastTime == 0 or not wector.Game.ActivePlayer:IsMoving())
end
