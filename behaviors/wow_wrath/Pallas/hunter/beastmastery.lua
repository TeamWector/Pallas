local options = {
    Name = "Hunter (Beastmastery)",

    Widgets = {
    }
}

local function PetAttack(target)
    if not Me.Pet then return end
    if not Me.Pet.Target or Me.Pet.Target ~= target then Me:PetAttack(target) end
    if Me.Pet.Target and Me.Pet:GetDistance(Me.Pet.Target) < 9 then Spell.Prowl:CastEx(Me.Pet) end
    Spell.Growl:CastEx(target)
    Spell.Rake:CastEx(target)
    Spell.Claw:CastEx(target)
end

local function PetFollow()
    if not Me.Pet then return end
    if Me.Pet.Target then Me:PetFollow() end
end

local function PetSmart()
    if not Me.Pet then return end
    local mend = Me.Pet:GetAura(Spell.MendPet.Name)
    if Me.Pet.HealthPct < 90 and (not mend or mend.Remaining < 3000) and Spell.MendPet:CastEx(Me) then return end
end

local function HunterBeastmasteryCombat()
    if Me.IsMounted then return end

    if not Me:HasAura(Spell.AspectOfTheHawk.Name) and Spell.AspectOfTheHawk:CastEx(Me) then return end
    PetSmart()

    local target = Combat.BestTarget
    if not target then PetFollow() return end

    PetAttack(target)

    if Me.InCombat and target.HealthPct == 100 and Spell.BloodFury:CastEx(Me) then return end
    if not target:HasDebuffByMe(Spell.HuntersMark.Name) and Spell.HuntersMark:CastEx(target) then return end
    if Spell.ArcaneShot:CastEx(target) then return end

    if Me:InMeleeRange(target) then
        if Spell.RaptorStrike:CastEx(target) then return end
    end
end

local behaviors = {
    [BehaviorType.Combat] = HunterBeastmasteryCombat
}

return { Options = options, Behaviors = behaviors }
