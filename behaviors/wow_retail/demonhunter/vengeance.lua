local common = require('behaviors.wow_retail.demonhunter.common')

local options = {
    -- The sub menu name
    Name = "Demonhunter (Vengeance)",

    -- widgets  TODO
    Widgets = {
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local run = false;

local function TheHunt(target)
    local frailtyAura = target:GetAura("Frailty")
    if frailtyAura and frailtyAura.Stacks > 2 and Spell.TheHunt:CastEx(target) then return end
end

local function SoulCarver(target)
    local frailtyAura = target:GetAura("Frailty")
    if frailtyAura and frailtyAura.Stacks > 5 and Spell.SoulCarver:CastEx(target) then return end
end

local function FelDevastation(target)
    if Me.Power >= 50 and Spell.FelDevastation:CastEx(target) then return end
end

local function SoulCleave(target)
    local frailtyAura = target:GetAura("Frailty")
    if frailtyAura and frailtyAura.Remaining > 3000 and Me.Power >= 60 then
        if Spell.ChaosStrike:CastEx(target) then return end
    end
end

local function DemonSpikes()
    -- todo revisit me charges is nil
    if Me.HealthPct < 55 and Spell.DemonSpikes.charges > 0 then
        if Spell.DemonSpikes:CastEx() then return end
    end
end

local function FieryBrand(target)
    if Me.HealthPct < 40 then
        if Spell.FieryBrand:CastEx(target) then return end
    end
end

local function SpiritBomb(target)
    local soulFragmentAura = Me:GetAura("Soul Fragments")
    if soulFragmentAura and soulFragmentAura.Stacks >= 5 and Me.Power >= 40 then
        if Spell.SpiritBomb:CastEx(target) then return end
    end
end

local function SigilOfFlame(target)
    if Me.Power < 70 and Spell.SigilOfFlame:CastEx(target) then return end
end

local function DemonhunterVengeanceCombat()
    local target = Combat.BestTarget
    if not target then return end

    if not Me:InMeleeRange(target) then
        if Spell.ThrowGlaive:CastEx(target) then return end
    end

    -- only melee spells from here on
    if not Me:InMeleeRange(target) or not Me:IsFacing(target) then return end

    common:DoInterrupt()
    FieryBrand(target)
    -- todo optional infernalStrike
    SpiritBomb(target)
    FelDevastation(target)

    if Combat.EnemiesInMeleeRange > 1 then
        common:UseTrinkets()
    end

    SoulCleave(target)
    if Spell.ImmolationAura:CastEx(Me) then return end
    TheHunt(target)
    SoulCarver(target)
    SigilOfFlame(target)

    -- Instead of Fracture, works for Shear as well.
    if Spell.DemonsBite:CastEx(target) then return end
    if Spell.ThrowGlaive:CastEx(target) then return end
    
end

local behaviors = {
    [BehaviorType.Combat] = DemonhunterVengeanceCombat
}

return { Options = options, Behaviors = behaviors }
