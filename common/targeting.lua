--- Abstract interface for targeting
---@class Targeting
---@field Targets WoWUnit[]
Targeting = {
  Targets = {},
  HealTargets = {}
}

function Targeting:New(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Targeting:WantToRun()
  return true
end

function Targeting:Update()
  self:Reset()

  if not self:WantToRun() then return end

  self:CollectTargets()
  self:ExclusionFilter()
  self:InclusionFilter()
  self:WeighFilter()
end

function Targeting:Reset()
  self.Targets = {}
  self.HealTargets = {}
end

function Targeting:CollectTargets()
  return {}
end

function Targeting:ExclusionFilter(units)
  return units
end

function Targeting:InclusionFilter(units)
  return units
end

function Targeting:WeighFilter(units)
  return units
end
