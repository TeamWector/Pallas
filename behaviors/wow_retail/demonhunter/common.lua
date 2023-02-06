local commonDemonhunter = {}

--[[ !TODO
  - Everything
]]

commonDemonhunter.widgets = {
  {
    type = "checkbox",
    uid = "DemonhunterCommonTrinket1",
    text = "Use Trinket 1",
    default = false
  },
  {
    type = "checkbox",
    uid = "DemonhunterCommonTrinket2",
    text = "Use Trinket 2",
    default = false
  },
}

---
--- Interrupts melee attackers spell casting if possible, returns true if there is a spell casting on us we cannot interrupt.
---@return boolean
function commonDemonhunter:DoInterrupt()
  local t1 = Combat.BestTarget
  local t2 = Tank.BestTarget
  local target = t1 and t1 or t2
  if not target then return false end

  -- TODO: Merge these two loops, lazy!

  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    if not u.IsInterruptible then goto continue end

    if castorchan and spell and spell.CastStart + 500 < wector.Game.Time and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Disrupt
      if Spell.Disrupt:CastEx(u) then return false end
    end

    ::continue::
    local ut = u.Target
    if u.IsCasting and spell and ut and ut.Guid == Me.Guid then
      return true
    end
  end

  for _, u in pairs(Tank.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    if not u.IsInterruptible then goto continue end

    if castorchan and spell and spell.CastStart + 500 < wector.Game.Time and Me:InMeleeRange(u) and Me:IsFacing(u) then
      -- Concussion Blow
      if Spell.StormBolt:CastEx(u) then return false end

      -- Pummel
      if Spell.Pummel:CastEx(u) then return false end
    end

    ::continue::
    local ut = u.Target
    if u.IsCasting and spell and ut and ut.Guid == Me.Guid then
      return true
    end
  end

  return false
end

function commonDemonhunter:UseTrinkets()
  local items = Me.Equipment

  local trinket1 = items[EquipSlot.Trinket1]
  if Settings.DemonhunterCommonTrinket1 and trinket1:UseX() then return end

  local trinket2 = items[EquipSlot.Trinket2]
  if Settings.DemonhunterCommonTrinket2 and trinket2:UseX() then return end
end

return commonDemonhunter
