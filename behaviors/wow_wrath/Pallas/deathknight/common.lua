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
        type = "slider",
        uid = "DeathPactPct",
        text = "Death Pact (%)",
        default = 20,
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
    {
        type = "checkbox",
        uid = "Trinket1",
        text = "Use Trinket1",
        default = false
    },
    {
        type = "checkbox",
        uid = "Trinket2",
        text = "Use Trinket2",
        default = false
    },
}

function commonDeathKnight:GetRuneCount(type)
    local count = 0

    for i = 0, 5 do
        if Me:GetRuneType(i) == type and Me:GetRuneCooldown(i) == 0 then
            count = count + 1
        end
    end

    return count
end

function commonDeathKnight:DoTrinkets(target)
    local trinket1 = WoWItem:GetUsableEquipment(EquipSlot.Trinket1)
    local trinket2 = WoWItem:GetUsableEquipment(EquipSlot.Trinket2)

    if not target then target = Me end

    if Settings.Trinket1 and trinket1 and trinket1:UseX(Me) then return end
    if Settings.Trinket2 and trinket2 and trinket2:UseX(Me) then return end
end

function commonDeathKnight:HornOfWinter()
    local hornofWinter = Me:GetAura(Spell.HornOfWinter.Name)

    return Settings.HornOfWinter and (not hornofWinter or hornofWinter.Remaining < 30000) and
        Spell.HornOfWinter:CastEx(Me)
end

--- Uses blood tap if we dont have any blood runes at all left.
function commonDeathKnight:BloodTap()
    return self:GetRuneCount(RuneType.Blood) == 0 and Spell.BloodTap:CastEx(Me)
end

function commonDeathKnight:DeathAndDecay()
    local avgdeath = Combat:TargetsAverageDeathTime()
    local blood = self:GetRuneCount(RuneType.Blood)
    local unholy = self:GetRuneCount(RuneType.Unholy)
    local frost = self:GetRuneCount(RuneType.Frost)

    if blood > 0 and (unholy == 0 or frost == 0) then
        self:BloodTap()
    end

    -- avgdeath needed to make most of our death and decay.
    return avgdeath > 15 and Spell.DeathAndDecay:CastEx(Me)
end

function commonDeathKnight:PathOfFrost()
    return Settings.PathOfFrost and not Me:HasVisibleAura(Spell.PathOfFrost.Name) and Spell.PathOfFrost:CastEx(Me)
end

---@param range integer The range around me to check for diseases
---@return boolean EveryoneDisesased All Targets within range yards have disesases on them.
function commonDeathKnight:EveryoneDiseased(range)
    for _, u in pairs(Combat.Targets) do
        if Me:GetDistance(u) < range and not self:TargetHasDiseases(u) then
            return false
        end
    end

    return true
end

function commonDeathKnight:ShouldPestilence()
    local avgdeath = Combat:TargetsAverageDeathTime()
    local alldiseased = self:EveryoneDiseased(15)

    return not alldiseased and avgdeath > 10
end

function commonDeathKnight:BloodBoil()
    local allcancer = self:EveryoneDiseased(10)
    local dndcd = Spell.DeathAndDecay:CooldownRemaining() > 5000

    return (dndcd or self:GetRuneCount(RuneType.Blood) == 2) and allcancer and Spell.BloodBoil:CastEx(Me)
end

--- Gets a unit with either plague or fever for optimal plague delivery.
function commonDeathKnight:GetDiseaseTarget()
    local targets = {}
    local defaults = {}

    for _, u in pairs(Combat.Targets) do
        local plague = u:GetAuraByMe(self.auras.bloodplague.Name)
        local fever = u:GetAuraByMe(self.auras.frostfever.Name)

        if Me:InMeleeRange(u) and (plague and plague.Remaining > 3000 or fever and fever.Remaining > 3000) then
            table.insert(targets, u)
        end
    end

    if table.length(targets) > 1 then
        table.sort(targets, function(x, y)
            return x:TimeToDeath() > y:TimeToDeath()
        end)
    end

    if targets[1] then
        return targets[1]
    end

    for _, u in pairs(Combat.Targets) do
        if Me:InMeleeRange(u) then
            table.insert(defaults, u)
        end
    end

    table.sort(defaults, function(x, y)
        return x.Health > y.Health
    end)

    if defaults[1] then
        return defaults[1]
    end

    return Combat.Targets[1]
end

function commonDeathKnight:DoDiseases(target)
    local plague = target:GetAuraByMe(self.auras.bloodplague.Name)
    local fever = target:GetAuraByMe(self.auras.frostfever.Name)

    if (not fever or fever.Remaining < 3000) and Spell.IcyTouch:CastEx(target) then return true end
    if (not plague or plague.Remaining < 3000) and Spell.PlagueStrike:CastEx(target) then return true end
end

--- Returns a target on which we can use pestilence on.
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

function commonDeathKnight:RuneTap(target)
    return Me.HealthPct <= Settings.DeathStrikePct and
        Spell.RuneTap:CastEx(Me)
end

function commonDeathKnight:DeathPact()
    return Me.HealthPct <= Settings.DeathPactPct and Me.Pet and Spell.DeathPact:CastEx(Me)
end

---@param unit WoWUnit
---@return boolean? HasDiseases
function commonDeathKnight:TargetHasDiseases(unit)
    local plague = unit:GetAuraByMe(self.auras.bloodplague.Name)
    local fever = unit:GetAuraByMe(self.auras.frostfever.Name)

    return plague and plague.Remaining > 3000 and fever and fever.Remaining > 3000
end

function commonDeathKnight:PestilenceRefresh(target)
    local fever = target:GetAuraByMe(self.auras.frostfever.Name)
    local plague = target:GetAuraByMe(self.auras.bloodplague.Name)
    return self:GetRuneCount(RuneType.Blood) > 0 and
        (plague and plague.Remaining < 3000 or fever and fever.Remaining < 3000) and Spell.Pestilence:CastEx(target)
end

---@return boolean shouldpest this both does pestilence and checks if we should
function commonDeathKnight:Pestilence()
    local pestTarget = self:GetPestilenceTarget()
    local shouldPest = self:ShouldPestilence()

    if not shouldPest then return false end

    if pestTarget then
        if Spell.Pestilence:CastEx(pestTarget) then return true end
    else
        local diseaseTarget = self:GetDiseaseTarget()
        if diseaseTarget and self:DoDiseases(diseaseTarget) then return true end
    end

    return true
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
