local common = require('behaviors.wow_retail.shaman.common')


-- TALENTS
-- BYQAAAAAAAAAAAAAAAAAAAAAAAAAAAAgUSr0SSLJgg0okD0SJJEAAAAAAKBkIJhioISLJpBotAJIBA

local options = {
  -- The sub menu name
  Name = "Shaman PVP (Elemental)",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ShamanUseCooldowns",
      text = "Allow the usage of Big Cooldowns",
      default = true
    },
    {
      type = "checkbox",
      uid = "ShamanPurgeEnemies",
      text = "Use Purge",
      default = false
    },
  }
}

for k, v in pairs(common.widgets) do
  table.insert(options.Widgets, v)
end

local flag = false;

local function IsSurgeOfPower()
  return Me:HasVisibleAura("Surge of Power")
end

local function IsLavaSurge()
  return Me:HasVisibleAura("Lava Surge")
end

local function StormElemental()
  if Spell.StormElemental:CastEx(Me) then return true end
end

local function FlameOrFrostShockMoving(target)
  if Me:IsMoving() then
    if Spell.FlameShock:CastEx(target) or Spell.FrostShock:CastEx(target) then return true end
  end
end

-- Loop through all units find one without flame shock or lowest duration to cast Flame Shock
local function FlameShockEveryoneElse()
  for _, u in pairs(Combat.Targets) do
    if u.IsPlayer then
      local flameShockAura = u:GetAuraByMe("Flame Shock")
      if (not flameShockAura or flameShockAura.Remaining < 5400) and Spell.FlameShock:CastEx(u) then return true end
    end
  end
end

local function LavaBurstWithSurgeOfPower(target)
  if IsSurgeOfPower() and Spell.LavaBurst:CastEx(target) then return true end
end

local function LavaBurstWithLavaSurge(target)
  if IsLavaSurge() and target:HasAura("Flame Shock") and Spell.LavaBurst:CastEx(target) then return true end
end




local function FlameShock(target)
  local spell = Spell.FlameShock
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end

local function Icefury(target)
  local spell = Spell.Icefury
  if spell:CooldownRemaining() > 0 then return false end
  if spell:CastEx(target) then return true end
end

local function Earthquake(target)
  local spell = Spell.Earthquake
  if spell:CooldownRemaining() > 0 then return false end
  if Me:HasAura("Echoes of Great Sundering") and spell:CastEx(target) then return true end
end

local function Purge(priority)
  local spell = Spell.GreaterPurge
  if not Settings.ShamanPurgeEnemies then return false end

  if spell:Dispel(false, priority, WoWDispelType.Magic) then return true end
end

local function SkyfuryTotem()
  local spell = Spell.SkyfuryTotem
  if spell:CooldownRemaining() > 0 then return false end

  if Me:HasAura("Stormkeeper") or Me.Power > 79 and spell:CastEx(Me) then return end
end



local blacklist = {
  [61305] = "Polymorph (Cat)",
  [161354] = "Polymorph (Monkey)",
  [161355] = "Polymorph (Penguin)",
  [28272] = "Polymorph (Pig)",
  [161353] = "Polymorph (Polar Bear)",
  [126819] = "Polymorph (Porcupine)",
  [61721] = "Polymorph (Rabbit)",
  [118] = "Polymorph (Sheep)",
  [61780] = "Polymorph (Turkey)",
  [28271] = "Polymorph (Turtle)",
  [211015] = "Hex (Cockroach)",
  [210873] = "Hex (Compy)",
  [51514] = "Hex (Frog)",
  [211010] = "Hex (Snake)",
  [211004] = "Hex (Spider)",
}

local function GroundingTotem()
  for _, t in pairs(Combat.Targets) do
    if t.IsCastingOrChanneling then
      local spellInfo = t.SpellInfo
      local target = wector.Game:GetObjectByGuid(spellInfo.TargetGuid1)
      if (t.CurrentSpell) then
        local onBlacklist = blacklist[t.CurrentSpell.Id]
        if onBlacklist and Spell.GroundingTotem:CastEx(Me) then return end
      end
    end
  end
end


local function getMyTarget()
  local target = Me.Target
  if not target then return end

  -- copy-paste from combat.lua
  if not Me:CanAttack(target) then
    return
  elseif not target.InCombat or (not Settings.PallasAttackOOC and not target.InCombat) then
    return
  elseif target.Dead or target.Health <= 0 then
    return
  elseif target:GetDistance(Me.ToUnit) > 40 then
    return
  elseif target.IsTapDenied and (not target.Target or target.Target ~= Me) then
    return
  elseif target:IsImmune() then
    return
  end
  return target
end


local function ShamanElementalCombat()
  if wector.SpellBook.GCD:CooldownRemaining() > 0 then return end

  local target = getMyTarget()
  if target == nil then
    target = Combat.BestTarget
    if (not target) or (not target.IsPlayer) then return end
  end

  if Me.IsCastingOrChanneling then return end
  if not Me:IsFacing(target) then return end


  if common:AstralShift() then return end
  if common:EarthShield() then return end
  if common:LightningShield() then return end
  if common:FlametongueWeapon() then return end


  if common:DoInterrupt() then return end
  if Purge(DispelPriority.High) then return end
  if common:FireElemental(target) then return end
  if GroundingTotem() then return end
  if StormElemental() then return end
  if common:PrimordialWave(target) then return end
  if FlameShock(target) then return end
  if common:EarthShock(target) then return end
  if common:LightningBoltWithStormkeeper(target) then return end
  if Icefury(target) then return end
  if common:FrostShock(target) then return end
  if FlameShockEveryoneElse() then return end
  if LavaBurstWithLavaSurge(target) then return end
  if common:Stormkeeper() then return end
  if SkyfuryTotem() then return end
  if Earthquake(target) then return end
  if common:LavaBurst(target) then return end
  if Purge(DispelPriority.Medium) then return end
  if common:LightningBolt(target) then return end
  if Purge(DispelPriority.Low) then return end
  if FlameOrFrostShockMoving(target) then return end
end

local behaviors = {
  [BehaviorType.Combat] = ShamanElementalCombat
}

return { Options = options, Behaviors = behaviors }
