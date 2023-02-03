---@return WoWUnit[]
function WoWGroup:GetGroupUnits()
    local group = self(GroupType.Auto)
    local members = {}

    if not group.InGroup then
        table.insert(members, Me.ToUnit)
    else
        local companions = group.Members
        for _, m in pairs(companions) do
            local unit = wector.Game:GetObjectByGuid(m.Guid).ToUnit
            if unit then
                table.insert(members, unit)
            end
        end
    end

    return members
end