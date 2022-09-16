local options = {
  Name = "Autoloot",

  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ExtraAutoloot",
      text = "Enable Autoloot",
      default = true
    },
    {
      type = "checkbox",
      uid = "ExtraSkinning",
      text = "Enable Skinning",
      default = false
    },
    {
      type = "checkbox",
      uid = "ExtraBreakStealth",
      text = "Break Stealth",
      default = false
    },
    {
      type = "slider",
      uid = "LootCacheReset",
      text = "Cache Reset (MS)",
      default = 1500,
      min = 0,
      max = 10000
    }
  }
}

LootListener = wector.FrameScript:CreateListener()

local function tableContains(tbl, val)
  for i = 1, #tbl do
    if tbl[i] == val then
      return true
    end
  end

  return false
end

local function isInStealth()
  local stealth = Me.ShapeshiftForm == ShapeshiftForm.Stealth
  local prowl = Me.ShapeshiftForm == ShapeshiftForm.Cat and Me:HasAura("Prowl")
  return stealth or prowl
end

local looted = {}
local lastloot = 0
local function Autoloot()
  if not Settings.ExtraAutoloot then return end
  if not Settings.ExtraBreakStealth and isInStealth() then return end

  local units = wector.Game.Units

  if Me:IsMoving() or Me.IsCastingOrChanneling or (#Me:GetUnitsAround(10) > 0 and Me.InCombat) or Me.IsMounted then return end

  -- clean up looted cache
  local timesince = wector.Game.Time - lastloot
  if timesince > Settings.LootCacheReset and #looted > 0 then
    looted = {}
    lastloot = wector.Game.Time
  end

  for _, u in pairs(units) do
    local lootable = u.IsLootable
    local skinnable = u.UnitFlags == UnitFlags.Skinnable
    local inrange = Me:GetDistance(u) < 5
    local alreadylooted = tableContains(looted, u.Guid)
    local valid = u and u.Dead

    if valid and (Settings.ExtraSkinning and skinnable or lootable) and not alreadylooted and inrange then
      u:Interact()
      table.insert(looted, u.Guid)
      return
    end
  end
end

local behaviors = {
  [BehaviorType.Extra] = Autoloot
}

return { Options = options, Behaviors = behaviors }
