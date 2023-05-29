local common = require('behaviors.wow_retail.Pallas.shaman.common')

local options = {
    -- The sub menu name
    Name = "Shaman (Elemental)",
    -- widgets
    Widgets = {
        {
            type = "checkbox",
            uid = "ShamanUseCooldowns",
            text = "Allow the usage of Big Cooldowns",
            default = true
        },
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local flag = false;

local function IsSurgeOfPower()
    return Me:HasVisibleAura("Surge of Power")
end

local function IsMasterOfTheElements()
    return Me:HasVisibleAura("Master of the Elements")
end

local function IsStormkeeper()
    return Me:HasVisibleAura("Stormkeeper")
end

local function IsPrimordialWave()
    return Me:HasVisibleAura("Primordial Wave")
end

local function IsPowerOfTheMaelstrom()
    return Me:HasVisibleAura("Power of the Maelstrom")
end

local function TotemicRecall()
    if Spell.LiquidMagmaTotem:CooldownRemaining() > 3000 and Spell.TotemicRecall:CastEx(Me) then return true end
end

local function LiquidMagmaTotem()
    if Spell.LiquidMagmaTotem:CastEx(Me) then return true end
end

local function StormkeeperNoAscendance()
    if (not Me:HasVisibleAura("Ascendance")) and Spell.Stormkeeper:CastEx(Me) then return true end
end

local function LavaBurstWithStormkeeper(target)
    if IsStormkeeper() and not (IsMasterOfTheElements() or IsSurgeOfPower()) and Spell.LavaBurst:CastEx(target) then return true end
end

local function LavaBurstWithPrimordialWave(target)
    if IsPrimordialWave() and Spell.LavaBurst:CastEx(target) then return true end
end

local function LavaBurstWithFlameShock(target)
    if (target:HasAura("Flame Shock") or #target:GetUnitsAround(20) > 2) and Spell.LavaBurst:CastEx(target) then return true end
    for _, u in pairs(Combat.Targets) do
        local flameShockAura = u:GetAuraByMe("Flame Shock")
        if (flameShockAura) and Spell.LavaBurst:CastEx(u) then return true end
    end
end

local function LightningBoltWithSurgeOfPower(target)
    if IsSurgeOfPower() and Spell.LightningBolt:CastEx(target) then return true end
end

local function ElementalBlast(target)
    if Spell.ElementalBlast:CastEx(target) then return true end
end

local function LavaBurst(target)
    if Spell.LavaBurst:CastEx(target) then return true end
end

local function Earthquake(target)
    if Spell.Earthquake:CastEx(target) then return true end
end

local function FlameOrFrostShockMoving(target)
    if Me:IsMoving() then
        if Spell.FlameShock:CastEx(target) or Spell.FrostShock:CastEx(target) then return true end
    end
end

local function Stormkeeper()
    if Spell.Stormkeeper:CastEx(Me) then return true end
end

local function LavaBeamOrChainLightning(target)
    if (Spell.LavaBeam:CastEx(target) or Spell.ChainLightning:CastEx(target)) then return true end
end

local function ChainLightningMulti(target)
    if IsStormkeeper() or IsPowerOfTheMaelstrom() or IsSurgeOfPower() then
        LavaBeamOrChainLightning(target)
    end
end

-- Loop through all units find one without flame shock or lowest duration to cast Primordial Wave
local function PrimordialWave()
    local lowestDuration = nil
    local unitToCastAt = nil
    for _, u in pairs(Combat.Targets) do
        local flameShockAura = u:GetAuraByMe("Flame Shock")
        if (not flameShockAura) and Spell.PrimordialWave:CastEx(u) then return true end
        if flameShockAura and ((not lowestDuration) or lowestDuration > flameShockAura.Remaining) then
            lowestDuration = flameShockAura.Remaining
            unitToCastAt = u
        end
    end
    if (unitToCastAt) and Spell.PrimordialWave:CastEx(unitToCastAt) then return true end
end




local function ShamanElementalCombat()
    if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end
    local target = Combat.BestTarget
    if not target then return end
    if Me.IsCastingOrChanneling then return end




    if common:AstralShift() then return end
    if common:EarthShield() then return end
    if common:LightningShield() then return end
    if common:FlametongueWeapon() then return end

    if common:DoInterrupt() then return end

    if common:FireElemental(target) then return end

    if #target:GetUnitsAround(20) > 2 then
        --MULTI TARGET
        if Stormkeeper() then return end
        if PrimordialWave() then return end
        if common:FlameShock() then return end
        if common:EarthShock(target) then return end
        if LiquidMagmaTotem() then return end
        if LavaBurstWithPrimordialWave() then return end
        if #target:GetUnitsAround(20) > 3 then
            if Earthquake(target) then return end
        else
            if ElementalBlast(target) then return end
        end
        if ChainLightningMulti(target) then return end
        if LavaBurstWithFlameShock(target) then return end
        if LavaBeamOrChainLightning(target) then return end
        if FlameOrFrostShockMoving(target) then return end
    else
        -- SINGLE TARGET
        if TotemicRecall() then return end
        if LiquidMagmaTotem() then return end
        if PrimordialWave() then return end
        if common:FlameShock() then return end
        if common:EarthShock(target) then return end
        if StormkeeperNoAscendance() then return end
        if LavaBurstWithStormkeeper(target) then return end
        if LightningBoltWithSurgeOfPower(target) then return end
        if ElementalBlast(target) then return end
        if LavaBurst(target) then return end
        if common:LightningBolt(target) then return end
        if FlameOrFrostShockMoving(target) then return end
    end
end

local behaviors = {
        [BehaviorType.Combat] = ShamanElementalCombat
}

return { Options = options, Behaviors = behaviors }
