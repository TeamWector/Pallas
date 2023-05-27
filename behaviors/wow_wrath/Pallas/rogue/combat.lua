local options = {
  -- The sub menu name
  Name = "Rogue (Combat)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "RogueCommonInStealth",
      text = "Attack in stealth",
      default = false
    },
  }
}

local spells = {
  -- general
  Kick = WoWSpell("Kick"),

  -- generators
  SinisterStrike = WoWSpell("Sinister Strike"),

  -- spenders
  SliceAndDice = WoWSpell("Slice and Dice"),
  Eviscerate = WoWSpell("Eviscerate"),
  KidneyShot = WoWSpell("Kidney Shot"),

  -- talents
  Riposte = WoWSpell("Riposte"),

  -- Stealth only
  CheapShot = WoWSpell("Cheap Shot"),
}

local function StealthRotation(target)
  if spells.CheapShot:CastEx(target) then return end
end

local function interrupt()
  local target = Combat.BestTarget
  if not target then return false end
  local comboPoints = Me:GetPowerByType(PowerType.Obsolete)

  for _, u in pairs(Combat.Targets) do
    local castorchan = u.IsCastingOrChanneling
    local spell = u.CurrentSpell

    -- Kick
    if castorchan and spell and Me:InMeleeRange(u) and spells.Kick:CastEx(target) then return false end

    -- Kidney Shot
    if castorchan and spell and Me:InMeleeRange(u) and spells.KidneyShot:CastEx(target) then return false end
  end

  return false
end

local function RogueCombatCombat()
  local target = Combat.BestTarget
  if not target then return end

  -- Start combat behaviors

  -- only attack melee
  if not Me:InMeleeRange(target) then return end

  interrupt()

  -- Stealth rotation
  if Settings.RogueCombatInStealth and (Me.ShapeshiftForm & ShapeshiftForm.Stealth) then
    StealthRotation(target)
    return
  end

  local comboPoints = Me:GetPowerByType(PowerType.Obsolete)
  if not Me:HasAura("Slice and Dice") and comboPoints > 2 and spells.SliceAndDice:CastEx(target) then return end

  if spells.Riposte:CastEx(target) then return end

  if spells.SinisterStrike:CastEx(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = RogueCombatCombat
}

return { Options = options, Behaviors = behaviors }
