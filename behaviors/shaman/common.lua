local commonShaman = {}

commonShaman.widgets = {
    {
        type = "checkbox",
        uid = "ShamanInterrupt",
        text = "Interrupt",
        default = true
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
        type = "checkbox",
        uid = "Ghostwolf",
        text = "Auto Ghostwolf",
        default = true
    },
    {
        type = "slider",
        uid = "GhostwolfTime",
        text = "Ghostwolf Timer (MS)",
        default = 1500,
        min = 0,
        max = 5000
    },
}

ShamanListener = wector.FrameScript:CreateListener()
ShamanListener:RegisterEvent('PLAYER_STARTED_MOVING')
ShamanListener:RegisterEvent('PLAYER_STOPPED_MOVING')

local start = 0
function ShamanListener:PLAYER_STARTED_MOVING()
    start = wector.Game.Time
end

function ShamanListener:PLAYER_STOPPED_MOVING()
    start = 0
end

function commonShaman:Interrupt()
    if Settings.ShamanInterrupt then
        local units = wector.Game.Units
        for _, u in pairs(units) do
            if u:InCombatWithMe() and u.IsCastingOrChanneling then
                local cast = u.CurrentCast
                local timeLeft
                local random = math.random(0, 100)

                if cast then
                    timeLeft = cast.CastEnd - wector.Game.Time
                else
                    timeLeft = 0
                end

                if (timeLeft <= Settings.InterruptTime + random or u.IsChanneling) and Spell.WindShear:CastEx(u) then return end
            end
        end
    end
end

function commonShaman:Ghostwolf()
    local timespentmoving = 0

    if start ~= 0 then
        timespentmoving = wector.Game.Time - start
    end

    if Settings.Ghostwolf and timespentmoving > Settings.GhostwolfTime and not Me.InCombat then
        if not Me:HasVisibleAura(Spell.GhostWolf.Name) and Spell.GhostWolf:CastEx(Me) then return end
    end
end

return commonShaman
