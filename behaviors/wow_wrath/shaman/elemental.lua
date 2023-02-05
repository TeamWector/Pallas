local options = {
    -- The sub menu name
    Name = "Shaman (Ele)",

    -- widgets
    Widgets = {
        {
            type = "checkbox",
            uid = "placeholder",
            text = "placeholder",
            default = false
        },
    }
}

local function ShamanElementalCombat()
end

local behaviors = {
    [BehaviorType.Combat] = ShamanElementalCombat
}

return { Options = options, Behaviors = behaviors }
