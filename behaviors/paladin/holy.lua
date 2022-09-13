local common = require('behaviors.paladin.common')

local options = {
    Name = "Paladin (Holy)",
    Widgets = {
        {
            type = "slider",
            uid = "HolyLightAmt",
            text = "Holy Light Heal Amount",
            default = 4000,
            min = 0,
            max = 10000
        },
        {
            type = "slider",
            uid = "FlashOfLightAmt",
            text = "Flash Of Light Heal Amount",
            default = 1500,
            min = 0,
            max = 10000
        },
        {
            type = "slider",
            uid = "HolyShockAmt",
            text = "Holy Shock Heal Amount",
            default = 1500,
            min = 0,
            max = 10000
        },
        {
            type = "slider",
            uid = "HandOfProtectionPct",
            text = "Hand Of Protection %",
            default = 25,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "LayOnHandsPct",
            text = "Lay on Hands %",
            default = 10,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "HandOfSacrificePct",
            text = "Hand of Sacrifice % (FOCUS)",
            default = 70,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "DPSHpct",
            text = "Damage Above Health Percent",
            default = 95,
            min = 0,
            max = 99
        }
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local function IsCastingHeal()
    return Me.CurrentCast == Spell.HolyLight or Me.CurrentCast == Spell.FlashOfLight
end

local function PaladinHolyHeal()
    common:DoAura()

    if Me.StandStance == StandStance.Sit then return end
    if Me.IsMounted then return end

    if not Me.InCombat then
        common:DoSeal()
        common:DoBuff()
    end

    local focus = Me.FocusTarget

    if focus and focus.InCombat then
        if not focus:HasBuffByMe(Spell.BeaconOfLight.Name) and Spell.BeaconOfLight:CastEx(focus) then return end
        if focus.HealthPct <= Settings.HandOfSacrificePct and Spell.HandOfSacrifice:CastEx(focus) then return end
    end

    local spelltarget = WoWSpell:GetCastTarget()
    if Me.IsCasting and IsCastingHeal() and spelltarget then
        local hlost = spelltarget.HealthMax - spelltarget.Health
        if hlost < Settings.FlashOfLightAmt * 0.7 then Me:StopCasting() end
    end

    for _, v in pairs(Heal.PriorityList) do
        local u = v.Unit
        local hpct = u.HealthPct
        local hlost = u.HealthMax - u.Health

        if u.InCombat then
            if hpct <= Settings.LayOnHandsPct and Spell.LayOnHands:CastEx(u) then return end
            if hpct <= Settings.HandOfProtectionPct and Spell.HandOfProtection:CastEx(u) then return end
        end

        if hlost >= Settings.HolyShockAmt and Spell.HolyShock:CastEx(u) then return end
        if hlost >= Settings.HolyLightAmt and Spell.HolyLight:CastEx(u) and
            u:TimeToDeath() + 3 >= Spell.HolyLight.CastTime / 1000 then return end
        if hlost >= Settings.FlashOfLightAmt and Spell.FlashOfLight:CastEx(u) then return end
    end
end

local function PaladinHolyDamage()
    if Me.StandStance == StandStance.Sit then return end
    if Me.IsMounted then return end

    local lowest = Heal:GetLowestMember()

    local target = Me.Target
    if not target or not Me:CanAttack(target) or target.Dead then return end
    local aoe = #Me:GetUnitsAround(8) > 2

    -- Only continue if the lowest group member is above this percent
    if not lowest or lowest and lowest.HealthPct <= Settings.DPSHpct then return end
    if Spell.HammerOfWrath:CastEx(target) then return end
    if not target:HasDebuffByMe(Spell.JudgementOfLight.Name) and Spell.JudgementOfLight:CastEx(target) then return end
    if Spell.Exorcism:CastEx(target) then return end
    if aoe and Spell.Consecration:CastEx(Me) then return end
end

local behaviors = {
    [BehaviorType.Heal] = PaladinHolyHeal,
    [BehaviorType.Combat] = PaladinHolyDamage
}

return { Options = options, Behaviors = behaviors }
