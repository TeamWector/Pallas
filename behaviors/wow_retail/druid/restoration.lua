local options = {
  -- The sub menu name
  Name = "Druid (Resto)",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "DruidRestoDPS",
      text = "Enable DPS",
      default = false
    },
    {
      type = "checkbox",
      uid = "DruidRestoEfflorescence",
      text = "Use Efflorescence (experimental)",
      default = false
    }
  }
}

local function CalculateNearbyFriendlies(loc, range)
  local count = 0

  local group = WoWGroup(GroupType.Auto)
  local members = group.Members
  for _, member in pairs(members) do
    local unit = wector.Game:GetObjectByGuid(member.Guid)
    if unit and loc:DistanceSq(unit.Position) < range then
      count = count + 1
    end
  end
  return count
end

-- XXX: Testing, very buggy right now
local function CalculateEfflorescencePosition()
  local range = 40.0
  local node_size = 5.0
  local origin = Me.Position
  origin.z = origin.z + Me.DisplayHeight
  local best_position = Vec3(0.0, 0.0, 0.0)
  local best_count = 0

  for x = origin.x - range, origin.x + range, node_size do
    for y = origin.y - range, origin.y + range, node_size do
      local from = Vec3(x, y, origin.z)
      local to = Vec3(x, y, 0.0)
      local hitflags = TraceLineHitFlags.WmoCollision | TraceLineHitFlags.Terrain
      local intersected, result = wector.World:TraceLineWithResult(from, to, hitflags)
      if intersected then
        -- XXX: zdelta is bogus sometimes which screws everything up
        local zdelta = 5.0 - math.abs(result.Hit.z - origin.z)
        origin.z = origin.z + zdelta

        result.Hit.z = result.Hit.z + 0.1
        if not wector.World:TraceLine(origin, result.Hit, TraceLineHitFlags.WmoCollision) then
          -- calculate nearby friendly units
          local num = CalculateNearbyFriendlies(result.Hit, 10)
          if num > best_count then
            best_position = result.Hit
            best_count = num
          end
        end
      end
    end
  end

  return best_position
end

local function DruidRestoDamage()
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

  if Me.ShapeshiftForm == ShapeshiftForm.Normal then
    if Me:InMeleeRange(target) and Me:IsFacing(target) and Spell.CatForm:CastEx(Me) then return end
  end

  if Me.ShapeshiftForm == ShapeshiftForm.Cat then
    if not target:HasDebuffByMe("Rake") and Spell.Rake:CastEx(target) then return end
    if not target:HasDebuffByMe("Thrash") and Spell.Thrash:CastEx(target) then return end
    if Me:GetPowerByType(PowerType.ComboPoints) == 5 and Spell.FerociousBite:CastEx(target) then return end
    if #target:GetUnitsAround(10) > 2 then
      if Spell.Swipe:CastEx(target) then return end
    else
      if Spell.Shred:CastEx(target) then return end
    end
  end
end

local efflorescence_time = 0
local efflorescence_pos = Vec3(0.0, 0.0, 0.0)
local function DruidRestoHeal()
  if Me.Dead then return end
  if Me:IsStunned() then return end
  if Me.IsCastingOrChanneling then return end
  if Me.StandStance == StandStance.Sit then return end
  if (Me.MovementFlags & MovementFlags.Flying) > 0 then return end

  if Me.ShapeshiftForm == ShapeshiftForm.Bear or
      Me.ShapeshiftForm == ShapeshiftForm.DireBear then return end

  if Me.ShapeshiftForm ~= ShapeshiftForm.Travel then

  end

  local wildgrowth = false
  if table.length(Heal.PriorityList) > 3 then
    wildgrowth = true
  end

  if Settings.DruidRestoEfflorescence then
    -- XXX: Testing, very buggy right now
    if wildgrowth and wector.Game.Time - efflorescence_time > 15000 then
      local efflo_pos = CalculateEfflorescencePosition()
      if efflo_pos.x ~= 0.0 and efflorescence_pos:DistanceSq(efflo_pos) > 30 then
        if Spell.Efflorescence:CastEx(efflo_pos) then
          efflorescence_time = wector.Game.Time
          return
        end
      end
    end
  end

  for _, v in pairs(Heal.PriorityList) do
    ---@type WoWUnit
    local u = v.Unit
    local prio = v.Priority

    if wildgrowth and Spell.WildGrowth:CastEx(u) then return end


    if u.HealthPct < 50 and Spell.CenarionWard:CastEx(u) then return end
    if u.HealthPct < 50 and (u:HasBuffByMe("Rejuvenation") or u:HasBuffByMe("Regrowth")) and
        Spell.Swiftmend:CastEx(u, SpellCastExFlags.NoUsable) then return end
    if u.HealthPct < 92 and not u:HasBuffByMe("Rejuvenation") and Spell.Rejuvenation:CastEx(u) then return end

    -- Max level uses Nourish as filler, low level uses Regrowth
    if Spell.Nourish.IsKnown then
      if u.HealthPct < 70 and
          (u:HasBuffByMe("Rejuvenation") or u:HasBuffByMe("Regrowth") or u:HasBuffByMe("Wild Growth") or
              u:HasBuffByMe("Lifebloom")) and Spell.Nourish:CastEx(u) then return end
    else
      if u.HealthPct < 70 and (not u:HasBuffByMe("Regrowth") or u.HealthPct < 60) and Spell.Regrowth:CastEx(u) then return end
    end
  end

  --[[
  for _, v in pairs(Heal.PriorityList) do
    ---@type WoWUnit
    local unit = v.Unit
    local auras = unit.VisibleAuras
    for _, aura in pairs(auras) do
      if aura.DispelType ==
    end
  end
  ]]

  for _, v in pairs(Heal.Tanks) do
    ---@type WoWUnit
    local u = v.Unit

    -- this is a mess but works
    local lifebloom = u:GetAuraByMe("Lifebloom")
    if not lifebloom and Spell.Lifebloom:CastEx(u) then return end
    --if lifebloom and u.InCombat then
    --  if u.HealthPct < 90 and lifebloom.Stacks < 1 and Spell.Lifebloom:CastEx(u) then return end
    --  if u.HealthPct < 80 and lifebloom.Stacks < 2 and Spell.Lifebloom:CastEx(u) then return end
    --  if u.HealthPct < 70 and lifebloom.Stacks < 3 and Spell.Lifebloom:CastEx(u) then return end
    --  --if lifebloom.Remaining < 2500 and u.HealthPct > 70 and Spell.Lifebloom:CastEx(u) then return end
    --end
  end

  if Settings.DruidRestoDPS then
    DruidRestoDamage()
  end
end

return {
  Options = options,
  Behaviors = {
    [BehaviorType.Heal] = DruidRestoHeal,
  }
}
