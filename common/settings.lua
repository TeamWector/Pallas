Settings = setmetatable({
  Core = {
    AutoTarget = false,
    AttackOutOfCombat = false
  },
  Character = {}
},
{
  __index = function(tbl, key)
    local raw = rawget(tbl, key)
    if raw ~= nil then return raw end

    local me = wector.Game.ActivePlayer
    if not me or me.NameUnsafe == "Unknown" then return end

    local char = rawget(tbl, 'Character')
    if not char then return end
    local mine = rawget(char, me.NameUnsafe)
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

    local me = wector.Game.ActivePlayer
    if not me or me.NameUnsafe == "Unknown" then return end

    local char = rawget(tbl, 'Character')
    if not char then return end
    local mine = rawget(char, me.NameUnsafe)
    if not mine then
      mine = rawset(char, me.NameUnsafe, {})
    end

    rawset(mine, key, value)
  end
})

return Settings
