---@diagnostic disable: param-type-mismatch

local attack_spell = WoWSpell("Attack")

local function atan2(a, b)
  local atan2val = 0
  if (b > 0) then
    atan2val = math.atan(a/b);
  elseif ((b < 0) and (a >= 0)) then
    atan2val = math.atan(a/b) + math.pi;
  elseif ((b < 0) and (a < 0)) then
    atan2val = math.atan(a/b) - math.pi;
  elseif((b == 0) and (a > 0)) then
    atan2val = math.pi / 2;
  elseif ((b == 0) and (a < 0)) then
    atan2val = 0 - (math.pi / 2 );
  elseif ((b == 0) and (a == 0)) then
    atan2val = 1000; --represents undefined
  end
  return atan2val;
end

---@param from WoWUnit
---@param to WoWUnit
---@return number angle
local function angleTo(from, to)
  local frompos = from.Position
  local topos = to.Position
  local angle = atan2(topos.y - frompos.y, topos.x - frompos.x)
  if angle < 0 then
    angle = angle + math.pi
  end

  local f = angle - from.Facing
  if f < 0 then
    f = f + math.pi
  end

  if f > math.pi then
    f = from.Facing - angle
    if f < 0 then
      f = f + math.pi
    end
  end

  return math.deg(f)
end

---@param target WoWUnit
---@return boolean inMeleeRange
function WoWUnit:InMeleeRange(target)
  local dist = self.Position:DistanceSq(target.Position)
  return dist <= self:GetMeleeRange(target)
end

---@param target WoWUnit
---@return number inMeleeRange
function WoWUnit:GetMeleeRange(target)
  return math.max(self.BoundingRadius + target.BoundingRadius + 1.333, 5)
end

---@param target WoWObject
---@return number distance
function WoWUnit:Distance(target)
  return self.Position:DistanceSq(target.Position)
end

---@param target WoWUnit
---@return boolean isFacing
function WoWUnit:IsFacing(target)
  return angleTo(self, target) < 90
end

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

function WoWUnit:IsMoving()
  return self.MovementFlags > 0
end