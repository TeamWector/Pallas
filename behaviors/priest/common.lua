local commonPriest = {}

commonPriest.widgets = {
    {
        type = "checkbox",
        uid = "InnerFire",
        text = "Inner Fire",
        default = false
    },
    {
        type = "checkbox",
        uid = "PWDFSelf",
        text = "Power Word: Fortitude Self",
        default = false
    },
    {
        type = "slider",
        uid = "PWDSPercent",
        text = "Power Word: Shield Below %",
        default = 95,
        min = 0,
        max = 100
    },
}



function commonPriest:PowerWordFortitude()
    if not Settings.PWDFSelf then return end
    local pwdf = Me:GetAura(Spell.PowerWordFortitude.Name)

    if not pwdf or pwdf.Remaining < 60000 then
        if Spell.PowerWordFortitude:CastEx(Me) then return end
    end
end

function commonPriest:PowerWordShield()
    if Settings.PWDSPercent == 0 then return end

    if not Me:HasAura(Spell.PowerWordShield.Name) and not Me:HasAura("Weakened Soul") then
        if Me.HealthPct <= Settings.PWDSPercent and Spell.PowerWordShield:CastEx(Me) then return end
    end
end

function commonPriest:InnerFire()
    if not Settings.InnerFire then return end

    if not Me:HasAura(Spell.InnerFire.Name) and Spell.InnerFire:CastEx(Me) then return end
end

return commonPriest
