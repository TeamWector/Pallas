local options = {
    Name = "Paladin (Holy)",
    Widgets = {
        {
            type = "checkbox",
            uid = "PaladinHolyDPS",
            text = "Enable DPS",
            default = false
        }
    }
}

-- for k, v in pairs(common.widgets) do
--     table.insert(options.Widgets, v)
-- end


local function PaladinHolyDamage()
    local target = Me.Target
    if not target then return end

    -- copy-paste from combat.lua
    if not Me:CanAttack(target) then
      return
    elseif not target.InCombat or (not Settings.PallasAttackOOC and not target.InCombat) then
      return
    elseif target.Dead or target.Health <= 0 then
      return
    elseif target:GetDistance(Me.ToUnit) > 40 then
      return
    elseif target.IsTapDenied and (not target.Target or target.Target ~= Me) then
      return
    elseif target:IsImmune() then
      return
    end

    if Spell.ShieldOfTheRighteous:CastEx(target) then return end
    if Spell.HammerOfWrath:CastEx(target) then return end
    if Spell.CrusaderStrike:CastEx(target) then return end
    if Spell.Judgment:CastEx(target) then return end
    if Spell.HolyShock:CastEx(target) then return end
    if Me:InMeleeRange(target) and Spell.Consecration:CastEx(Me) then return end

end



local function PaladinHolyHeal()
    if Me.Dead then return end
    if Me:IsStunned() then return end
    if Me.IsCastingOrChanneling then return end
    if Me.StandStance == StandStance.Sit then return end
    if (Me.MovementFlags & MovementFlags.Flying) > 0 then return end


    for _, v in pairs(Heal.PriorityList) do
        ---@type WoWUnit
        local u = v.Unit
        local prio = v.Priority

        if u.HealthPct < 15 and Spell.LayOnHands:CastEx(u) then return end
        if u.HealthPct < 70 and Spell.WordOfGlory:CastEx(u) then return end
        if u.HealthPct < 60 and Spell.FlashOfLight:CastEx(u) then return end
        if u.HealthPct < 80 and Spell.HolyShock:CastEx(u) then return end
        if u.HealthPct < 70 and Spell.HolyLight:CastEx(u) then return end

    end

    for _, v in pairs(Heal.Tanks) do
        ---@type WoWUnit
        local u = v.Unit

        if not u:HasBuffByMe("Beacon of Light") and Spell.BeaconOfLight:CastEx(u) then return end
    end

    if Settings.PaladinHolyDPS then
        PaladinHolyDamage()
    end
end

local behaviors = {
    [BehaviorType.Heal] = PaladinHolyHeal
}

return { Options = options, Behaviors = behaviors }
