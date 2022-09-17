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

    -- Cast regrowth if target is under 60% health and has no hots
    if u.HealthPct < 92 and not u:HasBuffByMe("Rejuvenation") and Spell.Rejuvenation:CastEx(u) then return end
    if u.HealthPct < 40 and (u:HasBuffByMe("Rejuvenation") or u:HasBuffByMe("Regrowth")) and Spell.Swiftmend:CastEx(u, SpellCastExFlags.NoUsable) then return end
    if u.HealthPct < 60 and (not u:HasBuffByMe("Regrowth")) and Spell.Regrowth:CastEx(u) then return end
    if u.HealthPct < 30 and u:HasBuffByMe("Regrowth") and Spell.Regrowth:CastEx(u) then return end
    if u.HealthPct < 80 and u.InCombat and table.length(Heal.Tanks) == 0 and (not lifebloom or lifebloom.Stacks < 3) and Spell.Lifebloom:CastEx(u) then return end
  end

  for _, v in pairs(Heal.Tanks) do
    ---@type WoWUnit
    local u = v.Unit

    -- this is a mess but works
    local lifebloom = u:GetAuraByMe("Lifebloom")
    if not lifebloom and u.InCombat and Spell.Lifebloom:CastEx(u) then return end
    if lifebloom and u.InCombat then
      if lifebloom.Stacks < 3 and u.HealthPct > 80 and Spell.Lifebloom:CastEx(u) then return end
      if lifebloom.Stacks < 3 and lifebloom.Remaining > 2500 and u.HealthPct < 80 and Spell.Lifebloom:CastEx(u) then return end
      if lifebloom.Remaining < 1500 and u.HealthPct > 70 and Spell.Lifebloom:CastEx(u) then return end
    end
  end
end

return {
  Behaviors = {
    [BehaviorType.Heal] = DruidRestoHeal,
  }
}
