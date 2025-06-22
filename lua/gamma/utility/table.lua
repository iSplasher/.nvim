local M = {}

---A helper function to turn a table into a string.
---@param tbl table @The table.
---@param depth? number @The depth of sub-tables to traverse through.
---@param indent? number @Do NOT manually set this. This controls formatting through recursion.
---@return string @The string representation of the table.
function M.table_to_string(tbl, depth, indent)
  indent = indent or 0
  depth = depth or 5
  local str = ""
  
  if depth == 0 then
    return string.rep("  ", indent) .. "..."
  end

  if type(tbl) ~= "table" then
    return tostring(tbl)
  end

  -- Check if table is empty
  if next(tbl) == nil then
    return "{}"
  end

  -- Check if table is array-like
  local is_array = true
  local max_index = 0
  for k, _ in pairs(tbl) do
    if type(k) ~= "number" or k <= 0 or k ~= math.floor(k) then
      is_array = false
      break
    end
    max_index = math.max(max_index, k)
  end

  -- For arrays, check if indices are contiguous
  if is_array then
    for i = 1, max_index do
      if tbl[i] == nil then
        is_array = false
        break
      end
    end
  end

  str = str .. "{\n"

  if is_array then
    -- Format as array
    for i = 1, max_index do
      local value = tbl[i]
      str = str .. string.rep("  ", indent + 1)

      if type(value) == "table" then
        str = str .. M.table_to_string(value, depth - 1, indent + 1)
      elseif type(value) == "string" then
        str = str .. string.format("%q", value)
      elseif type(value) == "function" then
        str = str .. "<function>"
      elseif type(value) == "nil" then
        str = str .. "nil"
      elseif type(value) == "boolean" then
        str = str .. tostring(value)
      else
        str = str .. tostring(value)
      end

      if i < max_index then
        str = str .. ","
      end
      str = str .. "\n"
    end
  else
    -- Format as dictionary
    local keys = {}
    for k, _ in pairs(tbl) do
      table.insert(keys, k)
    end

    -- Sort keys for consistent output
    table.sort(keys, function(a, b)
      local ta, tb = type(a), type(b)
      if ta == tb then
        if ta == "string" or ta == "number" then
          return tostring(a) < tostring(b)
        end
      end
      return ta < tb
    end)

    for i, key in ipairs(keys) do
      local value = tbl[key]
      str = str .. string.rep("  ", indent + 1)

      -- Format key
      if type(key) == "string" then
        if key:match("^[%a_][%w_]*$") then
          str = str .. key -- Valid identifier, no quotes needed
        else
          str = str .. "[" .. string.format("%q", key) .. "]"
        end
      elseif type(key) == "number" then
        str = str .. "[" .. tostring(key) .. "]"
      else
        str = str .. "[" .. tostring(key) .. "]"
      end

      str = str .. " = "

      -- Format value
      if type(value) == "table" then
        str = str .. M.table_to_string(value, depth - 1, indent + 1)
      elseif type(value) == "string" then
        str = str .. string.format("%q", value)
      elseif type(value) == "function" then
        str = str .. "<function>"
      elseif type(value) == "nil" then
        str = str .. "nil"
      elseif type(value) == "boolean" then
        str = str .. tostring(value)
      else
        str = str .. tostring(value)
      end

      if i < #keys then
        str = str .. ","
      end
      str = str .. "\n"
    end
  end

  str = str .. string.rep("  ", indent) .. "}"
  return str
end

M.format_table = M.table_to_string -- Alias for table_to_string

---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth? number @The depth of sub-tables to traverse through and print.
function M.print_table(tbl, depth)
  print(M.table_to_string(tbl, depth));
end

---A helper function to deep merge two tables.
---@param a table @The first table to merge.
---@param b table @The second table(s) to merge. (overwrites)
---@return table @The merged table.
function M.merge_table(a, b)
  if type(a) == 'table' and type(b) == 'table' then
    for k, v in pairs(b) do
      if type(v) == 'table' and type(a[k] or false) == 'table' then
        M.merge_table(a[k], v)
      else
        a[k] = v
      end
    end
  end
  return a
end

---A helper function to deep merge two tables.
---@param a table @The first table to merge.
---@param b table[] @The  tables to merge. (overwrites)
---@return table @The merged table.
function M.merge_tables(a, b)
  for _, t in ipairs(b) do
    a = M.merge_table(a, t)
  end
  return a
end

return M