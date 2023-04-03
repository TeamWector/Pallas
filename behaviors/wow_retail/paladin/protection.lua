local common = require("behaviors.wow_retail.paladin.common")

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

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local gcd = wector.SpellBook.GCD

local auras = {
  shininglight = 327510,
  consecration = 188370,
  divinepurpose = 223817
}

local function Consecration()
  local spell = Spell.Consecration
  if spell:CooldownRemaining() > 0 then return false end

  return not Me:IsMoving() and not Me:HasAura(auras.consecration) and spell:CastEx(Me)
end

local function ShieldOfTheRighteous()
  local spell = Spell.ShieldOfTheRighteous
  local holypower = common:GetHolyPower()

  if holypower < 3 then return false end

  for _, target in pairs(Tank.Targets) do
    if Me:GetDistance(target) <= 6 and Me:IsFacing(target) then
      return spell:CastEx(Me)
    end
  end
end

local function Judgment(enemy)
  local spell = Spell.Judgment
  if spell:CooldownRemaining() > 0 then return false end

  return spell:CastEx(enemy)
end

local function AvengersShield(enemy)
  local spell = Spell.AvengersShield
  if spell:CooldownRemaining() > 0 then return false end

  if spell:Interrupt() then wector.Console:Log("Interrupt Shield") return true end

  return spell:CastEx(enemy)
end

local function BlessedHammer()
  local spell = Spell.BlessedHammer
  if spell:CooldownRemaining() > 0 then return end

  return Combat.EnemiesInMeleeRange > 0 and spell:CastEx(Me)
end

local function PaladinProtCombat()
  local target = Tank.BestTarget
  if not target then return end

  -- Lets do a GCD check so our priority is followed.
  if gcd:CooldownRemaining() > 0 then return end

  -- Keep priority down here.
  if common:DoInterrupt() then return end
  if Consecration() then return end
  if ShieldOfTheRighteous() then return end
  if Judgment(target) then return end
  if common:HammerOfWrath() then return end
  if AvengersShield(target) then return end
  if BlessedHammer() then return end
end

local function PaladinProtHeal()
  local shining_light = Me:GetAura(auras.shininglight)
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
