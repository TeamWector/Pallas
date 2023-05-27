---@diagnostic disable: duplicate-set-field

local dispels = require('data.dispels')
local interrupts = require('data.interrupts')

---@enum SpellCastExFlags
SpellCastExFlags = {
  NoUsable = 0x1
}

local randomModifier = 0
local spellDelay = {}
local globalDelay = 0
---@type WoWUnit
WoWSpell.Target = nil
---@type boolean
WoWSpell.ignoreCastTime = false

SpellListener = wector.FrameScript:CreateListener()
SpellListener:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
SpellListener:RegisterEvent('UNIT_SPELLCAST_SENT')
SpellListener:RegisterEvent('CONSOLE_MESSAGE')

local queue = {}

---@param target WoWUnit @target, focus, me
---@param interrupt boolean Interrupt current cast
function WoWSpell:AddToQueue(target, interrupt)
  local slot = #queue + 1

  local object = {
    target = target,
    ability = self,
    interrupt = interrupt or false,
    timer = #queue == 0 and wector.Game.Time + 3000 or queue[#queue].timer + 3000
  }

  for _, v in pairs(queue) do
    if v.ability == self then return end
  end

  queue[slot] = object
  Alert("Queued: " .. self.Name .. " on " .. target.Name, 3)
end

function SpellListener:CONSOLE_MESSAGE(msg, color)
  if not string.find(msg, 'queue') then return end

  local target = string.match(msg, "queue%s*(%a*)%s*(%a+)")
  local ability = string.match(msg, "queue %a+ (%a+)")
  local interrupt = string.find(msg, "interrupt")

  if target and ability then
    ability = Spell[ability]

    if not ability or ability.Slot < 0 or ability:CooldownRemaining() > Me:GCDCooldown() then
      print("Spell Wasn't Added To Queue")
      return
    end

    if not target or (target == "target" and not Me.Target or target == "focus" and not Me.FocusTarget) then
      print("Invalid Target")
      return
    else
      target = (target == "target" and Me.Target or target == "focus" and Me.FocusTarget) or Me
    end

    ability:AddToQueue(target, interrupt)
  else
    print("Invalid Macro Expression")
  end
end

local is_queue_spell = false
local spellIdCast = 0
function SpellListener:UNIT_SPELLCAST_SENT(unit, target, castguid, spellID)
  spellIdCast = spellID
  if is_queue_spell then
    for k, q in pairs(queue) do
      if q.ability.Id == spellID then
        table.remove(queue, k)
        is_queue_spell = false
      end
    end
  end

  spellDelay[spellID] = wector.Game.Time + math.random(150, 300)
end

function SpellListener:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGuid, SpellID)
  if SpellID ~= spellIdCast then return end

  spellIdCast = 0

  local latency = Settings.PallasGlobalDelay and 100 or 0
  globalDelay = wector.Game.Time + latency
end

local exclusions = {
  [117952] = true,-- Crackling Jade Lightning
  [115175] = true, --Soothing Mist
  [357208] = true, -- Fire Breath
  [356995] = true,-- Disintegrate,
  [359073] = true,-- Eternity Surge
  [15407] = true,  -- Mind Flay
  [391403] = true, -- Mind flay V2
}

function WoWSpell:CastEx(a1, ...)
  if queue[1] then
    local ability = queue[1].ability
    local target = queue[1].target
    local interrupt = queue[1].interrupt

    if ability:IsUsable() and ability:InRange(target) then
      self = queue[1].ability
      a1 = target
      is_queue_spell = true

      if interrupt and Me.IsCastingOrChanneling then
        Me:StopCasting()
      end
    end

    for k, v in pairs(queue) do
      if v.timer < wector.Game.Time then
        table.remove(queue, k)
        return
      end
    end
  end

  local arg1, arg2, arg3 = a1, ...
  if not arg1 then return false end
  -- generic checks

  -- delay
  if spellDelay[self.Id] and spellDelay[self.Id] > wector.Game.Time then return false end
  if globalDelay > wector.Game.Time then return false end

  if not self.IsKnown and self.Slot > 0 then return false end

  -- is spell ready?
  if not self.IsReady then return false end

  -- are we already casting (i.e. actionbar button is highlighted)?
  if self.IsActive then return false end

  -- if spell has cast time, are we moving?
  if (self.CastTime > 0 or exclusions[self.Id]) and Me:IsMoving() and not self.ignoreCastTime then return false end

  if type(arg1) == 'userdata' and type(arg1.ToUnit) ~= 'nil' then
    -- cast at unit
    local unit = arg1.ToUnit
    local flags = arg2 and arg2 or 0x0

    -- is spell usable?
    if (flags & SpellCastExFlags.NoUsable) == 0 and not self:IsUsable() then return false end

    -- unit specific checks

    -- are we in range of unit?
    if self:HasRange(unit) and not self:InRange(unit) then return false end

    if not Me:WithinLineOfSight(unit) then return false end

    wector.Console:Log('Cast ' .. self.Name)

    WoWSpell.Target = arg1.ToUnit
    return self:Cast(arg1.ToUnit)
  else
    -- cast at position
    local x, y, z = 0, 0, 0
    if type(arg1) == 'userdata' and type(arg1.z) ~= 'nil' then
      -- is spell usable?
      if not self:IsUsable() then return false end

      -- Vec3 input
      x, y, z = arg1.x, arg1.y, arg1.z
    elseif arg2 and arg3 then
      -- x, y, z input
      x, y, z = arg1, arg2, arg3
    else
      -- unknown type
      return false
    end

    wector.Console:Log('Cast ' .. self.Name)
    return self:Cast(x, y, z)
  end
