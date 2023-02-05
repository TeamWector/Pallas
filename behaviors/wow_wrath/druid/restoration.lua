local function DruidRestoHeal()
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end
  if (Me.MovementFlags & MovementFlags.Flying) > 0 then return end
  if Me.ShapeshiftForm == ShapeshiftForm.Cat or Me.ShapeshiftForm == ShapeshiftForm.Bear or Me.ShapeshiftForm == ShapeshiftForm.DireBear then return end

  if Me.ShapeshiftForm ~= ShapeshiftForm.Travel then

  end

  local wildgrowth = false
  if table.length(Heal.PriorityList) > 3 then
    wildgrowth = true
  end

  for _, v in pairs(Heal.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit
    local prio = v.Priority
    local lifebloom = u:GetAuraByMe("Lifebloom")

    if wildgrowth and Spell.WildGrowth:CastEx(u) then return end

    if u.HealthPct < 92 and not u:HasBuffByMe("Rejuvenation") and Spell.Rejuvenation:CastEx(u) then return end
    if u.HealthPct < 50 and (u:HasBuffByMe("Rejuvenation") or u:HasBuffByMe("Regrowth")) and Spell.Swiftmend:CastEx(u, SpellCastExFlags.NoUsable) then return end

    -- Max level uses Nourish as filler, low level uses Regrowth
    if Spell.Nourish.IsKnown then
      if u.HealthPct < 70 and (u:HasBuffByMe("Rejuvenation") or u:HasBuffByMe("Regrowth") or u:HasBuffByMe("Wild Growth") or u:HasBuffByMe("Lifebloom")) and Spell.Nourish:CastEx(u) then return end
    else
      if u.HealthPct < 60 and (not u:HasBuffByMe("Regrowth") or u.HealthPct < 30) and Spell.Regrowth:CastEx(u) then return end
    end
  end

  --[[
  for _, v in pairs(Heal.PriorityList) do
    ---@type WoWUnit
    local unit = v.Unit
    local auras = unit.VisibleAuras
    for _, aura in pairs(auras) do
      if aura.DispelType ==
    end
  end
  ]]

  for _, v in pairs(Heal.Tanks) do
    ---@type WoWUnit
    local u = v.Unit

    -- this is a mess but works
    local lifebloom = u:GetAuraByMe("Lifebloom")
    if not lifebloom and u.InCombat and Spell.Lifebloom:CastEx(u) then return end
    if lifebloom and u.InCombat then
      if u.HealthPct < 90 and lifebloom.Stacks < 1 and Spell.Lifebloom:CastEx(u) then return end
      if u.HealthPct < 80 and lifebloom.Stacks < 2 and Spell.Lifebloom:CastEx(u) then return end
      if u.HealthPct < 70 and lifebloom.Stacks < 3 and Spell.Lifebloom:CastEx(u) then return end
      --if lifebloom.Remaining < 2500 and u.HealthPct > 70 and Spell.Lifebloom:CastEx(u) then return end
    end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidRestoHeal,
  }
}
