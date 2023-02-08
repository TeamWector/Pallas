---@param list table
table.length = function(list)
  local len = 0
  for _, _ in pairs(list) do
    len = len + 1
  end
  return len
end

table.contains = function(tbl, value)
  for k, v in pairs(tbl) do
    if value == v then
      return true
    end
  end

  return false
end
