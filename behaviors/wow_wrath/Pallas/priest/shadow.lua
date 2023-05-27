local common = require('behaviors.wow_wrath.Pallas.priest.common')

local options = {
    Name = "Priest (Shadow)",

    Widgets = {
        {
            type = "checkbox",
            uid = "shadowform",
            text = "Auto Shadowform",
            default = false
        },
        {
            type = "slider",
            uid = "ShadowSelfHeal",
            text = "Self heal Below %",
            default = 50,
            min = 0,
            max = 100
        },
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end


local function PriestShadowCombat()
    if Me.IsMounted then return end

    if not Me.InCombat then
        common:PowerWordFortitude()
        common:InnerFire()
    end

    if Me.HealthPct <= Settings.ShadowSelfHeal then
        if Spell.LesserHeal:CastEx(Me) then return end
    end

    common:PowerWordShield()

    local target = Combat.BestTarget
    if not target then return end

    if target.HealthPct > 20 then
        if Spell.MindBlast:CastEx(target) then return end
    end

    if not Spell.Shoot.IsAutoRepeat and Spell.Shoot:CastEx(target) then return end
end

local behaviors = {
    [BehaviorType.Combat] = PriestShadowCombat
}

return { Options = options, Behaviors = behaviors }
