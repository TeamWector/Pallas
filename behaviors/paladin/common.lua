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
        options = { "Judgement of Wisdom", "Judgement of Light", "Judgement of Justice" }
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
        uid = "Blessings",
        text = "Auto Bless Companions",
        default = true
    },
    {
        type = "checkbox",
        uid = "Crusader",
        text = "Auto Crusader Aura",
        default = true
    },
}

function commonPaladin:Blessings()
    if not Settings.Blessings then return end

    local classBlessings = {
        [ClassType.Rogue] = { Spell.BlessingOfKings, Spell.BlessingOfMight },
        [ClassType.Warrior] = { Spell.BlessingOfMight, Spell.BlessingOfKings },
        [ClassType.DeathKnight] = { Spell.BlessingOfKings, Spell.BlessingOfMight },
        [ClassType.Druid] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
        [ClassType.Hunter] = { Spell.BlessingOfMight, Spell.BlessingOfKings },
        [ClassType.Mage] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
        [ClassType.Shaman] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
        [ClassType.Warlock] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
        [ClassType.Priest] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom },
        [ClassType.Paladin] = { Spell.BlessingOfKings, Spell.BlessingOfWisdom }
    }

    local group = WoWGroup:GetGroupUnits()
    for _, member in ipairs(group) do
        local isBuffedByMe = member:HasBuffByMe(Spell.BlessingOfKings.Name) or
            member:HasBuffByMe(Spell.BlessingOfWisdom.Name) or member:HasBuffByMe(Spell.BlessingOfMight.Name)
        local class = member.Class
        local blessings = classBlessings[class]

        for _, blessing in ipairs(blessings) do
            if not isBuffedByMe and not member:HasAura(blessing.Name) and blessing:CastEx(member) then
                return
            end
        end
    end
end

function commonPaladin:DivinePlea()
    return Me.PowerPct <= Settings.PleaPct and Spell.DivinePlea:CastEx(Me)
end

function commonPaladin:HolyWrath()
    for _, u in pairs(Combat.Targets) do
        local correctType = u.CreatureType == CreatureType.Undead and not u.Dead and u.isAttackable
        if correctType and Me:GetDistance(u) < 8 and Spell.HolyWrath:CastEx(u) then return end
    end
end

function commonPaladin:HammerOfWrath()
    for _, u in pairs(Combat.Targets) do
        if u.HealthPct < 20 and Spell.HammerOfWrath:CastEx(u, SpellCastExFlags.NoUsable) then return end
    end
end

function commonPaladin:Judgement(target)
    local spells = { Spell.JudgementOfWisdom, Spell.JudgementOfLight, Spell.JudgementOfJustice }
    local option = Settings.PaladinJudge
    return spells[option + 1]:CastEx(target)
end

function commonPaladin:GetAuraOption()
    local options = { Spell.DevotionAura, Spell.RetributionAura, Spell.ConcentrationAura, Spell.ShadowResistanceAura,
        Spell.FrostResistanceAura, Spell.FireResistanceAura }
    local option = Settings.PaladinAura
    return options[math.min(option + 1, #options)]
end

function commonPaladin:DoAura()
    if Settings.Crusader and Me.IsMounted then
        if not Me:HasVisibleAura(Spell.CrusaderAura.Name) then
            return Spell.CrusaderAura:CastEx(Me)
        end
        return
    end

    local options = { Spell.DevotionAura, Spell.RetributionAura, Spell.ConcentrationAura, Spell.ShadowResistanceAura,
        Spell.FrostResistanceAura, Spell.FireResistanceAura }
    local option = Settings.PaladinAura
    local aura = options[math.min(option + 1, #options)] or options[1]
    if not Me:HasBuffByMe(aura.Name) then
        return aura:CastEx(Me)
    end
end

function commonPaladin:DoSeal()
    local seals = { Spell.SealOfWisdom, Spell.SealOfLight, Spell.SealOfRighteousness, Spell.SealOfCorruption,
        Spell.SealOfJustice, Spell.SealOfCommand }
    local option = Settings.PaladinSeal
    local seal = seals[math.min(option + 1, #seals)] or Spell.SealOfWisdom
    if not Me:HasBuffByMe(seal.Name) and seal:CastEx(Me) then return end
end

function commonPaladin:DoBuff()
    local spells = { Spell.BlessingOfWisdom, Spell.BlessingOfKings, Spell.BlessingOfMight, Spell.BlessingOfSanctuary }
    local option = Settings.PaladinBuff
    local buff = spells[math.min(option + 1, #spells)]
    if not Me:HasBuffByMe(buff.Name) then buff:CastEx(Me) end
end

return commonPaladin
