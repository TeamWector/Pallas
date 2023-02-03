local commonPaladin = {}

commonPaladin.widgets = {
    {
        type = "slider",
        uid = "PleaPct",
        text = "Divine Plea Below %",
        default = 85,
        min = 0,
        max = 99
    },
    {
        type = "combobox",
        uid = "PaladinJudge",
        text = "Select Judgement",
        default = 0,
        options = { "Judgement of Wisdom", "Judgement of Light", "Judgement of Justice"}
    },
    {
        type = "combobox",
        uid = "PaladinSeal",
        text = "Select Seal",
        default = 0,
        options = { "Seal of Wisdom", "Seal of Light", "Seal of Righteousness", "Seal of Corruption",
            "Seal of Justice", "Seal of Command" }
    },
    {
        type = "combobox",
        uid = "PaladinBuff",
        text = "Select Self Buff",
        default = 0,
        options = { "Blessing of Wisdom", "Blessing of Kings", "Blessing of Might", "Blessing of Sanctuary" }
    },
    {
        type = "combobox",
        uid = "PaladinAura",
        text = "Select Aura",
        default = 2,
        options = { "Devotion Aura", "Retribution Aura", "Concentration Aura", "Shadow Res Aura", "Frost Res Aura",
            "Fire Res Aura" }
    },
    {
        type = "checkbox",
        uid = "Crusader",
        text = "Auto Crusader Aura",
        default = true
    },
}

function commonPaladin:DivinePlea()
    return Me.PowerPct <= Settings.PleaPct and Spell.DivinePlea:CastEx(Me)
end

function commonPaladin:HolyWrath()
    local units = wector.Game.Units
    for _, u in pairs(units) do
        local correctType = u.CreatureType == 6 and not u.Dead
        if correctType and Me:GetDistance(u) < 8 and Spell.HolyWrath:CastEx(u) then return end
    end
end

function commonPaladin:HammerOfWrath()
    local units = wector.Game.Units
    for _, u in pairs(units) do
        local correctUnit = Me:GetDistance(u) < 30 and u.HealthPct <= 20 and Me:CanAttack(u) and not u.Dead
        if correctUnit and Spell.HammerOfWrath:CastEx(u) then return end
    end
end

function commonPaladin:Judgement(target)
    local option = Settings.PaladinJudge
    if option == 0 then
        return Spell.JudgementOfWisdom:CastEx(target)
    elseif option == 1 then
        return Spell.JudgementOfLight:CastEx(target)
    elseif option == 2 then
        return Spell.JudgementOfJustice:CastEx(target)
    end
end

function commonPaladin:GetSealOption()
    local option = Settings.PaladinSeal
    if option == 0 then
        return Spell.SealOfWisdom
    elseif option == 1 then
        return Spell.SealOfLight
    elseif option == 2 then
        return Spell.SealOfRighteousness
    elseif option == 3 then
        return Spell.SealOfCorruption
    elseif option == 4 then
        return Spell.SealOfJustice
    elseif option == 5 then
        return Spell.SealOfCommand
    end

    -- default to wisdom..
    return Spell.SealOfWisdom
end

function commonPaladin:GetBuffOption()
    local option = Settings.PaladinBuff
    if option == 0 then
        return Spell.BlessingOfWisdom
    elseif option == 1 then
        return Spell.BlessingOfKings
    elseif option == 2 then
        return Spell.BlessingOfMight
    elseif option == 3 then
        return Spell.BlessingOfSanctuary
    end

    -- Default to wisdom..
    return Spell.BlessingOfWisdom
end

function commonPaladin:GetAuraOption()
    local option = Settings.PaladinAura
    if option == 0 then
        return Spell.DevotionAura
    elseif option == 1 then
        return Spell.RetributionAura
    elseif option == 2 then
        return Spell.ConcentrationAura
    elseif option == 3 then
        return Spell.ShadowResistanceAura
    elseif option == 4 then
        return Spell.FrostResistanceAura
    elseif option == 5 then
        return Spell.FireResistanceAura
    end

    -- Default to concentration..
    return Spell.ConcentrationAura
end

function commonPaladin:DoAura()
    if Settings.Crusader and Me.IsMounted then
        if not Me:HasVisibleAura(Spell.CrusaderAura.Name) and Spell.CrusaderAura:CastEx(Me) then return end
        return
    end

    local aura = self:GetAuraOption()
    if not Me:HasBuffByMe(aura.Name) and aura:CastEx(Me) then return end
end

function commonPaladin:DoSeal()
    local seal = self:GetSealOption()
    if not Me:HasBuffByMe(seal.Name) and seal:CastEx(Me) then return end
end

function commonPaladin:DoBuff()
    local buff = self:GetBuffOption()
    if not Me:HasBuffByMe(buff.Name) and buff:CastEx(Me) then return end
end

return commonPaladin
