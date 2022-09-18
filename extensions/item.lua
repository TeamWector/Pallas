---@return WoWItem?
---@param slot EquipSlot
function WoWItem:GetUsableEquipment(slot)
    for k, i in pairs(Me.Equipment) do
        if k == slot then
            return i
        end
    end
end

function WoWItem:UseX(unit)
    if not self.Spell then return false end
    if not self.HasCooldown then return false end
    if self.CooldownRemaining > 0 then return false end
    if not self:InRange(unit) then return false end

    self:Use(unit)
end
