local behavior_map = require('data.specializations')

function WoWActivePlayer:Specialization()
  if wector.CurrentScript.Game == 'wow_retail' then
    return Me.Talents.ActiveSpecializationId
  elseif wector.CurrentScript.Game == 'wow_wrath' then
    -- on wrath pick the specialization that has the most talent points
    local bestspec = -1
    local bestspecpoints = -1
    for _, v in pairs(Me.Talents.ActiveTalentGroup.Tabs) do
      if v.Points > bestspecpoints then
        bestspec = v.Id
        bestspecpoints = v.Points
      end
    end
    return bestspec
  end
  return -1
end

--- Finds the specialization name based on class and current spec id
-- @return string: The specialization name
function WoWActivePlayer:SpecializationName()
  -- Trim the class name and convert to lower case
  local class_trim = self.ClassName:gsub("%s+", "")
  class_trim = class_trim:lower()

  -- Get the spec id
  local specid = Me:Specialization()

  -- Get the specname from the behavior_map
  local specname = behavior_map[class_trim][specid]

  return specname
end
