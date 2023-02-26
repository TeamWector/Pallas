local options = {
    Name = "Paladin (Prot)",
    Widgets = {
        {
            type = "slider",
            uid = "PaladinProtWogSelfPct",
            text = "Word Of Glory Self(%)",
            default = 50,
            min = 0,
            max = 100
        },
    }
}

local gcd = wector.SpellBook.GCD
local freewog = 327510
local consecration = 188370
local blessing_of_dawn = 385127
local divine_purpose = 223817

local function EyeOfTyr()
  if Spell.EyeOfTyr:CooldownRemaining() > 0 or table.length(Combat.Targets) < 2 or Me:IsMoving() then return end

  local allGathered = true
  for _, target in pairs(Combat.Targets) do
    if Me:GetDistance(target) > 8 then
      allGathered = false
    end
  end

  return allGathered and Spell.EyeOfTyr:CastEx(Me)
end

local function HammerOfWrath()
  if Spell.HammerOfWrath:CooldownRemaining() > 0 then return end

  for _, target in pairs(Combat.Targets) do
    if target.HealthPct < 20 and Spell.HammerOfWrath:CastEx(target, SpellCastExFlags.NoUsable) then return end
  end

  return false
end

-- Placeholder for now. NYI
local function GetHolyPower()
  return Me:GetPowerByType(PowerType.HolyPower)
end

local function PaladinProtCombat()
  local target = Tank.BestTarget
  if not target then return end

  local dawn = Me:GetAura(blessing_of_dawn)
  local has_dawn = dawn and dawn.Remaining > 10000

  -- OGCD Spells
  if has_dawn and Spell.ShieldOfTheRighteous:CastEx(target) then return end

  -- Lets do a GCD check so our priority is followed.
  if gcd:CooldownRemaining() > 0 then return end

  -- Keep priority down here.
  if Spell.Judgment:CastEx(target) then return end
  if HammerOfWrath() then return end
  if Spell.AvengersShield:CastEx(target) then return end
  if not Me:IsMoving() and not Me:GetAura(consecration) and Spell.Consecration:CastEx(Me) then return end
  if EyeOfTyr() then return end
  if Spell.BlessedHammer.Charges > 0 and Spell.BlessedHammer:CastEx(target) then return end
end

local function PaladinProtHeal()
  local shining_light = Me:GetAura(freewog)
  local lowest = Heal:GetLowestMember()

  if Me.HealthPct < Settings.PaladinProtWogSelfPct and Spell.WordOfGlory:CastEx(Me) then return end

  -- free world of glory
  if shining_light and shining_light.Remaining < 3000 and lowest and lowest.HealthPct < 100 and Spell.WordOfGlory:CastEx(lowest) then
    return
  end
end

local behaviors = {
  [BehaviorType.Tank] = PaladinProtCombat,
  [BehaviorType.Heal] = PaladinProtHeal
}

return { Options = options, Behaviors = behaviors }
