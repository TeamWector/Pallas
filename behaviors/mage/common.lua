local commonMage = {}

commonMage.widgets = {
    {
        type = "combobox",
        uid = "MageCooldownType",
        text = "Use Cooldowns On",
        default = 0,
        options = { "None", "Everything", "Elites" }
    },
    {
        type = "slider",
        uid = "MageWandFinish",
        text = "Wand Finisher %",
        default = 0,
        min = 0,
        max = 100
    },
    {
        type = "checkbox",
        uid = "PolyAdd",
        text = "Polymorph Add",
        default = false
    },
}

MageListener = wector.FrameScript:CreateListener()
MageListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')

local PolyFix = 0
function MageListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, _, spellID)
    if unitTarget == Me and spellID == Spell.Polymorph.Id then
        PolyFix = wector.Game.Time + 100
    end
end

---@return boolean
---@param unit WoWUnit
function commonMage:UseCooldowns(unit)
    local uClass = unit.Classification
    local option = Settings.MageCooldownType

    if not Me:WithinLineOfSight(unit) or Me:GetDistance(unit) > 30 or Me:IsMoving() then return false end

    if option == 0 then return false end

    if option == 1 then return true end

    if option == 2 and uClass > 0 then return true end

    return false
end

function commonMage:Polymorph()
    if not Settings.PolyAdd then return end
    local shouldPoly = (wector.Game.Time - PolyFix) > 0
    if not shouldPoly then return end

    local anyPolyd = false
    local units = wector.Game.Units
    for _, target in pairs(units) do
        local poly = target:GetAuraByMe(Spell.Polymorph.Name)
        if poly and poly.Remaining > 3000 then
            anyPolyd = true
        end
    end

    if anyPolyd then return false end

    if not Me.InCombat then
        local around = Combat.BestTarget:GetUnitsAround(12)
        for _, target in pairs(around) do
            local reaction = target:GetReaction(Me.ToUnit)
            local validType = target.CreatureType == 1 or target.CreatureType == 7
            if validType and target ~= Combat.BestTarget and (reaction < 4 or target:InCombatWithMe()) and
                Me:CanAttack(target) then
                if Spell.Polymorph:CastEx(target) then return end
            end
        end
    end

    for _, target in pairs(units) do
        local validType = target.CreatureType == 1 or target.CreatureType == 7
        if validType and target ~= Combat.BestTarget and target:InCombatWithMe() then
            if Spell.Polymorph:CastEx(target) then return end
        end
    end
end

function commonMage:Wand(target)
    local cast = Me.CurrentCast
    local lowMob = target.Classification == 0
    if target.HealthPct <= Settings.MageWandFinish and lowMob or Me.PowerPct < 4 then
        if cast and cast:CastRemaining() > 1000 then
            Me:StopCasting()
        end

        if not Spell.Shoot.IsAutoRepeat then Spell.Shoot:CastEx(target) end
        return true
    end
end

return commonMage
