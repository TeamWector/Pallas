local commonShaman = {}

commonShaman.widgets = {
    {
        type = "checkbox",
        uid = "ShamanInterrupt",
        text = "Interrupt",
        default = true
    },
    {
        type = "checkbox",
        uid = "Ghostwolf",
        text = "Auto Ghostwolf",
        default = true
    },
}

function commonShaman:Interrupt()
    if Settings.ShamanInterrupt then
        local units = wector.Game.Units
        for _, u in pairs(units) do
            if u:InCombatWithMe() and u.IsCastingOrChanneling then
                if Spell.WindShear:CastEx(u) then return end
            end
        end
    end
end

function commonShaman:Ghostwolf()
    if Settings.Ghostwolf and Me:IsMoving() then
        if not Me:HasVisibleAura(Spell.Ghostwolf.Name) and Spell.Ghostwolf:CastEx(Me) then return end
    end
end

return commonShaman
