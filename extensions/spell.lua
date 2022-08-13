---@param target WoWUnit
---@return boolean inRange
function WoWSpell:InRange(target)
  if not target then return false end

  local unit = wector.Game.ActivePlayer
  if not unit then return false end

  if self.IsPet then
    -- to satisfy the intellisense about not being the correct type
    unit = unit.ToUnit()

    local pet = unit.Pet
    if not pet then return false end

    unit = pet
  end

  local dist = unit:Distance(target)
  local minRange, maxRange = self:GetRange(target)

  -- whirlwind is special
  if self.Id == 1680 then
    return dist >= 0 and dist <= (8 + maxRange - 1)
  end

  return dist >= minRange and dist <= maxRange
end
