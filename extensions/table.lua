---@param list table
table.length = function(list)
  local len = 0
  for _, _ in pairs(list) do
    len = len + 1
  end
  return len
end
