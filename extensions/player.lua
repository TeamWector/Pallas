function WoWActivePlayer:GetUnitNotAttackingMe()
  local collected = {}
  local units = wector.Game.Units
  for _, u in pairs(units) do
    if u:GetThreatPct(Me.ToUnit) > 0 and u.Target and u.Target ~= Me and Me:WithinLineOfSight(u) then
      table.insert(collected, u)
    end
  end

  -- Let's sort so the furthest ones are priorities since we can easily aggro stuff near us.
  table.sort(collected, function(x, y)
    return Me:GetDistance(x) > Me:GetDistance(y)
  end)

  return collected[1]
end

function WoWActivePlayer:GetUnitsNotAttackingMe()
  local collected = {}
  local units = wector.Game.Units
  for _, u in pairs(units) do
    if u:GetThreatPct(Me.ToUnit) > 0 and u.Target and u.Target ~= Me and Me:WithinLineOfSight(u) then
      table.insert(collected, u)
    end
  end

  return collected
end

--- Checks units around you if they have the debuff you provided
---@param spell WoWSpell Debuff spell
---@return WoWUnit
function WoWActivePlayer:GetTargetForDebuff(spell)
  local units = wector.Game.Units
  local collected = {}
  for _, u in pairs(units) do
    if u:InCombatWithMe() and not u:HasVisibleAura(spell.Name) then
      table.insert(collected, u)
    end
  end

  -- Let's sort them so we prioritise the closest ones.
  table.sort(collected, function(x, y)
    return Me:GetDistance(x) < Me:GetDistance(y)
  end)

  return collected[1]
end

--Arena - Periodic Aura
local ARENA_PERIODIC_AURA = 74410
local ARENA_PREPARATION = { 32727, 32728 }

---returns true if you are in arena, false otherwise
---@return boolean
function WoWActivePlayer:InArena()
  local arenaAura = self:GetAura(ARENA_PERIODIC_AURA)
  return arenaAura ~= nil
end

---returns true if you are in arena and during preparation phase, false otherwise
---@return boolean
function WoWActivePlayer:HasArenaPreparation()
  -- probably don't need this is arena check - what we have prep for arena but no arena?
  if self:InArena() then
    for _, auraId in pairs(ARENA_PREPARATION) do
      local prepAura = self:GetAura(auraId)
      if prepAura ~= nil then return true end
    end
  end
  return false
end
