local gametype = wector.CurrentScript.Game
local options = {
  Name = "Autoloot",
  -- widgets
  Widgets = {
    {
      type = "checkbox",
      uid = "ExtraAutoloot",
      text = "Enable Autoloot",
      default = false
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
      text = gametype == "wow_wrath" and "Cache Reset (MS)" or gametype == "wow_retail" and "Pulse Time (MS)",
      default = 1500,
      min = 0,
      max = 10000
    }
  }
}

local function isInStealth()
  local stealth = Me.ShapeshiftForm == ShapeshiftForm.Stealth
  local prowl = Me.ShapeshiftForm == ShapeshiftForm.Cat and Me:HasAura("Prowl")
  return stealth or prowl
end

local function GetLootableUnit()
  local units = wector.Game.Units
  for _, u in pairs(units) do
    local lootable = u.IsLootable
    local skinnable = (u.UnitFlags & UnitFlags.Skinnable) > 0
    local inrange = Me:InInteractRange(u)
    local valid = u and u.Dead

    if valid and inrange and lootable then
      return u
    end

    if Settings.ExtraSkinning and inrange and skinnable then
      return u
    end
  end
end

local looted = {}
local lastloot = 0
local function Autoloot()
  if not Settings.ExtraAutoloot then return end
  if not Settings.ExtraBreakStealth and isInStealth() then return end

  local units = wector.Game.Units

  if Me:IsMoving() or Me.IsCastingOrChanneling or (#Me:GetUnitsAround(10) > 0 and Me.InCombat) or
      Me.IsMounted then
    return
  end

  -- clean up looted cache
  local timesince = wector.Game.Time - lastloot
  if timesince > Settings.LootCacheReset and #looted > 0 then
    looted = {}
    lastloot = wector.Game.Time
  end

  if gametype == 'wow_wrath' then
    for _, u in pairs(units) do
      local lootable = u.IsLootable
      local skinnable = (u.UnitFlags & UnitFlags.Skinnable) > 0
      local inrange = Me:InInteractRange(u)
      local alreadylooted = table.contains(looted, u.Guid)
      local valid = u and u.Dead

      if valid and (Settings.ExtraSkinning and skinnable or lootable) and not alreadylooted and inrange then
        u:Interact()
        table.insert(looted, u.Guid)
        return
      end
    end
  end

  if gametype == 'wow_retail' then
    local lootunit = GetLootableUnit()
    if lootunit and wector.Game.Time > lastloot then
      lootunit:Interact()
      lastloot = wector.Game.Time + Settings.LootCacheReset
      return
    end
  end
end

local behaviors = {
  [BehaviorType.Extra] = Autoloot
}

return { Options = options, Behaviors = behaviors }
