---@return WoWItem?
---@param slot EquipSlot
function WoWItem:GetUsableEquipment(slot)
  for k, i in pairs(Me.Equipment) do
    if k == slot then
      return i
    end
  end
end

---@return boolean success if the item was successfully used
---@param unit WoWUnit? Unit to use the item on.
function WoWItem:UseX(unit)
  if not unit then unit = Me end
  if not unit then return false end

  if not self.Spell then return false end
  if not self.Spell:IsUsable() then return false end
  if not self.HasCooldown then return false end
  if self.CooldownRemaining > 0 then return false end
  if not self:InRange(unit.ToObject) then return false end

  wector.Console:Log("Use: " .. self.Name)
  return self:Use(unit.ToObject)
end
