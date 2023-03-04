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

-- Perhaps move this to a separate file called pvp.lua?

--Arena - Periodic Aura
local ARENA_PERIODIC_AURA = 74410
local ARENA_PREPARATION = { 32727, 32728 }

---returns true if you are in arena, false otherwise
---@return boolean
function WoWGroup:IsArena()
    local arenaAura = Me:GetAura(ARENA_PERIODIC_AURA)
    if arenaAura ~= nil then return true else return false end
end

---returns true if you are in arena and during preparation phase, false otherwise
---@return boolean
function WoWGroup:IsArenaPreparation()
    -- probably don't need this is arena check - what we have prep for arena but no arena? That's retarded
    if WoWGroup:IsArena() then
        for _, auraId in pairs(ARENA_PREPARATION) do
            local prepAura = Me:GetAura(auraId)
            if prepAura ~= nil then return true end
        end
    end
    return false
end
