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

local movingMask =
  MovementFlags.Forward |
  MovementFlags.Backward |
  MovementFlags.StrafeLeft |
  MovementFlags.StrafeRight |
  MovementFlags.Falling |
  MovementFlags.Ascending |
  MovementFlags.Descending
function WoWUnit:IsMoving()
  return (self.MovementFlags & movingMask) > 0
end

function WoWUnit:GetHealthPercent()
  return (self.Health / self.HealthMax) * 100
end

function WoWUnit:InCombatWithMe()
  --for k,v in pairs(self.ThreatTable) do
  --  if Me.Guid == v.Guid then return true end
  --end

  return false
end

function WoWUnit:WithinLineOfSight(target)
  local from = Me.Position
  from.z = from.z + Me.DisplayHeight

  local to = target.Position
  to.z = to.z + target.DisplayHeight

  local flags = TraceLineHitFlags.SpellLineOfSightMask

  if wector.World:TraceLine(from, to, flags) then return false end
  return true
end

function WoWUnit:AngleToXY(x1, y1, x2, y2)
  -- angle to target according to north (0 rotation)
  local angle = math.atan(y2 - y1, x2 - x1)

  -- take into account our facing in the world
  local diff = angle - Me.Facing

  -- make angle be 0 -> rad
  if angle < 0 then
    angle = angle + math.pi*2
  end

  -- make difference be 0 -> rad
  if diff < 0 then
    diff = diff + math.pi*2
  end

  -- make diff be between -rad/2 -> rad*2
  -- where negative is target to the right and positive is target to the left
  if diff > math.pi then
    diff = diff - math.pi * 2
  end

  return math.deg(diff)
end

function WoWUnit:AngleToPos(from, to)
  return self:AngleToXY(from.x, from.y, to.x, to.y)
end

function WoWUnit:AngleTo(target)
  return self:AngleToPos(Me.Position, target.Position)
end

function WoWUnit:IsFacing(target)
  local angle = Me:AngleTo(target)
  return math.abs(angle) < 90
end

local ttdHistory = {}
--- Very simple TTD, lot of room for improvements here!
---@return number timeToDeath Time until death in seconds
function WoWUnit:TimeToDeath()
  local uid = self.Guid.Low
  local t = wector.Game.Time
  local curhp = self.HealthPct

  if ttdHistory[uid] then
    -- uid is in the list update the TTD
    local o = ttdHistory[uid]
    local hpdiff = o.inithp - curhp
    local tdiff = t - o.inittime

    local hps = hpdiff / (tdiff / 1000)

    if hps > 0 then
      o.ttd = curhp / hps
    end

    return o.ttd
  else
    -- first time seeing this uid, add it to list
    ttdHistory[uid] = { inittime = t, inithp = curhp, ttd = 9999 }
  end

  return 9999
end
