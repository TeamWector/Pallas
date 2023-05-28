local common = require('behaviors.paladin.common')
local options = {
    -- The sub menu name
    Name = "Paladin (Ret)",

    -- widgets
    Widgets = {
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local lastAttack = 0
local pause = false
local function MeleeAttack(target)
    if wector.Game.Time - lastAttack > 100 then pause = false end
    if pause then return end
    if not Me:IsAttacking(target) then
        Me:StartAttack(target)
        lastAttack = wector.Game.Time
        pause = true
    end
end

local function PaladinRetriHeal()
    common:DoAura()

    if Me.StandStance == StandStance.Sit then return end
    if Me.IsMounted then return end
    if Me.IsCastingOrChanneling then return end

    common:DoBuff()
    common:DoSeal()

    local lowest = Heal:GetLowestMember()
    local artofwar = Me:GetVisibleAura("The Art of War")
    local castTarget = WoWSpell.Target
    local currentSpell = Me.CurrentSpell
    if castTarget and currentSpell and currentSpell.Name == "Flash of Light" and castTarget.HealthPct > 95 then
        Me:StopCasting()
        return
    end

    if lowest then
        local healthLost = lowest.HealthMax - lowest.Health
        if lowest.HealthPct < 10 and lowest.InCombat and Spell.LayOnHands:CastEx(lowest) then return end
        if lowest.HealthPct < 65 and Spell.FlashOfLight:CastEx(lowest) then return end
        if artofwar and healthLost > 500 and Spell.FlashOfLight:CastEx(lowest) then return end
    end

    local target = Combat.BestTarget
    if not target then return end

    if target:HasVisibleAura(Spell.Repentance.Name) then return end

    --MeleeAttack(target)
    if Me:IsStunned() and Spell.HandOfFreedom:CastEx(Me) then return end
    if common:HammerOfWrath() then return end
    if Spell.JudgementOfLight:CastEx(target) then return end

    if artofwar and (not lowest or lowest.HealthPct > 95) and Spell.Exorcism:CastEx(target) then return end
    if Spell.CrusaderStrike:CastEx(target) then return end
    if Spell.DivineStorm:CastEx(target) then return end
    common:HolyWrath()
    if not Me:IsMoving() and Me:GetDistance(target) < 8 and Combat:TargetsAverageDeathTime() > 8 and
        Spell.Consecration:CastEx(Me) then return end
end

local function PaladinRetriCombat()
    Combat:Update()
end

local behaviors = {
    [BehaviorType.Heal] = PaladinRetriHeal,
    [BehaviorType.Combat] = PaladinRetriCombat
}

return { Options = options, Behaviors = behaviors }
