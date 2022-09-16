local commonDeathKnight = {}

-- We are using spells to get correct aura names
commonDeathKnight.auras = {
    frostfever = WoWSpell(55095),
    bloodplague = WoWSpell(55078),
    unholypresence = WoWSpell(48265),
    bloodpresence = WoWSpell(48266),
    frostpresence = WoWSpell(48263),
    desolation = WoWSpell(66803)
}

commonDeathKnight.widgets = {
    {
        type = "checkbox",
        uid = "MFInterrupt",
        text = "Mind Freeze Interrupt",
        default = true
    },
    {
        type = "checkbox",
        uid = "DGInterrupt",
        text = "Death Grip Interrupt Ranged",
        default = false
    },
    {
        type = "slider",
        uid = "InterruptTime",
        text = "Interrupt Time (MS)",
        default = 500,
        min = 0,
        max = 2000
    },
    {
        type = "slider",
        uid = "DeathStrikePct",
        text = "Death Strike (%)",
        default = 60,
        min = 0,
        max = 99
    },
    {
        type = "checkbox",
        uid = "HornOfWinter",
        text = "Horn of Winter",
        default = true
    },
    {
        type = "checkbox",
        uid = "PathOfFrost",
        text = "Path of Frost (OOC)",
        default = false
    },
}

function commonDeathKnight:HornOfWinter()
    if Settings.HornOfWinter and Spell.HornOfWinter:CastEx(Me) then return end
end

function commonDeathKnight:DeathAndDecay(target)
    local unitcount = table.length(Combat.Targets)
    local seconds = 0

    if unitcount < 3 then return end

    for _, u in pairs(Combat.Targets) do
        seconds = seconds + u:TimeToDeath()
    end

    local avgdeath = seconds / unitcount

    -- avgdeath needed to make most of our death and decay.
    return avgdeath > 15 and Spell.DeathAndDecay:CastEx(Me.Position)
end

function commonDeathKnight:PathOfFrost()
    return Settings.PathOfFrost and not Me:HasVisibleAura(Spell.PathOfFrost.Name) and Spell.PathOfFrost:CastEx(Me)
end

function commonDeathKnight:BloodBoil()
    local unitcount = table.length(Combat.Targets)
    local allcancer = true

    if unitcount < 3 then return end

    for _, u in pairs(Combat.Targets) do
        if Me:GetDistance(u) <= 10 and not self:TargetHasDiseases(u) then
            allcancer = false
        end
    end

    return allcancer and Spell.BloodBoil:CastEx(Me)
end

function commonDeathKnight:GetPestilenceTarget()
    if Me.Target and self:TargetHasDiseases(Me.Target) then
        return Me.Target
    end

    local units = Combat.Targets
    for _, u in pairs(units) do
        if Me:InMeleeRange(u) and self:TargetHasDiseases(u) then
            return u
        end
    end
end

function commonDeathKnight:DeathStrike(target)
    return Me.HealthPct <= Settings.DeathStrikePct and self:TargetHasDiseases(target) and
        Spell.DeathStrike:CastEx(target)
end

---@param unit WoWUnit
---@return boolean HasDiseases
function commonDeathKnight:TargetHasDiseases(unit)
    local plague = unit:GetAuraByMe(self.auras.bloodplague.Name)
    local fever = unit:GetAuraByMe(self.auras.frostfever.Name)

    return plague and plague.Remaining > 3000 and fever and fever.Remaining > 3000
end

function commonDeathKnight:Pestilence()
    local pestilencetarget = self:GetPestilenceTarget()
    for _, u in pairs(Combat.Targets) do
        if Me:GetDistance(u) <= 15 and not self:TargetHasDiseases(u) and pestilencetarget then
            if Spell.Pestilence:CastEx(pestilencetarget) then return end
        end
    end
end

local random = math.random(100, 200)
function commonDeathKnight:Interrupt()
    if not Settings.MFInterrupt and not Settings.DGInterrupt and not Settings.GnawSpell then return end
    local units = wector.Game.Units
    for _, u in pairs(units) do
        if u:InCombatWithMe() and u.CurrentSpell then
            local cast = u.CurrentCast
            local timeLeft = 0
            local channel = u.CurrentChannel

            if cast then
                timeLeft = cast.CastEnd - wector.Game.Time
            end

            if timeLeft <= Settings.InterruptTime + random or channel then
                if (Settings.MFInterrupt and Spell.MindFreeze:CastEx(u)) or
                    (Settings.DGInterrupt and Me:GetDistance(u) >= 10 and Spell.DeathGrip:CastEx(u)) or
                    (Settings.GnawSpell and Spell.Gnaw:CastEx(u)) then return end
            end
        end
    end
end

return commonDeathKnight
