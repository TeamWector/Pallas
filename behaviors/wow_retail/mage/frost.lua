local common = require('behaviors.wow_retail.mage.common')

local options = {
    -- The sub menu name
    Name = "Mage (Frost)",

    -- widgets  TODO
    Widgets = {
        {
            type = "checkbox",
            uid = "FrostMageIceBlock",
            text = "Enable IceBlock Use",
            default = false
        },
        {
            type = "slider",
            uid = "FrostMageIceBlockPercent",
            text = "HP Percent to Ice Blockt",
            default = 19,
            min = 1,
            max = 100
        },
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local function IceBlock()
    if Settings.FrostMageIceBlock and Me.HealthPct <= Settings.FrostMageIceBlockPercent and not Me:HasVisibleAura("Hypothermia") then
        if Spell.IceBlock:CastEx(Me) then return true end
    end
end

local function IceBarrier()
    if not Me:HasVisibleAura("Ice Barrier") then
        if Spell.IceBarrier:CastEx(Me) then return true end
    end
end

local function IceNova(target)
    if Spell.IceNova:CastEx(target) then return true end
end

local function RuneOfPower()
    if (not Spell.IcyVeins.IsKnown or Spell.IcyVeins:CooldownRemaining() > 10000) and not Me:HasVisibleAura("Rune of Power") and
        (not Me:IsMoving()) then
        if Spell.RuneOfPower:CastEx(Me) then return true end
    end
end

local function IcyVeins()
    if not Me:HasVisibleAura("Rune of Power") then
        if Spell.IcyVeins:CastEx(Me) then return true end
    end
end

local function Blizzard(target)
    if Spell.Blizzard:CastEx(target) then return true end
end

local function Flurry(target)
    if not target:HasAura("Winter's Chill") then
        if Spell.Flurry:CastEx(target) then return true end
    end
end

local function FrozenOrb(target)
    if Me:IsFacing(target) and Spell.FrozenOrb:CastEx(target) then return true end
end

local function CometStorm(target)
    if Spell.CometStorm:CastEx(target) then return true end
end

local function IceLance(target)
    if (target:HasAura("Winter's Chill") or Me:HasVisibleAura("Fingers of Frost") or (Me:IsMoving())) and Spell.IceLance:CastEx(target) then return true end
end

local function Frostbolt(target)
    if Me:IsMoving() then return end
    if Spell.Frostbolt:CastEx(target) then return true end
end

local function MageRest()
    common:ArcaneIntellect()
end

local function MageFrostCombat()

    if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

    if IceBlock() then return end


    local target = Combat.BestTarget
    if not target then return end
    if Me.IsCastingOrChanneling then return end

    if IceBarrier() then return end

    if common:DoInterrupt() then return end

    if RuneOfPower() then return end
    if IcyVeins() then return end


    if Combat:GetEnemiesWithinDistance(39) > 2 then
        -- multitarget rotation
        if FrozenOrb(target) then return end
        if Blizzard(target) then return end
        if IceNova(target) then return end
        if Flurry(target) then return end
    else
        -- singletarget rotation
        if Flurry(target) then return end
        if FrozenOrb(target) then return end
    end

    if CometStorm(target) then return end
    if IceLance(target) then return end
    if Frostbolt(target) then return end
end

local behaviors = {
    [BehaviorType.Combat] = MageFrostCombat,
    [BehaviorType.Rest] = MageRest
}

return { Options = options, Behaviors = behaviors }
