local immunes = require("data.immunes")

---@enum Classification
Classification = {
  Normal = 0,
  Elite = 1,
  Rare = 2,
  Boss = 3
}

function ClassificationName(classification)
  for k, v in pairs(Classification) do
    if classification == v then return k end
  end
  return 'Unknown Classification ' .. classification
end

---@enum CreatureType
CreatureType = {
  --Mechanical = 0,
  Beast = 1,
  Dragonkin = 2,
  Demon = 3,
  Elemental = 4,
  --GasCloud = 5,
  Undead = 6,
  Humanoid = 7,
  Critter = 8,
  Mechanical = 9,
  --NonCombatPet = 9,
  NotSpecified = 10,
  Totem = 11,
  --Giant = 12,
  --WildPet = 13
}

function CreatureTypeName(creatureType)
  for k, v in pairs(CreatureType) do
    if creatureType == v then return k end
  end
  return 'Unknown Creature Type ' .. creatureType
end

---@enum CreatureFamily
CreatureFamily = {
  None = 0,
  Wolf = 1,
  Bear = 4,
  Crab = 8,
  Worm = 42,
}

function CreatureFamilyName(creatureFamily)
  for k, v in pairs(CreatureFamily) do
    if creatureFamily == v then return k end
  end
  return tostring(creatureFamily)
end

---@return boolean HasDebuff
---@param bname string buff name
function WoWUnit:HasBuffByMe(bname)
  local auras = self.Auras
  for _, aura in pairs(auras) do
    if aura.Name == bname and aura.HasCaster and aura.Caster == Me.ToUnit then
      return true
    end
  end

  return false
end

---@return boolean HasDebuff
---@param dname string debuff name
function WoWUnit:HasDebuffByMe(dname)
  local auras = self.Auras
  for _, aura in pairs(auras) do
    if aura.Name == dname and aura.HasCaster and aura.Caster == Me.ToUnit then
      return true
    end
  end

  return false
end

---@param identifier any aura name or id
---@return WoWAura?
function WoWUnit:GetAuraByMe(identifier)
  local auras = self.Auras
  local typ = type(identifier)

  for _, aura in pairs(auras) do
    if (typ == "string" and aura.Name == identifier or typ == "number" and aura.Id == identifier)
        and aura.Caster and aura.Caster == Me.ToUnit then
      -- Undocumented copy-constructor
      ---@diagnostic disable-next-line: undefined-global
      return WoWAura(aura)
    end
  end
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

function WoWUnit:IsSitting()
  return self.StandStance == StandStance.Sit
end

function WoWUnit:InCombatWithMe()
  for k, v in pairs(self.ThreatTable) do
    if Me.Guid == v.Guid then return true end
  end

  return false
end

function WoWUnit:IsSwimming()
  return (self.MovementFlags & MovementFlags.Swimming > 0)
end

function WoWUnit:IsStunned()
  return (self.UnitFlags & UnitFlags.Stunned > 0)
end

function WoWUnit:IsImmune()
  for _, immune in pairs(immunes) do
    if self:HasAura(immune) then
      return true
    end
  end

  return (self.UnitFlags & UnitFlags.Unk31 > 0)
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
    angle = angle + math.pi * 2
  end

  -- make difference be 0 -> rad
  if diff < 0 then
    diff = diff + math.pi * 2
  end

  -- make diff be between -rad/2 -> rad*2
  -- where negative is target to the right and positive is target to the left
  if diff > math.pi then
    diff = diff - math.pi * 2
  end

  return math.deg(diff)
end

function WoWUnit:GetHealthLost()
  return self.HealthMax - self.Health
end

function WoWUnit:AngleToPos(from, to)
  return self:AngleToXY(from.x, from.y, to.x, to.y)
end

function WoWUnit:AngleTo(target)
  return self:AngleToPos(Me.Position, target.Position)
end

function WoWUnit:IsFacing(target, ang)
  local angle = Me:AngleTo(target)
  ang = ang or 90
  return math.abs(angle) < ang
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

---@return integer
---@param target WoWUnit The target of the unit, pet, me, another player?
function WoWUnit:GetThreatPct(target)
  local threat = self.ThreatTable
  for _, v in pairs(threat) do
    if v.Guid == target.Guid then
      return v.RawPct
    end
  end

  return 0
end

---@return WoWUnit[]
---@param dist integer Distance from unit to check for other attackable units
function WoWUnit:GetUnitsAround(dist)
  local units = wector.Game.Units
  local collected = {}
  for _, u in pairs(units) do
    if self:GetDistance(u) < dist and Me:CanAttack(u) and not u.Dead then
      table.insert(collected, u)
    end
  end

  return collected
end
