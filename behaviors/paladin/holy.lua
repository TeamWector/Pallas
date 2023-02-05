---@diagnostic disable: param-type-mismatch
local common = require('behaviors.paladin.common')
local dispels = require('data.dispels')

local options = {
    Name = "Paladin (Holy)",
    Widgets = {
        {
            type = "slider",
            uid = "HolyLightAmt",
            text = "Holy Light Amount",
            default = 6000,
            min = 0,
            max = 20000
        },
        {
            type = "slider",
            uid = "FlashOfLightAmt",
            text = "Flash of Light Amount",
            default = 1500,
            min = 0,
            max = 10000
        },
        {
            type = "slider",
            uid = "HolyShockAmt",
            text = "Holy Shock Amount",
            default = 1500,
            min = 0,
            max = 10000
        },
        {
            type = "slider",
            uid = "HandOfProtectionPct",
            text = "Hand of Protection Threshold (%)",
            default = 25,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "LayOnHandsPct",
            text = "Lay on Hands Threshold (%)",
            default = 10,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "HandOfSacrificePct",
            text = "Hand of Sacrifice Threshold Focus (%)",
            default = 70,
            min = 0,
            max = 99
        },
        {
            type = "slider",
            uid = "DPSManaPct",
            text = "DPS Above Mana Threshold (%)",
            default = 70,
            min = 0,
            max = 99
        }
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local function Dispel(...)
    local dispelTypes = {...}
    local group = WoWGroup:GetGroupUnits()

    for _, unit in pairs(group) do
        local auras = unit.VisibleAuras
        for _, aura in pairs(auras) do
            if aura.IsDebuff and dispels[aura.Id] then
                for _, dispelType in pairs(dispelTypes) do
                    if dispels[aura.Id] == dispelType then
                        return Spell.Cleanse:CastEx(unit)
                    end
                end
            end
        end
    end
end

local function IsCastingHeal()
    return Me.IsCasting and (Me.CurrentCast == Spell.HolyLight or Me.CurrentCast == Spell.FlashOfLight)
end

-- We should never heal the target with beacon of light directly. So this functions returns another unit.
local function BeaconLogic()
    for _, v in pairs(Heal.PriorityList) do
        local unit = v.Unit
        local hlost = unit:GetHealthLost()

        if not unit:HasBuffByMe(Spell.BeaconOfLight.Name) and hlost > 0 and Spell.HolyLight:InRange(unit) then
            return unit
        end
    end

    return Me
end

local function PaladinHolyHeal()
    local spelltarget = WoWSpell:GetCastTarget()
    if IsCastingHeal() and spelltarget then
        local hlost = spelltarget:GetHealthLost()
        if hlost < Settings.FlashOfLightAmt * 0.7 and
            (not Me.FocusTarget or Me.FocusTarget:GetHealthLost() < Settings.FlashOfLightAmt * 0.7) then
            Me:StopCasting()
        end
    end

    if Me.IsCastingOrChanneling then return end

    common:DoAura()

    if Me.StandStance == StandStance.Sit then return end
    if Me.IsMounted then return end

    if not Me.InCombat then
        common:DoSeal()
        common:DoBuff()
        common:Blessings()
    end

    local focus = Me.FocusTarget
    local lowest = Heal:GetLowestMember()

    if not lowest then
        common:DivinePlea()
    end

    if not lowest or lowest:GetHealthLost() < Settings.FlashOfLightAmt then
        Dispel("Magic", "Poison", "Disease")
    end

    if focus then
        if not lowest or lowest.HealthPct > 50 then
            if not focus:HasBuffByMe(Spell.BeaconOfLight.Name) and Spell.BeaconOfLight:CastEx(focus) then return end
            if not focus:HasBuffByMe(Spell.SacredShield.Name) and Spell.SacredShield:CastEx(focus) then return end
        end
        if focus.InCombat and focus.HealthPct <= Settings.HandOfSacrificePct and Spell.HandOfSacrifice:CastEx(focus) then return end
    end

    for _, v in pairs(Heal.PriorityList) do
        local u = v.Unit
        local hpct = u.HealthPct
        local hlost = u:GetHealthLost()
        local isTank = WoWGroup(GroupType.Auto).InGroup and
            WoWGroup(GroupType.Auto):GetMemberByGuid(u.Guid).GroupRole == "Tank"
        local healTarget = u

        if u:HasBuffByMe(Spell.BeaconOfLight.Name) then
            healTarget = BeaconLogic()
        end

        if u.InCombat then
            if hpct <= Settings.LayOnHandsPct and #u:GetUnitsAround(10) > 0 and Spell.LayOnHands:CastEx(u) then return end
            if not isTank and hpct <= Settings.HandOfProtectionPct and #u:GetUnitsAround(10) > 0 and
                Spell.HandOfProtection:CastEx(u) then return end
        end

        if hlost > Settings.HolyLightAmt * 1.5 then
            Spell.DivineFavor:CastEx(Me)
        end

        if hlost >= Settings.HolyShockAmt and Spell.HolyShock:CastEx(healTarget) then return end
        if hlost >= Settings.HolyLightAmt and u:TimeToDeath() + 3 >= Spell.HolyLight.CastTime / 1000 and
            Spell.HolyLight:CastEx(healTarget)
        then return end
        if hlost >= Settings.FlashOfLightAmt and Spell.FlashOfLight:CastEx(healTarget) then return end
    end
end

local function PaladinHolyDamage()
    local target = Combat.BestTarget
    if not target or Me.IsCastingOrChanneling or Me.StandStance == StandStance.Sit or Me.IsMounted or target.Dead then return end

    local aoe = Combat:GetEnemiesWithinDistance(8) > 1
    local lowest = Heal:GetLowestMember()
    local shouldAttack = not lowest or lowest:GetHealthLost() < Settings.FlashOfLightAmt

    if shouldAttack and common:Judgement(target) then return end

    if not shouldAttack or Me.PowerPct < Settings.DPSManaPct then return end

    if common:HammerOfWrath() then return end
    if Spell.Exorcism:CastEx(target) then return end
    if aoe and Spell.Consecration:CastEx(target) then return end
    if aoe and common:HolyWrath() then return end
end

local behaviors = {
    [BehaviorType.Heal] = PaladinHolyHeal,
    [BehaviorType.Combat] = PaladinHolyDamage
}

return { Options = options, Behaviors = behaviors }
