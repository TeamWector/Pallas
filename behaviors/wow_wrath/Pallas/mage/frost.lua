local common = require("behaviors.wow_wrath.Pallas.mage.common")
local options = {
    Name = "Mage (Frost)",
    Widgets = {

    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local GCD = WoWSpell(61304)
local function MageFrost()
    if Me.StandStance == StandStance.Sit then return end
    if Me.IsMounted then return end

    if not Me.InCombat then
        local ai = Me:GetVisibleAura(Spell.ArcaneIntellect.Name)
        local fa = Me:GetVisibleAura(Spell.FrostArmor.Name)
        local dm = Me:GetVisibleAura(Spell.DampenMagic.Name)

        if (not dm or dm.Remaining < 6000) and Spell.DampenMagic:CastEx(Me) then return end
        if (not ai or ai.Remaining < 60000) and Spell.ArcaneIntellect:CastEx(Me) then return end
        if (not fa or fa.Remaining < 60000) and Spell.FrostArmor:CastEx(Me) then return end
    end

    local target = Combat.BestTarget
    if not target then return end

    if Me.CurrentChannel and Me.CurrentChannel.Name == Spell.Evocation.Name then return end

    if common:Wand(target) then return end

    if GCD:CooldownRemaining() > 0 then return end
    common:Polymorph()

    if common:UseCooldowns(target) and target:TimeToDeath() > 10 then
        Spell.Berserking:CastEx(Me)
        Spell.IcyVeins:CastEx(Me)
    end

    if Spell.Frostbolt:CastEx(target) then return end
    if Spell.Frostbolt:CooldownRemaining() > 2000 and Spell.Fireball:CastEx(target) then return end
end

local behaviors = {
    [BehaviorType.Combat] = MageFrost
}
return { Options = options, Behaviors = behaviors }
