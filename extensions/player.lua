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