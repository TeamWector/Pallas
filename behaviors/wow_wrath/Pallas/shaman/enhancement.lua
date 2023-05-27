local common = require('behaviors.shaman.common')

local options = {
    -- The sub menu name
    Name = "Shaman (Enh)",

    -- widgets
    Widgets = {
        {
            type = "checkbox",
            uid = "shamanrage",
            text = "Auto Shamanistic Rage",
            default = false
        },
    }
}

for k, v in pairs(common.widgets) do
    table.insert(options.Widgets, v)
end

local lastenchanted = 0
local firstenchant = false
local function WeaponEnchant()
    local passed = (wector.Game.Time - lastenchanted) / 1000

    if not firstenchant then
        if Spell.FlametongueWeapon:CastEx(Me) then
            firstenchant = true
            lastenchanted = wector.Game.Time
            return
        end
    end

    if passed > 900 then
        if Spell.FlametongueWeapon:CastEx(Me) then
            lastenchanted = wector.Game.Time
        end
    end
end

local function ShamanEnhancementCombat()
    if Me.IsMounted then return end

    WeaponEnchant()
    common:Ghostwolf()
    common:Interrupt()
    common:Shield()

    local target = Combat.BestTarget
    if not target then return end

    if not Me:IsAttacking(target) then Me:StartAttack(target) end

    if target:TimeToDeath() > 10 and not target:HasDebuffByMe(Spell.FlameShock.Name) and Spell.FlameShock:CastEx(target) then return end
    if target.InCombat and Spell.EarthShock:CastEx(target) then return end
end

local behaviors = {
    [BehaviorType.Combat] = ShamanEnhancementCombat
}

return { Options = options, Behaviors = behaviors }
