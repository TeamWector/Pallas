local commonEvoker = {}

commonEvoker.widgets = {
  {
    type = "text",
    uid = "EvokerGeneralText",
    text = ">> General <<",
  },
  {
    type = "combobox",
    uid = "CommonDispels",
    text = "Dispel",
    default = 0,
    options = { "Disabled", "Any", "Whitelist" }
  },
}

local empowerWanted = 0
---Sets our desired empower level to release a empowered spell at.
---@param level number level to release our empowered spell at.
function commonEvoker:EmpowerTo(level)
  empowerWanted = level
  return true
end

---Handles empower spells, releases them at the right timing.
function commonEvoker:EmpowerHandler()
  local empowerLevel = self:GetEmpowerLevel()
  local empowerDone = empowerWanted > 0 and empowerLevel >= empowerWanted

  if empowerDone then
    local currentSpell = WoWSpell(Me.CurrentSpell.Id)

    if currentSpell.Id == Spell.EternitySurge.OverrideId then
      currentSpell = Spell.EternitySurge
    elseif currentSpell.Id == Spell.FireBreath.OverrideId then
      currentSpell = Spell.FireBreath
    elseif currentSpell.Id == Spell.DreamBreath.OverrideId then
      currentSpell = Spell.DreamBreath
    elseif currentSpell.Id == Spell.Spiritbloom.OverrideId then
      currentSpell = Spell.Spiritbloom
    end

    currentSpell:Cast(Me)
    empowerWanted = 0
  end
end

---@return number empowerlevel the current empowered spells level/stage
function commonEvoker:GetEmpowerLevel()
  local empowerspells = {
    firebreath = Spell.FireBreath.OverrideId,
    eternitySurge = Spell.EternitySurge.OverrideId,
    dreambreath = Spell.DreamBreath.OverrideId,
    spiritbloom = Spell.Spiritbloom.OverrideId
  }

  local cSpell = Me.CurrentChannel

  if not cSpell or not table.contains(empowerspells, cSpell.Id) then return 0 end

  local castDuration = cSpell.CastEnd - cSpell.CastStart
  local castPct = cSpell:CastRemaining() / castDuration * 100

  if castPct <= 1 then
    return 4
  elseif castPct <= 25 then
    return 3
  elseif castPct <= 50 then
    return 2
  elseif castPct <= 75 then
    return 1
  end

  return 0
end

return commonEvoker
