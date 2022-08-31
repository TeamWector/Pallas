local spells = {
  Rejuvenation = WoWSpell("Rejuvenation"),
  HealingTouch = WoWSpell("Healing Touch"),
  Regrowth = WoWSpell("Regrowth"),
  Swiftmend = WoWSpell("Swiftmend"),

  MarkOfTheWild = WoWSpell("Mark of the Wild"),
  GiftOfTheWild = WoWSpell("Gift of the Wild"),
  Thorns = WoWSpell("Thorns"),
}

local function DruidRestoHeal()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end

  for _, v in pairs(Heal.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit
    local prio = v.Priority

    if prio > 25 and u:HasBuffByMe("Rejuvenation") and spells.Swiftmend:CastEx(u) then return end
    if prio > 1 and not u:HasBuffByMe("Rejuvenation") and spells.Rejuvenation:CastEx(u) then return end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidRestoHeal,
  }
}
