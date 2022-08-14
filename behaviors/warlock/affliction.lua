local options = {
    -- The sub menu name
    Name = "Warlock (Affli)",

    -- widgets
    Widgets = {
        { "checkbox", "WandFinish", "Wand Finisher", false },
        { "slider", "LifeTapPercent", "Life Tap %", 90, 0, 100 },
        { "slider", "WandExecutePercent", "Wand Finish %", 30, 0, 60 },
    }
}



local spells = {
    DemonArmor = WoWSpell("Demon Armor"),
    LifeTap = WoWSpell("Life Tap"),
    CurseOfAgony = WoWSpell("Curse of Agony"),
    Corruption = WoWSpell("Corruption"),
    DrainLife = WoWSpell("Drain Life"),
    ShadowBolt = WoWSpell("Shadow Bolt"),
    Shoot = WoWSpell("Shoot")
}

local function IsDotted(unit)
    local agony = false
    local corruption = false

    local auras = unit.Auras
    for _, aura in pairs(auras) do
        if aura.Name == "Corruption" and aura.Caster.IsPlayer then
            corruption = true
        end

        if aura.Name == "Curse of Agony" and aura.Caster.IsPlayer then
            agony = true
        end
    end

    return agony and corruption
end

-- Threshold % on me for LifeTap
local HPThresh = 90
-- Threshold % on enemy for using spells
local SpellThresh = 30

local function WarlockAfflictionCombat()
    -- buff up
    if not Me:HasBuff("Demon Armor") then
        if spells.DemonArmor:CanUse() then
            if spells.DemonArmor:Cast(Me) then
                return
            end
        end
    end

    -- Omegalul workaround
    if Me:GetHealthPercent() >= HPThresh and Me.PowerPct < 90 and not Me.IsCastingOrChanneling then
        if spells.LifeTap:CanUse() then
            spells.LifeTap:Cast(Me)
        end
    end

    -- Make sure we have a target before continuing
    local target = Combat.BestTarget
    if not target then return end

    -- Only do this when pet is active
    if Me.Pet then
        -- PetAttack my target
        if not Me.Pet.Target or Me.Pet.Target ~= Me.Target then
            Me:PetAttack(target)
        end

        -- set follow if no target
        if not target and Me.Pet.Target then
            Me:PetFollow()
        end
    end

    if Me:HasBuff("Shadow Trance") and spells.ShadowBolt:CanUse(target) then
        spells.ShadowBolt:Cast(target)
        return
    end

    -- Wand finisher, convert to percentage when that is implemented
    if target:GetHealthPercent() <= SpellThresh then
        if not spells.Shoot.IsAutoRepeat and spells.Shoot:CanUse(target) then
            spells.Shoot:Cast(target)
        end

        return
    end

    -- If target doesnt have dots, stop wand to reapply dots.
    if not IsDotted(target) and spells.Shoot.IsAutoRepeat then
        Me:StopCasting()
    end

    if Me.IsCastingOrChanneling then return end

    if not target:HasDebuffByMe("Curse of Agony") then
        if spells.CurseOfAgony:CanUse(target) then
            spells.CurseOfAgony:Cast(target)
            return
        end
    end

    if not target:HasDebuffByMe("Corruption") then
        if spells.Corruption:CanUse(target) then
            spells.Corruption:Cast(target)
            return
        end
    end

    if spells.DrainLife:CanUse(target) and Me.PowerPct > 70 then
        spells.DrainLife:Cast(target)
    end

    -- Wand
    if IsDotted(target) and Me.PowerPct <= 70 then
        if not spells.Shoot.IsAutoRepeat and spells.Shoot:CanUse(target) then
            spells.Shoot:Cast(target)
            return
        end
    end
end

local behaviors = {
    [BehaviorType.Combat] = WarlockAfflictionCombat
}

return { Options = options, Behaviors = behaviors }
