local commonEvoker = {}

function commonEvoker:GetEmpowerLevel()
  local empowerspells = {
    firebreath = Spell.FireBreath.OverrideId,
    eternitySurge = Spell.EternitySurge.OverrideId
  }

  local cSpell = Me.CurrentChannel

  if not cSpell or not table.contains(empowerspells, cSpell.Id) then return 0 end

  local castDuration = cSpell.CastEnd - cSpell.CastStart
  local castPct = cSpell:CastRemaining() / castDuration * 100

  if castPct <= 0 then
    return 4
  elseif castPct < 25 then
    return 3
  elseif castPct < 50 then
    return 2
  elseif castPct < 75 then
    return 1
  end

  return 0
end

return commonEvoker