end

function WoWSpell:CooldownRemaining()
  local start, dur, enabled, modrate = self:GetCooldown()
  if dur ~= 0 then
    return start + dur - wector.Game.Time
  end

  return 0
end

function WoWSpell:HasRange(target)
  local min, max = 0, 0
  if target then
    min, max = self:GetRange(target)
  else
    min, max = self:GetRange()
  end

  return min > 0 or max > 0
end

function WoWSpell:CastRemaining()
  return self.CastEnd - wector.Game.Time
end

---@param unit WoWUnit? Unit to apply our aura to.
---@param condition boolean? condition to fulfill before applying
---@return boolean applied if we successfully applied our aura.
function WoWSpell:Apply(unit, condition)
  if not unit then
    print("No unit passed to function Apply")
    return false
  end

  if condition ~= nil then
    local type = type(condition)

    if type == "function" then
      if not condition() then return false end
    elseif type == "boolean" then
      if not condition then return false end
    else
      print("Invalid type as condition.")
      return false
    end
  end

  local aura = unit:GetAuraByMe(self.Name)
  -- Absolute corruption exception (Aura Remaining 0)
  if aura and (aura.Remaining > 2000 or aura.Remaining == 0) then return false end

  return self:CastEx(unit) or false
end

---@return boolean casted if we used our interrupt.
function WoWSpell:Interrupt()
  if self:CooldownRemaining() > 0 then return false end

  -- Create a slider in your behavior file with uid CommonInterruptPct to set your own kick pct.
  local kickpct = Settings.CommonInterruptPct or 35
  local units = Behavior:HasBehavior(BehaviorType.Combat) and Combat.Targets or wector.Game.Units
  -- We create a combobox with uid CommonInterrupts that has three values, disabled, any, whitelist.
  local kick = Settings.CommonInterrupts or 0

  if kick == 0 then return false end

  for _, unit in pairs(units) do
    local cast = unit.IsInterruptible and unit.CurrentSpell
    local validTarget = self:InRange(unit) and Me:IsFacing(unit)

    if (not cast or kick == 2 and not interrupts[cast.Id]) or not validTarget then goto continue end

    local channel = unit.CurrentChannel
    local castRemains = cast.CastEnd - wector.Game.Time
    local castTime = cast.CastEnd - cast.CastStart
    local castPctRemain = math.floor(castRemains / castTime * 100) + randomModifier
    local channeledTime = channel and (wector.Game.Time - channel.CastStart) + randomModifier * 10

    if (castPctRemain < kickpct or channel and channeledTime > 777) and self:CastEx(unit) then
      randomModifier = math.random(-15, 15)
      return true
    end

    ::continue::
  end

  return false
end

---@param ... table dispeltypes that we have access to Magic, Curse, Disease, Poison
---@param friends boolean if we are supposed to use this spell on our friends, otherwise will use it on enemies (Soothe, Purge, Tranq Shot)
---@param priority DispelPriority the priority level for the dispel. Defaults to Low if not provided.
---@return boolean casted if we casted dispel.
function WoWSpell:Dispel(friends, priority, ...)
  if self:CooldownRemaining() > 0 then return false end
  -- We create a combobox with uid CommonDispels that has three values, disabled, any, whitelist.
  local dispel = Settings.CommonDispels or 0

  if dispel == 0 then return false end

  local list = not friends and Combat.Targets or friends and WoWGroup:GetGroupUnits()

  if not list then
    print("No List Was Provided For Dispel")
    return false
  end

  local types = { ... }
  priority = priority or DispelPriority.Low

  for _, unit in pairs(list) do
    local auras = unit.IsActivePlayer and unit.VisibleAuras or unit.Auras
    for _, aura in pairs(auras) do
      if (friends and aura.IsDebuff or not friends and aura.IsBuff) and (dispel == 1 or dispels[aura.Id]) and aura.Remaining > 2000 then
        local dispelPriority = dispels[aura.Id]
        if (dispel == 1 or dispelPriority >= priority) and table.contains(types, aura.DispelType) then
          local durPassed = aura.Duration - aura.Remaining
          if durPassed > 777 and self:CastEx(unit) then
            print('cast dispel on target to remove ' .. aura.Name .. ' with priority ' .. priority)
            return true
          end
        end
      end
    end
  end

  return false
end
