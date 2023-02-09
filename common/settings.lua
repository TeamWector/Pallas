Settings = setmetatable({
  Character = {}
},
{
  __index = function(tbl, key)
    local raw = rawget(tbl, key)
    if raw ~= nil then return raw end

    local char = rawget(tbl, 'Character')
    if not char then return end
    local mine = rawget(char, string.format('player%d', Me.Guid.Low))
    if not mine then return end

    local value = rawget(mine, key)
    local int = math.tointeger(value)
    if value == nil then return end
    if type(value) == 'boolean' then return value end
    if int then return int end

    return value
  end,
  __newindex = function(tbl, key, value)
    local raw = rawget(tbl, key)
    if raw ~= nil then return raw end

    local char = rawget(tbl, 'Character')
    if not char then return end
    local mine = rawget(char, string.format('player%d', Me.Guid.Low))
    if not mine then
      rawset(char, string.format('player%d', Me.Guid.Low), {})
      mine = rawget(char, string.format('player%d', Me.Guid.Low))
    end

    rawset(mine, key, value)
  end
})

return Settings
